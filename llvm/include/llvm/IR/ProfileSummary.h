//===- ProfileSummary.h - Profile summary data structure. -------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the profile summary data structure.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_IR_PROFILESUMMARY_H
#define LLVM_IR_PROFILESUMMARY_H

#include <algorithm>
#include <cstdint>
#include <vector>

namespace llvm {

class LLVMContext;
class Metadata;
class raw_ostream;

// The profile summary is one or more (Cutoff, MinCount, NumCounts) triplets.
// The semantics of counts depend on the type of profile. For instrumentation
// profile, counts are block counts and for sample profile, counts are
// per-line samples. Given a target counts percentile, we compute the minimum
// number of counts needed to reach this target and the minimum among these
// counts.
struct ProfileSummaryEntry {
  uint32_t Cutoff;    ///< The required percentile of counts.
  uint64_t MinCount;  ///< The minimum count for this percentile.
  uint64_t NumCounts; ///< Number of counts >= the minimum count.

  ProfileSummaryEntry(uint32_t TheCutoff, uint64_t TheMinCount,
                      uint64_t TheNumCounts)
      : Cutoff(TheCutoff), MinCount(TheMinCount), NumCounts(TheNumCounts) {}
};

using SummaryEntryVector = std::vector<ProfileSummaryEntry>;

class ProfileSummary {
public:
  enum Kind { PSK_Instr, PSK_CSInstr, PSK_Sample };

private:
  const Kind PSK;
  SummaryEntryVector DetailedSummary;
  uint64_t TotalCount, MaxCount, MaxInternalCount, MaxFunctionCount;
  uint32_t NumCounts, NumFunctions;
  /// If 'Partial' is false, it means the profile being used to optimize
  /// a target is collected from the same target.
  /// If 'Partial' is true, it means the profile is for common/shared
  /// code. The common profile is usually merged from profiles collected
  /// from running other targets.
  bool Partial = false;
  /// Return detailed summary as metadata.
  Metadata *getDetailedSummaryMD(LLVMContext &Context);

public:
  static const int Scale = 1000000;

  ProfileSummary(Kind K, SummaryEntryVector DetailedSummary,
                 uint64_t TotalCount, uint64_t MaxCount,
                 uint64_t MaxInternalCount, uint64_t MaxFunctionCount,
                 uint32_t NumCounts, uint32_t NumFunctions,
                 bool Partial = false)
      : PSK(K), DetailedSummary(std::move(DetailedSummary)),
        TotalCount(TotalCount), MaxCount(MaxCount),
        MaxInternalCount(MaxInternalCount), MaxFunctionCount(MaxFunctionCount),
        NumCounts(NumCounts), NumFunctions(NumFunctions), Partial(Partial) {}

  Kind getKind() const { return PSK; }
  /// Return summary information as metadata.
  Metadata *getMD(LLVMContext &Context, bool AddPartialField = true);
  /// Construct profile summary from metdata.
  static ProfileSummary *getFromMD(Metadata *MD);
  SummaryEntryVector &getDetailedSummary() { return DetailedSummary; }
  uint32_t getNumFunctions() { return NumFunctions; }
  uint64_t getMaxFunctionCount() { return MaxFunctionCount; }
  uint32_t getNumCounts() { return NumCounts; }
  uint64_t getTotalCount() { return TotalCount; }
  uint64_t getMaxCount() { return MaxCount; }
  uint64_t getMaxInternalCount() { return MaxInternalCount; }
  void setPartialProfile(bool PP) { Partial = PP; }
  bool isPartialProfile() { return Partial; }
  void printSummary(raw_ostream &OS);
  void printDetailedSummary(raw_ostream &OS);
};

} // end namespace llvm

#endif // LLVM_IR_PROFILESUMMARY_H
