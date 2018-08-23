// Copyright (c) 2018, NVIDIA CORPORATION.  All rights reserved.
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

#ifndef FORTRAN_EVALUATE_TYPE_H_
#define FORTRAN_EVALUATE_TYPE_H_

// These definitions map Fortran's intrinsic types, characterized by byte
// sizes encoded in KIND type parameter values, to their value representation
// types in the evaluation library, which are parameterized in terms of
// total bit width and real precision.

#include "complex.h"
#include "integer.h"
#include "logical.h"
#include "real.h"
#include "../common/fortran.h"
#include "../common/idioms.h"
#include "../common/kind-variant.h"
#include "../common/template.h"
#include <cinttypes>
#include <optional>
#include <string>
#include <variant>

namespace Fortran::evaluate {

using common::TypeCategory;

// Specific intrinsic types

template<TypeCategory C, int KIND> struct Type;

template<TypeCategory C, int KIND> struct TypeBase {
  static constexpr TypeCategory category{C};
  static constexpr int kind{KIND};
  static constexpr bool hasLen{false};
  static std::string Dump() {
    return EnumToString(category) + '(' + std::to_string(kind) + ')';
  }
};

template<int KIND>
struct Type<TypeCategory::Integer, KIND>
  : public TypeBase<TypeCategory::Integer, KIND> {
  using Scalar = value::Integer<8 * KIND>;
};

template<>
struct Type<TypeCategory::Real, 2> : public TypeBase<TypeCategory::Real, 2> {
  using Scalar =
      value::Real<typename Type<TypeCategory::Integer, 2>::Scalar, 11>;
};

template<>
struct Type<TypeCategory::Real, 4> : public TypeBase<TypeCategory::Real, 4> {
  using Scalar =
      value::Real<typename Type<TypeCategory::Integer, 4>::Scalar, 24>;
};

template<>
struct Type<TypeCategory::Real, 8> : public TypeBase<TypeCategory::Real, 8> {
  using Scalar =
      value::Real<typename Type<TypeCategory::Integer, 8>::Scalar, 53>;
};

template<>
struct Type<TypeCategory::Real, 10> : public TypeBase<TypeCategory::Real, 10> {
  using Scalar = value::Real<value::Integer<80>, 64, false>;
};

template<>
struct Type<TypeCategory::Real, 16> : public TypeBase<TypeCategory::Real, 16> {
  using Scalar = value::Real<value::Integer<128>, 112>;
};

// The KIND type parameter on COMPLEX is the kind of each of its components.
template<int KIND>
struct Type<TypeCategory::Complex, KIND>
  : public TypeBase<TypeCategory::Complex, KIND> {
  using Part = Type<TypeCategory::Real, KIND>;
  using Scalar = value::Complex<typename Part::Scalar>;
};

template<int KIND> struct Type<TypeCategory::Character, KIND> {
  static constexpr TypeCategory category{TypeCategory::Character};
  static constexpr int kind{KIND};
  static constexpr bool hasLen{true};
  using Scalar = std::string;
  static std::string Dump() {
    return EnumToString(category) + '(' + std::to_string(kind) + ')';
  }
};

template<int KIND>
struct Type<TypeCategory::Logical, KIND>
  : public TypeBase<TypeCategory::Logical, KIND> {
  using Scalar = value::Logical<8 * KIND>;
};

// Type functions

template<typename T> using Scalar = typename std::decay_t<T>::Scalar;

// Given a specific type, find the type of the same kind in another category.
template<TypeCategory C, typename T>
using SameKind = Type<C, std::decay_t<T>::kind>;

// Convenience type aliases:
// Default REAL just simply has to be IEEE-754 single precision today.
// It occupies one numeric storage unit by definition.  The default INTEGER
// and default LOGICAL intrinsic types also have to occupy one numeric
// storage unit, so their kinds are also forced.  Default COMPLEX occupies
// two numeric storage units.
// TODO: Support compile-time options to default reals, ints, or both to KIND=8

using DefaultReal = Type<TypeCategory::Real, 4>;
using DefaultDoublePrecision = Type<TypeCategory::Real, 2 * DefaultReal::kind>;
using DefaultInteger = Type<TypeCategory::Integer, DefaultReal::kind>;
using IntrinsicTypeParameterType = DefaultInteger;
using DefaultComplex = SameKind<TypeCategory::Complex, DefaultReal>;
using DefaultLogical = Type<TypeCategory::Logical, DefaultInteger::kind>;
using DefaultCharacter = Type<TypeCategory::Character, 1>;

using SubscriptInteger = Type<TypeCategory::Integer, 8>;
using LogicalResult = Type<TypeCategory::Logical, 1>;

// The CategoryUnion template applies a given template to all of
// the supported kinds in a given intrinsic type category, and
// builds a KindVariant<> union over the results.  This allows
// us to specify the supported kind values in just one place (here)
// with resorting to macros.
template<TypeCategory CAT, template<TypeCategory, int> class TYPE>
struct CategoryUnionTemplate;

template<template<TypeCategory, int> class TYPE>
struct CategoryUnionTemplate<TypeCategory::Integer, TYPE> {
  static constexpr auto category{TypeCategory::Integer};
  template<int K> using PerKind = TYPE<category, K>;
  using type = common::KindVariant<int, PerKind, 1, 2, 4, 8, 16>;
};

template<template<TypeCategory, int> class TYPE>
struct CategoryUnionTemplate<TypeCategory::Real, TYPE> {
  static constexpr auto category{TypeCategory::Real};
  template<int K> using PerKind = TYPE<category, K>;
  using type = common::KindVariant<int, PerKind, 2, 4, 8, 10, 16>;
};

template<template<TypeCategory, int> class TYPE>
struct CategoryUnionTemplate<TypeCategory::Complex, TYPE> {
  static constexpr auto category{TypeCategory::Complex};
  template<int K> using PerKind = TYPE<category, K>;
  using type = common::KindVariant<int, PerKind, 2, 4, 8, 10, 16>;
};

template<template<TypeCategory, int> class TYPE>
struct CategoryUnionTemplate<TypeCategory::Character, TYPE> {
  static constexpr auto category{TypeCategory::Character};
  template<int K> using PerKind = TYPE<category, K>;
  using type = common::KindVariant<int, PerKind, 1>;  // TODO: add kinds 2 & 4;
};

template<template<TypeCategory, int> class TYPE>
struct CategoryUnionTemplate<TypeCategory::Logical, TYPE> {
  static constexpr auto category{TypeCategory::Logical};
  template<int K> using PerKind = TYPE<category, K>;
  using type = common::KindVariant<int, PerKind, 1, 2, 4, 8>;
};

template<TypeCategory CAT, template<TypeCategory, int> class TYPE>
using CategoryUnion = typename CategoryUnionTemplate<CAT, TYPE>::type;

// IntrinsicTypeUnion takes a template and instantiates it over
// all five of the intrinsic type categories, using them as the
// alternatives in a KindVariant.
template<template<TypeCategory, int> class A>
struct IntrinsicTypeUnionTemplate {
  template<TypeCategory C> using PerCategory = CategoryUnion<C, A>;
  using type = common::KindVariant<TypeCategory, PerCategory,
      TypeCategory::Integer, TypeCategory::Real, TypeCategory::Complex,
      TypeCategory::Character, TypeCategory::Logical>;
};

template<template<TypeCategory, int> class A>
using IntrinsicTypeUnion = typename IntrinsicTypeUnionTemplate<A>::type;

// For an intrinsic type category CAT, CategoryTypes<CAT> is an instantiation
// of std::tuple<Type<CAT, K>> for every supported kind K in that category.
template<TypeCategory CAT, int... KINDS>
using CategoryTypesTuple = std::tuple<Type<CAT, KINDS>...>;

template<TypeCategory CAT> struct CategoryTypesHelper;
template<> struct CategoryTypesHelper<TypeCategory::Integer> {
  using type = CategoryTypesTuple<TypeCategory::Integer, 1, 2, 4, 8, 16>;
};
template<> struct CategoryTypesHelper<TypeCategory::Real> {
  using type = CategoryTypesTuple<TypeCategory::Real, 2, 4, 8, 10, 16>;
};
template<> struct CategoryTypesHelper<TypeCategory::Complex> {
  using type = CategoryTypesTuple<TypeCategory::Complex, 2, 4, 8, 10, 16>;
};
template<> struct CategoryTypesHelper<TypeCategory::Character> {
  using type = CategoryTypesTuple<TypeCategory::Character, 1>;  // TODO: 2 & 4
};
template<> struct CategoryTypesHelper<TypeCategory::Logical> {
  using type = CategoryTypesTuple<TypeCategory::Logical, 1, 2, 4, 8>;
};
template<TypeCategory CAT>
using CategoryTypes = typename CategoryTypesHelper<CAT>::type;

using NumericTypes = common::CombineTuples<CategoryTypes<TypeCategory::Integer>,
    CategoryTypes<TypeCategory::Real>, CategoryTypes<TypeCategory::Complex>>;
using RelationalTypes =
    common::CombineTuples<NumericTypes, CategoryTypes<TypeCategory::Character>>;
using AllIntrinsicTypes = common::CombineTuples<RelationalTypes,
    CategoryTypes<TypeCategory::Logical>>;

// When Scalar<T> is S, then TypeOf<S> is T.
// TypeOf is implemented by scanning all supported types for a match
// with Type<T>::Scalar.
template<typename CONST> struct TypeOfHelper {
  template<typename T> struct Predicate {
    static constexpr bool value() {
      return std::is_same_v<std::decay_t<CONST>,
          std::decay_t<typename T::Scalar>>;
    }
  };
  static constexpr int index{
      common::SearchMembers<Predicate, AllIntrinsicTypes>};
  static_assert(index >= 0 || !"No intrinsic type found for constant type");
  using type = std::tuple_element_t<index, AllIntrinsicTypes>;
};

template<typename CONST> using TypeOf = typename TypeOfHelper<CONST>::type;

// A variant union that can hold a scalar constant of some type in a set.
template<typename TYPES> struct SomeScalar {
  using Types = TYPES;
  CLASS_BOILERPLATE(SomeScalar)

  template<typename A> SomeScalar(const A &x) : u{x} {}
  template<typename A>
  SomeScalar(std::enable_if_t<!std::is_reference_v<A>, A> &&x)
    : u{std::move(x)} {}

  auto ToInt64() const {
    return std::visit(
        [](const auto &x) -> std::optional<std::int64_t> {
          if constexpr (TypeOf<decltype(x)>::category ==
              TypeCategory::Integer) {
            return {x.ToInt64()};
          } else {
            return std::nullopt;
          }
        },
        u);
  }

  auto ToString() const {
    return std::visit(
        [](const auto &x) -> std::optional<std::string> {
          if constexpr (std::is_same_v<std::string,
                            std::decay_t<decltype(x)>>) {
            return {x};
          } else {
            return std::nullopt;
          }
        },
        u);
  }

  template<typename T> auto GetIf() const {
    return common::GetIf<Scalar<T>>(u);
  }

  common::MapTemplate<Scalar, std::variant, Types> u;
};

template<TypeCategory CAT>
using SomeKindScalar = SomeScalar<CategoryTypes<CAT>>;
using GenericScalar = SomeScalar<AllIntrinsicTypes>;

// Represents a type of any supported kind within a particular category.
template<TypeCategory CAT> struct SomeKind {
  using Scalar = SomeKindScalar<CAT>;
  static constexpr TypeCategory category{CAT};
};

using SomeInteger = SomeKind<TypeCategory::Integer>;
using SomeReal = SomeKind<TypeCategory::Real>;
using SomeComplex = SomeKind<TypeCategory::Complex>;
using SomeCharacter = SomeKind<TypeCategory::Character>;
using SomeLogical = SomeKind<TypeCategory::Logical>;

// Represents a completely generic intrinsic type.
struct SomeType {
  using Scalar = GenericScalar;
};

}  // namespace Fortran::evaluate
#endif  // FORTRAN_EVALUATE_TYPE_H_
