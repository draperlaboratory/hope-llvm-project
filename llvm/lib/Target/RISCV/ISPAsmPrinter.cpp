//===-- ISPAsmPrinter.cpp - ISP LLVM assembly writer ----------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that hooks the RISCV Printer in order to 
//   implement metadata output features.
//
//===----------------------------------------------------------------------===//

#include "llvm/CodeGen/MachineInstr.h"
#include "RISCV.h"
#include "RISCVAsmPrinter.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/TargetRegistry.h"
#include "TargetInfo/RISCVTargetInfo.h"

#include "ISP.h"

using namespace llvm;

class ISPAsmPrinter : public RISCVAsmPrinter {
  
public:
  explicit ISPAsmPrinter(TargetMachine &TM,
			 std::unique_ptr<MCStreamer> Streamer)
    : RISCVAsmPrinter(TM, std::move(Streamer)) {}
  
  void EmitFnRangeMetadata(MCSymbol *begin, MCSymbol *end);

  void emitInstruction(const MachineInstr *MI) override;
};


//SSITH
void ISPAsmPrinter::EmitFnRangeMetadata(MCSymbol *begin, MCSymbol *end){
  
  SmallVector<MCFixup, 4> Fixups;

  MCContext &Ctx = OutContext;
  const MCExpr *MEbegin = MCSymbolRefExpr::create(begin, Ctx);
  const MCExpr *MEend = MCSymbolRefExpr::create(end, Ctx);

  //Push fixups -- the linker will write the 4 byte address for us
  Fixups.push_back(MCFixup::create(0, MEbegin, MCFixupKind(FK_Data_4)));
  Fixups.push_back(MCFixup::create(0, MEend, MCFixupKind(FK_Data_4)));

  // TODO: Pointer disasters
  OutStreamer->emitLabel(end);
  ((ISPTargetELFStreamer*)(OutStreamer->getTargetStreamer()))->EmitSSITHMetadataEntry(Fixups, DMD_FUNCTION_RANGE, 0);
}

static void LowerToSSITHEpilogStore32(const MachineInstr *MI, MCInst &OutMI,
                                          const AsmPrinter &AP) {
  OutMI.setOpcode(RISCV::SW);

  bool first = true;
  for (const MachineOperand &MO : MI->operands()) {
    MCOperand MCOp;
    if(first){
      OutMI.addOperand(MCOperand::createReg(RISCV::X0));
      first = false;
    }
    else if (lowerRISCVMachineOperandToMCOperand(MO, MCOp, AP))
      OutMI.addOperand(MCOp);
  }

  OutMI.setFlags(MI->getFlags());
}

static void LowerToSSITHEpilogStore64(const MachineInstr *MI, MCInst &OutMI,
                                          const AsmPrinter &AP) {
  OutMI.setOpcode(RISCV::SD);

  bool first = true;
  for (const MachineOperand &MO : MI->operands()) {
    MCOperand MCOp;
    if(first){
      OutMI.addOperand(MCOperand::createReg(RISCV::X0));
      first = false;
    }
    else if (lowerRISCVMachineOperandToMCOperand(MO, MCOp, AP))
      OutMI.addOperand(MCOp);
  }

  OutMI.setFlags(MI->getFlags());
}

void ISPAsmPrinter::emitInstruction(const MachineInstr *MI) {
  // this is terrible
  auto *MutableMI = const_cast<MachineInstr *>(MI);
  MutableMI->setFlag(MachineInstr::HasParentFn);

  // If this is an epilog instruction that we replace
  // then it won't be the last instruction in the block
  if (MI->getFlag(MachineInstr::FnEpilog) &&
     (MI->getOpcode() == RISCV::LW || MI->getOpcode() == RISCV::LD)) {
   MutableMI->setFlags(MI->getFlags() % ~(MachineInstrFlags_t)MachineInstr::IsBlockEnd);
  }

  RISCVAsmPrinter::emitInstruction(MI);

  // fn range avoids NoCFI on C code stuff
  // TODO: this may or may not be in the "right" place...
  if(MI->isReturn() || MI->getFlag(MachineInstr::IsTailCall)) {
    EmitFnRangeMetadata(CurrentFnBegin, OutContext.createNamedTempSymbol("ISP_FUNC_END_"));
  }
  //SSITH - clean up in function epilog
  if(MI->getFlag(MachineInstr::FnEpilog) && MI->getOpcode() == RISCV::LW){
    //Emit our new store
    MCInst SSITHStore;
    LowerToSSITHEpilogStore32(MI, SSITHStore, *this);
    EmitToStreamer(*OutStreamer, SSITHStore);
  } else if(MI->getFlag(MachineInstr::FnEpilog) && MI->getOpcode() == RISCV::LD){
    //Same as above, but for 64-bit load instructions
    MCInst SSITHStore;
    LowerToSSITHEpilogStore64(MI, SSITHStore, *this);
    EmitToStreamer(*OutStreamer, SSITHStore);
  }

}

// Force static initialization.
extern "C" void LLVMInitializeRISCVAsmPrinter() {
  RegisterAsmPrinter<ISPAsmPrinter> X(getTheRISCV32Target());
  RegisterAsmPrinter<ISPAsmPrinter> Y(getTheRISCV64Target());
}
