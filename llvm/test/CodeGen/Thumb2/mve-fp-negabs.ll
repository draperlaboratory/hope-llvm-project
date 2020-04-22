; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main-none-none-eabi -mattr=+mve,+fullfp16 -verify-machineinstrs %s -o - | FileCheck %s --check-prefix=CHECK --check-prefix=CHECK-MVE
; RUN: llc -mtriple=thumbv8.1m.main-none-none-eabi -mattr=+mve.fp -verify-machineinstrs %s -o - | FileCheck %s --check-prefix=CHECK --check-prefix=CHECK-MVEFP

define arm_aapcs_vfpcc <8 x half> @fneg_float16_t(<8 x half> %src) {
; CHECK-MVE-LABEL: fneg_float16_t:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vmovx.f16 s4, s0
; CHECK-MVE-NEXT:    vneg.f16 s8, s1
; CHECK-MVE-NEXT:    vneg.f16 s4, s4
; CHECK-MVE-NEXT:    vmov r0, s4
; CHECK-MVE-NEXT:    vneg.f16 s4, s0
; CHECK-MVE-NEXT:    vmov r1, s4
; CHECK-MVE-NEXT:    vmovx.f16 s0, s3
; CHECK-MVE-NEXT:    vmov.16 q1[0], r1
; CHECK-MVE-NEXT:    vneg.f16 s0, s0
; CHECK-MVE-NEXT:    vmov.16 q1[1], r0
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmovx.f16 s8, s1
; CHECK-MVE-NEXT:    vmov.16 q1[2], r0
; CHECK-MVE-NEXT:    vneg.f16 s8, s8
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vneg.f16 s8, s2
; CHECK-MVE-NEXT:    vmov.16 q1[3], r0
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmovx.f16 s8, s2
; CHECK-MVE-NEXT:    vmov.16 q1[4], r0
; CHECK-MVE-NEXT:    vneg.f16 s8, s8
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vneg.f16 s8, s3
; CHECK-MVE-NEXT:    vmov.16 q1[5], r0
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmov.16 q1[6], r0
; CHECK-MVE-NEXT:    vmov r0, s0
; CHECK-MVE-NEXT:    vmov.16 q1[7], r0
; CHECK-MVE-NEXT:    vmov q0, q1
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: fneg_float16_t:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vneg.f16 q0, q0
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %0 = fsub nnan ninf nsz <8 x half> <half 0.0e0, half 0.0e0, half 0.0e0, half 0.0e0, half 0.0e0, half 0.0e0, half 0.0e0, half 0.0e0>, %src
  ret <8 x half> %0
}

define arm_aapcs_vfpcc <4 x float> @fneg_float32_t(<4 x float> %src) {
; CHECK-MVE-LABEL: fneg_float32_t:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vneg.f32 s7, s3
; CHECK-MVE-NEXT:    vneg.f32 s6, s2
; CHECK-MVE-NEXT:    vneg.f32 s5, s1
; CHECK-MVE-NEXT:    vneg.f32 s4, s0
; CHECK-MVE-NEXT:    vmov q0, q1
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: fneg_float32_t:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vneg.f32 q0, q0
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %0 = fsub nnan ninf nsz <4 x float> <float 0.0e0, float 0.0e0, float 0.0e0, float 0.0e0>, %src
  ret <4 x float> %0
}

define arm_aapcs_vfpcc <2 x double> @fneg_float64_t(<2 x double> %src) {
; CHECK-LABEL: fneg_float64_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r7, lr}
; CHECK-NEXT:    push {r4, r5, r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vldr d0, .LCPI2_0
; CHECK-NEXT:    vmov r2, r3, d9
; CHECK-NEXT:    vmov r4, r5, d0
; CHECK-NEXT:    mov r0, r4
; CHECK-NEXT:    mov r1, r5
; CHECK-NEXT:    bl __aeabi_dsub
; CHECK-NEXT:    vmov r2, r3, d8
; CHECK-NEXT:    vmov d9, r0, r1
; CHECK-NEXT:    mov r0, r4
; CHECK-NEXT:    mov r1, r5
; CHECK-NEXT:    bl __aeabi_dsub
; CHECK-NEXT:    vmov d8, r0, r1
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r4, r5, r7, pc}
; CHECK-NEXT:    .p2align 3
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI2_0:
; CHECK-NEXT:    .long 0 @ double -0
; CHECK-NEXT:    .long 2147483648
entry:
  %0 = fsub nnan ninf nsz <2 x double> <double 0.0e0, double 0.0e0>, %src
  ret <2 x double> %0
}

define arm_aapcs_vfpcc <8 x half> @fabs_float16_t(<8 x half> %src) {
; CHECK-MVE-LABEL: fabs_float16_t:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vmovx.f16 s4, s0
; CHECK-MVE-NEXT:    vabs.f16 s8, s1
; CHECK-MVE-NEXT:    vabs.f16 s4, s4
; CHECK-MVE-NEXT:    vmov r0, s4
; CHECK-MVE-NEXT:    vabs.f16 s4, s0
; CHECK-MVE-NEXT:    vmov r1, s4
; CHECK-MVE-NEXT:    vmovx.f16 s0, s3
; CHECK-MVE-NEXT:    vmov.16 q1[0], r1
; CHECK-MVE-NEXT:    vabs.f16 s0, s0
; CHECK-MVE-NEXT:    vmov.16 q1[1], r0
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmovx.f16 s8, s1
; CHECK-MVE-NEXT:    vmov.16 q1[2], r0
; CHECK-MVE-NEXT:    vabs.f16 s8, s8
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vabs.f16 s8, s2
; CHECK-MVE-NEXT:    vmov.16 q1[3], r0
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmovx.f16 s8, s2
; CHECK-MVE-NEXT:    vmov.16 q1[4], r0
; CHECK-MVE-NEXT:    vabs.f16 s8, s8
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vabs.f16 s8, s3
; CHECK-MVE-NEXT:    vmov.16 q1[5], r0
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmov.16 q1[6], r0
; CHECK-MVE-NEXT:    vmov r0, s0
; CHECK-MVE-NEXT:    vmov.16 q1[7], r0
; CHECK-MVE-NEXT:    vmov q0, q1
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: fabs_float16_t:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vabs.f16 q0, q0
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %0 = call nnan ninf nsz <8 x half> @llvm.fabs.v8f16(<8 x half> %src)
  ret <8 x half> %0
}

define arm_aapcs_vfpcc <4 x float> @fabs_float32_t(<4 x float> %src) {
; CHECK-MVE-LABEL: fabs_float32_t:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vabs.f32 s7, s3
; CHECK-MVE-NEXT:    vabs.f32 s6, s2
; CHECK-MVE-NEXT:    vabs.f32 s5, s1
; CHECK-MVE-NEXT:    vabs.f32 s4, s0
; CHECK-MVE-NEXT:    vmov q0, q1
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: fabs_float32_t:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vabs.f32 q0, q0
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %0 = call nnan ninf nsz <4 x float> @llvm.fabs.v4f32(<4 x float> %src)
  ret <4 x float> %0
}

define arm_aapcs_vfpcc <2 x double> @fabs_float64_t(<2 x double> %src) {
; CHECK-LABEL: fabs_float64_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldr d2, .LCPI5_0
; CHECK-NEXT:    vmov r12, r3, d0
; CHECK-NEXT:    vmov r0, r1, d2
; CHECK-NEXT:    vmov r0, r2, d1
; CHECK-NEXT:    lsrs r1, r1, #31
; CHECK-NEXT:    bfi r2, r1, #31, #1
; CHECK-NEXT:    bfi r3, r1, #31, #1
; CHECK-NEXT:    vmov d1, r0, r2
; CHECK-NEXT:    vmov d0, r12, r3
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 3
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI5_0:
; CHECK-NEXT:    .long 0 @ double 0
; CHECK-NEXT:    .long 0
entry:
  %0 = call nnan ninf nsz <2 x double> @llvm.fabs.v2f64(<2 x double> %src)
  ret <2 x double> %0
}

declare <4 x float> @llvm.fabs.v4f32(<4 x float>)
declare <8 x half> @llvm.fabs.v8f16(<8 x half>)
declare <2 x double> @llvm.fabs.v2f64(<2 x double>)

