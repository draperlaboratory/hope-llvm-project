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

#ifndef FORTRAN_EVALUATE_EXPRESSION_H_
#define FORTRAN_EVALUATE_EXPRESSION_H_

// Represent Fortran expressions in a type-safe manner.
// Expressions are the sole owners of their constituents; i.e., there is no
// context-independent hash table or sharing of common subexpressions.
// Both deep copy and move semantics are supported for expression construction
// and manipulation in place.
// TODO: convenience wrappers for constructing conversions

#include "common.h"
#include "expression-forward.h"
#include "type.h"
#include "variable.h"
#include "../lib/common/idioms.h"
#include "../lib/parser/char-block.h"
#include "../lib/parser/message.h"
#include <ostream>
#include <variant>

namespace Fortran::evaluate {

struct FoldingContext {
  const parser::CharBlock &at;
  parser::Messages *messages;
};

// Helper base classes for packaging subexpressions.
template<typename A, typename CONST = typename A::Constant> class Unary {
public:
  using Operand = A;
  using Constant = CONST;
  CLASS_BOILERPLATE(Unary)
  Unary(const A &a) : operand_{a} {}
  Unary(A &&a) : operand_{std::move(a)} {}
  Unary(CopyableIndirection<A> &&a) : operand_{std::move(a)} {}
  const A &operand() const { return *operand_; }
  A &operand() { return *operand_; }
  std::ostream &Dump(std::ostream &, const char *opr) const;
  std::optional<CONST> Fold(FoldingContext &);  // folds operand, no result

private:
  CopyableIndirection<A> operand_;
};

template<typename A, typename B = A, typename CONST = typename A::Constant>
class Binary {
public:
  using Left = A;
  using Right = B;
  using Constant = CONST;
  CLASS_BOILERPLATE(Binary)
  Binary(const A &a, const B &b) : left_{a}, right_{b} {}
  Binary(A &&a, B &&b) : left_{std::move(a)}, right_{std::move(b)} {}
  Binary(CopyableIndirection<const A> &&a, CopyableIndirection<const B> &&b)
    : left_{std::move(a)}, right_{std::move(b)} {}
  const A &left() const { return *left_; }
  A &left() { return *left_; }
  const B &right() const { return *right_; }
  B &right() { return *right_; }
  std::ostream &Dump(
      std::ostream &, const char *opr, const char *before = "(") const;
  std::optional<CONST> Fold(FoldingContext &);  // folds operands, no result

private:
  CopyableIndirection<A> left_;
  CopyableIndirection<B> right_;
};

template<int KIND> class Expr<Category::Integer, KIND> {
public:
  using Result = Type<Category::Integer, KIND>;
  using Constant = typename Result::Value;
  struct ConvertInteger : public Unary<GenericIntegerExpr, Constant> {
    using Unary<GenericIntegerExpr, Constant>::Unary;
    std::optional<Constant> Fold(FoldingContext &);
  };
  struct ConvertReal : public Unary<GenericRealExpr, Constant> {
    using Unary<GenericRealExpr, Constant>::Unary;
  };
  using Un = Unary<Expr, Constant>;
  using Bin = Binary<Expr, Expr, Constant>;
  struct Parentheses : public Un {
    using Un::Un;
    std::optional<Constant> Fold(FoldingContext &c) {
      return this->operand().Fold(c);
    }
  };
  struct Negate : public Un {
    using Un::Un;
    std::optional<Constant> Fold(FoldingContext &);
  };
  struct Add : public Bin {
    using Bin::Bin;
    std::optional<Constant> Fold(FoldingContext &);
  };
  struct Subtract : public Bin {
    using Bin::Bin;
    std::optional<Constant> Fold(FoldingContext &);
  };
  struct Multiply : public Bin {
    using Bin::Bin;
    std::optional<Constant> Fold(FoldingContext &);
  };
  struct Divide : public Bin {
    using Bin::Bin;
    std::optional<Constant> Fold(FoldingContext &);
  };
  struct Power : public Bin {
    using Bin::Bin;
    std::optional<Constant> Fold(FoldingContext &);
  };
  struct Max : public Bin {
    using Bin::Bin;
    std::optional<Constant> Fold(FoldingContext &);
  };
  struct Min : public Bin {
    using Bin::Bin;
    std::optional<Constant> Fold(FoldingContext &);
  };
  // TODO: R916 type-param-inquiry

  CLASS_BOILERPLATE(Expr)
  Expr(const Constant &x) : u_{x} {}
  Expr(std::int64_t n) : u_{Constant{n}} {}
  Expr(std::uint64_t n) : u_{Constant{n}} {}
  Expr(int n) : u_{Constant{n}} {}
  template<int K>
  Expr(const IntegerExpr<K> &x) : u_{ConvertInteger{GenericIntegerExpr{x}}} {}
  template<int K>
  Expr(IntegerExpr<K> &&x)
    : u_{ConvertInteger{GenericIntegerExpr{std::move(x)}}} {}
  template<int K>
  Expr(const RealExpr<K> &x) : u_{ConvertReal{GenericRealExpr{x}}} {}
  template<int K>
  Expr(RealExpr<K> &&x) : u_{ConvertReal{GenericRealExpr{std::move(x)}}} {}
  template<typename A> Expr(const A &x) : u_{x} {}
  template<typename A>
  Expr(std::enable_if_t<!std::is_reference_v<A> &&
          (std::is_base_of_v<Un, A> || std::is_base_of_v<Bin, A>),
      A> &&x)
    : u_(std::move(x)) {}
  template<typename A> Expr(CopyableIndirection<A> &&x) : u_{std::move(x)} {}

  std::optional<Constant> ConstantValue() const;
  std::optional<Constant> Fold(FoldingContext &c);

private:
  std::variant<Constant, CopyableIndirection<DataRef>,
      CopyableIndirection<FunctionRef>, ConvertInteger, ConvertReal,
      Parentheses, Negate, Add, Subtract, Multiply, Divide, Power, Max, Min>
      u_;
};

template<int KIND> class Expr<Category::Real, KIND> {
public:
  using Result = Type<Category::Real, KIND>;
  using Constant = typename Result::Value;
  // N.B. Real->Complex and Complex->Real conversions are done with CMPLX
  // and part access operations (resp.).  Conversions between kinds of
  // Complex are done via decomposition to Real and reconstruction.
  struct ConvertInteger : public Unary<GenericIntegerExpr, Constant> {
    using Unary<GenericIntegerExpr, Constant>::Unary;
    std::optional<Constant> Fold(FoldingContext &);
  };
  struct ConvertReal : public Unary<GenericRealExpr, Constant> {
    using Unary<GenericRealExpr, Constant>::Unary;
  };
  using Un = Unary<Expr, Constant>;
  using Bin = Binary<Expr, Expr, Constant>;
  struct Parentheses : public Un {
    using Un::Un;
  };
  struct Negate : public Un {
    using Un::Un;
  };
  struct Add : public Bin {
    using Bin::Bin;
  };
  struct Subtract : public Bin {
    using Bin::Bin;
  };
  struct Multiply : public Bin {
    using Bin::Bin;
  };
  struct Divide : public Bin {
    using Bin::Bin;
  };
  struct Power : public Bin {
    using Bin::Bin;
  };
  struct IntPower : public Binary<Expr, GenericIntegerExpr, Constant> {
    using Binary<Expr, GenericIntegerExpr, Constant>::Binary;
  };
  struct Max : public Bin {
    using Bin::Bin;
  };
  struct Min : public Bin {
    using Bin::Bin;
  };
  using CplxUn = Unary<ComplexExpr<KIND>, Constant>;
  struct RealPart : public CplxUn {
    using CplxUn::CplxUn;
  };
  struct AIMAG : public CplxUn {
    using CplxUn::CplxUn;
  };

  CLASS_BOILERPLATE(Expr)
  Expr(const Constant &x) : u_{x} {}
  template<int K>
  Expr(const IntegerExpr<K> &x) : u_{ConvertInteger{GenericIntegerExpr{x}}} {}
  template<int K>
  Expr(IntegerExpr<K> &&x)
    : u_{ConvertInteger{GenericIntegerExpr{std::move(x)}}} {}
  template<int K>
  Expr(const RealExpr<K> &x) : u_{ConvertReal{GenericRealExpr{x}}} {}
  template<int K>
  Expr(RealExpr<K> &&x) : u_{ConvertReal{GenericRealExpr{std::move(x)}}} {}
  template<typename A> Expr(const A &x) : u_{x} {}
  template<typename A>
  Expr(std::enable_if_t<!std::is_reference_v<A>, A> &&x) : u_{std::move(x)} {}
  template<typename A> Expr(CopyableIndirection<A> &&x) : u_{std::move(x)} {}

private:
  std::variant<Constant, CopyableIndirection<DataRef>,
      CopyableIndirection<ComplexPart>, CopyableIndirection<FunctionRef>,
      ConvertInteger, ConvertReal, Parentheses, Negate, Add, Subtract, Multiply,
      Divide, Power, IntPower, Max, Min, RealPart, AIMAG>
      u_;
};

template<int KIND> class Expr<Category::Complex, KIND> {
public:
  using Result = Type<Category::Complex, KIND>;
  using Constant = typename Result::Value;
  using Un = Unary<Expr, Constant>;
  using Bin = Binary<Expr, Expr, Constant>;
  struct Parentheses : public Un {
    using Un::Un;
  };
  struct Negate : public Un {
    using Un::Un;
  };
  struct Add : public Bin {
    using Bin::Bin;
  };
  struct Subtract : public Bin {
    using Bin::Bin;
  };
  struct Multiply : public Bin {
    using Bin::Bin;
  };
  struct Divide : public Bin {
    using Bin::Bin;
  };
  struct Power : public Bin {
    using Bin::Bin;
  };
  struct IntPower : public Binary<Expr, GenericIntegerExpr, Constant> {
    using Binary<Expr, GenericIntegerExpr, Constant>::Binary;
  };
  struct CMPLX : public Binary<RealExpr<KIND>, RealExpr<KIND>, Constant> {
    using Binary<RealExpr<KIND>, RealExpr<KIND>, Constant>::Binary;
  };

  CLASS_BOILERPLATE(Expr)
  Expr(const Constant &x) : u_{x} {}
  template<typename A> Expr(const A &x) : u_{x} {}
  template<typename A>
  Expr(std::enable_if_t<!std::is_reference_v<A>, A> &&x) : u_{std::move(x)} {}
  template<typename A> Expr(CopyableIndirection<A> &&x) : u_{std::move(x)} {}

private:
  std::variant<Constant, CopyableIndirection<DataRef>,
      CopyableIndirection<FunctionRef>, Parentheses, Negate, Add, Subtract,
      Multiply, Divide, Power, IntPower, CMPLX>
      u_;
};

template<int KIND> class Expr<Category::Character, KIND> {
public:
  using Result = Type<Category::Character, KIND>;
  using Constant = typename Result::Value;
  using Bin = Binary<Expr, Expr, Constant>;
  struct Concat : public Bin {
    using Bin::Bin;
  };
  struct Max : public Bin {
    using Bin::Bin;
  };
  struct Min : public Bin {
    using Bin::Bin;
  };

  CLASS_BOILERPLATE(Expr)
  Expr(const Constant &x) : u_{x} {}
  Expr(Constant &&x) : u_{std::move(x)} {}
  template<typename A> Expr(const A &x) : u_{x} {}
  template<typename A>
  Expr(std::enable_if_t<!std::is_reference_v<A>, A> &&x) : u_{std::move(x)} {}
  template<typename A> Expr(CopyableIndirection<A> &&x) : u_{std::move(x)} {}

  SubscriptIntegerExpr LEN() const;

private:
  std::variant<Constant, CopyableIndirection<DataRef>,
      CopyableIndirection<Substring>, CopyableIndirection<FunctionRef>, Concat,
      Max, Min>
      u_;
};

// The Comparison class template is a helper for constructing logical
// expressions with polymorphism over the cross product of the possible
// categories and kinds of comparable operands.
ENUM_CLASS(RelationalOperator, LT, LE, EQ, NE, GE, GT)

template<typename EXPR> struct Comparison : Binary<EXPR, EXPR, bool> {
  CLASS_BOILERPLATE(Comparison)
  Comparison(RelationalOperator r, const EXPR &a, const EXPR &b)
    : Binary<EXPR, EXPR, bool>{a, b}, opr{r} {}
  Comparison(RelationalOperator r, EXPR &&a, EXPR &&b)
    : Binary<EXPR, EXPR, bool>{std::move(a), std::move(b)}, opr{r} {}
  RelationalOperator opr;
};

extern template struct Comparison<IntegerExpr<1>>;
extern template struct Comparison<IntegerExpr<2>>;
extern template struct Comparison<IntegerExpr<4>>;
extern template struct Comparison<IntegerExpr<8>>;
extern template struct Comparison<IntegerExpr<16>>;
extern template struct Comparison<RealExpr<2>>;
extern template struct Comparison<RealExpr<4>>;
extern template struct Comparison<RealExpr<8>>;
extern template struct Comparison<RealExpr<10>>;
extern template struct Comparison<RealExpr<16>>;
extern template struct Comparison<ComplexExpr<2>>;
extern template struct Comparison<ComplexExpr<4>>;
extern template struct Comparison<ComplexExpr<8>>;
extern template struct Comparison<ComplexExpr<10>>;
extern template struct Comparison<ComplexExpr<16>>;
extern template struct Comparison<CharacterExpr<1>>;

// Dynamically polymorphic comparisons that can hold any supported kind
// of a specific category.
template<Category CAT> struct CategoryComparison {
  CLASS_BOILERPLATE(CategoryComparison)
  template<int KIND>
  CategoryComparison(const Comparison<Expr<CAT, KIND>> &x) : u{x} {}
  template<int KIND>
  CategoryComparison(Comparison<Expr<CAT, KIND>> &&x) : u{std::move(x)} {}
  template<int K> using KindComparison = Comparison<Expr<CAT, K>>;
  typename KindsVariant<CAT, KindComparison>::type u;
};

// No need to distinguish the various kinds of LOGICAL expression results.
template<> class Expr<Category::Logical, 1> {
public:
  using Constant = bool;
  struct Not : Unary<Expr, bool> {
    using Unary<Expr, Constant>::Unary;
  };
  using Bin = Binary<Expr, Expr, bool>;
  struct And : public Bin {
    using Bin::Bin;
  };
  struct Or : public Bin {
    using Bin::Bin;
  };
  struct Eqv : public Bin {
    using Bin::Bin;
  };
  struct Neqv : public Bin {
    using Bin::Bin;
  };

  CLASS_BOILERPLATE(Expr)
  Expr(Constant x) : u_{x} {}
  template<Category CAT, int KIND>
  Expr(const Comparison<Expr<CAT, KIND>> &x) : u_{CategoryComparison<CAT>{x}} {}
  template<Category CAT, int KIND>
  Expr(Comparison<Expr<CAT, KIND>> &&x)
    : u_{CategoryComparison<CAT>{std::move(x)}} {}
  template<typename A> Expr(const A &x) : u_(x) {}
  template<typename A>
  Expr(std::enable_if_t<!std::is_reference_v<A>, A> &&x) : u_{std::move(x)} {}
  template<typename A> Expr(CopyableIndirection<A> &&x) : u_{std::move(x)} {}

private:
  std::variant<Constant, CopyableIndirection<DataRef>,
      CopyableIndirection<FunctionRef>, Not, And, Or, Eqv, Neqv,
      CategoryComparison<Category::Integer>, CategoryComparison<Category::Real>,
      CategoryComparison<Category::Complex>,
      CategoryComparison<Category::Character>>
      u_;
};

extern template class Expr<Category::Integer, 1>;
extern template class Expr<Category::Integer, 2>;
extern template class Expr<Category::Integer, 4>;
extern template class Expr<Category::Integer, 8>;
extern template class Expr<Category::Integer, 16>;
extern template class Expr<Category::Real, 2>;
extern template class Expr<Category::Real, 4>;
extern template class Expr<Category::Real, 8>;
extern template class Expr<Category::Real, 10>;
extern template class Expr<Category::Real, 16>;
extern template class Expr<Category::Complex, 2>;
extern template class Expr<Category::Complex, 4>;
extern template class Expr<Category::Complex, 8>;
extern template class Expr<Category::Complex, 10>;
extern template class Expr<Category::Complex, 16>;
extern template class Expr<Category::Character, 1>;
extern template class Expr<Category::Logical, 1>;

// Dynamically polymorphic expressions that can hold any supported kind
// of a specific category.
template<Category CAT> struct CategoryExpr {
  CLASS_BOILERPLATE(CategoryExpr)
  template<int KIND> CategoryExpr(const Expr<CAT, KIND> &x) : u{x} {}
  template<int KIND> CategoryExpr(Expr<CAT, KIND> &&x) : u{std::move(x)} {}
  template<int K> using KindExpr = Expr<CAT, K>;
  typename KindsVariant<CAT, KindExpr>::type u;
};

// A completely generic expression, polymorphic across the type categories.
struct GenericExpr {
  CLASS_BOILERPLATE(GenericExpr)
  template<Category CAT, int KIND>
  GenericExpr(const Expr<CAT, KIND> &x) : u{CategoryExpr<CAT>{x}} {}
  template<Category CAT, int KIND>
  GenericExpr(Expr<CAT, KIND> &&x) : u{CategoryExpr<CAT>{std::move(x)}} {}
  template<typename A> GenericExpr(const A &x) : u{x} {}
  template<typename A>
  GenericExpr(std::enable_if_t<!std::is_reference_v<A>, A> &&x)
    : u{std::move(x)} {}
  std::variant<GenericIntegerExpr, GenericRealExpr, GenericComplexExpr,
      GenericCharacterExpr, LogicalExpr>
      u;
};

// Convenience functions and operator overloadings for expression construction.
// These definitions are created with temporary helper macros to reduce
// C++ boilerplate.  All combinations of lvalue and rvalue references are
// allowed for operands.
#define UNARY(FUNC, CONSTR) \
  template<typename A> A FUNC(const A &x) { return {typename A::CONSTR{x}}; }
UNARY(Parentheses, Parentheses)
UNARY(operator-, Negate)
#undef UNARY

#define BINARY(FUNC, CONSTR) \
  template<typename A> A FUNC(const A &x, const A &y) { \
    return {typename A::CONSTR{x, y}}; \
  } \
  template<typename A> \
  std::enable_if_t<!std::is_reference_v<A>, A> FUNC(const A &x, A &&y) { \
    return {typename A::CONSTR{A{x}, std::move(y)}}; \
  } \
  template<typename A> \
  std::enable_if_t<!std::is_reference_v<A>, A> FUNC(A &&x, const A &y) { \
    return {typename A::CONSTR{std::move(x), A{y}}}; \
  } \
  template<typename A> \
  std::enable_if_t<!std::is_reference_v<A>, A> FUNC(A &&x, A &&y) { \
    return {typename A::CONSTR{std::move(x), std::move(y)}}; \
  }

BINARY(operator+, Add)
BINARY(operator-, Subtract)
BINARY(operator*, Multiply)
BINARY(operator/, Divide)
BINARY(Power, Power)
#undef BINARY

#define BINARY(FUNC, OP) \
  template<typename A> LogicalExpr FUNC(const A &x, const A &y) { \
    return {Comparison<A>{OP, x, y}}; \
  } \
  template<typename A> \
  std::enable_if_t<!std::is_reference_v<A>, LogicalExpr> FUNC( \
      const A &x, A &&y) { \
    return {Comparison<A>{OP, x, std::move(y)}}; \
  } \
  template<typename A> \
  std::enable_if_t<!std::is_reference_v<A>, LogicalExpr> FUNC( \
      A &&x, const A &y) { \
    return {Comparison<A>{OP, std::move(x), y}}; \
  } \
  template<typename A> \
  std::enable_if_t<!std::is_reference_v<A>, LogicalExpr> FUNC(A &&x, A &&y) { \
    return {Comparison<A>{OP, std::move(x), std::move(y)}}; \
  }

BINARY(operator<, RelationalOperator::LT)
BINARY(operator<=, RelationalOperator::LE)
BINARY(operator==, RelationalOperator::EQ)
BINARY(operator!=, RelationalOperator::NE)
BINARY(operator>=, RelationalOperator::GE)
BINARY(operator>, RelationalOperator::GT)
#undef BINARY
}  // namespace Fortran::evaluate
#endif  // FORTRAN_EVALUATE_EXPRESSION_H_
