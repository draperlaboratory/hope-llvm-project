//===-- X86TargetTransformInfo.cpp - X86 specific TTI pass ----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
/// \file
/// This file implements a TargetTransformInfo analysis pass specific to the
/// X86 target machine. It uses the target's detailed information to provide
/// more precise answers to certain TTI queries, while letting the target
/// independent and default TTI implementations handle the rest.
///
//===----------------------------------------------------------------------===//
/// About Cost Model numbers used below it's necessary to say the following:
/// the numbers correspond to some "generic" X86 CPU instead of usage of
/// concrete CPU model. Usually the numbers correspond to CPU where the feature
/// apeared at the first time. For example, if we do Subtarget.hasSSE42() in
/// the lookups below the cost is based on Nehalem as that was the first CPU
/// to support that feature level and thus has most likely the worst case cost.
/// Some examples of other technologies/CPUs:
///   SSE 3   - Pentium4 / Athlon64
///   SSE 4.1 - Penryn
///   SSE 4.2 - Nehalem
///   AVX     - Sandy Bridge
///   AVX2    - Haswell
///   AVX-512 - Xeon Phi / Skylake
/// And some examples of instruction target dependent costs (latency)
///                   divss     sqrtss          rsqrtss
///   AMD K7            11-16     19              3
///   Piledriver        9-24      13-15           5
///   Jaguar            14        16              2
///   Pentium II,III    18        30              2
///   Nehalem           7-14      7-18            3
///   Haswell           10-13     11              5
/// TODO: Develop and implement  the target dependent cost model and
/// specialize cost numbers for different Cost Model Targets such as throughput,
/// code size, latency and uop count.
//===----------------------------------------------------------------------===//

#include "X86TargetTransformInfo.h"
#include "llvm/Analysis/TargetTransformInfo.h"
#include "llvm/CodeGen/BasicTTIImpl.h"
#include "llvm/CodeGen/CostTable.h"
#include "llvm/CodeGen/TargetLowering.h"
#include "llvm/IR/IntrinsicInst.h"
#include "llvm/Support/Debug.h"

using namespace llvm;

#define DEBUG_TYPE "x86tti"

//===----------------------------------------------------------------------===//
//
// X86 cost model.
//
//===----------------------------------------------------------------------===//

TargetTransformInfo::PopcntSupportKind
X86TTIImpl::getPopcntSupport(unsigned TyWidth) {
  assert(isPowerOf2_32(TyWidth) && "Ty width must be power of 2");
  // TODO: Currently the __builtin_popcount() implementation using SSE3
  //   instructions is inefficient. Once the problem is fixed, we should
  //   call ST->hasSSE3() instead of ST->hasPOPCNT().
  return ST->hasPOPCNT() ? TTI::PSK_FastHardware : TTI::PSK_Software;
}

llvm::Optional<unsigned> X86TTIImpl::getCacheSize(
  TargetTransformInfo::CacheLevel Level) const {
  switch (Level) {
  case TargetTransformInfo::CacheLevel::L1D:
    //   - Penryn
    //   - Nehalem
    //   - Westmere
    //   - Sandy Bridge
    //   - Ivy Bridge
    //   - Haswell
    //   - Broadwell
    //   - Skylake
    //   - Kabylake
    return 32 * 1024;  //  32 KByte
  case TargetTransformInfo::CacheLevel::L2D:
    //   - Penryn
    //   - Nehalem
    //   - Westmere
    //   - Sandy Bridge
    //   - Ivy Bridge
    //   - Haswell
    //   - Broadwell
    //   - Skylake
    //   - Kabylake
    return 256 * 1024; // 256 KByte
  }

  llvm_unreachable("Unknown TargetTransformInfo::CacheLevel");
}

llvm::Optional<unsigned> X86TTIImpl::getCacheAssociativity(
  TargetTransformInfo::CacheLevel Level) const {
  //   - Penryn
  //   - Nehalem
  //   - Westmere
  //   - Sandy Bridge
  //   - Ivy Bridge
  //   - Haswell
  //   - Broadwell
  //   - Skylake
  //   - Kabylake
  switch (Level) {
  case TargetTransformInfo::CacheLevel::L1D:
    LLVM_FALLTHROUGH;
  case TargetTransformInfo::CacheLevel::L2D:
    return 8;
  }

  llvm_unreachable("Unknown TargetTransformInfo::CacheLevel");
}

unsigned X86TTIImpl::getNumberOfRegisters(unsigned ClassID) const {
  bool Vector = (ClassID == 1);
  if (Vector && !ST->hasSSE1())
    return 0;

  if (ST->is64Bit()) {
    if (Vector && ST->hasAVX512())
      return 32;
    return 16;
  }
  return 8;
}

unsigned X86TTIImpl::getRegisterBitWidth(bool Vector) const {
  unsigned PreferVectorWidth = ST->getPreferVectorWidth();
  if (Vector) {
    if (ST->hasAVX512() && PreferVectorWidth >= 512)
      return 512;
    if (ST->hasAVX() && PreferVectorWidth >= 256)
      return 256;
    if (ST->hasSSE1() && PreferVectorWidth >= 128)
      return 128;
    return 0;
  }

  if (ST->is64Bit())
    return 64;

  return 32;
}

unsigned X86TTIImpl::getLoadStoreVecRegBitWidth(unsigned) const {
  return getRegisterBitWidth(true);
}

unsigned X86TTIImpl::getMaxInterleaveFactor(unsigned VF) {
  // If the loop will not be vectorized, don't interleave the loop.
  // Let regular unroll to unroll the loop, which saves the overflow
  // check and memory check cost.
  if (VF == 1)
    return 1;

  if (ST->isAtom())
    return 1;

  // Sandybridge and Haswell have multiple execution ports and pipelined
  // vector units.
  if (ST->hasAVX())
    return 4;

  return 2;
}

int X86TTIImpl::getArithmeticInstrCost(unsigned Opcode, Type *Ty,
                                       TTI::TargetCostKind CostKind,
                                       TTI::OperandValueKind Op1Info,
                                       TTI::OperandValueKind Op2Info,
                                       TTI::OperandValueProperties Opd1PropInfo,
                                       TTI::OperandValueProperties Opd2PropInfo,
                                       ArrayRef<const Value *> Args,
                                       const Instruction *CxtI) {
  // TODO: Handle more cost kinds.
  if (CostKind != TTI::TCK_RecipThroughput)
    return BaseT::getArithmeticInstrCost(Opcode, Ty, CostKind, Op1Info,
                                         Op2Info, Opd1PropInfo,
                                         Opd2PropInfo, Args, CxtI);
  // Legalize the type.
  std::pair<int, MVT> LT = TLI->getTypeLegalizationCost(DL, Ty);

  int ISD = TLI->InstructionOpcodeToISD(Opcode);
  assert(ISD && "Invalid opcode");

  static const CostTblEntry GLMCostTable[] = {
    { ISD::FDIV,  MVT::f32,   18 }, // divss
    { ISD::FDIV,  MVT::v4f32, 35 }, // divps
    { ISD::FDIV,  MVT::f64,   33 }, // divsd
    { ISD::FDIV,  MVT::v2f64, 65 }, // divpd
  };

  if (ST->useGLMDivSqrtCosts())
    if (const auto *Entry = CostTableLookup(GLMCostTable, ISD,
                                            LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry SLMCostTable[] = {
    { ISD::MUL,   MVT::v4i32, 11 }, // pmulld
    { ISD::MUL,   MVT::v8i16, 2  }, // pmullw
    { ISD::MUL,   MVT::v16i8, 14 }, // extend/pmullw/trunc sequence.
    { ISD::FMUL,  MVT::f64,   2  }, // mulsd
    { ISD::FMUL,  MVT::v2f64, 4  }, // mulpd
    { ISD::FMUL,  MVT::v4f32, 2  }, // mulps
    { ISD::FDIV,  MVT::f32,   17 }, // divss
    { ISD::FDIV,  MVT::v4f32, 39 }, // divps
    { ISD::FDIV,  MVT::f64,   32 }, // divsd
    { ISD::FDIV,  MVT::v2f64, 69 }, // divpd
    { ISD::FADD,  MVT::v2f64, 2  }, // addpd
    { ISD::FSUB,  MVT::v2f64, 2  }, // subpd
    // v2i64/v4i64 mul is custom lowered as a series of long:
    // multiplies(3), shifts(3) and adds(2)
    // slm muldq version throughput is 2 and addq throughput 4
    // thus: 3X2 (muldq throughput) + 3X1 (shift throughput) +
    //       3X4 (addq throughput) = 17
    { ISD::MUL,   MVT::v2i64, 17 },
    // slm addq\subq throughput is 4
    { ISD::ADD,   MVT::v2i64, 4  },
    { ISD::SUB,   MVT::v2i64, 4  },
  };

  if (ST->isSLM()) {
    if (Args.size() == 2 && ISD == ISD::MUL && LT.second == MVT::v4i32) {
      // Check if the operands can be shrinked into a smaller datatype.
      bool Op1Signed = false;
      unsigned Op1MinSize = BaseT::minRequiredElementSize(Args[0], Op1Signed);
      bool Op2Signed = false;
      unsigned Op2MinSize = BaseT::minRequiredElementSize(Args[1], Op2Signed);

      bool signedMode = Op1Signed | Op2Signed;
      unsigned OpMinSize = std::max(Op1MinSize, Op2MinSize);

      if (OpMinSize <= 7)
        return LT.first * 3; // pmullw/sext
      if (!signedMode && OpMinSize <= 8)
        return LT.first * 3; // pmullw/zext
      if (OpMinSize <= 15)
        return LT.first * 5; // pmullw/pmulhw/pshuf
      if (!signedMode && OpMinSize <= 16)
        return LT.first * 5; // pmullw/pmulhw/pshuf
    }

    if (const auto *Entry = CostTableLookup(SLMCostTable, ISD,
                                            LT.second)) {
      return LT.first * Entry->Cost;
    }
  }

  if ((ISD == ISD::SDIV || ISD == ISD::SREM || ISD == ISD::UDIV ||
       ISD == ISD::UREM) &&
      (Op2Info == TargetTransformInfo::OK_UniformConstantValue ||
       Op2Info == TargetTransformInfo::OK_NonUniformConstantValue) &&
      Opd2PropInfo == TargetTransformInfo::OP_PowerOf2) {
    if (ISD == ISD::SDIV || ISD == ISD::SREM) {
      // On X86, vector signed division by constants power-of-two are
      // normally expanded to the sequence SRA + SRL + ADD + SRA.
      // The OperandValue properties may not be the same as that of the previous
      // operation; conservatively assume OP_None.
      int Cost =
          2 * getArithmeticInstrCost(Instruction::AShr, Ty, CostKind, Op1Info,
                                     Op2Info,
                                     TargetTransformInfo::OP_None,
                                     TargetTransformInfo::OP_None);
      Cost += getArithmeticInstrCost(Instruction::LShr, Ty, CostKind, Op1Info,
                                     Op2Info,
                                     TargetTransformInfo::OP_None,
                                     TargetTransformInfo::OP_None);
      Cost += getArithmeticInstrCost(Instruction::Add, Ty, CostKind, Op1Info,
                                     Op2Info,
                                     TargetTransformInfo::OP_None,
                                     TargetTransformInfo::OP_None);

      if (ISD == ISD::SREM) {
        // For SREM: (X % C) is the equivalent of (X - (X/C)*C)
        Cost += getArithmeticInstrCost(Instruction::Mul, Ty, CostKind, Op1Info,
                                       Op2Info);
        Cost += getArithmeticInstrCost(Instruction::Sub, Ty, CostKind, Op1Info,
                                       Op2Info);
      }

      return Cost;
    }

    // Vector unsigned division/remainder will be simplified to shifts/masks.
    if (ISD == ISD::UDIV)
      return getArithmeticInstrCost(Instruction::LShr, Ty, CostKind,
                                    Op1Info, Op2Info,
                                    TargetTransformInfo::OP_None,
                                    TargetTransformInfo::OP_None);

    else // UREM
      return getArithmeticInstrCost(Instruction::And, Ty, CostKind,
                                    Op1Info, Op2Info,
                                    TargetTransformInfo::OP_None,
                                    TargetTransformInfo::OP_None);
  }

  static const CostTblEntry AVX512BWUniformConstCostTable[] = {
    { ISD::SHL,  MVT::v64i8,   2 }, // psllw + pand.
    { ISD::SRL,  MVT::v64i8,   2 }, // psrlw + pand.
    { ISD::SRA,  MVT::v64i8,   4 }, // psrlw, pand, pxor, psubb.
  };

  if (Op2Info == TargetTransformInfo::OK_UniformConstantValue &&
      ST->hasBWI()) {
    if (const auto *Entry = CostTableLookup(AVX512BWUniformConstCostTable, ISD,
                                            LT.second))
      return LT.first * Entry->Cost;
  }

  static const CostTblEntry AVX512UniformConstCostTable[] = {
    { ISD::SRA,  MVT::v2i64,   1 },
    { ISD::SRA,  MVT::v4i64,   1 },
    { ISD::SRA,  MVT::v8i64,   1 },

    { ISD::SHL,  MVT::v64i8,   4 }, // psllw + pand.
    { ISD::SRL,  MVT::v64i8,   4 }, // psrlw + pand.
    { ISD::SRA,  MVT::v64i8,   8 }, // psrlw, pand, pxor, psubb.
  };

  if (Op2Info == TargetTransformInfo::OK_UniformConstantValue &&
      ST->hasAVX512()) {
    if (const auto *Entry = CostTableLookup(AVX512UniformConstCostTable, ISD,
                                            LT.second))
      return LT.first * Entry->Cost;
  }

  static const CostTblEntry AVX2UniformConstCostTable[] = {
    { ISD::SHL,  MVT::v32i8,   2 }, // psllw + pand.
    { ISD::SRL,  MVT::v32i8,   2 }, // psrlw + pand.
    { ISD::SRA,  MVT::v32i8,   4 }, // psrlw, pand, pxor, psubb.

    { ISD::SRA,  MVT::v4i64,   4 }, // 2 x psrad + shuffle.
  };

  if (Op2Info == TargetTransformInfo::OK_UniformConstantValue &&
      ST->hasAVX2()) {
    if (const auto *Entry = CostTableLookup(AVX2UniformConstCostTable, ISD,
                                            LT.second))
      return LT.first * Entry->Cost;
  }

  static const CostTblEntry SSE2UniformConstCostTable[] = {
    { ISD::SHL,  MVT::v16i8,     2 }, // psllw + pand.
    { ISD::SRL,  MVT::v16i8,     2 }, // psrlw + pand.
    { ISD::SRA,  MVT::v16i8,     4 }, // psrlw, pand, pxor, psubb.

    { ISD::SHL,  MVT::v32i8,   4+2 }, // 2*(psllw + pand) + split.
    { ISD::SRL,  MVT::v32i8,   4+2 }, // 2*(psrlw + pand) + split.
    { ISD::SRA,  MVT::v32i8,   8+2 }, // 2*(psrlw, pand, pxor, psubb) + split.
  };

  // XOP has faster vXi8 shifts.
  if (Op2Info == TargetTransformInfo::OK_UniformConstantValue &&
      ST->hasSSE2() && !ST->hasXOP()) {
    if (const auto *Entry =
            CostTableLookup(SSE2UniformConstCostTable, ISD, LT.second))
      return LT.first * Entry->Cost;
  }

  static const CostTblEntry AVX512BWConstCostTable[] = {
    { ISD::SDIV, MVT::v64i8,  14 }, // 2*ext+2*pmulhw sequence
    { ISD::SREM, MVT::v64i8,  16 }, // 2*ext+2*pmulhw+mul+sub sequence
    { ISD::UDIV, MVT::v64i8,  14 }, // 2*ext+2*pmulhw sequence
    { ISD::UREM, MVT::v64i8,  16 }, // 2*ext+2*pmulhw+mul+sub sequence
    { ISD::SDIV, MVT::v32i16,  6 }, // vpmulhw sequence
    { ISD::SREM, MVT::v32i16,  8 }, // vpmulhw+mul+sub sequence
    { ISD::UDIV, MVT::v32i16,  6 }, // vpmulhuw sequence
    { ISD::UREM, MVT::v32i16,  8 }, // vpmulhuw+mul+sub sequence
  };

  if ((Op2Info == TargetTransformInfo::OK_UniformConstantValue ||
       Op2Info == TargetTransformInfo::OK_NonUniformConstantValue) &&
      ST->hasBWI()) {
    if (const auto *Entry =
            CostTableLookup(AVX512BWConstCostTable, ISD, LT.second))
      return LT.first * Entry->Cost;
  }

  static const CostTblEntry AVX512ConstCostTable[] = {
    { ISD::SDIV, MVT::v16i32, 15 }, // vpmuldq sequence
    { ISD::SREM, MVT::v16i32, 17 }, // vpmuldq+mul+sub sequence
    { ISD::UDIV, MVT::v16i32, 15 }, // vpmuludq sequence
    { ISD::UREM, MVT::v16i32, 17 }, // vpmuludq+mul+sub sequence
    { ISD::SDIV, MVT::v64i8,  28 }, // 4*ext+4*pmulhw sequence
    { ISD::SREM, MVT::v64i8,  32 }, // 4*ext+4*pmulhw+mul+sub sequence
    { ISD::UDIV, MVT::v64i8,  28 }, // 4*ext+4*pmulhw sequence
    { ISD::UREM, MVT::v64i8,  32 }, // 4*ext+4*pmulhw+mul+sub sequence
    { ISD::SDIV, MVT::v32i16, 12 }, // 2*vpmulhw sequence
    { ISD::SREM, MVT::v32i16, 16 }, // 2*vpmulhw+mul+sub sequence
    { ISD::UDIV, MVT::v32i16, 12 }, // 2*vpmulhuw sequence
    { ISD::UREM, MVT::v32i16, 16 }, // 2*vpmulhuw+mul+sub sequence
  };

  if ((Op2Info == TargetTransformInfo::OK_UniformConstantValue ||
       Op2Info == TargetTransformInfo::OK_NonUniformConstantValue) &&
      ST->hasAVX512()) {
    if (const auto *Entry =
            CostTableLookup(AVX512ConstCostTable, ISD, LT.second))
      return LT.first * Entry->Cost;
  }

  static const CostTblEntry AVX2ConstCostTable[] = {
    { ISD::SDIV, MVT::v32i8,  14 }, // 2*ext+2*pmulhw sequence
    { ISD::SREM, MVT::v32i8,  16 }, // 2*ext+2*pmulhw+mul+sub sequence
    { ISD::UDIV, MVT::v32i8,  14 }, // 2*ext+2*pmulhw sequence
    { ISD::UREM, MVT::v32i8,  16 }, // 2*ext+2*pmulhw+mul+sub sequence
    { ISD::SDIV, MVT::v16i16,  6 }, // vpmulhw sequence
    { ISD::SREM, MVT::v16i16,  8 }, // vpmulhw+mul+sub sequence
    { ISD::UDIV, MVT::v16i16,  6 }, // vpmulhuw sequence
    { ISD::UREM, MVT::v16i16,  8 }, // vpmulhuw+mul+sub sequence
    { ISD::SDIV, MVT::v8i32,  15 }, // vpmuldq sequence
    { ISD::SREM, MVT::v8i32,  19 }, // vpmuldq+mul+sub sequence
    { ISD::UDIV, MVT::v8i32,  15 }, // vpmuludq sequence
    { ISD::UREM, MVT::v8i32,  19 }, // vpmuludq+mul+sub sequence
  };

  if ((Op2Info == TargetTransformInfo::OK_UniformConstantValue ||
       Op2Info == TargetTransformInfo::OK_NonUniformConstantValue) &&
      ST->hasAVX2()) {
    if (const auto *Entry = CostTableLookup(AVX2ConstCostTable, ISD, LT.second))
      return LT.first * Entry->Cost;
  }

  static const CostTblEntry SSE2ConstCostTable[] = {
    { ISD::SDIV, MVT::v32i8,  28+2 }, // 4*ext+4*pmulhw sequence + split.
    { ISD::SREM, MVT::v32i8,  32+2 }, // 4*ext+4*pmulhw+mul+sub sequence + split.
    { ISD::SDIV, MVT::v16i8,    14 }, // 2*ext+2*pmulhw sequence
    { ISD::SREM, MVT::v16i8,    16 }, // 2*ext+2*pmulhw+mul+sub sequence
    { ISD::UDIV, MVT::v32i8,  28+2 }, // 4*ext+4*pmulhw sequence + split.
    { ISD::UREM, MVT::v32i8,  32+2 }, // 4*ext+4*pmulhw+mul+sub sequence + split.
    { ISD::UDIV, MVT::v16i8,    14 }, // 2*ext+2*pmulhw sequence
    { ISD::UREM, MVT::v16i8,    16 }, // 2*ext+2*pmulhw+mul+sub sequence
    { ISD::SDIV, MVT::v16i16, 12+2 }, // 2*pmulhw sequence + split.
    { ISD::SREM, MVT::v16i16, 16+2 }, // 2*pmulhw+mul+sub sequence + split.
    { ISD::SDIV, MVT::v8i16,     6 }, // pmulhw sequence
    { ISD::SREM, MVT::v8i16,     8 }, // pmulhw+mul+sub sequence
    { ISD::UDIV, MVT::v16i16, 12+2 }, // 2*pmulhuw sequence + split.
    { ISD::UREM, MVT::v16i16, 16+2 }, // 2*pmulhuw+mul+sub sequence + split.
    { ISD::UDIV, MVT::v8i16,     6 }, // pmulhuw sequence
    { ISD::UREM, MVT::v8i16,     8 }, // pmulhuw+mul+sub sequence
    { ISD::SDIV, MVT::v8i32,  38+2 }, // 2*pmuludq sequence + split.
    { ISD::SREM, MVT::v8i32,  48+2 }, // 2*pmuludq+mul+sub sequence + split.
    { ISD::SDIV, MVT::v4i32,    19 }, // pmuludq sequence
    { ISD::SREM, MVT::v4i32,    24 }, // pmuludq+mul+sub sequence
    { ISD::UDIV, MVT::v8i32,  30+2 }, // 2*pmuludq sequence + split.
    { ISD::UREM, MVT::v8i32,  40+2 }, // 2*pmuludq+mul+sub sequence + split.
    { ISD::UDIV, MVT::v4i32,    15 }, // pmuludq sequence
    { ISD::UREM, MVT::v4i32,    20 }, // pmuludq+mul+sub sequence
  };

  if ((Op2Info == TargetTransformInfo::OK_UniformConstantValue ||
       Op2Info == TargetTransformInfo::OK_NonUniformConstantValue) &&
      ST->hasSSE2()) {
    // pmuldq sequence.
    if (ISD == ISD::SDIV && LT.second == MVT::v8i32 && ST->hasAVX())
      return LT.first * 32;
    if (ISD == ISD::SREM && LT.second == MVT::v8i32 && ST->hasAVX())
      return LT.first * 38;
    if (ISD == ISD::SDIV && LT.second == MVT::v4i32 && ST->hasSSE41())
      return LT.first * 15;
    if (ISD == ISD::SREM && LT.second == MVT::v4i32 && ST->hasSSE41())
      return LT.first * 20;

    if (const auto *Entry = CostTableLookup(SSE2ConstCostTable, ISD, LT.second))
      return LT.first * Entry->Cost;
  }

  static const CostTblEntry AVX512BWShiftCostTable[] = {
    { ISD::SHL,   MVT::v8i16,      1 }, // vpsllvw
    { ISD::SRL,   MVT::v8i16,      1 }, // vpsrlvw
    { ISD::SRA,   MVT::v8i16,      1 }, // vpsravw

    { ISD::SHL,   MVT::v16i16,     1 }, // vpsllvw
    { ISD::SRL,   MVT::v16i16,     1 }, // vpsrlvw
    { ISD::SRA,   MVT::v16i16,     1 }, // vpsravw

    { ISD::SHL,   MVT::v32i16,     1 }, // vpsllvw
    { ISD::SRL,   MVT::v32i16,     1 }, // vpsrlvw
    { ISD::SRA,   MVT::v32i16,     1 }, // vpsravw
  };

  if (ST->hasBWI())
    if (const auto *Entry = CostTableLookup(AVX512BWShiftCostTable, ISD, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry AVX2UniformCostTable[] = {
    // Uniform splats are cheaper for the following instructions.
    { ISD::SHL,  MVT::v16i16, 1 }, // psllw.
    { ISD::SRL,  MVT::v16i16, 1 }, // psrlw.
    { ISD::SRA,  MVT::v16i16, 1 }, // psraw.
    { ISD::SHL,  MVT::v32i16, 2 }, // 2*psllw.
    { ISD::SRL,  MVT::v32i16, 2 }, // 2*psrlw.
    { ISD::SRA,  MVT::v32i16, 2 }, // 2*psraw.
  };

  if (ST->hasAVX2() &&
      ((Op2Info == TargetTransformInfo::OK_UniformConstantValue) ||
       (Op2Info == TargetTransformInfo::OK_UniformValue))) {
    if (const auto *Entry =
            CostTableLookup(AVX2UniformCostTable, ISD, LT.second))
      return LT.first * Entry->Cost;
  }

  static const CostTblEntry SSE2UniformCostTable[] = {
    // Uniform splats are cheaper for the following instructions.
    { ISD::SHL,  MVT::v8i16,  1 }, // psllw.
    { ISD::SHL,  MVT::v4i32,  1 }, // pslld
    { ISD::SHL,  MVT::v2i64,  1 }, // psllq.

    { ISD::SRL,  MVT::v8i16,  1 }, // psrlw.
    { ISD::SRL,  MVT::v4i32,  1 }, // psrld.
    { ISD::SRL,  MVT::v2i64,  1 }, // psrlq.

    { ISD::SRA,  MVT::v8i16,  1 }, // psraw.
    { ISD::SRA,  MVT::v4i32,  1 }, // psrad.
  };

  if (ST->hasSSE2() &&
      ((Op2Info == TargetTransformInfo::OK_UniformConstantValue) ||
       (Op2Info == TargetTransformInfo::OK_UniformValue))) {
    if (const auto *Entry =
            CostTableLookup(SSE2UniformCostTable, ISD, LT.second))
      return LT.first * Entry->Cost;
  }

  static const CostTblEntry AVX512DQCostTable[] = {
    { ISD::MUL,  MVT::v2i64, 1 },
    { ISD::MUL,  MVT::v4i64, 1 },
    { ISD::MUL,  MVT::v8i64, 1 }
  };

  // Look for AVX512DQ lowering tricks for custom cases.
  if (ST->hasDQI())
    if (const auto *Entry = CostTableLookup(AVX512DQCostTable, ISD, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry AVX512BWCostTable[] = {
    { ISD::SHL,   MVT::v64i8,     11 }, // vpblendvb sequence.
    { ISD::SRL,   MVT::v64i8,     11 }, // vpblendvb sequence.
    { ISD::SRA,   MVT::v64i8,     24 }, // vpblendvb sequence.

    { ISD::MUL,   MVT::v64i8,     11 }, // extend/pmullw/trunc sequence.
    { ISD::MUL,   MVT::v32i8,      4 }, // extend/pmullw/trunc sequence.
    { ISD::MUL,   MVT::v16i8,      4 }, // extend/pmullw/trunc sequence.
  };

  // Look for AVX512BW lowering tricks for custom cases.
  if (ST->hasBWI())
    if (const auto *Entry = CostTableLookup(AVX512BWCostTable, ISD, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry AVX512CostTable[] = {
    { ISD::SHL,     MVT::v16i32,     1 },
    { ISD::SRL,     MVT::v16i32,     1 },
    { ISD::SRA,     MVT::v16i32,     1 },

    { ISD::SHL,     MVT::v8i64,      1 },
    { ISD::SRL,     MVT::v8i64,      1 },

    { ISD::SRA,     MVT::v2i64,      1 },
    { ISD::SRA,     MVT::v4i64,      1 },
    { ISD::SRA,     MVT::v8i64,      1 },

    { ISD::MUL,     MVT::v64i8,     26 }, // extend/pmullw/trunc sequence.
    { ISD::MUL,     MVT::v32i8,     13 }, // extend/pmullw/trunc sequence.
    { ISD::MUL,     MVT::v16i8,      5 }, // extend/pmullw/trunc sequence.
    { ISD::MUL,     MVT::v16i32,     1 }, // pmulld (Skylake from agner.org)
    { ISD::MUL,     MVT::v8i32,      1 }, // pmulld (Skylake from agner.org)
    { ISD::MUL,     MVT::v4i32,      1 }, // pmulld (Skylake from agner.org)
    { ISD::MUL,     MVT::v8i64,      8 }, // 3*pmuludq/3*shift/2*add

    { ISD::FADD,    MVT::v8f64,      1 }, // Skylake from http://www.agner.org/
    { ISD::FSUB,    MVT::v8f64,      1 }, // Skylake from http://www.agner.org/
    { ISD::FMUL,    MVT::v8f64,      1 }, // Skylake from http://www.agner.org/

    { ISD::FADD,    MVT::v16f32,     1 }, // Skylake from http://www.agner.org/
    { ISD::FSUB,    MVT::v16f32,     1 }, // Skylake from http://www.agner.org/
    { ISD::FMUL,    MVT::v16f32,     1 }, // Skylake from http://www.agner.org/
  };

  if (ST->hasAVX512())
    if (const auto *Entry = CostTableLookup(AVX512CostTable, ISD, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry AVX2ShiftCostTable[] = {
    // Shifts on v4i64/v8i32 on AVX2 is legal even though we declare to
    // customize them to detect the cases where shift amount is a scalar one.
    { ISD::SHL,     MVT::v4i32,    1 },
    { ISD::SRL,     MVT::v4i32,    1 },
    { ISD::SRA,     MVT::v4i32,    1 },
    { ISD::SHL,     MVT::v8i32,    1 },
    { ISD::SRL,     MVT::v8i32,    1 },
    { ISD::SRA,     MVT::v8i32,    1 },
    { ISD::SHL,     MVT::v2i64,    1 },
    { ISD::SRL,     MVT::v2i64,    1 },
    { ISD::SHL,     MVT::v4i64,    1 },
    { ISD::SRL,     MVT::v4i64,    1 },
  };

  if (ST->hasAVX512()) {
    if (ISD == ISD::SHL && LT.second == MVT::v32i16 &&
        (Op2Info == TargetTransformInfo::OK_UniformConstantValue ||
         Op2Info == TargetTransformInfo::OK_NonUniformConstantValue))
      // On AVX512, a packed v32i16 shift left by a constant build_vector
      // is lowered into a vector multiply (vpmullw).
      return getArithmeticInstrCost(Instruction::Mul, Ty, CostKind,
                                    Op1Info, Op2Info,
                                    TargetTransformInfo::OP_None,
                                    TargetTransformInfo::OP_None);
  }

  // Look for AVX2 lowering tricks.
  if (ST->hasAVX2()) {
    if (ISD == ISD::SHL && LT.second == MVT::v16i16 &&
        (Op2Info == TargetTransformInfo::OK_UniformConstantValue ||
         Op2Info == TargetTransformInfo::OK_NonUniformConstantValue))
      // On AVX2, a packed v16i16 shift left by a constant build_vector
      // is lowered into a vector multiply (vpmullw).
      return getArithmeticInstrCost(Instruction::Mul, Ty, CostKind,
                                    Op1Info, Op2Info,
                                    TargetTransformInfo::OP_None,
                                    TargetTransformInfo::OP_None);

    if (const auto *Entry = CostTableLookup(AVX2ShiftCostTable, ISD, LT.second))
      return LT.first * Entry->Cost;
  }

  static const CostTblEntry XOPShiftCostTable[] = {
    // 128bit shifts take 1cy, but right shifts require negation beforehand.
    { ISD::SHL,     MVT::v16i8,    1 },
    { ISD::SRL,     MVT::v16i8,    2 },
    { ISD::SRA,     MVT::v16i8,    2 },
    { ISD::SHL,     MVT::v8i16,    1 },
    { ISD::SRL,     MVT::v8i16,    2 },
    { ISD::SRA,     MVT::v8i16,    2 },
    { ISD::SHL,     MVT::v4i32,    1 },
    { ISD::SRL,     MVT::v4i32,    2 },
    { ISD::SRA,     MVT::v4i32,    2 },
    { ISD::SHL,     MVT::v2i64,    1 },
    { ISD::SRL,     MVT::v2i64,    2 },
    { ISD::SRA,     MVT::v2i64,    2 },
    // 256bit shifts require splitting if AVX2 didn't catch them above.
    { ISD::SHL,     MVT::v32i8,  2+2 },
    { ISD::SRL,     MVT::v32i8,  4+2 },
    { ISD::SRA,     MVT::v32i8,  4+2 },
    { ISD::SHL,     MVT::v16i16, 2+2 },
    { ISD::SRL,     MVT::v16i16, 4+2 },
    { ISD::SRA,     MVT::v16i16, 4+2 },
    { ISD::SHL,     MVT::v8i32,  2+2 },
    { ISD::SRL,     MVT::v8i32,  4+2 },
    { ISD::SRA,     MVT::v8i32,  4+2 },
    { ISD::SHL,     MVT::v4i64,  2+2 },
    { ISD::SRL,     MVT::v4i64,  4+2 },
    { ISD::SRA,     MVT::v4i64,  4+2 },
  };

  // Look for XOP lowering tricks.
  if (ST->hasXOP()) {
    // If the right shift is constant then we'll fold the negation so
    // it's as cheap as a left shift.
    int ShiftISD = ISD;
    if ((ShiftISD == ISD::SRL || ShiftISD == ISD::SRA) &&
        (Op2Info == TargetTransformInfo::OK_UniformConstantValue ||
         Op2Info == TargetTransformInfo::OK_NonUniformConstantValue))
      ShiftISD = ISD::SHL;
    if (const auto *Entry =
            CostTableLookup(XOPShiftCostTable, ShiftISD, LT.second))
      return LT.first * Entry->Cost;
  }

  static const CostTblEntry SSE2UniformShiftCostTable[] = {
    // Uniform splats are cheaper for the following instructions.
    { ISD::SHL,  MVT::v16i16, 2+2 }, // 2*psllw + split.
    { ISD::SHL,  MVT::v8i32,  2+2 }, // 2*pslld + split.
    { ISD::SHL,  MVT::v4i64,  2+2 }, // 2*psllq + split.

    { ISD::SRL,  MVT::v16i16, 2+2 }, // 2*psrlw + split.
    { ISD::SRL,  MVT::v8i32,  2+2 }, // 2*psrld + split.
    { ISD::SRL,  MVT::v4i64,  2+2 }, // 2*psrlq + split.

    { ISD::SRA,  MVT::v16i16, 2+2 }, // 2*psraw + split.
    { ISD::SRA,  MVT::v8i32,  2+2 }, // 2*psrad + split.
    { ISD::SRA,  MVT::v2i64,    4 }, // 2*psrad + shuffle.
    { ISD::SRA,  MVT::v4i64,  8+2 }, // 2*(2*psrad + shuffle) + split.
  };

  if (ST->hasSSE2() &&
      ((Op2Info == TargetTransformInfo::OK_UniformConstantValue) ||
       (Op2Info == TargetTransformInfo::OK_UniformValue))) {

    // Handle AVX2 uniform v4i64 ISD::SRA, it's not worth a table.
    if (ISD == ISD::SRA && LT.second == MVT::v4i64 && ST->hasAVX2())
      return LT.first * 4; // 2*psrad + shuffle.

    if (const auto *Entry =
            CostTableLookup(SSE2UniformShiftCostTable, ISD, LT.second))
      return LT.first * Entry->Cost;
  }

  if (ISD == ISD::SHL &&
      Op2Info == TargetTransformInfo::OK_NonUniformConstantValue) {
    MVT VT = LT.second;
    // Vector shift left by non uniform constant can be lowered
    // into vector multiply.
    if (((VT == MVT::v8i16 || VT == MVT::v4i32) && ST->hasSSE2()) ||
        ((VT == MVT::v16i16 || VT == MVT::v8i32) && ST->hasAVX()))
      ISD = ISD::MUL;
  }

  static const CostTblEntry AVX2CostTable[] = {
    { ISD::SHL,  MVT::v32i8,     11 }, // vpblendvb sequence.
    { ISD::SHL,  MVT::v64i8,     22 }, // 2*vpblendvb sequence.
    { ISD::SHL,  MVT::v16i16,    10 }, // extend/vpsrlvd/pack sequence.
    { ISD::SHL,  MVT::v32i16,    20 }, // 2*extend/vpsrlvd/pack sequence.

    { ISD::SRL,  MVT::v32i8,     11 }, // vpblendvb sequence.
    { ISD::SRL,  MVT::v64i8,     22 }, // 2*vpblendvb sequence.
    { ISD::SRL,  MVT::v16i16,    10 }, // extend/vpsrlvd/pack sequence.
    { ISD::SRL,  MVT::v32i16,    20 }, // 2*extend/vpsrlvd/pack sequence.

    { ISD::SRA,  MVT::v32i8,     24 }, // vpblendvb sequence.
    { ISD::SRA,  MVT::v64i8,     48 }, // 2*vpblendvb sequence.
    { ISD::SRA,  MVT::v16i16,    10 }, // extend/vpsravd/pack sequence.
    { ISD::SRA,  MVT::v32i16,    20 }, // 2*extend/vpsravd/pack sequence.
    { ISD::SRA,  MVT::v2i64,      4 }, // srl/xor/sub sequence.
    { ISD::SRA,  MVT::v4i64,      4 }, // srl/xor/sub sequence.

    { ISD::SUB,  MVT::v32i8,      1 }, // psubb
    { ISD::ADD,  MVT::v32i8,      1 }, // paddb
    { ISD::SUB,  MVT::v16i16,     1 }, // psubw
    { ISD::ADD,  MVT::v16i16,     1 }, // paddw
    { ISD::SUB,  MVT::v8i32,      1 }, // psubd
    { ISD::ADD,  MVT::v8i32,      1 }, // paddd
    { ISD::SUB,  MVT::v4i64,      1 }, // psubq
    { ISD::ADD,  MVT::v4i64,      1 }, // paddq

    { ISD::MUL,  MVT::v32i8,     17 }, // extend/pmullw/trunc sequence.
    { ISD::MUL,  MVT::v16i8,      7 }, // extend/pmullw/trunc sequence.
    { ISD::MUL,  MVT::v16i16,     1 }, // pmullw
    { ISD::MUL,  MVT::v8i32,      2 }, // pmulld (Haswell from agner.org)
    { ISD::MUL,  MVT::v4i64,      8 }, // 3*pmuludq/3*shift/2*add

    { ISD::FADD, MVT::v4f64,      1 }, // Haswell from http://www.agner.org/
    { ISD::FADD, MVT::v8f32,      1 }, // Haswell from http://www.agner.org/
    { ISD::FSUB, MVT::v4f64,      1 }, // Haswell from http://www.agner.org/
    { ISD::FSUB, MVT::v8f32,      1 }, // Haswell from http://www.agner.org/
    { ISD::FMUL, MVT::v4f64,      1 }, // Haswell from http://www.agner.org/
    { ISD::FMUL, MVT::v8f32,      1 }, // Haswell from http://www.agner.org/

    { ISD::FDIV, MVT::f32,        7 }, // Haswell from http://www.agner.org/
    { ISD::FDIV, MVT::v4f32,      7 }, // Haswell from http://www.agner.org/
    { ISD::FDIV, MVT::v8f32,     14 }, // Haswell from http://www.agner.org/
    { ISD::FDIV, MVT::f64,       14 }, // Haswell from http://www.agner.org/
    { ISD::FDIV, MVT::v2f64,     14 }, // Haswell from http://www.agner.org/
    { ISD::FDIV, MVT::v4f64,     28 }, // Haswell from http://www.agner.org/
  };

  // Look for AVX2 lowering tricks for custom cases.
  if (ST->hasAVX2())
    if (const auto *Entry = CostTableLookup(AVX2CostTable, ISD, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry AVX1CostTable[] = {
    // We don't have to scalarize unsupported ops. We can issue two half-sized
    // operations and we only need to extract the upper YMM half.
    // Two ops + 1 extract + 1 insert = 4.
    { ISD::MUL,     MVT::v16i16,     4 },
    { ISD::MUL,     MVT::v8i32,      4 },
    { ISD::SUB,     MVT::v32i8,      4 },
    { ISD::ADD,     MVT::v32i8,      4 },
    { ISD::SUB,     MVT::v16i16,     4 },
    { ISD::ADD,     MVT::v16i16,     4 },
    { ISD::SUB,     MVT::v8i32,      4 },
    { ISD::ADD,     MVT::v8i32,      4 },
    { ISD::SUB,     MVT::v4i64,      4 },
    { ISD::ADD,     MVT::v4i64,      4 },

    // A v4i64 multiply is custom lowered as two split v2i64 vectors that then
    // are lowered as a series of long multiplies(3), shifts(3) and adds(2)
    // Because we believe v4i64 to be a legal type, we must also include the
    // extract+insert in the cost table. Therefore, the cost here is 18
    // instead of 8.
    { ISD::MUL,     MVT::v4i64,     18 },

    { ISD::MUL,     MVT::v32i8,     26 }, // extend/pmullw/trunc sequence.

    { ISD::FDIV,    MVT::f32,       14 }, // SNB from http://www.agner.org/
    { ISD::FDIV,    MVT::v4f32,     14 }, // SNB from http://www.agner.org/
    { ISD::FDIV,    MVT::v8f32,     28 }, // SNB from http://www.agner.org/
    { ISD::FDIV,    MVT::f64,       22 }, // SNB from http://www.agner.org/
    { ISD::FDIV,    MVT::v2f64,     22 }, // SNB from http://www.agner.org/
    { ISD::FDIV,    MVT::v4f64,     44 }, // SNB from http://www.agner.org/
  };

  if (ST->hasAVX())
    if (const auto *Entry = CostTableLookup(AVX1CostTable, ISD, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry SSE42CostTable[] = {
    { ISD::FADD, MVT::f64,     1 }, // Nehalem from http://www.agner.org/
    { ISD::FADD, MVT::f32,     1 }, // Nehalem from http://www.agner.org/
    { ISD::FADD, MVT::v2f64,   1 }, // Nehalem from http://www.agner.org/
    { ISD::FADD, MVT::v4f32,   1 }, // Nehalem from http://www.agner.org/

    { ISD::FSUB, MVT::f64,     1 }, // Nehalem from http://www.agner.org/
    { ISD::FSUB, MVT::f32 ,    1 }, // Nehalem from http://www.agner.org/
    { ISD::FSUB, MVT::v2f64,   1 }, // Nehalem from http://www.agner.org/
    { ISD::FSUB, MVT::v4f32,   1 }, // Nehalem from http://www.agner.org/

    { ISD::FMUL, MVT::f64,     1 }, // Nehalem from http://www.agner.org/
    { ISD::FMUL, MVT::f32,     1 }, // Nehalem from http://www.agner.org/
    { ISD::FMUL, MVT::v2f64,   1 }, // Nehalem from http://www.agner.org/
    { ISD::FMUL, MVT::v4f32,   1 }, // Nehalem from http://www.agner.org/

    { ISD::FDIV,  MVT::f32,   14 }, // Nehalem from http://www.agner.org/
    { ISD::FDIV,  MVT::v4f32, 14 }, // Nehalem from http://www.agner.org/
    { ISD::FDIV,  MVT::f64,   22 }, // Nehalem from http://www.agner.org/
    { ISD::FDIV,  MVT::v2f64, 22 }, // Nehalem from http://www.agner.org/
  };

  if (ST->hasSSE42())
    if (const auto *Entry = CostTableLookup(SSE42CostTable, ISD, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry SSE41CostTable[] = {
    { ISD::SHL,  MVT::v16i8,      11 }, // pblendvb sequence.
    { ISD::SHL,  MVT::v32i8,  2*11+2 }, // pblendvb sequence + split.
    { ISD::SHL,  MVT::v8i16,      14 }, // pblendvb sequence.
    { ISD::SHL,  MVT::v16i16, 2*14+2 }, // pblendvb sequence + split.
    { ISD::SHL,  MVT::v4i32,       4 }, // pslld/paddd/cvttps2dq/pmulld
    { ISD::SHL,  MVT::v8i32,   2*4+2 }, // pslld/paddd/cvttps2dq/pmulld + split

    { ISD::SRL,  MVT::v16i8,      12 }, // pblendvb sequence.
    { ISD::SRL,  MVT::v32i8,  2*12+2 }, // pblendvb sequence + split.
    { ISD::SRL,  MVT::v8i16,      14 }, // pblendvb sequence.
    { ISD::SRL,  MVT::v16i16, 2*14+2 }, // pblendvb sequence + split.
    { ISD::SRL,  MVT::v4i32,      11 }, // Shift each lane + blend.
    { ISD::SRL,  MVT::v8i32,  2*11+2 }, // Shift each lane + blend + split.

    { ISD::SRA,  MVT::v16i8,      24 }, // pblendvb sequence.
    { ISD::SRA,  MVT::v32i8,  2*24+2 }, // pblendvb sequence + split.
    { ISD::SRA,  MVT::v8i16,      14 }, // pblendvb sequence.
    { ISD::SRA,  MVT::v16i16, 2*14+2 }, // pblendvb sequence + split.
    { ISD::SRA,  MVT::v4i32,      12 }, // Shift each lane + blend.
    { ISD::SRA,  MVT::v8i32,  2*12+2 }, // Shift each lane + blend + split.

    { ISD::MUL,  MVT::v4i32,       2 }  // pmulld (Nehalem from agner.org)
  };

  if (ST->hasSSE41())
    if (const auto *Entry = CostTableLookup(SSE41CostTable, ISD, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry SSE2CostTable[] = {
    // We don't correctly identify costs of casts because they are marked as
    // custom.
    { ISD::SHL,  MVT::v16i8,      26 }, // cmpgtb sequence.
    { ISD::SHL,  MVT::v8i16,      32 }, // cmpgtb sequence.
    { ISD::SHL,  MVT::v4i32,     2*5 }, // We optimized this using mul.
    { ISD::SHL,  MVT::v2i64,       4 }, // splat+shuffle sequence.
    { ISD::SHL,  MVT::v4i64,   2*4+2 }, // splat+shuffle sequence + split.

    { ISD::SRL,  MVT::v16i8,      26 }, // cmpgtb sequence.
    { ISD::SRL,  MVT::v8i16,      32 }, // cmpgtb sequence.
    { ISD::SRL,  MVT::v4i32,      16 }, // Shift each lane + blend.
    { ISD::SRL,  MVT::v2i64,       4 }, // splat+shuffle sequence.
    { ISD::SRL,  MVT::v4i64,   2*4+2 }, // splat+shuffle sequence + split.

    { ISD::SRA,  MVT::v16i8,      54 }, // unpacked cmpgtb sequence.
    { ISD::SRA,  MVT::v8i16,      32 }, // cmpgtb sequence.
    { ISD::SRA,  MVT::v4i32,      16 }, // Shift each lane + blend.
    { ISD::SRA,  MVT::v2i64,      12 }, // srl/xor/sub sequence.
    { ISD::SRA,  MVT::v4i64,  2*12+2 }, // srl/xor/sub sequence+split.

    { ISD::MUL,  MVT::v16i8,      12 }, // extend/pmullw/trunc sequence.
    { ISD::MUL,  MVT::v8i16,       1 }, // pmullw
    { ISD::MUL,  MVT::v4i32,       6 }, // 3*pmuludq/4*shuffle
    { ISD::MUL,  MVT::v2i64,       8 }, // 3*pmuludq/3*shift/2*add

    { ISD::FDIV, MVT::f32,        23 }, // Pentium IV from http://www.agner.org/
    { ISD::FDIV, MVT::v4f32,      39 }, // Pentium IV from http://www.agner.org/
    { ISD::FDIV, MVT::f64,        38 }, // Pentium IV from http://www.agner.org/
    { ISD::FDIV, MVT::v2f64,      69 }, // Pentium IV from http://www.agner.org/

    { ISD::FADD, MVT::f32,         2 }, // Pentium IV from http://www.agner.org/
    { ISD::FADD, MVT::f64,         2 }, // Pentium IV from http://www.agner.org/

    { ISD::FSUB, MVT::f32,         2 }, // Pentium IV from http://www.agner.org/
    { ISD::FSUB, MVT::f64,         2 }, // Pentium IV from http://www.agner.org/
  };

  if (ST->hasSSE2())
    if (const auto *Entry = CostTableLookup(SSE2CostTable, ISD, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry SSE1CostTable[] = {
    { ISD::FDIV, MVT::f32,   17 }, // Pentium III from http://www.agner.org/
    { ISD::FDIV, MVT::v4f32, 34 }, // Pentium III from http://www.agner.org/

    { ISD::FADD, MVT::f32,    1 }, // Pentium III from http://www.agner.org/
    { ISD::FADD, MVT::v4f32,  2 }, // Pentium III from http://www.agner.org/

    { ISD::FSUB, MVT::f32,    1 }, // Pentium III from http://www.agner.org/
    { ISD::FSUB, MVT::v4f32,  2 }, // Pentium III from http://www.agner.org/

    { ISD::ADD, MVT::i8,      1 }, // Pentium III from http://www.agner.org/
    { ISD::ADD, MVT::i16,     1 }, // Pentium III from http://www.agner.org/
    { ISD::ADD, MVT::i32,     1 }, // Pentium III from http://www.agner.org/

    { ISD::SUB, MVT::i8,      1 }, // Pentium III from http://www.agner.org/
    { ISD::SUB, MVT::i16,     1 }, // Pentium III from http://www.agner.org/
    { ISD::SUB, MVT::i32,     1 }, // Pentium III from http://www.agner.org/
  };

  if (ST->hasSSE1())
    if (const auto *Entry = CostTableLookup(SSE1CostTable, ISD, LT.second))
      return LT.first * Entry->Cost;

  // It is not a good idea to vectorize division. We have to scalarize it and
  // in the process we will often end up having to spilling regular
  // registers. The overhead of division is going to dominate most kernels
  // anyways so try hard to prevent vectorization of division - it is
  // generally a bad idea. Assume somewhat arbitrarily that we have to be able
  // to hide "20 cycles" for each lane.
  if (LT.second.isVector() && (ISD == ISD::SDIV || ISD == ISD::SREM ||
                               ISD == ISD::UDIV || ISD == ISD::UREM)) {
    int ScalarCost = getArithmeticInstrCost(
        Opcode, Ty->getScalarType(), CostKind, Op1Info, Op2Info,
        TargetTransformInfo::OP_None, TargetTransformInfo::OP_None);
    return 20 * LT.first * LT.second.getVectorNumElements() * ScalarCost;
  }

  // Fallback to the default implementation.
  return BaseT::getArithmeticInstrCost(Opcode, Ty, CostKind, Op1Info, Op2Info);
}

int X86TTIImpl::getShuffleCost(TTI::ShuffleKind Kind, VectorType *BaseTp,
                               int Index, VectorType *SubTp) {
  // 64-bit packed float vectors (v2f32) are widened to type v4f32.
  // 64-bit packed integer vectors (v2i32) are widened to type v4i32.
  std::pair<int, MVT> LT = TLI->getTypeLegalizationCost(DL, BaseTp);

  // Treat Transpose as 2-op shuffles - there's no difference in lowering.
  if (Kind == TTI::SK_Transpose)
    Kind = TTI::SK_PermuteTwoSrc;

  // For Broadcasts we are splatting the first element from the first input
  // register, so only need to reference that input and all the output
  // registers are the same.
  if (Kind == TTI::SK_Broadcast)
    LT.first = 1;

  // Subvector extractions are free if they start at the beginning of a
  // vector and cheap if the subvectors are aligned.
  if (Kind == TTI::SK_ExtractSubvector && LT.second.isVector()) {
    int NumElts = LT.second.getVectorNumElements();
    if ((Index % NumElts) == 0)
      return 0;
    std::pair<int, MVT> SubLT = TLI->getTypeLegalizationCost(DL, SubTp);
    if (SubLT.second.isVector()) {
      int NumSubElts = SubLT.second.getVectorNumElements();
      if ((Index % NumSubElts) == 0 && (NumElts % NumSubElts) == 0)
        return SubLT.first;
      // Handle some cases for widening legalization. For now we only handle
      // cases where the original subvector was naturally aligned and evenly
      // fit in its legalized subvector type.
      // FIXME: Remove some of the alignment restrictions.
      // FIXME: We can use permq for 64-bit or larger extracts from 256-bit
      // vectors.
      int OrigSubElts = cast<VectorType>(SubTp)->getNumElements();
      if (NumSubElts > OrigSubElts && (Index % OrigSubElts) == 0 &&
          (NumSubElts % OrigSubElts) == 0 &&
          LT.second.getVectorElementType() ==
              SubLT.second.getVectorElementType() &&
          LT.second.getVectorElementType().getSizeInBits() ==
              BaseTp->getElementType()->getPrimitiveSizeInBits()) {
        assert(NumElts >= NumSubElts && NumElts > OrigSubElts &&
               "Unexpected number of elements!");
        VectorType *VecTy = VectorType::get(BaseTp->getElementType(),
                                            LT.second.getVectorNumElements());
        VectorType *SubTy =
          VectorType::get(BaseTp->getElementType(),
                          SubLT.second.getVectorNumElements());
        int ExtractIndex = alignDown((Index % NumElts), NumSubElts);
        int ExtractCost = getShuffleCost(TTI::SK_ExtractSubvector, VecTy,
                                         ExtractIndex, SubTy);

        // If the original size is 32-bits or more, we can use pshufd. Otherwise
        // if we have SSSE3 we can use pshufb.
        if (SubTp->getPrimitiveSizeInBits() >= 32 || ST->hasSSSE3())
          return ExtractCost + 1; // pshufd or pshufb

        assert(SubTp->getPrimitiveSizeInBits() == 16 &&
               "Unexpected vector size");

        return ExtractCost + 2; // worst case pshufhw + pshufd
      }
    }
  }

  // Handle some common (illegal) sub-vector types as they are often very cheap
  // to shuffle even on targets without PSHUFB.
  EVT VT = TLI->getValueType(DL, BaseTp);
  if (VT.isSimple() && VT.isVector() && VT.getSizeInBits() < 128 &&
      !ST->hasSSSE3()) {
     static const CostTblEntry SSE2SubVectorShuffleTbl[] = {
      {TTI::SK_Broadcast,        MVT::v4i16, 1}, // pshuflw
      {TTI::SK_Broadcast,        MVT::v2i16, 1}, // pshuflw
      {TTI::SK_Broadcast,        MVT::v8i8,  2}, // punpck/pshuflw
      {TTI::SK_Broadcast,        MVT::v4i8,  2}, // punpck/pshuflw
      {TTI::SK_Broadcast,        MVT::v2i8,  1}, // punpck

      {TTI::SK_Reverse,          MVT::v4i16, 1}, // pshuflw
      {TTI::SK_Reverse,          MVT::v2i16, 1}, // pshuflw
      {TTI::SK_Reverse,          MVT::v4i8,  3}, // punpck/pshuflw/packus
      {TTI::SK_Reverse,          MVT::v2i8,  1}, // punpck

      {TTI::SK_PermuteTwoSrc,    MVT::v4i16, 2}, // punpck/pshuflw
      {TTI::SK_PermuteTwoSrc,    MVT::v2i16, 2}, // punpck/pshuflw
      {TTI::SK_PermuteTwoSrc,    MVT::v8i8,  7}, // punpck/pshuflw
      {TTI::SK_PermuteTwoSrc,    MVT::v4i8,  4}, // punpck/pshuflw
      {TTI::SK_PermuteTwoSrc,    MVT::v2i8,  2}, // punpck

      {TTI::SK_PermuteSingleSrc, MVT::v4i16, 1}, // pshuflw
      {TTI::SK_PermuteSingleSrc, MVT::v2i16, 1}, // pshuflw
      {TTI::SK_PermuteSingleSrc, MVT::v8i8,  5}, // punpck/pshuflw
      {TTI::SK_PermuteSingleSrc, MVT::v4i8,  3}, // punpck/pshuflw
      {TTI::SK_PermuteSingleSrc, MVT::v2i8,  1}, // punpck
    };

    if (ST->hasSSE2())
      if (const auto *Entry =
              CostTableLookup(SSE2SubVectorShuffleTbl, Kind, VT.getSimpleVT()))
        return Entry->Cost;
  }

  // We are going to permute multiple sources and the result will be in multiple
  // destinations. Providing an accurate cost only for splits where the element
  // type remains the same.
  if (Kind == TTI::SK_PermuteSingleSrc && LT.first != 1) {
    MVT LegalVT = LT.second;
    if (LegalVT.isVector() &&
        LegalVT.getVectorElementType().getSizeInBits() ==
            BaseTp->getElementType()->getPrimitiveSizeInBits() &&
        LegalVT.getVectorNumElements() < BaseTp->getNumElements()) {

      unsigned VecTySize = DL.getTypeStoreSize(BaseTp);
      unsigned LegalVTSize = LegalVT.getStoreSize();
      // Number of source vectors after legalization:
      unsigned NumOfSrcs = (VecTySize + LegalVTSize - 1) / LegalVTSize;
      // Number of destination vectors after legalization:
      unsigned NumOfDests = LT.first;

      VectorType *SingleOpTy =
        VectorType::get(BaseTp->getElementType(),
                        LegalVT.getVectorNumElements());

      unsigned NumOfShuffles = (NumOfSrcs - 1) * NumOfDests;
      return NumOfShuffles *
             getShuffleCost(TTI::SK_PermuteTwoSrc, SingleOpTy, 0, nullptr);
    }

    return BaseT::getShuffleCost(Kind, BaseTp, Index, SubTp);
  }

  // For 2-input shuffles, we must account for splitting the 2 inputs into many.
  if (Kind == TTI::SK_PermuteTwoSrc && LT.first != 1) {
    // We assume that source and destination have the same vector type.
    int NumOfDests = LT.first;
    int NumOfShufflesPerDest = LT.first * 2 - 1;
    LT.first = NumOfDests * NumOfShufflesPerDest;
  }

  static const CostTblEntry AVX512VBMIShuffleTbl[] = {
      {TTI::SK_Reverse, MVT::v64i8, 1}, // vpermb
      {TTI::SK_Reverse, MVT::v32i8, 1}, // vpermb

      {TTI::SK_PermuteSingleSrc, MVT::v64i8, 1}, // vpermb
      {TTI::SK_PermuteSingleSrc, MVT::v32i8, 1}, // vpermb

      {TTI::SK_PermuteTwoSrc, MVT::v64i8, 2}, // vpermt2b
      {TTI::SK_PermuteTwoSrc, MVT::v32i8, 2}, // vpermt2b
      {TTI::SK_PermuteTwoSrc, MVT::v16i8, 2}  // vpermt2b
  };

  if (ST->hasVBMI())
    if (const auto *Entry =
            CostTableLookup(AVX512VBMIShuffleTbl, Kind, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry AVX512BWShuffleTbl[] = {
      {TTI::SK_Broadcast, MVT::v32i16, 1}, // vpbroadcastw
      {TTI::SK_Broadcast, MVT::v64i8, 1},  // vpbroadcastb

      {TTI::SK_Reverse, MVT::v32i16, 2}, // vpermw
      {TTI::SK_Reverse, MVT::v16i16, 2}, // vpermw
      {TTI::SK_Reverse, MVT::v64i8, 2},  // pshufb + vshufi64x2

      {TTI::SK_PermuteSingleSrc, MVT::v32i16, 2}, // vpermw
      {TTI::SK_PermuteSingleSrc, MVT::v16i16, 2}, // vpermw
      {TTI::SK_PermuteSingleSrc, MVT::v64i8, 8},  // extend to v32i16

      {TTI::SK_PermuteTwoSrc, MVT::v32i16, 2}, // vpermt2w
      {TTI::SK_PermuteTwoSrc, MVT::v16i16, 2}, // vpermt2w
      {TTI::SK_PermuteTwoSrc, MVT::v8i16, 2},  // vpermt2w
      {TTI::SK_PermuteTwoSrc, MVT::v64i8, 19}, // 6 * v32i8 + 1
  };

  if (ST->hasBWI())
    if (const auto *Entry =
            CostTableLookup(AVX512BWShuffleTbl, Kind, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry AVX512ShuffleTbl[] = {
      {TTI::SK_Broadcast, MVT::v8f64, 1},  // vbroadcastpd
      {TTI::SK_Broadcast, MVT::v16f32, 1}, // vbroadcastps
      {TTI::SK_Broadcast, MVT::v8i64, 1},  // vpbroadcastq
      {TTI::SK_Broadcast, MVT::v16i32, 1}, // vpbroadcastd
      {TTI::SK_Broadcast, MVT::v32i16, 1}, // vpbroadcastw
      {TTI::SK_Broadcast, MVT::v64i8, 1},  // vpbroadcastb

      {TTI::SK_Reverse, MVT::v8f64, 1},  // vpermpd
      {TTI::SK_Reverse, MVT::v16f32, 1}, // vpermps
      {TTI::SK_Reverse, MVT::v8i64, 1},  // vpermq
      {TTI::SK_Reverse, MVT::v16i32, 1}, // vpermd

      {TTI::SK_PermuteSingleSrc, MVT::v8f64, 1},  // vpermpd
      {TTI::SK_PermuteSingleSrc, MVT::v4f64, 1},  // vpermpd
      {TTI::SK_PermuteSingleSrc, MVT::v2f64, 1},  // vpermpd
      {TTI::SK_PermuteSingleSrc, MVT::v16f32, 1}, // vpermps
      {TTI::SK_PermuteSingleSrc, MVT::v8f32, 1},  // vpermps
      {TTI::SK_PermuteSingleSrc, MVT::v4f32, 1},  // vpermps
      {TTI::SK_PermuteSingleSrc, MVT::v8i64, 1},  // vpermq
      {TTI::SK_PermuteSingleSrc, MVT::v4i64, 1},  // vpermq
      {TTI::SK_PermuteSingleSrc, MVT::v2i64, 1},  // vpermq
      {TTI::SK_PermuteSingleSrc, MVT::v16i32, 1}, // vpermd
      {TTI::SK_PermuteSingleSrc, MVT::v8i32, 1},  // vpermd
      {TTI::SK_PermuteSingleSrc, MVT::v4i32, 1},  // vpermd
      {TTI::SK_PermuteSingleSrc, MVT::v16i8, 1},  // pshufb

      {TTI::SK_PermuteTwoSrc, MVT::v8f64, 1},  // vpermt2pd
      {TTI::SK_PermuteTwoSrc, MVT::v16f32, 1}, // vpermt2ps
      {TTI::SK_PermuteTwoSrc, MVT::v8i64, 1},  // vpermt2q
      {TTI::SK_PermuteTwoSrc, MVT::v16i32, 1}, // vpermt2d
      {TTI::SK_PermuteTwoSrc, MVT::v4f64, 1},  // vpermt2pd
      {TTI::SK_PermuteTwoSrc, MVT::v8f32, 1},  // vpermt2ps
      {TTI::SK_PermuteTwoSrc, MVT::v4i64, 1},  // vpermt2q
      {TTI::SK_PermuteTwoSrc, MVT::v8i32, 1},  // vpermt2d
      {TTI::SK_PermuteTwoSrc, MVT::v2f64, 1},  // vpermt2pd
      {TTI::SK_PermuteTwoSrc, MVT::v4f32, 1},  // vpermt2ps
      {TTI::SK_PermuteTwoSrc, MVT::v2i64, 1},  // vpermt2q
      {TTI::SK_PermuteTwoSrc, MVT::v4i32, 1},  // vpermt2d

      // FIXME: This just applies the type legalization cost rules above
      // assuming these completely split.
      {TTI::SK_PermuteSingleSrc, MVT::v32i16, 14},
      {TTI::SK_PermuteSingleSrc, MVT::v64i8,  14},
      {TTI::SK_PermuteTwoSrc,    MVT::v32i16, 42},
      {TTI::SK_PermuteTwoSrc,    MVT::v64i8,  42},
  };

  if (ST->hasAVX512())
    if (const auto *Entry = CostTableLookup(AVX512ShuffleTbl, Kind, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry AVX2ShuffleTbl[] = {
      {TTI::SK_Broadcast, MVT::v4f64, 1},  // vbroadcastpd
      {TTI::SK_Broadcast, MVT::v8f32, 1},  // vbroadcastps
      {TTI::SK_Broadcast, MVT::v4i64, 1},  // vpbroadcastq
      {TTI::SK_Broadcast, MVT::v8i32, 1},  // vpbroadcastd
      {TTI::SK_Broadcast, MVT::v16i16, 1}, // vpbroadcastw
      {TTI::SK_Broadcast, MVT::v32i8, 1},  // vpbroadcastb

      {TTI::SK_Reverse, MVT::v4f64, 1},  // vpermpd
      {TTI::SK_Reverse, MVT::v8f32, 1},  // vpermps
      {TTI::SK_Reverse, MVT::v4i64, 1},  // vpermq
      {TTI::SK_Reverse, MVT::v8i32, 1},  // vpermd
      {TTI::SK_Reverse, MVT::v16i16, 2}, // vperm2i128 + pshufb
      {TTI::SK_Reverse, MVT::v32i8, 2},  // vperm2i128 + pshufb

      {TTI::SK_Select, MVT::v16i16, 1}, // vpblendvb
      {TTI::SK_Select, MVT::v32i8, 1},  // vpblendvb

      {TTI::SK_PermuteSingleSrc, MVT::v4f64, 1},  // vpermpd
      {TTI::SK_PermuteSingleSrc, MVT::v8f32, 1},  // vpermps
      {TTI::SK_PermuteSingleSrc, MVT::v4i64, 1},  // vpermq
      {TTI::SK_PermuteSingleSrc, MVT::v8i32, 1},  // vpermd
      {TTI::SK_PermuteSingleSrc, MVT::v16i16, 4}, // vperm2i128 + 2*vpshufb
                                                  // + vpblendvb
      {TTI::SK_PermuteSingleSrc, MVT::v32i8, 4},  // vperm2i128 + 2*vpshufb
                                                  // + vpblendvb

      {TTI::SK_PermuteTwoSrc, MVT::v4f64, 3},  // 2*vpermpd + vblendpd
      {TTI::SK_PermuteTwoSrc, MVT::v8f32, 3},  // 2*vpermps + vblendps
      {TTI::SK_PermuteTwoSrc, MVT::v4i64, 3},  // 2*vpermq + vpblendd
      {TTI::SK_PermuteTwoSrc, MVT::v8i32, 3},  // 2*vpermd + vpblendd
      {TTI::SK_PermuteTwoSrc, MVT::v16i16, 7}, // 2*vperm2i128 + 4*vpshufb
                                               // + vpblendvb
      {TTI::SK_PermuteTwoSrc, MVT::v32i8, 7},  // 2*vperm2i128 + 4*vpshufb
                                               // + vpblendvb
  };

  if (ST->hasAVX2())
    if (const auto *Entry = CostTableLookup(AVX2ShuffleTbl, Kind, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry XOPShuffleTbl[] = {
      {TTI::SK_PermuteSingleSrc, MVT::v4f64, 2},  // vperm2f128 + vpermil2pd
      {TTI::SK_PermuteSingleSrc, MVT::v8f32, 2},  // vperm2f128 + vpermil2ps
      {TTI::SK_PermuteSingleSrc, MVT::v4i64, 2},  // vperm2f128 + vpermil2pd
      {TTI::SK_PermuteSingleSrc, MVT::v8i32, 2},  // vperm2f128 + vpermil2ps
      {TTI::SK_PermuteSingleSrc, MVT::v16i16, 4}, // vextractf128 + 2*vpperm
                                                  // + vinsertf128
      {TTI::SK_PermuteSingleSrc, MVT::v32i8, 4},  // vextractf128 + 2*vpperm
                                                  // + vinsertf128

      {TTI::SK_PermuteTwoSrc, MVT::v16i16, 9}, // 2*vextractf128 + 6*vpperm
                                               // + vinsertf128
      {TTI::SK_PermuteTwoSrc, MVT::v8i16, 1},  // vpperm
      {TTI::SK_PermuteTwoSrc, MVT::v32i8, 9},  // 2*vextractf128 + 6*vpperm
                                               // + vinsertf128
      {TTI::SK_PermuteTwoSrc, MVT::v16i8, 1},  // vpperm
  };

  if (ST->hasXOP())
    if (const auto *Entry = CostTableLookup(XOPShuffleTbl, Kind, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry AVX1ShuffleTbl[] = {
      {TTI::SK_Broadcast, MVT::v4f64, 2},  // vperm2f128 + vpermilpd
      {TTI::SK_Broadcast, MVT::v8f32, 2},  // vperm2f128 + vpermilps
      {TTI::SK_Broadcast, MVT::v4i64, 2},  // vperm2f128 + vpermilpd
      {TTI::SK_Broadcast, MVT::v8i32, 2},  // vperm2f128 + vpermilps
      {TTI::SK_Broadcast, MVT::v16i16, 3}, // vpshuflw + vpshufd + vinsertf128
      {TTI::SK_Broadcast, MVT::v32i8, 2},  // vpshufb + vinsertf128

      {TTI::SK_Reverse, MVT::v4f64, 2},  // vperm2f128 + vpermilpd
      {TTI::SK_Reverse, MVT::v8f32, 2},  // vperm2f128 + vpermilps
      {TTI::SK_Reverse, MVT::v4i64, 2},  // vperm2f128 + vpermilpd
      {TTI::SK_Reverse, MVT::v8i32, 2},  // vperm2f128 + vpermilps
      {TTI::SK_Reverse, MVT::v16i16, 4}, // vextractf128 + 2*pshufb
                                         // + vinsertf128
      {TTI::SK_Reverse, MVT::v32i8, 4},  // vextractf128 + 2*pshufb
                                         // + vinsertf128

      {TTI::SK_Select, MVT::v4i64, 1},  // vblendpd
      {TTI::SK_Select, MVT::v4f64, 1},  // vblendpd
      {TTI::SK_Select, MVT::v8i32, 1},  // vblendps
      {TTI::SK_Select, MVT::v8f32, 1},  // vblendps
      {TTI::SK_Select, MVT::v16i16, 3}, // vpand + vpandn + vpor
      {TTI::SK_Select, MVT::v32i8, 3},  // vpand + vpandn + vpor

      {TTI::SK_PermuteSingleSrc, MVT::v4f64, 2},  // vperm2f128 + vshufpd
      {TTI::SK_PermuteSingleSrc, MVT::v4i64, 2},  // vperm2f128 + vshufpd
      {TTI::SK_PermuteSingleSrc, MVT::v8f32, 4},  // 2*vperm2f128 + 2*vshufps
      {TTI::SK_PermuteSingleSrc, MVT::v8i32, 4},  // 2*vperm2f128 + 2*vshufps
      {TTI::SK_PermuteSingleSrc, MVT::v16i16, 8}, // vextractf128 + 4*pshufb
                                                  // + 2*por + vinsertf128
      {TTI::SK_PermuteSingleSrc, MVT::v32i8, 8},  // vextractf128 + 4*pshufb
                                                  // + 2*por + vinsertf128

      {TTI::SK_PermuteTwoSrc, MVT::v4f64, 3},   // 2*vperm2f128 + vshufpd
      {TTI::SK_PermuteTwoSrc, MVT::v4i64, 3},   // 2*vperm2f128 + vshufpd
      {TTI::SK_PermuteTwoSrc, MVT::v8f32, 4},   // 2*vperm2f128 + 2*vshufps
      {TTI::SK_PermuteTwoSrc, MVT::v8i32, 4},   // 2*vperm2f128 + 2*vshufps
      {TTI::SK_PermuteTwoSrc, MVT::v16i16, 15}, // 2*vextractf128 + 8*pshufb
                                                // + 4*por + vinsertf128
      {TTI::SK_PermuteTwoSrc, MVT::v32i8, 15},  // 2*vextractf128 + 8*pshufb
                                                // + 4*por + vinsertf128
  };

  if (ST->hasAVX())
    if (const auto *Entry = CostTableLookup(AVX1ShuffleTbl, Kind, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry SSE41ShuffleTbl[] = {
      {TTI::SK_Select, MVT::v2i64, 1}, // pblendw
      {TTI::SK_Select, MVT::v2f64, 1}, // movsd
      {TTI::SK_Select, MVT::v4i32, 1}, // pblendw
      {TTI::SK_Select, MVT::v4f32, 1}, // blendps
      {TTI::SK_Select, MVT::v8i16, 1}, // pblendw
      {TTI::SK_Select, MVT::v16i8, 1}  // pblendvb
  };

  if (ST->hasSSE41())
    if (const auto *Entry = CostTableLookup(SSE41ShuffleTbl, Kind, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry SSSE3ShuffleTbl[] = {
      {TTI::SK_Broadcast, MVT::v8i16, 1}, // pshufb
      {TTI::SK_Broadcast, MVT::v16i8, 1}, // pshufb

      {TTI::SK_Reverse, MVT::v8i16, 1}, // pshufb
      {TTI::SK_Reverse, MVT::v16i8, 1}, // pshufb

      {TTI::SK_Select, MVT::v8i16, 3}, // 2*pshufb + por
      {TTI::SK_Select, MVT::v16i8, 3}, // 2*pshufb + por

      {TTI::SK_PermuteSingleSrc, MVT::v8i16, 1}, // pshufb
      {TTI::SK_PermuteSingleSrc, MVT::v16i8, 1}, // pshufb

      {TTI::SK_PermuteTwoSrc, MVT::v8i16, 3}, // 2*pshufb + por
      {TTI::SK_PermuteTwoSrc, MVT::v16i8, 3}, // 2*pshufb + por
  };

  if (ST->hasSSSE3())
    if (const auto *Entry = CostTableLookup(SSSE3ShuffleTbl, Kind, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry SSE2ShuffleTbl[] = {
      {TTI::SK_Broadcast, MVT::v2f64, 1}, // shufpd
      {TTI::SK_Broadcast, MVT::v2i64, 1}, // pshufd
      {TTI::SK_Broadcast, MVT::v4i32, 1}, // pshufd
      {TTI::SK_Broadcast, MVT::v8i16, 2}, // pshuflw + pshufd
      {TTI::SK_Broadcast, MVT::v16i8, 3}, // unpck + pshuflw + pshufd

      {TTI::SK_Reverse, MVT::v2f64, 1}, // shufpd
      {TTI::SK_Reverse, MVT::v2i64, 1}, // pshufd
      {TTI::SK_Reverse, MVT::v4i32, 1}, // pshufd
      {TTI::SK_Reverse, MVT::v8i16, 3}, // pshuflw + pshufhw + pshufd
      {TTI::SK_Reverse, MVT::v16i8, 9}, // 2*pshuflw + 2*pshufhw
                                        // + 2*pshufd + 2*unpck + packus

      {TTI::SK_Select, MVT::v2i64, 1}, // movsd
      {TTI::SK_Select, MVT::v2f64, 1}, // movsd
      {TTI::SK_Select, MVT::v4i32, 2}, // 2*shufps
      {TTI::SK_Select, MVT::v8i16, 3}, // pand + pandn + por
      {TTI::SK_Select, MVT::v16i8, 3}, // pand + pandn + por

      {TTI::SK_PermuteSingleSrc, MVT::v2f64, 1}, // shufpd
      {TTI::SK_PermuteSingleSrc, MVT::v2i64, 1}, // pshufd
      {TTI::SK_PermuteSingleSrc, MVT::v4i32, 1}, // pshufd
      {TTI::SK_PermuteSingleSrc, MVT::v8i16, 5}, // 2*pshuflw + 2*pshufhw
                                                  // + pshufd/unpck
    { TTI::SK_PermuteSingleSrc, MVT::v16i8, 10 }, // 2*pshuflw + 2*pshufhw
                                                  // + 2*pshufd + 2*unpck + 2*packus

    { TTI::SK_PermuteTwoSrc,    MVT::v2f64,  1 }, // shufpd
    { TTI::SK_PermuteTwoSrc,    MVT::v2i64,  1 }, // shufpd
    { TTI::SK_PermuteTwoSrc,    MVT::v4i32,  2 }, // 2*{unpck,movsd,pshufd}
    { TTI::SK_PermuteTwoSrc,    MVT::v8i16,  8 }, // blend+permute
    { TTI::SK_PermuteTwoSrc,    MVT::v16i8, 13 }, // blend+permute
  };

  if (ST->hasSSE2())
    if (const auto *Entry = CostTableLookup(SSE2ShuffleTbl, Kind, LT.second))
      return LT.first * Entry->Cost;

  static const CostTblEntry SSE1ShuffleTbl[] = {
    { TTI::SK_Broadcast,        MVT::v4f32, 1 }, // shufps
    { TTI::SK_Reverse,          MVT::v4f32, 1 }, // shufps
    { TTI::SK_Select,           MVT::v4f32, 2 }, // 2*shufps
    { TTI::SK_PermuteSingleSrc, MVT::v4f32, 1 }, // shufps
    { TTI::SK_PermuteTwoSrc,    MVT::v4f32, 2 }, // 2*shufps
  };

  if (ST->hasSSE1())
    if (const auto *Entry = CostTableLookup(SSE1ShuffleTbl, Kind, LT.second))
      return LT.first * Entry->Cost;

  return BaseT::getShuffleCost(Kind, BaseTp, Index, SubTp);
}

int X86TTIImpl::getCastInstrCost(unsigned Opcode, Type *Dst, Type *Src,
                                 TTI::TargetCostKind CostKind,
                                 const Instruction *I) {
  int ISD = TLI->InstructionOpcodeToISD(Opcode);
  assert(ISD && "Invalid opcode");

  // TODO: Allow non-throughput costs that aren't binary.
  auto AdjustCost = [&CostKind](int Cost) {
    if (CostKind != TTI::TCK_RecipThroughput)
      return Cost == 0 ? 0 : 1;
    return Cost;
  };

  // FIXME: Need a better design of the cost table to handle non-simple types of
  // potential massive combinations (elem_num x src_type x dst_type).

  static const TypeConversionCostTblEntry AVX512BWConversionTbl[] {
    { ISD::SIGN_EXTEND, MVT::v32i16, MVT::v32i8, 1 },
    { ISD::ZERO_EXTEND, MVT::v32i16, MVT::v32i8, 1 },

    // Mask sign extend has an instruction.
    { ISD::SIGN_EXTEND, MVT::v2i8,   MVT::v2i1,  1 },
    { ISD::SIGN_EXTEND, MVT::v2i16,  MVT::v2i1,  1 },
    { ISD::SIGN_EXTEND, MVT::v4i8,   MVT::v4i1,  1 },
    { ISD::SIGN_EXTEND, MVT::v4i16,  MVT::v4i1,  1 },
    { ISD::SIGN_EXTEND, MVT::v8i8,   MVT::v8i1,  1 },
    { ISD::SIGN_EXTEND, MVT::v8i16,  MVT::v8i1,  1 },
    { ISD::SIGN_EXTEND, MVT::v16i8,  MVT::v16i1, 1 },
    { ISD::SIGN_EXTEND, MVT::v16i16, MVT::v16i1, 1 },
    { ISD::SIGN_EXTEND, MVT::v32i8,  MVT::v32i1, 1 },
    { ISD::SIGN_EXTEND, MVT::v32i16, MVT::v32i1, 1 },
    { ISD::SIGN_EXTEND, MVT::v64i8,  MVT::v64i1, 1 },

    // Mask zero extend is a sext + shift.
    { ISD::ZERO_EXTEND, MVT::v2i8,   MVT::v2i1,  2 },
    { ISD::ZERO_EXTEND, MVT::v2i16,  MVT::v2i1,  2 },
    { ISD::ZERO_EXTEND, MVT::v4i8,   MVT::v4i1,  2 },
    { ISD::ZERO_EXTEND, MVT::v4i16,  MVT::v4i1,  2 },
    { ISD::ZERO_EXTEND, MVT::v8i8,   MVT::v8i1,  2 },
    { ISD::ZERO_EXTEND, MVT::v8i16,  MVT::v8i1,  2 },
    { ISD::ZERO_EXTEND, MVT::v16i8,  MVT::v16i1, 2 },
    { ISD::ZERO_EXTEND, MVT::v16i16, MVT::v16i1, 2 },
    { ISD::ZERO_EXTEND, MVT::v32i8,  MVT::v32i1, 2 },
    { ISD::ZERO_EXTEND, MVT::v32i16, MVT::v32i1, 2 },
    { ISD::ZERO_EXTEND, MVT::v64i8,  MVT::v64i1, 2 },

    { ISD::TRUNCATE,    MVT::v32i8,  MVT::v32i16, 2 },
    { ISD::TRUNCATE,    MVT::v16i8,  MVT::v16i16, 2 }, // widen to zmm
    { ISD::TRUNCATE,    MVT::v2i1,   MVT::v2i8,   2 }, // widen to zmm
    { ISD::TRUNCATE,    MVT::v2i1,   MVT::v2i16,  2 }, // widen to zmm
    { ISD::TRUNCATE,    MVT::v4i1,   MVT::v4i8,   2 }, // widen to zmm
    { ISD::TRUNCATE,    MVT::v4i1,   MVT::v4i16,  2 }, // widen to zmm
    { ISD::TRUNCATE,    MVT::v8i1,   MVT::v8i8,   2 }, // widen to zmm
    { ISD::TRUNCATE,    MVT::v8i1,   MVT::v8i16,  2 }, // widen to zmm
    { ISD::TRUNCATE,    MVT::v16i1,  MVT::v16i8,  2 }, // widen to zmm
    { ISD::TRUNCATE,    MVT::v16i1,  MVT::v16i16, 2 }, // widen to zmm
    { ISD::TRUNCATE,    MVT::v32i1,  MVT::v32i8,  2 }, // widen to zmm
    { ISD::TRUNCATE,    MVT::v32i1,  MVT::v32i16, 2 },
    { ISD::TRUNCATE,    MVT::v64i1,  MVT::v64i8,  2 },
  };

  static const TypeConversionCostTblEntry AVX512DQConversionTbl[] = {
    { ISD::SINT_TO_FP,  MVT::v8f32,  MVT::v8i64,  1 },
    { ISD::SINT_TO_FP,  MVT::v8f64,  MVT::v8i64,  1 },

    { ISD::UINT_TO_FP,  MVT::v8f32,  MVT::v8i64,  1 },
    { ISD::UINT_TO_FP,  MVT::v8f64,  MVT::v8i64,  1 },

    { ISD::FP_TO_SINT,  MVT::v8i64,  MVT::v8f32,  1 },
    { ISD::FP_TO_SINT,  MVT::v8i64,  MVT::v8f64,  1 },

    { ISD::FP_TO_UINT,  MVT::v8i64,  MVT::v8f32,  1 },
    { ISD::FP_TO_UINT,  MVT::v8i64,  MVT::v8f64,  1 },
  };

  // TODO: For AVX512DQ + AVX512VL, we also have cheap casts for 128-bit and
  // 256-bit wide vectors.

  static const TypeConversionCostTblEntry AVX512FConversionTbl[] = {
    { ISD::FP_EXTEND, MVT::v8f64,   MVT::v8f32,  1 },
    { ISD::FP_EXTEND, MVT::v8f64,   MVT::v16f32, 3 },
    { ISD::FP_ROUND,  MVT::v8f32,   MVT::v8f64,  1 },

    { ISD::TRUNCATE,  MVT::v2i1,    MVT::v2i8,   3 }, // sext+vpslld+vptestmd
    { ISD::TRUNCATE,  MVT::v4i1,    MVT::v4i8,   3 }, // sext+vpslld+vptestmd
    { ISD::TRUNCATE,  MVT::v8i1,    MVT::v8i8,   3 }, // sext+vpslld+vptestmd
    { ISD::TRUNCATE,  MVT::v16i1,   MVT::v16i8,  3 }, // sext+vpslld+vptestmd
    { ISD::TRUNCATE,  MVT::v2i1,    MVT::v2i16,  3 }, // sext+vpsllq+vptestmq
    { ISD::TRUNCATE,  MVT::v4i1,    MVT::v4i16,  3 }, // sext+vpsllq+vptestmq
    { ISD::TRUNCATE,  MVT::v8i1,    MVT::v8i16,  3 }, // sext+vpsllq+vptestmq
    { ISD::TRUNCATE,  MVT::v16i1,   MVT::v16i16, 3 }, // sext+vpslld+vptestmd
    { ISD::TRUNCATE,  MVT::v2i1,    MVT::v2i32,  2 }, // zmm vpslld+vptestmd
    { ISD::TRUNCATE,  MVT::v4i1,    MVT::v4i32,  2 }, // zmm vpslld+vptestmd
    { ISD::TRUNCATE,  MVT::v8i1,    MVT::v8i32,  2 }, // zmm vpslld+vptestmd
    { ISD::TRUNCATE,  MVT::v16i1,   MVT::v16i32, 2 }, // vpslld+vptestmd
    { ISD::TRUNCATE,  MVT::v2i1,    MVT::v2i64,  2 }, // zmm vpsllq+vptestmq
    { ISD::TRUNCATE,  MVT::v4i1,    MVT::v4i64,  2 }, // zmm vpsllq+vptestmq
    { ISD::TRUNCATE,  MVT::v8i1,    MVT::v8i64,  2 }, // vpsllq+vptestmq
    { ISD::TRUNCATE,  MVT::v16i8,   MVT::v16i32, 2 },
    { ISD::TRUNCATE,  MVT::v16i16,  MVT::v16i32, 2 },
    { ISD::TRUNCATE,  MVT::v8i8,    MVT::v8i64,  2 },
    { ISD::TRUNCATE,  MVT::v8i16,   MVT::v8i64,  2 },
    { ISD::TRUNCATE,  MVT::v8i32,   MVT::v8i64,  1 },
    { ISD::TRUNCATE,  MVT::v4i32,   MVT::v4i64,  1 }, // zmm vpmovqd
    { ISD::TRUNCATE,  MVT::v16i8,   MVT::v16i64, 5 },// 2*vpmovqd+concat+vpmovdb

    { ISD::TRUNCATE,  MVT::v16i8,  MVT::v16i16,  3 }, // extend to v16i32
    { ISD::TRUNCATE,  MVT::v32i8,  MVT::v32i16,  8 },

    // Sign extend is zmm vpternlogd+vptruncdb.
    // Zero extend is zmm broadcast load+vptruncdw.
    { ISD::SIGN_EXTEND, MVT::v2i8,   MVT::v2i1,   3 },
    { ISD::ZERO_EXTEND, MVT::v2i8,   MVT::v2i1,   4 },
    { ISD::SIGN_EXTEND, MVT::v4i8,   MVT::v4i1,   3 },
    { ISD::ZERO_EXTEND, MVT::v4i8,   MVT::v4i1,   4 },
    { ISD::SIGN_EXTEND, MVT::v8i8,   MVT::v8i1,   3 },
    { ISD::ZERO_EXTEND, MVT::v8i8,   MVT::v8i1,   4 },
    { ISD::SIGN_EXTEND, MVT::v16i8,  MVT::v16i1,  3 },
    { ISD::ZERO_EXTEND, MVT::v16i8,  MVT::v16i1,  4 },

    // Sign extend is zmm vpternlogd+vptruncdw.
    // Zero extend is zmm vpternlogd+vptruncdw+vpsrlw.
    { ISD::SIGN_EXTEND, MVT::v2i16,  MVT::v2i1,   3 },
    { ISD::ZERO_EXTEND, MVT::v2i16,  MVT::v2i1,   4 },
    { ISD::SIGN_EXTEND, MVT::v4i16,  MVT::v4i1,   3 },
    { ISD::ZERO_EXTEND, MVT::v4i16,  MVT::v4i1,   4 },
    { ISD::SIGN_EXTEND, MVT::v8i16,  MVT::v8i1,   3 },
    { ISD::ZERO_EXTEND, MVT::v8i16,  MVT::v8i1,   4 },
    { ISD::SIGN_EXTEND, MVT::v16i16, MVT::v16i1,  3 },
    { ISD::ZERO_EXTEND, MVT::v16i16, MVT::v16i1,  4 },

    { ISD::SIGN_EXTEND, MVT::v2i32,  MVT::v2i1,   1 }, // zmm vpternlogd
    { ISD::ZERO_EXTEND, MVT::v2i32,  MVT::v2i1,   2 }, // zmm vpternlogd+psrld
    { ISD::SIGN_EXTEND, MVT::v4i32,  MVT::v4i1,   1 }, // zmm vpternlogd
    { ISD::ZERO_EXTEND, MVT::v4i32,  MVT::v4i1,   2 }, // zmm vpternlogd+psrld
    { ISD::SIGN_EXTEND, MVT::v8i32,  MVT::v8i1,   1 }, // zmm vpternlogd
    { ISD::ZERO_EXTEND, MVT::v8i32,  MVT::v8i1,   2 }, // zmm vpternlogd+psrld
    { ISD::SIGN_EXTEND, MVT::v2i64,  MVT::v2i1,   1 }, // zmm vpternlogq
    { ISD::ZERO_EXTEND, MVT::v2i64,  MVT::v2i1,   2 }, // zmm vpternlogq+psrlq
    { ISD::SIGN_EXTEND, MVT::v4i64,  MVT::v4i1,   1 }, // zmm vpternlogq
    { ISD::ZERO_EXTEND, MVT::v4i64,  MVT::v4i1,   2 }, // zmm vpternlogq+psrlq

    { ISD::SIGN_EXTEND, MVT::v16i32, MVT::v16i1,  1 }, // vpternlogd
    { ISD::ZERO_EXTEND, MVT::v16i32, MVT::v16i1,  2 }, // vpternlogd+psrld
    { ISD::SIGN_EXTEND, MVT::v8i64,  MVT::v8i1,   1 }, // vpternlogq
    { ISD::ZERO_EXTEND, MVT::v8i64,  MVT::v8i1,   2 }, // vpternlogq+psrlq

    { ISD::SIGN_EXTEND, MVT::v16i32, MVT::v16i8,  1 },
    { ISD::ZERO_EXTEND, MVT::v16i32, MVT::v16i8,  1 },
    { ISD::SIGN_EXTEND, MVT::v16i32, MVT::v16i16, 1 },
    { ISD::ZERO_EXTEND, MVT::v16i32, MVT::v16i16, 1 },
    { ISD::SIGN_EXTEND, MVT::v8i64,  MVT::v8i8,   1 },
    { ISD::ZERO_EXTEND, MVT::v8i64,  MVT::v8i8,   1 },
    { ISD::SIGN_EXTEND, MVT::v8i64,  MVT::v8i16,  1 },
    { ISD::ZERO_EXTEND, MVT::v8i64,  MVT::v8i16,  1 },
    { ISD::SIGN_EXTEND, MVT::v8i64,  MVT::v8i32,  1 },
    { ISD::ZERO_EXTEND, MVT::v8i64,  MVT::v8i32,  1 },

    { ISD::SIGN_EXTEND, MVT::v32i16, MVT::v32i8, 3 }, // FIXME: May not be right
    { ISD::ZERO_EXTEND, MVT::v32i16, MVT::v32i8, 3 }, // FIXME: May not be right

    { ISD::SINT_TO_FP,  MVT::v8f64,  MVT::v8i1,   4 },
    { ISD::SINT_TO_FP,  MVT::v16f32, MVT::v16i1,  3 },
    { ISD::SINT_TO_FP,  MVT::v8f64,  MVT::v8i8,   2 },
    { ISD::SINT_TO_FP,  MVT::v16f32, MVT::v16i8,  2 },
    { ISD::SINT_TO_FP,  MVT::v8f64,  MVT::v8i16,  2 },
    { ISD::SINT_TO_FP,  MVT::v16f32, MVT::v16i16, 2 },
    { ISD::SINT_TO_FP,  MVT::v16f32, MVT::v16i32, 1 },
    { ISD::SINT_TO_FP,  MVT::v8f64,  MVT::v8i32,  1 },

    { ISD::UINT_TO_FP,  MVT::v8f64,  MVT::v8i1,   4 },
    { ISD::UINT_TO_FP,  MVT::v16f32, MVT::v16i1,  3 },
    { ISD::UINT_TO_FP,  MVT::v8f64,  MVT::v8i8,   2 },
    { ISD::UINT_TO_FP,  MVT::v16f32, MVT::v16i8,  2 },
    { ISD::UINT_TO_FP,  MVT::v8f64,  MVT::v8i16,  2 },
    { ISD::UINT_TO_FP,  MVT::v16f32, MVT::v16i16, 2 },
    { ISD::UINT_TO_FP,  MVT::v8f64,  MVT::v8i32,  1 },
    { ISD::UINT_TO_FP,  MVT::v16f32, MVT::v16i32, 1 },
    { ISD::UINT_TO_FP,  MVT::v8f32,  MVT::v8i64, 26 },
    { ISD::UINT_TO_FP,  MVT::v8f64,  MVT::v8i64,  5 },

    { ISD::FP_TO_SINT,  MVT::v8i8,   MVT::v8f64,  3 },
    { ISD::FP_TO_SINT,  MVT::v8i16,  MVT::v8f64,  3 },
    { ISD::FP_TO_SINT,  MVT::v16i8,  MVT::v16f32, 3 },
    { ISD::FP_TO_SINT,  MVT::v16i16, MVT::v16f32, 3 },

    { ISD::FP_TO_UINT,  MVT::v8i32,  MVT::v8f64,  1 },
    { ISD::FP_TO_UINT,  MVT::v8i16,  MVT::v8f64,  3 },
    { ISD::FP_TO_UINT,  MVT::v8i8,   MVT::v8f64,  3 },
    { ISD::FP_TO_UINT,  MVT::v16i32, MVT::v16f32, 1 },
    { ISD::FP_TO_UINT,  MVT::v16i16, MVT::v16f32, 3 },
    { ISD::FP_TO_UINT,  MVT::v16i8,  MVT::v16f32, 3 },
  };

  static const TypeConversionCostTblEntry AVX512BWVLConversionTbl[] {
    // Mask sign extend has an instruction.
    { ISD::SIGN_EXTEND, MVT::v2i8,   MVT::v2i1,  1 },
    { ISD::SIGN_EXTEND, MVT::v2i16,  MVT::v2i1,  1 },
    { ISD::SIGN_EXTEND, MVT::v4i8,   MVT::v4i1,  1 },
    { ISD::SIGN_EXTEND, MVT::v4i16,  MVT::v4i1,  1 },
    { ISD::SIGN_EXTEND, MVT::v8i8,   MVT::v8i1,  1 },
    { ISD::SIGN_EXTEND, MVT::v8i16,  MVT::v8i1,  1 },
    { ISD::SIGN_EXTEND, MVT::v16i8,  MVT::v16i1, 1 },
    { ISD::SIGN_EXTEND, MVT::v16i16, MVT::v16i1, 1 },
    { ISD::SIGN_EXTEND, MVT::v32i8,  MVT::v32i1, 1 },

    // Mask zero extend is a sext + shift.
    { ISD::ZERO_EXTEND, MVT::v2i8,   MVT::v2i1,  2 },
    { ISD::ZERO_EXTEND, MVT::v2i16,  MVT::v2i1,  2 },
    { ISD::ZERO_EXTEND, MVT::v4i8,   MVT::v4i1,  2 },
    { ISD::ZERO_EXTEND, MVT::v4i16,  MVT::v4i1,  2 },
    { ISD::ZERO_EXTEND, MVT::v8i8,   MVT::v8i1,  2 },
    { ISD::ZERO_EXTEND, MVT::v8i16,  MVT::v8i1,  2 },
    { ISD::ZERO_EXTEND, MVT::v16i8,  MVT::v16i1, 2 },
    { ISD::ZERO_EXTEND, MVT::v16i16, MVT::v16i1, 2 },
    { ISD::ZERO_EXTEND, MVT::v32i8,  MVT::v32i1, 2 },

    { ISD::TRUNCATE,    MVT::v16i8,  MVT::v16i16, 2 },
    { ISD::TRUNCATE,    MVT::v2i1,   MVT::v2i8,   2 }, // vpsllw+vptestmb
    { ISD::TRUNCATE,    MVT::v2i1,   MVT::v2i16,  2 }, // vpsllw+vptestmw
    { ISD::TRUNCATE,    MVT::v4i1,   MVT::v4i8,   2 }, // vpsllw+vptestmb
    { ISD::TRUNCATE,    MVT::v4i1,   MVT::v4i16,  2 }, // vpsllw+vptestmw
    { ISD::TRUNCATE,    MVT::v8i1,   MVT::v8i8,   2 }, // vpsllw+vptestmb
    { ISD::TRUNCATE,    MVT::v8i1,   MVT::v8i16,  2 }, // vpsllw+vptestmw
    { ISD::TRUNCATE,    MVT::v16i1,  MVT::v16i8,  2 }, // vpsllw+vptestmb
    { ISD::TRUNCATE,    MVT::v16i1,  MVT::v16i16, 2 }, // vpsllw+vptestmw
    { ISD::TRUNCATE,    MVT::v32i1,  MVT::v32i8,  2 }, // vpsllw+vptestmb
  };

  static const TypeConversionCostTblEntry AVX512DQVLConversionTbl[] = {
    { ISD::SINT_TO_FP,  MVT::v2f32,  MVT::v2i64,  1 },
    { ISD::SINT_TO_FP,  MVT::v2f64,  MVT::v2i64,  1 },
    { ISD::SINT_TO_FP,  MVT::v4f32,  MVT::v4i64,  1 },
    { ISD::SINT_TO_FP,  MVT::v4f64,  MVT::v4i64,  1 },

    { ISD::UINT_TO_FP,  MVT::v2f32,  MVT::v2i64,  1 },
    { ISD::UINT_TO_FP,  MVT::v2f64,  MVT::v2i64,  1 },
    { ISD::UINT_TO_FP,  MVT::v4f32,  MVT::v4i64,  1 },
    { ISD::UINT_TO_FP,  MVT::v4f64,  MVT::v4i64,  1 },

    { ISD::FP_TO_SINT,  MVT::v2i64,  MVT::v2f32,  1 },
    { ISD::FP_TO_SINT,  MVT::v4i64,  MVT::v4f32,  1 },
    { ISD::FP_TO_SINT,  MVT::v2i64,  MVT::v2f64,  1 },
    { ISD::FP_TO_SINT,  MVT::v4i64,  MVT::v4f64,  1 },

    { ISD::FP_TO_UINT,  MVT::v2i64,  MVT::v2f32,  1 },
    { ISD::FP_TO_UINT,  MVT::v4i64,  MVT::v4f32,  1 },
    { ISD::FP_TO_UINT,  MVT::v2i64,  MVT::v2f64,  1 },
    { ISD::FP_TO_UINT,  MVT::v4i64,  MVT::v4f64,  1 },
  };

  static const TypeConversionCostTblEntry AVX512VLConversionTbl[] = {
    { ISD::TRUNCATE,  MVT::v2i1,    MVT::v2i8,   3 }, // sext+vpslld+vptestmd
    { ISD::TRUNCATE,  MVT::v4i1,    MVT::v4i8,   3 }, // sext+vpslld+vptestmd
    { ISD::TRUNCATE,  MVT::v8i1,    MVT::v8i8,   3 }, // sext+vpslld+vptestmd
    { ISD::TRUNCATE,  MVT::v16i1,   MVT::v16i8,  8 }, // split+2*v8i8
    { ISD::TRUNCATE,  MVT::v2i1,    MVT::v2i16,  3 }, // sext+vpsllq+vptestmq
    { ISD::TRUNCATE,  MVT::v4i1,    MVT::v4i16,  3 }, // sext+vpsllq+vptestmq
    { ISD::TRUNCATE,  MVT::v8i1,    MVT::v8i16,  3 }, // sext+vpsllq+vptestmq
    { ISD::TRUNCATE,  MVT::v16i1,   MVT::v16i16, 8 }, // split+2*v8i16
    { ISD::TRUNCATE,  MVT::v2i1,    MVT::v2i32,  2 }, // vpslld+vptestmd
    { ISD::TRUNCATE,  MVT::v4i1,    MVT::v4i32,  2 }, // vpslld+vptestmd
    { ISD::TRUNCATE,  MVT::v8i1,    MVT::v8i32,  2 }, // vpslld+vptestmd
    { ISD::TRUNCATE,  MVT::v2i1,    MVT::v2i64,  2 }, // vpsllq+vptestmq
    { ISD::TRUNCATE,  MVT::v4i1,    MVT::v4i64,  2 }, // vpsllq+vptestmq
    { ISD::TRUNCATE,  MVT::v4i32,   MVT::v4i64,  1 }, // vpmovqd

    // sign extend is vpcmpeq+maskedmove+vpmovdw+vpacksswb
    // zero extend is vpcmpeq+maskedmove+vpmovdw+vpsrlw+vpackuswb
    { ISD::SIGN_EXTEND, MVT::v2i8,   MVT::v2i1,   5 },
    { ISD::ZERO_EXTEND, MVT::v2i8,   MVT::v2i1,   6 },
    { ISD::SIGN_EXTEND, MVT::v4i8,   MVT::v4i1,   5 },
    { ISD::ZERO_EXTEND, MVT::v4i8,   MVT::v4i1,   6 },
    { ISD::SIGN_EXTEND, MVT::v8i8,   MVT::v8i1,   5 },
    { ISD::ZERO_EXTEND, MVT::v8i8,   MVT::v8i1,   6 },
    { ISD::SIGN_EXTEND, MVT::v16i8,  MVT::v16i1, 10 },
    { ISD::ZERO_EXTEND, MVT::v16i8,  MVT::v16i1, 12 },

    // sign extend is vpcmpeq+maskedmove+vpmovdw
    // zero extend is vpcmpeq+maskedmove+vpmovdw+vpsrlw
    { ISD::SIGN_EXTEND, MVT::v2i16,  MVT::v2i1,   4 },
    { ISD::ZERO_EXTEND, MVT::v2i16,  MVT::v2i1,   5 },
    { ISD::SIGN_EXTEND, MVT::v4i16,  MVT::v4i1,   4 },
    { ISD::ZERO_EXTEND, MVT::v4i16,  MVT::v4i1,   5 },
    { ISD::SIGN_EXTEND, MVT::v8i16,  MVT::v8i1,   4 },
    { ISD::ZERO_EXTEND, MVT::v8i16,  MVT::v8i1,   5 },
    { ISD::SIGN_EXTEND, MVT::v16i16, MVT::v16i1, 10 },
    { ISD::ZERO_EXTEND, MVT::v16i16, MVT::v16i1, 12 },

    { ISD::SIGN_EXTEND, MVT::v2i32,  MVT::v2i1,   1 }, // vpternlogd
    { ISD::ZERO_EXTEND, MVT::v2i32,  MVT::v2i1,   2 }, // vpternlogd+psrld
    { ISD::SIGN_EXTEND, MVT::v4i32,  MVT::v4i1,   1 }, // vpternlogd
    { ISD::ZERO_EXTEND, MVT::v4i32,  MVT::v4i1,   2 }, // vpternlogd+psrld
    { ISD::SIGN_EXTEND, MVT::v8i32,  MVT::v8i1,   1 }, // vpternlogd
    { ISD::ZERO_EXTEND, MVT::v8i32,  MVT::v8i1,   2 }, // vpternlogd+psrld
    { ISD::SIGN_EXTEND, MVT::v2i64,  MVT::v2i1,   1 }, // vpternlogq
    { ISD::ZERO_EXTEND, MVT::v2i64,  MVT::v2i1,   2 }, // vpternlogq+psrlq
    { ISD::SIGN_EXTEND, MVT::v4i64,  MVT::v4i1,   1 }, // vpternlogq
    { ISD::ZERO_EXTEND, MVT::v4i64,  MVT::v4i1,   2 }, // vpternlogq+psrlq

    { ISD::UINT_TO_FP,  MVT::v2f64,  MVT::v2i8,   2 },
    { ISD::UINT_TO_FP,  MVT::v4f64,  MVT::v4i8,   2 },
    { ISD::UINT_TO_FP,  MVT::v8f32,  MVT::v8i8,   2 },
    { ISD::UINT_TO_FP,  MVT::v2f64,  MVT::v2i16,  5 },
    { ISD::UINT_TO_FP,  MVT::v4f64,  MVT::v4i16,  2 },
    { ISD::UINT_TO_FP,  MVT::v8f32,  MVT::v8i16,  2 },
    { ISD::UINT_TO_FP,  MVT::v2f32,  MVT::v2i32,  2 },
    { ISD::UINT_TO_FP,  MVT::v2f64,  MVT::v2i32,  1 },
    { ISD::UINT_TO_FP,  MVT::v4f32,  MVT::v4i32,  1 },
    { ISD::UINT_TO_FP,  MVT::v4f64,  MVT::v4i32,  1 },
    { ISD::UINT_TO_FP,  MVT::v8f32,  MVT::v8i32,  1 },
    { ISD::UINT_TO_FP,  MVT::v2f32,  MVT::v2i64,  5 },
    { ISD::UINT_TO_FP,  MVT::v2f64,  MVT::v2i64,  5 },
    { ISD::UINT_TO_FP,  MVT::v4f64,  MVT::v4i64,  5 },

    { ISD::UINT_TO_FP,  MVT::f32,    MVT::i64,    1 },
    { ISD::UINT_TO_FP,  MVT::f64,    MVT::i64,    1 },

    { ISD::FP_TO_SINT,  MVT::v8i8,   MVT::v8f32,  3 },
    { ISD::FP_TO_UINT,  MVT::v8i8,   MVT::v8f32,  3 },

    { ISD::FP_TO_UINT,  MVT::i64,    MVT::f32,    1 },
    { ISD::FP_TO_UINT,  MVT::i64,    MVT::f64,    1 },

    { ISD::FP_TO_UINT,  MVT::v2i32,  MVT::v2f32,  1 },
    { ISD::FP_TO_UINT,  MVT::v4i32,  MVT::v4f32,  1 },
    { ISD::FP_TO_UINT,  MVT::v2i32,  MVT::v2f64,  1 },
    { ISD::FP_TO_UINT,  MVT::v4i32,  MVT::v4f64,  1 },
    { ISD::FP_TO_UINT,  MVT::v8i32,  MVT::v8f32,  1 },
  };

  static const TypeConversionCostTblEntry AVX2ConversionTbl[] = {
    { ISD::SIGN_EXTEND, MVT::v4i64,  MVT::v4i1,   3 },
    { ISD::ZERO_EXTEND, MVT::v4i64,  MVT::v4i1,   3 },
    { ISD::SIGN_EXTEND, MVT::v8i32,  MVT::v8i1,   3 },
    { ISD::ZERO_EXTEND, MVT::v8i32,  MVT::v8i1,   3 },
    { ISD::SIGN_EXTEND, MVT::v4i64,  MVT::v4i8,   1 },
    { ISD::ZERO_EXTEND, MVT::v4i64,  MVT::v4i8,   1 },
    { ISD::SIGN_EXTEND, MVT::v8i32,  MVT::v8i8,   1 },
    { ISD::ZERO_EXTEND, MVT::v8i32,  MVT::v8i8,   1 },
    { ISD::SIGN_EXTEND, MVT::v16i16, MVT::v16i1,  1 },
    { ISD::ZERO_EXTEND, MVT::v16i16, MVT::v16i1,  1 },
    { ISD::SIGN_EXTEND, MVT::v16i16, MVT::v16i8,  1 },
    { ISD::ZERO_EXTEND, MVT::v16i16, MVT::v16i8,  1 },
    { ISD::SIGN_EXTEND, MVT::v4i64,  MVT::v4i16,  1 },
    { ISD::ZERO_EXTEND, MVT::v4i64,  MVT::v4i16,  1 },
    { ISD::SIGN_EXTEND, MVT::v8i32,  MVT::v8i16,  1 },
    { ISD::ZERO_EXTEND, MVT::v8i32,  MVT::v8i16,  1 },
    { ISD::SIGN_EXTEND, MVT::v4i64,  MVT::v4i32,  1 },
    { ISD::ZERO_EXTEND, MVT::v4i64,  MVT::v4i32,  1 },
    { ISD::ZERO_EXTEND, MVT::v16i32, MVT::v16i16, 3 },
    { ISD::SIGN_EXTEND, MVT::v16i32, MVT::v16i16, 3 },

    { ISD::TRUNCATE,    MVT::v4i32,  MVT::v4i64,  2 },
    { ISD::TRUNCATE,    MVT::v8i1,   MVT::v8i32,  2 },

    { ISD::TRUNCATE,    MVT::v4i8,   MVT::v4i64,  2 },
    { ISD::TRUNCATE,    MVT::v4i16,  MVT::v4i64,  2 },
    { ISD::TRUNCATE,    MVT::v8i8,   MVT::v8i32,  2 },
    { ISD::TRUNCATE,    MVT::v8i16,  MVT::v8i32,  2 },

    { ISD::FP_EXTEND,   MVT::v8f64,  MVT::v8f32,  3 },
    { ISD::FP_ROUND,    MVT::v8f32,  MVT::v8f64,  3 },

    { ISD::UINT_TO_FP,  MVT::v8f32,  MVT::v8i32,  8 },
  };

  static const TypeConversionCostTblEntry AVXConversionTbl[] = {
    { ISD::SIGN_EXTEND, MVT::v4i64,  MVT::v4i1,  6 },
    { ISD::ZERO_EXTEND, MVT::v4i64,  MVT::v4i1,  4 },
    { ISD::SIGN_EXTEND, MVT::v8i32,  MVT::v8i1,  7 },
    { ISD::ZERO_EXTEND, MVT::v8i32,  MVT::v8i1,  4 },
    { ISD::SIGN_EXTEND, MVT::v4i64,  MVT::v4i8,  4 },
    { ISD::ZERO_EXTEND, MVT::v4i64,  MVT::v4i8,  4 },
    { ISD::SIGN_EXTEND, MVT::v8i32,  MVT::v8i8,  4 },
    { ISD::ZERO_EXTEND, MVT::v8i32,  MVT::v8i8,  4 },
    { ISD::SIGN_EXTEND, MVT::v16i16, MVT::v16i1, 4 },
    { ISD::ZERO_EXTEND, MVT::v16i16, MVT::v16i1, 4 },
    { ISD::SIGN_EXTEND, MVT::v16i16, MVT::v16i8, 4 },
    { ISD::ZERO_EXTEND, MVT::v16i16, MVT::v16i8, 4 },
    { ISD::SIGN_EXTEND, MVT::v4i64,  MVT::v4i16, 4 },
    { ISD::ZERO_EXTEND, MVT::v4i64,  MVT::v4i16, 3 },
    { ISD::SIGN_EXTEND, MVT::v8i32,  MVT::v8i16, 4 },
    { ISD::ZERO_EXTEND, MVT::v8i32,  MVT::v8i16, 4 },
    { ISD::SIGN_EXTEND, MVT::v4i64,  MVT::v4i32, 4 },
    { ISD::ZERO_EXTEND, MVT::v4i64,  MVT::v4i32, 4 },

    { ISD::TRUNCATE,    MVT::v4i1,  MVT::v4i64,  4 },
    { ISD::TRUNCATE,    MVT::v8i1,  MVT::v8i32,  5 },
    { ISD::TRUNCATE,    MVT::v16i1, MVT::v16i16, 4 },
    { ISD::TRUNCATE,    MVT::v8i1,  MVT::v8i64,  9 },
    { ISD::TRUNCATE,    MVT::v16i1, MVT::v16i64, 11 },

    { ISD::TRUNCATE,    MVT::v16i8, MVT::v16i16, 4 },
    { ISD::TRUNCATE,    MVT::v8i8,  MVT::v8i32,  4 },
    { ISD::TRUNCATE,    MVT::v8i16, MVT::v8i32,  5 },
    { ISD::TRUNCATE,    MVT::v4i8,  MVT::v4i64,  4 },
    { ISD::TRUNCATE,    MVT::v4i16, MVT::v4i64,  4 },
    { ISD::TRUNCATE,    MVT::v4i32, MVT::v4i64,  2 },
    { ISD::TRUNCATE,    MVT::v8i8,  MVT::v8i64, 11 },
    { ISD::TRUNCATE,    MVT::v8i16, MVT::v8i64,  9 },
    { ISD::TRUNCATE,    MVT::v8i32, MVT::v8i64,  3 },
    { ISD::TRUNCATE,    MVT::v16i8, MVT::v16i64, 11 },

    { ISD::SINT_TO_FP,  MVT::v4f32, MVT::v4i1,  3 },
    { ISD::SINT_TO_FP,  MVT::v4f64, MVT::v4i1,  3 },
    { ISD::SINT_TO_FP,  MVT::v8f32, MVT::v8i1,  8 },
    { ISD::SINT_TO_FP,  MVT::v4f32, MVT::v4i8,  3 },
    { ISD::SINT_TO_FP,  MVT::v4f64, MVT::v4i8,  3 },
    { ISD::SINT_TO_FP,  MVT::v8f32, MVT::v8i8,  8 },
    { ISD::SINT_TO_FP,  MVT::v4f32, MVT::v4i16, 3 },
    { ISD::SINT_TO_FP,  MVT::v4f64, MVT::v4i16, 3 },
    { ISD::SINT_TO_FP,  MVT::v8f32, MVT::v8i16, 5 },
    { ISD::SINT_TO_FP,  MVT::v4f32, MVT::v4i32, 1 },
    { ISD::SINT_TO_FP,  MVT::v4f64, MVT::v4i32, 1 },
    { ISD::SINT_TO_FP,  MVT::v8f32, MVT::v8i32, 1 },

    { ISD::UINT_TO_FP,  MVT::v4f32, MVT::v4i1,  7 },
    { ISD::UINT_TO_FP,  MVT::v4f64, MVT::v4i1,  7 },
    { ISD::UINT_TO_FP,  MVT::v8f32, MVT::v8i1,  6 },
    { ISD::UINT_TO_FP,  MVT::v4f32, MVT::v4i8,  2 },
    { ISD::UINT_TO_FP,  MVT::v4f64, MVT::v4i8,  2 },
    { ISD::UINT_TO_FP,  MVT::v8f32, MVT::v8i8,  5 },
    { ISD::UINT_TO_FP,  MVT::v4f32, MVT::v4i16, 2 },
    { ISD::UINT_TO_FP,  MVT::v4f64, MVT::v4i16, 2 },
    { ISD::UINT_TO_FP,  MVT::v8f32, MVT::v8i16, 5 },
    { ISD::UINT_TO_FP,  MVT::v2f64, MVT::v2i32, 6 },
    { ISD::UINT_TO_FP,  MVT::v4f32, MVT::v4i32, 6 },
    { ISD::UINT_TO_FP,  MVT::v4f64, MVT::v4i32, 6 },
    { ISD::UINT_TO_FP,  MVT::v8f32, MVT::v8i32, 9 },
    { ISD::UINT_TO_FP,  MVT::v2f64, MVT::v2i64, 5 },
    { ISD::UINT_TO_FP,  MVT::v4f64, MVT::v4i64, 6 },
    // The generic code to compute the scalar overhead is currently broken.
    // Workaround this limitation by estimating the scalarization overhead
    // here. We have roughly 10 instructions per scalar element.
    // Multiply that by the vector width.
    // FIXME: remove that when PR19268 is fixed.
    { ISD::SINT_TO_FP,  MVT::v4f64, MVT::v4i64, 13 },
    { ISD::SINT_TO_FP,  MVT::v4f64, MVT::v4i64, 13 },

    { ISD::FP_TO_SINT,  MVT::v8i8,  MVT::v8f32, 4 },
    { ISD::FP_TO_SINT,  MVT::v4i8,  MVT::v4f64, 3 },
    { ISD::FP_TO_SINT,  MVT::v4i16, MVT::v4f64, 2 },
    { ISD::FP_TO_SINT,  MVT::v8i16, MVT::v8f32, 3 },

    { ISD::FP_TO_UINT,  MVT::v4i8,  MVT::v4f64, 3 },
    { ISD::FP_TO_UINT,  MVT::v4i16, MVT::v4f64, 2 },
    { ISD::FP_TO_UINT,  MVT::v8i8,  MVT::v8f32, 4 },
    { ISD::FP_TO_UINT,  MVT::v8i16, MVT::v8f32, 3 },
    // This node is expanded into scalarized operations but BasicTTI is overly
    // optimistic estimating its cost.  It computes 3 per element (one
    // vector-extract, one scalar conversion and one vector-insert).  The
    // problem is that the inserts form a read-modify-write chain so latency
    // should be factored in too.  Inflating the cost per element by 1.
    { ISD::FP_TO_UINT,  MVT::v8i32, MVT::v8f32, 8*4 },
    { ISD::FP_TO_UINT,  MVT::v4i32, MVT::v4f64, 4*4 },

    { ISD::FP_EXTEND,   MVT::v4f64,  MVT::v4f32,  1 },
    { ISD::FP_ROUND,    MVT::v4f32,  MVT::v4f64,  1 },
  };

  static const TypeConversionCostTblEntry SSE41ConversionTbl[] = {
    { ISD::ZERO_EXTEND, MVT::v4i64, MVT::v4i8,    2 },
    { ISD::SIGN_EXTEND, MVT::v4i64, MVT::v4i8,    2 },
    { ISD::ZERO_EXTEND, MVT::v4i64, MVT::v4i16,   2 },
    { ISD::SIGN_EXTEND, MVT::v4i64, MVT::v4i16,   2 },
    { ISD::ZERO_EXTEND, MVT::v4i64, MVT::v4i32,   2 },
    { ISD::SIGN_EXTEND, MVT::v4i64, MVT::v4i32,   2 },

    { ISD::ZERO_EXTEND, MVT::v4i16,  MVT::v4i8,   1 },
    { ISD::SIGN_EXTEND, MVT::v4i16,  MVT::v4i8,   2 },
    { ISD::ZERO_EXTEND, MVT::v4i32,  MVT::v4i8,   1 },
    { ISD::SIGN_EXTEND, MVT::v4i32,  MVT::v4i8,   1 },
    { ISD::ZERO_EXTEND, MVT::v8i16,  MVT::v8i8,   1 },
    { ISD::SIGN_EXTEND, MVT::v8i16,  MVT::v8i8,   1 },
    { ISD::ZERO_EXTEND, MVT::v8i32,  MVT::v8i8,   2 },
    { ISD::SIGN_EXTEND, MVT::v8i32,  MVT::v8i8,   2 },
    { ISD::ZERO_EXTEND, MVT::v16i16, MVT::v16i8,  2 },
    { ISD::SIGN_EXTEND, MVT::v16i16, MVT::v16i8,  2 },
    { ISD::ZERO_EXTEND, MVT::v16i32, MVT::v16i8,  4 },
    { ISD::SIGN_EXTEND, MVT::v16i32, MVT::v16i8,  4 },
    { ISD::ZERO_EXTEND, MVT::v4i32,  MVT::v4i16,  1 },
    { ISD::SIGN_EXTEND, MVT::v4i32,  MVT::v4i16,  1 },
    { ISD::ZERO_EXTEND, MVT::v8i32,  MVT::v8i16,  2 },
    { ISD::SIGN_EXTEND, MVT::v8i32,  MVT::v8i16,  2 },
    { ISD::ZERO_EXTEND, MVT::v16i32, MVT::v16i16, 4 },
    { ISD::SIGN_EXTEND, MVT::v16i32, MVT::v16i16, 4 },

    // These truncates end up widening elements.
    { ISD::TRUNCATE,    MVT::v2i1,   MVT::v2i8,   1 }, // PMOVXZBQ
    { ISD::TRUNCATE,    MVT::v2i1,   MVT::v2i16,  1 }, // PMOVXZWQ
    { ISD::TRUNCATE,    MVT::v4i1,   MVT::v4i8,   1 }, // PMOVXZBD

    { ISD::TRUNCATE,    MVT::v2i8,   MVT::v2i16,  1 },
    { ISD::TRUNCATE,    MVT::v4i8,   MVT::v4i16,  1 },
    { ISD::TRUNCATE,    MVT::v8i8,   MVT::v8i16,  1 },
    { ISD::TRUNCATE,    MVT::v4i8,   MVT::v4i32,  1 },
    { ISD::TRUNCATE,    MVT::v4i16,  MVT::v4i32,  1 },
    { ISD::TRUNCATE,    MVT::v8i8,   MVT::v8i32,  3 },
    { ISD::TRUNCATE,    MVT::v8i16,  MVT::v8i32,  3 },
    { ISD::TRUNCATE,    MVT::v16i16, MVT::v16i32, 6 },
    { ISD::TRUNCATE,    MVT::v2i8,   MVT::v2i64,  1 }, // PSHUFB

    { ISD::UINT_TO_FP,  MVT::f32,    MVT::i64,    4 },
    { ISD::UINT_TO_FP,  MVT::f64,    MVT::i64,    4 },

    { ISD::FP_TO_SINT,  MVT::v2i8,   MVT::v2f32,  3 },
    { ISD::FP_TO_SINT,  MVT::v2i8,   MVT::v2f64,  3 },

    { ISD::FP_TO_UINT,  MVT::v2i8,   MVT::v2f32,  3 },
    { ISD::FP_TO_UINT,  MVT::v2i8,   MVT::v2f64,  3 },
    { ISD::FP_TO_UINT,  MVT::v4i16,  MVT::v4f32,  2 },
  };

  static const TypeConversionCostTblEntry SSE2ConversionTbl[] = {
    // These are somewhat magic numbers justified by looking at the output of
    // Intel's IACA, running some kernels and making sure when we take
    // legalization into account the throughput will be overestimated.
    { ISD::SINT_TO_FP, MVT::v4f32, MVT::v16i8, 8 },
    { ISD::SINT_TO_FP, MVT::v2f64, MVT::v16i8, 16*10 },
    { ISD::SINT_TO_FP, MVT::v4f32, MVT::v8i16, 15 },
    { ISD::SINT_TO_FP, MVT::v2f64, MVT::v8i16, 8*10 },
    { ISD::SINT_TO_FP, MVT::v4f32, MVT::v4i32, 5 },
    { ISD::SINT_TO_FP, MVT::v2f64, MVT::v4i32, 2*10 },
    { ISD::SINT_TO_FP, MVT::v2f64, MVT::v2i32, 2*10 },
    { ISD::SINT_TO_FP, MVT::v4f32, MVT::v2i64, 15 },
    { ISD::SINT_TO_FP, MVT::v2f64, MVT::v2i64, 2*10 },

    { ISD::UINT_TO_FP, MVT::v2f64, MVT::v16i8, 16*10 },
    { ISD::UINT_TO_FP, MVT::v4f32, MVT::v16i8, 8 },
    { ISD::UINT_TO_FP, MVT::v4f32, MVT::v8i16, 15 },
    { ISD::UINT_TO_FP, MVT::v2f64, MVT::v8i16, 8*10 },
    { ISD::UINT_TO_FP, MVT::v2f64, MVT::v4i32, 4*10 },
    { ISD::UINT_TO_FP, MVT::v4f32, MVT::v4i32, 8 },
    { ISD::UINT_TO_FP, MVT::v2f64, MVT::v2i64, 6 },
    { ISD::UINT_TO_FP, MVT::v4f32, MVT::v2i64, 15 },

    { ISD::FP_TO_SINT,  MVT::v2i8,   MVT::v2f32,  4 },
    { ISD::FP_TO_SINT,  MVT::v2i16,  MVT::v2f32,  2 },
    { ISD::FP_TO_SINT,  MVT::v4i8,   MVT::v4f32,  3 },
    { ISD::FP_TO_SINT,  MVT::v4i16,  MVT::v4f32,  2 },
    { ISD::FP_TO_SINT,  MVT::v2i16,  MVT::v2f64,  2 },
    { ISD::FP_TO_SINT,  MVT::v2i8,   MVT::v2f64,  4 },

    { ISD::FP_TO_SINT,  MVT::v2i32,  MVT::v2f64,  1 },

    { ISD::UINT_TO_FP,  MVT::f32,    MVT::i64,    6 },
    { ISD::UINT_TO_FP,  MVT::f64,    MVT::i64,    6 },

    { ISD::FP_TO_UINT,  MVT::i64,    MVT::f32,    4 },
    { ISD::FP_TO_UINT,  MVT::i64,    MVT::f64,    4 },
    { ISD::FP_TO_UINT,  MVT::v2i8,   MVT::v2f32,  4 },
    { ISD::FP_TO_UINT,  MVT::v2i8,   MVT::v2f64,  4 },
    { ISD::FP_TO_UINT,  MVT::v4i8,   MVT::v4f32,  3 },
    { ISD::FP_TO_UINT,  MVT::v2i16,  MVT::v2f32,  2 },
    { ISD::FP_TO_UINT,  MVT::v2i16,  MVT::v2f64,  2 },
    { ISD::FP_TO_UINT,  MVT::v4i16,  MVT::v4f32,  4 },

    { ISD::ZERO_EXTEND, MVT::v4i16,  MVT::v4i8,   1 },
    { ISD::SIGN_EXTEND, MVT::v4i16,  MVT::v4i8,   6 },
    { ISD::ZERO_EXTEND, MVT::v4i32,  MVT::v4i8,   2 },
    { ISD::SIGN_EXTEND, MVT::v4i32,  MVT::v4i8,   3 },
    { ISD::ZERO_EXTEND, MVT::v4i64,  MVT::v4i8,   4 },
    { ISD::SIGN_EXTEND, MVT::v4i64,  MVT::v4i8,   8 },
    { ISD::ZERO_EXTEND, MVT::v8i16,  MVT::v8i8,   1 },
    { ISD::SIGN_EXTEND, MVT::v8i16,  MVT::v8i8,   2 },
    { ISD::ZERO_EXTEND, MVT::v8i32,  MVT::v8i8,   6 },
    { ISD::SIGN_EXTEND, MVT::v8i32,  MVT::v8i8,   6 },
    { ISD::ZERO_EXTEND, MVT::v16i16, MVT::v16i8,  3 },
    { ISD::SIGN_EXTEND, MVT::v16i16, MVT::v16i8,  4 },
    { ISD::ZERO_EXTEND, MVT::v16i32, MVT::v16i8,  9 },
    { ISD::SIGN_EXTEND, MVT::v16i32, MVT::v16i8,  12 },
    { ISD::ZERO_EXTEND, MVT::v4i32,  MVT::v4i16,  1 },
    { ISD::SIGN_EXTEND, MVT::v4i32,  MVT::v4i16,  2 },
    { ISD::ZERO_EXTEND, MVT::v4i64,  MVT::v4i16,  3 },
    { ISD::SIGN_EXTEND, MVT::v4i64,  MVT::v4i16,  10 },
    { ISD::ZERO_EXTEND, MVT::v8i32,  MVT::v8i16,  3 },
    { ISD::SIGN_EXTEND, MVT::v8i32,  MVT::v8i16,  4 },
    { ISD::ZERO_EXTEND, MVT::v16i32, MVT::v16i16, 6 },
    { ISD::SIGN_EXTEND, MVT::v16i32, MVT::v16i16, 8 },
    { ISD::ZERO_EXTEND, MVT::v4i64,  MVT::v4i32,  3 },
    { ISD::SIGN_EXTEND, MVT::v4i64,  MVT::v4i32,  5 },

    // These truncates are really widening elements.
    { ISD::TRUNCATE,    MVT::v2i1,   MVT::v2i32,  1 }, // PSHUFD
    { ISD::TRUNCATE,    MVT::v2i1,   MVT::v2i16,  2 }, // PUNPCKLWD+DQ
    { ISD::TRUNCATE,    MVT::v2i1,   MVT::v2i8,   3 }, // PUNPCKLBW+WD+PSHUFD
    { ISD::TRUNCATE,    MVT::v4i1,   MVT::v4i16,  1 }, // PUNPCKLWD
    { ISD::TRUNCATE,    MVT::v4i1,   MVT::v4i8,   2 }, // PUNPCKLBW+WD
    { ISD::TRUNCATE,    MVT::v8i1,   MVT::v8i8,   1 }, // PUNPCKLBW

    { ISD::TRUNCATE,    MVT::v2i8,   MVT::v2i16,  2 }, // PAND+PACKUSWB
    { ISD::TRUNCATE,    MVT::v4i8,   MVT::v4i16,  2 }, // PAND+PACKUSWB
    { ISD::TRUNCATE,    MVT::v8i8,   MVT::v8i16,  2 }, // PAND+PACKUSWB
    { ISD::TRUNCATE,    MVT::v16i8,  MVT::v16i16, 3 },
    { ISD::TRUNCATE,    MVT::v2i8,   MVT::v2i32,  3 }, // PAND+2*PACKUSWB
    { ISD::TRUNCATE,    MVT::v2i16,  MVT::v2i32,  1 },
    { ISD::TRUNCATE,    MVT::v4i8,   MVT::v4i32,  3 },
    { ISD::TRUNCATE,    MVT::v4i16,  MVT::v4i32,  3 },
    { ISD::TRUNCATE,    MVT::v8i8,   MVT::v8i32,  4 },
    { ISD::TRUNCATE,    MVT::v16i8,  MVT::v16i32, 7 },
    { ISD::TRUNCATE,    MVT::v8i16,  MVT::v8i32,  5 },
    { ISD::TRUNCATE,    MVT::v16i16, MVT::v16i32, 10 },
    { ISD::TRUNCATE,    MVT::v2i8,   MVT::v2i64,  4 }, // PAND+3*PACKUSWB
    { ISD::TRUNCATE,    MVT::v2i16,  MVT::v2i64,  2 }, // PSHUFD+PSHUFLW
    { ISD::TRUNCATE,    MVT::v2i32,  MVT::v2i64,  1 }, // PSHUFD
  };

  std::pair<int, MVT> LTSrc = TLI->getTypeLegalizationCost(DL, Src);
  std::pair<int, MVT> LTDest = TLI->getTypeLegalizationCost(DL, Dst);

  if (ST->hasSSE2() && !ST->hasAVX()) {
    if (const auto *Entry = ConvertCostTableLookup(SSE2ConversionTbl, ISD,
                                                   LTDest.second, LTSrc.second))
      return AdjustCost(LTSrc.first * Entry->Cost);
  }

  EVT SrcTy = TLI->getValueType(DL, Src);
  EVT DstTy = TLI->getValueType(DL, Dst);

  // The function getSimpleVT only handles simple value types.
  if (!SrcTy.isSimple() || !DstTy.isSimple())
    return AdjustCost(BaseT::getCastInstrCost(Opcode, Dst, Src, CostKind));

  MVT SimpleSrcTy = SrcTy.getSimpleVT();
  MVT SimpleDstTy = DstTy.getSimpleVT();

  if (ST->useAVX512Regs()) {
    if (ST->hasBWI())
      if (const auto *Entry = ConvertCostTableLookup(AVX512BWConversionTbl, ISD,
                                                     SimpleDstTy, SimpleSrcTy))
        return AdjustCost(Entry->Cost);

    if (ST->hasDQI())
      if (const auto *Entry = ConvertCostTableLookup(AVX512DQConversionTbl, ISD,
                                                     SimpleDstTy, SimpleSrcTy))
        return AdjustCost(Entry->Cost);

    if (ST->hasAVX512())
      if (const auto *Entry = ConvertCostTableLookup(AVX512FConversionTbl, ISD,
                                                     SimpleDstTy, SimpleSrcTy))
        return AdjustCost(Entry->Cost);
  }

  if (ST->hasBWI())
    if (const auto *Entry = ConvertCostTableLookup(AVX512BWVLConversionTbl, ISD,
                                                   SimpleDstTy, SimpleSrcTy))
      return AdjustCost(Entry->Cost);

  if (ST->hasDQI())
    if (const auto *Entry = ConvertCostTableLookup(AVX512DQVLConversionTbl, ISD,
                                                   SimpleDstTy, SimpleSrcTy))
      return AdjustCost(Entry->Cost);

  if (ST->hasAVX512())
    if (const auto *Entry = ConvertCostTableLookup(AVX512VLConversionTbl, ISD,
                                                   SimpleDstTy, SimpleSrcTy))
      return AdjustCost(Entry->Cost);

  if (ST->hasAVX2()) {
    if (const auto *Entry = ConvertCostTableLookup(AVX2ConversionTbl, ISD,
                                                   SimpleDstTy, SimpleSrcTy))
      return AdjustCost(Entry->Cost);
  }

  if (ST->hasAVX()) {
    if (const auto *Entry = ConvertCostTableLookup(AVXConversionTbl, ISD,
                                                   SimpleDstTy, SimpleSrcTy))
      return AdjustCost(Entry->Cost);
  }

  if (ST->hasSSE41()) {
    if (const auto *Entry = ConvertCostTableLookup(SSE41ConversionTbl, ISD,
                                                   SimpleDstTy, SimpleSrcTy))
      return AdjustCost(Entry->Cost);
  }

  if (ST->hasSSE2()) {
    if (const auto *Entry = ConvertCostTableLookup(SSE2ConversionTbl, ISD,
                                                   SimpleDstTy, SimpleSrcTy))
      return AdjustCost(Entry->Cost);
  }

  return AdjustCost(BaseT::getCastInstrCost(Opcode, Dst, Src, CostKind, I));
}

int X86TTIImpl::getCmpSelInstrCost(unsigned Opcode, Type *ValTy, Type *CondTy,
                                   TTI::TargetCostKind CostKind,
                                   const Instruction *I) {
  // TODO: Handle other cost kinds.
  if (CostKind != TTI::TCK_RecipThroughput)
    return BaseT::getCmpSelInstrCost(Opcode, ValTy, CondTy, CostKind, I);

  // Legalize the type.
  std::pair<int, MVT> LT = TLI->getTypeLegalizationCost(DL, ValTy);

  MVT MTy = LT.second;

  int ISD = TLI->InstructionOpcodeToISD(Opcode);
  assert(ISD && "Invalid opcode");

  unsigned ExtraCost = 0;
  if (I && (Opcode == Instruction::ICmp || Opcode == Instruction::FCmp)) {
    // Some vector comparison predicates cost extra instructions.
    if (MTy.isVector() &&
        !((ST->hasXOP() && (!ST->hasAVX2() || MTy.is128BitVector())) ||
          (ST->hasAVX512() && 32 <= MTy.getScalarSizeInBits()) ||
          ST->hasBWI())) {
      switch (cast<CmpInst>(I)->getPredicate()) {
      case CmpInst::Predicate::ICMP_NE:
        // xor(cmpeq(x,y),-1)
        ExtraCost = 1;
        break;
      case CmpInst::Predicate::ICMP_SGE:
      case CmpInst::Predicate::ICMP_SLE:
        // xor(cmpgt(x,y),-1)
        ExtraCost = 1;
        break;
      case CmpInst::Predicate::ICMP_ULT:
      case CmpInst::Predicate::ICMP_UGT:
        // cmpgt(xor(x,signbit),xor(y,signbit))
        // xor(cmpeq(pmaxu(x,y),x),-1)
        ExtraCost = 2;
        break;
      case CmpInst::Predicate::ICMP_ULE:
      case CmpInst::Predicate::ICMP_UGE:
        if ((ST->hasSSE41() && MTy.getScalarSizeInBits() == 32) ||
            (ST->hasSSE2() && MTy.getScalarSizeInBits() < 32)) {
          // cmpeq(psubus(x,y),0)
          // cmpeq(pminu(x,y),x)
          ExtraCost = 1;
        } else {
          // xor(cmpgt(xor(x,signbit),xor(y,signbit)),-1)
          ExtraCost = 3;
        }
        break;
      default:
        break;
      }
    }
  }

  static const CostTblEntry SLMCostTbl[] = {
    // slm pcmpeq/pcmpgt throughput is 2
    { ISD::SETCC,   MVT::v2i64,   2 },
  };

  static const CostTblEntry AVX512BWCostTbl[] = {
    { ISD::SETCC,   MVT::v32i16,  1 },
    { ISD::SETCC,   MVT::v64i8,   1 },

    { ISD::SELECT,  MVT::v32i16,  1 },
    { ISD::SELECT,  MVT::v64i8,   1 },
  };

  static const CostTblEntry AVX512CostTbl[] = {
    { ISD::SETCC,   MVT::v8i64,   1 },
    { ISD::SETCC,   MVT::v16i32,  1 },
    { ISD::SETCC,   MVT::v8f64,   1 },
    { ISD::SETCC,   MVT::v16f32,  1 },

    { ISD::SELECT,  MVT::v8i64,   1 },
    { ISD::SELECT,  MVT::v16i32,  1 },
    { ISD::SELECT,  MVT::v8f64,   1 },
    { ISD::SELECT,  MVT::v16f32,  1 },

    { ISD::SETCC,   MVT::v32i16,  2 }, // FIXME: should probably be 4
    { ISD::SETCC,   MVT::v64i8,   2 }, // FIXME: should probably be 4

    { ISD::SELECT,  MVT::v32i16,  2 }, // FIXME: should be 3
    { ISD::SELECT,  MVT::v64i8,   2 }, // FIXME: should be 3
  };

  static const CostTblEntry AVX2CostTbl[] = {
    { ISD::SETCC,   MVT::v4i64,   1 },
    { ISD::SETCC,   MVT::v8i32,   1 },
    { ISD::SETCC,   MVT::v16i16,  1 },
    { ISD::SETCC,   MVT::v32i8,   1 },

    { ISD::SELECT,  MVT::v4i64,   1 }, // pblendvb
    { ISD::SELECT,  MVT::v8i32,   1 }, // pblendvb
    { ISD::SELECT,  MVT::v16i16,  1 }, // pblendvb
    { ISD::SELECT,  MVT::v32i8,   1 }, // pblendvb
  };

  static const CostTblEntry AVX1CostTbl[] = {
    { ISD::SETCC,   MVT::v4f64,   1 },
    { ISD::SETCC,   MVT::v8f32,   1 },
    // AVX1 does not support 8-wide integer compare.
    { ISD::SETCC,   MVT::v4i64,   4 },
    { ISD::SETCC,   MVT::v8i32,   4 },
    { ISD::SETCC,   MVT::v16i16,  4 },
    { ISD::SETCC,   MVT::v32i8,   4 },

    { ISD::SELECT,  MVT::v4f64,   1 }, // vblendvpd
    { ISD::SELECT,  MVT::v8f32,   1 }, // vblendvps
    { ISD::SELECT,  MVT::v4i64,   1 }, // vblendvpd
    { ISD::SELECT,  MVT::v8i32,   1 }, // vblendvps
    { ISD::SELECT,  MVT::v16i16,  3 }, // vandps + vandnps + vorps
    { ISD::SELECT,  MVT::v32i8,   3 }, // vandps + vandnps + vorps
  };

  static const CostTblEntry SSE42CostTbl[] = {
    { ISD::SETCC,   MVT::v2f64,   1 },
    { ISD::SETCC,   MVT::v4f32,   1 },
    { ISD::SETCC,   MVT::v2i64,   1 },
  };

  static const CostTblEntry SSE41CostTbl[] = {
    { ISD::SELECT,  MVT::v2f64,   1 }, // blendvpd
    { ISD::SELECT,  MVT::v4f32,   1 }, // blendvps
    { ISD::SELECT,  MVT::v2i64,   1 }, // pblendvb
    { ISD::SELECT,  MVT::v4i32,   1 }, // pblendvb
    { ISD::SELECT,  MVT::v8i16,   1 }, // pblendvb
    { ISD::SELECT,  MVT::v16i8,   1 }, // pblendvb
  };

  static const CostTblEntry SSE2CostTbl[] = {
    { ISD::SETCC,   MVT::v2f64,   2 },
    { ISD::SETCC,   MVT::f64,     1 },
    { ISD::SETCC,   MVT::v2i64,   8 },
    { ISD::SETCC,   MVT::v4i32,   1 },
    { ISD::SETCC,   MVT::v8i16,   1 },
    { ISD::SETCC,   MVT::v16i8,   1 },

    { ISD::SELECT,  MVT::v2f64,   3 }, // andpd + andnpd + orpd
    { ISD::SELECT,  MVT::v2i64,   3 }, // pand + pandn + por
    { ISD::SELECT,  MVT::v4i32,   3 }, // pand + pandn + por
    { ISD::SELECT,  MVT::v8i16,   3 }, // pand + pandn + por
    { ISD::SELECT,  MVT::v16i8,   3 }, // pand + pandn + por
  };

  static const CostTblEntry SSE1CostTbl[] = {
    { ISD::SETCC,   MVT::v4f32,   2 },
    { ISD::SETCC,   MVT::f32,     1 },

    { ISD::SELECT,  MVT::v4f32,   3 }, // andps + andnps + orps
  };

  if (ST->isSLM())
    if (const auto *Entry = CostTableLookup(SLMCostTbl, ISD, MTy))
      return LT.first * (ExtraCost + Entry->Cost);

  if (ST->hasBWI())
    if (const auto *Entry = CostTableLookup(AVX512BWCostTbl, ISD, MTy))
      return LT.first * (ExtraCost + Entry->Cost);

  if (ST->hasAVX512())
    if (const auto *Entry = CostTableLookup(AVX512CostTbl, ISD, MTy))
      return LT.first * (ExtraCost + Entry->Cost);

  if (ST->hasAVX2())
    if (const auto *Entry = CostTableLookup(AVX2CostTbl, ISD, MTy))
      return LT.first * (ExtraCost + Entry->Cost);

  if (ST->hasAVX())
    if (const auto *Entry = CostTableLookup(AVX1CostTbl, ISD, MTy))
      return LT.first * (ExtraCost + Entry->Cost);

  if (ST->hasSSE42())
    if (const auto *Entry = CostTableLookup(SSE42CostTbl, ISD, MTy))
      return LT.first * (ExtraCost + Entry->Cost);

  if (ST->hasSSE41())
    if (const auto *Entry = CostTableLookup(SSE41CostTbl, ISD, MTy))
      return LT.first * (ExtraCost + Entry->Cost);

  if (ST->hasSSE2())
    if (const auto *Entry = CostTableLookup(SSE2CostTbl, ISD, MTy))
      return LT.first * (ExtraCost + Entry->Cost);

  if (ST->hasSSE1())
    if (const auto *Entry = CostTableLookup(SSE1CostTbl, ISD, MTy))
      return LT.first * (ExtraCost + Entry->Cost);

  return BaseT::getCmpSelInstrCost(Opcode, ValTy, CondTy, CostKind, I);
}

unsigned X86TTIImpl::getAtomicMemIntrinsicMaxElementSize() const { return 16; }

int X86TTIImpl::getTypeBasedIntrinsicInstrCost(
  const IntrinsicCostAttributes &ICA, TTI::TargetCostKind CostKind) {

  // Costs should match the codegen from:
  // BITREVERSE: llvm\test\CodeGen\X86\vector-bitreverse.ll
  // BSWAP: llvm\test\CodeGen\X86\bswap-vector.ll
  // CTLZ: llvm\test\CodeGen\X86\vector-lzcnt-*.ll
  // CTPOP: llvm\test\CodeGen\X86\vector-popcnt-*.ll
  // CTTZ: llvm\test\CodeGen\X86\vector-tzcnt-*.ll
  static const CostTblEntry AVX512CDCostTbl[] = {
    { ISD::CTLZ,       MVT::v8i64,   1 },
    { ISD::CTLZ,       MVT::v16i32,  1 },
    { ISD::CTLZ,       MVT::v32i16,  8 },
    { ISD::CTLZ,       MVT::v64i8,  20 },
    { ISD::CTLZ,       MVT::v4i64,   1 },
    { ISD::CTLZ,       MVT::v8i32,   1 },
    { ISD::CTLZ,       MVT::v16i16,  4 },
    { ISD::CTLZ,       MVT::v32i8,  10 },
    { ISD::CTLZ,       MVT::v2i64,   1 },
    { ISD::CTLZ,       MVT::v4i32,   1 },
    { ISD::CTLZ,       MVT::v8i16,   4 },
    { ISD::CTLZ,       MVT::v16i8,   4 },
  };
  static const CostTblEntry AVX512BWCostTbl[] = {
    { ISD::BITREVERSE, MVT::v8i64,   5 },
    { ISD::BITREVERSE, MVT::v16i32,  5 },
    { ISD::BITREVERSE, MVT::v32i16,  5 },
    { ISD::BITREVERSE, MVT::v64i8,   5 },
    { ISD::CTLZ,       MVT::v8i64,  23 },
    { ISD::CTLZ,       MVT::v16i32, 22 },
    { ISD::CTLZ,       MVT::v32i16, 18 },
    { ISD::CTLZ,       MVT::v64i8,  17 },
    { ISD::CTPOP,      MVT::v8i64,   7 },
    { ISD::CTPOP,      MVT::v16i32, 11 },
    { ISD::CTPOP,      MVT::v32i16,  9 },
    { ISD::CTPOP,      MVT::v64i8,   6 },
    { ISD::CTTZ,       MVT::v8i64,  10 },
    { ISD::CTTZ,       MVT::v16i32, 14 },
    { ISD::CTTZ,       MVT::v32i16, 12 },
    { ISD::CTTZ,       MVT::v64i8,   9 },
    { ISD::SADDSAT,    MVT::v32i16,  1 },
    { ISD::SADDSAT,    MVT::v64i8,   1 },
    { ISD::SSUBSAT,    MVT::v32i16,  1 },
    { ISD::SSUBSAT,    MVT::v64i8,   1 },
    { ISD::UADDSAT,    MVT::v32i16,  1 },
    { ISD::UADDSAT,    MVT::v64i8,   1 },
    { ISD::USUBSAT,    MVT::v32i16,  1 },
    { ISD::USUBSAT,    MVT::v64i8,   1 },
  };
  static const CostTblEntry AVX512CostTbl[] = {
    { ISD::BITREVERSE, MVT::v8i64,  36 },
    { ISD::BITREVERSE, MVT::v16i32, 24 },
    { ISD::BITREVERSE, MVT::v32i16, 10 },
    { ISD::BITREVERSE, MVT::v64i8,  10 },
    { ISD::CTLZ,       MVT::v8i64,  29 },
    { ISD::CTLZ,       MVT::v16i32, 35 },
    { ISD::CTLZ,       MVT::v32i16, 28 },
    { ISD::CTLZ,       MVT::v64i8,  18 },
    { ISD::CTPOP,      MVT::v8i64,  16 },
    { ISD::CTPOP,      MVT::v16i32, 24 },
    { ISD::CTPOP,      MVT::v32i16, 18 },
    { ISD::CTPOP,      MVT::v64i8,  12 },
    { ISD::CTTZ,       MVT::v8i64,  20 },
    { ISD::CTTZ,       MVT::v16i32, 28 },
    { ISD::CTTZ,       MVT::v32i16, 24 },
    { ISD::CTTZ,       MVT::v64i8,  18 },
    { ISD::USUBSAT,    MVT::v16i32,  2 }, // pmaxud + psubd
    { ISD::USUBSAT,    MVT::v2i64,   2 }, // pmaxuq + psubq
    { ISD::USUBSAT,    MVT::v4i64,   2 }, // pmaxuq + psubq
    { ISD::USUBSAT,    MVT::v8i64,   2 }, // pmaxuq + psubq
    { ISD::UADDSAT,    MVT::v16i32,  3 }, // not + pminud + paddd
    { ISD::UADDSAT,    MVT::v2i64,   3 }, // not + pminuq + paddq
    { ISD::UADDSAT,    MVT::v4i64,   3 }, // not + pminuq + paddq
    { ISD::UADDSAT,    MVT::v8i64,   3 }, // not + pminuq + paddq
    { ISD::SADDSAT,    MVT::v32i16,  2 }, // FIXME: include split
    { ISD::SADDSAT,    MVT::v64i8,   2 }, // FIXME: include split
    { ISD::SSUBSAT,    MVT::v32i16,  2 }, // FIXME: include split
    { ISD::SSUBSAT,    MVT::v64i8,   2 }, // FIXME: include split
    { ISD::UADDSAT,    MVT::v32i16,  2 }, // FIXME: include split
    { ISD::UADDSAT,    MVT::v64i8,   2 }, // FIXME: include split
    { ISD::USUBSAT,    MVT::v32i16,  2 }, // FIXME: include split
    { ISD::USUBSAT,    MVT::v64i8,   2 }, // FIXME: include split
    { ISD::FMAXNUM,    MVT::f32,     2 },
    { ISD::FMAXNUM,    MVT::v4f32,   2 },
    { ISD::FMAXNUM,    MVT::v8f32,   2 },
    { ISD::FMAXNUM,    MVT::v16f32,  2 },
    { ISD::FMAXNUM,    MVT::f64,     2 },
    { ISD::FMAXNUM,    MVT::v2f64,   2 },
    { ISD::FMAXNUM,    MVT::v4f64,   2 },
    { ISD::FMAXNUM,    MVT::v8f64,   2 },
  };
  static const CostTblEntry XOPCostTbl[] = {
    { ISD::BITREVERSE, MVT::v4i64,   4 },
    { ISD::BITREVERSE, MVT::v8i32,   4 },
    { ISD::BITREVERSE, MVT::v16i16,  4 },
    { ISD::BITREVERSE, MVT::v32i8,   4 },
    { ISD::BITREVERSE, MVT::v2i64,   1 },
    { ISD::BITREVERSE, MVT::v4i32,   1 },
    { ISD::BITREVERSE, MVT::v8i16,   1 },
    { ISD::BITREVERSE, MVT::v16i8,   1 },
    { ISD::BITREVERSE, MVT::i64,     3 },
    { ISD::BITREVERSE, MVT::i32,     3 },
    { ISD::BITREVERSE, MVT::i16,     3 },
    { ISD::BITREVERSE, MVT::i8,      3 }
  };
  static const CostTblEntry AVX2CostTbl[] = {
    { ISD::BITREVERSE, MVT::v4i64,   5 },
    { ISD::BITREVERSE, MVT::v8i32,   5 },
    { ISD::BITREVERSE, MVT::v16i16,  5 },
    { ISD::BITREVERSE, MVT::v32i8,   5 },
    { ISD::BSWAP,      MVT::v4i64,   1 },
    { ISD::BSWAP,      MVT::v8i32,   1 },
    { ISD::BSWAP,      MVT::v16i16,  1 },
    { ISD::CTLZ,       MVT::v4i64,  23 },
    { ISD::CTLZ,       MVT::v8i32,  18 },
    { ISD::CTLZ,       MVT::v16i16, 14 },
    { ISD::CTLZ,       MVT::v32i8,   9 },
    { ISD::CTPOP,      MVT::v4i64,   7 },
    { ISD::CTPOP,      MVT::v8i32,  11 },
    { ISD::CTPOP,      MVT::v16i16,  9 },
    { ISD::CTPOP,      MVT::v32i8,   6 },
    { ISD::CTTZ,       MVT::v4i64,  10 },
    { ISD::CTTZ,       MVT::v8i32,  14 },
    { ISD::CTTZ,       MVT::v16i16, 12 },
    { ISD::CTTZ,       MVT::v32i8,   9 },
    { ISD::SADDSAT,    MVT::v16i16,  1 },
    { ISD::SADDSAT,    MVT::v32i8,   1 },
    { ISD::SSUBSAT,    MVT::v16i16,  1 },
    { ISD::SSUBSAT,    MVT::v32i8,   1 },
    { ISD::UADDSAT,    MVT::v16i16,  1 },
    { ISD::UADDSAT,    MVT::v32i8,   1 },
    { ISD::UADDSAT,    MVT::v8i32,   3 }, // not + pminud + paddd
    { ISD::USUBSAT,    MVT::v16i16,  1 },
    { ISD::USUBSAT,    MVT::v32i8,   1 },
    { ISD::USUBSAT,    MVT::v8i32,   2 }, // pmaxud + psubd
    { ISD::FSQRT,      MVT::f32,     7 }, // Haswell from http://www.agner.org/
    { ISD::FSQRT,      MVT::v4f32,   7 }, // Haswell from http://www.agner.org/
    { ISD::FSQRT,      MVT::v8f32,  14 }, // Haswell from http://www.agner.org/
    { ISD::FSQRT,      MVT::f64,    14 }, // Haswell from http://www.agner.org/
    { ISD::FSQRT,      MVT::v2f64,  14 }, // Haswell from http://www.agner.org/
    { ISD::FSQRT,      MVT::v4f64,  28 }, // Haswell from http://www.agner.org/
  };
  static const CostTblEntry AVX1CostTbl[] = {
    { ISD::BITREVERSE, MVT::v4i64,  12 }, // 2 x 128-bit Op + extract/insert
    { ISD::BITREVERSE, MVT::v8i32,  12 }, // 2 x 128-bit Op + extract/insert
    { ISD::BITREVERSE, MVT::v16i16, 12 }, // 2 x 128-bit Op + extract/insert
    { ISD::BITREVERSE, MVT::v32i8,  12 }, // 2 x 128-bit Op + extract/insert
    { ISD::BSWAP,      MVT::v4i64,   4 },
    { ISD::BSWAP,      MVT::v8i32,   4 },
    { ISD::BSWAP,      MVT::v16i16,  4 },
    { ISD::CTLZ,       MVT::v4i64,  48 }, // 2 x 128-bit Op + extract/insert
    { ISD::CTLZ,       MVT::v8i32,  38 }, // 2 x 128-bit Op + extract/insert
    { ISD::CTLZ,       MVT::v16i16, 30 }, // 2 x 128-bit Op + extract/insert
    { ISD::CTLZ,       MVT::v32i8,  20 }, // 2 x 128-bit Op + extract/insert
    { ISD::CTPOP,      MVT::v4i64,  16 }, // 2 x 128-bit Op + extract/insert
    { ISD::CTPOP,      MVT::v8i32,  24 }, // 2 x 128-bit Op + extract/insert
    { ISD::CTPOP,      MVT::v16i16, 20 }, // 2 x 128-bit Op + extract/insert
    { ISD::CTPOP,      MVT::v32i8,  14 }, // 2 x 128-bit Op + extract/insert
    { ISD::CTTZ,       MVT::v4i64,  22 }, // 2 x 128-bit Op + extract/insert
    { ISD::CTTZ,       MVT::v8i32,  30 }, // 2 x 128-bit Op + extract/insert
    { ISD::CTTZ,       MVT::v16i16, 26 }, // 2 x 128-bit Op + extract/insert
    { ISD::CTTZ,       MVT::v32i8,  20 }, // 2 x 128-bit Op + extract/insert
    { ISD::SADDSAT,    MVT::v16i16,  4 }, // 2 x 128-bit Op + extract/insert
    { ISD::SADDSAT,    MVT::v32i8,   4 }, // 2 x 128-bit Op + extract/insert
    { ISD::SSUBSAT,    MVT::v16i16,  4 }, // 2 x 128-bit Op + extract/insert
    { ISD::SSUBSAT,    MVT::v32i8,   4 }, // 2 x 128-bit Op + extract/insert
    { ISD::UADDSAT,    MVT::v16i16,  4 }, // 2 x 128-bit Op + extract/insert
    { ISD::UADDSAT,    MVT::v32i8,   4 }, // 2 x 128-bit Op + extract/insert
    { ISD::UADDSAT,    MVT::v8i32,   8 }, // 2 x 128-bit Op + extract/insert
    { ISD::USUBSAT,    MVT::v16i16,  4 }, // 2 x 128-bit Op + extract/insert
    { ISD::USUBSAT,    MVT::v32i8,   4 }, // 2 x 128-bit Op + extract/insert
    { ISD::USUBSAT,    MVT::v8i32,   6 }, // 2 x 128-bit Op + extract/insert
    { ISD::FMAXNUM,    MVT::f32,     3 },
    { ISD::FMAXNUM,    MVT::v4f32,   3 },
    { ISD::FMAXNUM,    MVT::v8f32,   5 },
    { ISD::FMAXNUM,    MVT::f64,     3 },
    { ISD::FMAXNUM,    MVT::v2f64,   3 },
    { ISD::FMAXNUM,    MVT::v4f64,   5 },
    { ISD::FSQRT,      MVT::f32,    14 }, // SNB from http://www.agner.org/
    { ISD::FSQRT,      MVT::v4f32,  14 }, // SNB from http://www.agner.org/
    { ISD::FSQRT,      MVT::v8f32,  28 }, // SNB from http://www.agner.org/
    { ISD::FSQRT,      MVT::f64,    21 }, // SNB from http://www.agner.org/
    { ISD::FSQRT,      MVT::v2f64,  21 }, // SNB from http://www.agner.org/
    { ISD::FSQRT,      MVT::v4f64,  43 }, // SNB from http://www.agner.org/
  };
  static const CostTblEntry GLMCostTbl[] = {
    { ISD::FSQRT, MVT::f32,   19 }, // sqrtss
    { ISD::FSQRT, MVT::v4f32, 37 }, // sqrtps
    { ISD::FSQRT, MVT::f64,   34 }, // sqrtsd
    { ISD::FSQRT, MVT::v2f64, 67 }, // sqrtpd
  };
  static const CostTblEntry SLMCostTbl[] = {
    { ISD::FSQRT, MVT::f32,   20 }, // sqrtss
    { ISD::FSQRT, MVT::v4f32, 40 }, // sqrtps
    { ISD::FSQRT, MVT::f64,   35 }, // sqrtsd
    { ISD::FSQRT, MVT::v2f64, 70 }, // sqrtpd
  };
  static const CostTblEntry SSE42CostTbl[] = {
    { ISD::USUBSAT,    MVT::v4i32,   2 }, // pmaxud + psubd
    { ISD::UADDSAT,    MVT::v4i32,   3 }, // not + pminud + paddd
    { ISD::FSQRT,      MVT::f32,    18 }, // Nehalem from http://www.agner.org/
    { ISD::FSQRT,      MVT::v4f32,  18 }, // Nehalem from http://www.agner.org/
  };
  static const CostTblEntry SSSE3CostTbl[] = {
    { ISD::BITREVERSE, MVT::v2i64,   5 },
    { ISD::BITREVERSE, MVT::v4i32,   5 },
    { ISD::BITREVERSE, MVT::v8i16,   5 },
    { ISD::BITREVERSE, MVT::v16i8,   5 },
    { ISD::BSWAP,      MVT::v2i64,   1 },
    { ISD::BSWAP,      MVT::v4i32,   1 },
    { ISD::BSWAP,      MVT::v8i16,   1 },
    { ISD::CTLZ,       MVT::v2i64,  23 },
    { ISD::CTLZ,       MVT::v4i32,  18 },
    { ISD::CTLZ,       MVT::v8i16,  14 },
    { ISD::CTLZ,       MVT::v16i8,   9 },
    { ISD::CTPOP,      MVT::v2i64,   7 },
    { ISD::CTPOP,      MVT::v4i32,  11 },
    { ISD::CTPOP,      MVT::v8i16,   9 },
    { ISD::CTPOP,      MVT::v16i8,   6 },
    { ISD::CTTZ,       MVT::v2i64,  10 },
    { ISD::CTTZ,       MVT::v4i32,  14 },
    { ISD::CTTZ,       MVT::v8i16,  12 },
    { ISD::CTTZ,       MVT::v16i8,   9 }
  };
  static const CostTblEntry SSE2CostTbl[] = {
    { ISD::BITREVERSE, MVT::v2i64,  29 },
    { ISD::BITREVERSE, MVT::v4i32,  27 },
    { ISD::BITREVERSE, MVT::v8i16,  27 },
    { ISD::BITREVERSE, MVT::v16i8,  20 },
    { ISD::BSWAP,      MVT::v2i64,   7 },
    { ISD::BSWAP,      MVT::v4i32,   7 },
    { ISD::BSWAP,      MVT::v8i16,   7 },
    { ISD::CTLZ,       MVT::v2i64,  25 },
    { ISD::CTLZ,       MVT::v4i32,  26 },
    { ISD::CTLZ,       MVT::v8i16,  20 },
    { ISD::CTLZ,       MVT::v16i8,  17 },
    { ISD::CTPOP,      MVT::v2i64,  12 },
    { ISD::CTPOP,      MVT::v4i32,  15 },
    { ISD::CTPOP,      MVT::v8i16,  13 },
    { ISD::CTPOP,      MVT::v16i8,  10 },
    { ISD::CTTZ,       MVT::v2i64,  14 },
    { ISD::CTTZ,       MVT::v4i32,  18 },
    { ISD::CTTZ,       MVT::v8i16,  16 },
    { ISD::CTTZ,       MVT::v16i8,  13 },
    { ISD::SADDSAT,    MVT::v8i16,   1 },
    { ISD::SADDSAT,    MVT::v16i8,   1 },
    { ISD::SSUBSAT,    MVT::v8i16,   1 },
    { ISD::SSUBSAT,    MVT::v16i8,   1 },
    { ISD::UADDSAT,    MVT::v8i16,   1 },
    { ISD::UADDSAT,    MVT::v16i8,   1 },
    { ISD::USUBSAT,    MVT::v8i16,   1 },
    { ISD::USUBSAT,    MVT::v16i8,   1 },
    { ISD::FMAXNUM,    MVT::f64,     4 },
    { ISD::FMAXNUM,    MVT::v2f64,   4 },
    { ISD::FSQRT,      MVT::f64,    32 }, // Nehalem from http://www.agner.org/
    { ISD::FSQRT,      MVT::v2f64,  32 }, // Nehalem from http://www.agner.org/
  };
  static const CostTblEntry SSE1CostTbl[] = {
    { ISD::FMAXNUM,    MVT::f32,     4 },
    { ISD::FMAXNUM,    MVT::v4f32,   4 },
    { ISD::FSQRT,      MVT::f32,    28 }, // Pentium III from http://www.agner.org/
    { ISD::FSQRT,      MVT::v4f32,  56 }, // Pentium III from http://www.agner.org/
  };
  static const CostTblEntry BMI64CostTbl[] = { // 64-bit targets
    { ISD::CTTZ,       MVT::i64,     1 },
  };
  static const CostTblEntry BMI32CostTbl[] = { // 32 or 64-bit targets
    { ISD::CTTZ,       MVT::i32,     1 },
    { ISD::CTTZ,       MVT::i16,     1 },
    { ISD::CTTZ,       MVT::i8,      1 },
  };
  static const CostTblEntry LZCNT64CostTbl[] = { // 64-bit targets
    { ISD::CTLZ,       MVT::i64,     1 },
  };
  static const CostTblEntry LZCNT32CostTbl[] = { // 32 or 64-bit targets
    { ISD::CTLZ,       MVT::i32,     1 },
    { ISD::CTLZ,       MVT::i16,     1 },
    { ISD::CTLZ,       MVT::i8,      1 },
  };
  static const CostTblEntry POPCNT64CostTbl[] = { // 64-bit targets
    { ISD::CTPOP,      MVT::i64,     1 },
  };
  static const CostTblEntry POPCNT32CostTbl[] = { // 32 or 64-bit targets
    { ISD::CTPOP,      MVT::i32,     1 },
    { ISD::CTPOP,      MVT::i16,     1 },
    { ISD::CTPOP,      MVT::i8,      1 },
  };
  static const CostTblEntry X64CostTbl[] = { // 64-bit targets
    { ISD::BITREVERSE, MVT::i64,    14 },
    { ISD::CTLZ,       MVT::i64,     4 }, // BSR+XOR or BSR+XOR+CMOV
    { ISD::CTTZ,       MVT::i64,     3 }, // TEST+BSF+CMOV/BRANCH
    { ISD::CTPOP,      MVT::i64,    10 },
    { ISD::SADDO,      MVT::i64,     1 },
    { ISD::UADDO,      MVT::i64,     1 },
  };
  static const CostTblEntry X86CostTbl[] = { // 32 or 64-bit targets
    { ISD::BITREVERSE, MVT::i32,    14 },
    { ISD::BITREVERSE, MVT::i16,    14 },
    { ISD::BITREVERSE, MVT::i8,     11 },
    { ISD::CTLZ,       MVT::i32,     4 }, // BSR+XOR or BSR+XOR+CMOV
    { ISD::CTLZ,       MVT::i16,     4 }, // BSR+XOR or BSR+XOR+CMOV
    { ISD::CTLZ,       MVT::i8,      4 }, // BSR+XOR or BSR+XOR+CMOV
    { ISD::CTTZ,       MVT::i32,     3 }, // TEST+BSF+CMOV/BRANCH
    { ISD::CTTZ,       MVT::i16,     3 }, // TEST+BSF+CMOV/BRANCH
    { ISD::CTTZ,       MVT::i8,      3 }, // TEST+BSF+CMOV/BRANCH
    { ISD::CTPOP,      MVT::i32,     8 },
    { ISD::CTPOP,      MVT::i16,     9 },
    { ISD::CTPOP,      MVT::i8,      7 },
    { ISD::SADDO,      MVT::i32,     1 },
    { ISD::SADDO,      MVT::i16,     1 },
    { ISD::SADDO,      MVT::i8,      1 },
    { ISD::UADDO,      MVT::i32,     1 },
    { ISD::UADDO,      MVT::i16,     1 },
    { ISD::UADDO,      MVT::i8,      1 },
  };

  Type *RetTy = ICA.getReturnType();
  Type *OpTy = RetTy;
  Intrinsic::ID IID = ICA.getID();
  unsigned ISD = ISD::DELETED_NODE;
  switch (IID) {
  default:
    break;
  case Intrinsic::bitreverse:
    ISD = ISD::BITREVERSE;
    break;
  case Intrinsic::bswap:
    ISD = ISD::BSWAP;
    break;
  case Intrinsic::ctlz:
    ISD = ISD::CTLZ;
    break;
  case Intrinsic::ctpop:
    ISD = ISD::CTPOP;
    break;
  case Intrinsic::cttz:
    ISD = ISD::CTTZ;
    break;
  case Intrinsic::maxnum:
  case Intrinsic::minnum:
    // FMINNUM has same costs so don't duplicate.
    ISD = ISD::FMAXNUM;
    break;
  case Intrinsic::sadd_sat:
    ISD = ISD::SADDSAT;
    break;
  case Intrinsic::ssub_sat:
    ISD = ISD::SSUBSAT;
    break;
  case Intrinsic::uadd_sat:
    ISD = ISD::UADDSAT;
    break;
  case Intrinsic::usub_sat:
    ISD = ISD::USUBSAT;
    break;
  case Intrinsic::sqrt:
    ISD = ISD::FSQRT;
    break;
  case Intrinsic::sadd_with_overflow:
  case Intrinsic::ssub_with_overflow:
    // SSUBO has same costs so don't duplicate.
    ISD = ISD::SADDO;
    OpTy = RetTy->getContainedType(0);
    break;
  case Intrinsic::uadd_with_overflow:
  case Intrinsic::usub_with_overflow:
    // USUBO has same costs so don't duplicate.
    ISD = ISD::UADDO;
    OpTy = RetTy->getContainedType(0);
    break;
  }

  if (ISD != ISD::DELETED_NODE) {
    // Legalize the type.
    std::pair<int, MVT> LT = TLI->getTypeLegalizationCost(DL, OpTy);
    MVT MTy = LT.second;

    // Attempt to lookup cost.
    if (ST->useGLMDivSqrtCosts())
      if (const auto *Entry = CostTableLookup(GLMCostTbl, ISD, MTy))
        return LT.first * Entry->Cost;

    if (ST->isSLM())
      if (const auto *Entry = CostTableLookup(SLMCostTbl, ISD, MTy))
        return LT.first * Entry->Cost;

    if (ST->hasCDI())
      if (const auto *Entry = CostTableLookup(AVX512CDCostTbl, ISD, MTy))
        return LT.first * Entry->Cost;

    if (ST->hasBWI())
      if (const auto *Entry = CostTableLookup(AVX512BWCostTbl, ISD, MTy))
        return LT.first * Entry->Cost;

    if (ST->hasAVX512())
      if (const auto *Entry = CostTableLookup(AVX512CostTbl, ISD, MTy))
        return LT.first * Entry->Cost;

    if (ST->hasXOP())
      if (const auto *Entry = CostTableLookup(XOPCostTbl, ISD, MTy))
        return LT.first * Entry->Cost;

    if (ST->hasAVX2())
      if (const auto *Entry = CostTableLookup(AVX2CostTbl, ISD, MTy))
        return LT.first * Entry->Cost;

    if (ST->hasAVX())
      if (const auto *Entry = CostTableLookup(AVX1CostTbl, ISD, MTy))
        return LT.first * Entry->Cost;

    if (ST->hasSSE42())
      if (const auto *Entry = CostTableLookup(SSE42CostTbl, ISD, MTy))
        return LT.first * Entry->Cost;

    if (ST->hasSSSE3())
      if (const auto *Entry = CostTableLookup(SSSE3CostTbl, ISD, MTy))
        return LT.first * Entry->Cost;

    if (ST->hasSSE2())
      if (const auto *Entry = CostTableLookup(SSE2CostTbl, ISD, MTy))
        return LT.first * Entry->Cost;

    if (ST->hasSSE1())
      if (const auto *Entry = CostTableLookup(SSE1CostTbl, ISD, MTy))
        return LT.first * Entry->Cost;

    if (ST->hasBMI()) {
      if (ST->is64Bit())
        if (const auto *Entry = CostTableLookup(BMI64CostTbl, ISD, MTy))
          return LT.first * Entry->Cost;

      if (const auto *Entry = CostTableLookup(BMI32CostTbl, ISD, MTy))
        return LT.first * Entry->Cost;
    }

    if (ST->hasLZCNT()) {
      if (ST->is64Bit())
        if (const auto *Entry = CostTableLookup(LZCNT64CostTbl, ISD, MTy))
          return LT.first * Entry->Cost;

      if (const auto *Entry = CostTableLookup(LZCNT32CostTbl, ISD, MTy))
        return LT.first * Entry->Cost;
    }

    if (ST->hasPOPCNT()) {
      if (ST->is64Bit())
        if (const auto *Entry = CostTableLookup(POPCNT64CostTbl, ISD, MTy))
          return LT.first * Entry->Cost;

      if (const auto *Entry = CostTableLookup(POPCNT32CostTbl, ISD, MTy))
        return LT.first * Entry->Cost;
    }

    // TODO - add BMI (TZCNT) scalar handling

    if (ST->is64Bit())
      if (const auto *Entry = CostTableLookup(X64CostTbl, ISD, MTy))
        return LT.first * Entry->Cost;

    if (const auto *Entry = CostTableLookup(X86CostTbl, ISD, MTy))
      return LT.first * Entry->Cost;
  }

  return BaseT::getIntrinsicInstrCost(ICA, CostKind);
}

int X86TTIImpl::getIntrinsicInstrCost(const IntrinsicCostAttributes &ICA,
                                      TTI::TargetCostKind CostKind) {
  if (CostKind != TTI::TCK_RecipThroughput)
    return BaseT::getIntrinsicInstrCost(ICA, CostKind);

  if (ICA.isTypeBasedOnly())
    return getTypeBasedIntrinsicInstrCost(ICA, CostKind);

  static const CostTblEntry AVX512CostTbl[] = {
    { ISD::ROTL,       MVT::v8i64,   1 },
    { ISD::ROTL,       MVT::v4i64,   1 },
    { ISD::ROTL,       MVT::v2i64,   1 },
    { ISD::ROTL,       MVT::v16i32,  1 },
    { ISD::ROTL,       MVT::v8i32,   1 },
    { ISD::ROTL,       MVT::v4i32,   1 },
    { ISD::ROTR,       MVT::v8i64,   1 },
    { ISD::ROTR,       MVT::v4i64,   1 },
    { ISD::ROTR,       MVT::v2i64,   1 },
    { ISD::ROTR,       MVT::v16i32,  1 },
    { ISD::ROTR,       MVT::v8i32,   1 },
    { ISD::ROTR,       MVT::v4i32,   1 }
  };
  // XOP: ROTL = VPROT(X,Y), ROTR = VPROT(X,SUB(0,Y))
  static const CostTblEntry XOPCostTbl[] = {
    { ISD::ROTL,       MVT::v4i64,   4 },
    { ISD::ROTL,       MVT::v8i32,   4 },
    { ISD::ROTL,       MVT::v16i16,  4 },
    { ISD::ROTL,       MVT::v32i8,   4 },
    { ISD::ROTL,       MVT::v2i64,   1 },
    { ISD::ROTL,       MVT::v4i32,   1 },
    { ISD::ROTL,       MVT::v8i16,   1 },
    { ISD::ROTL,       MVT::v16i8,   1 },
    { ISD::ROTR,       MVT::v4i64,   6 },
    { ISD::ROTR,       MVT::v8i32,   6 },
    { ISD::ROTR,       MVT::v16i16,  6 },
    { ISD::ROTR,       MVT::v32i8,   6 },
    { ISD::ROTR,       MVT::v2i64,   2 },
    { ISD::ROTR,       MVT::v4i32,   2 },
    { ISD::ROTR,       MVT::v8i16,   2 },
    { ISD::ROTR,       MVT::v16i8,   2 }
  };
  static const CostTblEntry X64CostTbl[] = { // 64-bit targets
    { ISD::ROTL,       MVT::i64,     1 },
    { ISD::ROTR,       MVT::i64,     1 },
    { ISD::FSHL,       MVT::i64,     4 }
  };
  static const CostTblEntry X86CostTbl[] = { // 32 or 64-bit targets
    { ISD::ROTL,       MVT::i32,     1 },
    { ISD::ROTL,       MVT::i16,     1 },
    { ISD::ROTL,       MVT::i8,      1 },
    { ISD::ROTR,       MVT::i32,     1 },
    { ISD::ROTR,       MVT::i16,     1 },
    { ISD::ROTR,       MVT::i8,      1 },
    { ISD::FSHL,       MVT::i32,     4 },
    { ISD::FSHL,       MVT::i16,     4 },
    { ISD::FSHL,       MVT::i8,      4 }
  };

  Intrinsic::ID IID = ICA.getID();
  Type *RetTy = ICA.getReturnType();
  const SmallVectorImpl<Value *> &Args = ICA.getArgs();
  unsigned ISD = ISD::DELETED_NODE;
  switch (IID) {
  default:
    break;
  case Intrinsic::fshl:
    ISD = ISD::FSHL;
    if (Args[0] == Args[1])
      ISD = ISD::ROTL;
    break;
  case Intrinsic::fshr:
    // FSHR has same costs so don't duplicate.
    ISD = ISD::FSHL;
    if (Args[0] == Args[1])
      ISD = ISD::ROTR;
    break;
  }

  if (ISD != ISD::DELETED_NODE) {
    // Legalize the type.
    std::pair<int, MVT> LT = TLI->getTypeLegalizationCost(DL, RetTy);
    MVT MTy = LT.second;

    // Attempt to lookup cost.
    if (ST->hasAVX512())
      if (const auto *Entry = CostTableLookup(AVX512CostTbl, ISD, MTy))
        return LT.first * Entry->Cost;

    if (ST->hasXOP())
      if (const auto *Entry = CostTableLookup(XOPCostTbl, ISD, MTy))
        return LT.first * Entry->Cost;

    if (ST->is64Bit())
      if (const auto *Entry = CostTableLookup(X64CostTbl, ISD, MTy))
        return LT.first * Entry->Cost;

    if (const auto *Entry = CostTableLookup(X86CostTbl, ISD, MTy))
      return LT.first * Entry->Cost;
  }

  return BaseT::getIntrinsicInstrCost(ICA, CostKind);
}

int X86TTIImpl::getVectorInstrCost(unsigned Opcode, Type *Val, unsigned Index) {
  static const CostTblEntry SLMCostTbl[] = {
     { ISD::EXTRACT_VECTOR_ELT,       MVT::i8,      4 },
     { ISD::EXTRACT_VECTOR_ELT,       MVT::i16,     4 },
     { ISD::EXTRACT_VECTOR_ELT,       MVT::i32,     4 },
     { ISD::EXTRACT_VECTOR_ELT,       MVT::i64,     7 }
   };

  assert(Val->isVectorTy() && "This must be a vector type");
  Type *ScalarType = Val->getScalarType();
  int RegisterFileMoveCost = 0;

  if (Index != -1U && (Opcode == Instruction::ExtractElement ||
                       Opcode == Instruction::InsertElement)) {
    // Legalize the type.
    std::pair<int, MVT> LT = TLI->getTypeLegalizationCost(DL, Val);

    // This type is legalized to a scalar type.
    if (!LT.second.isVector())
      return 0;

    // The type may be split. Normalize the index to the new type.
    unsigned NumElts = LT.second.getVectorNumElements();
    unsigned SubNumElts = NumElts;
    Index = Index % NumElts;

    // For >128-bit vectors, we need to extract higher 128-bit subvectors.
    // For inserts, we also need to insert the subvector back.
    if (LT.second.getSizeInBits() > 128) {
      assert((LT.second.getSizeInBits() % 128) == 0 && "Illegal vector");
      unsigned NumSubVecs = LT.second.getSizeInBits() / 128;
      SubNumElts = NumElts / NumSubVecs;
      if (SubNumElts <= Index) {
        RegisterFileMoveCost += (Opcode == Instruction::InsertElement ? 2 : 1);
        Index %= SubNumElts;
      }
    }

    if (Index == 0) {
      // Floating point scalars are already located in index #0.
      // Many insertions to #0 can fold away for scalar fp-ops, so let's assume
      // true for all.
      if (ScalarType->isFloatingPointTy())
        return RegisterFileMoveCost;

      // Assume movd/movq XMM -> GPR is relatively cheap on all targets.
      if (ScalarType->isIntegerTy() && Opcode == Instruction::ExtractElement)
        return 1 + RegisterFileMoveCost;
    }

    int ISD = TLI->InstructionOpcodeToISD(Opcode);
    assert(ISD && "Unexpected vector opcode");
    MVT MScalarTy = LT.second.getScalarType();
    if (ST->isSLM())
      if (auto *Entry = CostTableLookup(SLMCostTbl, ISD, MScalarTy))
        return Entry->Cost + RegisterFileMoveCost;

    // Assume pinsr/pextr XMM <-> GPR is relatively cheap on all targets.
    if ((MScalarTy == MVT::i16 && ST->hasSSE2()) ||
        (MScalarTy.isInteger() && ST->hasSSE41()))
      return 1 + RegisterFileMoveCost;

    // Assume insertps is relatively cheap on all targets.
    if (MScalarTy == MVT::f32 && ST->hasSSE41() &&
        Opcode == Instruction::InsertElement)
      return 1 + RegisterFileMoveCost;

    // For extractions we just need to shuffle the element to index 0, which
    // should be very cheap (assume cost = 1). For insertions we need to shuffle
    // the elements to its destination. In both cases we must handle the
    // subvector move(s).
    // If the vector type is already less than 128-bits then don't reduce it.
    // TODO: Under what circumstances should we shuffle using the full width?
    int ShuffleCost = 1;
    if (Opcode == Instruction::InsertElement) {
      auto *SubTy = cast<VectorType>(Val);
      EVT VT = TLI->getValueType(DL, Val);
      if (VT.getScalarType() != MScalarTy || VT.getSizeInBits() >= 128)
        SubTy = VectorType::get(ScalarType, SubNumElts);
      ShuffleCost = getShuffleCost(TTI::SK_PermuteTwoSrc, SubTy, 0, SubTy);
    }
    int IntOrFpCost = ScalarType->isFloatingPointTy() ? 0 : 1;
    return ShuffleCost + IntOrFpCost + RegisterFileMoveCost;
  }

  // Add to the base cost if we know that the extracted element of a vector is
  // destined to be moved to and used in the integer register file.
  if (Opcode == Instruction::ExtractElement && ScalarType->isPointerTy())
    RegisterFileMoveCost += 1;

  return BaseT::getVectorInstrCost(Opcode, Val, Index) + RegisterFileMoveCost;
}

unsigned X86TTIImpl::getScalarizationOverhead(VectorType *Ty,
                                              const APInt &DemandedElts,
                                              bool Insert, bool Extract) {
  unsigned Cost = 0;

  // For insertions, a ISD::BUILD_VECTOR style vector initialization can be much
  // cheaper than an accumulation of ISD::INSERT_VECTOR_ELT.
  if (Insert) {
    std::pair<int, MVT> LT = TLI->getTypeLegalizationCost(DL, Ty);
    MVT MScalarTy = LT.second.getScalarType();

    if ((MScalarTy == MVT::i16 && ST->hasSSE2()) ||
        (MScalarTy.isInteger() && ST->hasSSE41()) ||
        (MScalarTy == MVT::f32 && ST->hasSSE41())) {
      // For types we can insert directly, insertion into 128-bit sub vectors is
      // cheap, followed by a cheap chain of concatenations.
      if (LT.second.getSizeInBits() <= 128) {
        Cost +=
            BaseT::getScalarizationOverhead(Ty, DemandedElts, Insert, false);
      } else {
        unsigned NumSubVecs = LT.second.getSizeInBits() / 128;
        Cost += (PowerOf2Ceil(NumSubVecs) - 1) * LT.first;
        Cost += DemandedElts.countPopulation();

        // For vXf32 cases, insertion into the 0'th index in each v4f32
        // 128-bit vector is free.
        // NOTE: This assumes legalization widens vXf32 vectors.
        if (MScalarTy == MVT::f32)
          for (unsigned i = 0, e = Ty->getNumElements(); i < e; i += 4)
            if (DemandedElts[i])
              Cost--;
      }
    } else if (LT.second.isVector()) {
      // Without fast insertion, we need to use MOVD/MOVQ to pass each demanded
      // integer element as a SCALAR_TO_VECTOR, then we build the vector as a
      // series of UNPCK followed by CONCAT_VECTORS - all of these can be
      // considered cheap.
      if (Ty->isIntOrIntVectorTy())
        Cost += DemandedElts.countPopulation();

      // Get the smaller of the legalized or original pow2-extended number of
      // vector elements, which represents the number of unpacks we'll end up
      // performing.
      unsigned NumElts = LT.second.getVectorNumElements();
      unsigned Pow2Elts = PowerOf2Ceil(Ty->getNumElements());
      Cost += (std::min<unsigned>(NumElts, Pow2Elts) - 1) * LT.first;
    }
  }

  // TODO: Use default extraction for now, but we should investigate extending this
  // to handle repeated subvector extraction.
  if (Extract)
    Cost += BaseT::getScalarizationOverhead(Ty, DemandedElts, false, Extract);

  return Cost;
}

int X86TTIImpl::getMemoryOpCost(unsigned Opcode, Type *Src,
                                MaybeAlign Alignment, unsigned AddressSpace,
                                TTI::TargetCostKind CostKind,
                                const Instruction *I) {
  // TODO: Handle other cost kinds.
  if (CostKind != TTI::TCK_RecipThroughput) {
    if (isa_and_nonnull<StoreInst>(I)) {
      Value *Ptr = I->getOperand(1);
      // Store instruction with index and scale costs 2 Uops.
      // Check the preceding GEP to identify non-const indices.
      if (auto *GEP = dyn_cast<GetElementPtrInst>(Ptr)) {
        if (!all_of(GEP->indices(), [](Value *V) { return isa<Constant>(V); }))
          return TTI::TCC_Basic * 2;
      }
    }
    return TTI::TCC_Basic;
  }

  // Handle non-power-of-two vectors such as <3 x float>
  if (VectorType *VTy = dyn_cast<VectorType>(Src)) {
    unsigned NumElem = VTy->getNumElements();

    // Handle a few common cases:
    // <3 x float>
    if (NumElem == 3 && VTy->getScalarSizeInBits() == 32)
      // Cost = 64 bit store + extract + 32 bit store.
      return 3;

    // <3 x double>
    if (NumElem == 3 && VTy->getScalarSizeInBits() == 64)
      // Cost = 128 bit store + unpack + 64 bit store.
      return 3;

    // Assume that all other non-power-of-two numbers are scalarized.
    if (!isPowerOf2_32(NumElem)) {
      APInt DemandedElts = APInt::getAllOnesValue(NumElem);
      int Cost = BaseT::getMemoryOpCost(Opcode, VTy->getScalarType(), Alignment,
                                        AddressSpace, CostKind);
      int SplitCost = getScalarizationOverhead(VTy, DemandedElts,
                                               Opcode == Instruction::Load,
                                               Opcode == Instruction::Store);
      return NumElem * Cost + SplitCost;
    }
  }

  // Type legalization can't handle structs
  if (TLI->getValueType(DL, Src,  true) == MVT::Other)
    return BaseT::getMemoryOpCost(Opcode, Src, Alignment, AddressSpace,
                                  CostKind);

  // Legalize the type.
  std::pair<int, MVT> LT = TLI->getTypeLegalizationCost(DL, Src);
  assert((Opcode == Instruction::Load || Opcode == Instruction::Store) &&
         "Invalid Opcode");

  // Each load/store unit costs 1.
  int Cost = LT.first * 1;

  // This isn't exactly right. We're using slow unaligned 32-byte accesses as a
  // proxy for a double-pumped AVX memory interface such as on Sandybridge.
  if (LT.second.getStoreSize() == 32 && ST->isUnalignedMem32Slow())
    Cost *= 2;

  return Cost;
}

int X86TTIImpl::getMaskedMemoryOpCost(unsigned Opcode, Type *SrcTy,
                                      unsigned Alignment,
                                      unsigned AddressSpace,
                                      TTI::TargetCostKind CostKind) {
  bool IsLoad = (Instruction::Load == Opcode);
  bool IsStore = (Instruction::Store == Opcode);

  VectorType *SrcVTy = dyn_cast<VectorType>(SrcTy);
  if (!SrcVTy)
    // To calculate scalar take the regular cost, without mask
    return getMemoryOpCost(Opcode, SrcTy, MaybeAlign(Alignment), AddressSpace,
                           CostKind);

  unsigned NumElem = SrcVTy->getNumElements();
  VectorType *MaskTy =
      VectorType::get(Type::getInt8Ty(SrcVTy->getContext()), NumElem);
  if ((IsLoad && !isLegalMaskedLoad(SrcVTy, MaybeAlign(Alignment))) ||
      (IsStore && !isLegalMaskedStore(SrcVTy, MaybeAlign(Alignment))) ||
      !isPowerOf2_32(NumElem)) {
    // Scalarization
    APInt DemandedElts = APInt::getAllOnesValue(NumElem);
    int MaskSplitCost =
        getScalarizationOverhead(MaskTy, DemandedElts, false, true);
    int ScalarCompareCost = getCmpSelInstrCost(
        Instruction::ICmp, Type::getInt8Ty(SrcVTy->getContext()), nullptr,
        CostKind);
    int BranchCost = getCFInstrCost(Instruction::Br, CostKind);
    int MaskCmpCost = NumElem * (BranchCost + ScalarCompareCost);
    int ValueSplitCost =
        getScalarizationOverhead(SrcVTy, DemandedElts, IsLoad, IsStore);
    int MemopCost =
        NumElem * BaseT::getMemoryOpCost(Opcode, SrcVTy->getScalarType(),
                                         MaybeAlign(Alignment), AddressSpace,
                                         CostKind);
    return MemopCost + ValueSplitCost + MaskSplitCost + MaskCmpCost;
  }

  // Legalize the type.
  std::pair<int, MVT> LT = TLI->getTypeLegalizationCost(DL, SrcVTy);
  auto VT = TLI->getValueType(DL, SrcVTy);
  int Cost = 0;
  if (VT.isSimple() && LT.second != VT.getSimpleVT() &&
      LT.second.getVectorNumElements() == NumElem)
    // Promotion requires expand/truncate for data and a shuffle for mask.
    Cost += getShuffleCost(TTI::SK_PermuteTwoSrc, SrcVTy, 0, nullptr) +
            getShuffleCost(TTI::SK_PermuteTwoSrc, MaskTy, 0, nullptr);

  else if (LT.second.getVectorNumElements() > NumElem) {
    VectorType *NewMaskTy = VectorType::get(MaskTy->getElementType(),
                                            LT.second.getVectorNumElements());
    // Expanding requires fill mask with zeroes
    Cost += getShuffleCost(TTI::SK_InsertSubvector, NewMaskTy, 0, MaskTy);
  }

  // Pre-AVX512 - each maskmov load costs 2 + store costs ~8.
  if (!ST->hasAVX512())
    return Cost + LT.first * (IsLoad ? 2 : 8);

  // AVX-512 masked load/store is cheapper
  return Cost + LT.first;
}

int X86TTIImpl::getAddressComputationCost(Type *Ty, ScalarEvolution *SE,
                                          const SCEV *Ptr) {
  // Address computations in vectorized code with non-consecutive addresses will
  // likely result in more instructions compared to scalar code where the
  // computation can more often be merged into the index mode. The resulting
  // extra micro-ops can significantly decrease throughput.
  const unsigned NumVectorInstToHideOverhead = 10;

  // Cost modeling of Strided Access Computation is hidden by the indexing
  // modes of X86 regardless of the stride value. We dont believe that there
  // is a difference between constant strided access in gerenal and constant
  // strided value which is less than or equal to 64.
  // Even in the case of (loop invariant) stride whose value is not known at
  // compile time, the address computation will not incur more than one extra
  // ADD instruction.
  if (Ty->isVectorTy() && SE) {
    if (!BaseT::isStridedAccess(Ptr))
      return NumVectorInstToHideOverhead;
    if (!BaseT::getConstantStrideStep(SE, Ptr))
      return 1;
  }

  return BaseT::getAddressComputationCost(Ty, SE, Ptr);
}

int X86TTIImpl::getArithmeticReductionCost(unsigned Opcode, VectorType *ValTy,
                                           bool IsPairwise,
                                           TTI::TargetCostKind CostKind) {
  // Just use the default implementation for pair reductions.
  if (IsPairwise)
    return BaseT::getArithmeticReductionCost(Opcode, ValTy, IsPairwise, CostKind);

  // We use the Intel Architecture Code Analyzer(IACA) to measure the throughput
  // and make it as the cost.

  static const CostTblEntry SLMCostTblNoPairWise[] = {
    { ISD::FADD,  MVT::v2f64,   3 },
    { ISD::ADD,   MVT::v2i64,   5 },
  };

  static const CostTblEntry SSE2CostTblNoPairWise[] = {
    { ISD::FADD,  MVT::v2f64,   2 },
    { ISD::FADD,  MVT::v4f32,   4 },
    { ISD::ADD,   MVT::v2i64,   2 },      // The data reported by the IACA tool is "1.6".
    { ISD::ADD,   MVT::v2i32,   2 }, // FIXME: chosen to be less than v4i32
    { ISD::ADD,   MVT::v4i32,   3 },      // The data reported by the IACA tool is "3.3".
    { ISD::ADD,   MVT::v2i16,   2 },      // The data reported by the IACA tool is "4.3".
    { ISD::ADD,   MVT::v4i16,   3 },      // The data reported by the IACA tool is "4.3".
    { ISD::ADD,   MVT::v8i16,   4 },      // The data reported by the IACA tool is "4.3".
    { ISD::ADD,   MVT::v2i8,    2 },
    { ISD::ADD,   MVT::v4i8,    2 },
    { ISD::ADD,   MVT::v8i8,    2 },
    { ISD::ADD,   MVT::v16i8,   3 },
  };

  static const CostTblEntry AVX1CostTblNoPairWise[] = {
    { ISD::FADD,  MVT::v4f64,   3 },
    { ISD::FADD,  MVT::v4f32,   3 },
    { ISD::FADD,  MVT::v8f32,   4 },
    { ISD::ADD,   MVT::v2i64,   1 },      // The data reported by the IACA tool is "1.5".
    { ISD::ADD,   MVT::v4i64,   3 },
    { ISD::ADD,   MVT::v8i32,   5 },
    { ISD::ADD,   MVT::v16i16,  5 },
    { ISD::ADD,   MVT::v32i8,   4 },
  };

  int ISD = TLI->InstructionOpcodeToISD(Opcode);
  assert(ISD && "Invalid opcode");

  // Before legalizing the type, give a chance to look up illegal narrow types
  // in the table.
  // FIXME: Is there a better way to do this?
  EVT VT = TLI->getValueType(DL, ValTy);
  if (VT.isSimple()) {
    MVT MTy = VT.getSimpleVT();
    if (ST->isSLM())
      if (const auto *Entry = CostTableLookup(SLMCostTblNoPairWise, ISD, MTy))
        return Entry->Cost;

    if (ST->hasAVX())
      if (const auto *Entry = CostTableLookup(AVX1CostTblNoPairWise, ISD, MTy))
        return Entry->Cost;

    if (ST->hasSSE2())
      if (const auto *Entry = CostTableLookup(SSE2CostTblNoPairWise, ISD, MTy))
        return Entry->Cost;
  }

  std::pair<int, MVT> LT = TLI->getTypeLegalizationCost(DL, ValTy);

  MVT MTy = LT.second;

  auto *ValVTy = cast<VectorType>(ValTy);

  unsigned ArithmeticCost = 0;
  if (LT.first != 1 && MTy.isVector() &&
      MTy.getVectorNumElements() < ValVTy->getNumElements()) {
    // Type needs to be split. We need LT.first - 1 arithmetic ops.
    auto *SingleOpTy = FixedVectorType::get(ValVTy->getElementType(),
                                            MTy.getVectorNumElements());
    ArithmeticCost = getArithmeticInstrCost(Opcode, SingleOpTy, CostKind);
    ArithmeticCost *= LT.first - 1;
  }

  if (ST->isSLM())
    if (const auto *Entry = CostTableLookup(SLMCostTblNoPairWise, ISD, MTy))
      return ArithmeticCost + Entry->Cost;

  if (ST->hasAVX())
    if (const auto *Entry = CostTableLookup(AVX1CostTblNoPairWise, ISD, MTy))
      return ArithmeticCost + Entry->Cost;

  if (ST->hasSSE2())
    if (const auto *Entry = CostTableLookup(SSE2CostTblNoPairWise, ISD, MTy))
      return ArithmeticCost + Entry->Cost;

  // FIXME: These assume a naive kshift+binop lowering, which is probably
  // conservative in most cases.
  static const CostTblEntry AVX512BoolReduction[] = {
    { ISD::AND,  MVT::v2i1,   3 },
    { ISD::AND,  MVT::v4i1,   5 },
    { ISD::AND,  MVT::v8i1,   7 },
    { ISD::AND,  MVT::v16i1,  9 },
    { ISD::AND,  MVT::v32i1, 11 },
    { ISD::AND,  MVT::v64i1, 13 },
    { ISD::OR,   MVT::v2i1,   3 },
    { ISD::OR,   MVT::v4i1,   5 },
    { ISD::OR,   MVT::v8i1,   7 },
    { ISD::OR,   MVT::v16i1,  9 },
    { ISD::OR,   MVT::v32i1, 11 },
    { ISD::OR,   MVT::v64i1, 13 },
  };

  static const CostTblEntry AVX2BoolReduction[] = {
    { ISD::AND,  MVT::v16i16,  2 }, // vpmovmskb + cmp
    { ISD::AND,  MVT::v32i8,   2 }, // vpmovmskb + cmp
    { ISD::OR,   MVT::v16i16,  2 }, // vpmovmskb + cmp
    { ISD::OR,   MVT::v32i8,   2 }, // vpmovmskb + cmp
  };

  static const CostTblEntry AVX1BoolReduction[] = {
    { ISD::AND,  MVT::v4i64,   2 }, // vmovmskpd + cmp
    { ISD::AND,  MVT::v8i32,   2 }, // vmovmskps + cmp
    { ISD::AND,  MVT::v16i16,  4 }, // vextractf128 + vpand + vpmovmskb + cmp
    { ISD::AND,  MVT::v32i8,   4 }, // vextractf128 + vpand + vpmovmskb + cmp
    { ISD::OR,   MVT::v4i64,   2 }, // vmovmskpd + cmp
    { ISD::OR,   MVT::v8i32,   2 }, // vmovmskps + cmp
    { ISD::OR,   MVT::v16i16,  4 }, // vextractf128 + vpor + vpmovmskb + cmp
    { ISD::OR,   MVT::v32i8,   4 }, // vextractf128 + vpor + vpmovmskb + cmp
  };

  static const CostTblEntry SSE2BoolReduction[] = {
    { ISD::AND,  MVT::v2i64,   2 }, // movmskpd + cmp
    { ISD::AND,  MVT::v4i32,   2 }, // movmskps + cmp
    { ISD::AND,  MVT::v8i16,   2 }, // pmovmskb + cmp
    { ISD::AND,  MVT::v16i8,   2 }, // pmovmskb + cmp
    { ISD::OR,   MVT::v2i64,   2 }, // movmskpd + cmp
    { ISD::OR,   MVT::v4i32,   2 }, // movmskps + cmp
    { ISD::OR,   MVT::v8i16,   2 }, // pmovmskb + cmp
    { ISD::OR,   MVT::v16i8,   2 }, // pmovmskb + cmp
  };

  // Handle bool allof/anyof patterns.
  if (ValVTy->getElementType()->isIntegerTy(1)) {
    unsigned ArithmeticCost = 0;
    if (LT.first != 1 && MTy.isVector() &&
        MTy.getVectorNumElements() < ValVTy->getNumElements()) {
      // Type needs to be split. We need LT.first - 1 arithmetic ops.
      auto *SingleOpTy = FixedVectorType::get(ValVTy->getElementType(),
                                              MTy.getVectorNumElements());
      ArithmeticCost = getArithmeticInstrCost(Opcode, SingleOpTy, CostKind);
      ArithmeticCost *= LT.first - 1;
    }

    if (ST->hasAVX512())
      if (const auto *Entry = CostTableLookup(AVX512BoolReduction, ISD, MTy))
        return ArithmeticCost + Entry->Cost;
    if (ST->hasAVX2())
      if (const auto *Entry = CostTableLookup(AVX2BoolReduction, ISD, MTy))
        return ArithmeticCost + Entry->Cost;
    if (ST->hasAVX())
      if (const auto *Entry = CostTableLookup(AVX1BoolReduction, ISD, MTy))
        return ArithmeticCost + Entry->Cost;
    if (ST->hasSSE2())
      if (const auto *Entry = CostTableLookup(SSE2BoolReduction, ISD, MTy))
        return ArithmeticCost + Entry->Cost;

    return BaseT::getArithmeticReductionCost(Opcode, ValVTy, IsPairwise,
                                             CostKind);
  }

  unsigned NumVecElts = ValVTy->getNumElements();
  unsigned ScalarSize = ValVTy->getScalarSizeInBits();

  // Special case power of 2 reductions where the scalar type isn't changed
  // by type legalization.
  if (!isPowerOf2_32(NumVecElts) || ScalarSize != MTy.getScalarSizeInBits())
    return BaseT::getArithmeticReductionCost(Opcode, ValVTy, IsPairwise,
                                             CostKind);

  unsigned ReductionCost = 0;

  auto *Ty = ValVTy;
  if (LT.first != 1 && MTy.isVector() &&
      MTy.getVectorNumElements() < ValVTy->getNumElements()) {
    // Type needs to be split. We need LT.first - 1 arithmetic ops.
    Ty = VectorType::get(ValVTy->getElementType(), MTy.getVectorNumElements());
    ReductionCost = getArithmeticInstrCost(Opcode, Ty, CostKind);
    ReductionCost *= LT.first - 1;
    NumVecElts = MTy.getVectorNumElements();
  }

  // Now handle reduction with the legal type, taking into account size changes
  // at each level.
  while (NumVecElts > 1) {
    // Determine the size of the remaining vector we need to reduce.
    unsigned Size = NumVecElts * ScalarSize;
    NumVecElts /= 2;
    // If we're reducing from 256/512 bits, use an extract_subvector.
    if (Size > 128) {
      auto *SubTy = VectorType::get(ValVTy->getElementType(), NumVecElts);
      ReductionCost +=
          getShuffleCost(TTI::SK_ExtractSubvector, Ty, NumVecElts, SubTy);
      Ty = SubTy;
    } else if (Size == 128) {
      // Reducing from 128 bits is a permute of v2f64/v2i64.
      VectorType *ShufTy;
      if (ValVTy->isFloatingPointTy())
        ShufTy = VectorType::get(Type::getDoubleTy(ValVTy->getContext()), 2);
      else
        ShufTy = VectorType::get(Type::getInt64Ty(ValVTy->getContext()), 2);
      ReductionCost +=
          getShuffleCost(TTI::SK_PermuteSingleSrc, ShufTy, 0, nullptr);
    } else if (Size == 64) {
      // Reducing from 64 bits is a shuffle of v4f32/v4i32.
      VectorType *ShufTy;
      if (ValVTy->isFloatingPointTy())
        ShufTy = VectorType::get(Type::getFloatTy(ValVTy->getContext()), 4);
      else
        ShufTy = VectorType::get(Type::getInt32Ty(ValVTy->getContext()), 4);
      ReductionCost +=
          getShuffleCost(TTI::SK_PermuteSingleSrc, ShufTy, 0, nullptr);
    } else {
      // Reducing from smaller size is a shift by immediate.
      auto *ShiftTy = FixedVectorType::get(
          Type::getIntNTy(ValVTy->getContext(), Size), 128 / Size);
      ReductionCost += getArithmeticInstrCost(
          Instruction::LShr, ShiftTy, CostKind,
          TargetTransformInfo::OK_AnyValue,
          TargetTransformInfo::OK_UniformConstantValue,
          TargetTransformInfo::OP_None, TargetTransformInfo::OP_None);
    }

    // Add the arithmetic op for this level.
    ReductionCost += getArithmeticInstrCost(Opcode, Ty, CostKind);
  }

  // Add the final extract element to the cost.
  return ReductionCost + getVectorInstrCost(Instruction::ExtractElement, Ty, 0);
}

int X86TTIImpl::getMinMaxCost(Type *Ty, Type *CondTy, bool IsUnsigned) {
  std::pair<int, MVT> LT = TLI->getTypeLegalizationCost(DL, Ty);

  MVT MTy = LT.second;

  int ISD;
  if (Ty->isIntOrIntVectorTy()) {
    ISD = IsUnsigned ? ISD::UMIN : ISD::SMIN;
  } else {
    assert(Ty->isFPOrFPVectorTy() &&
           "Expected float point or integer vector type.");
    ISD = ISD::FMINNUM;
  }

  static const CostTblEntry SSE1CostTbl[] = {
    {ISD::FMINNUM, MVT::v4f32, 1},
  };

  static const CostTblEntry SSE2CostTbl[] = {
    {ISD::FMINNUM, MVT::v2f64, 1},
    {ISD::SMIN,    MVT::v8i16, 1},
    {ISD::UMIN,    MVT::v16i8, 1},
  };

  static const CostTblEntry SSE41CostTbl[] = {
    {ISD::SMIN,    MVT::v4i32, 1},
    {ISD::UMIN,    MVT::v4i32, 1},
    {ISD::UMIN,    MVT::v8i16, 1},
    {ISD::SMIN,    MVT::v16i8, 1},
  };

  static const CostTblEntry SSE42CostTbl[] = {
    {ISD::UMIN,    MVT::v2i64, 3}, // xor+pcmpgtq+blendvpd
  };

  static const CostTblEntry AVX1CostTbl[] = {
    {ISD::FMINNUM, MVT::v8f32,  1},
    {ISD::FMINNUM, MVT::v4f64,  1},
    {ISD::SMIN,    MVT::v8i32,  3},
    {ISD::UMIN,    MVT::v8i32,  3},
    {ISD::SMIN,    MVT::v16i16, 3},
    {ISD::UMIN,    MVT::v16i16, 3},
    {ISD::SMIN,    MVT::v32i8,  3},
    {ISD::UMIN,    MVT::v32i8,  3},
  };

  static const CostTblEntry AVX2CostTbl[] = {
    {ISD::SMIN,    MVT::v8i32,  1},
    {ISD::UMIN,    MVT::v8i32,  1},
    {ISD::SMIN,    MVT::v16i16, 1},
    {ISD::UMIN,    MVT::v16i16, 1},
    {ISD::SMIN,    MVT::v32i8,  1},
    {ISD::UMIN,    MVT::v32i8,  1},
  };

  static const CostTblEntry AVX512CostTbl[] = {
    {ISD::FMINNUM, MVT::v16f32, 1},
    {ISD::FMINNUM, MVT::v8f64,  1},
    {ISD::SMIN,    MVT::v2i64,  1},
    {ISD::UMIN,    MVT::v2i64,  1},
    {ISD::SMIN,    MVT::v4i64,  1},
    {ISD::UMIN,    MVT::v4i64,  1},
    {ISD::SMIN,    MVT::v8i64,  1},
    {ISD::UMIN,    MVT::v8i64,  1},
    {ISD::SMIN,    MVT::v16i32, 1},
    {ISD::UMIN,    MVT::v16i32, 1},
  };

  static const CostTblEntry AVX512BWCostTbl[] = {
    {ISD::SMIN,    MVT::v32i16, 1},
    {ISD::UMIN,    MVT::v32i16, 1},
    {ISD::SMIN,    MVT::v64i8,  1},
    {ISD::UMIN,    MVT::v64i8,  1},
  };

  // If we have a native MIN/MAX instruction for this type, use it.
  if (ST->hasBWI())
    if (const auto *Entry = CostTableLookup(AVX512BWCostTbl, ISD, MTy))
      return LT.first * Entry->Cost;

  if (ST->hasAVX512())
    if (const auto *Entry = CostTableLookup(AVX512CostTbl, ISD, MTy))
      return LT.first * Entry->Cost;

  if (ST->hasAVX2())
    if (const auto *Entry = CostTableLookup(AVX2CostTbl, ISD, MTy))
      return LT.first * Entry->Cost;

  if (ST->hasAVX())
    if (const auto *Entry = CostTableLookup(AVX1CostTbl, ISD, MTy))
      return LT.first * Entry->Cost;

  if (ST->hasSSE42())
    if (const auto *Entry = CostTableLookup(SSE42CostTbl, ISD, MTy))
      return LT.first * Entry->Cost;

  if (ST->hasSSE41())
    if (const auto *Entry = CostTableLookup(SSE41CostTbl, ISD, MTy))
      return LT.first * Entry->Cost;

  if (ST->hasSSE2())
    if (const auto *Entry = CostTableLookup(SSE2CostTbl, ISD, MTy))
      return LT.first * Entry->Cost;

  if (ST->hasSSE1())
    if (const auto *Entry = CostTableLookup(SSE1CostTbl, ISD, MTy))
      return LT.first * Entry->Cost;

  unsigned CmpOpcode;
  if (Ty->isFPOrFPVectorTy()) {
    CmpOpcode = Instruction::FCmp;
  } else {
    assert(Ty->isIntOrIntVectorTy() &&
           "expecting floating point or integer type for min/max reduction");
    CmpOpcode = Instruction::ICmp;
  }

  TTI::TargetCostKind CostKind = TTI::TCK_RecipThroughput;
  // Otherwise fall back to cmp+select.
  return getCmpSelInstrCost(CmpOpcode, Ty, CondTy, CostKind) +
         getCmpSelInstrCost(Instruction::Select, Ty, CondTy, CostKind);
}

int X86TTIImpl::getMinMaxReductionCost(VectorType *ValTy, VectorType *CondTy,
                                       bool IsPairwise, bool IsUnsigned,
                                       TTI::TargetCostKind CostKind) {
  // Just use the default implementation for pair reductions.
  if (IsPairwise)
    return BaseT::getMinMaxReductionCost(ValTy, CondTy, IsPairwise, IsUnsigned,
                                         CostKind);

  std::pair<int, MVT> LT = TLI->getTypeLegalizationCost(DL, ValTy);

  MVT MTy = LT.second;

  int ISD;
  if (ValTy->isIntOrIntVectorTy()) {
    ISD = IsUnsigned ? ISD::UMIN : ISD::SMIN;
  } else {
    assert(ValTy->isFPOrFPVectorTy() &&
           "Expected float point or integer vector type.");
    ISD = ISD::FMINNUM;
  }

  // We use the Intel Architecture Code Analyzer(IACA) to measure the throughput
  // and make it as the cost.

  static const CostTblEntry SSE2CostTblNoPairWise[] = {
      {ISD::UMIN, MVT::v2i16, 5}, // need pxors to use pminsw/pmaxsw
      {ISD::UMIN, MVT::v4i16, 7}, // need pxors to use pminsw/pmaxsw
      {ISD::UMIN, MVT::v8i16, 9}, // need pxors to use pminsw/pmaxsw
  };

  static const CostTblEntry SSE41CostTblNoPairWise[] = {
      {ISD::SMIN, MVT::v2i16, 3}, // same as sse2
      {ISD::SMIN, MVT::v4i16, 5}, // same as sse2
      {ISD::UMIN, MVT::v2i16, 5}, // same as sse2
      {ISD::UMIN, MVT::v4i16, 7}, // same as sse2
      {ISD::SMIN, MVT::v8i16, 4}, // phminposuw+xor
      {ISD::UMIN, MVT::v8i16, 4}, // FIXME: umin is cheaper than umax
      {ISD::SMIN, MVT::v2i8,  3}, // pminsb
      {ISD::SMIN, MVT::v4i8,  5}, // pminsb
      {ISD::SMIN, MVT::v8i8,  7}, // pminsb
      {ISD::SMIN, MVT::v16i8, 6},
      {ISD::UMIN, MVT::v2i8,  3}, // same as sse2
      {ISD::UMIN, MVT::v4i8,  5}, // same as sse2
      {ISD::UMIN, MVT::v8i8,  7}, // same as sse2
      {ISD::UMIN, MVT::v16i8, 6}, // FIXME: umin is cheaper than umax
  };

  static const CostTblEntry AVX1CostTblNoPairWise[] = {
      {ISD::SMIN, MVT::v16i16, 6},
      {ISD::UMIN, MVT::v16i16, 6}, // FIXME: umin is cheaper than umax
      {ISD::SMIN, MVT::v32i8, 8},
      {ISD::UMIN, MVT::v32i8, 8},
  };

  static const CostTblEntry AVX512BWCostTblNoPairWise[] = {
      {ISD::SMIN, MVT::v32i16, 8},
      {ISD::UMIN, MVT::v32i16, 8}, // FIXME: umin is cheaper than umax
      {ISD::SMIN, MVT::v64i8, 10},
      {ISD::UMIN, MVT::v64i8, 10},
  };

  // Before legalizing the type, give a chance to look up illegal narrow types
  // in the table.
  // FIXME: Is there a better way to do this?
  EVT VT = TLI->getValueType(DL, ValTy);
  if (VT.isSimple()) {
    MVT MTy = VT.getSimpleVT();
    if (ST->hasBWI())
      if (const auto *Entry = CostTableLookup(AVX512BWCostTblNoPairWise, ISD, MTy))
        return Entry->Cost;

    if (ST->hasAVX())
      if (const auto *Entry = CostTableLookup(AVX1CostTblNoPairWise, ISD, MTy))
        return Entry->Cost;

    if (ST->hasSSE41())
      if (const auto *Entry = CostTableLookup(SSE41CostTblNoPairWise, ISD, MTy))
        return Entry->Cost;

    if (ST->hasSSE2())
      if (const auto *Entry = CostTableLookup(SSE2CostTblNoPairWise, ISD, MTy))
        return Entry->Cost;
  }

  auto *ValVTy = cast<VectorType>(ValTy);
  unsigned NumVecElts = ValVTy->getNumElements();

  auto *Ty = ValVTy;
  unsigned MinMaxCost = 0;
  if (LT.first != 1 && MTy.isVector() &&
      MTy.getVectorNumElements() < ValVTy->getNumElements()) {
    // Type needs to be split. We need LT.first - 1 operations ops.
    Ty = VectorType::get(ValVTy->getElementType(), MTy.getVectorNumElements());
    auto *SubCondTy = VectorType::get(
        cast<VectorType>(CondTy)->getElementType(), MTy.getVectorNumElements());
    MinMaxCost = getMinMaxCost(Ty, SubCondTy, IsUnsigned);
    MinMaxCost *= LT.first - 1;
    NumVecElts = MTy.getVectorNumElements();
  }

  if (ST->hasBWI())
    if (const auto *Entry = CostTableLookup(AVX512BWCostTblNoPairWise, ISD, MTy))
      return MinMaxCost + Entry->Cost;

  if (ST->hasAVX())
    if (const auto *Entry = CostTableLookup(AVX1CostTblNoPairWise, ISD, MTy))
      return MinMaxCost + Entry->Cost;

  if (ST->hasSSE41())
    if (const auto *Entry = CostTableLookup(SSE41CostTblNoPairWise, ISD, MTy))
      return MinMaxCost + Entry->Cost;

  if (ST->hasSSE2())
    if (const auto *Entry = CostTableLookup(SSE2CostTblNoPairWise, ISD, MTy))
      return MinMaxCost + Entry->Cost;

  unsigned ScalarSize = ValTy->getScalarSizeInBits();

  // Special case power of 2 reductions where the scalar type isn't changed
  // by type legalization.
  if (!isPowerOf2_32(ValVTy->getNumElements()) ||
      ScalarSize != MTy.getScalarSizeInBits())
    return BaseT::getMinMaxReductionCost(ValTy, CondTy, IsPairwise, IsUnsigned,
                                         CostKind);

  // Now handle reduction with the legal type, taking into account size changes
  // at each level.
  while (NumVecElts > 1) {
    // Determine the size of the remaining vector we need to reduce.
    unsigned Size = NumVecElts * ScalarSize;
    NumVecElts /= 2;
    // If we're reducing from 256/512 bits, use an extract_subvector.
    if (Size > 128) {
      auto *SubTy = VectorType::get(ValVTy->getElementType(), NumVecElts);
      MinMaxCost +=
          getShuffleCost(TTI::SK_ExtractSubvector, Ty, NumVecElts, SubTy);
      Ty = SubTy;
    } else if (Size == 128) {
      // Reducing from 128 bits is a permute of v2f64/v2i64.
      VectorType *ShufTy;
      if (ValTy->isFloatingPointTy())
        ShufTy = VectorType::get(Type::getDoubleTy(ValTy->getContext()), 2);
      else
        ShufTy = VectorType::get(Type::getInt64Ty(ValTy->getContext()), 2);
      MinMaxCost +=
          getShuffleCost(TTI::SK_PermuteSingleSrc, ShufTy, 0, nullptr);
    } else if (Size == 64) {
      // Reducing from 64 bits is a shuffle of v4f32/v4i32.
      VectorType *ShufTy;
      if (ValTy->isFloatingPointTy())
        ShufTy = VectorType::get(Type::getFloatTy(ValTy->getContext()), 4);
      else
        ShufTy = VectorType::get(Type::getInt32Ty(ValTy->getContext()), 4);
      MinMaxCost +=
          getShuffleCost(TTI::SK_PermuteSingleSrc, ShufTy, 0, nullptr);
    } else {
      // Reducing from smaller size is a shift by immediate.
      VectorType *ShiftTy = VectorType::get(
          Type::getIntNTy(ValTy->getContext(), Size), 128 / Size);
      MinMaxCost += getArithmeticInstrCost(
          Instruction::LShr, ShiftTy, TTI::TCK_RecipThroughput,
          TargetTransformInfo::OK_AnyValue,
          TargetTransformInfo::OK_UniformConstantValue,
          TargetTransformInfo::OP_None, TargetTransformInfo::OP_None);
    }

    // Add the arithmetic op for this level.
    auto *SubCondTy =
        FixedVectorType::get(CondTy->getElementType(), Ty->getNumElements());
    MinMaxCost += getMinMaxCost(Ty, SubCondTy, IsUnsigned);
  }

  // Add the final extract element to the cost.
  return MinMaxCost + getVectorInstrCost(Instruction::ExtractElement, Ty, 0);
}

/// Calculate the cost of materializing a 64-bit value. This helper
/// method might only calculate a fraction of a larger immediate. Therefore it
/// is valid to return a cost of ZERO.
int X86TTIImpl::getIntImmCost(int64_t Val) {
  if (Val == 0)
    return TTI::TCC_Free;

  if (isInt<32>(Val))
    return TTI::TCC_Basic;

  return 2 * TTI::TCC_Basic;
}

int X86TTIImpl::getIntImmCost(const APInt &Imm, Type *Ty,
                              TTI::TargetCostKind CostKind) {
  assert(Ty->isIntegerTy());

  unsigned BitSize = Ty->getPrimitiveSizeInBits();
  if (BitSize == 0)
    return ~0U;

  // Never hoist constants larger than 128bit, because this might lead to
  // incorrect code generation or assertions in codegen.
  // Fixme: Create a cost model for types larger than i128 once the codegen
  // issues have been fixed.
  if (BitSize > 128)
    return TTI::TCC_Free;

  if (Imm == 0)
    return TTI::TCC_Free;

  // Sign-extend all constants to a multiple of 64-bit.
  APInt ImmVal = Imm;
  if (BitSize % 64 != 0)
    ImmVal = Imm.sext(alignTo(BitSize, 64));

  // Split the constant into 64-bit chunks and calculate the cost for each
  // chunk.
  int Cost = 0;
  for (unsigned ShiftVal = 0; ShiftVal < BitSize; ShiftVal += 64) {
    APInt Tmp = ImmVal.ashr(ShiftVal).sextOrTrunc(64);
    int64_t Val = Tmp.getSExtValue();
    Cost += getIntImmCost(Val);
  }
  // We need at least one instruction to materialize the constant.
  return std::max(1, Cost);
}

int X86TTIImpl::getIntImmCostInst(unsigned Opcode, unsigned Idx, const APInt &Imm,
                                  Type *Ty, TTI::TargetCostKind CostKind) {
  assert(Ty->isIntegerTy());

  unsigned BitSize = Ty->getPrimitiveSizeInBits();
  // There is no cost model for constants with a bit size of 0. Return TCC_Free
  // here, so that constant hoisting will ignore this constant.
  if (BitSize == 0)
    return TTI::TCC_Free;

  unsigned ImmIdx = ~0U;
  switch (Opcode) {
  default:
    return TTI::TCC_Free;
  case Instruction::GetElementPtr:
    // Always hoist the base address of a GetElementPtr. This prevents the
    // creation of new constants for every base constant that gets constant
    // folded with the offset.
    if (Idx == 0)
      return 2 * TTI::TCC_Basic;
    return TTI::TCC_Free;
  case Instruction::Store:
    ImmIdx = 0;
    break;
  case Instruction::ICmp:
    // This is an imperfect hack to prevent constant hoisting of
    // compares that might be trying to check if a 64-bit value fits in
    // 32-bits. The backend can optimize these cases using a right shift by 32.
    // Ideally we would check the compare predicate here. There also other
    // similar immediates the backend can use shifts for.
    if (Idx == 1 && Imm.getBitWidth() == 64) {
      uint64_t ImmVal = Imm.getZExtValue();
      if (ImmVal == 0x100000000ULL || ImmVal == 0xffffffff)
        return TTI::TCC_Free;
    }
    ImmIdx = 1;
    break;
  case Instruction::And:
    // We support 64-bit ANDs with immediates with 32-bits of leading zeroes
    // by using a 32-bit operation with implicit zero extension. Detect such
    // immediates here as the normal path expects bit 31 to be sign extended.
    if (Idx == 1 && Imm.getBitWidth() == 64 && isUInt<32>(Imm.getZExtValue()))
      return TTI::TCC_Free;
    ImmIdx = 1;
    break;
  case Instruction::Add:
  case Instruction::Sub:
    // For add/sub, we can use the opposite instruction for INT32_MIN.
    if (Idx == 1 && Imm.getBitWidth() == 64 && Imm.getZExtValue() == 0x80000000)
      return TTI::TCC_Free;
    ImmIdx = 1;
    break;
  case Instruction::UDiv:
  case Instruction::SDiv:
  case Instruction::URem:
  case Instruction::SRem:
    // Division by constant is typically expanded later into a different
    // instruction sequence. This completely changes the constants.
    // Report them as "free" to stop ConstantHoist from marking them as opaque.
    return TTI::TCC_Free;
  case Instruction::Mul:
  case Instruction::Or:
  case Instruction::Xor:
    ImmIdx = 1;
    break;
  // Always return TCC_Free for the shift value of a shift instruction.
  case Instruction::Shl:
  case Instruction::LShr:
  case Instruction::AShr:
    if (Idx == 1)
      return TTI::TCC_Free;
    break;
  case Instruction::Trunc:
  case Instruction::ZExt:
  case Instruction::SExt:
  case Instruction::IntToPtr:
  case Instruction::PtrToInt:
  case Instruction::BitCast:
  case Instruction::PHI:
  case Instruction::Call:
  case Instruction::Select:
  case Instruction::Ret:
  case Instruction::Load:
    break;
  }

  if (Idx == ImmIdx) {
    int NumConstants = divideCeil(BitSize, 64);
    int Cost = X86TTIImpl::getIntImmCost(Imm, Ty, CostKind);
    return (Cost <= NumConstants * TTI::TCC_Basic)
               ? static_cast<int>(TTI::TCC_Free)
               : Cost;
  }

  return X86TTIImpl::getIntImmCost(Imm, Ty, CostKind);
}

int X86TTIImpl::getIntImmCostIntrin(Intrinsic::ID IID, unsigned Idx,
                                    const APInt &Imm, Type *Ty,
                                    TTI::TargetCostKind CostKind) {
  assert(Ty->isIntegerTy());

  unsigned BitSize = Ty->getPrimitiveSizeInBits();
  // There is no cost model for constants with a bit size of 0. Return TCC_Free
  // here, so that constant hoisting will ignore this constant.
  if (BitSize == 0)
    return TTI::TCC_Free;

  switch (IID) {
  default:
    return TTI::TCC_Free;
  case Intrinsic::sadd_with_overflow:
  case Intrinsic::uadd_with_overflow:
  case Intrinsic::ssub_with_overflow:
  case Intrinsic::usub_with_overflow:
  case Intrinsic::smul_with_overflow:
  case Intrinsic::umul_with_overflow:
    if ((Idx == 1) && Imm.getBitWidth() <= 64 && isInt<32>(Imm.getSExtValue()))
      return TTI::TCC_Free;
    break;
  case Intrinsic::experimental_stackmap:
    if ((Idx < 2) || (Imm.getBitWidth() <= 64 && isInt<64>(Imm.getSExtValue())))
      return TTI::TCC_Free;
    break;
  case Intrinsic::experimental_patchpoint_void:
  case Intrinsic::experimental_patchpoint_i64:
    if ((Idx < 4) || (Imm.getBitWidth() <= 64 && isInt<64>(Imm.getSExtValue())))
      return TTI::TCC_Free;
    break;
  }
  return X86TTIImpl::getIntImmCost(Imm, Ty, CostKind);
}

// Return an average cost of Gather / Scatter instruction, maybe improved later
int X86TTIImpl::getGSVectorCost(unsigned Opcode, Type *SrcVTy, Value *Ptr,
                                unsigned Alignment, unsigned AddressSpace) {

  assert(isa<VectorType>(SrcVTy) && "Unexpected type in getGSVectorCost");
  unsigned VF = cast<VectorType>(SrcVTy)->getNumElements();

  // Try to reduce index size from 64 bit (default for GEP)
  // to 32. It is essential for VF 16. If the index can't be reduced to 32, the
  // operation will use 16 x 64 indices which do not fit in a zmm and needs
  // to split. Also check that the base pointer is the same for all lanes,
  // and that there's at most one variable index.
  auto getIndexSizeInBits = [](Value *Ptr, const DataLayout& DL) {
    unsigned IndexSize = DL.getPointerSizeInBits();
    GetElementPtrInst *GEP = dyn_cast<GetElementPtrInst>(Ptr);
    if (IndexSize < 64 || !GEP)
      return IndexSize;

    unsigned NumOfVarIndices = 0;
    Value *Ptrs = GEP->getPointerOperand();
    if (Ptrs->getType()->isVectorTy() && !getSplatValue(Ptrs))
      return IndexSize;
    for (unsigned i = 1; i < GEP->getNumOperands(); ++i) {
      if (isa<Constant>(GEP->getOperand(i)))
        continue;
      Type *IndxTy = GEP->getOperand(i)->getType();
      if (auto *IndexVTy = dyn_cast<VectorType>(IndxTy))
        IndxTy = IndexVTy->getElementType();
      if ((IndxTy->getPrimitiveSizeInBits() == 64 &&
          !isa<SExtInst>(GEP->getOperand(i))) ||
         ++NumOfVarIndices > 1)
        return IndexSize; // 64
    }
    return (unsigned)32;
  };


  // Trying to reduce IndexSize to 32 bits for vector 16.
  // By default the IndexSize is equal to pointer size.
  unsigned IndexSize = (ST->hasAVX512() && VF >= 16)
                           ? getIndexSizeInBits(Ptr, DL)
                           : DL.getPointerSizeInBits();

  auto *IndexVTy = FixedVectorType::get(
      IntegerType::get(SrcVTy->getContext(), IndexSize), VF);
  std::pair<int, MVT> IdxsLT = TLI->getTypeLegalizationCost(DL, IndexVTy);
  std::pair<int, MVT> SrcLT = TLI->getTypeLegalizationCost(DL, SrcVTy);
  int SplitFactor = std::max(IdxsLT.first, SrcLT.first);
  if (SplitFactor > 1) {
    // Handle splitting of vector of pointers
    auto *SplitSrcTy =
        FixedVectorType::get(SrcVTy->getScalarType(), VF / SplitFactor);
    return SplitFactor * getGSVectorCost(Opcode, SplitSrcTy, Ptr, Alignment,
                                         AddressSpace);
  }

  // The gather / scatter cost is given by Intel architects. It is a rough
  // number since we are looking at one instruction in a time.
  const int GSOverhead = (Opcode == Instruction::Load)
                             ? ST->getGatherOverhead()
                             : ST->getScatterOverhead();
  return GSOverhead + VF * getMemoryOpCost(Opcode, SrcVTy->getScalarType(),
                                           MaybeAlign(Alignment), AddressSpace,
                                           TTI::TCK_RecipThroughput);
}

/// Return the cost of full scalarization of gather / scatter operation.
///
/// Opcode - Load or Store instruction.
/// SrcVTy - The type of the data vector that should be gathered or scattered.
/// VariableMask - The mask is non-constant at compile time.
/// Alignment - Alignment for one element.
/// AddressSpace - pointer[s] address space.
///
int X86TTIImpl::getGSScalarCost(unsigned Opcode, Type *SrcVTy,
                                bool VariableMask, unsigned Alignment,
                                unsigned AddressSpace) {
  unsigned VF = cast<VectorType>(SrcVTy)->getNumElements();
  APInt DemandedElts = APInt::getAllOnesValue(VF);
  TTI::TargetCostKind CostKind = TTI::TCK_RecipThroughput;

  int MaskUnpackCost = 0;
  if (VariableMask) {
    VectorType *MaskTy =
      VectorType::get(Type::getInt1Ty(SrcVTy->getContext()), VF);
    MaskUnpackCost =
        getScalarizationOverhead(MaskTy, DemandedElts, false, true);
    int ScalarCompareCost =
      getCmpSelInstrCost(Instruction::ICmp, Type::getInt1Ty(SrcVTy->getContext()),
                         nullptr, CostKind);
    int BranchCost = getCFInstrCost(Instruction::Br, CostKind);
    MaskUnpackCost += VF * (BranchCost + ScalarCompareCost);
  }

  // The cost of the scalar loads/stores.
  int MemoryOpCost = VF * getMemoryOpCost(Opcode, SrcVTy->getScalarType(),
                                          MaybeAlign(Alignment), AddressSpace,
                                          CostKind);

  int InsertExtractCost = 0;
  if (Opcode == Instruction::Load)
    for (unsigned i = 0; i < VF; ++i)
      // Add the cost of inserting each scalar load into the vector
      InsertExtractCost +=
        getVectorInstrCost(Instruction::InsertElement, SrcVTy, i);
  else
    for (unsigned i = 0; i < VF; ++i)
      // Add the cost of extracting each element out of the data vector
      InsertExtractCost +=
        getVectorInstrCost(Instruction::ExtractElement, SrcVTy, i);

  return MemoryOpCost + MaskUnpackCost + InsertExtractCost;
}

/// Calculate the cost of Gather / Scatter operation
int X86TTIImpl::getGatherScatterOpCost(
    unsigned Opcode, Type *SrcVTy, Value *Ptr, bool VariableMask,
    unsigned Alignment, TTI::TargetCostKind CostKind,
    const Instruction *I = nullptr) {

  if (CostKind != TTI::TCK_RecipThroughput)
    return 1;

  assert(SrcVTy->isVectorTy() && "Unexpected data type for Gather/Scatter");
  unsigned VF = cast<VectorType>(SrcVTy)->getNumElements();
  PointerType *PtrTy = dyn_cast<PointerType>(Ptr->getType());
  if (!PtrTy && Ptr->getType()->isVectorTy())
    PtrTy = dyn_cast<PointerType>(
        cast<VectorType>(Ptr->getType())->getElementType());
  assert(PtrTy && "Unexpected type for Ptr argument");
  unsigned AddressSpace = PtrTy->getAddressSpace();

  bool Scalarize = false;
  if ((Opcode == Instruction::Load &&
       !isLegalMaskedGather(SrcVTy, MaybeAlign(Alignment))) ||
      (Opcode == Instruction::Store &&
       !isLegalMaskedScatter(SrcVTy, MaybeAlign(Alignment))))
    Scalarize = true;
  // Gather / Scatter for vector 2 is not profitable on KNL / SKX
  // Vector-4 of gather/scatter instruction does not exist on KNL.
  // We can extend it to 8 elements, but zeroing upper bits of
  // the mask vector will add more instructions. Right now we give the scalar
  // cost of vector-4 for KNL. TODO: Check, maybe the gather/scatter instruction
  // is better in the VariableMask case.
  if (ST->hasAVX512() && (VF == 2 || (VF == 4 && !ST->hasVLX())))
    Scalarize = true;

  if (Scalarize)
    return getGSScalarCost(Opcode, SrcVTy, VariableMask, Alignment,
                           AddressSpace);

  return getGSVectorCost(Opcode, SrcVTy, Ptr, Alignment, AddressSpace);
}

bool X86TTIImpl::isLSRCostLess(TargetTransformInfo::LSRCost &C1,
                               TargetTransformInfo::LSRCost &C2) {
    // X86 specific here are "instruction number 1st priority".
    return std::tie(C1.Insns, C1.NumRegs, C1.AddRecCost,
                    C1.NumIVMuls, C1.NumBaseAdds,
                    C1.ScaleCost, C1.ImmCost, C1.SetupCost) <
           std::tie(C2.Insns, C2.NumRegs, C2.AddRecCost,
                    C2.NumIVMuls, C2.NumBaseAdds,
                    C2.ScaleCost, C2.ImmCost, C2.SetupCost);
}

bool X86TTIImpl::canMacroFuseCmp() {
  return ST->hasMacroFusion() || ST->hasBranchFusion();
}

bool X86TTIImpl::isLegalMaskedLoad(Type *DataTy, MaybeAlign Alignment) {
  if (!ST->hasAVX())
    return false;

  // The backend can't handle a single element vector.
  if (isa<VectorType>(DataTy) &&
      cast<VectorType>(DataTy)->getNumElements() == 1)
    return false;
  Type *ScalarTy = DataTy->getScalarType();

  if (ScalarTy->isPointerTy())
    return true;

  if (ScalarTy->isFloatTy() || ScalarTy->isDoubleTy())
    return true;

  if (!ScalarTy->isIntegerTy())
    return false;

  unsigned IntWidth = ScalarTy->getIntegerBitWidth();
  return IntWidth == 32 || IntWidth == 64 ||
         ((IntWidth == 8 || IntWidth == 16) && ST->hasBWI());
}

bool X86TTIImpl::isLegalMaskedStore(Type *DataType, MaybeAlign Alignment) {
  return isLegalMaskedLoad(DataType, Alignment);
}

bool X86TTIImpl::isLegalNTLoad(Type *DataType, Align Alignment) {
  unsigned DataSize = DL.getTypeStoreSize(DataType);
  // The only supported nontemporal loads are for aligned vectors of 16 or 32
  // bytes.  Note that 32-byte nontemporal vector loads are supported by AVX2
  // (the equivalent stores only require AVX).
  if (Alignment >= DataSize && (DataSize == 16 || DataSize == 32))
    return DataSize == 16 ?  ST->hasSSE1() : ST->hasAVX2();

  return false;
}

bool X86TTIImpl::isLegalNTStore(Type *DataType, Align Alignment) {
  unsigned DataSize = DL.getTypeStoreSize(DataType);

  // SSE4A supports nontemporal stores of float and double at arbitrary
  // alignment.
  if (ST->hasSSE4A() && (DataType->isFloatTy() || DataType->isDoubleTy()))
    return true;

  // Besides the SSE4A subtarget exception above, only aligned stores are
  // available nontemporaly on any other subtarget.  And only stores with a size
  // of 4..32 bytes (powers of 2, only) are permitted.
  if (Alignment < DataSize || DataSize < 4 || DataSize > 32 ||
      !isPowerOf2_32(DataSize))
    return false;

  // 32-byte vector nontemporal stores are supported by AVX (the equivalent
  // loads require AVX2).
  if (DataSize == 32)
    return ST->hasAVX();
  else if (DataSize == 16)
    return ST->hasSSE1();
  return true;
}

bool X86TTIImpl::isLegalMaskedExpandLoad(Type *DataTy) {
  if (!isa<VectorType>(DataTy))
    return false;

  if (!ST->hasAVX512())
    return false;

  // The backend can't handle a single element vector.
  if (cast<VectorType>(DataTy)->getNumElements() == 1)
    return false;

  Type *ScalarTy = cast<VectorType>(DataTy)->getElementType();

  if (ScalarTy->isFloatTy() || ScalarTy->isDoubleTy())
    return true;

  if (!ScalarTy->isIntegerTy())
    return false;

  unsigned IntWidth = ScalarTy->getIntegerBitWidth();
  return IntWidth == 32 || IntWidth == 64 ||
         ((IntWidth == 8 || IntWidth == 16) && ST->hasVBMI2());
}

bool X86TTIImpl::isLegalMaskedCompressStore(Type *DataTy) {
  return isLegalMaskedExpandLoad(DataTy);
}

bool X86TTIImpl::isLegalMaskedGather(Type *DataTy, MaybeAlign Alignment) {
  // Some CPUs have better gather performance than others.
  // TODO: Remove the explicit ST->hasAVX512()?, That would mean we would only
  // enable gather with a -march.
  if (!(ST->hasAVX512() || (ST->hasFastGather() && ST->hasAVX2())))
    return false;

  // This function is called now in two cases: from the Loop Vectorizer
  // and from the Scalarizer.
  // When the Loop Vectorizer asks about legality of the feature,
  // the vectorization factor is not calculated yet. The Loop Vectorizer
  // sends a scalar type and the decision is based on the width of the
  // scalar element.
  // Later on, the cost model will estimate usage this intrinsic based on
  // the vector type.
  // The Scalarizer asks again about legality. It sends a vector type.
  // In this case we can reject non-power-of-2 vectors.
  // We also reject single element vectors as the type legalizer can't
  // scalarize it.
  if (auto *DataVTy = dyn_cast<VectorType>(DataTy)) {
    unsigned NumElts = DataVTy->getNumElements();
    if (NumElts == 1 || !isPowerOf2_32(NumElts))
      return false;
  }
  Type *ScalarTy = DataTy->getScalarType();
  if (ScalarTy->isPointerTy())
    return true;

  if (ScalarTy->isFloatTy() || ScalarTy->isDoubleTy())
    return true;

  if (!ScalarTy->isIntegerTy())
    return false;

  unsigned IntWidth = ScalarTy->getIntegerBitWidth();
  return IntWidth == 32 || IntWidth == 64;
}

bool X86TTIImpl::isLegalMaskedScatter(Type *DataType, MaybeAlign Alignment) {
  // AVX2 doesn't support scatter
  if (!ST->hasAVX512())
    return false;
  return isLegalMaskedGather(DataType, Alignment);
}

bool X86TTIImpl::hasDivRemOp(Type *DataType, bool IsSigned) {
  EVT VT = TLI->getValueType(DL, DataType);
  return TLI->isOperationLegal(IsSigned ? ISD::SDIVREM : ISD::UDIVREM, VT);
}

bool X86TTIImpl::isFCmpOrdCheaperThanFCmpZero(Type *Ty) {
  return false;
}

bool X86TTIImpl::areInlineCompatible(const Function *Caller,
                                     const Function *Callee) const {
  const TargetMachine &TM = getTLI()->getTargetMachine();

  // Work this as a subsetting of subtarget features.
  const FeatureBitset &CallerBits =
      TM.getSubtargetImpl(*Caller)->getFeatureBits();
  const FeatureBitset &CalleeBits =
      TM.getSubtargetImpl(*Callee)->getFeatureBits();

  FeatureBitset RealCallerBits = CallerBits & ~InlineFeatureIgnoreList;
  FeatureBitset RealCalleeBits = CalleeBits & ~InlineFeatureIgnoreList;
  return (RealCallerBits & RealCalleeBits) == RealCalleeBits;
}

bool X86TTIImpl::areFunctionArgsABICompatible(
    const Function *Caller, const Function *Callee,
    SmallPtrSetImpl<Argument *> &Args) const {
  if (!BaseT::areFunctionArgsABICompatible(Caller, Callee, Args))
    return false;

  // If we get here, we know the target features match. If one function
  // considers 512-bit vectors legal and the other does not, consider them
  // incompatible.
  const TargetMachine &TM = getTLI()->getTargetMachine();

  if (TM.getSubtarget<X86Subtarget>(*Caller).useAVX512Regs() ==
      TM.getSubtarget<X86Subtarget>(*Callee).useAVX512Regs())
    return true;

  // Consider the arguments compatible if they aren't vectors or aggregates.
  // FIXME: Look at the size of vectors.
  // FIXME: Look at the element types of aggregates to see if there are vectors.
  // FIXME: The API of this function seems intended to allow arguments
  // to be removed from the set, but the caller doesn't check if the set
  // becomes empty so that may not work in practice.
  return llvm::none_of(Args, [](Argument *A) {
    auto *EltTy = cast<PointerType>(A->getType())->getElementType();
    return EltTy->isVectorTy() || EltTy->isAggregateType();
  });
}

X86TTIImpl::TTI::MemCmpExpansionOptions
X86TTIImpl::enableMemCmpExpansion(bool OptSize, bool IsZeroCmp) const {
  TTI::MemCmpExpansionOptions Options;
  Options.MaxNumLoads = TLI->getMaxExpandSizeMemcmp(OptSize);
  Options.NumLoadsPerBlock = 2;
  // All GPR and vector loads can be unaligned.
  Options.AllowOverlappingLoads = true;
  if (IsZeroCmp) {
    // Only enable vector loads for equality comparison. Right now the vector
    // version is not as fast for three way compare (see #33329).
    const unsigned PreferredWidth = ST->getPreferVectorWidth();
    if (PreferredWidth >= 512 && ST->hasAVX512()) Options.LoadSizes.push_back(64);
    if (PreferredWidth >= 256 && ST->hasAVX()) Options.LoadSizes.push_back(32);
    if (PreferredWidth >= 128 && ST->hasSSE2()) Options.LoadSizes.push_back(16);
  }
  if (ST->is64Bit()) {
    Options.LoadSizes.push_back(8);
  }
  Options.LoadSizes.push_back(4);
  Options.LoadSizes.push_back(2);
  Options.LoadSizes.push_back(1);
  return Options;
}

bool X86TTIImpl::enableInterleavedAccessVectorization() {
  // TODO: We expect this to be beneficial regardless of arch,
  // but there are currently some unexplained performance artifacts on Atom.
  // As a temporary solution, disable on Atom.
  return !(ST->isAtom());
}

// Get estimation for interleaved load/store operations for AVX2.
// \p Factor is the interleaved-access factor (stride) - number of
// (interleaved) elements in the group.
// \p Indices contains the indices for a strided load: when the
// interleaved load has gaps they indicate which elements are used.
// If Indices is empty (or if the number of indices is equal to the size
// of the interleaved-access as given in \p Factor) the access has no gaps.
//
// As opposed to AVX-512, AVX2 does not have generic shuffles that allow
// computing the cost using a generic formula as a function of generic
// shuffles. We therefore use a lookup table instead, filled according to
// the instruction sequences that codegen currently generates.
int X86TTIImpl::getInterleavedMemoryOpCostAVX2(unsigned Opcode, Type *VecTy,
                                               unsigned Factor,
                                               ArrayRef<unsigned> Indices,
                                               unsigned Alignment,
                                               unsigned AddressSpace,
                                               TTI::TargetCostKind CostKind,
                                               bool UseMaskForCond,
                                               bool UseMaskForGaps) {

  if (UseMaskForCond || UseMaskForGaps)
    return BaseT::getInterleavedMemoryOpCost(Opcode, VecTy, Factor, Indices,
                                             Alignment, AddressSpace, CostKind,
                                             UseMaskForCond, UseMaskForGaps);

  // We currently Support only fully-interleaved groups, with no gaps.
  // TODO: Support also strided loads (interleaved-groups with gaps).
  if (Indices.size() && Indices.size() != Factor)
    return BaseT::getInterleavedMemoryOpCost(Opcode, VecTy, Factor, Indices,
                                             Alignment, AddressSpace,
                                             CostKind);

  // VecTy for interleave memop is <VF*Factor x Elt>.
  // So, for VF=4, Interleave Factor = 3, Element type = i32 we have
  // VecTy = <12 x i32>.
  MVT LegalVT = getTLI()->getTypeLegalizationCost(DL, VecTy).second;

  // This function can be called with VecTy=<6xi128>, Factor=3, in which case
  // the VF=2, while v2i128 is an unsupported MVT vector type
  // (see MachineValueType.h::getVectorVT()).
  if (!LegalVT.isVector())
    return BaseT::getInterleavedMemoryOpCost(Opcode, VecTy, Factor, Indices,
                                             Alignment, AddressSpace,
                                             CostKind);

  unsigned VF = cast<VectorType>(VecTy)->getNumElements() / Factor;
  Type *ScalarTy = cast<VectorType>(VecTy)->getElementType();

  // Calculate the number of memory operations (NumOfMemOps), required
  // for load/store the VecTy.
  unsigned VecTySize = DL.getTypeStoreSize(VecTy);
  unsigned LegalVTSize = LegalVT.getStoreSize();
  unsigned NumOfMemOps = (VecTySize + LegalVTSize - 1) / LegalVTSize;

  // Get the cost of one memory operation.
  auto *SingleMemOpTy =
      FixedVectorType::get(cast<VectorType>(VecTy)->getElementType(),
                           LegalVT.getVectorNumElements());
  unsigned MemOpCost = getMemoryOpCost(Opcode, SingleMemOpTy,
                                       MaybeAlign(Alignment), AddressSpace,
                                       CostKind);

  auto *VT = FixedVectorType::get(ScalarTy, VF);
  EVT ETy = TLI->getValueType(DL, VT);
  if (!ETy.isSimple())
    return BaseT::getInterleavedMemoryOpCost(Opcode, VecTy, Factor, Indices,
                                             Alignment, AddressSpace,
                                             CostKind);

  // TODO: Complete for other data-types and strides.
  // Each combination of Stride, ElementTy and VF results in a different
  // sequence; The cost tables are therefore accessed with:
  // Factor (stride) and VectorType=VFxElemType.
  // The Cost accounts only for the shuffle sequence;
  // The cost of the loads/stores is accounted for separately.
  //
  static const CostTblEntry AVX2InterleavedLoadTbl[] = {
    { 2, MVT::v4i64, 6 }, //(load 8i64 and) deinterleave into 2 x 4i64
    { 2, MVT::v4f64, 6 }, //(load 8f64 and) deinterleave into 2 x 4f64

    { 3, MVT::v2i8,  10 }, //(load 6i8 and)  deinterleave into 3 x 2i8
    { 3, MVT::v4i8,  4 },  //(load 12i8 and) deinterleave into 3 x 4i8
    { 3, MVT::v8i8,  9 },  //(load 24i8 and) deinterleave into 3 x 8i8
    { 3, MVT::v16i8, 11},  //(load 48i8 and) deinterleave into 3 x 16i8
    { 3, MVT::v32i8, 13},  //(load 96i8 and) deinterleave into 3 x 32i8
    { 3, MVT::v8f32, 17 }, //(load 24f32 and)deinterleave into 3 x 8f32

    { 4, MVT::v2i8,  12 }, //(load 8i8 and)   deinterleave into 4 x 2i8
    { 4, MVT::v4i8,  4 },  //(load 16i8 and)  deinterleave into 4 x 4i8
    { 4, MVT::v8i8,  20 }, //(load 32i8 and)  deinterleave into 4 x 8i8
    { 4, MVT::v16i8, 39 }, //(load 64i8 and)  deinterleave into 4 x 16i8
    { 4, MVT::v32i8, 80 }, //(load 128i8 and) deinterleave into 4 x 32i8

    { 8, MVT::v8f32, 40 }  //(load 64f32 and)deinterleave into 8 x 8f32
  };

  static const CostTblEntry AVX2InterleavedStoreTbl[] = {
    { 2, MVT::v4i64, 6 }, //interleave into 2 x 4i64 into 8i64 (and store)
    { 2, MVT::v4f64, 6 }, //interleave into 2 x 4f64 into 8f64 (and store)

    { 3, MVT::v2i8,  7 },  //interleave 3 x 2i8  into 6i8 (and store)
    { 3, MVT::v4i8,  8 },  //interleave 3 x 4i8  into 12i8 (and store)
    { 3, MVT::v8i8,  11 }, //interleave 3 x 8i8  into 24i8 (and store)
    { 3, MVT::v16i8, 11 }, //interleave 3 x 16i8 into 48i8 (and store)
    { 3, MVT::v32i8, 13 }, //interleave 3 x 32i8 into 96i8 (and store)

    { 4, MVT::v2i8,  12 }, //interleave 4 x 2i8  into 8i8 (and store)
    { 4, MVT::v4i8,  9 },  //interleave 4 x 4i8  into 16i8 (and store)
    { 4, MVT::v8i8,  10 }, //interleave 4 x 8i8  into 32i8 (and store)
    { 4, MVT::v16i8, 10 }, //interleave 4 x 16i8 into 64i8 (and store)
    { 4, MVT::v32i8, 12 }  //interleave 4 x 32i8 into 128i8 (and store)
  };

  if (Opcode == Instruction::Load) {
    if (const auto *Entry =
            CostTableLookup(AVX2InterleavedLoadTbl, Factor, ETy.getSimpleVT()))
      return NumOfMemOps * MemOpCost + Entry->Cost;
  } else {
    assert(Opcode == Instruction::Store &&
           "Expected Store Instruction at this  point");
    if (const auto *Entry =
            CostTableLookup(AVX2InterleavedStoreTbl, Factor, ETy.getSimpleVT()))
      return NumOfMemOps * MemOpCost + Entry->Cost;
  }

  return BaseT::getInterleavedMemoryOpCost(Opcode, VecTy, Factor, Indices,
                                           Alignment, AddressSpace, CostKind);
}

// Get estimation for interleaved load/store operations and strided load.
// \p Indices contains indices for strided load.
// \p Factor - the factor of interleaving.
// AVX-512 provides 3-src shuffles that significantly reduces the cost.
int X86TTIImpl::getInterleavedMemoryOpCostAVX512(unsigned Opcode, Type *VecTy,
                                                 unsigned Factor,
                                                 ArrayRef<unsigned> Indices,
                                                 unsigned Alignment,
                                                 unsigned AddressSpace,
                                                 TTI::TargetCostKind CostKind,
                                                 bool UseMaskForCond,
                                                 bool UseMaskForGaps) {

  if (UseMaskForCond || UseMaskForGaps)
    return BaseT::getInterleavedMemoryOpCost(Opcode, VecTy, Factor, Indices,
                                             Alignment, AddressSpace, CostKind,
                                             UseMaskForCond, UseMaskForGaps);

  // VecTy for interleave memop is <VF*Factor x Elt>.
  // So, for VF=4, Interleave Factor = 3, Element type = i32 we have
  // VecTy = <12 x i32>.

  // Calculate the number of memory operations (NumOfMemOps), required
  // for load/store the VecTy.
  MVT LegalVT = getTLI()->getTypeLegalizationCost(DL, VecTy).second;
  unsigned VecTySize = DL.getTypeStoreSize(VecTy);
  unsigned LegalVTSize = LegalVT.getStoreSize();
  unsigned NumOfMemOps = (VecTySize + LegalVTSize - 1) / LegalVTSize;

  // Get the cost of one memory operation.
  auto *SingleMemOpTy =
      VectorType::get(cast<VectorType>(VecTy)->getElementType(),
                      LegalVT.getVectorNumElements());
  unsigned MemOpCost = getMemoryOpCost(Opcode, SingleMemOpTy,
                                       MaybeAlign(Alignment), AddressSpace,
                                       CostKind);

  unsigned VF = cast<VectorType>(VecTy)->getNumElements() / Factor;
  MVT VT = MVT::getVectorVT(MVT::getVT(VecTy->getScalarType()), VF);

  if (Opcode == Instruction::Load) {
    // The tables (AVX512InterleavedLoadTbl and AVX512InterleavedStoreTbl)
    // contain the cost of the optimized shuffle sequence that the
    // X86InterleavedAccess pass will generate.
    // The cost of loads and stores are computed separately from the table.

    // X86InterleavedAccess support only the following interleaved-access group.
    static const CostTblEntry AVX512InterleavedLoadTbl[] = {
        {3, MVT::v16i8, 12}, //(load 48i8 and) deinterleave into 3 x 16i8
        {3, MVT::v32i8, 14}, //(load 96i8 and) deinterleave into 3 x 32i8
        {3, MVT::v64i8, 22}, //(load 96i8 and) deinterleave into 3 x 32i8
    };

    if (const auto *Entry =
            CostTableLookup(AVX512InterleavedLoadTbl, Factor, VT))
      return NumOfMemOps * MemOpCost + Entry->Cost;
    //If an entry does not exist, fallback to the default implementation.

    // Kind of shuffle depends on number of loaded values.
    // If we load the entire data in one register, we can use a 1-src shuffle.
    // Otherwise, we'll merge 2 sources in each operation.
    TTI::ShuffleKind ShuffleKind =
        (NumOfMemOps > 1) ? TTI::SK_PermuteTwoSrc : TTI::SK_PermuteSingleSrc;

    unsigned ShuffleCost =
        getShuffleCost(ShuffleKind, SingleMemOpTy, 0, nullptr);

    unsigned NumOfLoadsInInterleaveGrp =
        Indices.size() ? Indices.size() : Factor;
    auto *ResultTy = FixedVectorType::get(
        cast<VectorType>(VecTy)->getElementType(),
        cast<VectorType>(VecTy)->getNumElements() / Factor);
    unsigned NumOfResults =
        getTLI()->getTypeLegalizationCost(DL, ResultTy).first *
        NumOfLoadsInInterleaveGrp;

    // About a half of the loads may be folded in shuffles when we have only
    // one result. If we have more than one result, we do not fold loads at all.
    unsigned NumOfUnfoldedLoads =
        NumOfResults > 1 ? NumOfMemOps : NumOfMemOps / 2;

    // Get a number of shuffle operations per result.
    unsigned NumOfShufflesPerResult =
        std::max((unsigned)1, (unsigned)(NumOfMemOps - 1));

    // The SK_MergeTwoSrc shuffle clobbers one of src operands.
    // When we have more than one destination, we need additional instructions
    // to keep sources.
    unsigned NumOfMoves = 0;
    if (NumOfResults > 1 && ShuffleKind == TTI::SK_PermuteTwoSrc)
      NumOfMoves = NumOfResults * NumOfShufflesPerResult / 2;

    int Cost = NumOfResults * NumOfShufflesPerResult * ShuffleCost +
               NumOfUnfoldedLoads * MemOpCost + NumOfMoves;

    return Cost;
  }

  // Store.
  assert(Opcode == Instruction::Store &&
         "Expected Store Instruction at this  point");
  // X86InterleavedAccess support only the following interleaved-access group.
  static const CostTblEntry AVX512InterleavedStoreTbl[] = {
      {3, MVT::v16i8, 12}, // interleave 3 x 16i8 into 48i8 (and store)
      {3, MVT::v32i8, 14}, // interleave 3 x 32i8 into 96i8 (and store)
      {3, MVT::v64i8, 26}, // interleave 3 x 64i8 into 96i8 (and store)

      {4, MVT::v8i8, 10},  // interleave 4 x 8i8  into 32i8  (and store)
      {4, MVT::v16i8, 11}, // interleave 4 x 16i8 into 64i8  (and store)
      {4, MVT::v32i8, 14}, // interleave 4 x 32i8 into 128i8 (and store)
      {4, MVT::v64i8, 24}  // interleave 4 x 32i8 into 256i8 (and store)
  };

  if (const auto *Entry =
          CostTableLookup(AVX512InterleavedStoreTbl, Factor, VT))
    return NumOfMemOps * MemOpCost + Entry->Cost;
  //If an entry does not exist, fallback to the default implementation.

  // There is no strided stores meanwhile. And store can't be folded in
  // shuffle.
  unsigned NumOfSources = Factor; // The number of values to be merged.
  unsigned ShuffleCost =
      getShuffleCost(TTI::SK_PermuteTwoSrc, SingleMemOpTy, 0, nullptr);
  unsigned NumOfShufflesPerStore = NumOfSources - 1;

  // The SK_MergeTwoSrc shuffle clobbers one of src operands.
  // We need additional instructions to keep sources.
  unsigned NumOfMoves = NumOfMemOps * NumOfShufflesPerStore / 2;
  int Cost = NumOfMemOps * (MemOpCost + NumOfShufflesPerStore * ShuffleCost) +
             NumOfMoves;
  return Cost;
}

int X86TTIImpl::getInterleavedMemoryOpCost(unsigned Opcode, Type *VecTy,
                                           unsigned Factor,
                                           ArrayRef<unsigned> Indices,
                                           unsigned Alignment,
                                           unsigned AddressSpace,
                                           TTI::TargetCostKind CostKind,
                                           bool UseMaskForCond,
                                           bool UseMaskForGaps) {
  auto isSupportedOnAVX512 = [](Type *VecTy, bool HasBW) {
    Type *EltTy = cast<VectorType>(VecTy)->getElementType();
    if (EltTy->isFloatTy() || EltTy->isDoubleTy() || EltTy->isIntegerTy(64) ||
        EltTy->isIntegerTy(32) || EltTy->isPointerTy())
      return true;
    if (EltTy->isIntegerTy(16) || EltTy->isIntegerTy(8))
      return HasBW;
    return false;
  };
  if (ST->hasAVX512() && isSupportedOnAVX512(VecTy, ST->hasBWI()))
    return getInterleavedMemoryOpCostAVX512(Opcode, VecTy, Factor, Indices,
                                            Alignment, AddressSpace, CostKind,
                                            UseMaskForCond, UseMaskForGaps);
  if (ST->hasAVX2())
    return getInterleavedMemoryOpCostAVX2(Opcode, VecTy, Factor, Indices,
                                          Alignment, AddressSpace, CostKind,
                                          UseMaskForCond, UseMaskForGaps);

  return BaseT::getInterleavedMemoryOpCost(Opcode, VecTy, Factor, Indices,
                                           Alignment, AddressSpace, CostKind,
                                           UseMaskForCond, UseMaskForGaps);
}
