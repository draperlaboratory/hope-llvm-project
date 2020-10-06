//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// UNSUPPORTED: c++03

// <unordered_map>

// template <class P,
//           class = typename enable_if<is_convertible<P, value_type>::value>::type>
//     iterator insert(const_iterator p, P&& x);

// UNSUPPORTED: libcxx-no-debug-mode

#define _LIBCPP_DEBUG 1
#define _LIBCPP_ASSERT(x, m) ((x) ? (void)0 : std::exit(0))

#include <unordered_map>
#include <cassert>

#include "test_macros.h"

int main(int, char**)
{
    {
        typedef std::unordered_multimap<double, int> C;
        typedef C::iterator R;
        typedef C::value_type P;
        C c;
        C c2;
        C::const_iterator e = c2.end();
        R r = c.insert(e, P(3.5, 3));
        assert(false);
    }

    return 0;
}
