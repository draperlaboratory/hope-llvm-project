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
#include "llvm/Support/TargetRegistry.h"

#include "ISP.h"

using namespace llvm;

class ISPAsmPrinter : public RISCVAsmPrinter {
  
public:
  explicit ISPAsmPrinter(TargetMachine &TM,
			 std::unique_ptr<MCStreamer> Streamer)
    : RISCVAsmPrinter(TM, std::move(Streamer)) {}
  
  void EmitFnRangeMetadata(MCSymbol *begin, MCSymbol *end);

  void EmitInstruction(const MachineInstr *MI) override;
};


//SSITH
void ISPAsmPrinter::EmitFnRangeMetadata(MCSymbol *begin, MCSymbol *end){
  
  SmallVector<MCFixup, 4> Fixups;

  MCContext &Ctx = OutContext;
  const MCExpr *MEbegin = MCSymbolRefExpr::create(begin, MCSymbolRefExpr::VK_None, Ctx);
  const MCExpr *MEend = MCSymbolRefExpr::create(end, MCSymbolRefExpr::VK_None, Ctx);

  //Push fixups -- the linker will write the 4 byte address for us
  Fixups.push_back(
      MCFixup::create(0, MEbegin, MCFixupKind(FK_Data_4), SMLoc::getFromPointer(nullptr)));
  Fixups.push_back(
      MCFixup::create(0, MEend, MCFixupKind(FK_Data_4), SMLoc::getFromPointer(nullptr)));

  // TODO: Pointer disasters
  OutStreamer->EmitLabel(end);
  ((ISPTargetELFStreamer*)(OutStreamer->getTargetStreamer()))->EmitSSITHMetadataEntry(Fixups, DMD_FUNCTION_RANGE, 0);
}

void ISPAsmPrinter::EmitInstruction(const MachineInstr *MI) {
  
  RISCVAsmPrinter::EmitInstruction(MI);
  
  // fn range avoids NoCFI on C code stuff
  // TODO: this may or may not be in the "right" place...
  if(MI->isReturn()) 
    EmitFnRangeMetadata(CurrentFnSym, OutContext.createTempSymbol());

  //SSITH - clean up in function epilog
  if(MI->getFlag(MachineInstr::FnEpilog) && MI->getOpcode() == RISCV::LW){
    //Emit our new store
    MCInst SSITHStore;
    LowerToSSITHEpilogStore(MI, SSITHStore, *this);
    EmitToStreamer(*OutStreamer, SSITHStore);
  }

}

// Force static initialization.
extern "C" void LLVMInitializeRISCVAsmPrinter() {
  RegisterAsmPrinter<ISPAsmPrinter> X(getTheRISCV32Target());
  RegisterAsmPrinter<ISPAsmPrinter> Y(getTheRISCV64Target());
}
