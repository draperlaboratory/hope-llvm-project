; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; XFAIL: *
; RUN: opt < %s -basic-aa -dse -S | FileCheck %s
; RUN: opt < %s -aa-pipeline=basic-aa -passes=dse -S | FileCheck %s
target datalayout = "E-p:64:64:64-a0:0:8-f32:32:32-f64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-v64:64:64-v128:128:128"

; Remove redundant store if loaded value is in another block inside a loop.
define i32 @test31(i1 %c, i32* %p, i32 %i) {
; CHECK-LABEL: @test31(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[BB1:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    br i1 undef, label [[BB1]], label [[BB2:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    ret i32 0
;
entry:
  %v = load i32, i32* %p, align 4
  br label %bb1
bb1:
  store i32 %v, i32* %p, align 4
  br i1 undef, label %bb1, label %bb2
bb2:
  ret i32 0
}
