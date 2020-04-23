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

svfloat16_t test_svcvtnt_f16_f32_m(svfloat16_t inactive, svbool_t pg, svfloat32_t op)
{
  // CHECK-LABEL: test_svcvtnt_f16_f32_m
  // CHECK: %[[PG:.*]] = call <vscale x 4 x i1> @llvm.aarch64.sve.convert.from.svbool.nxv4i1(<vscale x 16 x i1> %pg)
  // CHECK: %[[INTRINSIC:.*]] = call <vscale x 8 x half> @llvm.aarch64.sve.fcvtnt.f16f32(<vscale x 8 x half> %inactive, <vscale x 4 x i1> %[[PG]], <vscale x 4 x float> %op)
  // CHECK: ret <vscale x 8 x half> %[[INTRINSIC]]
  // overload-warning@+2 {{implicit declaration of function 'svcvtnt_f16_m'}}
  // expected-warning@+1 {{implicit declaration of function 'svcvtnt_f16_f32_m'}}
  return SVE_ACLE_FUNC(svcvtnt_f16,_f32,_m,)(inactive, pg, op);
}

svfloat32_t test_svcvtnt_f32_f64_m(svfloat32_t inactive, svbool_t pg, svfloat64_t op)
{
  // CHECK-LABEL: test_svcvtnt_f32_f64_m
  // CHECK: %[[PG:.*]] = call <vscale x 2 x i1> @llvm.aarch64.sve.convert.from.svbool.nxv2i1(<vscale x 16 x i1> %pg)
  // CHECK: %[[INTRINSIC:.*]] = call <vscale x 4 x float> @llvm.aarch64.sve.fcvtnt.f32f64(<vscale x 4 x float> %inactive, <vscale x 2 x i1> %[[PG]], <vscale x 2 x double> %op)
  // CHECK: ret <vscale x 4 x float> %[[INTRINSIC]]
  // overload-warning@+2 {{implicit declaration of function 'svcvtnt_f32_m'}}
  // expected-warning@+1 {{implicit declaration of function 'svcvtnt_f32_f64_m'}}
  return SVE_ACLE_FUNC(svcvtnt_f32,_f64,_m,)(inactive, pg, op);
}

svfloat16_t test_svcvtnt_f16_f32_x(svfloat16_t even, svbool_t pg, svfloat32_t op)
{
  // CHECK-LABEL: test_svcvtnt_f16_f32_x
  // CHECK: %[[PG:.*]] = call <vscale x 4 x i1> @llvm.aarch64.sve.convert.from.svbool.nxv4i1(<vscale x 16 x i1> %pg)
  // CHECK: %[[INTRINSIC:.*]] = call <vscale x 8 x half> @llvm.aarch64.sve.fcvtnt.f16f32(<vscale x 8 x half> %even, <vscale x 4 x i1> %[[PG]], <vscale x 4 x float> %op)
  // CHECK: ret <vscale x 8 x half> %[[INTRINSIC]]
  // overload-warning@+2 {{implicit declaration of function 'svcvtnt_f16_x'}}
  // expected-warning@+1 {{implicit declaration of function 'svcvtnt_f16_f32_x'}}
  return SVE_ACLE_FUNC(svcvtnt_f16,_f32,_x,)(even, pg, op);
}

svfloat32_t test_svcvtnt_f32_f64_x(svfloat32_t even, svbool_t pg, svfloat64_t op)
{
  // CHECK-LABEL: test_svcvtnt_f32_f64_x
  // CHECK: %[[PG:.*]] = call <vscale x 2 x i1> @llvm.aarch64.sve.convert.from.svbool.nxv2i1(<vscale x 16 x i1> %pg)
  // CHECK: %[[INTRINSIC:.*]] = call <vscale x 4 x float> @llvm.aarch64.sve.fcvtnt.f32f64(<vscale x 4 x float> %even, <vscale x 2 x i1> %[[PG]], <vscale x 2 x double> %op)
  // CHECK: ret <vscale x 4 x float> %[[INTRINSIC]]
  // overload-warning@+2 {{implicit declaration of function 'svcvtnt_f32_x'}}
  // expected-warning@+1 {{implicit declaration of function 'svcvtnt_f32_f64_x'}}
  return SVE_ACLE_FUNC(svcvtnt_f32,_f64,_x,)(even, pg, op);
}
