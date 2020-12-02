; RUN: split-file %s %t
; RUN: opt -module-summary %t/a.ll -o %a.bc
; RUN: opt -module-summary %t/b.ll -o %b.bc
; RUN: llvm-lto2 run %a.bc %b.bc -o %c.bc -save-temps \
; RUN:   -r=%a.bc,nossp_caller,px \
; RUN:   -r=%a.bc,ssp_caller,px \
; RUN:   -r=%a.bc,nossp_caller2,px \
; RUN:   -r=%a.bc,ssp_caller2,px \
; RUN:   -r=%a.bc,nossp_callee,x \
; RUN:   -r=%a.bc,ssp_callee,x \
; RUN:   -r=%b.bc,nossp_callee,px \
; RUN:   -r=%b.bc,ssp_callee,px \
; RUN:   -r=%b.bc,foo
; RUN: llvm-dis %c.bc.1.4.opt.bc -o - | FileCheck %s

;--- a.ll

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

declare void @nossp_callee()
declare void @ssp_callee() ssp

; nossp caller should be able to inline nossp callee.
define void @nossp_caller() {
; CHECK-LABEL: @nossp_caller
; CHECK-NEXT: tail call void @foo
  tail call void @nossp_callee()
  ret void
}

; ssp caller should be able to inline ssp callee.
define void @ssp_caller() ssp {
; CHECK-LABEL: @ssp_caller
; CHECK-NEXT: tail call void @foo
  tail call void @ssp_callee()
  ret void
}

; nossp caller should *NOT* be able to inline ssp callee.
define void @nossp_caller2() {
; CHECK-LABEL: @nossp_caller2
; CHECK-NEXT: tail call void @ssp_callee
  tail call void @ssp_callee()
  ret void
}

; ssp caller should *NOT* be able to inline nossp callee.
define void @ssp_caller2() ssp {
; CHECK-LABEL: @ssp_caller2
; CHECK-NEXT: tail call void @nossp_callee
  tail call void @nossp_callee()
  ret void
}

;--- b.ll
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

declare void @foo()

define void @nossp_callee() {
  call void @foo()
  ret void
}

define void @ssp_callee() ssp {
  call void @foo()
  ret void
}
