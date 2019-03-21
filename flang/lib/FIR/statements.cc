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

#include "statements.h"

namespace Fortran::FIR {

Addressable_impl *GetAddressable(Statement *stmt) {
  return std::visit(
      [](auto &s) -> Addressable_impl * {
        if constexpr (std::is_base_of_v<Addressable_impl,
                          std::decay_t<decltype(s)>>) {
          return &s;
        }
        return nullptr;
      },
      stmt->u);
}

static std::string dump(const Expression &e) {
  std::stringstream stringStream;
  e.AsFortran(stringStream);
  return stringStream.str();
}

BranchStmt::BranchStmt(const std::optional<Value> &cond, BasicBlock *trueBlock,
    BasicBlock *falseBlock)
  : condition_{cond}, succs_{trueBlock, falseBlock} {
  CHECK(succs_[TrueIndex]);
  if (cond) {
    CHECK(condition_);
    CHECK(succs_[FalseIndex]);
  }
}

template<typename L>
static std::list<BasicBlock *> SuccBlocks(
    const typename L::ValueSuccPairListType &valueSuccPairList) {
  std::pair<std::list<typename L::ValueType>, std::list<BasicBlock *>> result;
  UnzipSnd(result, valueSuccPairList.begin(), valueSuccPairList.end());
  return result.second;
}

ReturnStmt::ReturnStmt(Statement *exp) : value_{GetApplyExpr(exp)} {
  CHECK(value_);
}

SwitchStmt::SwitchStmt(const Value &cond, const ValueSuccPairListType &args)
  : condition_{cond} {
  valueSuccPairs_.insert(valueSuccPairs_.end(), args.begin(), args.end());
}
std::list<BasicBlock *> SwitchStmt::succ_blocks() const {
  return SuccBlocks<SwitchStmt>(valueSuccPairs_);
}
BasicBlock *SwitchStmt::defaultSucc() const {
  CHECK(IsNothing(valueSuccPairs_[0].first));
  return valueSuccPairs_[0].second;
}

SwitchCaseStmt::SwitchCaseStmt(Value cond, const ValueSuccPairListType &args)
  : condition_{cond} {
  valueSuccPairs_.insert(valueSuccPairs_.end(), args.begin(), args.end());
}
std::list<BasicBlock *> SwitchCaseStmt::succ_blocks() const {
  return SuccBlocks<SwitchCaseStmt>(valueSuccPairs_);
}
BasicBlock *SwitchCaseStmt::defaultSucc() const {
  CHECK(std::holds_alternative<Default>(valueSuccPairs_[0].first));
  return valueSuccPairs_[0].second;
}

SwitchTypeStmt::SwitchTypeStmt(Value cond, const ValueSuccPairListType &args)
  : condition_{cond} {
  valueSuccPairs_.insert(valueSuccPairs_.end(), args.begin(), args.end());
}
std::list<BasicBlock *> SwitchTypeStmt::succ_blocks() const {
  return SuccBlocks<SwitchTypeStmt>(valueSuccPairs_);
}
BasicBlock *SwitchTypeStmt::defaultSucc() const {
  CHECK(std::holds_alternative<Default>(valueSuccPairs_[0].first));
  return valueSuccPairs_[0].second;
}

SwitchRankStmt ::SwitchRankStmt(Value cond, const ValueSuccPairListType &args)
  : condition_{cond} {
  valueSuccPairs_.insert(valueSuccPairs_.end(), args.begin(), args.end());
}
std::list<BasicBlock *> SwitchRankStmt::succ_blocks() const {
  return SuccBlocks<SwitchRankStmt>(valueSuccPairs_);
}
BasicBlock *SwitchRankStmt::defaultSucc() const {
  CHECK(std::holds_alternative<Default>(valueSuccPairs_[0].first));
  return valueSuccPairs_[0].second;
}

// check LoadInsn constraints
static void CheckLoadInsn(const Value &v) {
  std::visit(
      common::visitors{
          [](DataObject *) { /* ok */ },
          [](Statement *s) { CHECK(GetAddressable(s)); },
          [](auto) { CHECK(!"invalid load input"); },
      },
      v.u);
}
LoadInsn::LoadInsn(const Value &addr) : address_{addr} {
  CheckLoadInsn(address_);
}
LoadInsn::LoadInsn(Value &&addr) : address_{std::move(addr)} {
  CheckLoadInsn(address_);
}
LoadInsn::LoadInsn(Statement *addr) : address_{addr} {
  CHECK(GetAddressable(addr));
}

StoreInsn::StoreInsn(Statement *addr, Statement *val)
  : address_{GetAddressable(addr)} {
  CHECK(address_);
  if (auto *value{GetAddressable(val)}) {
    value_ = value;
  } else {
    auto *expr{GetApplyExpr(val)};
    CHECK(expr);
    value_ = expr;
  }
}
StoreInsn::StoreInsn(Statement *addr, BasicBlock *val)
  : address_{GetAddressable(addr)}, value_{val} {
  CHECK(address_);
  CHECK(val);
}

std::string Statement::dump() const {
  return std::visit(
      common::visitors{
          [](const ReturnStmt &) { return "return"s; },
          [](const BranchStmt &branch) {
            if (branch.hasCondition()) {
              std::string cond{"???"};
              return "branch (" + cond + ") " +
                  std::to_string(
                      reinterpret_cast<std::intptr_t>(branch.getTrueSucc())) +
                  ' ' +
                  std::to_string(
                      reinterpret_cast<std::intptr_t>(branch.getFalseSucc()));
            }
            return "goto " +
                std::to_string(
                    reinterpret_cast<std::intptr_t>(branch.getTrueSucc()));
          },
          [](const SwitchStmt &stmt) {
            // return "switch(" + stmt.getCond().dump() + ")";
            return "switch(?)"s;
          },
          [](const SwitchCaseStmt &switchCaseStmt) {
            // return "switch-case(" + switchCaseStmt.getCond().dump() + ")";
            return "switch-case(?)"s;
          },
          [](const SwitchTypeStmt &switchTypeStmt) {
            // return "switch-type(" + switchTypeStmt.getCond().dump() + ")";
            return "switch-type(?)"s;
          },
          [](const SwitchRankStmt &switchRankStmt) {
            // return "switch-rank(" + switchRankStmt.getCond().dump() + ")";
            return "switch-rank(?)"s;
          },
          [](const IndirectBranchStmt &) { return "ibranch"s; },
          [](const UnreachableStmt &) { return "unreachable"s; },
          [](const ApplyExprStmt &e) { return FIR::dump(e.expression()); },
          [](const LocateExprStmt &e) {
            return "&" + FIR::dump(e.expression());
          },
          [](const AllocateInsn &) { return "alloc"s; },
          [](const DeallocateInsn &) { return "dealloc"s; },
          [](const AllocateLocalInsn &) { return "alloca"s; },
          [](const LoadInsn &) { return "load"s; },
          [](const StoreInsn &) { return "store"s; },
          [](const DisassociateInsn &) { return "NULLIFY"s; },
          [](const CallStmt &) { return "call"s; },
          [](const RuntimeStmt &) { return "runtime-call()"s; },
          [](const IORuntimeStmt &) { return "io-call()"s; },
          [](const ScopeEnterStmt &) { return "scopeenter"s; },
          [](const ScopeExitStmt &) { return "scopeexit"s; },
          [](const PHIStmt &) { return "PHI"s; },
      },
      u);
}
}
