//===-- runtime/terminator.h ------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// Termination of the image

#ifndef FORTRAN_RUNTIME_TERMINATOR_H_
#define FORTRAN_RUNTIME_TERMINATOR_H_

#include "entry-names.h"
#include <cstdarg>

namespace Fortran::runtime {

// A mixin class for statement-specific image error termination
// for errors detected in the runtime library
class Terminator {
public:
  Terminator() {}
  explicit Terminator(const char *sourceFileName, int sourceLine = 0)
    : sourceFileName_{sourceFileName}, sourceLine_{sourceLine} {}
  void SetLocation(const char *sourceFileName = nullptr, int sourceLine = 0) {
    sourceFileName_ = sourceFileName;
    sourceLine_ = sourceLine;
  }
  [[noreturn]] void Crash(const char *message, ...);
  [[noreturn]] void CrashArgs(const char *message, va_list &);

private:
  const char *sourceFileName_{nullptr};
  int sourceLine_{0};
};

void NotifyOtherImagesOfNormalEnd();
void NotifyOtherImagesOfFailImageStatement();
void NotifyOtherImagesOfErrorTermination();
}
#endif  // FORTRAN_RUNTIME_TERMINATOR_H_
