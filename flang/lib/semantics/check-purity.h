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

#ifndef FORTRAN_SEMANTICS_CHECK_PURITY_H_
#define FORTRAN_SEMANTICS_CHECK_PURITY_H_
#include "semantics.h"
#include <list>
namespace Fortran::parser {
struct ExecutableConstruct;
struct SubroutineSubprogram;
struct FunctionSubprogram;
struct PrefixSpec;
}
namespace Fortran::semantics {
class PurityChecker : public virtual BaseChecker {
public:
  explicit PurityChecker(SemanticsContext &c) : context_{c} {}
  void Enter(const parser::ExecutableConstruct &);
  void Enter(const parser::SubroutineSubprogram &);
  void Leave(const parser::SubroutineSubprogram &);
  void Enter(const parser::FunctionSubprogram &);
  void Leave(const parser::FunctionSubprogram &);

private:
  bool InPureSubprogram() const;
  bool HasPurePrefix(const std::list<parser::PrefixSpec> &) const;
  void Entered(parser::CharBlock, const std::list<parser::PrefixSpec> &);
  void Left();
  SemanticsContext &context_;
  int depth_{0};
  int pureDepth_{-1};
};
}
#endif
