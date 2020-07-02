//===- ConvertSPIRVToLLVM.cpp - SPIR-V dialect to LLVM dialect conversion -===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements patterns to convert SPIR-V dialect to LLVM dialect.
//
//===----------------------------------------------------------------------===//

#include "mlir/Conversion/SPIRVToLLVM/ConvertSPIRVToLLVM.h"
#include "mlir/Conversion/StandardToLLVM/ConvertStandardToLLVM.h"
#include "mlir/Conversion/StandardToLLVM/ConvertStandardToLLVMPass.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/SPIRV/SPIRVDialect.h"
#include "mlir/Dialect/SPIRV/SPIRVOps.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/IR/Module.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Support/LogicalResult.h"
#include "mlir/Transforms/DialectConversion.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "spirv-to-llvm-pattern"

using namespace mlir;

//===----------------------------------------------------------------------===//
// Utility functions
//===----------------------------------------------------------------------===//

/// Returns true if the given type is an unsigned integer or vector type
static bool isUnsignedIntegerOrVector(Type type) {
  if (type.isUnsignedInteger())
    return true;
  if (auto vecType = type.dyn_cast<VectorType>())
    return vecType.getElementType().isUnsignedInteger();
  return false;
}

/// Returns the bit width of integer, float or vector of float or integer values
static unsigned getBitWidth(Type type) {
  assert((type.isIntOrFloat() || type.isa<VectorType>()) &&
         "bitwidth is not supported for this type");
  if (type.isIntOrFloat())
    return type.getIntOrFloatBitWidth();
  auto vecType = type.dyn_cast<VectorType>();
  auto elementType = vecType.getElementType();
  assert(elementType.isIntOrFloat() &&
         "only integers and floats have a bitwidth");
  return elementType.getIntOrFloatBitWidth();
}

/// Returns the bit width of LLVMType integer or vector.
static unsigned getLLVMTypeBitWidth(LLVM::LLVMType type) {
  return type.isVectorTy() ? type.getVectorElementType()
                                 .getUnderlyingType()
                                 ->getIntegerBitWidth()
                           : type.getUnderlyingType()->getIntegerBitWidth();
}

/// Creates `IntegerAttribute` with all bits set for given type
IntegerAttr minusOneIntegerAttribute(Type type, Builder builder) {
  if (auto vecType = type.dyn_cast<VectorType>()) {
    auto integerType = vecType.getElementType().cast<IntegerType>();
    return builder.getIntegerAttr(integerType, -1);
  }
  auto integerType = type.cast<IntegerType>();
  return builder.getIntegerAttr(integerType, -1);
}

/// Creates `llvm.mlir.constant` with all bits set for the given type.
static Value createConstantAllBitsSet(Location loc, Type srcType, Type dstType,
                                      PatternRewriter &rewriter) {
  if (srcType.isa<VectorType>())
    return rewriter.create<LLVM::ConstantOp>(
        loc, dstType,
        SplatElementsAttr::get(srcType.cast<ShapedType>(),
                               minusOneIntegerAttribute(srcType, rewriter)));
  return rewriter.create<LLVM::ConstantOp>(
      loc, dstType, minusOneIntegerAttribute(srcType, rewriter));
}

/// Utility function for bitfiled ops:
///   - `BitFieldInsert`
///   - `BitFieldSExtract`
///   - `BitFieldUExtract`
/// Truncates or extends the value. If the bitwidth of the value is the same as
/// `dstType` bitwidth, the value remains unchanged.
static Value optionallyTruncateOrExtend(Location loc, Value value, Type dstType,
                                        PatternRewriter &rewriter) {
  auto srcType = value.getType();
  auto llvmType = dstType.cast<LLVM::LLVMType>();
  unsigned targetBitWidth = getLLVMTypeBitWidth(llvmType);
  unsigned valueBitWidth =
      srcType.isa<LLVM::LLVMType>()
          ? getLLVMTypeBitWidth(srcType.cast<LLVM::LLVMType>())
          : getBitWidth(srcType);

  if (valueBitWidth < targetBitWidth)
    return rewriter.create<LLVM::ZExtOp>(loc, llvmType, value);
  // If the bit widths of `Count` and `Offset` are greater than the bit width
  // of the target type, they are truncated. Truncation is safe since `Count`
  // and `Offset` must be no more than 64 for op behaviour to be defined. Hence,
  // both values can be expressed in 8 bits.
  if (valueBitWidth > targetBitWidth)
    return rewriter.create<LLVM::TruncOp>(loc, llvmType, value);
  return value;
}

/// Broadcasts the value to vector with `numElements` number of elements
static Value broadcast(Location loc, Value toBroadcast, unsigned numElements,
                       LLVMTypeConverter &typeConverter,
                       ConversionPatternRewriter &rewriter) {
  auto vectorType = VectorType::get(numElements, toBroadcast.getType());
  auto llvmVectorType = typeConverter.convertType(vectorType);
  auto llvmI32Type = typeConverter.convertType(rewriter.getIntegerType(32));
  Value broadcasted = rewriter.create<LLVM::UndefOp>(loc, llvmVectorType);
  for (unsigned i = 0; i < numElements; ++i) {
    auto index = rewriter.create<LLVM::ConstantOp>(
        loc, llvmI32Type, rewriter.getI32IntegerAttr(i));
    broadcasted = rewriter.create<LLVM::InsertElementOp>(
        loc, llvmVectorType, broadcasted, toBroadcast, index);
  }
  return broadcasted;
}

//===----------------------------------------------------------------------===//
// Operation conversion
//===----------------------------------------------------------------------===//

namespace {

class BitFieldInsertPattern
    : public SPIRVToLLVMConversion<spirv::BitFieldInsertOp> {
public:
  using SPIRVToLLVMConversion<spirv::BitFieldInsertOp>::SPIRVToLLVMConversion;

  LogicalResult
  matchAndRewrite(spirv::BitFieldInsertOp op, ArrayRef<Value> operands,
                  ConversionPatternRewriter &rewriter) const override {
    auto srcType = op.getType();
    auto dstType = this->typeConverter.convertType(srcType);
    if (!dstType)
      return failure();
    Location loc = op.getLoc();

    // Broadcast `Offset` and `Count` to match the type of `Base` and `Insert`.
    // If `Base` is of a vector type, construct a vector that has:
    //  - same number of elements as `Base`
    //  - each element has the type that is the same as the type of `Offset` or
    //    `Count`
    //  - each element has the same value as `Offset` or `Count`
    Value offset;
    Value count;
    if (auto vectorType = srcType.dyn_cast<VectorType>()) {
      unsigned numElements = vectorType.getNumElements();
      offset =
          broadcast(loc, op.offset(), numElements, typeConverter, rewriter);
      count = broadcast(loc, op.count(), numElements, typeConverter, rewriter);
    } else {
      offset = op.offset();
      count = op.count();
    }

    // Create a mask with all bits set of the same type as `srcType`
    Value minusOne = createConstantAllBitsSet(loc, srcType, dstType, rewriter);

    // Need to cast `Offset` and `Count` if their bit width is different
    // from `Base` bit width.
    Value optionallyCastedCount =
        optionallyTruncateOrExtend(loc, count, dstType, rewriter);
    Value optionallyCastedOffset =
        optionallyTruncateOrExtend(loc, offset, dstType, rewriter);

    // Create a mask with bits set outside [Offset, Offset + Count - 1].
    Value maskShiftedByCount = rewriter.create<LLVM::ShlOp>(
        loc, dstType, minusOne, optionallyCastedCount);
    Value negated = rewriter.create<LLVM::XOrOp>(loc, dstType,
                                                 maskShiftedByCount, minusOne);
    Value maskShiftedByCountAndOffset = rewriter.create<LLVM::ShlOp>(
        loc, dstType, negated, optionallyCastedOffset);
    Value mask = rewriter.create<LLVM::XOrOp>(
        loc, dstType, maskShiftedByCountAndOffset, minusOne);

    // Extract unchanged bits from the `Base`  that are outside of
    // [Offset, Offset + Count - 1]. Then `or` with shifted `Insert`.
    Value baseAndMask =
        rewriter.create<LLVM::AndOp>(loc, dstType, op.base(), mask);
    Value insertShiftedByOffset = rewriter.create<LLVM::ShlOp>(
        loc, dstType, op.insert(), optionallyCastedOffset);
    rewriter.replaceOpWithNewOp<LLVM::OrOp>(op, dstType, baseAndMask,
                                            insertShiftedByOffset);
    return success();
  }
};

/// Converts SPIR-V operations that have straightforward LLVM equivalent
/// into LLVM dialect operations.
template <typename SPIRVOp, typename LLVMOp>
class DirectConversionPattern : public SPIRVToLLVMConversion<SPIRVOp> {
public:
  using SPIRVToLLVMConversion<SPIRVOp>::SPIRVToLLVMConversion;

  LogicalResult
  matchAndRewrite(SPIRVOp operation, ArrayRef<Value> operands,
                  ConversionPatternRewriter &rewriter) const override {
    auto dstType = this->typeConverter.convertType(operation.getType());
    if (!dstType)
      return failure();
    rewriter.template replaceOpWithNewOp<LLVMOp>(operation, dstType, operands,
                                                 operation.getAttrs());
    return success();
  }
};

/// Converts SPIR-V cast ops that do not have straightforward LLVM
/// equivalent in LLVM dialect.
template <typename SPIRVOp, typename LLVMExtOp, typename LLVMTruncOp>
class IndirectCastPattern : public SPIRVToLLVMConversion<SPIRVOp> {
public:
  using SPIRVToLLVMConversion<SPIRVOp>::SPIRVToLLVMConversion;

  LogicalResult
  matchAndRewrite(SPIRVOp operation, ArrayRef<Value> operands,
                  ConversionPatternRewriter &rewriter) const override {

    Type fromType = operation.operand().getType();
    Type toType = operation.getType();

    auto dstType = this->typeConverter.convertType(toType);
    if (!dstType)
      return failure();

    if (getBitWidth(fromType) < getBitWidth(toType)) {
      rewriter.template replaceOpWithNewOp<LLVMExtOp>(operation, dstType,
                                                      operands);
      return success();
    }
    if (getBitWidth(fromType) > getBitWidth(toType)) {
      rewriter.template replaceOpWithNewOp<LLVMTruncOp>(operation, dstType,
                                                        operands);
      return success();
    }
    return failure();
  }
};

/// Converts SPIR-V floating-point comparisons to llvm.fcmp "predicate"
template <typename SPIRVOp, LLVM::FCmpPredicate predicate>
class FComparePattern : public SPIRVToLLVMConversion<SPIRVOp> {
public:
  using SPIRVToLLVMConversion<SPIRVOp>::SPIRVToLLVMConversion;

  LogicalResult
  matchAndRewrite(SPIRVOp operation, ArrayRef<Value> operands,
                  ConversionPatternRewriter &rewriter) const override {

    auto dstType = this->typeConverter.convertType(operation.getType());
    if (!dstType)
      return failure();

    rewriter.template replaceOpWithNewOp<LLVM::FCmpOp>(
        operation, dstType,
        rewriter.getI64IntegerAttr(static_cast<int64_t>(predicate)),
        operation.operand1(), operation.operand2());
    return success();
  }
};

/// Converts SPIR-V integer comparisons to llvm.icmp "predicate"
template <typename SPIRVOp, LLVM::ICmpPredicate predicate>
class IComparePattern : public SPIRVToLLVMConversion<SPIRVOp> {
public:
  using SPIRVToLLVMConversion<SPIRVOp>::SPIRVToLLVMConversion;

  LogicalResult
  matchAndRewrite(SPIRVOp operation, ArrayRef<Value> operands,
                  ConversionPatternRewriter &rewriter) const override {

    auto dstType = this->typeConverter.convertType(operation.getType());
    if (!dstType)
      return failure();

    rewriter.template replaceOpWithNewOp<LLVM::ICmpOp>(
        operation, dstType,
        rewriter.getI64IntegerAttr(static_cast<int64_t>(predicate)),
        operation.operand1(), operation.operand2());
    return success();
  }
};

/// Converts `spv.Not` and `spv.LogicalNot` into LLVM dialect.
template <typename SPIRVOp>
class NotPattern : public SPIRVToLLVMConversion<SPIRVOp> {
public:
  using SPIRVToLLVMConversion<SPIRVOp>::SPIRVToLLVMConversion;

  LogicalResult
  matchAndRewrite(SPIRVOp notOp, ArrayRef<Value> operands,
                  ConversionPatternRewriter &rewriter) const override {

    auto srcType = notOp.getType();
    auto dstType = this->typeConverter.convertType(srcType);
    if (!dstType)
      return failure();

    Location loc = notOp.getLoc();
    IntegerAttr minusOne = minusOneIntegerAttribute(srcType, rewriter);
    auto mask = srcType.template isa<VectorType>()
                    ? rewriter.create<LLVM::ConstantOp>(
                          loc, dstType,
                          SplatElementsAttr::get(
                              srcType.template cast<VectorType>(), minusOne))
                    : rewriter.create<LLVM::ConstantOp>(loc, dstType, minusOne);
    rewriter.template replaceOpWithNewOp<LLVM::XOrOp>(notOp, dstType,
                                                      notOp.operand(), mask);
    return success();
  }
};

class ReturnPattern : public SPIRVToLLVMConversion<spirv::ReturnOp> {
public:
  using SPIRVToLLVMConversion<spirv::ReturnOp>::SPIRVToLLVMConversion;

  LogicalResult
  matchAndRewrite(spirv::ReturnOp returnOp, ArrayRef<Value> operands,
                  ConversionPatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<LLVM::ReturnOp>(returnOp, ArrayRef<Type>(),
                                                ArrayRef<Value>());
    return success();
  }
};

class ReturnValuePattern : public SPIRVToLLVMConversion<spirv::ReturnValueOp> {
public:
  using SPIRVToLLVMConversion<spirv::ReturnValueOp>::SPIRVToLLVMConversion;

  LogicalResult
  matchAndRewrite(spirv::ReturnValueOp returnValueOp, ArrayRef<Value> operands,
                  ConversionPatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<LLVM::ReturnOp>(returnValueOp, ArrayRef<Type>(),
                                                operands);
    return success();
  }
};

/// Converts SPIR-V shift ops to LLVM shift ops. Since LLVM dialect
/// puts a restriction on `Shift` and `Base` to have the same bit width,
/// `Shift` is zero or sign extended to match this specification. Cases when
/// `Shift` bit width > `Base` bit width are considered to be illegal.
template <typename SPIRVOp, typename LLVMOp>
class ShiftPattern : public SPIRVToLLVMConversion<SPIRVOp> {
public:
  using SPIRVToLLVMConversion<SPIRVOp>::SPIRVToLLVMConversion;

  LogicalResult
  matchAndRewrite(SPIRVOp operation, ArrayRef<Value> operands,
                  ConversionPatternRewriter &rewriter) const override {

    auto dstType = this->typeConverter.convertType(operation.getType());
    if (!dstType)
      return failure();

    Type op1Type = operation.operand1().getType();
    Type op2Type = operation.operand2().getType();

    if (op1Type == op2Type) {
      rewriter.template replaceOpWithNewOp<LLVMOp>(operation, dstType,
                                                   operands);
      return success();
    }

    Location loc = operation.getLoc();
    Value extended;
    if (isUnsignedIntegerOrVector(op2Type)) {
      extended = rewriter.template create<LLVM::ZExtOp>(loc, dstType,
                                                        operation.operand2());
    } else {
      extended = rewriter.template create<LLVM::SExtOp>(loc, dstType,
                                                        operation.operand2());
    }
    Value result = rewriter.template create<LLVMOp>(
        loc, dstType, operation.operand1(), extended);
    rewriter.replaceOp(operation, result);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// FuncOp conversion
//===----------------------------------------------------------------------===//

class FuncConversionPattern : public SPIRVToLLVMConversion<spirv::FuncOp> {
public:
  using SPIRVToLLVMConversion<spirv::FuncOp>::SPIRVToLLVMConversion;

  LogicalResult
  matchAndRewrite(spirv::FuncOp funcOp, ArrayRef<Value> operands,
                  ConversionPatternRewriter &rewriter) const override {

    // Convert function signature. At the moment LLVMType converter is enough
    // for currently supported types.
    auto funcType = funcOp.getType();
    TypeConverter::SignatureConversion signatureConverter(
        funcType.getNumInputs());
    auto llvmType = this->typeConverter.convertFunctionSignature(
        funcOp.getType(), /*isVariadic=*/false, signatureConverter);

    // Create a new `LLVMFuncOp`
    Location loc = funcOp.getLoc();
    StringRef name = funcOp.getName();
    auto newFuncOp = rewriter.create<LLVM::LLVMFuncOp>(loc, name, llvmType);

    // Convert SPIR-V Function Control to equivalent LLVM function attribute
    MLIRContext *context = funcOp.getContext();
    switch (funcOp.function_control()) {
#define DISPATCH(functionControl, llvmAttr)                                    \
  case functionControl:                                                        \
    newFuncOp.setAttr("passthrough", ArrayAttr::get({llvmAttr}, context));     \
    break;

          DISPATCH(spirv::FunctionControl::Inline,
                   StringAttr::get("alwaysinline", context));
          DISPATCH(spirv::FunctionControl::DontInline,
                   StringAttr::get("noinline", context));
          DISPATCH(spirv::FunctionControl::Pure,
                   StringAttr::get("readonly", context));
          DISPATCH(spirv::FunctionControl::Const,
                   StringAttr::get("readnone", context));

#undef DISPATCH

    // Default: if `spirv::FunctionControl::None`, then no attributes are
    // needed.
    default:
      break;
    }

    rewriter.inlineRegionBefore(funcOp.getBody(), newFuncOp.getBody(),
                                newFuncOp.end());
    rewriter.applySignatureConversion(&newFuncOp.getBody(), signatureConverter);
    rewriter.eraseOp(funcOp);
    return success();
  }
};

//===----------------------------------------------------------------------===//
// ModuleOp conversion
//===----------------------------------------------------------------------===//

class ModuleConversionPattern : public SPIRVToLLVMConversion<spirv::ModuleOp> {
public:
  using SPIRVToLLVMConversion<spirv::ModuleOp>::SPIRVToLLVMConversion;

  LogicalResult
  matchAndRewrite(spirv::ModuleOp spvModuleOp, ArrayRef<Value> operands,
                  ConversionPatternRewriter &rewriter) const override {

    auto newModuleOp = rewriter.create<ModuleOp>(spvModuleOp.getLoc());
    rewriter.inlineRegionBefore(spvModuleOp.body(), newModuleOp.getBody());

    // Remove the terminator block that was automatically added by builder
    rewriter.eraseBlock(&newModuleOp.getBodyRegion().back());
    rewriter.eraseOp(spvModuleOp);
    return success();
  }
};

class ModuleEndConversionPattern
    : public SPIRVToLLVMConversion<spirv::ModuleEndOp> {
public:
  using SPIRVToLLVMConversion<spirv::ModuleEndOp>::SPIRVToLLVMConversion;

  LogicalResult
  matchAndRewrite(spirv::ModuleEndOp moduleEndOp, ArrayRef<Value> operands,
                  ConversionPatternRewriter &rewriter) const override {

    rewriter.replaceOpWithNewOp<ModuleTerminatorOp>(moduleEndOp);
    return success();
  }
};

} // namespace

//===----------------------------------------------------------------------===//
// Pattern population
//===----------------------------------------------------------------------===//

void mlir::populateSPIRVToLLVMConversionPatterns(
    MLIRContext *context, LLVMTypeConverter &typeConverter,
    OwningRewritePatternList &patterns) {
  patterns.insert<
      // Arithmetic ops
      DirectConversionPattern<spirv::IAddOp, LLVM::AddOp>,
      DirectConversionPattern<spirv::IMulOp, LLVM::MulOp>,
      DirectConversionPattern<spirv::ISubOp, LLVM::SubOp>,
      DirectConversionPattern<spirv::FAddOp, LLVM::FAddOp>,
      DirectConversionPattern<spirv::FDivOp, LLVM::FDivOp>,
      DirectConversionPattern<spirv::FNegateOp, LLVM::FNegOp>,
      DirectConversionPattern<spirv::FRemOp, LLVM::FRemOp>,
      DirectConversionPattern<spirv::FSubOp, LLVM::FSubOp>,
      DirectConversionPattern<spirv::SDivOp, LLVM::SDivOp>,
      DirectConversionPattern<spirv::SRemOp, LLVM::SRemOp>,
      DirectConversionPattern<spirv::UDivOp, LLVM::UDivOp>,
      DirectConversionPattern<spirv::UModOp, LLVM::URemOp>,

      // Bitwise ops
      BitFieldInsertPattern,
      DirectConversionPattern<spirv::BitCountOp, LLVM::CtPopOp>,
      DirectConversionPattern<spirv::BitReverseOp, LLVM::BitReverseOp>,
      DirectConversionPattern<spirv::BitwiseAndOp, LLVM::AndOp>,
      DirectConversionPattern<spirv::BitwiseOrOp, LLVM::OrOp>,
      DirectConversionPattern<spirv::BitwiseXorOp, LLVM::XOrOp>,
      NotPattern<spirv::NotOp>,

      // Cast ops
      DirectConversionPattern<spirv::BitcastOp, LLVM::BitcastOp>,
      DirectConversionPattern<spirv::ConvertFToSOp, LLVM::FPToSIOp>,
      DirectConversionPattern<spirv::ConvertFToUOp, LLVM::FPToUIOp>,
      DirectConversionPattern<spirv::ConvertSToFOp, LLVM::SIToFPOp>,
      DirectConversionPattern<spirv::ConvertUToFOp, LLVM::UIToFPOp>,
      IndirectCastPattern<spirv::FConvertOp, LLVM::FPExtOp, LLVM::FPTruncOp>,
      IndirectCastPattern<spirv::SConvertOp, LLVM::SExtOp, LLVM::TruncOp>,
      IndirectCastPattern<spirv::UConvertOp, LLVM::ZExtOp, LLVM::TruncOp>,

      // Comparison ops
      IComparePattern<spirv::IEqualOp, LLVM::ICmpPredicate::eq>,
      IComparePattern<spirv::INotEqualOp, LLVM::ICmpPredicate::ne>,
      FComparePattern<spirv::FOrdEqualOp, LLVM::FCmpPredicate::oeq>,
      FComparePattern<spirv::FOrdGreaterThanOp, LLVM::FCmpPredicate::ogt>,
      FComparePattern<spirv::FOrdGreaterThanEqualOp, LLVM::FCmpPredicate::oge>,
      FComparePattern<spirv::FOrdLessThanEqualOp, LLVM::FCmpPredicate::ole>,
      FComparePattern<spirv::FOrdLessThanOp, LLVM::FCmpPredicate::olt>,
      FComparePattern<spirv::FOrdNotEqualOp, LLVM::FCmpPredicate::one>,
      FComparePattern<spirv::FUnordEqualOp, LLVM::FCmpPredicate::ueq>,
      FComparePattern<spirv::FUnordGreaterThanOp, LLVM::FCmpPredicate::ugt>,
      FComparePattern<spirv::FUnordGreaterThanEqualOp,
                      LLVM::FCmpPredicate::uge>,
      FComparePattern<spirv::FUnordLessThanEqualOp, LLVM::FCmpPredicate::ule>,
      FComparePattern<spirv::FUnordLessThanOp, LLVM::FCmpPredicate::ult>,
      FComparePattern<spirv::FUnordNotEqualOp, LLVM::FCmpPredicate::une>,
      IComparePattern<spirv::SGreaterThanOp, LLVM::ICmpPredicate::sgt>,
      IComparePattern<spirv::SGreaterThanEqualOp, LLVM::ICmpPredicate::sge>,
      IComparePattern<spirv::SLessThanEqualOp, LLVM::ICmpPredicate::sle>,
      IComparePattern<spirv::SLessThanOp, LLVM::ICmpPredicate::slt>,
      IComparePattern<spirv::UGreaterThanOp, LLVM::ICmpPredicate::ugt>,
      IComparePattern<spirv::UGreaterThanEqualOp, LLVM::ICmpPredicate::uge>,
      IComparePattern<spirv::ULessThanEqualOp, LLVM::ICmpPredicate::ule>,
      IComparePattern<spirv::ULessThanOp, LLVM::ICmpPredicate::ult>,

      // Logical ops
      DirectConversionPattern<spirv::LogicalAndOp, LLVM::AndOp>,
      DirectConversionPattern<spirv::LogicalOrOp, LLVM::OrOp>,
      IComparePattern<spirv::LogicalEqualOp, LLVM::ICmpPredicate::eq>,
      IComparePattern<spirv::LogicalNotEqualOp, LLVM::ICmpPredicate::ne>,
      NotPattern<spirv::LogicalNotOp>,

      // Shift ops
      ShiftPattern<spirv::ShiftRightArithmeticOp, LLVM::AShrOp>,
      ShiftPattern<spirv::ShiftRightLogicalOp, LLVM::LShrOp>,
      ShiftPattern<spirv::ShiftLeftLogicalOp, LLVM::ShlOp>,

      // Return ops
      ReturnPattern, ReturnValuePattern>(context, typeConverter);
}

void mlir::populateSPIRVToLLVMFunctionConversionPatterns(
    MLIRContext *context, LLVMTypeConverter &typeConverter,
    OwningRewritePatternList &patterns) {
  patterns.insert<FuncConversionPattern>(context, typeConverter);
}

void mlir::populateSPIRVToLLVMModuleConversionPatterns(
    MLIRContext *context, LLVMTypeConverter &typeConverter,
    OwningRewritePatternList &patterns) {
  patterns.insert<ModuleConversionPattern, ModuleEndConversionPattern>(
      context, typeConverter);
}
