//===-- RISCVMCInstLower.cpp - Convert RISCV MachineInstr to an MCInst ------=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains code to lower RISCV MachineInstrs to their corresponding
// MCInst records.
//
//===----------------------------------------------------------------------===//

#include "RISCV.h"
#include "MCTargetDesc/RISCVMCExpr.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCExpr.h"
#include "llvm/MC/MCInst.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/raw_ostream.h"

#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCContext.h"


using namespace llvm;

static MCOperand lowerSymbolOperand(const MachineOperand &MO, MCSymbol *Sym,
                                    const AsmPrinter &AP) {
  MCContext &Ctx = AP.OutContext;
  RISCVMCExpr::VariantKind Kind;

  switch (MO.getTargetFlags()) {
  default:
    llvm_unreachable("Unknown target flag on GV operand");
  case RISCVII::MO_None:
    Kind = RISCVMCExpr::VK_RISCV_None;
    break;
  case RISCVII::MO_CALL:
    Kind = RISCVMCExpr::VK_RISCV_CALL;
    break;
  case RISCVII::MO_LO:
    Kind = RISCVMCExpr::VK_RISCV_LO;
    break;
  case RISCVII::MO_HI:
    Kind = RISCVMCExpr::VK_RISCV_HI;
    break;
  case RISCVII::MO_PCREL_LO:
    Kind = RISCVMCExpr::VK_RISCV_PCREL_LO;
    break;
  case RISCVII::MO_PCREL_HI:
    Kind = RISCVMCExpr::VK_RISCV_PCREL_HI;
    break;
  }

  const MCExpr *ME =
      MCSymbolRefExpr::create(Sym, MCSymbolRefExpr::VK_None, Ctx);

  if (!MO.isJTI() && !MO.isMBB() && MO.getOffset())
    ME = MCBinaryExpr::createAdd(
        ME, MCConstantExpr::create(MO.getOffset(), Ctx), Ctx);

  if (Kind != RISCVMCExpr::VK_RISCV_None)
    ME = RISCVMCExpr::create(ME, Kind, Ctx);
  return MCOperand::createExpr(ME);
}

bool llvm::LowerRISCVMachineOperandToMCOperand(const MachineOperand &MO,
                                               MCOperand &MCOp,
                                               const AsmPrinter &AP) {
  switch (MO.getType()) {
  default:
    report_fatal_error("LowerRISCVMachineInstrToMCInst: unknown operand type");
  case MachineOperand::MO_Register:
    // Ignore all implicit register operands.
    if (MO.isImplicit())
      return false;
    MCOp = MCOperand::createReg(MO.getReg());
    break;
  case MachineOperand::MO_RegisterMask:
    // Regmasks are like implicit defs.
    return false;
  case MachineOperand::MO_Immediate:
    MCOp = MCOperand::createImm(MO.getImm());
    break;
  case MachineOperand::MO_MachineBasicBlock:
    MCOp = lowerSymbolOperand(MO, MO.getMBB()->getSymbol(), AP);
    break;
  case MachineOperand::MO_GlobalAddress:
    MCOp = lowerSymbolOperand(MO, AP.getSymbol(MO.getGlobal()), AP);
    break;
  case MachineOperand::MO_BlockAddress:
    MCOp = lowerSymbolOperand(
        MO, AP.GetBlockAddressSymbol(MO.getBlockAddress()), AP);
    break;
  case MachineOperand::MO_ExternalSymbol:
    MCOp = lowerSymbolOperand(
        MO, AP.GetExternalSymbolSymbol(MO.getSymbolName()), AP);
    break;
  case MachineOperand::MO_ConstantPoolIndex:
    MCOp = lowerSymbolOperand(MO, AP.GetCPISymbol(MO.getIndex()), AP);
    break;
  }
  return true;
}

void llvm::LowerRISCVMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI,
                                          AsmPrinter &AP) {
  OutMI.setOpcode(MI->getOpcode());

  for (const MachineOperand &MO : MI->operands()) {
    MCOperand MCOp;
    if (LowerRISCVMachineOperandToMCOperand(MO, MCOp, AP))
      OutMI.addOperand(MCOp);
  }

  // BEGIN SSITH

  /* SSITH BEGIN */
  MCSymbol *InstSym;
  InstSym  = nullptr;

  const std::unique_ptr<MCStreamer> &OutStreamer = AP.OutStreamer;
  MCContext &OutContext = AP.OutContext;
  
  if(MI->getFlag(MachineInstr::FnProlog)) {
    OutMI.setISPMetadataTag(DMT_STACK_PROLOGUE_AUTHORITY);
    //    AP.EmitSSITHMetadata(InstSym, DMT_STACK_PROLOGUE_AUTHORITY);
  }
  else if(MI->getFlag(MachineInstr::FnEpilog)){
    OutMI.setISPMetadataTag(DMT_STACK_EPILOGUE_AUTHORITY);
    //    AP.EmitSSITHMetadata(InstSym, DMT_STACK_EPILOGUE_AUTHORITY);
  }
  else if(MI->getFlag(MachineInstr::FPtrStore)){
    OutMI.setISPMetadataTag(DMT_FPTR_STORE_AUTHORITY);
    //    AP.EmitSSITHMetadata(InstSym, DMT_FPTR_STORE_AUTHORITY);
  }
  else if(MI->getFlag(MachineInstr::FPtrCreate)){
    //MI->dump();
    //errs() << "create\n--------------------\n";
    OutMI.setISPMetadataTag(DMT_FPTR_CREATE_AUTHORITY);
    //    AP.EmitSSITHMetadata(InstSym, DMT_FPTR_CREATE_AUTHORITY);
  }

  if ( MI->getFlag(MachineInstr::CallTarget) ) {
    OutMI.setISPMetadataTag(DMT_CFI3L_VALID_TGT);
  }

  if ( MI->getFlag(MachineInstr::ReturnTarget) ) 
    OutMI.setISPMetadataTag(DMT_RET_VALID_TGT);

  if ( MI->getFlag(MachineInstr::BranchTarget) )
    OutMI.setISPMetadataTag(DMT_BRANCH_VALID_TGT);    

  //return instructions aren't tagged epilog for whatever reason
  if(MI->isReturn()){

    printf("found a return instruction!\n");
    
    OutMI.setISPMetadataTag(DMT_STACK_EPILOGUE_AUTHORITY);
    OutMI.setISPMetadataTag(DMT_RETURN_INSTR);

    //NOTE -- Tail Calls get labelled as both return and call, we consider them calls
    //    AP.EmitSSITHMetadata(InstSym, DMT_STACK_EPILOGUE_AUTHORITY);
    //    AP.EmitSSITHMetadata(InstSym, DMT_RETURN_INSTR);
  }
  //Tag call instructions for 3 class CFI policy
  if(MI->isCall()) {
    printf("outputting call instruction!\n");
    OutMI.setISPMetadataTag(DMT_CALL_INSTR);
    //    AP.EmitSSITHMetadata(InstSym, DMT_CALL_INSTR);
  }
  //Tag branch instruction for 3 class CFI policy
  else if(MI->isBranch()) {
    OutMI.setISPMetadataTag(DMT_BRANCH_INSTR);
    //    AP.EmitSSITHMetadata(InstSym, DMT_BRANCH_INSTR);
  }

}

void llvm::LowerToSSITHEpilogStore(const MachineInstr *MI, MCInst &OutMI,
                                          const AsmPrinter &AP) {
  OutMI.setOpcode(RISCV::SW);

  bool first = true;
  for (const MachineOperand &MO : MI->operands()) {
    MCOperand MCOp;
    if(first){
      OutMI.addOperand(MCOperand::createReg(RISCV::X0));
      first = false;
    }
    else if (LowerRISCVMachineOperandToMCOperand(MO, MCOp, AP))
      OutMI.addOperand(MCOp);
  }
}
