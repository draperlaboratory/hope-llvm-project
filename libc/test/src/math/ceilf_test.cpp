//===-- Unittests for ceilf -----------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "include/math.h"
#include "src/math/ceilf.h"
#include "utils/FPUtil/BitPatterns.h"
#include "utils/FPUtil/FloatOperations.h"
#include "utils/FPUtil/FloatProperties.h"
#include "utils/MPFRWrapper/MPFRUtils.h"
#include "utils/UnitTest/Test.h"

using __llvm_libc::fputil::valueAsBits;
using __llvm_libc::fputil::valueFromBits;

using BitPatterns = __llvm_libc::fputil::BitPatterns<float>;
using Properties = __llvm_libc::fputil::FloatProperties<float>;

namespace mpfr = __llvm_libc::testing::mpfr;

// Zero tolerance; As in, exact match with MPFR result.
static constexpr mpfr::Tolerance tolerance{mpfr::Tolerance::doublePrecision, 0,
                                           0};

TEST(CeilfTest, SpecialNumbers) {
  EXPECT_EQ(
      BitPatterns::aQuietNaN,
      valueAsBits(__llvm_libc::ceilf(valueFromBits(BitPatterns::aQuietNaN))));
  EXPECT_EQ(BitPatterns::aNegativeQuietNaN,
            valueAsBits(__llvm_libc::ceilf(
                valueFromBits(BitPatterns::aNegativeQuietNaN))));

  EXPECT_EQ(BitPatterns::aSignallingNaN,
            valueAsBits(__llvm_libc::ceilf(
                valueFromBits(BitPatterns::aSignallingNaN))));
  EXPECT_EQ(BitPatterns::aNegativeSignallingNaN,
            valueAsBits(__llvm_libc::ceilf(
                valueFromBits(BitPatterns::aNegativeSignallingNaN))));

  EXPECT_EQ(BitPatterns::inf,
            valueAsBits(__llvm_libc::ceilf(valueFromBits(BitPatterns::inf))));
  EXPECT_EQ(BitPatterns::negInf, valueAsBits(__llvm_libc::ceilf(
                                     valueFromBits(BitPatterns::negInf))));

  EXPECT_EQ(BitPatterns::zero,
            valueAsBits(__llvm_libc::ceilf(valueFromBits(BitPatterns::zero))));
  EXPECT_EQ(BitPatterns::negZero, valueAsBits(__llvm_libc::ceilf(
                                      valueFromBits(BitPatterns::negZero))));
}

TEST(CeilfTest, RoundedNumbers) {
  EXPECT_EQ(valueAsBits(1.0f), valueAsBits(__llvm_libc::ceilf(1.0f)));
  EXPECT_EQ(valueAsBits(-1.0f), valueAsBits(__llvm_libc::ceilf(-1.0f)));
  EXPECT_EQ(valueAsBits(10.0f), valueAsBits(__llvm_libc::ceilf(10.0f)));
  EXPECT_EQ(valueAsBits(-10.0f), valueAsBits(__llvm_libc::ceilf(-10.0f)));
  EXPECT_EQ(valueAsBits(12345.0f), valueAsBits(__llvm_libc::ceilf(12345.0f)));
  EXPECT_EQ(valueAsBits(-12345.0f), valueAsBits(__llvm_libc::ceilf(-12345.0f)));
}

TEST(CeilfTest, InFloatRange) {
  using BitsType = Properties::BitsType;
  constexpr BitsType count = 1000000;
  constexpr BitsType step = UINT32_MAX / count;
  for (BitsType i = 0, v = 0; i <= count; ++i, v += step) {
    double x = valueFromBits(v);
    if (isnan(x) || isinf(x))
      continue;
    ASSERT_MPFR_MATCH(mpfr::Operation::Ceil, x, __llvm_libc::ceilf(x),
                      tolerance);
  }
}
