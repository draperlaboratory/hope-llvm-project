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

#include "check-do-concurrent.h"
#include "attr.h"
#include "scope.h"
#include "symbol.h"
#include "../parser/message.h"
#include "../parser/parse-tree-visitor.h"

namespace Fortran::semantics {

using namespace parser::literals;

// 11.1.7.5 - enforce semantics constraints on a DO CONCURRENT loop body
class DoConcurrentEnforcement {
public:
  DoConcurrentEnforcement(parser::Messages &messages) : messages_{messages} {}
  std::set<parser::Label> labels() { return labels_; }
  template<typename T> bool Pre(const T &) { return true; }
  template<typename T> void Post(const T &) {}
  template<typename T> bool Pre(const parser::Statement<T> &statement) {
    currentStatementSourcePosition_ = statement.source;
    if (statement.label.has_value()) {
      labels_.insert(*statement.label);
    }
    return true;
  }
  // C1136
  void Post(const parser::ReturnStmt &) {
    messages_.Say(currentStatementSourcePosition_,
        "RETURN not allowed in DO CONCURRENT"_err_en_US);
  }
  // C1137
  void NoImageControl() {
    messages_.Say(currentStatementSourcePosition_,
        "image control statement not allowed in DO CONCURRENT"_err_en_US);
  }
  void Post(const parser::SyncAllStmt &) { NoImageControl(); }
  void Post(const parser::SyncImagesStmt &) { NoImageControl(); }
  void Post(const parser::SyncMemoryStmt &) { NoImageControl(); }
  void Post(const parser::SyncTeamStmt &) { NoImageControl(); }
  void Post(const parser::ChangeTeamConstruct &) { NoImageControl(); }
  void Post(const parser::CriticalConstruct &) { NoImageControl(); }
  void Post(const parser::EventPostStmt &) { NoImageControl(); }
  void Post(const parser::EventWaitStmt &) { NoImageControl(); }
  void Post(const parser::FormTeamStmt &) { NoImageControl(); }
  void Post(const parser::LockStmt &) { NoImageControl(); }
  void Post(const parser::UnlockStmt &) { NoImageControl(); }
  void Post(const parser::StopStmt &) { NoImageControl(); }
  void Post(const parser::EndProgramStmt &) { NoImageControl(); }

  void Post(const parser::AllocateStmt &) {
    if (anyObjectIsCoarray()) {
      messages_.Say(currentStatementSourcePosition_,
          "ALLOCATE coarray not allowed in DO CONCURRENT"_err_en_US);
    }
  }
  void Post(const parser::DeallocateStmt &) {
    if (anyObjectIsCoarray()) {
      messages_.Say(currentStatementSourcePosition_,
          "DEALLOCATE coarray not allowed in DO CONCURRENT"_err_en_US);
    }
    // C1140: deallocation of polymorphic objects
    if (anyObjectIsPolymorphic()) {
      messages_.Say(currentStatementSourcePosition_,
          "DEALLOCATE polymorphic object(s) not allowed"
          " in DO CONCURRENT"_err_en_US);
    }
  }
  template<typename T> void Post(const parser::Statement<T> &) {
    if (EndTDeallocatesCoarray()) {
      messages_.Say(currentStatementSourcePosition_,
          "implicit deallocation of coarray not allowed"
          " in DO CONCURRENT"_err_en_US);
    }
  }
  // C1141: cannot call ieee_get_flag, ieee_[gs]et_halting_mode
  void Post(const parser::ProcedureDesignator &procedureDesignator) {
    if (auto *name{std::get_if<parser::Name>(&procedureDesignator.u)}) {
      // C1137: call move_alloc with coarray arguments
      if (name->ToString() == "move_alloc"s) {
        if (anyObjectIsCoarray()) {
          messages_.Say(currentStatementSourcePosition_,
              "call to MOVE_ALLOC intrinsic in DO CONCURRENT with coarray"
              " argument(s) not allowed"_err_en_US);
        }
      }
      // C1139: call to impure procedure
      if (name->symbol && !isPure(name->symbol->attrs())) {
        messages_.Say(currentStatementSourcePosition_,
            "call to impure subroutine in DO CONCURRENT not allowed"_err_en_US);
      }
      if (name->symbol && fromScope(*name->symbol, "ieee_exceptions"s)) {
        if (name->ToString() == "ieee_get_flag"s) {
          messages_.Say(currentStatementSourcePosition_,
              "IEEE_GET_FLAG not allowed in DO CONCURRENT"_err_en_US);
        } else if (name->ToString() == "ieee_set_halting_mode"s) {
          messages_.Say(currentStatementSourcePosition_,
              "IEEE_SET_HALTING_MODE not allowed in DO CONCURRENT"_err_en_US);
        } else if (name->ToString() == "ieee_get_halting_mode"s) {
          messages_.Say(currentStatementSourcePosition_,
              "IEEE_GET_HALTING_MODE not allowed in DO CONCURRENT"_err_en_US);
        }
      }
    } else {
      // C1139: this a procedure component
      auto &component{std::get<parser::ProcComponentRef>(procedureDesignator.u)
                          .v.thing.component};
      if (component.symbol && !isPure(component.symbol->attrs())) {
        messages_.Say(currentStatementSourcePosition_,
            "call to impure subroutine in DO CONCURRENT not allowed"_err_en_US);
      }
    }
  }

  // 11.1.7.5
  void Post(const parser::IoControlSpec &ioControlSpec) {
    if (auto *charExpr{
            std::get_if<parser::IoControlSpec::CharExpr>(&ioControlSpec.u)}) {
      if (std::get<parser::IoControlSpec::CharExpr::Kind>(charExpr->t) ==
          parser::IoControlSpec::CharExpr::Kind::Advance) {
        messages_.Say(currentStatementSourcePosition_,
            "ADVANCE specifier not allowed in DO CONCURRENT"_err_en_US);
      }
    }
  }

private:
  bool anyObjectIsCoarray() { return false; }  // FIXME placeholder
  bool anyObjectIsPolymorphic() { return false; }  // FIXME placeholder
  bool EndTDeallocatesCoarray() { return false; }  // FIXME placeholder
  bool isPure(Attrs &attrs) {
    return attrs.test(Attr::PURE) ||
        (attrs.test(Attr::ELEMENTAL) && !attrs.test(Attr::IMPURE));
  }
  bool fromScope(const Symbol &symbol, const std::string &moduleName) {
    if (symbol.scope() && symbol.scope()->IsModule()) {
      if (symbol.scope()->symbol()->name().ToString() == moduleName) {
        return true;
      }
    }
    return false;
  }

  std::set<parser::Label> labels_;
  parser::CharBlock currentStatementSourcePosition_;
  parser::Messages &messages_;
};

class DoConcurrentLabelEnforce {
public:
  DoConcurrentLabelEnforce(
      parser::Messages &messages, std::set<parser::Label> &&labels)
    : messages_{messages}, labels_{labels} {}
  template<typename T> bool Pre(const T &) { return true; }
  template<typename T> bool Pre(const parser::Statement<T> &statement) {
    currentStatementSourcePosition_ = statement.source;
    return true;
  }
  template<typename T> void Post(const T &) {}

  // C1138: branch from within a DO CONCURRENT shall not target outside loop
  void Post(const parser::GotoStmt &gotoStmt) { checkLabelUse(gotoStmt.v); }
  void Post(const parser::ComputedGotoStmt &computedGotoStmt) {
    for (auto &i : std::get<std::list<parser::Label>>(computedGotoStmt.t)) {
      checkLabelUse(i);
    }
  }
  void Post(const parser::ArithmeticIfStmt &arithmeticIfStmt) {
    checkLabelUse(std::get<1>(arithmeticIfStmt.t));
    checkLabelUse(std::get<2>(arithmeticIfStmt.t));
    checkLabelUse(std::get<3>(arithmeticIfStmt.t));
  }
  void Post(const parser::AssignStmt &assignStmt) {
    checkLabelUse(std::get<parser::Label>(assignStmt.t));
  }
  void Post(const parser::AssignedGotoStmt &assignedGotoStmt) {
    for (auto &i : std::get<std::list<parser::Label>>(assignedGotoStmt.t)) {
      checkLabelUse(i);
    }
  }
  void Post(const parser::AltReturnSpec &altReturnSpec) {
    checkLabelUse(altReturnSpec.v);
  }
  void Post(const parser::ErrLabel &errLabel) { checkLabelUse(errLabel.v); }
  void Post(const parser::EndLabel &endLabel) { checkLabelUse(endLabel.v); }
  void Post(const parser::EorLabel &eorLabel) { checkLabelUse(eorLabel.v); }
  void checkLabelUse(const parser::Label &labelUsed) {
    if (labels_.find(labelUsed) == labels_.end()) {
      messages_.Say(currentStatementSourcePosition_,
          "control flow escapes from DO CONCURRENT"_err_en_US);
    }
  }

private:
  parser::Messages &messages_;
  std::set<parser::Label> labels_;
  parser::CharBlock currentStatementSourcePosition_{nullptr};
};

// Find a canonical DO CONCURRENT and enforce semantics checks on its body
class FindDoConcurrentLoops {
public:
  FindDoConcurrentLoops(parser::Messages &messages) : messages_{messages} {}
  template<typename T> constexpr bool Pre(const T &) { return true; }
  template<typename T> constexpr void Post(const T &) {}
  template<typename T> constexpr bool Pre(const parser::Statement<T> &) {
    return false;
  }
  bool Pre(const parser::DoConstruct &doConstruct) {
    if (std::get<std::optional<parser::LoopControl>>(
            std::get<parser::Statement<parser::NonLabelDoStmt>>(doConstruct.t)
                .statement.t)
            .has_value() &&
        std::holds_alternative<parser::LoopControl::Concurrent>(
            std::get<std::optional<parser::LoopControl>>(
                std::get<parser::Statement<parser::NonLabelDoStmt>>(
                    doConstruct.t)
                    .statement.t)
                ->u)) {
      DoConcurrentEnforcement doConcurrentEnforcement{messages_};
      parser::Walk(
          std::get<parser::Block>(doConstruct.t), doConcurrentEnforcement);
      DoConcurrentLabelEnforce doConcurrentLabelEnforce{
          messages_, doConcurrentEnforcement.labels()};
      parser::Walk(
          std::get<parser::Block>(doConstruct.t), doConcurrentLabelEnforce);
    }
    return true;
  }

private:
  parser::Messages &messages_;
};

// DO loops must be canonicalized prior to calling
void CheckDoConcurrentConstraints(
    parser::Messages &messages, const parser::Program &program) {
  FindDoConcurrentLoops findDoConcurrentLoops{messages};
  Walk(program, findDoConcurrentLoops);
}

}  // namespace Fortran::semantics
