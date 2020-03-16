; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple armeb-eabi -mattr=armv8.2-a,neon,fullfp16 -target-abi=aapcs-gnu -float-abi hard -o - %s | FileCheck %s

;64 bit conversions to v4f16
define void @conv_i64_to_v4f16( i64 %val, <4 x half>* %store ) {
; CHECK-LABEL: conv_i64_to_v4f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov d16, r1, r0
; CHECK-NEXT:    vldr d17, [r2]
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vrev64.16 d17, d17
; CHECK-NEXT:    vadd.f16 d16, d16, d17
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vstr d16, [r2]
; CHECK-NEXT:    bx lr
entry:
  %v = bitcast i64 %val to <4 x half>
  %w = load <4 x half>, <4 x half>* %store
  %a = fadd <4 x half> %v, %w
  store <4 x half> %a, <4 x half>* %store
  ret void
}

define void @conv_f64_to_v4f16( double %val, <4 x half>* %store ) {
; CHECK-LABEL: conv_f64_to_v4f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldr d16, [r0]
; CHECK-NEXT:    vrev64.16 d17, d0
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vadd.f16 d16, d17, d16
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vstr d16, [r0]
; CHECK-NEXT:    bx lr
entry:
  %v = bitcast double %val to <4 x half>
  %w = load <4 x half>, <4 x half>* %store
  %a = fadd <4 x half> %v, %w
  store <4 x half> %a, <4 x half>* %store
  ret void
}

define void @conv_v2f32_to_v4f16( <2 x float> %a, <4 x half>* %store ) {
; CHECK-LABEL: conv_v2f32_to_v4f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldr d16, .LCPI2_0
; CHECK-NEXT:    vrev64.32 d17, d0
; CHECK-NEXT:    vrev64.32 d16, d16
; CHECK-NEXT:    vadd.f32 d16, d17, d16
; CHECK-NEXT:    vldr d17, [r0]
; CHECK-NEXT:    vrev64.16 d17, d17
; CHECK-NEXT:    vrev32.16 d16, d16
; CHECK-NEXT:    vadd.f16 d16, d16, d17
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vstr d16, [r0]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 3
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI2_0:
; CHECK-NEXT:    .long 0xbf800000 @ float -1
; CHECK-NEXT:    .long 0x3f800000 @ float 1
entry:
  %c = fadd <2 x float> %a, <float -1.0, float 1.0>
  %v = bitcast <2 x float> %c to <4 x half>
  %w = load <4 x half>, <4 x half>* %store
  %z = fadd <4 x half> %v, %w
  store <4 x half> %z, <4 x half>* %store
  ret void
}

define void @conv_v2i32_to_v4f16( <2 x i32> %a, <4 x half>* %store ) {
; CHECK-LABEL: conv_v2i32_to_v4f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldr d16, .LCPI3_0
; CHECK-NEXT:    vrev64.32 d17, d0
; CHECK-NEXT:    vrev64.32 d16, d16
; CHECK-NEXT:    vadd.i32 d16, d17, d16
; CHECK-NEXT:    vldr d18, [r0]
; CHECK-NEXT:    vrev64.16 d17, d18
; CHECK-NEXT:    vrev32.16 d16, d16
; CHECK-NEXT:    vadd.f16 d16, d16, d17
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vstr d16, [r0]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 3
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI3_0:
; CHECK-NEXT:    .long 1 @ 0x1
; CHECK-NEXT:    .long 4294967295 @ 0xffffffff
entry:
  %c = add <2 x i32> %a, <i32 1, i32 -1>
  %v = bitcast <2 x i32> %c to <4 x half>
  %w = load <4 x half>, <4 x half>* %store
  %z = fadd <4 x half> %v, %w
  store <4 x half> %z, <4 x half>* %store
  ret void
}

define void @conv_v4i16_to_v4f16( <4 x i16> %a, <4 x half>* %store ) {
; CHECK-LABEL: conv_v4i16_to_v4f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov.i64 d16, #0xffff00000000ffff
; CHECK-NEXT:    vldr d17, [r0]
; CHECK-NEXT:    vrev64.16 d18, d0
; CHECK-NEXT:    vrev64.16 d17, d17
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vadd.i16 d16, d18, d16
; CHECK-NEXT:    vadd.f16 d16, d16, d17
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vstr d16, [r0]
; CHECK-NEXT:    bx lr
entry:
  %c = add <4 x i16> %a, <i16 -1, i16 0, i16 0, i16 -1>
  %v = bitcast <4 x i16> %c to <4 x half>
  %w = load <4 x half>, <4 x half>* %store
  %z = fadd <4 x half> %v, %w
  store <4 x half> %z, <4 x half>* %store
  ret void
}

define void @conv_v8i8_to_v4f16( <8 x i8> %a, <4 x half>* %store ) {
; CHECK-LABEL: conv_v8i8_to_v4f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov.i8 d16, #0x1
; CHECK-NEXT:    vrev64.8 d17, d0
; CHECK-NEXT:    vldr d18, [r0]
; CHECK-NEXT:    vadd.i8 d16, d17, d16
; CHECK-NEXT:    vrev64.16 d17, d18
; CHECK-NEXT:    vrev16.8 d16, d16
; CHECK-NEXT:    vadd.f16 d16, d16, d17
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vstr d16, [r0]
; CHECK-NEXT:    bx lr
entry:
  %c = add <8 x i8> %a, <i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1>
  %v = bitcast <8 x i8> %c to <4 x half>
  %w = load <4 x half>, <4 x half>* %store
  %z = fadd <4 x half> %v, %w
  store <4 x half> %z, <4 x half>* %store
  ret void
}

define void @conv_v2i64_to_v8f16( <2 x i64> %val, <8 x half>* %store ) {
; CHECK-LABEL: conv_v2i64_to_v8f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vld1.64 {d16, d17}, [r0]
; CHECK-NEXT:    adr r1, .LCPI6_0
; CHECK-NEXT:    vld1.64 {d18, d19}, [r1:128]
; CHECK-NEXT:    vadd.i64 q9, q0, q9
; CHECK-NEXT:    vrev64.16 q8, q8
; CHECK-NEXT:    vrev64.16 q9, q9
; CHECK-NEXT:    vadd.f16 q8, q9, q8
; CHECK-NEXT:    vrev64.16 q8, q8
; CHECK-NEXT:    vst1.64 {d16, d17}, [r0]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI6_0:
; CHECK-NEXT:    .long 0 @ 0x0
; CHECK-NEXT:    .long 1 @ 0x1
; CHECK-NEXT:    .long 4294967295 @ 0xffffffff
; CHECK-NEXT:    .long 4294967295 @ 0xffffffff
entry:
  %v = add <2 x i64> %val, <i64 1, i64 -1>
  %v1 = bitcast <2 x i64> %v to <8 x half>
  %w = load <8 x half>, <8 x half>* %store
  %a = fadd <8 x half> %v1, %w
  store <8 x half> %a, <8 x half>* %store
  ret void
}
define void @conv_v2f64_to_v8f16( <2 x double> %val, <8 x half>* %store ) {
; CHECK-LABEL: conv_v2f64_to_v8f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vmov.f64 d16, #-1.000000e+00
; CHECK-NEXT:    vmov.f64 d17, #1.000000e+00
; CHECK-NEXT:    vadd.f64 d19, d1, d16
; CHECK-NEXT:    vadd.f64 d18, d0, d17
; CHECK-NEXT:    vld1.64 {d16, d17}, [r0]
; CHECK-NEXT:    vrev64.16 q8, q8
; CHECK-NEXT:    vrev64.16 q9, q9
; CHECK-NEXT:    vadd.f16 q8, q9, q8
; CHECK-NEXT:    vrev64.16 q8, q8
; CHECK-NEXT:    vst1.64 {d16, d17}, [r0]
; CHECK-NEXT:    bx lr
entry:
  %v = fadd <2 x double> %val, <double 1.0, double -1.0>
  %v1 = bitcast <2 x double> %v to <8 x half>
  %w = load <8 x half>, <8 x half>* %store
  %a = fadd <8 x half> %v1, %w
  store <8 x half> %a, <8 x half>* %store
  ret void
}

define void @conv_v4f32_to_v8f16( <4 x float> %a, <8 x half>* %store ) {
; CHECK-LABEL: conv_v4f32_to_v8f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    adr r1, .LCPI8_0
; CHECK-NEXT:    vrev64.32 q9, q0
; CHECK-NEXT:    vld1.64 {d16, d17}, [r1:128]
; CHECK-NEXT:    vrev64.32 q8, q8
; CHECK-NEXT:    vadd.f32 q8, q9, q8
; CHECK-NEXT:    vld1.64 {d18, d19}, [r0]
; CHECK-NEXT:    vrev64.16 q9, q9
; CHECK-NEXT:    vrev32.16 q8, q8
; CHECK-NEXT:    vadd.f16 q8, q8, q9
; CHECK-NEXT:    vrev64.16 q8, q8
; CHECK-NEXT:    vst1.64 {d16, d17}, [r0]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI8_0:
; CHECK-NEXT:    .long 0xbf800000 @ float -1
; CHECK-NEXT:    .long 0x3f800000 @ float 1
; CHECK-NEXT:    .long 0xbf800000 @ float -1
; CHECK-NEXT:    .long 0x3f800000 @ float 1
entry:
  %c = fadd <4 x float> %a, <float -1.0, float 1.0, float -1.0, float 1.0>
  %v = bitcast <4 x float> %c to <8 x half>
  %w = load <8 x half>, <8 x half>* %store
  %z = fadd <8 x half> %v, %w
  store <8 x half> %z, <8 x half>* %store
  ret void
}

define void @conv_v4i32_to_v8f16( <4 x i32> %a, <8 x half>* %store ) {
; CHECK-LABEL: conv_v4i32_to_v8f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    adr r1, .LCPI9_0
; CHECK-NEXT:    vrev64.32 q9, q0
; CHECK-NEXT:    vld1.64 {d16, d17}, [r1:128]
; CHECK-NEXT:    vrev64.32 q8, q8
; CHECK-NEXT:    vadd.i32 q8, q9, q8
; CHECK-NEXT:    vld1.64 {d20, d21}, [r0]
; CHECK-NEXT:    vrev64.16 q9, q10
; CHECK-NEXT:    vrev32.16 q8, q8
; CHECK-NEXT:    vadd.f16 q8, q8, q9
; CHECK-NEXT:    vrev64.16 q8, q8
; CHECK-NEXT:    vst1.64 {d16, d17}, [r0]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI9_0:
; CHECK-NEXT:    .long 4294967295 @ 0xffffffff
; CHECK-NEXT:    .long 1 @ 0x1
; CHECK-NEXT:    .long 4294967295 @ 0xffffffff
; CHECK-NEXT:    .long 1 @ 0x1
entry:
  %c = add <4 x i32> %a, <i32 -1, i32 1, i32 -1, i32 1>
  %v = bitcast <4 x i32> %c to <8 x half>
  %w = load <8 x half>, <8 x half>* %store
  %z = fadd <8 x half> %v, %w
  store <8 x half> %z, <8 x half>* %store
  ret void
}

define void @conv_v8i16_to_v8f16( <8 x i16> %a, <8 x half>* %store ) {
; CHECK-LABEL: conv_v8i16_to_v8f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    adr r1, .LCPI10_0
; CHECK-NEXT:    vld1.64 {d18, d19}, [r0]
; CHECK-NEXT:    vld1.64 {d16, d17}, [r1:128]
; CHECK-NEXT:    vrev64.16 q10, q0
; CHECK-NEXT:    vrev64.16 q8, q8
; CHECK-NEXT:    vrev64.16 q9, q9
; CHECK-NEXT:    vadd.i16 q8, q10, q8
; CHECK-NEXT:    vadd.f16 q8, q8, q9
; CHECK-NEXT:    vrev64.16 q8, q8
; CHECK-NEXT:    vst1.64 {d16, d17}, [r0]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI10_0:
; CHECK-NEXT:    .short 65535 @ 0xffff
; CHECK-NEXT:    .short 1 @ 0x1
; CHECK-NEXT:    .short 0 @ 0x0
; CHECK-NEXT:    .short 7 @ 0x7
; CHECK-NEXT:    .short 65535 @ 0xffff
; CHECK-NEXT:    .short 1 @ 0x1
; CHECK-NEXT:    .short 0 @ 0x0
; CHECK-NEXT:    .short 7 @ 0x7
entry:
  %c = add <8 x i16> %a, <i16 -1, i16 1, i16 0, i16 7, i16 -1, i16 1, i16 0, i16 7>
  %v = bitcast <8 x i16> %c to <8 x half>
  %w = load <8 x half>, <8 x half>* %store
  %z = fadd <8 x half> %v, %w
  store <8 x half> %z, <8 x half>* %store
  ret void
}

define void @conv_v16i8_to_v8f16( <16 x i8> %a, <8 x half>* %store ) {
; CHECK-LABEL: conv_v16i8_to_v8f16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vrev64.8 q8, q0
; CHECK-NEXT:    vmov.i8 q9, #0x1
; CHECK-NEXT:    vadd.i8 q8, q8, q9
; CHECK-NEXT:    vld1.64 {d20, d21}, [r0]
; CHECK-NEXT:    vrev64.16 q9, q10
; CHECK-NEXT:    vrev16.8 q8, q8
; CHECK-NEXT:    vadd.f16 q8, q8, q9
; CHECK-NEXT:    vrev64.16 q8, q8
; CHECK-NEXT:    vst1.64 {d16, d17}, [r0]
; CHECK-NEXT:    bx lr
entry:
  %c = add <16 x i8> %a, <i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1>
  %v = bitcast <16 x i8> %c to <8 x half>
  %w = load <8 x half>, <8 x half>* %store
  %z = fadd <8 x half> %v, %w
  store <8 x half> %z, <8 x half>* %store
  ret void
}

define void @conv_v4f16_to_i64( <4 x half> %a, i64* %store ) {
; CHECK-LABEL: conv_v4f16_to_i64:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldr d16, .LCPI12_0
; CHECK-NEXT:    vrev64.16 d17, d0
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vadd.f16 d16, d17, d16
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vmov r1, r2, d16
; CHECK-NEXT:    subs r1, r1, #1
; CHECK-NEXT:    sbc r2, r2, #0
; CHECK-NEXT:    str r2, [r0]
; CHECK-NEXT:    str r1, [r0, #4]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 3
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI12_0:
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
entry:
  %z = fadd <4 x half> %a, <half -1.0, half 1.0, half -1.0, half 1.0>
  %y = bitcast <4 x half> %z to i64
  %w = add i64 %y, -1
  store i64 %w, i64* %store
  ret void
}

define void @conv_v4f16_to_f64( <4 x half> %a, double* %store ) {
; CHECK-LABEL: conv_v4f16_to_f64:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldr d16, .LCPI13_0
; CHECK-NEXT:    vrev64.16 d17, d0
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vadd.f16 d16, d17, d16
; CHECK-NEXT:    vmov.f64 d17, #-1.000000e+00
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vadd.f64 d16, d16, d17
; CHECK-NEXT:    vstr d16, [r0]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 3
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI13_0:
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
entry:
  %z = fadd <4 x half> %a, <half -1.0, half 1.0, half -1.0, half 1.0>
  %y = bitcast <4 x half> %z to double
  %w = fadd double %y, -1.0
  store double %w, double* %store
  ret void
}

define void @conv_v4f16_to_v2i32( <4 x half> %a, <2 x i32>* %store ) {
; CHECK-LABEL: conv_v4f16_to_v2i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldr d16, .LCPI14_0
; CHECK-NEXT:    vrev64.16 d17, d0
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vadd.f16 d16, d17, d16
; CHECK-NEXT:    vldr d17, .LCPI14_1
; CHECK-NEXT:    vrev64.32 d17, d17
; CHECK-NEXT:    vrev32.16 d16, d16
; CHECK-NEXT:    vadd.i32 d16, d16, d17
; CHECK-NEXT:    vrev64.32 d16, d16
; CHECK-NEXT:    vstr d16, [r0]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 3
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI14_0:
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:  .LCPI14_1:
; CHECK-NEXT:    .long 4294967295 @ 0xffffffff
; CHECK-NEXT:    .long 1 @ 0x1
entry:
  %z = fadd <4 x half> %a, <half -1.0, half 1.0, half -1.0, half 1.0>
  %y = bitcast <4 x half> %z to <2 x i32>
  %w = add <2 x i32> %y, <i32 -1, i32 1>
  store <2 x i32> %w, <2 x i32>* %store
  ret void
}

define void @conv_v4f16_to_v2f32( <4 x half> %a, <2 x float>* %store ) {
; CHECK-LABEL: conv_v4f16_to_v2f32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldr d16, .LCPI15_0
; CHECK-NEXT:    vrev64.16 d17, d0
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vadd.f16 d16, d17, d16
; CHECK-NEXT:    vldr d17, .LCPI15_1
; CHECK-NEXT:    vrev64.32 d17, d17
; CHECK-NEXT:    vrev32.16 d16, d16
; CHECK-NEXT:    vadd.f32 d16, d16, d17
; CHECK-NEXT:    vrev64.32 d16, d16
; CHECK-NEXT:    vstr d16, [r0]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 3
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI15_0:
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:  .LCPI15_1:
; CHECK-NEXT:    .long 0xbf800000 @ float -1
; CHECK-NEXT:    .long 0x3f800000 @ float 1
entry:
  %z = fadd <4 x half> %a, <half -1.0, half 1.0, half -1.0, half 1.0>
  %y = bitcast <4 x half> %z to <2 x float>
  %w = fadd <2 x float> %y, <float -1.0, float 1.0>
  store <2 x float> %w, <2 x float>* %store
  ret void
}

define void @conv_v4f16_to_v4i16( <4 x half> %a, <4 x i16>* %store ) {
; CHECK-LABEL: conv_v4f16_to_v4i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldr d16, .LCPI16_0
; CHECK-NEXT:    vrev64.16 d17, d0
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vadd.f16 d16, d17, d16
; CHECK-NEXT:    vldr d17, .LCPI16_1
; CHECK-NEXT:    vrev64.16 d17, d17
; CHECK-NEXT:    vadd.i16 d16, d16, d17
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vstr d16, [r0]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 3
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI16_0:
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:  .LCPI16_1:
; CHECK-NEXT:    .short 65535 @ 0xffff
; CHECK-NEXT:    .short 1 @ 0x1
; CHECK-NEXT:    .short 0 @ 0x0
; CHECK-NEXT:    .short 7 @ 0x7
entry:
  %z = fadd <4 x half> %a, <half -1.0, half 1.0, half -1.0, half 1.0>
  %y = bitcast <4 x half> %z to <4 x i16>
  %w = add <4 x i16> %y, <i16 -1, i16 1, i16 0, i16 7>
  store <4 x i16> %w, <4 x i16>* %store
  ret void
}

define void @conv_v4f16_to_v8f8( <4 x half> %a, <8 x i8>* %store ) {
; CHECK-LABEL: conv_v4f16_to_v8f8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldr d16, .LCPI17_0
; CHECK-NEXT:    vrev64.16 d17, d0
; CHECK-NEXT:    vrev64.16 d16, d16
; CHECK-NEXT:    vadd.f16 d16, d17, d16
; CHECK-NEXT:    vmov.i8 d17, #0x1
; CHECK-NEXT:    vrev16.8 d16, d16
; CHECK-NEXT:    vadd.i8 d16, d16, d17
; CHECK-NEXT:    vrev64.8 d16, d16
; CHECK-NEXT:    vstr d16, [r0]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 3
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI17_0:
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
entry:
  %z = fadd <4 x half> %a, <half -1.0, half 1.0, half -1.0, half 1.0>
  %y = bitcast <4 x half> %z to <8 x i8>
  %w = add <8 x i8> %y, <i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1>
  store <8 x i8> %w, <8 x i8>* %store
  ret void
}

define void @conv_v8f16_to_i128( <8 x half> %a, i128* %store ) {
; CHECK-LABEL: conv_v8f16_to_i128:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    adr r1, .LCPI18_0
; CHECK-NEXT:    vrev64.16 q9, q0
; CHECK-NEXT:    vld1.64 {d16, d17}, [r1:128]
; CHECK-NEXT:    vrev64.16 q8, q8
; CHECK-NEXT:    vadd.f16 q8, q9, q8
; CHECK-NEXT:    vrev32.16 q8, q8
; CHECK-NEXT:    vmov.32 r12, d17[1]
; CHECK-NEXT:    vmov.32 r2, d17[0]
; CHECK-NEXT:    vmov.32 r3, d16[1]
; CHECK-NEXT:    vmov.32 r1, d16[0]
; CHECK-NEXT:    subs r12, r12, #1
; CHECK-NEXT:    sbcs r2, r2, #0
; CHECK-NEXT:    sbcs r3, r3, #0
; CHECK-NEXT:    sbc r1, r1, #0
; CHECK-NEXT:    stm r0, {r1, r3}
; CHECK-NEXT:    str r2, [r0, #8]
; CHECK-NEXT:    str r12, [r0, #12]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI18_0:
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
entry:
  %z = fadd <8 x half> %a, <half -1.0, half 1.0, half -1.0, half 1.0, half -1.0, half 1.0, half -1.0, half 1.0>
  %y = bitcast <8 x half> %z to i128
  %w = add i128 %y, -1
  store i128 %w, i128* %store
  ret void
}

define void @conv_v8f16_to_v2f64( <8 x half> %a, <2 x double>* %store ) {
; CHECK-LABEL: conv_v8f16_to_v2f64:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    adr r1, .LCPI19_0
; CHECK-NEXT:    vrev64.16 q9, q0
; CHECK-NEXT:    vld1.64 {d16, d17}, [r1:128]
; CHECK-NEXT:    vrev64.16 q8, q8
; CHECK-NEXT:    vadd.f16 q8, q9, q8
; CHECK-NEXT:    vmov.f64 d18, #1.000000e+00
; CHECK-NEXT:    vrev64.16 q8, q8
; CHECK-NEXT:    vmov.f64 d19, #-1.000000e+00
; CHECK-NEXT:    vadd.f64 d21, d17, d18
; CHECK-NEXT:    vadd.f64 d20, d16, d19
; CHECK-NEXT:    vst1.64 {d20, d21}, [r0]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI19_0:
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
entry:
  %z = fadd <8 x half> %a, <half -1.0, half 1.0, half -1.0, half 1.0, half -1.0, half 1.0, half -1.0, half 1.0>
  %y = bitcast <8 x half> %z to <2 x double>
  %w = fadd <2 x double> %y, <double -1.0, double 1.0>
  store <2 x double> %w, <2 x double>* %store
  ret void
}

define void @conv_v8f16_to_v4i32( <8 x half> %a, <4 x i32>* %store ) {
; CHECK-LABEL: conv_v8f16_to_v4i32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    adr r1, .LCPI20_0
; CHECK-NEXT:    vrev64.16 q9, q0
; CHECK-NEXT:    vld1.64 {d16, d17}, [r1:128]
; CHECK-NEXT:    adr r1, .LCPI20_1
; CHECK-NEXT:    vrev64.16 q8, q8
; CHECK-NEXT:    vadd.f16 q8, q9, q8
; CHECK-NEXT:    vld1.64 {d18, d19}, [r1:128]
; CHECK-NEXT:    vrev64.32 q9, q9
; CHECK-NEXT:    vrev32.16 q8, q8
; CHECK-NEXT:    vadd.i32 q8, q8, q9
; CHECK-NEXT:    vrev64.32 q8, q8
; CHECK-NEXT:    vst1.64 {d16, d17}, [r0]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI20_0:
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:  .LCPI20_1:
; CHECK-NEXT:    .long 4294967295 @ 0xffffffff
; CHECK-NEXT:    .long 1 @ 0x1
; CHECK-NEXT:    .long 4294967295 @ 0xffffffff
; CHECK-NEXT:    .long 1 @ 0x1
entry:
  %z = fadd <8 x half> %a, <half -1.0, half 1.0, half -1.0, half 1.0, half -1.0, half 1.0, half -1.0, half 1.0>
  %y = bitcast <8 x half> %z to <4 x i32>
  %w = add <4 x i32> %y, <i32 -1, i32 1, i32 -1, i32 1>
  store <4 x i32> %w, <4 x i32>* %store
  ret void
}

define void @conv_v8f16_to_v4f32( <8 x half> %a, <4 x float>* %store ) {
; CHECK-LABEL: conv_v8f16_to_v4f32:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    adr r1, .LCPI21_0
; CHECK-NEXT:    vrev64.16 q9, q0
; CHECK-NEXT:    vld1.64 {d16, d17}, [r1:128]
; CHECK-NEXT:    adr r1, .LCPI21_1
; CHECK-NEXT:    vrev64.16 q8, q8
; CHECK-NEXT:    vadd.f16 q8, q9, q8
; CHECK-NEXT:    vld1.64 {d18, d19}, [r1:128]
; CHECK-NEXT:    vrev64.32 q9, q9
; CHECK-NEXT:    vrev32.16 q8, q8
; CHECK-NEXT:    vadd.f32 q8, q8, q9
; CHECK-NEXT:    vrev64.32 q8, q8
; CHECK-NEXT:    vst1.64 {d16, d17}, [r0]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI21_0:
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:  .LCPI21_1:
; CHECK-NEXT:    .long 0xbf800000 @ float -1
; CHECK-NEXT:    .long 0x3f800000 @ float 1
; CHECK-NEXT:    .long 0xbf800000 @ float -1
; CHECK-NEXT:    .long 0x3f800000 @ float 1
entry:
  %z = fadd <8 x half> %a, <half -1.0, half 1.0, half -1.0, half 1.0, half -1.0, half 1.0, half -1.0, half 1.0>
  %y = bitcast <8 x half> %z to <4 x float>
  %w = fadd <4 x float> %y, <float -1.0, float 1.0, float -1.0, float 1.0>
  store <4 x float> %w, <4 x float>* %store
  ret void
}

define void @conv_v8f16_to_v8i16( <8 x half> %a, <8 x i16>* %store ) {
; CHECK-LABEL: conv_v8f16_to_v8i16:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    adr r1, .LCPI22_0
; CHECK-NEXT:    vrev64.16 q9, q0
; CHECK-NEXT:    vld1.64 {d16, d17}, [r1:128]
; CHECK-NEXT:    adr r1, .LCPI22_1
; CHECK-NEXT:    vrev64.16 q8, q8
; CHECK-NEXT:    vadd.f16 q8, q9, q8
; CHECK-NEXT:    vld1.64 {d18, d19}, [r1:128]
; CHECK-NEXT:    vrev64.16 q9, q9
; CHECK-NEXT:    vadd.i16 q8, q8, q9
; CHECK-NEXT:    vrev64.16 q8, q8
; CHECK-NEXT:    vst1.64 {d16, d17}, [r0]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI22_0:
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:  .LCPI22_1:
; CHECK-NEXT:    .short 65535 @ 0xffff
; CHECK-NEXT:    .short 1 @ 0x1
; CHECK-NEXT:    .short 0 @ 0x0
; CHECK-NEXT:    .short 7 @ 0x7
; CHECK-NEXT:    .short 65535 @ 0xffff
; CHECK-NEXT:    .short 1 @ 0x1
; CHECK-NEXT:    .short 0 @ 0x0
; CHECK-NEXT:    .short 7 @ 0x7
entry:
  %z = fadd <8 x half> %a, <half -1.0, half 1.0, half -1.0, half 1.0, half -1.0, half 1.0, half -1.0, half 1.0>
  %y = bitcast <8 x half> %z to <8 x i16>
  %w = add <8 x i16> %y, <i16 -1, i16 1, i16 0, i16 7, i16 -1, i16 1, i16 0, i16 7>
  store <8 x i16> %w, <8 x i16>* %store
  ret void
}

define void @conv_v8f16_to_v8f8( <8 x half> %a, <16 x i8>* %store ) {
; CHECK-LABEL: conv_v8f16_to_v8f8:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    adr r1, .LCPI23_0
; CHECK-NEXT:    vrev64.16 q9, q0
; CHECK-NEXT:    vld1.64 {d16, d17}, [r1:128]
; CHECK-NEXT:    vrev64.16 q8, q8
; CHECK-NEXT:    vadd.f16 q8, q9, q8
; CHECK-NEXT:    vmov.i8 q9, #0x1
; CHECK-NEXT:    vrev16.8 q8, q8
; CHECK-NEXT:    vadd.i8 q8, q8, q9
; CHECK-NEXT:    vrev64.8 q8, q8
; CHECK-NEXT:    vst1.64 {d16, d17}, [r0]
; CHECK-NEXT:    bx lr
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  @ %bb.1:
; CHECK-NEXT:  .LCPI23_0:
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
; CHECK-NEXT:    .short 0xbc00 @ half -1
; CHECK-NEXT:    .short 0x3c00 @ half 1
entry:
  %z = fadd <8 x half> %a, <half -1.0, half 1.0, half -1.0, half 1.0, half -1.0, half 1.0, half -1.0, half 1.0>
  %y = bitcast <8 x half> %z to <16 x i8>
  %w = add <16 x i8> %y, <i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1>
  store <16 x i8> %w, <16 x i8>* %store
  ret void
}
