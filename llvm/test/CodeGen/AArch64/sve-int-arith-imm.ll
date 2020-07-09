; RUN: llc -mtriple=aarch64-linux-gnu -mattr=+sve < %s 2>%t | FileCheck %s
; RUN: FileCheck --check-prefix=WARN --allow-empty %s <%t

; If this check fails please read test/CodeGen/AArch64/README for instructions on how to resolve it.
; WARN-NOT: warning

;
; SMAX
;
define <vscale x 16 x i8> @smax_i8_pos(<vscale x 16 x i8> %a) {
; CHECK-LABEL: smax_i8_pos
; CHECK: smax z0.b, z0.b, #27
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 16 x i8> undef, i8 27, i32 0
  %splat = shufflevector <vscale x 16 x i8> %elt, <vscale x 16 x i8> undef, <vscale x 16 x i32> zeroinitializer
  %cmp = icmp sgt <vscale x 16 x i8> %a, %splat
  %res = select <vscale x 16 x i1> %cmp, <vscale x 16 x i8> %a, <vscale x 16 x i8> %splat
  ret <vscale x 16 x i8> %res
}

define <vscale x 16 x i8> @smax_i8_neg(<vscale x 16 x i8> %a) {
; CHECK-LABEL: smax_i8_neg
; CHECK: smax z0.b, z0.b, #-58
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 16 x i8> undef, i8 -58, i32 0
  %splat = shufflevector <vscale x 16 x i8> %elt, <vscale x 16 x i8> undef, <vscale x 16 x i32> zeroinitializer
  %cmp = icmp sgt <vscale x 16 x i8> %a, %splat
  %res = select <vscale x 16 x i1> %cmp, <vscale x 16 x i8> %a, <vscale x 16 x i8> %splat
  ret <vscale x 16 x i8> %res
}

define <vscale x 8 x i16> @smax_i16_pos(<vscale x 8 x i16> %a) {
; CHECK-LABEL: smax_i16_pos
; CHECK: smax z0.h, z0.h, #27
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 8 x i16> undef, i16 27, i32 0
  %splat = shufflevector <vscale x 8 x i16> %elt, <vscale x 8 x i16> undef, <vscale x 8 x i32> zeroinitializer
  %cmp = icmp sgt <vscale x 8 x i16> %a, %splat
  %res = select <vscale x 8 x i1> %cmp, <vscale x 8 x i16> %a, <vscale x 8 x i16> %splat
  ret <vscale x 8 x i16> %res
}

define <vscale x 8 x i16> @smax_i16_neg(<vscale x 8 x i16> %a) {
; CHECK-LABEL: smax_i16_neg
; CHECK: smax z0.h, z0.h, #-58
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 8 x i16> undef, i16 -58, i32 0
  %splat = shufflevector <vscale x 8 x i16> %elt, <vscale x 8 x i16> undef, <vscale x 8 x i32> zeroinitializer
  %cmp = icmp sgt <vscale x 8 x i16> %a, %splat
  %res = select <vscale x 8 x i1> %cmp, <vscale x 8 x i16> %a, <vscale x 8 x i16> %splat
  ret <vscale x 8 x i16> %res
}

define <vscale x 4 x i32> @smax_i32_pos(<vscale x 4 x i32> %a) {
; CHECK-LABEL: smax_i32_pos
; CHECK: smax z0.s, z0.s, #27
; CHECK: ret
  %elt = insertelement <vscale x 4 x i32> undef, i32 27, i32 0
  %splat = shufflevector <vscale x 4 x i32> %elt, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %cmp = icmp sgt <vscale x 4 x i32> %a, %splat
  %res = select <vscale x 4 x i1> %cmp, <vscale x 4 x i32> %a, <vscale x 4 x i32> %splat
  ret <vscale x 4 x i32> %res
}

define <vscale x 4 x i32> @smax_i32_neg(<vscale x 4 x i32> %a) {
; CHECK-LABEL: smax_i32_neg
; CHECK: smax z0.s, z0.s, #-58
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 4 x i32> undef, i32 -58, i32 0
  %splat = shufflevector <vscale x 4 x i32> %elt, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %cmp = icmp sgt <vscale x 4 x i32> %a, %splat
  %res = select <vscale x 4 x i1> %cmp, <vscale x 4 x i32> %a, <vscale x 4 x i32> %splat
  ret <vscale x 4 x i32> %res
}

define <vscale x 2 x i64> @smax_i64_pos(<vscale x 2 x i64> %a) {
; CHECK-LABEL: smax_i64_pos
; CHECK: smax z0.d, z0.d, #27
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 2 x i64> undef, i64 27, i32 0
  %splat = shufflevector <vscale x 2 x i64> %elt, <vscale x 2 x i64> undef, <vscale x 2 x i32> zeroinitializer
  %cmp = icmp sgt <vscale x 2 x i64> %a, %splat
  %res = select <vscale x 2 x i1> %cmp, <vscale x 2 x i64> %a, <vscale x 2 x i64> %splat
  ret <vscale x 2 x i64> %res
}

define <vscale x 2 x i64> @smax_i64_neg(<vscale x 2 x i64> %a) {
; CHECK-LABEL: smax_i64_neg
; CHECK: smax z0.d, z0.d, #-58
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 2 x i64> undef, i64 -58, i32 0
  %splat = shufflevector <vscale x 2 x i64> %elt, <vscale x 2 x i64> undef, <vscale x 2 x i32> zeroinitializer
  %cmp = icmp sgt <vscale x 2 x i64> %a, %splat
  %res = select <vscale x 2 x i1> %cmp, <vscale x 2 x i64> %a, <vscale x 2 x i64> %splat
  ret <vscale x 2 x i64> %res
}

;
; SMIN
;
define <vscale x 16 x i8> @smin_i8_pos(<vscale x 16 x i8> %a) {
; CHECK-LABEL: smin_i8_pos
; CHECK: smin z0.b, z0.b, #27
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 16 x i8> undef, i8 27, i32 0
  %splat = shufflevector <vscale x 16 x i8> %elt, <vscale x 16 x i8> undef, <vscale x 16 x i32> zeroinitializer
  %cmp = icmp slt <vscale x 16 x i8> %a, %splat
  %res = select <vscale x 16 x i1> %cmp, <vscale x 16 x i8> %a, <vscale x 16 x i8> %splat
  ret <vscale x 16 x i8> %res
}

define <vscale x 16 x i8> @smin_i8_neg(<vscale x 16 x i8> %a) {
; CHECK-LABEL: smin_i8_neg
; CHECK: smin z0.b, z0.b, #-58
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 16 x i8> undef, i8 -58, i32 0
  %splat = shufflevector <vscale x 16 x i8> %elt, <vscale x 16 x i8> undef, <vscale x 16 x i32> zeroinitializer
  %cmp = icmp slt <vscale x 16 x i8> %a, %splat
  %res = select <vscale x 16 x i1> %cmp, <vscale x 16 x i8> %a, <vscale x 16 x i8> %splat
  ret <vscale x 16 x i8> %res
}

define <vscale x 8 x i16> @smin_i16_pos(<vscale x 8 x i16> %a) {
; CHECK-LABEL: smin_i16_pos
; CHECK: smin z0.h, z0.h, #27
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 8 x i16> undef, i16 27, i32 0
  %splat = shufflevector <vscale x 8 x i16> %elt, <vscale x 8 x i16> undef, <vscale x 8 x i32> zeroinitializer
  %cmp = icmp slt <vscale x 8 x i16> %a, %splat
  %res = select <vscale x 8 x i1> %cmp, <vscale x 8 x i16> %a, <vscale x 8 x i16> %splat
  ret <vscale x 8 x i16> %res
}

define <vscale x 8 x i16> @smin_i16_neg(<vscale x 8 x i16> %a) {
; CHECK-LABEL: smin_i16_neg
; CHECK: smin z0.h, z0.h, #-58
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 8 x i16> undef, i16 -58, i32 0
  %splat = shufflevector <vscale x 8 x i16> %elt, <vscale x 8 x i16> undef, <vscale x 8 x i32> zeroinitializer
  %cmp = icmp slt <vscale x 8 x i16> %a, %splat
  %res = select <vscale x 8 x i1> %cmp, <vscale x 8 x i16> %a, <vscale x 8 x i16> %splat
  ret <vscale x 8 x i16> %res
}

define <vscale x 4 x i32> @smin_i32_pos(<vscale x 4 x i32> %a) {
; CHECK-LABEL: smin_i32_pos
; CHECK: smin z0.s, z0.s, #27
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 4 x i32> undef, i32 27, i32 0
  %splat = shufflevector <vscale x 4 x i32> %elt, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %cmp = icmp slt <vscale x 4 x i32> %a, %splat
  %res = select <vscale x 4 x i1> %cmp, <vscale x 4 x i32> %a, <vscale x 4 x i32> %splat
  ret <vscale x 4 x i32> %res
}

define <vscale x 4 x i32> @smin_i32_neg(<vscale x 4 x i32> %a) {
; CHECK-LABEL: smin_i32_neg
; CHECK: smin z0.s, z0.s, #-58
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 4 x i32> undef, i32 -58, i32 0
  %splat = shufflevector <vscale x 4 x i32> %elt, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %cmp = icmp slt <vscale x 4 x i32> %a, %splat
  %res = select <vscale x 4 x i1> %cmp, <vscale x 4 x i32> %a, <vscale x 4 x i32> %splat
  ret <vscale x 4 x i32> %res
}

define <vscale x 2 x i64> @smin_i64_pos(<vscale x 2 x i64> %a) {
; CHECK-LABEL: smin_i64_pos
; CHECK: smin z0.d, z0.d, #27
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 2 x i64> undef, i64 27, i32 0
  %splat = shufflevector <vscale x 2 x i64> %elt, <vscale x 2 x i64> undef, <vscale x 2 x i32> zeroinitializer
  %cmp = icmp slt <vscale x 2 x i64> %a, %splat
  %res = select <vscale x 2 x i1> %cmp, <vscale x 2 x i64> %a, <vscale x 2 x i64> %splat
  ret <vscale x 2 x i64> %res
}

define <vscale x 2 x i64> @smin_i64_neg(<vscale x 2 x i64> %a) {
; CHECK-LABEL: smin_i64_neg
; CHECK: smin z0.d, z0.d, #-58
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 2 x i64> undef, i64 -58, i32 0
  %splat = shufflevector <vscale x 2 x i64> %elt, <vscale x 2 x i64> undef, <vscale x 2 x i32> zeroinitializer
  %cmp = icmp slt <vscale x 2 x i64> %a, %splat
  %res = select <vscale x 2 x i1> %cmp, <vscale x 2 x i64> %a, <vscale x 2 x i64> %splat
  ret <vscale x 2 x i64> %res
}

;
; UMAX
;
define <vscale x 16 x i8> @umax_i8_pos(<vscale x 16 x i8> %a) {
; CHECK-LABEL: umax_i8_pos
; CHECK: umax z0.b, z0.b, #27
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 16 x i8> undef, i8 27, i32 0
  %splat = shufflevector <vscale x 16 x i8> %elt, <vscale x 16 x i8> undef, <vscale x 16 x i32> zeroinitializer
  %cmp = icmp ugt <vscale x 16 x i8> %a, %splat
  %res = select <vscale x 16 x i1> %cmp, <vscale x 16 x i8> %a, <vscale x 16 x i8> %splat
  ret <vscale x 16 x i8> %res
}

define <vscale x 16 x i8> @umax_i8_large(<vscale x 16 x i8> %a) {
; CHECK-LABEL: umax_i8_large
; CHECK: umax z0.b, z0.b, #129
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 16 x i8> undef, i8 129, i32 0
  %splat = shufflevector <vscale x 16 x i8> %elt, <vscale x 16 x i8> undef, <vscale x 16 x i32> zeroinitializer
  %cmp = icmp ugt <vscale x 16 x i8> %a, %splat
  %res = select <vscale x 16 x i1> %cmp, <vscale x 16 x i8> %a, <vscale x 16 x i8> %splat
  ret <vscale x 16 x i8> %res
}

define <vscale x 8 x i16> @umax_i16_pos(<vscale x 8 x i16> %a) {
; CHECK-LABEL: umax_i16_pos
; CHECK: umax z0.h, z0.h, #27
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 8 x i16> undef, i16 27, i32 0
  %splat = shufflevector <vscale x 8 x i16> %elt, <vscale x 8 x i16> undef, <vscale x 8 x i32> zeroinitializer
  %cmp = icmp ugt <vscale x 8 x i16> %a, %splat
  %res = select <vscale x 8 x i1> %cmp, <vscale x 8 x i16> %a, <vscale x 8 x i16> %splat
  ret <vscale x 8 x i16> %res
}

define <vscale x 8 x i16> @umax_i16_large(<vscale x 8 x i16> %a) {
; CHECK-LABEL: umax_i16_large
; CHECK: umax z0.h, z0.h, #129
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 8 x i16> undef, i16 129, i32 0
  %splat = shufflevector <vscale x 8 x i16> %elt, <vscale x 8 x i16> undef, <vscale x 8 x i32> zeroinitializer
  %cmp = icmp ugt <vscale x 8 x i16> %a, %splat
  %res = select <vscale x 8 x i1> %cmp, <vscale x 8 x i16> %a, <vscale x 8 x i16> %splat
  ret <vscale x 8 x i16> %res
}

define <vscale x 4 x i32> @umax_i32_pos(<vscale x 4 x i32> %a) {
; CHECK-LABEL: umax_i32_pos
; CHECK: umax z0.s, z0.s, #27
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 4 x i32> undef, i32 27, i32 0
  %splat = shufflevector <vscale x 4 x i32> %elt, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %cmp = icmp ugt <vscale x 4 x i32> %a, %splat
  %res = select <vscale x 4 x i1> %cmp, <vscale x 4 x i32> %a, <vscale x 4 x i32> %splat
  ret <vscale x 4 x i32> %res
}

define <vscale x 4 x i32> @umax_i32_large(<vscale x 4 x i32> %a) {
; CHECK-LABEL: umax_i32_large
; CHECK: umax z0.s, z0.s, #129
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 4 x i32> undef, i32 129, i32 0
  %splat = shufflevector <vscale x 4 x i32> %elt, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %cmp = icmp ugt <vscale x 4 x i32> %a, %splat
  %res = select <vscale x 4 x i1> %cmp, <vscale x 4 x i32> %a, <vscale x 4 x i32> %splat
  ret <vscale x 4 x i32> %res
}

define <vscale x 2 x i64> @umax_i64_pos(<vscale x 2 x i64> %a) {
; CHECK-LABEL: umax_i64_pos
; CHECK: umax z0.d, z0.d, #27
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 2 x i64> undef, i64 27, i32 0
  %splat = shufflevector <vscale x 2 x i64> %elt, <vscale x 2 x i64> undef, <vscale x 2 x i32> zeroinitializer
  %cmp = icmp ugt <vscale x 2 x i64> %a, %splat
  %res = select <vscale x 2 x i1> %cmp, <vscale x 2 x i64> %a, <vscale x 2 x i64> %splat
  ret <vscale x 2 x i64> %res
}

define <vscale x 2 x i64> @umax_i64_large(<vscale x 2 x i64> %a) {
; CHECK-LABEL: umax_i64_large
; CHECK: umax z0.d, z0.d, #129
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 2 x i64> undef, i64 129, i32 0
  %splat = shufflevector <vscale x 2 x i64> %elt, <vscale x 2 x i64> undef, <vscale x 2 x i32> zeroinitializer
  %cmp = icmp ugt <vscale x 2 x i64> %a, %splat
  %res = select <vscale x 2 x i1> %cmp, <vscale x 2 x i64> %a, <vscale x 2 x i64> %splat
  ret <vscale x 2 x i64> %res
}

;
; UMIN
;
define <vscale x 16 x i8> @umin_i8_pos(<vscale x 16 x i8> %a) {
; CHECK-LABEL: umin_i8_pos
; CHECK: umin z0.b, z0.b, #27
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 16 x i8> undef, i8 27, i32 0
  %splat = shufflevector <vscale x 16 x i8> %elt, <vscale x 16 x i8> undef, <vscale x 16 x i32> zeroinitializer
  %cmp = icmp ult <vscale x 16 x i8> %a, %splat
  %res = select <vscale x 16 x i1> %cmp, <vscale x 16 x i8> %a, <vscale x 16 x i8> %splat
  ret <vscale x 16 x i8> %res
}

define <vscale x 16 x i8> @umin_i8_large(<vscale x 16 x i8> %a) {
; CHECK-LABEL: umin_i8_large
; CHECK: umin z0.b, z0.b, #129
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 16 x i8> undef, i8 129, i32 0
  %splat = shufflevector <vscale x 16 x i8> %elt, <vscale x 16 x i8> undef, <vscale x 16 x i32> zeroinitializer
  %cmp = icmp ult <vscale x 16 x i8> %a, %splat
  %res = select <vscale x 16 x i1> %cmp, <vscale x 16 x i8> %a, <vscale x 16 x i8> %splat
  ret <vscale x 16 x i8> %res
}

define <vscale x 8 x i16> @umin_i16_pos(<vscale x 8 x i16> %a) {
; CHECK-LABEL: umin_i16_pos
; CHECK: umin z0.h, z0.h, #27
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 8 x i16> undef, i16 27, i32 0
  %splat = shufflevector <vscale x 8 x i16> %elt, <vscale x 8 x i16> undef, <vscale x 8 x i32> zeroinitializer
  %cmp = icmp ult <vscale x 8 x i16> %a, %splat
  %res = select <vscale x 8 x i1> %cmp, <vscale x 8 x i16> %a, <vscale x 8 x i16> %splat
  ret <vscale x 8 x i16> %res
}

define <vscale x 8 x i16> @umin_i16_large(<vscale x 8 x i16> %a) {
; CHECK-LABEL: umin_i16_large
; CHECK: umin z0.h, z0.h, #129
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 8 x i16> undef, i16 129, i32 0
  %splat = shufflevector <vscale x 8 x i16> %elt, <vscale x 8 x i16> undef, <vscale x 8 x i32> zeroinitializer
  %cmp = icmp ult <vscale x 8 x i16> %a, %splat
  %res = select <vscale x 8 x i1> %cmp, <vscale x 8 x i16> %a, <vscale x 8 x i16> %splat
  ret <vscale x 8 x i16> %res
}

define <vscale x 4 x i32> @umin_i32_pos(<vscale x 4 x i32> %a) {
; CHECK-LABEL: umin_i32_pos
; CHECK: umin z0.s, z0.s, #27
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 4 x i32> undef, i32 27, i32 0
  %splat = shufflevector <vscale x 4 x i32> %elt, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %cmp = icmp ult <vscale x 4 x i32> %a, %splat
  %res = select <vscale x 4 x i1> %cmp, <vscale x 4 x i32> %a, <vscale x 4 x i32> %splat
  ret <vscale x 4 x i32> %res
}

define <vscale x 4 x i32> @umin_i32_large(<vscale x 4 x i32> %a) {
; CHECK-LABEL: umin_i32_large
; CHECK: umin z0.s, z0.s, #129
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 4 x i32> undef, i32 129, i32 0
  %splat = shufflevector <vscale x 4 x i32> %elt, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %cmp = icmp ult <vscale x 4 x i32> %a, %splat
  %res = select <vscale x 4 x i1> %cmp, <vscale x 4 x i32> %a, <vscale x 4 x i32> %splat
  ret <vscale x 4 x i32> %res
}

define <vscale x 2 x i64> @umin_i64_pos(<vscale x 2 x i64> %a) {
; CHECK-LABEL: umin_i64_pos
; CHECK: umin z0.d, z0.d, #27
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 2 x i64> undef, i64 27, i32 0
  %splat = shufflevector <vscale x 2 x i64> %elt, <vscale x 2 x i64> undef, <vscale x 2 x i32> zeroinitializer
  %cmp = icmp ult <vscale x 2 x i64> %a, %splat
  %res = select <vscale x 2 x i1> %cmp, <vscale x 2 x i64> %a, <vscale x 2 x i64> %splat
  ret <vscale x 2 x i64> %res
}

define <vscale x 2 x i64> @umin_i64_large(<vscale x 2 x i64> %a) {
; CHECK-LABEL: umin_i64_large
; CHECK: umin z0.d, z0.d, #129
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 2 x i64> undef, i64 129, i32 0
  %splat = shufflevector <vscale x 2 x i64> %elt, <vscale x 2 x i64> undef, <vscale x 2 x i32> zeroinitializer
  %cmp = icmp ult <vscale x 2 x i64> %a, %splat
  %res = select <vscale x 2 x i1> %cmp, <vscale x 2 x i64> %a, <vscale x 2 x i64> %splat
  ret <vscale x 2 x i64> %res
}

;
; MUL
;
define <vscale x 16 x i8> @mul_i8_neg(<vscale x 16 x i8> %a) {
; CHECK-LABEL: mul_i8_neg
; CHECK: mul z0.b, z0.b, #-17
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 16 x i8> undef, i8 -17, i32 0
  %splat = shufflevector <vscale x 16 x i8> %elt, <vscale x 16 x i8> undef, <vscale x 16 x i32> zeroinitializer
  %res = mul <vscale x 16 x i8> %a, %splat
  ret <vscale x 16 x i8> %res
}

define <vscale x 16 x i8> @mul_i8_pos(<vscale x 16 x i8> %a) {
; CHECK-LABEL: mul_i8_pos
; CHECK: mul z0.b, z0.b, #105
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 16 x i8> undef, i8 105, i32 0
  %splat = shufflevector <vscale x 16 x i8> %elt, <vscale x 16 x i8> undef, <vscale x 16 x i32> zeroinitializer
  %res = mul <vscale x 16 x i8> %a, %splat
  ret <vscale x 16 x i8> %res
}

define <vscale x 8 x i16> @mul_i16_neg(<vscale x 8 x i16> %a) {
; CHECK-LABEL: mul_i16_neg
; CHECK: mul z0.h, z0.h, #-17
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 8 x i16> undef, i16 -17, i32 0
  %splat = shufflevector <vscale x 8 x i16> %elt, <vscale x 8 x i16> undef, <vscale x 8 x i32> zeroinitializer
  %res = mul <vscale x 8 x i16> %a, %splat
  ret <vscale x 8 x i16> %res
}

define <vscale x 8 x i16> @mul_i16_pos(<vscale x 8 x i16> %a) {
; CHECK-LABEL: mul_i16_pos
; CHECK: mul z0.h, z0.h, #105
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 8 x i16> undef, i16 105, i32 0
  %splat = shufflevector <vscale x 8 x i16> %elt, <vscale x 8 x i16> undef, <vscale x 8 x i32> zeroinitializer
  %res = mul <vscale x 8 x i16> %a, %splat
  ret <vscale x 8 x i16> %res
}

define <vscale x 4 x i32> @mul_i32_neg(<vscale x 4 x i32> %a) {
; CHECK-LABEL: mul_i32_neg
; CHECK: mul z0.s, z0.s, #-17
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 4 x i32> undef, i32 -17, i32 0
  %splat = shufflevector <vscale x 4 x i32> %elt, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %res = mul <vscale x 4 x i32> %a, %splat
  ret <vscale x 4 x i32> %res
}

define <vscale x 4 x i32> @mul_i32_pos(<vscale x 4 x i32> %a) {
; CHECK-LABEL: mul_i32_pos
; CHECK: mul z0.s, z0.s, #105
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 4 x i32> undef, i32 105, i32 0
  %splat = shufflevector <vscale x 4 x i32> %elt, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %res = mul <vscale x 4 x i32> %a, %splat
  ret <vscale x 4 x i32> %res
}

define <vscale x 2 x i64> @mul_i64_neg(<vscale x 2 x i64> %a) {
; CHECK-LABEL: mul_i64_neg
; CHECK: mul z0.d, z0.d, #-17
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 2 x i64> undef, i64 -17, i32 0
  %splat = shufflevector <vscale x 2 x i64> %elt, <vscale x 2 x i64> undef, <vscale x 2 x i32> zeroinitializer
  %res = mul <vscale x 2 x i64> %a, %splat
  ret <vscale x 2 x i64> %res
}

define <vscale x 2 x i64> @mul_i64_pos(<vscale x 2 x i64> %a) {
; CHECK-LABEL: mul_i64_pos
; CHECK: mul z0.d, z0.d, #105
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 2 x i64> undef, i64 105, i32 0
  %splat = shufflevector <vscale x 2 x i64> %elt, <vscale x 2 x i64> undef, <vscale x 2 x i32> zeroinitializer
  %res = mul <vscale x 2 x i64> %a, %splat
  ret <vscale x 2 x i64> %res
}

define <vscale x 8 x i16> @mul_i16_range(<vscale x 8 x i16> %a) {
; CHECK-LABEL: mul_i16_range
; CHECK: mov w[[W:[0-9]+]], #255
; CHECK-NEXT: mov z1.h, w[[W]]
; CHECK: ptrue p0.h
; CHECK-NEXT: mul z0.h, p0/m, z0.h, z1.h
  %elt = insertelement <vscale x 8 x i16> undef, i16 255, i32 0
  %splat = shufflevector <vscale x 8 x i16> %elt, <vscale x 8 x i16> undef, <vscale x 8 x i32> zeroinitializer
  %res = mul <vscale x 8 x i16> %a, %splat
  ret <vscale x 8 x i16> %res
}

define <vscale x 4 x i32> @mul_i32_range(<vscale x 4 x i32> %a) {
; CHECK-LABEL: mul_i32_range
; CHECK: mov w[[W:[0-9]+]], #255
; CHECK-NEXT: mov z1.s, w[[W]]
; CHECK: ptrue p0.s
; CHECK-NEXT: mul z0.s, p0/m, z0.s, z1.s
  %elt = insertelement <vscale x 4 x i32> undef, i32 255, i32 0
  %splat = shufflevector <vscale x 4 x i32> %elt, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %res = mul <vscale x 4 x i32> %a, %splat
  ret <vscale x 4 x i32> %res
}

define <vscale x 2 x i64> @mul_i64_range(<vscale x 2 x i64> %a) {
; CHECK-LABEL: mul_i64_range
; CHECK: mov w[[W:[0-9]+]], #255
; CHECK-NEXT: mov z1.d, x[[W]]
; CHECK: ptrue p0.d
; CHECK-NEXT: mul z0.d, p0/m, z0.d, z1.d
  %elt = insertelement <vscale x 2 x i64> undef, i64 255, i32 0
  %splat = shufflevector <vscale x 2 x i64> %elt, <vscale x 2 x i64> undef, <vscale x 2 x i32> zeroinitializer
  %res = mul <vscale x 2 x i64> %a, %splat
  ret <vscale x 2 x i64> %res
}

; ASR

define <vscale x 16 x i8> @asr_i8(<vscale x 16 x i8> %a){
; CHECK-LABEL: @asr_i8
; CHECK-DAG: asr z0.b, z0.b, #8
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 16 x i8> undef, i8 8, i32 0
  %splat = shufflevector <vscale x 16 x i8> %elt, <vscale x 16 x i8> undef, <vscale x 16 x i32> zeroinitializer
  %lshr = ashr <vscale x 16 x i8> %a, %splat
  ret <vscale x 16 x i8> %lshr
}

define <vscale x 8 x i16> @asr_i16(<vscale x 8 x i16> %a){
; CHECK-LABEL: @asr_i16
; CHECK-DAG: asr z0.h, z0.h, #16
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 8 x i16> undef, i16 16, i32 0
  %splat = shufflevector <vscale x 8 x i16> %elt, <vscale x 8 x i16> undef, <vscale x 8 x i32> zeroinitializer
  %ashr = ashr <vscale x 8 x i16> %a, %splat
  ret <vscale x 8 x i16> %ashr
}

define <vscale x 4 x i32> @asr_i32(<vscale x 4 x i32> %a){
; CHECK-LABEL: @asr_i32
; CHECK-DAG: asr z0.s, z0.s, #32
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 4 x i32> undef, i32 32, i32 0
  %splat = shufflevector <vscale x 4 x i32> %elt, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %ashr = ashr <vscale x 4 x i32> %a, %splat
  ret <vscale x 4 x i32> %ashr
}

define <vscale x 2 x i64> @asr_i64(<vscale x 2 x i64> %a){
; CHECK-LABEL: @asr_i64
; CHECK-DAG: asr z0.d, z0.d, #64
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 2 x i64> undef, i64 64, i32 0
  %splat = shufflevector <vscale x 2 x i64> %elt, <vscale x 2 x i64> undef, <vscale x 2 x i32> zeroinitializer
  %ashr = ashr <vscale x 2 x i64> %a, %splat
  ret <vscale x 2 x i64> %ashr
}

; LSL

define <vscale x 16 x i8> @lsl_i8(<vscale x 16 x i8> %a){
; CHECK-LABEL: @lsl_i8
; CHECK-DAG: lsl z0.b, z0.b, #7
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 16 x i8> undef, i8 7, i32 0
  %splat = shufflevector <vscale x 16 x i8> %elt, <vscale x 16 x i8> undef, <vscale x 16 x i32> zeroinitializer
  %shl = shl <vscale x 16 x i8> %a, %splat
  ret <vscale x 16 x i8> %shl
}

define <vscale x 8 x i16> @lsl_i16(<vscale x 8 x i16> %a){
; CHECK-LABEL: @lsl_i16
; CHECK-DAG: lsl z0.h, z0.h, #15
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 8 x i16> undef, i16 15, i32 0
  %splat = shufflevector <vscale x 8 x i16> %elt, <vscale x 8 x i16> undef, <vscale x 8 x i32> zeroinitializer
  %shl = shl <vscale x 8 x i16> %a, %splat
  ret <vscale x 8 x i16> %shl
}

define <vscale x 4 x i32> @lsl_i32(<vscale x 4 x i32> %a){
; CHECK-LABEL: @lsl_i32
; CHECK-DAG: lsl z0.s, z0.s, #31
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 4 x i32> undef, i32 31, i32 0
  %splat = shufflevector <vscale x 4 x i32> %elt, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %shl = shl <vscale x 4 x i32> %a, %splat
  ret <vscale x 4 x i32> %shl
}

define <vscale x 2 x i64> @lsl_i64(<vscale x 2 x i64> %a){
; CHECK-LABEL: @lsl_i64
; CHECK-DAG: lsl z0.d, z0.d, #63
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 2 x i64> undef, i64 63, i32 0
  %splat = shufflevector <vscale x 2 x i64> %elt, <vscale x 2 x i64> undef, <vscale x 2 x i32> zeroinitializer
  %shl = shl <vscale x 2 x i64> %a, %splat
  ret <vscale x 2 x i64> %shl
}

; LSR

define <vscale x 16 x i8> @lsr_i8(<vscale x 16 x i8> %a){
; CHECK-LABEL: @lsr_i8
; CHECK-DAG: lsr z0.b, z0.b, #8
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 16 x i8> undef, i8 8, i32 0
  %splat = shufflevector <vscale x 16 x i8> %elt, <vscale x 16 x i8> undef, <vscale x 16 x i32> zeroinitializer
  %lshr = lshr <vscale x 16 x i8> %a, %splat
  ret <vscale x 16 x i8> %lshr
}

define <vscale x 8 x i16> @lsr_i16(<vscale x 8 x i16> %a){
; CHECK-LABEL: @lsr_i16
; CHECK-DAG: lsr z0.h, z0.h, #16
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 8 x i16> undef, i16 16, i32 0
  %splat = shufflevector <vscale x 8 x i16> %elt, <vscale x 8 x i16> undef, <vscale x 8 x i32> zeroinitializer
  %lshr = lshr <vscale x 8 x i16> %a, %splat
  ret <vscale x 8 x i16> %lshr
}

define <vscale x 4 x i32> @lsr_i32(<vscale x 4 x i32> %a){
; CHECK-LABEL: @lsr_i32
; CHECK-DAG: lsr z0.s, z0.s, #32
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 4 x i32> undef, i32 32, i32 0
  %splat = shufflevector <vscale x 4 x i32> %elt, <vscale x 4 x i32> undef, <vscale x 4 x i32> zeroinitializer
  %lshr = lshr <vscale x 4 x i32> %a, %splat
  ret <vscale x 4 x i32> %lshr
}

define <vscale x 2 x i64> @lsr_i64(<vscale x 2 x i64> %a){
; CHECK-LABEL: @lsr_i64
; CHECK-DAG: lsr z0.d, z0.d, #64
; CHECK-NEXT: ret
  %elt = insertelement <vscale x 2 x i64> undef, i64 64, i32 0
  %splat = shufflevector <vscale x 2 x i64> %elt, <vscale x 2 x i64> undef, <vscale x 2 x i32> zeroinitializer
  %lshr = lshr <vscale x 2 x i64> %a, %splat
  ret <vscale x 2 x i64> %lshr
}
