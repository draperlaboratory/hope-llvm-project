; RUN: llc -mtriple=riscv64 -mattr=+experimental-v -mattr=+experimental-zfh \
; RUN:   -mattr=+d -verify-machineinstrs \
; RUN:   --riscv-no-aliases < %s | FileCheck %s
declare <vscale x 1 x half> @llvm.riscv.vfrsub.nxv1f16.f16(
  <vscale x 1 x half>,
  half,
  i64);

define <vscale x 1 x half> @intrinsic_vfrsub_vf_nxv1f16_nxv1f16_f16(<vscale x 1 x half> %0, half %1, i64 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_vf_nxv1f16_nxv1f16_f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,mf4,ta,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}
  %a = call <vscale x 1 x half> @llvm.riscv.vfrsub.nxv1f16.f16(
    <vscale x 1 x half> %0,
    half %1,
    i64 %2)

  ret <vscale x 1 x half> %a
}

declare <vscale x 1 x half> @llvm.riscv.vfrsub.mask.nxv1f16.f16(
  <vscale x 1 x half>,
  <vscale x 1 x half>,
  half,
  <vscale x 1 x i1>,
  i64);

define <vscale x 1 x half> @intrinsic_vfrsub_mask_vf_nxv1f16_nxv1f16_f16(<vscale x 1 x half> %0, <vscale x 1 x half> %1, half %2, <vscale x 1 x i1> %3, i64 %4) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_mask_vf_nxv1f16_nxv1f16_f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,mf4,tu,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}, v0.t
  %a = call <vscale x 1 x half> @llvm.riscv.vfrsub.mask.nxv1f16.f16(
    <vscale x 1 x half> %0,
    <vscale x 1 x half> %1,
    half %2,
    <vscale x 1 x i1> %3,
    i64 %4)

  ret <vscale x 1 x half> %a
}

declare <vscale x 2 x half> @llvm.riscv.vfrsub.nxv2f16.f16(
  <vscale x 2 x half>,
  half,
  i64);

define <vscale x 2 x half> @intrinsic_vfrsub_vf_nxv2f16_nxv2f16_f16(<vscale x 2 x half> %0, half %1, i64 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_vf_nxv2f16_nxv2f16_f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,mf2,ta,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}
  %a = call <vscale x 2 x half> @llvm.riscv.vfrsub.nxv2f16.f16(
    <vscale x 2 x half> %0,
    half %1,
    i64 %2)

  ret <vscale x 2 x half> %a
}

declare <vscale x 2 x half> @llvm.riscv.vfrsub.mask.nxv2f16.f16(
  <vscale x 2 x half>,
  <vscale x 2 x half>,
  half,
  <vscale x 2 x i1>,
  i64);

define <vscale x 2 x half> @intrinsic_vfrsub_mask_vf_nxv2f16_nxv2f16_f16(<vscale x 2 x half> %0, <vscale x 2 x half> %1, half %2, <vscale x 2 x i1> %3, i64 %4) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_mask_vf_nxv2f16_nxv2f16_f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,mf2,tu,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}, v0.t
  %a = call <vscale x 2 x half> @llvm.riscv.vfrsub.mask.nxv2f16.f16(
    <vscale x 2 x half> %0,
    <vscale x 2 x half> %1,
    half %2,
    <vscale x 2 x i1> %3,
    i64 %4)

  ret <vscale x 2 x half> %a
}

declare <vscale x 4 x half> @llvm.riscv.vfrsub.nxv4f16.f16(
  <vscale x 4 x half>,
  half,
  i64);

define <vscale x 4 x half> @intrinsic_vfrsub_vf_nxv4f16_nxv4f16_f16(<vscale x 4 x half> %0, half %1, i64 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_vf_nxv4f16_nxv4f16_f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m1,ta,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}
  %a = call <vscale x 4 x half> @llvm.riscv.vfrsub.nxv4f16.f16(
    <vscale x 4 x half> %0,
    half %1,
    i64 %2)

  ret <vscale x 4 x half> %a
}

declare <vscale x 4 x half> @llvm.riscv.vfrsub.mask.nxv4f16.f16(
  <vscale x 4 x half>,
  <vscale x 4 x half>,
  half,
  <vscale x 4 x i1>,
  i64);

define <vscale x 4 x half> @intrinsic_vfrsub_mask_vf_nxv4f16_nxv4f16_f16(<vscale x 4 x half> %0, <vscale x 4 x half> %1, half %2, <vscale x 4 x i1> %3, i64 %4) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_mask_vf_nxv4f16_nxv4f16_f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m1,tu,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}, v0.t
  %a = call <vscale x 4 x half> @llvm.riscv.vfrsub.mask.nxv4f16.f16(
    <vscale x 4 x half> %0,
    <vscale x 4 x half> %1,
    half %2,
    <vscale x 4 x i1> %3,
    i64 %4)

  ret <vscale x 4 x half> %a
}

declare <vscale x 8 x half> @llvm.riscv.vfrsub.nxv8f16.f16(
  <vscale x 8 x half>,
  half,
  i64);

define <vscale x 8 x half> @intrinsic_vfrsub_vf_nxv8f16_nxv8f16_f16(<vscale x 8 x half> %0, half %1, i64 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_vf_nxv8f16_nxv8f16_f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m2,ta,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}
  %a = call <vscale x 8 x half> @llvm.riscv.vfrsub.nxv8f16.f16(
    <vscale x 8 x half> %0,
    half %1,
    i64 %2)

  ret <vscale x 8 x half> %a
}

declare <vscale x 8 x half> @llvm.riscv.vfrsub.mask.nxv8f16.f16(
  <vscale x 8 x half>,
  <vscale x 8 x half>,
  half,
  <vscale x 8 x i1>,
  i64);

define <vscale x 8 x half> @intrinsic_vfrsub_mask_vf_nxv8f16_nxv8f16_f16(<vscale x 8 x half> %0, <vscale x 8 x half> %1, half %2, <vscale x 8 x i1> %3, i64 %4) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_mask_vf_nxv8f16_nxv8f16_f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m2,tu,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}, v0.t
  %a = call <vscale x 8 x half> @llvm.riscv.vfrsub.mask.nxv8f16.f16(
    <vscale x 8 x half> %0,
    <vscale x 8 x half> %1,
    half %2,
    <vscale x 8 x i1> %3,
    i64 %4)

  ret <vscale x 8 x half> %a
}

declare <vscale x 16 x half> @llvm.riscv.vfrsub.nxv16f16.f16(
  <vscale x 16 x half>,
  half,
  i64);

define <vscale x 16 x half> @intrinsic_vfrsub_vf_nxv16f16_nxv16f16_f16(<vscale x 16 x half> %0, half %1, i64 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_vf_nxv16f16_nxv16f16_f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m4,ta,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}
  %a = call <vscale x 16 x half> @llvm.riscv.vfrsub.nxv16f16.f16(
    <vscale x 16 x half> %0,
    half %1,
    i64 %2)

  ret <vscale x 16 x half> %a
}

declare <vscale x 16 x half> @llvm.riscv.vfrsub.mask.nxv16f16.f16(
  <vscale x 16 x half>,
  <vscale x 16 x half>,
  half,
  <vscale x 16 x i1>,
  i64);

define <vscale x 16 x half> @intrinsic_vfrsub_mask_vf_nxv16f16_nxv16f16_f16(<vscale x 16 x half> %0, <vscale x 16 x half> %1, half %2, <vscale x 16 x i1> %3, i64 %4) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_mask_vf_nxv16f16_nxv16f16_f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m4,tu,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}, v0.t
  %a = call <vscale x 16 x half> @llvm.riscv.vfrsub.mask.nxv16f16.f16(
    <vscale x 16 x half> %0,
    <vscale x 16 x half> %1,
    half %2,
    <vscale x 16 x i1> %3,
    i64 %4)

  ret <vscale x 16 x half> %a
}

declare <vscale x 32 x half> @llvm.riscv.vfrsub.nxv32f16.f16(
  <vscale x 32 x half>,
  half,
  i64);

define <vscale x 32 x half> @intrinsic_vfrsub_vf_nxv32f16_nxv32f16_f16(<vscale x 32 x half> %0, half %1, i64 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_vf_nxv32f16_nxv32f16_f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m8,ta,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}
  %a = call <vscale x 32 x half> @llvm.riscv.vfrsub.nxv32f16.f16(
    <vscale x 32 x half> %0,
    half %1,
    i64 %2)

  ret <vscale x 32 x half> %a
}

declare <vscale x 32 x half> @llvm.riscv.vfrsub.mask.nxv32f16.f16(
  <vscale x 32 x half>,
  <vscale x 32 x half>,
  half,
  <vscale x 32 x i1>,
  i64);

define <vscale x 32 x half> @intrinsic_vfrsub_mask_vf_nxv32f16_nxv32f16_f16(<vscale x 32 x half> %0, <vscale x 32 x half> %1, half %2, <vscale x 32 x i1> %3, i64 %4) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_mask_vf_nxv32f16_nxv32f16_f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m8,tu,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}, v0.t
  %a = call <vscale x 32 x half> @llvm.riscv.vfrsub.mask.nxv32f16.f16(
    <vscale x 32 x half> %0,
    <vscale x 32 x half> %1,
    half %2,
    <vscale x 32 x i1> %3,
    i64 %4)

  ret <vscale x 32 x half> %a
}

declare <vscale x 1 x float> @llvm.riscv.vfrsub.nxv1f32.f32(
  <vscale x 1 x float>,
  float,
  i64);

define <vscale x 1 x float> @intrinsic_vfrsub_vf_nxv1f32_nxv1f32_f32(<vscale x 1 x float> %0, float %1, i64 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_vf_nxv1f32_nxv1f32_f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,mf2,ta,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}
  %a = call <vscale x 1 x float> @llvm.riscv.vfrsub.nxv1f32.f32(
    <vscale x 1 x float> %0,
    float %1,
    i64 %2)

  ret <vscale x 1 x float> %a
}

declare <vscale x 1 x float> @llvm.riscv.vfrsub.mask.nxv1f32.f32(
  <vscale x 1 x float>,
  <vscale x 1 x float>,
  float,
  <vscale x 1 x i1>,
  i64);

define <vscale x 1 x float> @intrinsic_vfrsub_mask_vf_nxv1f32_nxv1f32_f32(<vscale x 1 x float> %0, <vscale x 1 x float> %1, float %2, <vscale x 1 x i1> %3, i64 %4) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_mask_vf_nxv1f32_nxv1f32_f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,mf2,tu,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}, v0.t
  %a = call <vscale x 1 x float> @llvm.riscv.vfrsub.mask.nxv1f32.f32(
    <vscale x 1 x float> %0,
    <vscale x 1 x float> %1,
    float %2,
    <vscale x 1 x i1> %3,
    i64 %4)

  ret <vscale x 1 x float> %a
}

declare <vscale x 2 x float> @llvm.riscv.vfrsub.nxv2f32.f32(
  <vscale x 2 x float>,
  float,
  i64);

define <vscale x 2 x float> @intrinsic_vfrsub_vf_nxv2f32_nxv2f32_f32(<vscale x 2 x float> %0, float %1, i64 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_vf_nxv2f32_nxv2f32_f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m1,ta,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}
  %a = call <vscale x 2 x float> @llvm.riscv.vfrsub.nxv2f32.f32(
    <vscale x 2 x float> %0,
    float %1,
    i64 %2)

  ret <vscale x 2 x float> %a
}

declare <vscale x 2 x float> @llvm.riscv.vfrsub.mask.nxv2f32.f32(
  <vscale x 2 x float>,
  <vscale x 2 x float>,
  float,
  <vscale x 2 x i1>,
  i64);

define <vscale x 2 x float> @intrinsic_vfrsub_mask_vf_nxv2f32_nxv2f32_f32(<vscale x 2 x float> %0, <vscale x 2 x float> %1, float %2, <vscale x 2 x i1> %3, i64 %4) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_mask_vf_nxv2f32_nxv2f32_f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m1,tu,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}, v0.t
  %a = call <vscale x 2 x float> @llvm.riscv.vfrsub.mask.nxv2f32.f32(
    <vscale x 2 x float> %0,
    <vscale x 2 x float> %1,
    float %2,
    <vscale x 2 x i1> %3,
    i64 %4)

  ret <vscale x 2 x float> %a
}

declare <vscale x 4 x float> @llvm.riscv.vfrsub.nxv4f32.f32(
  <vscale x 4 x float>,
  float,
  i64);

define <vscale x 4 x float> @intrinsic_vfrsub_vf_nxv4f32_nxv4f32_f32(<vscale x 4 x float> %0, float %1, i64 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_vf_nxv4f32_nxv4f32_f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m2,ta,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}
  %a = call <vscale x 4 x float> @llvm.riscv.vfrsub.nxv4f32.f32(
    <vscale x 4 x float> %0,
    float %1,
    i64 %2)

  ret <vscale x 4 x float> %a
}

declare <vscale x 4 x float> @llvm.riscv.vfrsub.mask.nxv4f32.f32(
  <vscale x 4 x float>,
  <vscale x 4 x float>,
  float,
  <vscale x 4 x i1>,
  i64);

define <vscale x 4 x float> @intrinsic_vfrsub_mask_vf_nxv4f32_nxv4f32_f32(<vscale x 4 x float> %0, <vscale x 4 x float> %1, float %2, <vscale x 4 x i1> %3, i64 %4) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_mask_vf_nxv4f32_nxv4f32_f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m2,tu,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}, v0.t
  %a = call <vscale x 4 x float> @llvm.riscv.vfrsub.mask.nxv4f32.f32(
    <vscale x 4 x float> %0,
    <vscale x 4 x float> %1,
    float %2,
    <vscale x 4 x i1> %3,
    i64 %4)

  ret <vscale x 4 x float> %a
}

declare <vscale x 8 x float> @llvm.riscv.vfrsub.nxv8f32.f32(
  <vscale x 8 x float>,
  float,
  i64);

define <vscale x 8 x float> @intrinsic_vfrsub_vf_nxv8f32_nxv8f32_f32(<vscale x 8 x float> %0, float %1, i64 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_vf_nxv8f32_nxv8f32_f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m4,ta,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}
  %a = call <vscale x 8 x float> @llvm.riscv.vfrsub.nxv8f32.f32(
    <vscale x 8 x float> %0,
    float %1,
    i64 %2)

  ret <vscale x 8 x float> %a
}

declare <vscale x 8 x float> @llvm.riscv.vfrsub.mask.nxv8f32.f32(
  <vscale x 8 x float>,
  <vscale x 8 x float>,
  float,
  <vscale x 8 x i1>,
  i64);

define <vscale x 8 x float> @intrinsic_vfrsub_mask_vf_nxv8f32_nxv8f32_f32(<vscale x 8 x float> %0, <vscale x 8 x float> %1, float %2, <vscale x 8 x i1> %3, i64 %4) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_mask_vf_nxv8f32_nxv8f32_f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m4,tu,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}, v0.t
  %a = call <vscale x 8 x float> @llvm.riscv.vfrsub.mask.nxv8f32.f32(
    <vscale x 8 x float> %0,
    <vscale x 8 x float> %1,
    float %2,
    <vscale x 8 x i1> %3,
    i64 %4)

  ret <vscale x 8 x float> %a
}

declare <vscale x 16 x float> @llvm.riscv.vfrsub.nxv16f32.f32(
  <vscale x 16 x float>,
  float,
  i64);

define <vscale x 16 x float> @intrinsic_vfrsub_vf_nxv16f32_nxv16f32_f32(<vscale x 16 x float> %0, float %1, i64 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_vf_nxv16f32_nxv16f32_f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m8,ta,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}
  %a = call <vscale x 16 x float> @llvm.riscv.vfrsub.nxv16f32.f32(
    <vscale x 16 x float> %0,
    float %1,
    i64 %2)

  ret <vscale x 16 x float> %a
}

declare <vscale x 16 x float> @llvm.riscv.vfrsub.mask.nxv16f32.f32(
  <vscale x 16 x float>,
  <vscale x 16 x float>,
  float,
  <vscale x 16 x i1>,
  i64);

define <vscale x 16 x float> @intrinsic_vfrsub_mask_vf_nxv16f32_nxv16f32_f32(<vscale x 16 x float> %0, <vscale x 16 x float> %1, float %2, <vscale x 16 x i1> %3, i64 %4) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_mask_vf_nxv16f32_nxv16f32_f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m8,tu,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}, v0.t
  %a = call <vscale x 16 x float> @llvm.riscv.vfrsub.mask.nxv16f32.f32(
    <vscale x 16 x float> %0,
    <vscale x 16 x float> %1,
    float %2,
    <vscale x 16 x i1> %3,
    i64 %4)

  ret <vscale x 16 x float> %a
}

declare <vscale x 1 x double> @llvm.riscv.vfrsub.nxv1f64.f64(
  <vscale x 1 x double>,
  double,
  i64);

define <vscale x 1 x double> @intrinsic_vfrsub_vf_nxv1f64_nxv1f64_f64(<vscale x 1 x double> %0, double %1, i64 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_vf_nxv1f64_nxv1f64_f64
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e64,m1,ta,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}
  %a = call <vscale x 1 x double> @llvm.riscv.vfrsub.nxv1f64.f64(
    <vscale x 1 x double> %0,
    double %1,
    i64 %2)

  ret <vscale x 1 x double> %a
}

declare <vscale x 1 x double> @llvm.riscv.vfrsub.mask.nxv1f64.f64(
  <vscale x 1 x double>,
  <vscale x 1 x double>,
  double,
  <vscale x 1 x i1>,
  i64);

define <vscale x 1 x double> @intrinsic_vfrsub_mask_vf_nxv1f64_nxv1f64_f64(<vscale x 1 x double> %0, <vscale x 1 x double> %1, double %2, <vscale x 1 x i1> %3, i64 %4) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_mask_vf_nxv1f64_nxv1f64_f64
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e64,m1,tu,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}, v0.t
  %a = call <vscale x 1 x double> @llvm.riscv.vfrsub.mask.nxv1f64.f64(
    <vscale x 1 x double> %0,
    <vscale x 1 x double> %1,
    double %2,
    <vscale x 1 x i1> %3,
    i64 %4)

  ret <vscale x 1 x double> %a
}

declare <vscale x 2 x double> @llvm.riscv.vfrsub.nxv2f64.f64(
  <vscale x 2 x double>,
  double,
  i64);

define <vscale x 2 x double> @intrinsic_vfrsub_vf_nxv2f64_nxv2f64_f64(<vscale x 2 x double> %0, double %1, i64 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_vf_nxv2f64_nxv2f64_f64
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e64,m2,ta,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}
  %a = call <vscale x 2 x double> @llvm.riscv.vfrsub.nxv2f64.f64(
    <vscale x 2 x double> %0,
    double %1,
    i64 %2)

  ret <vscale x 2 x double> %a
}

declare <vscale x 2 x double> @llvm.riscv.vfrsub.mask.nxv2f64.f64(
  <vscale x 2 x double>,
  <vscale x 2 x double>,
  double,
  <vscale x 2 x i1>,
  i64);

define <vscale x 2 x double> @intrinsic_vfrsub_mask_vf_nxv2f64_nxv2f64_f64(<vscale x 2 x double> %0, <vscale x 2 x double> %1, double %2, <vscale x 2 x i1> %3, i64 %4) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_mask_vf_nxv2f64_nxv2f64_f64
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e64,m2,tu,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}, v0.t
  %a = call <vscale x 2 x double> @llvm.riscv.vfrsub.mask.nxv2f64.f64(
    <vscale x 2 x double> %0,
    <vscale x 2 x double> %1,
    double %2,
    <vscale x 2 x i1> %3,
    i64 %4)

  ret <vscale x 2 x double> %a
}

declare <vscale x 4 x double> @llvm.riscv.vfrsub.nxv4f64.f64(
  <vscale x 4 x double>,
  double,
  i64);

define <vscale x 4 x double> @intrinsic_vfrsub_vf_nxv4f64_nxv4f64_f64(<vscale x 4 x double> %0, double %1, i64 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_vf_nxv4f64_nxv4f64_f64
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e64,m4,ta,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}
  %a = call <vscale x 4 x double> @llvm.riscv.vfrsub.nxv4f64.f64(
    <vscale x 4 x double> %0,
    double %1,
    i64 %2)

  ret <vscale x 4 x double> %a
}

declare <vscale x 4 x double> @llvm.riscv.vfrsub.mask.nxv4f64.f64(
  <vscale x 4 x double>,
  <vscale x 4 x double>,
  double,
  <vscale x 4 x i1>,
  i64);

define <vscale x 4 x double> @intrinsic_vfrsub_mask_vf_nxv4f64_nxv4f64_f64(<vscale x 4 x double> %0, <vscale x 4 x double> %1, double %2, <vscale x 4 x i1> %3, i64 %4) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_mask_vf_nxv4f64_nxv4f64_f64
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e64,m4,tu,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}, v0.t
  %a = call <vscale x 4 x double> @llvm.riscv.vfrsub.mask.nxv4f64.f64(
    <vscale x 4 x double> %0,
    <vscale x 4 x double> %1,
    double %2,
    <vscale x 4 x i1> %3,
    i64 %4)

  ret <vscale x 4 x double> %a
}

declare <vscale x 8 x double> @llvm.riscv.vfrsub.nxv8f64.f64(
  <vscale x 8 x double>,
  double,
  i64);

define <vscale x 8 x double> @intrinsic_vfrsub_vf_nxv8f64_nxv8f64_f64(<vscale x 8 x double> %0, double %1, i64 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_vf_nxv8f64_nxv8f64_f64
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e64,m8,ta,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}
  %a = call <vscale x 8 x double> @llvm.riscv.vfrsub.nxv8f64.f64(
    <vscale x 8 x double> %0,
    double %1,
    i64 %2)

  ret <vscale x 8 x double> %a
}

declare <vscale x 8 x double> @llvm.riscv.vfrsub.mask.nxv8f64.f64(
  <vscale x 8 x double>,
  <vscale x 8 x double>,
  double,
  <vscale x 8 x i1>,
  i64);

define <vscale x 8 x double> @intrinsic_vfrsub_mask_vf_nxv8f64_nxv8f64_f64(<vscale x 8 x double> %0, <vscale x 8 x double> %1, double %2, <vscale x 8 x i1> %3, i64 %4) nounwind {
entry:
; CHECK-LABEL: intrinsic_vfrsub_mask_vf_nxv8f64_nxv8f64_f64
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e64,m8,tu,mu
; CHECK:       vfrsub.vf {{v[0-9]+}}, {{v[0-9]+}}, {{ft[0-9]+}}, v0.t
  %a = call <vscale x 8 x double> @llvm.riscv.vfrsub.mask.nxv8f64.f64(
    <vscale x 8 x double> %0,
    <vscale x 8 x double> %1,
    double %2,
    <vscale x 8 x i1> %3,
    i64 %4)

  ret <vscale x 8 x double> %a
}
