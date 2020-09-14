; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -verify -iroutliner -ir-outlining-no-cost < %s | FileCheck %s

; This test checks that invoke instructions are not outlined even if they
; in a similar section.  Outlining does not currently handle control flow
; changes.

declare void @llvm.donothing() nounwind readnone

define void @function1() personality i8 3 {
; CHECK-LABEL: @function1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = alloca i32, align 4
; CHECK-NEXT:    [[B:%.*]] = alloca i32, align 4
; CHECK-NEXT:    call void @outlined_ir_func_0(i32* [[A]], i32* [[B]])
; CHECK-NEXT:    invoke void @llvm.donothing()
; CHECK-NEXT:    to label [[NORMAL:%.*]] unwind label [[EXCEPTION:%.*]]
; CHECK:       exception:
; CHECK-NEXT:    [[CLEANUP:%.*]] = landingpad i8
; CHECK-NEXT:    cleanup
; CHECK-NEXT:    br label [[NORMAL]]
; CHECK:       normal:
; CHECK-NEXT:    ret void
;
entry:
  %a = alloca i32, align 4
  %b = alloca i32, align 4
  store i32 2, i32* %a, align 4
  store i32 3, i32* %b, align 4
  invoke void @llvm.donothing() to label %normal unwind label %exception
exception:
  %cleanup = landingpad i8 cleanup
  br label %normal
normal:
  ret void
}

define void @function2() personality i8 3 {
; CHECK-LABEL: @function2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = alloca i32, align 4
; CHECK-NEXT:    [[B:%.*]] = alloca i32, align 4
; CHECK-NEXT:    call void @outlined_ir_func_0(i32* [[A]], i32* [[B]])
; CHECK-NEXT:    invoke void @llvm.donothing()
; CHECK-NEXT:    to label [[NORMAL:%.*]] unwind label [[EXCEPTION:%.*]]
; CHECK:       exception:
; CHECK-NEXT:    [[CLEANUP:%.*]] = landingpad i8
; CHECK-NEXT:    cleanup
; CHECK-NEXT:    br label [[NORMAL]]
; CHECK:       normal:
; CHECK-NEXT:    ret void
;
entry:
  %a = alloca i32, align 4
  %b = alloca i32, align 4
  store i32 2, i32* %a, align 4
  store i32 3, i32* %b, align 4
  invoke void @llvm.donothing() to label %normal unwind label %exception
exception:
  %cleanup = landingpad i8 cleanup
  br label %normal
normal:
  ret void
}
