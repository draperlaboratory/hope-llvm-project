; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main-arm-none-eabi -mattr=+mve -verify-machineinstrs %s -o - | FileCheck %s --check-prefix=CHECK

define arm_aapcs_vfpcc <2 x i64> @sext_02(<4 x i32> %src1, <4 x i32> %src2) {
; CHECK-LABEL: sext_02:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov r0, s4
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    smull r0, r1, r1, r0
; CHECK-NEXT:    vmov.32 q2[0], r0
; CHECK-NEXT:    vmov r0, s6
; CHECK-NEXT:    vmov.32 q2[1], r1
; CHECK-NEXT:    vmov r1, s2
; CHECK-NEXT:    smull r0, r1, r1, r0
; CHECK-NEXT:    vmov.32 q2[2], r0
; CHECK-NEXT:    vmov.32 q2[3], r1
; CHECK-NEXT:    vmov q0, q2
; CHECK-NEXT:    bx lr
entry:
  %shuf1 = shufflevector <4 x i32> %src1, <4 x i32> undef, <2 x i32> <i32 0, i32 2>
  %out1 = sext <2 x i32> %shuf1 to <2 x i64>
  %shuf2 = shufflevector <4 x i32> %src2, <4 x i32> undef, <2 x i32> <i32 0, i32 2>
  %out2 = sext <2 x i32> %shuf2 to <2 x i64>
  %out = mul <2 x i64> %out1, %out2
  ret <2 x i64> %out
}

define arm_aapcs_vfpcc <2 x i64> @sext_13(<4 x i32> %src1, <4 x i32> %src2) {
; CHECK-LABEL: sext_13:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vrev64.32 q2, q1
; CHECK-NEXT:    vrev64.32 q1, q0
; CHECK-NEXT:    vmov r0, s8
; CHECK-NEXT:    vmov r1, s4
; CHECK-NEXT:    smull r0, r1, r1, r0
; CHECK-NEXT:    vmov.32 q0[0], r0
; CHECK-NEXT:    vmov r0, s10
; CHECK-NEXT:    vmov.32 q0[1], r1
; CHECK-NEXT:    vmov r1, s6
; CHECK-NEXT:    smull r0, r1, r1, r0
; CHECK-NEXT:    vmov.32 q0[2], r0
; CHECK-NEXT:    vmov.32 q0[3], r1
; CHECK-NEXT:    bx lr
entry:
  %shuf1 = shufflevector <4 x i32> %src1, <4 x i32> undef, <2 x i32> <i32 1, i32 3>
  %out1 = sext <2 x i32> %shuf1 to <2 x i64>
  %shuf2 = shufflevector <4 x i32> %src2, <4 x i32> undef, <2 x i32> <i32 1, i32 3>
  %out2 = sext <2 x i32> %shuf2 to <2 x i64>
  %out = mul <2 x i64> %out1, %out2
  ret <2 x i64> %out
}

define arm_aapcs_vfpcc <2 x i64> @zext_02(<4 x i32> %src1, <4 x i32> %src2) {
; CHECK-LABEL: zext_02:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov r0, s4
; CHECK-NEXT:    vmov r1, s0
; CHECK-NEXT:    umull r0, r1, r1, r0
; CHECK-NEXT:    vmov.32 q2[0], r0
; CHECK-NEXT:    vmov r0, s6
; CHECK-NEXT:    vmov.32 q2[1], r1
; CHECK-NEXT:    vmov r1, s2
; CHECK-NEXT:    umull r0, r1, r1, r0
; CHECK-NEXT:    vmov.32 q2[2], r0
; CHECK-NEXT:    vmov.32 q2[3], r1
; CHECK-NEXT:    vmov q0, q2
; CHECK-NEXT:    bx lr
entry:
  %shuf1 = shufflevector <4 x i32> %src1, <4 x i32> undef, <2 x i32> <i32 0, i32 2>
  %out1 = zext <2 x i32> %shuf1 to <2 x i64>
  %shuf2 = shufflevector <4 x i32> %src2, <4 x i32> undef, <2 x i32> <i32 0, i32 2>
  %out2 = zext <2 x i32> %shuf2 to <2 x i64>
  %out = mul <2 x i64> %out1, %out2
  ret <2 x i64> %out
}

define arm_aapcs_vfpcc <2 x i64> @zext_13(<4 x i32> %src1, <4 x i32> %src2) {
; CHECK-LABEL: zext_13:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vrev64.32 q2, q1
; CHECK-NEXT:    vrev64.32 q1, q0
; CHECK-NEXT:    vmov r0, s8
; CHECK-NEXT:    vmov r1, s4
; CHECK-NEXT:    umull r0, r1, r1, r0
; CHECK-NEXT:    vmov.32 q0[0], r0
; CHECK-NEXT:    vmov r0, s10
; CHECK-NEXT:    vmov.32 q0[1], r1
; CHECK-NEXT:    vmov r1, s6
; CHECK-NEXT:    umull r0, r1, r1, r0
; CHECK-NEXT:    vmov.32 q0[2], r0
; CHECK-NEXT:    vmov.32 q0[3], r1
; CHECK-NEXT:    bx lr
entry:
  %shuf1 = shufflevector <4 x i32> %src1, <4 x i32> undef, <2 x i32> <i32 1, i32 3>
  %out1 = zext <2 x i32> %shuf1 to <2 x i64>
  %shuf2 = shufflevector <4 x i32> %src2, <4 x i32> undef, <2 x i32> <i32 1, i32 3>
  %out2 = zext <2 x i32> %shuf2 to <2 x i64>
  %out = mul <2 x i64> %out1, %out2
  ret <2 x i64> %out
}


define arm_aapcs_vfpcc <4 x i32> @sext_0246(<8 x i16> %src1, <8 x i16> %src2) {
; CHECK-LABEL: sext_0246:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmovlb.s16 q1, q1
; CHECK-NEXT:    vmovlb.s16 q0, q0
; CHECK-NEXT:    vmul.i32 q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %shuf1 = shufflevector <8 x i16> %src1, <8 x i16> undef, <4 x i32> <i32 0, i32 2, i32 4, i32 6>
  %out1 = sext <4 x i16> %shuf1 to <4 x i32>
  %shuf2 = shufflevector <8 x i16> %src2, <8 x i16> undef, <4 x i32> <i32 0, i32 2, i32 4, i32 6>
  %out2 = sext <4 x i16> %shuf2 to <4 x i32>
  %out = mul <4 x i32> %out1, %out2
  ret <4 x i32> %out
}

define arm_aapcs_vfpcc <4 x i32> @sext_1357(<8 x i16> %src1, <8 x i16> %src2) {
; CHECK-LABEL: sext_1357:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmovlt.s16 q1, q1
; CHECK-NEXT:    vmovlt.s16 q0, q0
; CHECK-NEXT:    vmul.i32 q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %shuf1 = shufflevector <8 x i16> %src1, <8 x i16> undef, <4 x i32> <i32 1, i32 3, i32 5, i32 7>
  %out1 = sext <4 x i16> %shuf1 to <4 x i32>
  %shuf2 = shufflevector <8 x i16> %src2, <8 x i16> undef, <4 x i32> <i32 1, i32 3, i32 5, i32 7>
  %out2 = sext <4 x i16> %shuf2 to <4 x i32>
  %out = mul <4 x i32> %out1, %out2
  ret <4 x i32> %out
}

define arm_aapcs_vfpcc <4 x i32> @zext_0246(<8 x i16> %src1, <8 x i16> %src2) {
; CHECK-LABEL: zext_0246:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmovlb.u16 q1, q1
; CHECK-NEXT:    vmovlb.u16 q0, q0
; CHECK-NEXT:    vmul.i32 q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %shuf1 = shufflevector <8 x i16> %src1, <8 x i16> undef, <4 x i32> <i32 0, i32 2, i32 4, i32 6>
  %out1 = zext <4 x i16> %shuf1 to <4 x i32>
  %shuf2 = shufflevector <8 x i16> %src2, <8 x i16> undef, <4 x i32> <i32 0, i32 2, i32 4, i32 6>
  %out2 = zext <4 x i16> %shuf2 to <4 x i32>
  %out = mul <4 x i32> %out1, %out2
  ret <4 x i32> %out
}

define arm_aapcs_vfpcc <4 x i32> @zext_1357(<8 x i16> %src1, <8 x i16> %src2) {
; CHECK-LABEL: zext_1357:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmovlt.u16 q1, q1
; CHECK-NEXT:    vmovlt.u16 q0, q0
; CHECK-NEXT:    vmul.i32 q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %shuf1 = shufflevector <8 x i16> %src1, <8 x i16> undef, <4 x i32> <i32 1, i32 3, i32 5, i32 7>
  %out1 = zext <4 x i16> %shuf1 to <4 x i32>
  %shuf2 = shufflevector <8 x i16> %src2, <8 x i16> undef, <4 x i32> <i32 1, i32 3, i32 5, i32 7>
  %out2 = zext <4 x i16> %shuf2 to <4 x i32>
  %out = mul <4 x i32> %out1, %out2
  ret <4 x i32> %out
}

define arm_aapcs_vfpcc <8 x i16> @sext_02468101214(<16 x i8> %src1, <16 x i8> %src2) {
; CHECK-LABEL: sext_02468101214:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmovlb.s8 q1, q1
; CHECK-NEXT:    vmovlb.s8 q0, q0
; CHECK-NEXT:    vmul.i16 q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %shuf1 = shufflevector <16 x i8> %src1, <16 x i8> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %out1 = sext <8 x i8> %shuf1 to <8 x i16>
  %shuf2 = shufflevector <16 x i8> %src2, <16 x i8> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %out2 = sext <8 x i8> %shuf2 to <8 x i16>
  %out = mul <8 x i16> %out1, %out2
  ret <8 x i16> %out
}

define arm_aapcs_vfpcc <8 x i16> @sext_13579111315(<16 x i8> %src1, <16 x i8> %src2) {
; CHECK-LABEL: sext_13579111315:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmovlt.s8 q1, q1
; CHECK-NEXT:    vmovlt.s8 q0, q0
; CHECK-NEXT:    vmul.i16 q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %shuf1 = shufflevector <16 x i8> %src1, <16 x i8> undef, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15>
  %out1 = sext <8 x i8> %shuf1 to <8 x i16>
  %shuf2 = shufflevector <16 x i8> %src2, <16 x i8> undef, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15>
  %out2 = sext <8 x i8> %shuf2 to <8 x i16>
  %out = mul <8 x i16> %out1, %out2
  ret <8 x i16> %out
}

define arm_aapcs_vfpcc <8 x i16> @zext_02468101214(<16 x i8> %src1, <16 x i8> %src2) {
; CHECK-LABEL: zext_02468101214:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmovlb.u8 q1, q1
; CHECK-NEXT:    vmovlb.u8 q0, q0
; CHECK-NEXT:    vmul.i16 q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %shuf1 = shufflevector <16 x i8> %src1, <16 x i8> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %out1 = zext <8 x i8> %shuf1 to <8 x i16>
  %shuf2 = shufflevector <16 x i8> %src2, <16 x i8> undef, <8 x i32> <i32 0, i32 2, i32 4, i32 6, i32 8, i32 10, i32 12, i32 14>
  %out2 = zext <8 x i8> %shuf2 to <8 x i16>
  %out = mul <8 x i16> %out1, %out2
  ret <8 x i16> %out
}

define arm_aapcs_vfpcc <8 x i16> @zext_13579111315(<16 x i8> %src1, <16 x i8> %src2) {
; CHECK-LABEL: zext_13579111315:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmovlt.u8 q1, q1
; CHECK-NEXT:    vmovlt.u8 q0, q0
; CHECK-NEXT:    vmul.i16 q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %shuf1 = shufflevector <16 x i8> %src1, <16 x i8> undef, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15>
  %out1 = zext <8 x i8> %shuf1 to <8 x i16>
  %shuf2 = shufflevector <16 x i8> %src2, <16 x i8> undef, <8 x i32> <i32 1, i32 3, i32 5, i32 7, i32 9, i32 11, i32 13, i32 15>
  %out2 = zext <8 x i8> %shuf2 to <8 x i16>
  %out = mul <8 x i16> %out1, %out2
  ret <8 x i16> %out
}
