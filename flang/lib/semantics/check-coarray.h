//===-- lib/semantics/check-coarray.h ---------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef FORTRAN_SEMANTICS_CHECK_COARRAY_H_
#define FORTRAN_SEMANTICS_CHECK_COARRAY_H_

#include "flang/semantics/semantics.h"
#include <list>

namespace Fortran::parser {
class CharBlock;
class MessageFixedText;
struct ChangeTeamStmt;
struct CoarrayAssociation;
struct FormTeamStmt;
struct ImageSelectorSpec;
struct SyncTeamStmt;
struct TeamValue;
}

namespace Fortran::semantics {

class CoarrayChecker : public virtual BaseChecker {
public:
  CoarrayChecker(SemanticsContext &context) : context_{context} {}
  void Leave(const parser::ChangeTeamStmt &);
  void Leave(const parser::SyncTeamStmt &);
  void Leave(const parser::ImageSelectorSpec &);
  void Leave(const parser::FormTeamStmt &);

  void Enter(const parser::CriticalConstruct &);

private:
  SemanticsContext &context_;

  void CheckNamesAreDistinct(const std::list<parser::CoarrayAssociation> &);
  void Say2(const parser::CharBlock &, parser::MessageFixedText &&,
      const parser::CharBlock &, parser::MessageFixedText &&);
};
}
#endif  // FORTRAN_SEMANTICS_CHECK_COARRAY_H_
