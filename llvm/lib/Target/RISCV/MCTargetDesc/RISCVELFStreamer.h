//===-- RISCVELFStreamer.h - RISCV ELF Target Streamer ---------*- C++ -*--===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_RISCV_RISCVELFSTREAMER_H
#define LLVM_LIB_TARGET_RISCV_RISCVELFSTREAMER_H

#include "RISCVTargetStreamer.h"
#include "llvm/MC/MCELFStreamer.h"

namespace llvm {

class RISCVTargetELFStreamer : public RISCVTargetStreamer {
public:
  MCELFStreamer &getStreamer();
  RISCVTargetELFStreamer(MCStreamer &S, const MCSubtargetInfo &STI);

  virtual void emitDirectiveOptionPush()    override;
  virtual void emitDirectiveOptionPop()     override;
  virtual void emitDirectiveOptionRVC()     override;
  virtual void emitDirectiveOptionNoRVC()   override;
  virtual void emitDirectiveOptionRelax()   override;
  virtual void emitDirectiveOptionNoRelax() override;
};
}
#endif
