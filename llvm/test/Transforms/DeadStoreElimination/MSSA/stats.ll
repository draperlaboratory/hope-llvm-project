; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -basic-aa -dse -stats -S 2>&1 | FileCheck %s

; REQUIRES: asserts

target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"


define void @test2(i32* noalias %P, i32* noalias %C, i1 %c) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    br i1 [[C:%.*]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    store i32 3, i32* [[C:%.*]]
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    store i32 4, i32* [[C]]
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    store i32 0, i32* [[P:%.*]]
; CHECK-NEXT:    ret void
;
  store i32 1, i32* %P
  br i1 %c, label %bb1, label %bb2
bb1:
  store i32 3, i32* %C
  br label %bb3
bb2:
  store i32 4, i32* %C
  br label %bb3
bb3:
  store i32 0, i32* %P
  ret void
}

; CHECK: 1 dse - Number of stores deleted
; CHECK: 3 dse - Number of stores remaining after DSE
