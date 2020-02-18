//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// UNSUPPORTED: libcpp-has-no-threads
// UNSUPPORTED: c++98, c++03, c++11

// <semaphore>

#include <semaphore>
#include <thread>

#include "test_macros.h"

int main(int, char**)
{
  static_assert(std::counting_semaphore<>::max() > 0, "");
  static_assert(std::counting_semaphore<1>::max() >= 1, "");
  static_assert(std::counting_semaphore<std::numeric_limits<int>::max()>::max() >= 1, "");
  static_assert(std::counting_semaphore<std::numeric_limits<unsigned>::max()>::max() >= 1, "");
  static_assert(std::counting_semaphore<std::numeric_limits<ptrdiff_t>::max()>::max() >= 1, "");
  static_assert(std::counting_semaphore<1>::max() == std::binary_semaphore::max(), "");
  return 0;
}
