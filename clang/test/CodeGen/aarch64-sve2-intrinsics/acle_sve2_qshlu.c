// RUN: %clang_cc1 -D__ARM_FEATURE_SVE -D__ARM_FEATURE_SVE2 -triple aarch64-none-linux-gnu -target-feature +sve2 -fallow-half-arguments-and-returns -S -O1 -Werror -Wall -emit-llvm -o - %s | FileCheck %s
// RUN: %clang_cc1 -D__ARM_FEATURE_SVE -D__ARM_FEATURE_SVE2 -DSVE_OVERLOADED_FORMS -triple aarch64-none-linux-gnu -target-feature +sve2 -fallow-half-arguments-and-returns -S -O1 -Werror -Wall -emit-llvm -o - %s | FileCheck %s
// RUN: %clang_cc1 -D__ARM_FEATURE_SVE -triple aarch64-none-linux-gnu -target-feature +sve -fallow-half-arguments-and-returns -fsyntax-only -verify -verify-ignore-unexpected=error %s
// RUN: %clang_cc1 -D__ARM_FEATURE_SVE -DSVE_OVERLOADED_FORMS -triple aarch64-none-linux-gnu -target-feature +sve -fallow-half-arguments-and-returns -fsyntax-only -verify=overload -verify-ignore-unexpected=error %s

#include <arm_sve.h>

#ifdef SVE_OVERLOADED_FORMS
// A simple used,unused... macro, long enough to represent any SVE builtin.
#define SVE_ACLE_FUNC(A1,A2_UNUSED,A3,A4_UNUSED) A1##A3
#else
#define SVE_ACLE_FUNC(A1,A2,A3,A4) A1##A2##A3##A4
#endif

svuint8_t test_svqshlu_n_s8_m(svbool_t pg, svint8_t op1)
{
  // CHECK-LABEL: test_svqshlu_n_s8_m
  // CHECK: %[[INTRINSIC:.*]] = call <vscale x 16 x i8> @llvm.aarch64.sve.sqshlu.nxv16i8(<vscale x 16 x i1> %pg, <vscale x 16 x i8> %op1, i32 0)
  // CHECK: ret <vscale x 16 x i8> %[[INTRINSIC]]
  // overload-warning@+2 {{implicit declaration of function 'svqshlu_m'}}
  // expected-warning@+1 {{implicit declaration of function 'svqshlu_n_s8_m'}}
  return SVE_ACLE_FUNC(svqshlu,_n_s8,_m,)(pg, op1, 0);
}

svuint8_t test_svqshlu_n_s8_m_1(svbool_t pg, svint8_t op1)
{
  // CHECK-LABEL: test_svqshlu_n_s8_m_1
  // CHECK: %[[INTRINSIC:.*]] = call <vscale x 16 x i8> @llvm.aarch64.sve.sqshlu.nxv16i8(<vscale x 16 x i1> %pg, <vscale x 16 x i8> %op1, i32 7)
  // CHECK: ret <vscale x 16 x i8> %[[INTRINSIC]]
  // overload-warning@+2 {{implicit declaration of function 'svqshlu_m'}}
  // expected-warning@+1 {{implicit declaration of function 'svqshlu_n_s8_m'}}
  return SVE_ACLE_FUNC(svqshlu,_n_s8,_m,)(pg, op1, 7);
}

svuint16_t test_svqshlu_n_s16_m(svbool_t pg, svint16_t op1)
{
  // CHECK-LABEL: test_svqshlu_n_s16_m
  // CHECK: %[[PG:.*]] = call <vscale x 8 x i1> @llvm.aarch64.sve.convert.from.svbool.nxv8i1(<vscale x 16 x i1> %pg)
  // CHECK: %[[INTRINSIC:.*]] = call <vscale x 8 x i16> @llvm.aarch64.sve.sqshlu.nxv8i16(<vscale x 8 x i1> %[[PG]], <vscale x 8 x i16> %op1, i32 0)
  // CHECK: ret <vscale x 8 x i16> %[[INTRINSIC]]
  // overload-warning@+2 {{implicit declaration of function 'svqshlu_m'}}
  // expected-warning@+1 {{implicit declaration of function 'svqshlu_n_s16_m'}}
  return SVE_ACLE_FUNC(svqshlu,_n_s16,_m,)(pg, op1, 0);
}

svuint16_t test_svqshlu_n_s16_m_1(svbool_t pg, svint16_t op1)
{
  // CHECK-LABEL: test_svqshlu_n_s16_m_1
  // CHECK: %[[PG:.*]] = call <vscale x 8 x i1> @llvm.aarch64.sve.convert.from.svbool.nxv8i1(<vscale x 16 x i1> %pg)
  // CHECK: %[[INTRINSIC:.*]] = call <vscale x 8 x i16> @llvm.aarch64.sve.sqshlu.nxv8i16(<vscale x 8 x i1> %[[PG]], <vscale x 8 x i16> %op1, i32 15)
  // CHECK: ret <vscale x 8 x i16> %[[INTRINSIC]]
  // overload-warning@+2 {{implicit declaration of function 'svqshlu_m'}}
  // expected-warning@+1 {{implicit declaration of function 'svqshlu_n_s16_m'}}
  return SVE_ACLE_FUNC(svqshlu,_n_s16,_m,)(pg, op1, 15);
}

svuint32_t test_svqshlu_n_s32_m(svbool_t pg, svint32_t op1)
{
  // CHECK-LABEL: test_svqshlu_n_s32_m
  // CHECK: %[[PG:.*]] = call <vscale x 4 x i1> @llvm.aarch64.sve.convert.from.svbool.nxv4i1(<vscale x 16 x i1> %pg)
  // CHECK: %[[INTRINSIC:.*]] = call <vscale x 4 x i32> @llvm.aarch64.sve.sqshlu.nxv4i32(<vscale x 4 x i1> %[[PG]], <vscale x 4 x i32> %op1, i32 0)
  // CHECK: ret <vscale x 4 x i32> %[[INTRINSIC]]
  // overload-warning@+2 {{implicit declaration of function 'svqshlu_m'}}
  // expected-warning@+1 {{implicit declaration of function 'svqshlu_n_s32_m'}}
  return SVE_ACLE_FUNC(svqshlu,_n_s32,_m,)(pg, op1, 0);
}

svuint32_t test_svqshlu_n_s32_m_1(svbool_t pg, svint32_t op1)
{
  // CHECK-LABEL: test_svqshlu_n_s32_m_1
  // CHECK: %[[PG:.*]] = call <vscale x 4 x i1> @llvm.aarch64.sve.convert.from.svbool.nxv4i1(<vscale x 16 x i1> %pg)
  // CHECK: %[[INTRINSIC:.*]] = call <vscale x 4 x i32> @llvm.aarch64.sve.sqshlu.nxv4i32(<vscale x 4 x i1> %[[PG]], <vscale x 4 x i32> %op1, i32 31)
  // CHECK: ret <vscale x 4 x i32> %[[INTRINSIC]]
  // overload-warning@+2 {{implicit declaration of function 'svqshlu_m'}}
  // expected-warning@+1 {{implicit declaration of function 'svqshlu_n_s32_m'}}
  return SVE_ACLE_FUNC(svqshlu,_n_s32,_m,)(pg, op1, 31);
}

svuint64_t test_svqshlu_n_s64_m(svbool_t pg, svint64_t op1)
{
  // CHECK-LABEL: test_svqshlu_n_s64_m
  // CHECK: %[[PG:.*]] = call <vscale x 2 x i1> @llvm.aarch64.sve.convert.from.svbool.nxv2i1(<vscale x 16 x i1> %pg)
  // CHECK: %[[INTRINSIC:.*]] = call <vscale x 2 x i64> @llvm.aarch64.sve.sqshlu.nxv2i64(<vscale x 2 x i1> %[[PG]], <vscale x 2 x i64> %op1, i32 0)
  // CHECK: ret <vscale x 2 x i64> %[[INTRINSIC]]
  // overload-warning@+2 {{implicit declaration of function 'svqshlu_m'}}
  // expected-warning@+1 {{implicit declaration of function 'svqshlu_n_s64_m'}}
  return SVE_ACLE_FUNC(svqshlu,_n_s64,_m,)(pg, op1, 0);
}

svuint64_t test_svqshlu_n_s64_m_1(svbool_t pg, svint64_t op1)
{
  // CHECK-LABEL: test_svqshlu_n_s64_m_1
  // CHECK: %[[PG:.*]] = call <vscale x 2 x i1> @llvm.aarch64.sve.convert.from.svbool.nxv2i1(<vscale x 16 x i1> %pg)
  // CHECK: %[[INTRINSIC:.*]] = call <vscale x 2 x i64> @llvm.aarch64.sve.sqshlu.nxv2i64(<vscale x 2 x i1> %[[PG]], <vscale x 2 x i64> %op1, i32 63)
  // CHECK: ret <vscale x 2 x i64> %[[INTRINSIC]]
  // overload-warning@+2 {{implicit declaration of function 'svqshlu_m'}}
  // expected-warning@+1 {{implicit declaration of function 'svqshlu_n_s64_m'}}
  return SVE_ACLE_FUNC(svqshlu,_n_s64,_m,)(pg, op1, 63);
}
