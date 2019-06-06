//===-- RISCVExpandPseudoInsts.cpp - Expand pseudo instructions -----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains a pass that expands pseudo instructions into target
// instructions. This pass should be run after register allocation but before
// the post-regalloc scheduling pass.
//
//===----------------------------------------------------------------------===//

#include "RISCV.h"

#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"

using namespace llvm;

#define RISCV_ISP_METADATA_NAME "RISCV ISP Metadata calculation pass"

namespace {

class RISCVISPMetadata : public MachineFunctionPass {
public:
  static char ID;

  RISCVISPMetadata() : MachineFunctionPass(ID) {
    initializeRISCVISPMetadataPass(*PassRegistry::getPassRegistry());
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

  StringRef getPassName() const override { return RISCV_ISP_METADATA_NAME; }
};

char RISCVISPMetadata::ID = 1;

bool RISCVISPMetadata::runOnMachineFunction(MachineFunction &MF) {

  for (auto &MBB : MF) {

    MBB.getSymbol()->setISPMetadataTag(&MBB == &*MF.begin() ?
				       DMT_CFI3L_VALID_TGT :
				       DMT_BRANCH_VALID_TGT);
    
    // check first instruction
    auto MI = MBB.getFirstNonDebugInstr();
    for(auto &pred : MBB.predecessors()){
      const auto &last = pred->getLastNonDebugInstr();
      if(last != pred->end()) {
	if(last->isCall()) {
	  MI->setFlag(MachineInstr::ReturnTarget);
	}
	if(last->isBranch())
	  MI->setFlag(MachineInstr::BranchTarget);
      }
    }

    // check all other instructions
    for( auto MI = std::next(MBB.instr_begin()); MI != MBB.instr_end(); MI++ ) {

      //The zero size instructions from RISCVInstrInfo.cpp - getInstSizeInBytes
      //wasn't obvious how to call it, so here's this unmaintable approach
      switch(MI->getOpcode()){
        case TargetOpcode::EH_LABEL:
        case TargetOpcode::IMPLICIT_DEF:
        case TargetOpcode::KILL:
        case TargetOpcode::DBG_VALUE:
	  continue;
        default:  //do nothing
          break;  //breaks the switch not the loop
      }

      // todo: prev may be one of these weird zero size instructions
      if(std::prev(MI)->isCall())
	MI->setFlag(MachineInstr::ReturnTarget);

      if(std::prev(MI)->isBranch())
	MI->setFlag(MachineInstr::BranchTarget);
    }
  }

  return false;
}

} // end of anonymous namespace

INITIALIZE_PASS(RISCVISPMetadata, "riscv-isp-metadata",
                RISCV_ISP_METADATA_NAME, false, false)
namespace llvm {

FunctionPass *createRISCVISPMetadataPass() { return new RISCVISPMetadata(); }

} // end of namespace llvm
