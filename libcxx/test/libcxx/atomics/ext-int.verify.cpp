//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <atomic>

// Make sure that `std::atomic` doesn't work with `_ExtInt`. The intent is to
// disable them for now until their behavior can be designed better later.
// See https://reviews.llvm.org/D84049 for details.

// UNSUPPORTED: clang-4, clang-5, clang-6, clang-7, clang-8, clang-9, clang-10
// UNSUPPORTED: apple-clang-9, apple-clang-10, apple-clang-11, apple-clang-12

#include <atomic>

int main(int, char**)
{
  // expected-error@atomic:*1 {{_Atomic cannot be applied to integer type '_ExtInt(32)'}}
  std::atomic<_ExtInt(32)> x {42};

  return 0;
}
