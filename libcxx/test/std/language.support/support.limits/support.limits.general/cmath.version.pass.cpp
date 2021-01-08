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

// <cmath>

// Test the feature test macros defined by <cmath>

/*  Constant                            Value
    __cpp_lib_hypot                     201603L [C++17]
    __cpp_lib_interpolate               201902L [C++20]
    __cpp_lib_math_special_functions    201603L [C++17]
*/

#include <cmath>
#include "test_macros.h"

#if TEST_STD_VER < 14

# ifdef __cpp_lib_hypot
#   error "__cpp_lib_hypot should not be defined before c++17"
# endif

# ifdef __cpp_lib_interpolate
#   error "__cpp_lib_interpolate should not be defined before c++20"
# endif

# ifdef __cpp_lib_math_special_functions
#   error "__cpp_lib_math_special_functions should not be defined before c++17"
# endif

#elif TEST_STD_VER == 14

# ifdef __cpp_lib_hypot
#   error "__cpp_lib_hypot should not be defined before c++17"
# endif

# ifdef __cpp_lib_interpolate
#   error "__cpp_lib_interpolate should not be defined before c++20"
# endif

# ifdef __cpp_lib_math_special_functions
#   error "__cpp_lib_math_special_functions should not be defined before c++17"
# endif

#elif TEST_STD_VER == 17

# ifndef __cpp_lib_hypot
#   error "__cpp_lib_hypot should be defined in c++17"
# endif
# if __cpp_lib_hypot != 201603L
#   error "__cpp_lib_hypot should have the value 201603L in c++17"
# endif

# ifdef __cpp_lib_interpolate
#   error "__cpp_lib_interpolate should not be defined before c++20"
# endif

# if !defined(_LIBCPP_VERSION)
#   ifndef __cpp_lib_math_special_functions
#     error "__cpp_lib_math_special_functions should be defined in c++17"
#   endif
#   if __cpp_lib_math_special_functions != 201603L
#     error "__cpp_lib_math_special_functions should have the value 201603L in c++17"
#   endif
# else // _LIBCPP_VERSION
#   ifdef __cpp_lib_math_special_functions
#     error "__cpp_lib_math_special_functions should not be defined because it is unimplemented in libc++!"
#   endif
# endif

#elif TEST_STD_VER == 20

# ifndef __cpp_lib_hypot
#   error "__cpp_lib_hypot should be defined in c++20"
# endif
# if __cpp_lib_hypot != 201603L
#   error "__cpp_lib_hypot should have the value 201603L in c++20"
# endif

# ifndef __cpp_lib_interpolate
#   error "__cpp_lib_interpolate should be defined in c++20"
# endif
# if __cpp_lib_interpolate != 201902L
#   error "__cpp_lib_interpolate should have the value 201902L in c++20"
# endif

# if !defined(_LIBCPP_VERSION)
#   ifndef __cpp_lib_math_special_functions
#     error "__cpp_lib_math_special_functions should be defined in c++20"
#   endif
#   if __cpp_lib_math_special_functions != 201603L
#     error "__cpp_lib_math_special_functions should have the value 201603L in c++20"
#   endif
# else // _LIBCPP_VERSION
#   ifdef __cpp_lib_math_special_functions
#     error "__cpp_lib_math_special_functions should not be defined because it is unimplemented in libc++!"
#   endif
# endif

#elif TEST_STD_VER > 20

# ifndef __cpp_lib_hypot
#   error "__cpp_lib_hypot should be defined in c++2b"
# endif
# if __cpp_lib_hypot != 201603L
#   error "__cpp_lib_hypot should have the value 201603L in c++2b"
# endif

# ifndef __cpp_lib_interpolate
#   error "__cpp_lib_interpolate should be defined in c++2b"
# endif
# if __cpp_lib_interpolate != 201902L
#   error "__cpp_lib_interpolate should have the value 201902L in c++2b"
# endif

# if !defined(_LIBCPP_VERSION)
#   ifndef __cpp_lib_math_special_functions
#     error "__cpp_lib_math_special_functions should be defined in c++2b"
#   endif
#   if __cpp_lib_math_special_functions != 201603L
#     error "__cpp_lib_math_special_functions should have the value 201603L in c++2b"
#   endif
# else // _LIBCPP_VERSION
#   ifdef __cpp_lib_math_special_functions
#     error "__cpp_lib_math_special_functions should not be defined because it is unimplemented in libc++!"
#   endif
# endif

#endif // TEST_STD_VER > 20

int main(int, char**) { return 0; }
