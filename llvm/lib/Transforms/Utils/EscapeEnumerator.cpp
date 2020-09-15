//===- EscapeEnumerator.cpp -----------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Defines a helper class that enumerates all possible exits from a function,
// including exception handling.
//
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Utils/EscapeEnumerator.h"
#include "llvm/ADT/Triple.h"
#include "llvm/Analysis/EHPersonalities.h"
#include "llvm/IR/Module.h"
#include "llvm/Transforms/Utils/Local.h"

using namespace llvm;

static FunctionCallee getDefaultPersonalityFn(Module *M) {
  LLVMContext &C = M->getContext();
  Triple T(M->getTargetTriple());
  EHPersonality Pers = getDefaultEHPersonality(T);
  return M->getOrInsertFunction(getEHPersonalityName(Pers),
                                FunctionType::get(Type::getInt32Ty(C), true));
}

IRBuilder<> *EscapeEnumerator::Next() {
  if (Done)
    return nullptr;

  // Find all 'return', 'resume', and 'unwind' instructions.
  while (StateBB != StateE) {
    BasicBlock *CurBB = &*StateBB++;

    // Branches and invokes do not escape, only unwind, resume, and return
    // do.
    Instruction *TI = CurBB->getTerminator();
    if (!isa<ReturnInst>(TI) && !isa<ResumeInst>(TI))
      continue;

    // If the ret instruction is followed by a musttaill call,
    // or a bitcast instruction and then a musttail call, we should return
    // the musttail call as the insertion point to not break the musttail
    // contract.
    auto AdjustMustTailCall = [&](Instruction *I) -> Instruction * {
      auto *RI = dyn_cast<ReturnInst>(I);
      if (!RI || !RI->getPrevNode())
        return I;
      auto *CI = dyn_cast<CallInst>(RI->getPrevNode());
      if (CI && CI->isMustTailCall())
        return CI;
      auto *BI = dyn_cast<BitCastInst>(RI->getPrevNode());
      if (!BI || !BI->getPrevNode())
        return I;
      CI = dyn_cast<CallInst>(BI->getPrevNode());
      if (CI && CI->isMustTailCall())
        return CI;
      return I;
    };

    Builder.SetInsertPoint(AdjustMustTailCall(TI));
    return &Builder;
  }

  Done = true;

  if (!HandleExceptions)
    return nullptr;

  if (F.doesNotThrow())
    return nullptr;

  // Find all 'call' instructions that may throw.
  // We cannot tranform calls with musttail tag.
  SmallVector<Instruction *, 16> Calls;
  for (BasicBlock &BB : F)
    for (Instruction &II : BB)
      if (CallInst *CI = dyn_cast<CallInst>(&II))
        if (!CI->doesNotThrow() && !CI->isMustTailCall())
          Calls.push_back(CI);

  if (Calls.empty())
    return nullptr;

  // Create a cleanup block.
  LLVMContext &C = F.getContext();
  BasicBlock *CleanupBB = BasicBlock::Create(C, CleanupBBName, &F);
  Type *ExnTy = StructType::get(Type::getInt8PtrTy(C), Type::getInt32Ty(C));
  if (!F.hasPersonalityFn()) {
    FunctionCallee PersFn = getDefaultPersonalityFn(F.getParent());
    F.setPersonalityFn(cast<Constant>(PersFn.getCallee()));
  }

  if (isScopedEHPersonality(classifyEHPersonality(F.getPersonalityFn()))) {
    report_fatal_error("Scoped EH not supported");
  }

  LandingPadInst *LPad =
      LandingPadInst::Create(ExnTy, 1, "cleanup.lpad", CleanupBB);
  LPad->setCleanup(true);
  ResumeInst *RI = ResumeInst::Create(LPad, CleanupBB);

  // Transform the 'call' instructions into 'invoke's branching to the
  // cleanup block. Go in reverse order to make prettier BB names.
  SmallVector<Value *, 16> Args;
  for (unsigned I = Calls.size(); I != 0;) {
    CallInst *CI = cast<CallInst>(Calls[--I]);
    changeToInvokeAndSplitBasicBlock(CI, CleanupBB);
  }

  Builder.SetInsertPoint(RI);
  return &Builder;
}
