; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- -mcpu=corei7 | FileCheck %s

define void @autogen_SD31033(i16* %a0) {
; CHECK-LABEL: autogen_SD31033:
; CHECK:       # %bb.0: # %BB
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  .LBB0_1: # %CF
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    jmp .LBB0_1
BB:
  %L5 = load i16, i16* %a0
  %I8 = insertelement <4 x i16> zeroinitializer, i16 %L5, i32 1
  %Tr = trunc <4 x i16> %I8 to <4 x i1>
  %Shuff28 = shufflevector <4 x i1> zeroinitializer, <4 x i1> %Tr, <4 x i32> <i32 undef, i32 3, i32 5, i32 undef>
  br label %CF

CF:                                               ; preds = %CF, %BB
  %E42 = extractelement <4 x i1> %Shuff28, i32 3
  br label %CF
}
