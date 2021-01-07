//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// WARNING: This test was generated by generate_feature_test_macro_components.py
// and should not be edited manually.

// UNSUPPORTED: libcpp-has-no-threads

// <latch>

// Test the feature test macros defined by <latch>

/*  Constant           Value
    __cpp_lib_latch    201907L [C++20]
*/

#include <latch>
#include "test_macros.h"

#if TEST_STD_VER < 14

# ifdef __cpp_lib_latch
#   error "__cpp_lib_latch should not be defined before c++20"
# endif

#elif TEST_STD_VER == 14

# ifdef __cpp_lib_latch
#   error "__cpp_lib_latch should not be defined before c++20"
# endif

#elif TEST_STD_VER == 17

# ifdef __cpp_lib_latch
#   error "__cpp_lib_latch should not be defined before c++20"
# endif

#elif TEST_STD_VER == 20

# if !defined(_LIBCPP_HAS_NO_THREADS)
#   ifndef __cpp_lib_latch
#     error "__cpp_lib_latch should be defined in c++20"
#   endif
#   if __cpp_lib_latch != 201907L
#     error "__cpp_lib_latch should have the value 201907L in c++20"
#   endif
# else
#   ifdef __cpp_lib_latch
#     error "__cpp_lib_latch should not be defined when !defined(_LIBCPP_HAS_NO_THREADS) is not defined!"
#   endif
# endif

#endif // TEST_STD_VER == 20

int main(int, char**) { return 0; }
