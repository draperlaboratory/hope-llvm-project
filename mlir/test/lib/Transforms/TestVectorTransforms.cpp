//===- TestVectorToVectorConversion.cpp - Test VectorTransfers lowering ---===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include <type_traits>

#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/Dialect/Vector/VectorOps.h"
#include "mlir/Dialect/Vector/VectorTransforms.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Pass/Pass.h"

using namespace mlir;
using namespace mlir::vector;
namespace {

#include "TestVectorTransformPatterns.h.inc"

struct TestVectorToVectorConversion
    : public PassWrapper<TestVectorToVectorConversion, FunctionPass> {
  void runOnFunction() override {
    OwningRewritePatternList patterns;
    auto *context = &getContext();
    populateWithGenerated(context, &patterns);
    populateVectorToVectorCanonicalizationPatterns(patterns, context);
    populateVectorToVectorTransformationPatterns(patterns, context);
    applyPatternsAndFoldGreedily(getFunction(), patterns);
  }
};

struct TestVectorSlicesConversion
    : public PassWrapper<TestVectorSlicesConversion, FunctionPass> {
  void runOnFunction() override {
    OwningRewritePatternList patterns;
    populateVectorSlicesLoweringPatterns(patterns, &getContext());
    applyPatternsAndFoldGreedily(getFunction(), patterns);
  }
};

struct TestVectorContractionConversion
    : public PassWrapper<TestVectorContractionConversion, FunctionPass> {
  TestVectorContractionConversion() = default;
  TestVectorContractionConversion(const TestVectorContractionConversion &pass) {
  }

  Option<bool> lowerToFlatMatrix{
      *this, "vector-lower-matrix-intrinsics",
      llvm::cl::desc("Lower vector.contract to llvm.intr.matrix.multiply"),
      llvm::cl::init(false)};
  Option<bool> lowerToFlatTranspose{
      *this, "vector-flat-transpose",
      llvm::cl::desc("Lower 2-D vector.transpose to vector.flat_transpose"),
      llvm::cl::init(false)};
  Option<bool> lowerToOuterProduct{
      *this, "vector-outerproduct",
      llvm::cl::desc("Lower vector.contract to vector.outerproduct"),
      llvm::cl::init(false)};
  Option<bool> lowerToAXPY{*this, "vector-axpy",
                           llvm::cl::desc("Lower vector.contract to AXPY"),
                           llvm::cl::init(false)};

  void runOnFunction() override {
    OwningRewritePatternList patterns;

    // Test on one pattern in isolation.
    if (lowerToOuterProduct) {
      VectorContractLowering lowering = VectorContractLowering::OuterProduct;
      VectorTransformsOptions options{lowering};
      patterns.insert<ContractionOpToOuterProductOpLowering>(options,
                                                             &getContext());
      applyPatternsAndFoldGreedily(getFunction(), patterns);
      return;
    }

    // Test on all contract lowering patterns.
    VectorContractLowering contractLowering = VectorContractLowering::Dot;
    if (lowerToFlatMatrix)
      contractLowering = VectorContractLowering::Matmul;
    else if (lowerToAXPY)
      contractLowering = VectorContractLowering::AXPY;
    VectorTransposeLowering transposeLowering =
        VectorTransposeLowering::EltWise;
    if (lowerToFlatTranspose)
      transposeLowering = VectorTransposeLowering::Flat;
    VectorTransformsOptions options{contractLowering, transposeLowering};
    populateVectorContractLoweringPatterns(patterns, &getContext(), options);
    applyPatternsAndFoldGreedily(getFunction(), patterns);
  }
};

struct TestVectorUnrollingPatterns
    : public PassWrapper<TestVectorUnrollingPatterns, FunctionPass> {
  void runOnFunction() override {
    MLIRContext *ctx = &getContext();
    OwningRewritePatternList patterns;
    patterns.insert<UnrollVectorPattern<AddFOp>>(ArrayRef<int64_t>{2, 2}, ctx);
    patterns.insert<UnrollVectorPattern<vector::ContractionOp>>(
        ArrayRef<int64_t>{2, 2, 2}, ctx);
    populateVectorToVectorCanonicalizationPatterns(patterns, ctx);
    populateVectorToVectorTransformationPatterns(patterns, ctx);
    applyPatternsAndFoldGreedily(getFunction(), patterns);
  }
};

} // end anonymous namespace

namespace mlir {
void registerTestVectorConversions() {
  PassRegistration<TestVectorToVectorConversion> vectorToVectorPass(
      "test-vector-to-vector-conversion",
      "Test conversion patterns between ops in the vector dialect");

  PassRegistration<TestVectorSlicesConversion> slicesPass(
      "test-vector-slices-conversion",
      "Test conversion patterns that lower slices ops in the vector dialect");

  PassRegistration<TestVectorContractionConversion> contractionPass(
      "test-vector-contraction-conversion",
      "Test conversion patterns that lower contract ops in the vector dialect");

  PassRegistration<TestVectorUnrollingPatterns> contractionUnrollingPass(
      "test-vector-unrolling-patterns",
      "Test conversion patterns to unroll contract ops in the vector dialect");
}
} // namespace mlir
