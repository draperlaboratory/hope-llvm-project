; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main-none-none-eabi -mattr=+mve -verify-machineinstrs %s -o - | FileCheck %s


define arm_aapcs_vfpcc <4 x i32> @build_var0_v4i1(i32 %s, i32 %t, <4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: build_var0_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r0, r1
; CHECK-NEXT:    mov.w r1, #0
; CHECK-NEXT:    cset r0, lo
; CHECK-NEXT:    and r0, r0, #1
; CHECK-NEXT:    rsbs r0, r0, #0
; CHECK-NEXT:    bfi r1, r0, #0, #4
; CHECK-NEXT:    vmsr p0, r1
; CHECK-NEXT:    vpsel q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ult i32 %s, %t
  %vc = insertelement <4 x i1> zeroinitializer, i1 %c, i64 0
  %r = select <4 x i1> %vc, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %r
}

define arm_aapcs_vfpcc <4 x i32> @build_var3_v4i1(i32 %s, i32 %t, <4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: build_var3_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r0, r1
; CHECK-NEXT:    mov.w r1, #0
; CHECK-NEXT:    cset r0, lo
; CHECK-NEXT:    and r0, r0, #1
; CHECK-NEXT:    rsbs r0, r0, #0
; CHECK-NEXT:    bfi r1, r0, #12, #4
; CHECK-NEXT:    vmsr p0, r1
; CHECK-NEXT:    vpsel q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ult i32 %s, %t
  %vc = insertelement <4 x i1> zeroinitializer, i1 %c, i64 3
  %r = select <4 x i1> %vc, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %r
}

define arm_aapcs_vfpcc <4 x i32> @build_varN_v4i1(i32 %s, i32 %t, <4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: build_varN_v4i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r0, r1
; CHECK-NEXT:    cset r0, lo
; CHECK-NEXT:    and r0, r0, #1
; CHECK-NEXT:    rsbs r0, r0, #0
; CHECK-NEXT:    vmsr p0, r0
; CHECK-NEXT:    vpsel q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ult i32 %s, %t
  %vc1 = insertelement <4 x i1> undef, i1 %c, i64 0
  %vc4 = shufflevector <4 x i1> %vc1, <4 x i1> undef, <4 x i32> zeroinitializer
  %r = select <4 x i1> %vc4, <4 x i32> %a, <4 x i32> %b
  ret <4 x i32> %r
}


define arm_aapcs_vfpcc <8 x i16> @build_var0_v8i1(i32 %s, i32 %t, <8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: build_var0_v8i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r0, r1
; CHECK-NEXT:    mov.w r1, #0
; CHECK-NEXT:    cset r0, lo
; CHECK-NEXT:    and r0, r0, #1
; CHECK-NEXT:    rsbs r0, r0, #0
; CHECK-NEXT:    bfi r1, r0, #0, #2
; CHECK-NEXT:    vmsr p0, r1
; CHECK-NEXT:    vpsel q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ult i32 %s, %t
  %vc = insertelement <8 x i1> zeroinitializer, i1 %c, i64 0
  %r = select <8 x i1> %vc, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %r
}

define arm_aapcs_vfpcc <8 x i16> @build_var3_v8i1(i32 %s, i32 %t, <8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: build_var3_v8i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r0, r1
; CHECK-NEXT:    mov.w r1, #0
; CHECK-NEXT:    cset r0, lo
; CHECK-NEXT:    and r0, r0, #1
; CHECK-NEXT:    rsbs r0, r0, #0
; CHECK-NEXT:    bfi r1, r0, #6, #2
; CHECK-NEXT:    vmsr p0, r1
; CHECK-NEXT:    vpsel q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ult i32 %s, %t
  %vc = insertelement <8 x i1> zeroinitializer, i1 %c, i64 3
  %r = select <8 x i1> %vc, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %r
}

define arm_aapcs_vfpcc <8 x i16> @build_varN_v8i1(i32 %s, i32 %t, <8 x i16> %a, <8 x i16> %b) {
; CHECK-LABEL: build_varN_v8i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r0, r1
; CHECK-NEXT:    cset r0, lo
; CHECK-NEXT:    and r0, r0, #1
; CHECK-NEXT:    rsbs r0, r0, #0
; CHECK-NEXT:    vmsr p0, r0
; CHECK-NEXT:    vpsel q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ult i32 %s, %t
  %vc1 = insertelement <8 x i1> undef, i1 %c, i64 0
  %vc4 = shufflevector <8 x i1> %vc1, <8 x i1> undef, <8 x i32> zeroinitializer
  %r = select <8 x i1> %vc4, <8 x i16> %a, <8 x i16> %b
  ret <8 x i16> %r
}


define arm_aapcs_vfpcc <16 x i8> @build_var0_v16i1(i32 %s, i32 %t, <16 x i8> %a, <16 x i8> %b) {
; CHECK-LABEL: build_var0_v16i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r0, r1
; CHECK-NEXT:    mov.w r1, #0
; CHECK-NEXT:    cset r0, lo
; CHECK-NEXT:    and r0, r0, #1
; CHECK-NEXT:    rsbs r0, r0, #0
; CHECK-NEXT:    bfi r1, r0, #0, #1
; CHECK-NEXT:    vmsr p0, r1
; CHECK-NEXT:    vpsel q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ult i32 %s, %t
  %vc = insertelement <16 x i1> zeroinitializer, i1 %c, i64 0
  %r = select <16 x i1> %vc, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %r
}

define arm_aapcs_vfpcc <16 x i8> @build_var3_v16i1(i32 %s, i32 %t, <16 x i8> %a, <16 x i8> %b) {
; CHECK-LABEL: build_var3_v16i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r0, r1
; CHECK-NEXT:    mov.w r1, #0
; CHECK-NEXT:    cset r0, lo
; CHECK-NEXT:    and r0, r0, #1
; CHECK-NEXT:    rsbs r0, r0, #0
; CHECK-NEXT:    bfi r1, r0, #3, #1
; CHECK-NEXT:    vmsr p0, r1
; CHECK-NEXT:    vpsel q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ult i32 %s, %t
  %vc = insertelement <16 x i1> zeroinitializer, i1 %c, i64 3
  %r = select <16 x i1> %vc, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %r
}

define arm_aapcs_vfpcc <16 x i8> @build_varN_v16i1(i32 %s, i32 %t, <16 x i8> %a, <16 x i8> %b) {
; CHECK-LABEL: build_varN_v16i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r0, r1
; CHECK-NEXT:    cset r0, lo
; CHECK-NEXT:    and r0, r0, #1
; CHECK-NEXT:    rsbs r0, r0, #0
; CHECK-NEXT:    vmsr p0, r0
; CHECK-NEXT:    vpsel q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ult i32 %s, %t
  %vc1 = insertelement <16 x i1> undef, i1 %c, i64 0
  %vc4 = shufflevector <16 x i1> %vc1, <16 x i1> undef, <16 x i32> zeroinitializer
  %r = select <16 x i1> %vc4, <16 x i8> %a, <16 x i8> %b
  ret <16 x i8> %r
}


define arm_aapcs_vfpcc <2 x i64> @build_var0_v2i1(i32 %s, i32 %t, <2 x i64> %a, <2 x i64> %b) {
; CHECK-LABEL: build_var0_v2i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r0, r1
; CHECK-NEXT:    cset r0, lo
; CHECK-NEXT:    and r0, r0, #1
; CHECK-NEXT:    rsbs r0, r0, #0
; CHECK-NEXT:    vmov s8, r0
; CHECK-NEXT:    vldr s10, .LCPI9_0
; CHECK-NEXT:    vmov.f32 s9, s8
; CHECK-NEXT:    vmov.f32 s11, s10
; CHECK-NEXT:    vbic q1, q1, q2
; CHECK-NEXT:    vand q0, q0, q2
; CHECK-NEXT:    vorr q0, q0, q1
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 2
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI9_0:
; CHECK-NEXT:    .long 0x00000000 @ float 0
entry:
  %c = icmp ult i32 %s, %t
  %vc = insertelement <2 x i1> zeroinitializer, i1 %c, i64 0
  %r = select <2 x i1> %vc, <2 x i64> %a, <2 x i64> %b
  ret <2 x i64> %r
}

define arm_aapcs_vfpcc <2 x i64> @build_var1_v2i1(i32 %s, i32 %t, <2 x i64> %a, <2 x i64> %b) {
; CHECK-LABEL: build_var1_v2i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r0, r1
; CHECK-NEXT:    cset r0, lo
; CHECK-NEXT:    and r0, r0, #1
; CHECK-NEXT:    rsbs r0, r0, #0
; CHECK-NEXT:    vmov s10, r0
; CHECK-NEXT:    vldr s8, .LCPI10_0
; CHECK-NEXT:    vmov.f32 s9, s8
; CHECK-NEXT:    vmov.f32 s11, s10
; CHECK-NEXT:    vbic q1, q1, q2
; CHECK-NEXT:    vand q0, q0, q2
; CHECK-NEXT:    vorr q0, q0, q1
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 2
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI10_0:
; CHECK-NEXT:    .long 0x00000000 @ float 0
entry:
  %c = icmp ult i32 %s, %t
  %vc = insertelement <2 x i1> zeroinitializer, i1 %c, i64 1
  %r = select <2 x i1> %vc, <2 x i64> %a, <2 x i64> %b
  ret <2 x i64> %r
}

define arm_aapcs_vfpcc <2 x i64> @build_varN_v2i1(i32 %s, i32 %t, <2 x i64> %a, <2 x i64> %b) {
; CHECK-LABEL: build_varN_v2i1:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r0, r1
; CHECK-NEXT:    cset r0, lo
; CHECK-NEXT:    and r0, r0, #1
; CHECK-NEXT:    rsbs r0, r0, #0
; CHECK-NEXT:    vdup.32 q2, r0
; CHECK-NEXT:    vbic q1, q1, q2
; CHECK-NEXT:    vand q0, q0, q2
; CHECK-NEXT:    vorr q0, q0, q1
; CHECK-NEXT:    bx lr
entry:
  %c = icmp ult i32 %s, %t
  %vc1 = insertelement <2 x i1> undef, i1 %c, i64 0
  %vc4 = shufflevector <2 x i1> %vc1, <2 x i1> undef, <2 x i32> zeroinitializer
  %r = select <2 x i1> %vc4, <2 x i64> %a, <2 x i64> %b
  ret <2 x i64> %r
}
