; NOTE: Assertions have been autogenerated by update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

target datalayout = "e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:128:128"
target triple = "i386-apple-darwin9"

define <4 x float> @__inff4() nounwind readnone {
; CHECK-LABEL: @__inff4(
; CHECK-NEXT:    ret <4 x float> <float 0.000000e+00, float 0.000000e+00, float 0x7FF0000000000000, float 0x7FF0000000000000>
;
  %tmp14 = extractelement <1 x double> bitcast (<2 x float> <float 0x7FF0000000000000, float 0x7FF0000000000000> to <1 x double>), i32 0
  %tmp4 = bitcast double %tmp14 to i64
  %tmp3 = bitcast i64 %tmp4 to <2 x float>
  %tmp8 = shufflevector <2 x float> %tmp3, <2 x float> poison, <4 x i32> <i32 0, i32 1, i32 undef, i32 undef>
  %tmp9 = shufflevector <4 x float> zeroinitializer, <4 x float> %tmp8, <4 x i32> <i32 0, i32 1, i32 4, i32 5>
  ret <4 x float> %tmp9
}
