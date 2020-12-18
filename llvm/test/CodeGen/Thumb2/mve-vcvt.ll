; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main-none-none-eabi -mattr=+mve,+fullfp16 -verify-machineinstrs %s -o - | FileCheck %s --check-prefix=CHECK --check-prefix=CHECK-MVE
; RUN: llc -mtriple=thumbv8.1m.main-none-none-eabi -mattr=+mve.fp -verify-machineinstrs %s -o - | FileCheck %s --check-prefix=CHECK --check-prefix=CHECK-MVEFP

define arm_aapcs_vfpcc <4 x float> @foo_float_int32(<4 x i32> %src) {
; CHECK-MVE-LABEL: foo_float_int32:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vcvt.f32.s32 s7, s3
; CHECK-MVE-NEXT:    vcvt.f32.s32 s6, s2
; CHECK-MVE-NEXT:    vcvt.f32.s32 s5, s1
; CHECK-MVE-NEXT:    vcvt.f32.s32 s4, s0
; CHECK-MVE-NEXT:    vmov q0, q1
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: foo_float_int32:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvt.f32.s32 q0, q0
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %out = sitofp <4 x i32> %src to <4 x float>
  ret <4 x float> %out
}

define arm_aapcs_vfpcc <4 x float> @foo_float_uint32(<4 x i32> %src) {
; CHECK-MVE-LABEL: foo_float_uint32:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vcvt.f32.u32 s7, s3
; CHECK-MVE-NEXT:    vcvt.f32.u32 s6, s2
; CHECK-MVE-NEXT:    vcvt.f32.u32 s5, s1
; CHECK-MVE-NEXT:    vcvt.f32.u32 s4, s0
; CHECK-MVE-NEXT:    vmov q0, q1
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: foo_float_uint32:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvt.f32.u32 q0, q0
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %out = uitofp <4 x i32> %src to <4 x float>
  ret <4 x float> %out
}

define arm_aapcs_vfpcc <4 x i32> @foo_int32_float(<4 x float> %src) {
; CHECK-MVE-LABEL: foo_int32_float:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vcvt.s32.f32 s4, s2
; CHECK-MVE-NEXT:    vcvt.s32.f32 s6, s0
; CHECK-MVE-NEXT:    vcvt.s32.f32 s8, s3
; CHECK-MVE-NEXT:    vcvt.s32.f32 s10, s1
; CHECK-MVE-NEXT:    vmov r0, s4
; CHECK-MVE-NEXT:    vmov r1, s6
; CHECK-MVE-NEXT:    vmov q0[2], q0[0], r1, r0
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmov r1, s10
; CHECK-MVE-NEXT:    vmov q0[3], q0[1], r1, r0
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: foo_int32_float:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvt.s32.f32 q0, q0
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %out = fptosi <4 x float> %src to <4 x i32>
  ret <4 x i32> %out
}

define arm_aapcs_vfpcc <4 x i32> @foo_uint32_float(<4 x float> %src) {
; CHECK-MVE-LABEL: foo_uint32_float:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vcvt.u32.f32 s4, s2
; CHECK-MVE-NEXT:    vcvt.u32.f32 s6, s0
; CHECK-MVE-NEXT:    vcvt.u32.f32 s8, s3
; CHECK-MVE-NEXT:    vcvt.u32.f32 s10, s1
; CHECK-MVE-NEXT:    vmov r0, s4
; CHECK-MVE-NEXT:    vmov r1, s6
; CHECK-MVE-NEXT:    vmov q0[2], q0[0], r1, r0
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmov r1, s10
; CHECK-MVE-NEXT:    vmov q0[3], q0[1], r1, r0
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: foo_uint32_float:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvt.u32.f32 q0, q0
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %out = fptoui <4 x float> %src to <4 x i32>
  ret <4 x i32> %out
}

define arm_aapcs_vfpcc <8 x half> @foo_half_int16(<8 x i16> %src) {
; CHECK-MVE-LABEL: foo_half_int16:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vmov.u16 r0, q0[0]
; CHECK-MVE-NEXT:    vmov.u16 r1, q0[1]
; CHECK-MVE-NEXT:    sxth r0, r0
; CHECK-MVE-NEXT:    sxth r1, r1
; CHECK-MVE-NEXT:    vmov s4, r0
; CHECK-MVE-NEXT:    vcvt.f16.s32 s4, s4
; CHECK-MVE-NEXT:    vmov r0, s4
; CHECK-MVE-NEXT:    vmov s4, r1
; CHECK-MVE-NEXT:    vcvt.f16.s32 s4, s4
; CHECK-MVE-NEXT:    vmov r1, s4
; CHECK-MVE-NEXT:    vmov.16 q1[0], r0
; CHECK-MVE-NEXT:    vmov.u16 r0, q0[2]
; CHECK-MVE-NEXT:    vmov.16 q1[1], r1
; CHECK-MVE-NEXT:    sxth r0, r0
; CHECK-MVE-NEXT:    vmov s8, r0
; CHECK-MVE-NEXT:    vcvt.f16.s32 s8, s8
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmov.16 q1[2], r0
; CHECK-MVE-NEXT:    vmov.u16 r0, q0[3]
; CHECK-MVE-NEXT:    sxth r0, r0
; CHECK-MVE-NEXT:    vmov s8, r0
; CHECK-MVE-NEXT:    vcvt.f16.s32 s8, s8
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmov.16 q1[3], r0
; CHECK-MVE-NEXT:    vmov.u16 r0, q0[4]
; CHECK-MVE-NEXT:    sxth r0, r0
; CHECK-MVE-NEXT:    vmov s8, r0
; CHECK-MVE-NEXT:    vcvt.f16.s32 s8, s8
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmov.16 q1[4], r0
; CHECK-MVE-NEXT:    vmov.u16 r0, q0[5]
; CHECK-MVE-NEXT:    sxth r0, r0
; CHECK-MVE-NEXT:    vmov s8, r0
; CHECK-MVE-NEXT:    vcvt.f16.s32 s8, s8
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmov.16 q1[5], r0
; CHECK-MVE-NEXT:    vmov.u16 r0, q0[6]
; CHECK-MVE-NEXT:    sxth r0, r0
; CHECK-MVE-NEXT:    vmov s8, r0
; CHECK-MVE-NEXT:    vcvt.f16.s32 s8, s8
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmov.16 q1[6], r0
; CHECK-MVE-NEXT:    vmov.u16 r0, q0[7]
; CHECK-MVE-NEXT:    sxth r0, r0
; CHECK-MVE-NEXT:    vmov s0, r0
; CHECK-MVE-NEXT:    vcvt.f16.s32 s0, s0
; CHECK-MVE-NEXT:    vmov r0, s0
; CHECK-MVE-NEXT:    vmov.16 q1[7], r0
; CHECK-MVE-NEXT:    vmov q0, q1
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: foo_half_int16:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvt.f16.s16 q0, q0
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %out = sitofp <8 x i16> %src to <8 x half>
  ret <8 x half> %out
}

define arm_aapcs_vfpcc <8 x half> @foo_half_uint16(<8 x i16> %src) {
; CHECK-MVE-LABEL: foo_half_uint16:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vmov.u16 r0, q0[0]
; CHECK-MVE-NEXT:    vmov.u16 r1, q0[1]
; CHECK-MVE-NEXT:    vmov s4, r0
; CHECK-MVE-NEXT:    vcvt.f16.u32 s4, s4
; CHECK-MVE-NEXT:    vmov r0, s4
; CHECK-MVE-NEXT:    vmov s4, r1
; CHECK-MVE-NEXT:    vcvt.f16.u32 s4, s4
; CHECK-MVE-NEXT:    vmov r1, s4
; CHECK-MVE-NEXT:    vmov.16 q1[0], r0
; CHECK-MVE-NEXT:    vmov.u16 r0, q0[2]
; CHECK-MVE-NEXT:    vmov.16 q1[1], r1
; CHECK-MVE-NEXT:    vmov s8, r0
; CHECK-MVE-NEXT:    vcvt.f16.u32 s8, s8
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmov.16 q1[2], r0
; CHECK-MVE-NEXT:    vmov.u16 r0, q0[3]
; CHECK-MVE-NEXT:    vmov s8, r0
; CHECK-MVE-NEXT:    vcvt.f16.u32 s8, s8
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmov.16 q1[3], r0
; CHECK-MVE-NEXT:    vmov.u16 r0, q0[4]
; CHECK-MVE-NEXT:    vmov s8, r0
; CHECK-MVE-NEXT:    vcvt.f16.u32 s8, s8
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmov.16 q1[4], r0
; CHECK-MVE-NEXT:    vmov.u16 r0, q0[5]
; CHECK-MVE-NEXT:    vmov s8, r0
; CHECK-MVE-NEXT:    vcvt.f16.u32 s8, s8
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmov.16 q1[5], r0
; CHECK-MVE-NEXT:    vmov.u16 r0, q0[6]
; CHECK-MVE-NEXT:    vmov s8, r0
; CHECK-MVE-NEXT:    vcvt.f16.u32 s8, s8
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vmov.16 q1[6], r0
; CHECK-MVE-NEXT:    vmov.u16 r0, q0[7]
; CHECK-MVE-NEXT:    vmov s0, r0
; CHECK-MVE-NEXT:    vcvt.f16.u32 s0, s0
; CHECK-MVE-NEXT:    vmov r0, s0
; CHECK-MVE-NEXT:    vmov.16 q1[7], r0
; CHECK-MVE-NEXT:    vmov q0, q1
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: foo_half_uint16:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvt.f16.u16 q0, q0
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %out = uitofp <8 x i16> %src to <8 x half>
  ret <8 x half> %out
}

define arm_aapcs_vfpcc <8 x i16> @foo_int16_half(<8 x half> %src) {
; CHECK-MVE-LABEL: foo_int16_half:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vmovx.f16 s14, s0
; CHECK-MVE-NEXT:    vcvt.s32.f16 s0, s0
; CHECK-MVE-NEXT:    vcvt.s32.f16 s14, s14
; CHECK-MVE-NEXT:    vmov r0, s0
; CHECK-MVE-NEXT:    vmovx.f16 s4, s3
; CHECK-MVE-NEXT:    vmovx.f16 s6, s2
; CHECK-MVE-NEXT:    vmovx.f16 s10, s1
; CHECK-MVE-NEXT:    vcvt.s32.f16 s8, s3
; CHECK-MVE-NEXT:    vcvt.s32.f16 s12, s2
; CHECK-MVE-NEXT:    vcvt.s32.f16 s5, s1
; CHECK-MVE-NEXT:    vmov.16 q0[0], r0
; CHECK-MVE-NEXT:    vmov r0, s14
; CHECK-MVE-NEXT:    vmov.16 q0[1], r0
; CHECK-MVE-NEXT:    vmov r0, s5
; CHECK-MVE-NEXT:    vcvt.s32.f16 s10, s10
; CHECK-MVE-NEXT:    vmov.16 q0[2], r0
; CHECK-MVE-NEXT:    vmov r0, s10
; CHECK-MVE-NEXT:    vcvt.s32.f16 s6, s6
; CHECK-MVE-NEXT:    vmov.16 q0[3], r0
; CHECK-MVE-NEXT:    vmov r0, s12
; CHECK-MVE-NEXT:    vmov.16 q0[4], r0
; CHECK-MVE-NEXT:    vmov r0, s6
; CHECK-MVE-NEXT:    vmov.16 q0[5], r0
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vcvt.s32.f16 s4, s4
; CHECK-MVE-NEXT:    vmov.16 q0[6], r0
; CHECK-MVE-NEXT:    vmov r0, s4
; CHECK-MVE-NEXT:    vmov.16 q0[7], r0
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: foo_int16_half:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvt.s16.f16 q0, q0
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %out = fptosi <8 x half> %src to <8 x i16>
  ret <8 x i16> %out
}

define arm_aapcs_vfpcc <8 x i16> @foo_uint16_half(<8 x half> %src) {
; CHECK-MVE-LABEL: foo_uint16_half:
; CHECK-MVE:       @ %bb.0: @ %entry
; CHECK-MVE-NEXT:    vmovx.f16 s14, s0
; CHECK-MVE-NEXT:    vcvt.s32.f16 s0, s0
; CHECK-MVE-NEXT:    vcvt.s32.f16 s14, s14
; CHECK-MVE-NEXT:    vmov r0, s0
; CHECK-MVE-NEXT:    vmovx.f16 s4, s3
; CHECK-MVE-NEXT:    vmovx.f16 s6, s2
; CHECK-MVE-NEXT:    vmovx.f16 s10, s1
; CHECK-MVE-NEXT:    vcvt.s32.f16 s8, s3
; CHECK-MVE-NEXT:    vcvt.s32.f16 s12, s2
; CHECK-MVE-NEXT:    vcvt.s32.f16 s5, s1
; CHECK-MVE-NEXT:    vmov.16 q0[0], r0
; CHECK-MVE-NEXT:    vmov r0, s14
; CHECK-MVE-NEXT:    vmov.16 q0[1], r0
; CHECK-MVE-NEXT:    vmov r0, s5
; CHECK-MVE-NEXT:    vcvt.s32.f16 s10, s10
; CHECK-MVE-NEXT:    vmov.16 q0[2], r0
; CHECK-MVE-NEXT:    vmov r0, s10
; CHECK-MVE-NEXT:    vcvt.s32.f16 s6, s6
; CHECK-MVE-NEXT:    vmov.16 q0[3], r0
; CHECK-MVE-NEXT:    vmov r0, s12
; CHECK-MVE-NEXT:    vmov.16 q0[4], r0
; CHECK-MVE-NEXT:    vmov r0, s6
; CHECK-MVE-NEXT:    vmov.16 q0[5], r0
; CHECK-MVE-NEXT:    vmov r0, s8
; CHECK-MVE-NEXT:    vcvt.s32.f16 s4, s4
; CHECK-MVE-NEXT:    vmov.16 q0[6], r0
; CHECK-MVE-NEXT:    vmov r0, s4
; CHECK-MVE-NEXT:    vmov.16 q0[7], r0
; CHECK-MVE-NEXT:    bx lr
;
; CHECK-MVEFP-LABEL: foo_uint16_half:
; CHECK-MVEFP:       @ %bb.0: @ %entry
; CHECK-MVEFP-NEXT:    vcvt.u16.f16 q0, q0
; CHECK-MVEFP-NEXT:    bx lr
entry:
  %out = fptoui <8 x half> %src to <8 x i16>
  ret <8 x i16> %out
}

define arm_aapcs_vfpcc <2 x double> @foo_float_int64(<2 x i64> %src) {
; CHECK-LABEL: foo_float_int64:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, s18
; CHECK-NEXT:    vmov r1, s19
; CHECK-NEXT:    bl __aeabi_l2d
; CHECK-NEXT:    vmov r2, s16
; CHECK-NEXT:    vmov r3, s17
; CHECK-NEXT:    vmov d9, r0, r1
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    mov r1, r3
; CHECK-NEXT:    bl __aeabi_l2d
; CHECK-NEXT:    vmov d8, r0, r1
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %out = sitofp <2 x i64> %src to <2 x double>
  ret <2 x double> %out
}

define arm_aapcs_vfpcc <2 x double> @foo_float_uint64(<2 x i64> %src) {
; CHECK-LABEL: foo_float_uint64:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r7, lr}
; CHECK-NEXT:    push {r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, s18
; CHECK-NEXT:    vmov r1, s19
; CHECK-NEXT:    bl __aeabi_ul2d
; CHECK-NEXT:    vmov r2, s16
; CHECK-NEXT:    vmov r3, s17
; CHECK-NEXT:    vmov d9, r0, r1
; CHECK-NEXT:    mov r0, r2
; CHECK-NEXT:    mov r1, r3
; CHECK-NEXT:    bl __aeabi_ul2d
; CHECK-NEXT:    vmov d8, r0, r1
; CHECK-NEXT:    vmov q0, q4
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r7, pc}
entry:
  %out = uitofp <2 x i64> %src to <2 x double>
  ret <2 x double> %out
}

define arm_aapcs_vfpcc <2 x i64> @foo_int64_float(<2 x double> %src) {
; CHECK-LABEL: foo_int64_float:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r7, lr}
; CHECK-NEXT:    push {r4, r5, r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, r1, d9
; CHECK-NEXT:    bl __aeabi_d2lz
; CHECK-NEXT:    mov r4, r0
; CHECK-NEXT:    mov r5, r1
; CHECK-NEXT:    vmov r0, r1, d8
; CHECK-NEXT:    bl __aeabi_d2lz
; CHECK-NEXT:    vmov q0[2], q0[0], r0, r4
; CHECK-NEXT:    vmov q0[3], q0[1], r1, r5
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r4, r5, r7, pc}
entry:
  %out = fptosi <2 x double> %src to <2 x i64>
  ret <2 x i64> %out
}

define arm_aapcs_vfpcc <2 x i64> @foo_uint64_float(<2 x double> %src) {
; CHECK-LABEL: foo_uint64_float:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    .save {r4, r5, r7, lr}
; CHECK-NEXT:    push {r4, r5, r7, lr}
; CHECK-NEXT:    .vsave {d8, d9}
; CHECK-NEXT:    vpush {d8, d9}
; CHECK-NEXT:    vmov q4, q0
; CHECK-NEXT:    vmov r0, r1, d9
; CHECK-NEXT:    bl __aeabi_d2ulz
; CHECK-NEXT:    mov r4, r0
; CHECK-NEXT:    mov r5, r1
; CHECK-NEXT:    vmov r0, r1, d8
; CHECK-NEXT:    bl __aeabi_d2ulz
; CHECK-NEXT:    vmov q0[2], q0[0], r0, r4
; CHECK-NEXT:    vmov q0[3], q0[1], r1, r5
; CHECK-NEXT:    vpop {d8, d9}
; CHECK-NEXT:    pop {r4, r5, r7, pc}
entry:
  %out = fptoui <2 x double> %src to <2 x i64>
  ret <2 x i64> %out
}
