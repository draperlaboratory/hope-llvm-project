//===-- RISCVAsmPrinter.cpp - RISCV LLVM assembly writer ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to the RISCV assembly language.
//
//===----------------------------------------------------------------------===//

#include "RISCV.h"
#include "InstPrinter/RISCVInstPrinter.h"
#include "MCTargetDesc/RISCVMCExpr.h"
#include "RISCVTargetMachine.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/raw_ostream.h"

//SSITH Extra includes
#include "MCTargetDesc/RISCVFixupKinds.h"
#include "llvm/BinaryFormat/ELF.h"
#include "llvm/MC/MCAsmBackend.h"
#include "llvm/MC/MCFixupKindInfo.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCSectionELF.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/SSITHMetadata.h"
#include "llvm/Target/TargetLoweringObjectFile.h"

using namespace llvm;

#define DEBUG_TYPE "asm-printer"

namespace {
class RISCVAsmPrinter : public AsmPrinter {
public:
  explicit RISCVAsmPrinter(TargetMachine &TM,
                           std::unique_ptr<MCStreamer> Streamer)
      : AsmPrinter(TM, std::move(Streamer)) {}

  StringRef getPassName() const override { return "RISCV Assembly Printer"; }

  void EmitInstruction(const MachineInstr *MI) override;

  bool PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                       const char *ExtraCode, raw_ostream &OS) override;
  bool PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNo,
                             const char *ExtraCode, raw_ostream &OS) override;

  bool EmitToStreamer(MCStreamer &S, const MCInst &Inst);
  bool emitPseudoExpansionLowering(MCStreamer &OutStreamer,
                                   const MachineInstr *MI);

  //SSITH Addition
  void EmitSSITHMetadataFnRange(MCSymbol *begin, MCSymbol *end) override;
  
  // Wrapper needed for tblgenned pseudo lowering.
  bool lowerOperand(const MachineOperand &MO, MCOperand &MCOp) const {
    return LowerRISCVMachineOperandToMCOperand(MO, MCOp, *this);
  }
};
}

#define GEN_COMPRESS_INSTR
#include "RISCVGenCompressInstEmitter.inc"
bool RISCVAsmPrinter::EmitToStreamer(MCStreamer &S, const MCInst &Inst) {
  MCInst CInst;
  bool Res = compressInst(CInst, Inst, *TM.getMCSubtargetInfo(),
                          OutStreamer->getContext());
  AsmPrinter::EmitToStreamer(*OutStreamer, Res ? CInst : Inst);

  return Res;
}

// Simple pseudo-instructions have their lowering (with expansion to real
// instructions) auto-generated.
#include "RISCVGenMCPseudoLowering.inc"

//SSITH
void RISCVAsmPrinter::EmitSSITHMetadataFnRange(MCSymbol *begin, MCSymbol *end){
  
  SmallVector<MCFixup, 4> Fixups;

  printf("Emitting SSITHMetadataFnRange\n");
  
  //Make MCExpr for the fixups -- Inspired by LowerSymbolOperand in RISCVMCInstLower.cpp
  MCContext &Ctx = OutContext;
  RISCVMCExpr::VariantKind Kind = RISCVMCExpr::VK_RISCV_None;
  const MCExpr *MEbegin = MCSymbolRefExpr::create(begin, MCSymbolRefExpr::VK_None, Ctx);
  const MCExpr *MEend = MCSymbolRefExpr::create(end, MCSymbolRefExpr::VK_None, Ctx);
  MEbegin = RISCVMCExpr::create(MEbegin, Kind, Ctx);
  MEend = RISCVMCExpr::create(MEend, Kind, Ctx);
  
  //Push fixup -- the linker will write the 4 byte address for us
  Fixups.push_back(
      MCFixup::create(0, MEbegin, MCFixupKind(FK_Data_4), SMLoc::getFromPointer(nullptr)));
  Fixups.push_back(
      MCFixup::create(0, MEend, MCFixupKind(FK_Data_4), SMLoc::getFromPointer(nullptr)));

  OutStreamer->EmitLabel(end);
  OutStreamer->EmitSSITHMetadataEntry(Fixups, DMD_FUNCTION_RANGE, 0);
}

void RISCVAsmPrinter::EmitInstruction(const MachineInstr *MI) {

  // Do any auto-generated pseudo lowerings.
  if (!emitPseudoExpansionLowering(*OutStreamer, MI)){
    MCInst TmpInst;
    LowerRISCVMachineInstrToMCInst(MI, TmpInst, *this);
    EmitToStreamer(*OutStreamer, TmpInst);
  }

  /* SSITH BEGIN */

  // fn range avoids NoCFI on C code stuff
  if(MI->isReturn()) 
    EmitSSITHMetadataFnRange(CurrentFnSym, OutContext.createTempSymbol());

  //SSITH - clean up in function epilog
  if(MI->getFlag(MachineInstr::FnEpilog) && MI->getOpcode() == RISCV::LW){
    //Emit the metadata 
    //    MCSymbol *CurPos = OutContext.createTempSymbol();
    //    OutStreamer->EmitLabel(CurPos);
    //    EmitSSITHMetadata(CurPos, DMT_STACK_EPILOGUE_AUTHORITY);
    //    MI->setISPMetadataTag(DMT_STACK_EPILOGUE_AUTHORITY);
    
    //Emit our new store
    MCInst SSITHStore;
    LowerToSSITHEpilogStore(MI, SSITHStore, *this);
    EmitToStreamer(*OutStreamer, SSITHStore);
  }
  
}

bool RISCVAsmPrinter::PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                                      const char *ExtraCode, raw_ostream &OS) {
  // First try the generic code, which knows about modifiers like 'c' and 'n'.
  if (!AsmPrinter::PrintAsmOperand(MI, OpNo, ExtraCode, OS))
    return false;

  if (!ExtraCode) {
    const MachineOperand &MO = MI->getOperand(OpNo);
    switch (MO.getType()) {
    case MachineOperand::MO_Immediate:
      OS << MO.getImm();
      return false;
    case MachineOperand::MO_Register:
      OS << RISCVInstPrinter::getRegisterName(MO.getReg());
      return false;
    default:
      break;
    }
  }

  return true;
}

bool RISCVAsmPrinter::PrintAsmMemoryOperand(const MachineInstr *MI,
                                            unsigned OpNo,
                                            const char *ExtraCode,
                                            raw_ostream &OS) {
  if (!ExtraCode) {
    const MachineOperand &MO = MI->getOperand(OpNo);
    // For now, we only support register memory operands in registers and
    // assume there is no addend
    if (!MO.isReg())
      return true;

    OS << "0(" << RISCVInstPrinter::getRegisterName(MO.getReg()) << ")";
    return false;
  }

  return AsmPrinter::PrintAsmMemoryOperand(MI, OpNo, ExtraCode, OS);
}

// Force static initialization.
extern "C" void LLVMInitializeRISCVAsmPrinter() {
  RegisterAsmPrinter<RISCVAsmPrinter> X(getTheRISCV32Target());
  RegisterAsmPrinter<RISCVAsmPrinter> Y(getTheRISCV64Target());
}
