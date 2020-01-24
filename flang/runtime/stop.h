//===-- runtime/stop.h ------------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef FORTRAN_RUNTIME_STOP_H_
#define FORTRAN_RUNTIME_STOP_H_

#include "c-or-cpp.h"
#include "entry-names.h"
#include <stdlib.h>

EXTERN_C_BEGIN

// Program-initiated image stop
NORETURN void RTNAME(StopStatement)(int code DEFAULT_VALUE(EXIT_SUCCESS),
    bool isErrorStop DEFAULT_VALUE(false), bool quiet DEFAULT_VALUE(false));
NORETURN void RTNAME(StopStatementText)(const char *,
    bool isErrorStop DEFAULT_VALUE(false), bool quiet DEFAULT_VALUE(false));
NORETURN void RTNAME(FailImageStatement)(NO_ARGUMENTS);
NORETURN void RTNAME(ProgramEndStatement)(NO_ARGUMENTS);

EXTERN_C_END

#endif  // FORTRAN_RUNTIME_STOP_H_
