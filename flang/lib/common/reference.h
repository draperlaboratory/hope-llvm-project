// Copyright (c) 2019, NVIDIA CORPORATION.  All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Implements a better std::reference_wrapper<> template class with
// move semantics, equality testing, and member access.
// Use Reference<A> in place of a real A& reference when assignability is
// required; safer than a bare pointer because it's guaranteed to not be null.

#ifndef FORTRAN_COMMON_REFERENCE_H_
#define FORTRAN_COMMON_REFERENCE_H_
#include <type_traits>
namespace Fortran::common {
template<typename A> class Reference {
public:
  using type = A;
  Reference(type &x) : p_{&x} {}
  Reference(const Reference &that) : p_{that.p_} {}
  Reference(Reference &&that) : p_{that.p_} {}
  Reference &operator=(const Reference &that) {
    p_ = that.p_;
    return *this;
  }
  Reference &operator=(Reference &&that) {
    p_ = that.p_;
    return *this;
  }

  // Implicit conversions to references are supported only for
  // const-qualified types in order to avoid any pernicious
  // creation of a temporary copy in cases like:
  //   Reference<type> ref;
  //   const Type &x{ref};  // creates ref to temp copy!
  operator std::conditional_t<std::is_const_v<type>, type &, void>() const
      noexcept {
    if constexpr (std::is_const_v<type>) {
      return *p_;
    }
  }

  type &get() const noexcept { return *p_; }
  type *operator->() const { return p_; }
  type &operator*() const { return *p_; }
  bool operator==(Reference that) const { return *p_ == *that.p_; }
  bool operator!=(Reference that) const { return *p_ != *that.p_; }

private:
  type *p_;  // never null
};
template<typename A> Reference(A &)->Reference<A>;
}
#endif
