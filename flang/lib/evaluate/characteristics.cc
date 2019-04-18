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

#include "characteristics.h"
#include "intrinsics.h"
#include "tools.h"
#include "type.h"
#include "../common/indirection.h"
#include "../semantics/symbol.h"
#include <ostream>
#include <sstream>
#include <string>

using namespace std::literals::string_literals;

namespace Fortran::evaluate::characteristics {

bool TypeAndShape::operator==(const TypeAndShape &that) const {
  return type_ == that.type_ && shape_ == that.shape_ &&
      isAssumedRank_ == that.isAssumedRank_;
}

std::optional<TypeAndShape> TypeAndShape::Characterize(
    const semantics::Symbol &symbol) {
  if (const auto *object{symbol.detailsIf<semantics::ObjectEntityDetails>()}) {
    return Characterize(*object);
  } else if (const auto *proc{
                 symbol.detailsIf<semantics::ProcEntityDetails>()}) {
    return Characterize(*proc);
  } else {
    return std::nullopt;
  }
}

std::optional<TypeAndShape> TypeAndShape::Characterize(
    const semantics::Symbol *symbol) {
  if (symbol != nullptr) {
    return Characterize(*symbol);
  } else {
    return std::nullopt;
  }
}

std::optional<TypeAndShape> TypeAndShape::Characterize(
    const semantics::ObjectEntityDetails &object) {
  if (auto type{AsDynamicType(object.type())}) {
    TypeAndShape result{std::move(*type)};
    result.AcquireShape(object);
    return result;
  } else {
    return std::nullopt;
  }
}

std::optional<TypeAndShape> TypeAndShape::Characterize(
    const semantics::ProcEntityDetails &proc) {
  return Characterize(proc.interface());
}

std::optional<TypeAndShape> TypeAndShape::Characterize(
    const semantics::ProcInterface &interface) {
  if (auto maybeType{Characterize(interface.symbol())}) {
    return maybeType;
  } else {
    return Characterize(interface.type());
  }
}

std::optional<TypeAndShape> TypeAndShape::Characterize(
    const semantics::DeclTypeSpec &spec) {
  if (auto type{AsDynamicType(spec)}) {
    return TypeAndShape{std::move(*type)};
  } else {
    return std::nullopt;
  }
}

std::optional<TypeAndShape> TypeAndShape::Characterize(
    const semantics::DeclTypeSpec *spec) {
  if (spec != nullptr) {
    return Characterize(*spec);
  } else {
    return std::nullopt;
  }
}

void TypeAndShape::AcquireShape(const semantics::ObjectEntityDetails &object) {
  CHECK(shape_.empty() && !isAssumedRank_);
  if (object.IsAssumedRank()) {
    isAssumedRank_ = true;
    return;
  }
  for (const semantics::ShapeSpec &dim : object.shape()) {
    if (dim.ubound().GetExplicit().has_value()) {
      Expr<SubscriptInteger> extent{*dim.ubound().GetExplicit()};
      if (dim.lbound().GetExplicit().has_value()) {
        extent = std::move(extent) +
            common::Clone(*dim.lbound().GetExplicit()) -
            Expr<SubscriptInteger>{1};
      }
      shape_.emplace_back(std::move(extent));
    } else {
      shape_.push_back(std::nullopt);
    }
  }
}

std::ostream &TypeAndShape::Dump(std::ostream &o) const {
  o << type_.AsFortran();
  if (!shape_.empty()) {
    o << " dimension(";
    char sep{'('};
    for (const auto &expr : shape_) {
      o << sep;
      sep = ',';
      if (expr.has_value()) {
        expr->AsFortran(o);
      } else {
        o << ':';
      }
    }
    o << ')';
  } else if (isAssumedRank_) {
    o << " dimension(*)";
  }
  return o;
}

bool DummyDataObject::operator==(const DummyDataObject &that) const {
  return TypeAndShape::operator==(that) && attrs == that.attrs &&
      intent == that.intent && coshape == that.coshape;
}

std::ostream &DummyDataObject::Dump(std::ostream &o) const {
  attrs.Dump(o, EnumToString);
  if (intent != common::Intent::Default) {
    o << "INTENT(" << common::EnumToString(intent) << ')';
  }
  TypeAndShape::Dump(o);
  if (!coshape.empty()) {
    char sep{'['};
    for (const auto &expr : coshape) {
      expr.AsFortran(o << sep);
      sep = ',';
    }
  }
  return o;
}

DummyProcedure::DummyProcedure(Procedure &&p)
  : procedure{new Procedure{std::move(p)}} {}

bool DummyProcedure::operator==(const DummyProcedure &that) const {
  return attrs == that.attrs && procedure.value() == that.procedure.value();
}

std::ostream &DummyProcedure::Dump(std::ostream &o) const {
  attrs.Dump(o, EnumToString);
  procedure.value().Dump(o);
  return o;
}

std::ostream &AlternateReturn::Dump(std::ostream &o) const { return o << '*'; }

bool IsOptional(const DummyArgument &da) {
  return std::visit(
      common::visitors{
          [](const DummyDataObject &data) {
            return data.attrs.test(DummyDataObject::Attr::Optional);
          },
          [](const DummyProcedure &proc) {
            return proc.attrs.test(DummyProcedure::Attr::Optional);
          },
          [](const AlternateReturn &) { return false; },
      },
      da);
}

FunctionResult::~FunctionResult() = default;

bool FunctionResult::operator==(const FunctionResult &that) const {
  return attrs == that.attrs && u == that.u;
}

std::ostream &FunctionResult::Dump(std::ostream &o) const {
  attrs.Dump(o, EnumToString);
  std::visit(
      common::visitors{
          [&](const TypeAndShape &ts) { ts.Dump(o); },
          [&](const common::CopyableIndirection<Procedure> &p) {
            p.value().Dump(o << " procedure(") << ')';
          },
      },
      u);
  return o;
}

bool Procedure::operator==(const Procedure &that) const {
  return attrs == that.attrs && dummyArguments == that.dummyArguments &&
      functionResult == that.functionResult;
}

std::ostream &Procedure::Dump(std::ostream &o) const {
  attrs.Dump(o, EnumToString);
  if (functionResult.has_value()) {
    functionResult->Dump(o << "TYPE(") << ") FUNCTION";
  } else {
    o << "SUBROUTINE";
  }
  char sep{'('};
  for (const auto &dummy : dummyArguments) {
    o << sep;
    sep = ',';
    std::visit([&](const auto &x) { x.Dump(o); }, dummy);
  }
  return o << (sep == '(' ? "()" : ")");
}

std::optional<DummyDataObject> DummyDataObject::Characterize(
    const semantics::Symbol &symbol) {
  if (const auto *obj{symbol.detailsIf<semantics::ObjectEntityDetails>()}) {
    if (auto type{TypeAndShape::Characterize(*obj)}) {
      DummyDataObject result{*type};
      if (symbol.attrs().test(semantics::Attr::OPTIONAL)) {
        result.attrs.set(DummyDataObject::Attr::Optional);
      }
      if (symbol.attrs().test(semantics::Attr::ALLOCATABLE)) {
        result.attrs.set(DummyDataObject::Attr::Allocatable);
      }
      if (symbol.attrs().test(semantics::Attr::ASYNCHRONOUS)) {
        result.attrs.set(DummyDataObject::Attr::Asynchronous);
      }
      if (symbol.attrs().test(semantics::Attr::CONTIGUOUS)) {
        result.attrs.set(DummyDataObject::Attr::Contiguous);
      }
      if (symbol.attrs().test(semantics::Attr::VALUE)) {
        result.attrs.set(DummyDataObject::Attr::Value);
      }
      if (symbol.attrs().test(semantics::Attr::VOLATILE)) {
        result.attrs.set(DummyDataObject::Attr::Volatile);
      }
      if (symbol.attrs().test(semantics::Attr::POINTER)) {
        result.attrs.set(DummyDataObject::Attr::Pointer);
      }
      if (symbol.attrs().test(semantics::Attr::TARGET)) {
        result.attrs.set(DummyDataObject::Attr::Target);
      }
      if (symbol.attrs().test(semantics::Attr::INTENT_IN)) {
        result.intent = common::Intent::In;
      }
      if (symbol.attrs().test(semantics::Attr::INTENT_OUT)) {
        CHECK(result.intent == common::Intent::Default);
        result.intent = common::Intent::Out;
      }
      if (symbol.attrs().test(semantics::Attr::INTENT_INOUT)) {
        CHECK(result.intent == common::Intent::Default);
        result.intent = common::Intent::InOut;
      }
      // TODO: acquire coshape when symbol table represents it
      return result;
    }
  }
  return std::nullopt;
}

std::optional<DummyProcedure> DummyProcedure::Characterize(
    const semantics::Symbol &symbol, const IntrinsicProcTable &intrinsics) {
  if (symbol.has<semantics::ProcEntityDetails>()) {
    if (auto procedure{Procedure::Characterize(symbol, intrinsics)}) {
      DummyProcedure result{std::move(procedure.value())};
      if (symbol.attrs().test(semantics::Attr::OPTIONAL)) {
        result.attrs.set(DummyProcedure::Attr::Optional);
      }
      if (symbol.attrs().test(semantics::Attr::POINTER)) {
        result.attrs.set(DummyProcedure::Attr::Pointer);
      }
      return result;
    }
  }
  return std::nullopt;
}

std::optional<DummyArgument> CharacterizeDummyArgument(
    const semantics::Symbol &symbol, const IntrinsicProcTable &intrinsics) {
  if (auto objCharacteristics{DummyDataObject::Characterize(symbol)}) {
    return std::move(objCharacteristics.value());
  } else if (auto procCharacteristics{
                 DummyProcedure::Characterize(symbol, intrinsics)}) {
    return std::move(procCharacteristics.value());
  } else {
    return std::nullopt;
  }
}

std::optional<FunctionResult> FunctionResult::Characterize(
    const Symbol &symbol, const IntrinsicProcTable &intrinsics) {
  if (const auto *obj{symbol.detailsIf<semantics::ObjectEntityDetails>()}) {
    if (auto type{TypeAndShape::Characterize(*obj)}) {
      FunctionResult result{std::move(*type)};
      if (symbol.attrs().test(semantics::Attr::ALLOCATABLE)) {
        result.attrs.set(FunctionResult::Attr::Pointer);
      }
      if (symbol.attrs().test(semantics::Attr::CONTIGUOUS)) {
        result.attrs.set(FunctionResult::Attr::Contiguous);
      }
      if (symbol.attrs().test(semantics::Attr::POINTER)) {
        result.attrs.set(FunctionResult::Attr::Pointer);
      }
      return result;
    }
  } else if (auto maybeProc{Procedure::Characterize(symbol, intrinsics)}) {
    FunctionResult result{std::move(*maybeProc)};
    result.attrs.set(FunctionResult::Attr::Pointer);
    return result;
  }
  return std::nullopt;
}

bool FunctionResult::IsAssumedLengthCharacter() const {
  if (const auto *ts{std::get_if<TypeAndShape>(&u)}) {
    return ts->type().IsAssumedLengthCharacter();
  } else {
    return false;
  }
}

static void SetProcedureAttrs(
    Procedure &procedure, const semantics::Symbol &symbol) {
  if (symbol.attrs().test(semantics::Attr::PURE)) {
    procedure.attrs.set(Procedure::Attr::Pure);
  }
  if (symbol.attrs().test(semantics::Attr::ELEMENTAL)) {
    procedure.attrs.set(Procedure::Attr::Elemental);
  }
  if (symbol.attrs().test(semantics::Attr::BIND_C)) {
    procedure.attrs.set(Procedure::Attr::BindC);
  }
}

std::optional<Procedure> Procedure::Characterize(
    const semantics::Symbol &symbol, const IntrinsicProcTable &intrinsics) {
  Procedure result;
  if (const auto *subp{symbol.detailsIf<semantics::SubprogramDetails>()}) {
    if (subp->isFunction()) {
      if (auto maybeResult{
              FunctionResult::Characterize(subp->result(), intrinsics)}) {
        result.functionResult = std::move(maybeResult);
      } else {
        return std::nullopt;
      }
    }
    SetProcedureAttrs(result, symbol);
    for (const semantics::Symbol *arg : subp->dummyArgs()) {
      if (arg == nullptr) {
        result.dummyArguments.emplace_back(AlternateReturn{});
      } else if (auto argCharacteristics{
                     CharacterizeDummyArgument(*arg, intrinsics)}) {
        result.dummyArguments.emplace_back(
            std::move(argCharacteristics.value()));
      } else {
        return std::nullopt;
      }
    }
    return std::move(result);
  } else if (const auto *proc{
                 symbol.detailsIf<semantics::ProcEntityDetails>()}) {
    const semantics::ProcInterface &interface{proc->interface()};
    Procedure result;
    if (const semantics::Symbol * interfaceSymbol{interface.symbol()}) {
      if (auto characterized{Characterize(*interfaceSymbol, intrinsics)}) {
        result = *characterized;
      } else {
        return std::nullopt;
      }
    } else {
      result.attrs.set(Procedure::Attr::ImplicitInterface);
      if (const semantics::DeclTypeSpec * type{interface.type()}) {
        if (auto resultType{AsDynamicType(*type)}) {
          result.functionResult = FunctionResult{*resultType};
        } else {
          return std::nullopt;
        }
      } else {
        // subroutine, not function
      }
    }
    SetProcedureAttrs(result, symbol);
    // The PASS name, if any, is not a characteristic.
  } else if (const auto *misc{symbol.detailsIf<semantics::MiscDetails>()}) {
    if (misc->kind() == semantics::MiscDetails::Kind::SpecificIntrinsic) {
      if (auto intrinsic{intrinsics.IsUnrestrictedSpecificIntrinsicFunction(
              symbol.name().ToString())}) {
        return *intrinsic;
      }
    }
  }
  return std::nullopt;
}
DEFINE_DEFAULT_CONSTRUCTORS_AND_ASSIGNMENTS(DummyProcedure)
DEFINE_DEFAULT_CONSTRUCTORS_AND_ASSIGNMENTS(FunctionResult)
DEFINE_DEFAULT_CONSTRUCTORS_AND_ASSIGNMENTS(Procedure)
}
template class Fortran::common::Indirection<
    Fortran::evaluate::characteristics::Procedure, true>;
