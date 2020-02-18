//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// UNSUPPORTED: libcpp-has-no-threads
// XFAIL: c++98, c++03

// <atomic>

#include <atomic>
#include <type_traits>
#include <cassert>
#include <thread>

#include "test_macros.h"
#include "../atomics.types.operations.req/atomic_helpers.h"

template <class T>
struct TestFn {
  void operator()() const {
    typedef std::atomic<T> A;

    A t;
    std::atomic_init(&t, T(1));
    assert(std::atomic_load(&t) == T(1));
    std::atomic_wait(&t, T(0));
    std::thread t_([&](){
      std::atomic_store(&t, T(3));
      std::atomic_notify_one(&t);
    });
    std::atomic_wait(&t, T(1));
    t_.join();

    volatile A vt;
    std::atomic_init(&vt, T(2));
    assert(std::atomic_load(&vt) == T(2));
    std::atomic_wait(&vt, T(1));
    std::thread t2_([&](){
      std::atomic_store(&vt, T(4));
      std::atomic_notify_one(&vt);
    });
    std::atomic_wait(&vt, T(2));
    t2_.join();
  }
};

int main(int, char**)
{
    TestEachAtomicType<TestFn>()();

  return 0;
}
