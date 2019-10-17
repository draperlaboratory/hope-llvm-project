//===-- ISPMetadataPass.cpp - Calculate metadata for ISP ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains a pass that identifies and adds metadata to certain
//   instructions
//
//===----------------------------------------------------------------------===//

#include "RISCV.h"
#include "ISP.h"

#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineInstr.h"

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

static void setMIFlags(MachineInstr *MI) {

  if ( MI->isReturn() && !MI->isCall() ) {
    MI->setFlag(MachineInstr::IsReturn);
    MI->setFlag(MachineInstr::FnEpilog);
  }
  else if ( MI->isCall() )
    MI->setFlags(MachineInstr::IsCall);
  else if ( MI->isBranch() )
    MI->setFlags(MachineInstr::IsBranch);
  
}
  
bool RISCVISPMetadata::runOnMachineFunction(MachineFunction &MF) {

    for (auto &MBB : MF) {

        // check first instruction
        auto MI = MBB.getFirstNonDebugInstr();
        if ( MI == MBB.end() )
            continue;

        MBB.getSymbol()->modifyFlags((&MBB == &*MF.begin() ?
                    MachineInstr::CallTarget :
                    MachineInstr::BranchTarget),
                0);

        setMIFlags(&*MI);

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

        auto last = MI;
        for( auto MI = std::next(MBB.instr_begin()); MI != MBB.instr_end(); MI++ ) {

            setMIFlags(&*MI);

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

            if(last->isCall())
                MI->setFlag(MachineInstr::ReturnTarget);

            if(last->isBranch())
                MI->setFlag(MachineInstr::BranchTarget);

            last = MI;
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
