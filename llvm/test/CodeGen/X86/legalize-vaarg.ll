; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
;RUN: llc < %s -mtriple=x86_64-- -mattr=avx | FileCheck %s

define <32 x i32> @test_large_vec_vaarg(i32 %n, ...) {
; CHECK-LABEL: test_large_vec_vaarg:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl -{{[0-9]+}}(%rsp), %ecx
; CHECK-NEXT:    cmpl $24, %ecx
; CHECK-NEXT:    jae .LBB0_2
; CHECK-NEXT:  # %bb.1:
; CHECK-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; CHECK-NEXT:    addq %rcx, %rax
; CHECK-NEXT:    addl $8, %ecx
; CHECK-NEXT:    movl %ecx, -{{[0-9]+}}(%rsp)
; CHECK-NEXT:    jmp .LBB0_3
; CHECK-NEXT:  .LBB0_2:
; CHECK-NEXT:    movq (%rsp), %rax
; CHECK-NEXT:    addq $31, %rax
; CHECK-NEXT:    andq $-32, %rax
; CHECK-NEXT:    leaq 32(%rax), %rcx
; CHECK-NEXT:    movq %rcx, (%rsp)
; CHECK-NEXT:  .LBB0_3:
; CHECK-NEXT:    vmovaps (%rax), %ymm0
; CHECK-NEXT:    movl -{{[0-9]+}}(%rsp), %ecx
; CHECK-NEXT:    cmpl $24, %ecx
; CHECK-NEXT:    jae .LBB0_5
; CHECK-NEXT:  # %bb.4:
; CHECK-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; CHECK-NEXT:    addq %rcx, %rax
; CHECK-NEXT:    addl $8, %ecx
; CHECK-NEXT:    movl %ecx, -{{[0-9]+}}(%rsp)
; CHECK-NEXT:    jmp .LBB0_6
; CHECK-NEXT:  .LBB0_5:
; CHECK-NEXT:    movq (%rsp), %rax
; CHECK-NEXT:    addq $31, %rax
; CHECK-NEXT:    andq $-32, %rax
; CHECK-NEXT:    leaq 32(%rax), %rcx
; CHECK-NEXT:    movq %rcx, (%rsp)
; CHECK-NEXT:  .LBB0_6:
; CHECK-NEXT:    vmovaps (%rax), %ymm1
; CHECK-NEXT:    movl -{{[0-9]+}}(%rsp), %ecx
; CHECK-NEXT:    cmpl $24, %ecx
; CHECK-NEXT:    jae .LBB0_8
; CHECK-NEXT:  # %bb.7:
; CHECK-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; CHECK-NEXT:    addq %rcx, %rax
; CHECK-NEXT:    addl $8, %ecx
; CHECK-NEXT:    movl %ecx, -{{[0-9]+}}(%rsp)
; CHECK-NEXT:    jmp .LBB0_9
; CHECK-NEXT:  .LBB0_8:
; CHECK-NEXT:    movq (%rsp), %rax
; CHECK-NEXT:    addq $31, %rax
; CHECK-NEXT:    andq $-32, %rax
; CHECK-NEXT:    leaq 32(%rax), %rcx
; CHECK-NEXT:    movq %rcx, (%rsp)
; CHECK-NEXT:  .LBB0_9:
; CHECK-NEXT:    vmovaps (%rax), %ymm2
; CHECK-NEXT:    movl -{{[0-9]+}}(%rsp), %ecx
; CHECK-NEXT:    cmpl $24, %ecx
; CHECK-NEXT:    jae .LBB0_11
; CHECK-NEXT:  # %bb.10:
; CHECK-NEXT:    movq {{[0-9]+}}(%rsp), %rax
; CHECK-NEXT:    addq %rcx, %rax
; CHECK-NEXT:    addl $8, %ecx
; CHECK-NEXT:    movl %ecx, -{{[0-9]+}}(%rsp)
; CHECK-NEXT:    vmovaps (%rax), %ymm3
; CHECK-NEXT:    retq
; CHECK-NEXT:  .LBB0_11:
; CHECK-NEXT:    movq (%rsp), %rax
; CHECK-NEXT:    addq $31, %rax
; CHECK-NEXT:    andq $-32, %rax
; CHECK-NEXT:    leaq 32(%rax), %rcx
; CHECK-NEXT:    movq %rcx, (%rsp)
; CHECK-NEXT:    vmovaps (%rax), %ymm3
; CHECK-NEXT:    retq
  %args = alloca i8*, align 4
  %x = va_arg i8** %args, <32 x i32>
  ret <32 x i32> %x
}
