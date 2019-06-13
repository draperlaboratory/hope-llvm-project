//===-- RISCV.h - Top-level interface for RISCV -----------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the entry points for global functions defined in the LLVM
// RISC-V back-end.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_RISCV_ISP_H
#define LLVM_LIB_TARGET_RISCV_ISP_H

#include "llvm/MC/SSITHMetadata.h"
#include "MCTargetDesc/RISCVELFStreamer.h"

using namespace llvm;

class ISPTargetELFStreamer : public RISCVTargetELFStreamer {
public:
  ISPTargetELFStreamer(MCStreamer &S, const MCSubtargetInfo &STI);

  virtual void emitLabel(MCSymbol *Symbol) override;
  virtual void emitInstruction(const MCInst &Inst, const MCSubtargetInfo &) override;
  virtual void emitCommonSymbol(MCSymbol *Symbol, uint64_t Size,
				unsigned ByteAlignment) override;
  
  void EmitSSITHMetadataEntry(SmallVector<MCFixup, 4> &Fixups,
			      uint8_t MD_type, uint8_t tag);
  
private:

  bool ISPSecInitialized = false;

  void EmitMCSymbolMetadata(MCSymbol *Sym);
  void EmitMCInstMetadata(const MCInst &Inst);

  void EmitSSITHMetadataFnRange(MCSymbol *begin, MCSymbol *end);
  void EmitSSITHMetadataHeader(MCObjectStreamer &Streamer);
};

namespace llvm {
class PassRegistry;
class FunctionPass;
  
FunctionPass *createRISCVISPMetadataPass();
void initializeRISCVISPMetadataPass(PassRegistry &);

}

#endif
