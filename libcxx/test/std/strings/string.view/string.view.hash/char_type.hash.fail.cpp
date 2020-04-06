//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// GCC 5 does not evaluate static assertions dependent on a template parameter.
// UNSUPPORTED: gcc-5

// UNSUPPORTED: c++98, c++03

// <string>

// Test that hash specializations for <string_view> require "char_traits<_CharT>" not just any "_Trait".

#include <string_view>
#include <string> // for 'mbstate_t'

template <class _CharT>
struct trait // copied from <__string>
{
    typedef _CharT         char_type;
    typedef int            int_type;
    typedef std::streamoff off_type;
    typedef std::streampos pos_type;
    typedef std::mbstate_t state_type;

    static inline void assign(char_type& __c1, const char_type& __c2) {
        __c1 = __c2;
    }
    static inline bool eq(char_type __c1, char_type __c2) { return __c1 == __c2; }
    static inline bool lt(char_type __c1, char_type __c2) { return __c1 < __c2; }

    static int compare(const char_type* __s1, const char_type* __s2, size_t __n);
    static size_t length(const char_type* __s);
    static const char_type* find(const char_type* __s, size_t __n,
                                 const char_type& __a);

    static char_type* move(char_type* __s1, const char_type* __s2, size_t __n);
    static char_type* copy(char_type* __s1, const char_type* __s2, size_t __n);
    static char_type* assign(char_type* __s, size_t __n, char_type __a);

    static inline int_type not_eof(int_type __c) {
        return eq_int_type(__c, eof()) ? ~eof() : __c;
    }
    static inline char_type to_char_type(int_type __c) { return char_type(__c); }
    static inline int_type to_int_type(char_type __c) { return int_type(__c); }
    static inline bool eq_int_type(int_type __c1, int_type __c2) {
        return __c1 == __c2;
    }
    static inline int_type eof() { return int_type(EOF); }
};

template <class CharT>
void test() {
    typedef std::basic_string_view<CharT, trait<CharT> > strv_t;
    std::hash<strv_t>
        h; // expected-error-re 4 {{{{call to implicitly-deleted default constructor of 'std::hash<strv_t>'|implicit instantiation of undefined template}} {{.+}}}}}}
}

int main(int, char**) {
    test<char>();
    test<wchar_t>();
    test<char16_t>();
    test<char32_t>();

    return 0;
}
