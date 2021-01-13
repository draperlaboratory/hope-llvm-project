//===- InlineAdvisor.cpp - analysis pass implementation -------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements InlineAdvisorAnalysis and DefaultInlineAdvisor, and
// related types.
//
//===----------------------------------------------------------------------===//

#include "llvm/Analysis/InlineAdvisor.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/Analysis/InlineCost.h"
#include "llvm/Analysis/OptimizationRemarkEmitter.h"
#include "llvm/Analysis/ProfileSummaryInfo.h"
#include "llvm/Analysis/TargetLibraryInfo.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/IR/DebugInfoMetadata.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/raw_ostream.h"

#include <sstream>

using namespace llvm;
#define DEBUG_TYPE "inline"

// This weirdly named statistic tracks the number of times that, when attempting
// to inline a function A into B, we analyze the callers of B in order to see
// if those would be more profitable and blocked inline steps.
STATISTIC(NumCallerCallersAnalyzed, "Number of caller-callers analyzed");

/// Flag to add inline messages as callsite attributes 'inline-remark'.
static cl::opt<bool>
    InlineRemarkAttribute("inline-remark-attribute", cl::init(false),
                          cl::Hidden,
                          cl::desc("Enable adding inline-remark attribute to"
                                   " callsites processed by inliner but decided"
                                   " to be not inlined"));

// An integer used to limit the cost of inline deferral.  The default negative
// number tells shouldBeDeferred to only take the secondary cost into account.
static cl::opt<int>
    InlineDeferralScale("inline-deferral-scale",
                        cl::desc("Scale to limit the cost of inline deferral"),
                        cl::init(2), cl::Hidden);

void DefaultInlineAdvice::recordUnsuccessfulInliningImpl(
    const InlineResult &Result) {
  using namespace ore;
  llvm::setInlineRemark(*OriginalCB, std::string(Result.getFailureReason()) +
                                         "; " + inlineCostStr(*OIC));
  ORE.emit([&]() {
    return OptimizationRemarkMissed(DEBUG_TYPE, "NotInlined", DLoc, Block)
           << NV("Callee", Callee) << " will not be inlined into "
           << NV("Caller", Caller) << ": "
           << NV("Reason", Result.getFailureReason());
  });
}

void DefaultInlineAdvice::recordInliningWithCalleeDeletedImpl() {
  if (EmitRemarks)
    emitInlinedInto(ORE, DLoc, Block, *Callee, *Caller, *OIC);
}

void DefaultInlineAdvice::recordInliningImpl() {
  if (EmitRemarks)
    emitInlinedInto(ORE, DLoc, Block, *Callee, *Caller, *OIC);
}

llvm::Optional<llvm::InlineCost> static getDefaultInlineAdvice(
    CallBase &CB, FunctionAnalysisManager &FAM, const InlineParams &Params) {
  Function &Caller = *CB.getCaller();
  ProfileSummaryInfo *PSI =
      FAM.getResult<ModuleAnalysisManagerFunctionProxy>(Caller)
          .getCachedResult<ProfileSummaryAnalysis>(
              *CB.getParent()->getParent()->getParent());

  auto &ORE = FAM.getResult<OptimizationRemarkEmitterAnalysis>(Caller);
  auto GetAssumptionCache = [&](Function &F) -> AssumptionCache & {
    return FAM.getResult<AssumptionAnalysis>(F);
  };
  auto GetBFI = [&](Function &F) -> BlockFrequencyInfo & {
    return FAM.getResult<BlockFrequencyAnalysis>(F);
  };
  auto GetTLI = [&](Function &F) -> const TargetLibraryInfo & {
    return FAM.getResult<TargetLibraryAnalysis>(F);
  };

  auto GetInlineCost = [&](CallBase &CB) {
    Function &Callee = *CB.getCalledFunction();
    auto &CalleeTTI = FAM.getResult<TargetIRAnalysis>(Callee);
    bool RemarksEnabled =
        Callee.getContext().getDiagHandlerPtr()->isMissedOptRemarkEnabled(
            DEBUG_TYPE);
    return getInlineCost(CB, Params, CalleeTTI, GetAssumptionCache, GetTLI,
                         GetBFI, PSI, RemarksEnabled ? &ORE : nullptr);
  };
  return llvm::shouldInline(CB, GetInlineCost, ORE,
                            Params.EnableDeferral.getValueOr(false));
}

std::unique_ptr<InlineAdvice> DefaultInlineAdvisor::getAdvice(CallBase &CB) {
  auto OIC = getDefaultInlineAdvice(CB, FAM, Params);
  return std::make_unique<DefaultInlineAdvice>(
      this, CB, OIC,
      FAM.getResult<OptimizationRemarkEmitterAnalysis>(*CB.getCaller()));
}

InlineAdvice::InlineAdvice(InlineAdvisor *Advisor, CallBase &CB,
                           OptimizationRemarkEmitter &ORE,
                           bool IsInliningRecommended)
    : Advisor(Advisor), Caller(CB.getCaller()), Callee(CB.getCalledFunction()),
      DLoc(CB.getDebugLoc()), Block(CB.getParent()), ORE(ORE),
      IsInliningRecommended(IsInliningRecommended) {}

void InlineAdvisor::markFunctionAsDeleted(Function *F) {
  assert((!DeletedFunctions.count(F)) &&
         "Cannot put cause a function to become dead twice!");
  DeletedFunctions.insert(F);
}

void InlineAdvisor::freeDeletedFunctions() {
  for (auto *F : DeletedFunctions)
    delete F;
  DeletedFunctions.clear();
}

void InlineAdvice::recordInliningWithCalleeDeleted() {
  markRecorded();
  Advisor->markFunctionAsDeleted(Callee);
  recordInliningWithCalleeDeletedImpl();
}

AnalysisKey InlineAdvisorAnalysis::Key;

bool InlineAdvisorAnalysis::Result::tryCreate(InlineParams Params,
                                              InliningAdvisorMode Mode) {
  auto &FAM = MAM.getResult<FunctionAnalysisManagerModuleProxy>(M).getManager();
  switch (Mode) {
  case InliningAdvisorMode::Default:
    Advisor.reset(new DefaultInlineAdvisor(FAM, Params));
    break;
  case InliningAdvisorMode::MandatoryOnly:
    Advisor.reset(new MandatoryInlineAdvisor(FAM));
    break;
  case InliningAdvisorMode::Development:
#ifdef LLVM_HAVE_TF_API
    Advisor =
        llvm::getDevelopmentModeAdvisor(M, MAM, [&FAM, Params](CallBase &CB) {
          auto OIC = getDefaultInlineAdvice(CB, FAM, Params);
          return OIC.hasValue();
        });
#endif
    break;
  case InliningAdvisorMode::Release:
#ifdef LLVM_HAVE_TF_AOT
    Advisor = llvm::getReleaseModeAdvisor(M, MAM);
#endif
    break;
  }
  return !!Advisor;
}

/// Return true if inlining of CB can block the caller from being
/// inlined which is proved to be more beneficial. \p IC is the
/// estimated inline cost associated with callsite \p CB.
/// \p TotalSecondaryCost will be set to the estimated cost of inlining the
/// caller if \p CB is suppressed for inlining.
static bool
shouldBeDeferred(Function *Caller, InlineCost IC, int &TotalSecondaryCost,
                 function_ref<InlineCost(CallBase &CB)> GetInlineCost) {
  // For now we only handle local or inline functions.
  if (!Caller->hasLocalLinkage() && !Caller->hasLinkOnceODRLinkage())
    return false;
  // If the cost of inlining CB is non-positive, it is not going to prevent the
  // caller from being inlined into its callers and hence we don't need to
  // defer.
  if (IC.getCost() <= 0)
    return false;
  // Try to detect the case where the current inlining candidate caller (call
  // it B) is a static or linkonce-ODR function and is an inlining candidate
  // elsewhere, and the current candidate callee (call it C) is large enough
  // that inlining it into B would make B too big to inline later. In these
  // circumstances it may be best not to inline C into B, but to inline B into
  // its callers.
  //
  // This only applies to static and linkonce-ODR functions because those are
  // expected to be available for inlining in the translation units where they
  // are used. Thus we will always have the opportunity to make local inlining
  // decisions. Importantly the linkonce-ODR linkage covers inline functions
  // and templates in C++.
  //
  // FIXME: All of this logic should be sunk into getInlineCost. It relies on
  // the internal implementation of the inline cost metrics rather than
  // treating them as truly abstract units etc.
  TotalSecondaryCost = 0;
  // The candidate cost to be imposed upon the current function.
  int CandidateCost = IC.getCost() - 1;
  // If the caller has local linkage and can be inlined to all its callers, we
  // can apply a huge negative bonus to TotalSecondaryCost.
  bool ApplyLastCallBonus = Caller->hasLocalLinkage() && !Caller->hasOneUse();
  // This bool tracks what happens if we DO inline C into B.
  bool InliningPreventsSomeOuterInline = false;
  unsigned NumCallerUsers = 0;
  for (User *U : Caller->users()) {
    CallBase *CS2 = dyn_cast<CallBase>(U);

    // If this isn't a call to Caller (it could be some other sort
    // of reference) skip it.  Such references will prevent the caller
    // from being removed.
    if (!CS2 || CS2->getCalledFunction() != Caller) {
      ApplyLastCallBonus = false;
      continue;
    }

    InlineCost IC2 = GetInlineCost(*CS2);
    ++NumCallerCallersAnalyzed;
    if (!IC2) {
      ApplyLastCallBonus = false;
      continue;
    }
    if (IC2.isAlways())
      continue;

    // See if inlining of the original callsite would erase the cost delta of
    // this callsite. We subtract off the penalty for the call instruction,
    // which we would be deleting.
    if (IC2.getCostDelta() <= CandidateCost) {
      InliningPreventsSomeOuterInline = true;
      TotalSecondaryCost += IC2.getCost();
      NumCallerUsers++;
    }
  }

  if (!InliningPreventsSomeOuterInline)
    return false;

  // If all outer calls to Caller would get inlined, the cost for the last
  // one is set very low by getInlineCost, in anticipation that Caller will
  // be removed entirely.  We did not account for this above unless there
  // is only one caller of Caller.
  if (ApplyLastCallBonus)
    TotalSecondaryCost -= InlineConstants::LastCallToStaticBonus;

  // If InlineDeferralScale is negative, then ignore the cost of primary
  // inlining -- IC.getCost() multiplied by the number of callers to Caller.
  if (InlineDeferralScale < 0)
    return TotalSecondaryCost < IC.getCost();

  int TotalCost = TotalSecondaryCost + IC.getCost() * NumCallerUsers;
  int Allowance = IC.getCost() * InlineDeferralScale;
  return TotalCost < Allowance;
}

namespace llvm {
static std::basic_ostream<char> &operator<<(std::basic_ostream<char> &R,
                                            const ore::NV &Arg) {
  return R << Arg.Val;
}

template <class RemarkT>
RemarkT &operator<<(RemarkT &&R, const InlineCost &IC) {
  using namespace ore;
  if (IC.isAlways()) {
    R << "(cost=always)";
  } else if (IC.isNever()) {
    R << "(cost=never)";
  } else {
    R << "(cost=" << ore::NV("Cost", IC.getCost())
      << ", threshold=" << ore::NV("Threshold", IC.getThreshold()) << ")";
  }
  if (const char *Reason = IC.getReason())
    R << ": " << ore::NV("Reason", Reason);
  return R;
}
} // namespace llvm

std::string llvm::inlineCostStr(const InlineCost &IC) {
  std::stringstream Remark;
  Remark << IC;
  return Remark.str();
}

void llvm::setInlineRemark(CallBase &CB, StringRef Message) {
  if (!InlineRemarkAttribute)
    return;

  Attribute Attr = Attribute::get(CB.getContext(), "inline-remark", Message);
  CB.addAttribute(AttributeList::FunctionIndex, Attr);
}

/// Return the cost only if the inliner should attempt to inline at the given
/// CallSite. If we return the cost, we will emit an optimisation remark later
/// using that cost, so we won't do so from this function. Return None if
/// inlining should not be attempted.
Optional<InlineCost>
llvm::shouldInline(CallBase &CB,
                   function_ref<InlineCost(CallBase &CB)> GetInlineCost,
                   OptimizationRemarkEmitter &ORE, bool EnableDeferral) {
  using namespace ore;

  InlineCost IC = GetInlineCost(CB);
  Instruction *Call = &CB;
  Function *Callee = CB.getCalledFunction();
  Function *Caller = CB.getCaller();

  if (IC.isAlways()) {
    LLVM_DEBUG(dbgs() << "    Inlining " << inlineCostStr(IC)
                      << ", Call: " << CB << "\n");
    return IC;
  }

  if (!IC) {
    LLVM_DEBUG(dbgs() << "    NOT Inlining " << inlineCostStr(IC)
                      << ", Call: " << CB << "\n");
    if (IC.isNever()) {
      ORE.emit([&]() {
        return OptimizationRemarkMissed(DEBUG_TYPE, "NeverInline", Call)
               << NV("Callee", Callee) << " not inlined into "
               << NV("Caller", Caller) << " because it should never be inlined "
               << IC;
      });
    } else {
      ORE.emit([&]() {
        return OptimizationRemarkMissed(DEBUG_TYPE, "TooCostly", Call)
               << NV("Callee", Callee) << " not inlined into "
               << NV("Caller", Caller) << " because too costly to inline "
               << IC;
      });
    }
    setInlineRemark(CB, inlineCostStr(IC));
    return None;
  }

  int TotalSecondaryCost = 0;
  if (EnableDeferral &&
      shouldBeDeferred(Caller, IC, TotalSecondaryCost, GetInlineCost)) {
    LLVM_DEBUG(dbgs() << "    NOT Inlining: " << CB
                      << " Cost = " << IC.getCost()
                      << ", outer Cost = " << TotalSecondaryCost << '\n');
    ORE.emit([&]() {
      return OptimizationRemarkMissed(DEBUG_TYPE, "IncreaseCostInOtherContexts",
                                      Call)
             << "Not inlining. Cost of inlining " << NV("Callee", Callee)
             << " increases the cost of inlining " << NV("Caller", Caller)
             << " in other contexts";
    });
    setInlineRemark(CB, "deferred");
    // IC does not bool() to false, so get an InlineCost that will.
    // This will not be inspected to make an error message.
    return None;
  }

  LLVM_DEBUG(dbgs() << "    Inlining " << inlineCostStr(IC) << ", Call: " << CB
                    << '\n');
  return IC;
}

std::string llvm::getCallSiteLocation(DebugLoc DLoc) {
  std::ostringstream CallSiteLoc;
  bool First = true;
  for (DILocation *DIL = DLoc.get(); DIL; DIL = DIL->getInlinedAt()) {
    if (!First)
      CallSiteLoc << " @ ";
    // Note that negative line offset is actually possible, but we use
    // unsigned int to match line offset representation in remarks so
    // it's directly consumable by relay advisor.
    uint32_t Offset =
        DIL->getLine() - DIL->getScope()->getSubprogram()->getLine();
    uint32_t Discriminator = DIL->getBaseDiscriminator();
    StringRef Name = DIL->getScope()->getSubprogram()->getLinkageName();
    if (Name.empty())
      Name = DIL->getScope()->getSubprogram()->getName();
    CallSiteLoc << Name.str() << ":" << llvm::utostr(Offset) << ":"
                << llvm::utostr(DIL->getColumn());
    if (Discriminator)
      CallSiteLoc << "." << llvm::utostr(Discriminator);
    First = false;
  }

  return CallSiteLoc.str();
}

void llvm::addLocationToRemarks(OptimizationRemark &Remark, DebugLoc DLoc) {
  if (!DLoc.get()) {
    return;
  }

  bool First = true;
  Remark << " at callsite ";
  for (DILocation *DIL = DLoc.get(); DIL; DIL = DIL->getInlinedAt()) {
    if (!First)
      Remark << " @ ";
    unsigned int Offset = DIL->getLine();
    Offset -= DIL->getScope()->getSubprogram()->getLine();
    unsigned int Discriminator = DIL->getBaseDiscriminator();
    StringRef Name = DIL->getScope()->getSubprogram()->getLinkageName();
    if (Name.empty())
      Name = DIL->getScope()->getSubprogram()->getName();
    Remark << Name << ":" << ore::NV("Line", Offset) << ":"
           << ore::NV("Column", DIL->getColumn());
    if (Discriminator)
      Remark << "." << ore::NV("Disc", Discriminator);
    First = false;
  }

  Remark << ";";
}

void llvm::emitInlinedInto(OptimizationRemarkEmitter &ORE, DebugLoc DLoc,
                           const BasicBlock *Block, const Function &Callee,
                           const Function &Caller, const InlineCost &IC,
                           bool ForProfileContext, const char *PassName) {
  ORE.emit([&]() {
    bool AlwaysInline = IC.isAlways();
    StringRef RemarkName = AlwaysInline ? "AlwaysInline" : "Inlined";
    OptimizationRemark Remark(PassName ? PassName : DEBUG_TYPE, RemarkName,
                              DLoc, Block);
    Remark << ore::NV("Callee", &Callee) << " inlined into ";
    Remark << ore::NV("Caller", &Caller);
    if (ForProfileContext)
      Remark << " to match profiling context";
    Remark << " with " << IC;
    addLocationToRemarks(Remark, DLoc);
    return Remark;
  });
}

std::unique_ptr<InlineAdvice> MandatoryInlineAdvisor::getAdvice(CallBase &CB) {
  auto &Caller = *CB.getCaller();
  auto &Callee = *CB.getCalledFunction();
  auto &ORE = FAM.getResult<OptimizationRemarkEmitterAnalysis>(Caller);

  bool Advice = MandatoryInliningKind::Always ==
                    MandatoryInlineAdvisor::getMandatoryKind(CB, FAM, ORE) &&
                &Caller != &Callee;
  return std::make_unique<InlineAdvice>(this, CB, ORE, Advice);
}

MandatoryInlineAdvisor::MandatoryInliningKind
MandatoryInlineAdvisor::getMandatoryKind(CallBase &CB,
                                         FunctionAnalysisManager &FAM,
                                         OptimizationRemarkEmitter &ORE) {
  auto &Callee = *CB.getCalledFunction();

  auto GetTLI = [&](Function &F) -> const TargetLibraryInfo & {
    return FAM.getResult<TargetLibraryAnalysis>(F);
  };

  auto &TIR = FAM.getResult<TargetIRAnalysis>(Callee);

  auto TrivialDecision =
      llvm::getAttributeBasedInliningDecision(CB, &Callee, TIR, GetTLI);

  if (TrivialDecision.hasValue()) {
    if (TrivialDecision->isSuccess())
      return MandatoryInliningKind::Always;
    else
      return MandatoryInliningKind::Never;
  }
  return MandatoryInliningKind::NotMandatory;
}
