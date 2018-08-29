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

#include "expression.h"
#include "symbol.h"
#include "../common/idioms.h"
#include "../evaluate/common.h"
#include "../evaluate/tools.h"
#include <functional>

using namespace Fortran::parser::literals;

namespace Fortran::semantics {

using common::TypeCategory;
using evaluate::Expr;
using evaluate::SomeKind;
using evaluate::SomeType;
using evaluate::Type;

using MaybeIntExpr = std::optional<Expr<evaluate::SomeInteger>>;

// AnalyzeHelper is a local template function that keeps the API
// member function ExpressionAnalyzer::Analyze from having to be a
// many-specialized template itself.
template<typename A> MaybeExpr AnalyzeHelper(ExpressionAnalyzer &, const A &);

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr &expr) {
  return ea.Analyze(expr);
}

// Template wrappers are traversed with checking.
template<typename A>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const std::optional<A> &x) {
  if (x.has_value()) {
    return AnalyzeHelper(ea, *x);
  } else {
    return std::nullopt;
  }
}

template<typename A>
MaybeExpr AnalyzeHelper(
    ExpressionAnalyzer &ea, const common::Indirection<A> &p) {
  return AnalyzeHelper(ea, *p);
}

template<typename A>
auto AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Scalar<A> &tree)
    -> decltype(AnalyzeHelper(ea, tree.thing)) {
  auto result{AnalyzeHelper(ea, tree.thing)};
  if (result.has_value()) {
    if (result->Rank() > 0) {
      ea.context().messages.Say("must be scalar"_err_en_US);
      return std::nullopt;
    }
  }
  return result;
}

template<typename A>
MaybeExpr AnalyzeHelper(
    ExpressionAnalyzer &ea, const parser::Constant<A> &tree) {
  MaybeExpr result{AnalyzeHelper(ea, tree.thing)};
  if (result.has_value()) {
    result->Fold(ea.context());
    if (!result->ScalarValue().has_value()) {
      ea.context().messages.Say("must be constant"_err_en_US);
      return std::nullopt;
    }
  }
  return result;
}

template<typename A>
std::optional<Expr<evaluate::SomeInteger>> AnalyzeHelper(
    ExpressionAnalyzer &ea, const parser::Integer<A> &tree) {
  MaybeExpr result{AnalyzeHelper(ea, tree.thing)};
  if (result.has_value()) {
    if (auto *intexpr{std::get_if<Expr<evaluate::SomeInteger>>(&result->u)}) {
      return {std::move(*intexpr)};
    }
    ea.context().messages.Say("expression must be INTEGER"_err_en_US);
  }
  return std::nullopt;
}

// pmk: document, maybe put elsewhere
template<TypeCategory CAT, typename VALUE> struct ConstantHelper {
  using Types = evaluate::CategoryTypes<CAT>;
  explicit ConstantHelper(VALUE &&x) : value{std::move(x)} {}
  template<int J> void SetKindTraverser(int kind) {
    if constexpr (J < std::tuple_size_v<Types>) {
      using Ty = std::tuple_element_t<J, Types>;
      if (kind == Ty::kind) {
        result = Expr<Ty>{evaluate::Constant<Ty>{std::move(value)}};
      } else {
        SetKindTraverser<J + 1>(kind);
      }
    }
  }
  void SetKind(int kind) { SetKindTraverser<0>(kind); }
  VALUE value;
  std::optional<Expr<evaluate::SomeKind<CAT>>> result;
};

static std::optional<Expr<evaluate::SomeCharacter>> AnalyzeLiteral(
    ExpressionAnalyzer &ea, const parser::CharLiteralConstant &x) {
  auto kind{ea.Analyze(std::get<std::optional<parser::KindParam>>(x.t),
      ExpressionAnalyzer::KindParam{1})};
  auto value{std::get<std::string>(x.t)};
  ConstantHelper<TypeCategory::Character, std::string> helper{std::move(value)};
  helper.SetKind(kind);
  if (!helper.result.has_value()) {
    ea.context().messages.Say("unsupported CHARACTER(KIND=%ju)"_err_en_US,
        static_cast<std::uintmax_t>(kind));
  }
  return std::move(helper.result);
}

template<typename A> MaybeExpr PackageGeneric(std::optional<A> &&x) {
  if (x.has_value()) {
    return {evaluate::AsGenericExpr(std::move(*x))};
  }
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(
    ExpressionAnalyzer &ea, const parser::CharLiteralConstantSubstring &x) {
  const auto &range{std::get<parser::SubstringRange>(x.t)};
  const std::optional<parser::ScalarIntExpr> &lbTree{std::get<0>(range.t)};
  const std::optional<parser::ScalarIntExpr> &ubTree{std::get<1>(range.t)};
  if (!lbTree.has_value() && !ubTree.has_value()) {
    // "..."(:)
    return PackageGeneric(
        AnalyzeLiteral(ea, std::get<parser::CharLiteralConstant>(x.t)));
  }
  // TODO: ensure that any kind parameter is 1
  std::string str{std::get<parser::CharLiteralConstant>(x.t).GetString()};
  std::optional<Expr<evaluate::SubscriptInteger>> lb, ub;
  if (lbTree.has_value()) {
    if (MaybeIntExpr lbExpr{AnalyzeHelper(ea, *lbTree)}) {
      lb = evaluate::ConvertToType<evaluate::SubscriptInteger>(
          std::move(*lbExpr));
    }
  }
  if (ubTree.has_value()) {
    if (MaybeIntExpr ubExpr{AnalyzeHelper(ea, *ubTree)}) {
      ub = evaluate::ConvertToType<evaluate::SubscriptInteger>(
          std::move(*ubExpr));
    }
  }
  if (!lb.has_value() || !ub.has_value()) {
    return std::nullopt;
  }
  evaluate::Substring substring{std::move(str), std::move(lb), std::move(ub)};
  evaluate::CopyableIndirection<evaluate::Substring> ind{std::move(substring)};
  Expr<evaluate::DefaultCharacter> chExpr{std::move(ind)};
  chExpr.Fold(ea.context());
  return {evaluate::AsGenericExpr(chExpr)};
}

// Common handling of parser::IntLiteralConstant and SignedIntLiteralConstant
template<typename PARSED>
std::optional<Expr<evaluate::SomeInteger>> IntLiteralConstant(
    ExpressionAnalyzer &ea, const PARSED &x) {
  auto kind{ea.Analyze(std::get<std::optional<parser::KindParam>>(x.t),
      ea.defaultIntegerKind())};
  auto value{std::get<0>(x.t)};  // std::(u)int64_t
  ConstantHelper<TypeCategory::Integer, decltype(value)> helper{
      std::move(value)};
  helper.SetKind(kind);
  if (!helper.result.has_value()) {
    ea.context().messages.Say("unsupported INTEGER(KIND=%ju)"_err_en_US,
        static_cast<std::uintmax_t>(kind));
  }
  return std::move(helper.result);
}

static std::optional<Expr<evaluate::SomeInteger>> AnalyzeLiteral(
    ExpressionAnalyzer &ea, const parser::IntLiteralConstant &x) {
  return IntLiteralConstant(ea, x);
}

static std::optional<Expr<evaluate::SomeInteger>> AnalyzeLiteral(
    ExpressionAnalyzer &ea, const parser::SignedIntLiteralConstant &x) {
  return IntLiteralConstant(ea, x);
}

static std::optional<evaluate::BOZLiteralConstant> AnalyzeLiteral(
    ExpressionAnalyzer &ea, const parser::BOZLiteralConstant &x) {
  const char *p{x.v.data()};
  std::uint64_t base{16};
  switch (*p++) {
  case 'b': base = 2; break;
  case 'o': base = 8; break;
  case 'z': break;
  case 'x': break;
  default: CRASH_NO_CASE;
  }
  CHECK(*p == '"');
  auto value{evaluate::BOZLiteralConstant::ReadUnsigned(++p, base)};
  if (*p != '"') {
    ea.context().messages.Say(
        "invalid digit ('%c') in BOZ literal %s"_err_en_US, *p, x.v.data());
    return std::nullopt;
  }
  if (value.overflow) {
    ea.context().messages.Say("BOZ literal %s too large"_err_en_US, x.v.data());
    return std::nullopt;
  }
  return {value.value};
}

template<int KIND>
std::optional<Expr<evaluate::SomeReal>> ReadRealLiteral(
    parser::CharBlock source, evaluate::FoldingContext &context) {
  const char *p{source.begin()};
  using RealType = Type<TypeCategory::Real, KIND>;
  auto valWithFlags{evaluate::Scalar<RealType>::Read(p, context.rounding)};
  CHECK(p == source.end());
  evaluate::RealFlagWarnings(
      context, valWithFlags.flags, "conversion of REAL literal");
  auto value{valWithFlags.value};
  if (context.flushDenormalsToZero) {
    value = value.FlushDenormalToZero();
  }
  return {evaluate::AsCategoryExpr(
      Expr<RealType>{evaluate::Constant<RealType>{value}})};
}

struct RealHelper {
  RealHelper(parser::CharBlock lit, evaluate::FoldingContext &ctx)
    : literal{lit}, context{ctx} {}

  using Types = evaluate::CategoryTypes<TypeCategory::Real>;
  template<int J> void SetKindTraverser(int kind) {
    if constexpr (J < std::tuple_size_v<Types>) {
      using Ty = std::tuple_element_t<J, Types>;
      if (kind == Ty::kind) {
        result = ReadRealLiteral<Ty::kind>(literal, context);
      } else {
        SetKindTraverser<J + 1>(kind);
      }
    }
  }
  void SetKind(int kind) { SetKindTraverser<0>(kind); }

  parser::CharBlock literal;
  evaluate::FoldingContext &context;
  std::optional<Expr<evaluate::SomeReal>> result;
};

static std::optional<Expr<evaluate::SomeReal>> AnalyzeLiteral(
    ExpressionAnalyzer &ea, const parser::RealLiteralConstant &x) {
  // Use a local message context around the real literal.
  parser::ContextualMessages ctxMsgs{x.real.source, ea.context().messages};
  evaluate::FoldingContext localFoldingContext{ctxMsgs, ea.context()};
  // If a kind parameter appears, it takes precedence.  In the absence of
  // an explicit kind parameter, the exponent letter (e.g., 'e'/'d')
  // determines the kind.
  typename ExpressionAnalyzer::KindParam defaultKind{ea.defaultRealKind()};
  const char *end{x.real.source.end()};
  for (const char *p{x.real.source.begin()}; p < end; ++p) {
    if (parser::IsLetter(*p)) {
      switch (*p) {
      case 'e': defaultKind = 4; break;
      case 'd': defaultKind = 8; break;
      case 'q': defaultKind = 16; break;
      default: ctxMsgs.Say("unknown exponent letter '%c'"_err_en_US, *p);
      }
      break;
    }
  }
  auto kind{ea.Analyze(x.kind, defaultKind)};
  RealHelper helper{x.real.source, localFoldingContext};
  helper.SetKind(kind);
  if (!helper.result.has_value()) {
    ctxMsgs.Say("unsupported REAL(KIND=%ju)"_err_en_US,
        static_cast<std::uintmax_t>(kind));
  }
  return helper.result;
}

static std::optional<Expr<evaluate::SomeReal>> AnalyzeLiteral(
    ExpressionAnalyzer &ea, const parser::SignedRealLiteralConstant &x) {
  if (auto result{
          AnalyzeLiteral(ea, std::get<parser::RealLiteralConstant>(x.t))}) {
    if (auto sign{std::get<std::optional<parser::Sign>>(x.t)}) {
      if (sign == parser::Sign::Negative) {
        return {-std::move(*result)};
      }
    }
    return result;
  }
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Name &n) {
  CHECK(n.symbol != nullptr);
  auto *details{n.symbol->detailsIf<ObjectEntityDetails>()};
  if (details == nullptr || !n.symbol->attrs().test(Attr::PARAMETER)) {
    ea.context().messages.Say(
        "name (%s) is not a defined constant"_err_en_US, n.ToString().data());
    return std::nullopt;
  }
  // TODO: enumerators, do they have the PARAMETER attribute?
  return std::nullopt;  // TODO parameters and enumerators
}

template<>
MaybeExpr AnalyzeHelper(
    ExpressionAnalyzer &ea, const parser::NamedConstant &n) {
  return AnalyzeHelper(ea, n.v);
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::ComplexPart &x) {
  return std::visit(common::visitors{[&](const parser::NamedConstant &n) {
                                       return AnalyzeHelper(ea, n);
                                     },
                        [&](const auto &literal) {
                          return PackageGeneric(AnalyzeLiteral(ea, literal));
                        }},
      x.u);
}

// Per F'2018 R718, if both components are INTEGER, they are both converted
// to default REAL and the result is default COMPLEX.  Otherwise, the
// kind of the result is the kind of largest REAL component, and the other
// component is converted if necessary its type.
static std::optional<Expr<evaluate::SomeComplex>> AnalyzeLiteral(
    ExpressionAnalyzer &ea, const parser::ComplexLiteralConstant &z) {
  const parser::ComplexPart &re{std::get<0>(z.t)}, &im{std::get<1>(z.t)};
  return ea.ConstructComplex(AnalyzeHelper(ea, re), AnalyzeHelper(ea, im));
}

static std::optional<Expr<evaluate::SomeCharacter>> AnalyzeLiteral(
    ExpressionAnalyzer &ea, const parser::HollerithLiteralConstant &x) {
  Expr<evaluate::DefaultCharacter> expr{x.v};
  return {Expr<evaluate::SomeCharacter>{expr}};
}

static std::optional<Expr<evaluate::SomeLogical>> AnalyzeLiteral(
    ExpressionAnalyzer &ea, const parser::LogicalLiteralConstant &x) {
  auto kind{ea.Analyze(std::get<std::optional<parser::KindParam>>(x.t),
      ea.defaultLogicalKind())};
  bool value{std::get<bool>(x.t)};
  ConstantHelper<TypeCategory::Logical, bool> helper{std::move(value)};
  helper.SetKind(kind);
  if (!helper.result.has_value()) {
    ea.context().messages.Say("unsupported LOGICAL(KIND=%ju)"_err_en_US,
        static_cast<std::uintmax_t>(kind));
  }
  return std::move(helper.result);
}

template<>
MaybeExpr AnalyzeHelper(
    ExpressionAnalyzer &ea, const parser::LiteralConstant &x) {
  return std::visit(
      [&](const auto &c) { return PackageGeneric(AnalyzeLiteral(ea, c)); },
      x.u);
}

template<>
MaybeExpr AnalyzeHelper(
    ExpressionAnalyzer &ea, const parser::ArrayConstructor &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(
    ExpressionAnalyzer &ea, const parser::StructureConstructor &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(
    ExpressionAnalyzer &ea, const parser::TypeParamInquiry &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(
    ExpressionAnalyzer &ea, const parser::FunctionReference &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(
    ExpressionAnalyzer &ea, const parser::Expr::Parentheses &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(
    ExpressionAnalyzer &ea, const parser::Expr::UnaryPlus &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr::Negate &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr::NOT &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(
    ExpressionAnalyzer &ea, const parser::Expr::PercentLoc &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(
    ExpressionAnalyzer &ea, const parser::Expr::DefinedUnary &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr::Power &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(
    ExpressionAnalyzer &ea, const parser::Expr::Multiply &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr::Divide &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr::Add &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(
    ExpressionAnalyzer &ea, const parser::Expr::Subtract &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr::Concat &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr::LT &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr::LE &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr::EQ &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr::NE &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr::GE &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr::GT &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr::AND &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr::OR &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr::EQV &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr::NEQV &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(ExpressionAnalyzer &ea, const parser::Expr::XOR &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(
    ExpressionAnalyzer &ea, const parser::Expr::DefinedBinary &x) {
  // TODO
  return std::nullopt;
}

template<>
MaybeExpr AnalyzeHelper(
    ExpressionAnalyzer &ea, const parser::Expr::ComplexConstructor &x) {
  return PackageGeneric(ea.ConstructComplex(
      ea.Analyze(*std::get<0>(x.t)), ea.Analyze(*std::get<1>(x.t))));
}

MaybeExpr ExpressionAnalyzer::Analyze(const parser::Expr &x) {
  return std::visit(common::visitors{[&](const parser::LiteralConstant &c) {
                                       return AnalyzeHelper(*this, c);
                                     },
                        // TODO: remaining cases
                        [&](const auto &) { return MaybeExpr{}; }},
      x.u);
}

ExpressionAnalyzer::KindParam ExpressionAnalyzer::Analyze(
    const std::optional<parser::KindParam> &kindParam, KindParam defaultKind,
    KindParam kanjiKind) {
  if (!kindParam.has_value()) {
    return defaultKind;
  }
  return std::visit(
      common::visitors{
          [](std::uint64_t k) { return static_cast<KindParam>(k); },
          [&](const parser::Scalar<
              parser::Integer<parser::Constant<parser::Name>>> &n) {
            if (MaybeIntExpr ie{AnalyzeHelper(*this, n)}) {
              return *ie->ScalarValue()->ToInt64();
            }
            context_.messages.Say(
                "KIND type parameter must be a scalar integer constant"_err_en_US);
            return defaultKind;
          },
          [&](parser::KindParam::Kanji) {
            if (kanjiKind >= 0) {
              return kanjiKind;
            }
            context_.messages.Say("Kanji not allowed here"_err_en_US);
            return defaultKind;
          }},
      kindParam->u);
}

std::optional<Expr<evaluate::SomeComplex>> ExpressionAnalyzer::ConstructComplex(
    MaybeExpr &&real, MaybeExpr &&imaginary) {
  if (auto converted{evaluate::ConvertRealOperands(
          context_.messages, std::move(real), std::move(imaginary))}) {
    return {std::visit(
        [](auto &&pair) -> std::optional<Expr<evaluate::SomeComplex>> {
          using realType = evaluate::ResultType<decltype(pair[0])>;
          using zType = evaluate::SameKind<TypeCategory::Complex, realType>;
          auto cmplx{evaluate::ComplexConstructor<zType::kind>{
              std::move(pair[0]), std::move(pair[1])}};
          return {evaluate::AsCategoryExpr(evaluate::AsExpr(std::move(cmplx)))};
        },
        *converted)};
  }
  return std::nullopt;
}

}  // namespace Fortran::semantics
