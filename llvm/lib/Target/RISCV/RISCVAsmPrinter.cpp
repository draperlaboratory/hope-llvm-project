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
#include "MCTargetDesc/RISCVInstPrinter.h"
#include "MCTargetDesc/RISCVMCExpr.h"
#include "RISCVTargetMachine.h"
#include "TargetInfo/RISCVTargetInfo.h"
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
#include "llvm/MC/SSITHMetadata.h"
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
  void EmitSSITHMetadataInst(MCSymbol *Sym, const MCSubtargetInfo &STI, uint8_t tag) override;
  void EmitSSITHMetadataFnRange(MCSymbol *begin, MCSymbol *end, 
       const MCSubtargetInfo &STI) override;
  
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
void RISCVAsmPrinter::EmitSSITHMetadataFnRange(MCSymbol *begin, MCSymbol *end,
    const MCSubtargetInfo &STI){
  
  SmallVector<MCFixup, 4> Fixups;

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

  OutStreamer->EmitSSITHMetadataEntry(Fixups, STI, DMD_FUNCTION_RANGE, 0);
}

//SSITH
void RISCVAsmPrinter::EmitSSITHMetadataInst(MCSymbol *Sym, const MCSubtargetInfo &STI,
                                            uint8_t tag){
  SmallVector<MCFixup, 4> Fixups;

  //Make MCExpr for the fixups -- Inspired by LowerSymbolOperand in RISCVMCInstLower.cpp
  MCContext &Ctx = OutContext;
  RISCVMCExpr::VariantKind Kind = RISCVMCExpr::VK_RISCV_None;
  const MCExpr *ME = MCSymbolRefExpr::create(Sym, MCSymbolRefExpr::VK_None, Ctx);
  ME = RISCVMCExpr::create(ME, Kind, Ctx);
  
  //Push fixup -- the linker will write the 4 byte address for us
  Fixups.push_back(
      MCFixup::create(0, ME, MCFixupKind(FK_Data_4), SMLoc::getFromPointer(nullptr)));

  OutStreamer->EmitSSITHMetadataEntry(Fixups, STI, DMD_TAG_ADDRESS_OP, tag);
}

void RISCVAsmPrinter::EmitInstruction(const MachineInstr *MI) {
  /* SSITH BEGIN */
  MCSymbol *InstSym, *PriorInstSym;
  InstSym = PriorInstSym = nullptr;

  // Do any auto-generated pseudo lowerings.
  if (!emitPseudoExpansionLowering(*OutStreamer, MI)){
    MCInst TmpInst;
    LowerRISCVMachineInstrToMCInst(MI, TmpInst, *this);
    EmitToStreamer(*OutStreamer, TmpInst);
  }
    
  char *tmp = OutStreamer->SSITHpopLastInstruction(4);
  InstSym = OutContext.createTempSymbol();
  OutStreamer->EmitLabel(InstSym);
  //These get expanded to 2 instructions -- can you believe it! They aren't butter! 
  //they are whatever the fake butter product in those ads was called ...
  if(MI->getOpcode() == RISCV::PseudoTAIL ||
      MI->getOpcode() == RISCV::PseudoCALL){
    char *tmp2 = OutStreamer->SSITHpopLastInstruction(4);
    PriorInstSym = OutContext.createTempSymbol();
    OutStreamer->EmitLabel(PriorInstSym);
    OutStreamer->SSITHpushInstruction(tmp2, 4);
  }
  OutStreamer->SSITHpushInstruction(tmp, 4);

  //Get the new section
  MCContext &Context = getObjFileLowering().getContext();
  MCSectionELF *ISP = Context.getELFSection(".dover_metadata", ELF::SHT_PROGBITS, 0);
  
  bool retTarget = false;
  bool branchFallThrough = false;

  const MachineBasicBlock *MBB = MI->getParent();
  if(MI == MBB->getFirstNonDebugInstr()){
    for(auto &pred : MBB->predecessors()){
      const auto &last = pred->getLastNonDebugInstr();
      if(last != pred->end()) {
        if(last->isCall())
            retTarget = true;
        if(last->isBranch())
            branchFallThrough = true;
      }
    }
  }
  else{
    for(auto &MI2 : *(MBB)){
      if(&MI2 == MI) 
        break;
  
      //The zero size instructions from RISCVInstrInfo.cpp - getInstSizeInBytes
      //wasn't obvious how to call it, so here's this unmaintable approach
      switch(MI2.getOpcode()){
        case TargetOpcode::EH_LABEL:
        case TargetOpcode::IMPLICIT_DEF:
        case TargetOpcode::KILL:
        case TargetOpcode::DBG_VALUE:
          continue;
        default:  //do nothing
          break;  //breaks the switch not the loop
      }

      if(MI2.isCall())
        retTarget = true;
      else
        retTarget = false;

      if(MI2.isBranch())
        branchFallThrough = true;
      else
        branchFallThrough = false;
    }
  }

  //Swith to new section for ssith metadata
  OutStreamer->PushSection();
  OutStreamer->SwitchSection(ISP);
  if(MI->getFlag(MachineInstr::FnProlog))
    EmitSSITHMetadataInst(InstSym, getSubtargetInfo(), DMT_STACK_PROLOGUE_AUTHORITY);
  else if(MI->getFlag(MachineInstr::FnEpilog)){
    EmitSSITHMetadataInst(InstSym, getSubtargetInfo(), DMT_STACK_EPILOGUE_AUTHORITY);
  }
  else if(MI->getFlag(MachineInstr::FPtrStore)){
    //MI->dump();
    //errs() << "store\n--------------------\n";
    EmitSSITHMetadataInst(InstSym, getSubtargetInfo(), DMT_FPTR_STORE_AUTHORITY);
  }
  else if(MI->getFlag(MachineInstr::FPtrCreate)){
    //MI->dump();
    //errs() << "create\n--------------------\n";
    EmitSSITHMetadataInst(InstSym, getSubtargetInfo(), DMT_FPTR_CREATE_AUTHORITY);
  }
  //return instructions aren't tagged epilog for whatever reason
  else if(MI->isReturn() && !MI->isCall()){
    //NOTE -- Tail Calls get labelled as both return and call, we consider them calls
    EmitSSITHMetadataInst(InstSym, getSubtargetInfo(), DMT_STACK_EPILOGUE_AUTHORITY);
    EmitSSITHMetadataInst(InstSym, getSubtargetInfo(), DMT_RETURN_INSTR);
  }
  //Tag call instructions for 3 class CFI policy
  else if(MI->isCall())
    EmitSSITHMetadataInst(InstSym, getSubtargetInfo(), DMT_CALL_INSTR);
  //Tag branch instruction for 3 class CFI policy
  else if(MI->isBranch())
    EmitSSITHMetadataInst(InstSym, getSubtargetInfo(), DMT_BRANCH_INSTR);
 
  //whether its a tail call or a return (handled separately above) do this
  if(MI->isReturn())
    EmitSSITHMetadataFnRange(CurrentFnSym, InstSym, getSubtargetInfo());

  //Targets can also be other things, need a separate if check
  if(retTarget){
    MCSymbol *Tgt = PriorInstSym ? PriorInstSym : InstSym;
    EmitSSITHMetadataInst(Tgt, getSubtargetInfo(), DMT_RET_VALID_TGT);
  }
  else if(branchFallThrough){
    MCSymbol *Tgt = PriorInstSym ? PriorInstSym : InstSym;
    EmitSSITHMetadataInst(Tgt, getSubtargetInfo(), DMT_BRANCH_VALID_TGT);
  }
  //Restore the previous section
  OutStreamer->PopSection();

  //SSITH - clean up in function epilog
  if(MI->getFlag(MachineInstr::FnEpilog) && MI->getOpcode() == RISCV::LW){
    //Emit the metadata 
    MCSymbol *CurPos = OutContext.createTempSymbol();
    OutStreamer->EmitLabel(CurPos);
    OutStreamer->PushSection();
    OutStreamer->SwitchSection(ISP);
    EmitSSITHMetadataInst(CurPos, getSubtargetInfo(), DMT_STACK_EPILOGUE_AUTHORITY);
    OutStreamer->PopSection();

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

  const MachineOperand &MO = MI->getOperand(OpNo);
  if (ExtraCode && ExtraCode[0]) {
    if (ExtraCode[1] != 0)
      return true; // Unknown modifier.

    switch (ExtraCode[0]) {
    default:
      return true; // Unknown modifier.
    case 'z':      // Print zero register if zero, regular printing otherwise.
      if (MO.isImm() && MO.getImm() == 0) {
        OS << RISCVInstPrinter::getRegisterName(RISCV::X0);
        return false;
      }
      break;
    case 'i': // Literal 'i' if operand is not a register.
      if (!MO.isReg())
        OS << 'i';
      return false;
    }
  }

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
