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

static void MoveMetadataMachineInstrToMCInst(const MachineInstr *MI, MCInst &MC) {

  /* SSITH BEGIN */
  if(MI->getFlag(MachineInstr::FnProlog))
    MC.setISPMetadataTag(DMT_STACK_PROLOGUE_AUTHORITY);
  else if(MI->getFlag(MachineInstr::FnEpilog))
    MC.setISPMetadataTag(DMT_STACK_EPILOGUE_AUTHORITY);

  // CPI Tagging 
  if(MI->getFlag(MachineInstr::FPtrStore))
    MC.setISPMetadataTag(DMT_FPTR_STORE_AUTHORITY);
  else if(MI->getFlag(MachineInstr::FPtrCreate))
    MC.setISPMetadataTag(DMT_FPTR_CREATE_AUTHORITY);

  // threeClass tagging
  if ( MI->getFlag(MachineInstr::CallTarget) )
    MC.setISPMetadataTag(DMT_CFI3L_VALID_TGT);

  if ( MI->getFlag(MachineInstr::ReturnTarget) )
    MC.setISPMetadataTag(DMT_RET_VALID_TGT);

  if ( MI->getFlag(MachineInstr::BranchTarget) )
    MC.setISPMetadataTag(DMT_BRANCH_VALID_TGT);

  if(MI->isReturn() && !MI->isCall()){
    //return instructions aren't tagged epilog for whatever reason
    //NOTE -- Tail Calls get labelled as both return and call, we consider them calls
    MC.setISPMetadataTag(DMT_STACK_EPILOGUE_AUTHORITY);
    MC.setISPMetadataTag(DMT_RETURN_INSTR);
    //    MC.setISPSym((void*)&AP.CurrentFnSym);
  }
  else if(MI->isCall())
    MC.setISPMetadataTag(DMT_CALL_INSTR);
  else if(MI->isBranch()) 
    MC.setISPMetadataTag(DMT_BRANCH_INSTR);
}

void llvm::LowerRISCVMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI,
                                          AsmPrinter &AP) {
  OutMI.setOpcode(MI->getOpcode());

  for (const MachineOperand &MO : MI->operands()) {
    MCOperand MCOp;
    if (LowerRISCVMachineOperandToMCOperand(MO, MCOp, AP))
      OutMI.addOperand(MCOp);
  }

  MoveMetadataMachineInstrToMCInst(MI, OutMI);
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

  MoveMetadataMachineInstrToMCInst(MI, OutMI);
}
