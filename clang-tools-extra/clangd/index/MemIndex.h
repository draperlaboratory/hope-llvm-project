//===--- MemIndex.h - Dynamic in-memory symbol index. -------------- C++-*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_TOOLS_EXTRA_CLANGD_INDEX_MEMINDEX_H
#define LLVM_CLANG_TOOLS_EXTRA_CLANGD_INDEX_MEMINDEX_H

#include "Index.h"
#include <mutex>

namespace clang {
namespace clangd {

/// MemIndex is a naive in-memory index suitable for a small set of symbols.
class MemIndex : public SymbolIndex {
public:
  MemIndex() = default;
  // All symbols and refs must outlive this index.
  template <typename SymbolRange, typename RefRange, typename RelationRange>
  MemIndex(SymbolRange &&Symbols, RefRange &&Refs, RelationRange &&Relations) {
    for (const Symbol &S : Symbols)
      Index[S.ID] = &S;
    for (const std::pair<SymbolID, llvm::ArrayRef<Ref>> &R : Refs)
      this->Refs.try_emplace(R.first, R.second.begin(), R.second.end());
    for (const Relation &R : Relations)
      this->Relations[std::make_pair(R.Subject, R.Predicate)].push_back(
          R.Object);
  }
  // Symbols are owned by BackingData, Index takes ownership.
  template <typename SymbolRange, typename RefRange, typename RelationRange,
            typename Payload>
  MemIndex(SymbolRange &&Symbols, RefRange &&Refs, RelationRange &&Relations,
           Payload &&BackingData, size_t BackingDataSize)
      : MemIndex(std::forward<SymbolRange>(Symbols),
                 std::forward<RefRange>(Refs),
                 std::forward<RelationRange>(Relations)) {
    KeepAlive = std::shared_ptr<void>(
        std::make_shared<Payload>(std::move(BackingData)), nullptr);
    this->BackingDataSize = BackingDataSize;
  }

  /// Builds an index from slabs. The index takes ownership of the data.
  static std::unique_ptr<SymbolIndex> build(SymbolSlab Symbols, RefSlab Refs,
                                            RelationSlab Relations);

  bool
  fuzzyFind(const FuzzyFindRequest &Req,
            llvm::function_ref<void(const Symbol &)> Callback) const override;

  void lookup(const LookupRequest &Req,
              llvm::function_ref<void(const Symbol &)> Callback) const override;

  void refs(const RefsRequest &Req,
            llvm::function_ref<void(const Ref &)> Callback) const override;

  void relations(const RelationsRequest &Req,
                 llvm::function_ref<void(const SymbolID &, const Symbol &)>
                     Callback) const override;

  size_t estimateMemoryUsage() const override;

private:
  // Index is a set of symbols that are deduplicated by symbol IDs.
  llvm::DenseMap<SymbolID, const Symbol *> Index;
  // A map from symbol ID to symbol refs, support query by IDs.
  llvm::DenseMap<SymbolID, llvm::ArrayRef<Ref>> Refs;
  // A map from (subject, predicate) pair to objects.
  llvm::DenseMap<std::pair<SymbolID, index::SymbolRole>, std::vector<SymbolID>>
      Relations;
  std::shared_ptr<void> KeepAlive; // poor man's move-only std::any
  // Size of memory retained by KeepAlive.
  size_t BackingDataSize = 0;
};

} // namespace clangd
} // namespace clang

#endif // LLVM_CLANG_TOOLS_EXTRA_CLANGD_INDEX_MEMINDEX_H
