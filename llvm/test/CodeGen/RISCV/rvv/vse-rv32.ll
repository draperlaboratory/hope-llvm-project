; RUN: llc -mtriple=riscv32 -mattr=+experimental-v -mattr=+experimental-zfh \
; RUN:   -mattr=+f -verify-machineinstrs \
; RUN:   --riscv-no-aliases < %s | FileCheck %s
declare void @llvm.riscv.vse.nxv1i32(
  <vscale x 1 x i32>,
  <vscale x 1 x i32>*,
  i32);

define void @intrinsic_vse_v_nxv1i32_nxv1i32(<vscale x 1 x i32> %0, <vscale x 1 x i32>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv1i32_nxv1i32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,mf2,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv1i32(
    <vscale x 1 x i32> %0,
    <vscale x 1 x i32>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv1i32(
  <vscale x 1 x i32>,
  <vscale x 1 x i32>*,
  <vscale x 1 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv1i32_nxv1i32(<vscale x 1 x i32> %0, <vscale x 1 x i32>* %1, <vscale x 1 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv1i32_nxv1i32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,mf2,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv1i32(
    <vscale x 1 x i32> %0,
    <vscale x 1 x i32>* %1,
    <vscale x 1 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv2i32(
  <vscale x 2 x i32>,
  <vscale x 2 x i32>*,
  i32);

define void @intrinsic_vse_v_nxv2i32_nxv2i32(<vscale x 2 x i32> %0, <vscale x 2 x i32>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv2i32_nxv2i32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m1,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv2i32(
    <vscale x 2 x i32> %0,
    <vscale x 2 x i32>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv2i32(
  <vscale x 2 x i32>,
  <vscale x 2 x i32>*,
  <vscale x 2 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv2i32_nxv2i32(<vscale x 2 x i32> %0, <vscale x 2 x i32>* %1, <vscale x 2 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv2i32_nxv2i32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m1,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv2i32(
    <vscale x 2 x i32> %0,
    <vscale x 2 x i32>* %1,
    <vscale x 2 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv4i32(
  <vscale x 4 x i32>,
  <vscale x 4 x i32>*,
  i32);

define void @intrinsic_vse_v_nxv4i32_nxv4i32(<vscale x 4 x i32> %0, <vscale x 4 x i32>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv4i32_nxv4i32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m2,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv4i32(
    <vscale x 4 x i32> %0,
    <vscale x 4 x i32>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv4i32(
  <vscale x 4 x i32>,
  <vscale x 4 x i32>*,
  <vscale x 4 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv4i32_nxv4i32(<vscale x 4 x i32> %0, <vscale x 4 x i32>* %1, <vscale x 4 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv4i32_nxv4i32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m2,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv4i32(
    <vscale x 4 x i32> %0,
    <vscale x 4 x i32>* %1,
    <vscale x 4 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv8i32(
  <vscale x 8 x i32>,
  <vscale x 8 x i32>*,
  i32);

define void @intrinsic_vse_v_nxv8i32_nxv8i32(<vscale x 8 x i32> %0, <vscale x 8 x i32>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv8i32_nxv8i32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m4,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv8i32(
    <vscale x 8 x i32> %0,
    <vscale x 8 x i32>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv8i32(
  <vscale x 8 x i32>,
  <vscale x 8 x i32>*,
  <vscale x 8 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv8i32_nxv8i32(<vscale x 8 x i32> %0, <vscale x 8 x i32>* %1, <vscale x 8 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv8i32_nxv8i32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m4,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv8i32(
    <vscale x 8 x i32> %0,
    <vscale x 8 x i32>* %1,
    <vscale x 8 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv16i32(
  <vscale x 16 x i32>,
  <vscale x 16 x i32>*,
  i32);

define void @intrinsic_vse_v_nxv16i32_nxv16i32(<vscale x 16 x i32> %0, <vscale x 16 x i32>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv16i32_nxv16i32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m8,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv16i32(
    <vscale x 16 x i32> %0,
    <vscale x 16 x i32>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv16i32(
  <vscale x 16 x i32>,
  <vscale x 16 x i32>*,
  <vscale x 16 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv16i32_nxv16i32(<vscale x 16 x i32> %0, <vscale x 16 x i32>* %1, <vscale x 16 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv16i32_nxv16i32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m8,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv16i32(
    <vscale x 16 x i32> %0,
    <vscale x 16 x i32>* %1,
    <vscale x 16 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv1f32(
  <vscale x 1 x float>,
  <vscale x 1 x float>*,
  i32);

define void @intrinsic_vse_v_nxv1f32_nxv1f32(<vscale x 1 x float> %0, <vscale x 1 x float>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv1f32_nxv1f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,mf2,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv1f32(
    <vscale x 1 x float> %0,
    <vscale x 1 x float>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv1f32(
  <vscale x 1 x float>,
  <vscale x 1 x float>*,
  <vscale x 1 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv1f32_nxv1f32(<vscale x 1 x float> %0, <vscale x 1 x float>* %1, <vscale x 1 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv1f32_nxv1f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,mf2,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv1f32(
    <vscale x 1 x float> %0,
    <vscale x 1 x float>* %1,
    <vscale x 1 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv2f32(
  <vscale x 2 x float>,
  <vscale x 2 x float>*,
  i32);

define void @intrinsic_vse_v_nxv2f32_nxv2f32(<vscale x 2 x float> %0, <vscale x 2 x float>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv2f32_nxv2f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m1,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv2f32(
    <vscale x 2 x float> %0,
    <vscale x 2 x float>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv2f32(
  <vscale x 2 x float>,
  <vscale x 2 x float>*,
  <vscale x 2 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv2f32_nxv2f32(<vscale x 2 x float> %0, <vscale x 2 x float>* %1, <vscale x 2 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv2f32_nxv2f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m1,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv2f32(
    <vscale x 2 x float> %0,
    <vscale x 2 x float>* %1,
    <vscale x 2 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv4f32(
  <vscale x 4 x float>,
  <vscale x 4 x float>*,
  i32);

define void @intrinsic_vse_v_nxv4f32_nxv4f32(<vscale x 4 x float> %0, <vscale x 4 x float>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv4f32_nxv4f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m2,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv4f32(
    <vscale x 4 x float> %0,
    <vscale x 4 x float>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv4f32(
  <vscale x 4 x float>,
  <vscale x 4 x float>*,
  <vscale x 4 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv4f32_nxv4f32(<vscale x 4 x float> %0, <vscale x 4 x float>* %1, <vscale x 4 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv4f32_nxv4f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m2,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv4f32(
    <vscale x 4 x float> %0,
    <vscale x 4 x float>* %1,
    <vscale x 4 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv8f32(
  <vscale x 8 x float>,
  <vscale x 8 x float>*,
  i32);

define void @intrinsic_vse_v_nxv8f32_nxv8f32(<vscale x 8 x float> %0, <vscale x 8 x float>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv8f32_nxv8f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m4,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv8f32(
    <vscale x 8 x float> %0,
    <vscale x 8 x float>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv8f32(
  <vscale x 8 x float>,
  <vscale x 8 x float>*,
  <vscale x 8 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv8f32_nxv8f32(<vscale x 8 x float> %0, <vscale x 8 x float>* %1, <vscale x 8 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv8f32_nxv8f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m4,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv8f32(
    <vscale x 8 x float> %0,
    <vscale x 8 x float>* %1,
    <vscale x 8 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv16f32(
  <vscale x 16 x float>,
  <vscale x 16 x float>*,
  i32);

define void @intrinsic_vse_v_nxv16f32_nxv16f32(<vscale x 16 x float> %0, <vscale x 16 x float>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv16f32_nxv16f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m8,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv16f32(
    <vscale x 16 x float> %0,
    <vscale x 16 x float>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv16f32(
  <vscale x 16 x float>,
  <vscale x 16 x float>*,
  <vscale x 16 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv16f32_nxv16f32(<vscale x 16 x float> %0, <vscale x 16 x float>* %1, <vscale x 16 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv16f32_nxv16f32
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e32,m8,ta,mu
; CHECK:       vse32.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv16f32(
    <vscale x 16 x float> %0,
    <vscale x 16 x float>* %1,
    <vscale x 16 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv1i16(
  <vscale x 1 x i16>,
  <vscale x 1 x i16>*,
  i32);

define void @intrinsic_vse_v_nxv1i16_nxv1i16(<vscale x 1 x i16> %0, <vscale x 1 x i16>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv1i16_nxv1i16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,mf4,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv1i16(
    <vscale x 1 x i16> %0,
    <vscale x 1 x i16>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv1i16(
  <vscale x 1 x i16>,
  <vscale x 1 x i16>*,
  <vscale x 1 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv1i16_nxv1i16(<vscale x 1 x i16> %0, <vscale x 1 x i16>* %1, <vscale x 1 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv1i16_nxv1i16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,mf4,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv1i16(
    <vscale x 1 x i16> %0,
    <vscale x 1 x i16>* %1,
    <vscale x 1 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv2i16(
  <vscale x 2 x i16>,
  <vscale x 2 x i16>*,
  i32);

define void @intrinsic_vse_v_nxv2i16_nxv2i16(<vscale x 2 x i16> %0, <vscale x 2 x i16>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv2i16_nxv2i16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,mf2,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv2i16(
    <vscale x 2 x i16> %0,
    <vscale x 2 x i16>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv2i16(
  <vscale x 2 x i16>,
  <vscale x 2 x i16>*,
  <vscale x 2 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv2i16_nxv2i16(<vscale x 2 x i16> %0, <vscale x 2 x i16>* %1, <vscale x 2 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv2i16_nxv2i16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,mf2,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv2i16(
    <vscale x 2 x i16> %0,
    <vscale x 2 x i16>* %1,
    <vscale x 2 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv4i16(
  <vscale x 4 x i16>,
  <vscale x 4 x i16>*,
  i32);

define void @intrinsic_vse_v_nxv4i16_nxv4i16(<vscale x 4 x i16> %0, <vscale x 4 x i16>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv4i16_nxv4i16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m1,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv4i16(
    <vscale x 4 x i16> %0,
    <vscale x 4 x i16>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv4i16(
  <vscale x 4 x i16>,
  <vscale x 4 x i16>*,
  <vscale x 4 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv4i16_nxv4i16(<vscale x 4 x i16> %0, <vscale x 4 x i16>* %1, <vscale x 4 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv4i16_nxv4i16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m1,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv4i16(
    <vscale x 4 x i16> %0,
    <vscale x 4 x i16>* %1,
    <vscale x 4 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv8i16(
  <vscale x 8 x i16>,
  <vscale x 8 x i16>*,
  i32);

define void @intrinsic_vse_v_nxv8i16_nxv8i16(<vscale x 8 x i16> %0, <vscale x 8 x i16>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv8i16_nxv8i16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m2,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv8i16(
    <vscale x 8 x i16> %0,
    <vscale x 8 x i16>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv8i16(
  <vscale x 8 x i16>,
  <vscale x 8 x i16>*,
  <vscale x 8 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv8i16_nxv8i16(<vscale x 8 x i16> %0, <vscale x 8 x i16>* %1, <vscale x 8 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv8i16_nxv8i16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m2,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv8i16(
    <vscale x 8 x i16> %0,
    <vscale x 8 x i16>* %1,
    <vscale x 8 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv16i16(
  <vscale x 16 x i16>,
  <vscale x 16 x i16>*,
  i32);

define void @intrinsic_vse_v_nxv16i16_nxv16i16(<vscale x 16 x i16> %0, <vscale x 16 x i16>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv16i16_nxv16i16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m4,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv16i16(
    <vscale x 16 x i16> %0,
    <vscale x 16 x i16>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv16i16(
  <vscale x 16 x i16>,
  <vscale x 16 x i16>*,
  <vscale x 16 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv16i16_nxv16i16(<vscale x 16 x i16> %0, <vscale x 16 x i16>* %1, <vscale x 16 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv16i16_nxv16i16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m4,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv16i16(
    <vscale x 16 x i16> %0,
    <vscale x 16 x i16>* %1,
    <vscale x 16 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv32i16(
  <vscale x 32 x i16>,
  <vscale x 32 x i16>*,
  i32);

define void @intrinsic_vse_v_nxv32i16_nxv32i16(<vscale x 32 x i16> %0, <vscale x 32 x i16>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv32i16_nxv32i16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m8,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv32i16(
    <vscale x 32 x i16> %0,
    <vscale x 32 x i16>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv32i16(
  <vscale x 32 x i16>,
  <vscale x 32 x i16>*,
  <vscale x 32 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv32i16_nxv32i16(<vscale x 32 x i16> %0, <vscale x 32 x i16>* %1, <vscale x 32 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv32i16_nxv32i16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m8,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv32i16(
    <vscale x 32 x i16> %0,
    <vscale x 32 x i16>* %1,
    <vscale x 32 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv1f16(
  <vscale x 1 x half>,
  <vscale x 1 x half>*,
  i32);

define void @intrinsic_vse_v_nxv1f16_nxv1f16(<vscale x 1 x half> %0, <vscale x 1 x half>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv1f16_nxv1f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,mf4,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv1f16(
    <vscale x 1 x half> %0,
    <vscale x 1 x half>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv1f16(
  <vscale x 1 x half>,
  <vscale x 1 x half>*,
  <vscale x 1 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv1f16_nxv1f16(<vscale x 1 x half> %0, <vscale x 1 x half>* %1, <vscale x 1 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv1f16_nxv1f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,mf4,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv1f16(
    <vscale x 1 x half> %0,
    <vscale x 1 x half>* %1,
    <vscale x 1 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv2f16(
  <vscale x 2 x half>,
  <vscale x 2 x half>*,
  i32);

define void @intrinsic_vse_v_nxv2f16_nxv2f16(<vscale x 2 x half> %0, <vscale x 2 x half>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv2f16_nxv2f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,mf2,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv2f16(
    <vscale x 2 x half> %0,
    <vscale x 2 x half>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv2f16(
  <vscale x 2 x half>,
  <vscale x 2 x half>*,
  <vscale x 2 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv2f16_nxv2f16(<vscale x 2 x half> %0, <vscale x 2 x half>* %1, <vscale x 2 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv2f16_nxv2f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,mf2,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv2f16(
    <vscale x 2 x half> %0,
    <vscale x 2 x half>* %1,
    <vscale x 2 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv4f16(
  <vscale x 4 x half>,
  <vscale x 4 x half>*,
  i32);

define void @intrinsic_vse_v_nxv4f16_nxv4f16(<vscale x 4 x half> %0, <vscale x 4 x half>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv4f16_nxv4f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m1,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv4f16(
    <vscale x 4 x half> %0,
    <vscale x 4 x half>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv4f16(
  <vscale x 4 x half>,
  <vscale x 4 x half>*,
  <vscale x 4 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv4f16_nxv4f16(<vscale x 4 x half> %0, <vscale x 4 x half>* %1, <vscale x 4 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv4f16_nxv4f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m1,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv4f16(
    <vscale x 4 x half> %0,
    <vscale x 4 x half>* %1,
    <vscale x 4 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv8f16(
  <vscale x 8 x half>,
  <vscale x 8 x half>*,
  i32);

define void @intrinsic_vse_v_nxv8f16_nxv8f16(<vscale x 8 x half> %0, <vscale x 8 x half>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv8f16_nxv8f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m2,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv8f16(
    <vscale x 8 x half> %0,
    <vscale x 8 x half>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv8f16(
  <vscale x 8 x half>,
  <vscale x 8 x half>*,
  <vscale x 8 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv8f16_nxv8f16(<vscale x 8 x half> %0, <vscale x 8 x half>* %1, <vscale x 8 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv8f16_nxv8f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m2,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv8f16(
    <vscale x 8 x half> %0,
    <vscale x 8 x half>* %1,
    <vscale x 8 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv16f16(
  <vscale x 16 x half>,
  <vscale x 16 x half>*,
  i32);

define void @intrinsic_vse_v_nxv16f16_nxv16f16(<vscale x 16 x half> %0, <vscale x 16 x half>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv16f16_nxv16f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m4,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv16f16(
    <vscale x 16 x half> %0,
    <vscale x 16 x half>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv16f16(
  <vscale x 16 x half>,
  <vscale x 16 x half>*,
  <vscale x 16 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv16f16_nxv16f16(<vscale x 16 x half> %0, <vscale x 16 x half>* %1, <vscale x 16 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv16f16_nxv16f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m4,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv16f16(
    <vscale x 16 x half> %0,
    <vscale x 16 x half>* %1,
    <vscale x 16 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv32f16(
  <vscale x 32 x half>,
  <vscale x 32 x half>*,
  i32);

define void @intrinsic_vse_v_nxv32f16_nxv32f16(<vscale x 32 x half> %0, <vscale x 32 x half>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv32f16_nxv32f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m8,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv32f16(
    <vscale x 32 x half> %0,
    <vscale x 32 x half>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv32f16(
  <vscale x 32 x half>,
  <vscale x 32 x half>*,
  <vscale x 32 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv32f16_nxv32f16(<vscale x 32 x half> %0, <vscale x 32 x half>* %1, <vscale x 32 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv32f16_nxv32f16
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e16,m8,ta,mu
; CHECK:       vse16.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv32f16(
    <vscale x 32 x half> %0,
    <vscale x 32 x half>* %1,
    <vscale x 32 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv1i8(
  <vscale x 1 x i8>,
  <vscale x 1 x i8>*,
  i32);

define void @intrinsic_vse_v_nxv1i8_nxv1i8(<vscale x 1 x i8> %0, <vscale x 1 x i8>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv1i8_nxv1i8
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e8,mf8,ta,mu
; CHECK:       vse8.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv1i8(
    <vscale x 1 x i8> %0,
    <vscale x 1 x i8>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv1i8(
  <vscale x 1 x i8>,
  <vscale x 1 x i8>*,
  <vscale x 1 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv1i8_nxv1i8(<vscale x 1 x i8> %0, <vscale x 1 x i8>* %1, <vscale x 1 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv1i8_nxv1i8
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e8,mf8,ta,mu
; CHECK:       vse8.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv1i8(
    <vscale x 1 x i8> %0,
    <vscale x 1 x i8>* %1,
    <vscale x 1 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv2i8(
  <vscale x 2 x i8>,
  <vscale x 2 x i8>*,
  i32);

define void @intrinsic_vse_v_nxv2i8_nxv2i8(<vscale x 2 x i8> %0, <vscale x 2 x i8>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv2i8_nxv2i8
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e8,mf4,ta,mu
; CHECK:       vse8.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv2i8(
    <vscale x 2 x i8> %0,
    <vscale x 2 x i8>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv2i8(
  <vscale x 2 x i8>,
  <vscale x 2 x i8>*,
  <vscale x 2 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv2i8_nxv2i8(<vscale x 2 x i8> %0, <vscale x 2 x i8>* %1, <vscale x 2 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv2i8_nxv2i8
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e8,mf4,ta,mu
; CHECK:       vse8.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv2i8(
    <vscale x 2 x i8> %0,
    <vscale x 2 x i8>* %1,
    <vscale x 2 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv4i8(
  <vscale x 4 x i8>,
  <vscale x 4 x i8>*,
  i32);

define void @intrinsic_vse_v_nxv4i8_nxv4i8(<vscale x 4 x i8> %0, <vscale x 4 x i8>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv4i8_nxv4i8
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e8,mf2,ta,mu
; CHECK:       vse8.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv4i8(
    <vscale x 4 x i8> %0,
    <vscale x 4 x i8>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv4i8(
  <vscale x 4 x i8>,
  <vscale x 4 x i8>*,
  <vscale x 4 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv4i8_nxv4i8(<vscale x 4 x i8> %0, <vscale x 4 x i8>* %1, <vscale x 4 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv4i8_nxv4i8
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e8,mf2,ta,mu
; CHECK:       vse8.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv4i8(
    <vscale x 4 x i8> %0,
    <vscale x 4 x i8>* %1,
    <vscale x 4 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv8i8(
  <vscale x 8 x i8>,
  <vscale x 8 x i8>*,
  i32);

define void @intrinsic_vse_v_nxv8i8_nxv8i8(<vscale x 8 x i8> %0, <vscale x 8 x i8>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv8i8_nxv8i8
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e8,m1,ta,mu
; CHECK:       vse8.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv8i8(
    <vscale x 8 x i8> %0,
    <vscale x 8 x i8>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv8i8(
  <vscale x 8 x i8>,
  <vscale x 8 x i8>*,
  <vscale x 8 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv8i8_nxv8i8(<vscale x 8 x i8> %0, <vscale x 8 x i8>* %1, <vscale x 8 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv8i8_nxv8i8
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e8,m1,ta,mu
; CHECK:       vse8.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv8i8(
    <vscale x 8 x i8> %0,
    <vscale x 8 x i8>* %1,
    <vscale x 8 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv16i8(
  <vscale x 16 x i8>,
  <vscale x 16 x i8>*,
  i32);

define void @intrinsic_vse_v_nxv16i8_nxv16i8(<vscale x 16 x i8> %0, <vscale x 16 x i8>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv16i8_nxv16i8
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e8,m2,ta,mu
; CHECK:       vse8.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv16i8(
    <vscale x 16 x i8> %0,
    <vscale x 16 x i8>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv16i8(
  <vscale x 16 x i8>,
  <vscale x 16 x i8>*,
  <vscale x 16 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv16i8_nxv16i8(<vscale x 16 x i8> %0, <vscale x 16 x i8>* %1, <vscale x 16 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv16i8_nxv16i8
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e8,m2,ta,mu
; CHECK:       vse8.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv16i8(
    <vscale x 16 x i8> %0,
    <vscale x 16 x i8>* %1,
    <vscale x 16 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv32i8(
  <vscale x 32 x i8>,
  <vscale x 32 x i8>*,
  i32);

define void @intrinsic_vse_v_nxv32i8_nxv32i8(<vscale x 32 x i8> %0, <vscale x 32 x i8>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv32i8_nxv32i8
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e8,m4,ta,mu
; CHECK:       vse8.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv32i8(
    <vscale x 32 x i8> %0,
    <vscale x 32 x i8>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv32i8(
  <vscale x 32 x i8>,
  <vscale x 32 x i8>*,
  <vscale x 32 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv32i8_nxv32i8(<vscale x 32 x i8> %0, <vscale x 32 x i8>* %1, <vscale x 32 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv32i8_nxv32i8
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e8,m4,ta,mu
; CHECK:       vse8.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv32i8(
    <vscale x 32 x i8> %0,
    <vscale x 32 x i8>* %1,
    <vscale x 32 x i1> %2,
    i32 %3)

  ret void
}

declare void @llvm.riscv.vse.nxv64i8(
  <vscale x 64 x i8>,
  <vscale x 64 x i8>*,
  i32);

define void @intrinsic_vse_v_nxv64i8_nxv64i8(<vscale x 64 x i8> %0, <vscale x 64 x i8>* %1, i32 %2) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_v_nxv64i8_nxv64i8
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e8,m8,ta,mu
; CHECK:       vse8.v {{v[0-9]+}}, (a0)
  call void @llvm.riscv.vse.nxv64i8(
    <vscale x 64 x i8> %0,
    <vscale x 64 x i8>* %1,
    i32 %2)

  ret void
}

declare void @llvm.riscv.vse.mask.nxv64i8(
  <vscale x 64 x i8>,
  <vscale x 64 x i8>*,
  <vscale x 64 x i1>,
  i32);

define void @intrinsic_vse_mask_v_nxv64i8_nxv64i8(<vscale x 64 x i8> %0, <vscale x 64 x i8>* %1, <vscale x 64 x i1> %2, i32 %3) nounwind {
entry:
; CHECK-LABEL: intrinsic_vse_mask_v_nxv64i8_nxv64i8
; CHECK:       vsetvli {{.*}}, {{a[0-9]+}}, e8,m8,ta,mu
; CHECK:       vse8.v {{v[0-9]+}}, (a0), v0.t
  call void @llvm.riscv.vse.mask.nxv64i8(
    <vscale x 64 x i8> %0,
    <vscale x 64 x i8>* %1,
    <vscale x 64 x i1> %2,
    i32 %3)

  ret void
}
