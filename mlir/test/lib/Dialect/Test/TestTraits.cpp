//===- TestTraits.cpp - Test trait folding --------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "TestDialect.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/FoldUtils.h"

using namespace mlir;

//===----------------------------------------------------------------------===//
// Trait Folder.
//===----------------------------------------------------------------------===//

OpFoldResult TestInvolutionTraitFailingOperationFolderOp::fold(
    ArrayRef<Attribute> operands) {
  // This failure should cause the trait fold to run instead.
  return {};
}

OpFoldResult TestInvolutionTraitSuccesfulOperationFolderOp::fold(
    ArrayRef<Attribute> operands) {
  auto argument_op = getOperand();
  // The success case should cause the trait fold to be supressed.
  return argument_op.getDefiningOp() ? argument_op : OpFoldResult{};
}

namespace {
struct TestTraitFolder : public PassWrapper<TestTraitFolder, FunctionPass> {
  void runOnFunction() override {
    applyPatternsAndFoldGreedily(getFunction(), {});
  }
};
} // end anonymous namespace

namespace mlir {
void registerTestTraitsPass() {
  PassRegistration<TestTraitFolder>("test-trait-folder", "Run trait folding");
}
} // namespace mlir
