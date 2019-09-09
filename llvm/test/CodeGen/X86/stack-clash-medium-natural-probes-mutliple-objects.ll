; RUN: llc < %s | FileCheck %s


target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define i32 @foo() local_unnamed_addr #0 {

; CHECK-LABEL: foo:
; CHECK:         # %bb.0:
; CHECK-NEXT	subq	$4096, %rsp # imm = 0x1000
; CHECK-NEXT	.cfi_def_cfa_offset 5888
; CHECK-NEXT	movl	$1, 2088(%rsp)
; CHECK-NEXT	subq	$1784, %rsp # imm = 0x6F8
; CHECK-NEXT	movl	$2, 672(%rsp)
; CHECK-NEXT	movl	1872(%rsp), %eax
; CHECK-NEXT	addq	$5880, %rsp # imm = 0x16F8
; CHECK-NEXT	.cfi_def_cfa_offset 8
; CHECK-NEXT	retq


  %a = alloca i32, i64 1000, align 16
  %b = alloca i32, i64 500, align 16
  %a0 = getelementptr inbounds i32, i32* %a, i64 500
  %b0 = getelementptr inbounds i32, i32* %b, i64 200
  store volatile i32 1, i32* %a0
  store volatile i32 2, i32* %b0
  %c = load volatile i32, i32* %a
  ret i32 %c
}

attributes #0 =  {"probe-stack"="inline-asm"}
