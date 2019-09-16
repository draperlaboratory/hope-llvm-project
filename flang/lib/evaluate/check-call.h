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

// Constraint checking for procedure references

#ifndef FORTRAN_EVALUATE_CHECK_CALL_H_
#define FORTRAN_EVALUATE_CHECK_CALL_H_

#include "call.h"

namespace Fortran::parser {
class ContextualMessages;
}
namespace Fortran::evaluate::characteristics {
struct Procedure;
}

namespace Fortran::evaluate {
class FoldingContext;

// The Boolean flag argument should be true when the called procedure
// does not actually have an explicit interface at the call site, but
// its characteristics are known because it is a subroutine or function
// defined at the top level in the same source file.
void CheckArguments(const characteristics::Procedure &, ActualArguments &,
    FoldingContext &, bool treatingExternalAsImplicit = false);
}
#endif
