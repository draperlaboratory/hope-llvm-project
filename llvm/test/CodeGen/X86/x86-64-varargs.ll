; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --no_x86_scrub_sp
; RUN: llc < %s -mtriple=x86_64-apple-darwin -code-model=large -relocation-model=static | FileCheck --check-prefix=CHECK-X64 %s

@.str = internal constant [38 x i8] c"%d, %f, %d, %lld, %d, %f, %d, %d, %d\0A\00"		; <[38 x i8]*> [#uses=1]

declare i32 @printf(i8*, ...) nounwind

declare void @llvm.va_start(i8*)
declare void @llvm.va_copy(i8*, i8*)
declare void @llvm.va_end(i8*)

%struct.va_list = type { i32, i32, i8*, i8* }

define void @func(...) nounwind {
; CHECK-X64-LABEL: func:
; CHECK-X64:       ## %bb.0: ## %entry
; CHECK-X64-NEXT:    pushq %rbx
; CHECK-X64-NEXT:    subq $224, %rsp
; CHECK-X64-NEXT:    testb %al, %al
; CHECK-X64-NEXT:    je LBB0_2
; CHECK-X64-NEXT:  ## %bb.1: ## %entry
; CHECK-X64-NEXT:    movaps %xmm0, 96(%rsp)
; CHECK-X64-NEXT:    movaps %xmm1, 112(%rsp)
; CHECK-X64-NEXT:    movaps %xmm2, 128(%rsp)
; CHECK-X64-NEXT:    movaps %xmm3, 144(%rsp)
; CHECK-X64-NEXT:    movaps %xmm4, 160(%rsp)
; CHECK-X64-NEXT:    movaps %xmm5, 176(%rsp)
; CHECK-X64-NEXT:    movaps %xmm6, 192(%rsp)
; CHECK-X64-NEXT:    movaps %xmm7, 208(%rsp)
; CHECK-X64-NEXT:  LBB0_2: ## %entry
; CHECK-X64-NEXT:    movq %rdi, 48(%rsp)
; CHECK-X64-NEXT:    movq %rsi, 56(%rsp)
; CHECK-X64-NEXT:    movq %rdx, 64(%rsp)
; CHECK-X64-NEXT:    movq %rcx, 72(%rsp)
; CHECK-X64-NEXT:    movq %r8, 80(%rsp)
; CHECK-X64-NEXT:    movq %r9, 88(%rsp)
; CHECK-X64-NEXT:    movabsq $206158430208, %rax ## imm = 0x3000000000
; CHECK-X64-NEXT:    movq %rax, (%rsp)
; CHECK-X64-NEXT:    leaq 240(%rsp), %rax
; CHECK-X64-NEXT:    movq %rax, 8(%rsp)
; CHECK-X64-NEXT:    leaq 48(%rsp), %rax
; CHECK-X64-NEXT:    movq %rax, 16(%rsp)
; CHECK-X64-NEXT:    movl (%rsp), %ecx
; CHECK-X64-NEXT:    cmpl $48, %ecx
; CHECK-X64-NEXT:    jae LBB0_4
; CHECK-X64-NEXT:  ## %bb.3: ## %entry
; CHECK-X64-NEXT:    movq 16(%rsp), %rax
; CHECK-X64-NEXT:    addq %rcx, %rax
; CHECK-X64-NEXT:    addl $8, %ecx
; CHECK-X64-NEXT:    movl %ecx, (%rsp)
; CHECK-X64-NEXT:    jmp LBB0_5
; CHECK-X64-NEXT:  LBB0_4: ## %entry
; CHECK-X64-NEXT:    movq 8(%rsp), %rax
; CHECK-X64-NEXT:    movq %rax, %rcx
; CHECK-X64-NEXT:    addq $8, %rcx
; CHECK-X64-NEXT:    movq %rcx, 8(%rsp)
; CHECK-X64-NEXT:  LBB0_5: ## %entry
; CHECK-X64-NEXT:    movl (%rax), %r10d
; CHECK-X64-NEXT:    movl (%rsp), %ecx
; CHECK-X64-NEXT:    cmpl $48, %ecx
; CHECK-X64-NEXT:    jae LBB0_7
; CHECK-X64-NEXT:  ## %bb.6: ## %entry
; CHECK-X64-NEXT:    movq 16(%rsp), %rax
; CHECK-X64-NEXT:    addq %rcx, %rax
; CHECK-X64-NEXT:    addl $8, %ecx
; CHECK-X64-NEXT:    movl %ecx, (%rsp)
; CHECK-X64-NEXT:    jmp LBB0_8
; CHECK-X64-NEXT:  LBB0_7: ## %entry
; CHECK-X64-NEXT:    movq 8(%rsp), %rax
; CHECK-X64-NEXT:    movq %rax, %rcx
; CHECK-X64-NEXT:    addq $8, %rcx
; CHECK-X64-NEXT:    movq %rcx, 8(%rsp)
; CHECK-X64-NEXT:  LBB0_8: ## %entry
; CHECK-X64-NEXT:    movl (%rax), %r11d
; CHECK-X64-NEXT:    movl (%rsp), %ecx
; CHECK-X64-NEXT:    cmpl $48, %ecx
; CHECK-X64-NEXT:    jae LBB0_10
; CHECK-X64-NEXT:  ## %bb.9: ## %entry
; CHECK-X64-NEXT:    movq 16(%rsp), %rax
; CHECK-X64-NEXT:    addq %rcx, %rax
; CHECK-X64-NEXT:    addl $8, %ecx
; CHECK-X64-NEXT:    movl %ecx, (%rsp)
; CHECK-X64-NEXT:    jmp LBB0_11
; CHECK-X64-NEXT:  LBB0_10: ## %entry
; CHECK-X64-NEXT:    movq 8(%rsp), %rax
; CHECK-X64-NEXT:    movq %rax, %rcx
; CHECK-X64-NEXT:    addq $8, %rcx
; CHECK-X64-NEXT:    movq %rcx, 8(%rsp)
; CHECK-X64-NEXT:  LBB0_11: ## %entry
; CHECK-X64-NEXT:    movl (%rax), %r9d
; CHECK-X64-NEXT:    movq 16(%rsp), %rax
; CHECK-X64-NEXT:    movq %rax, 40(%rsp)
; CHECK-X64-NEXT:    movq (%rsp), %rax
; CHECK-X64-NEXT:    movq 8(%rsp), %rcx
; CHECK-X64-NEXT:    movq %rcx, 32(%rsp)
; CHECK-X64-NEXT:    movq %rax, 24(%rsp)
; CHECK-X64-NEXT:    movl 4(%rsp), %eax
; CHECK-X64-NEXT:    cmpl $176, %eax
; CHECK-X64-NEXT:    jae LBB0_13
; CHECK-X64-NEXT:  ## %bb.12: ## %entry
; CHECK-X64-NEXT:    addl $16, %eax
; CHECK-X64-NEXT:    movl %eax, 4(%rsp)
; CHECK-X64-NEXT:    jmp LBB0_14
; CHECK-X64-NEXT:  LBB0_13: ## %entry
; CHECK-X64-NEXT:    movq 8(%rsp), %rax
; CHECK-X64-NEXT:    addq $8, %rax
; CHECK-X64-NEXT:    movq %rax, 8(%rsp)
; CHECK-X64-NEXT:  LBB0_14: ## %entry
; CHECK-X64-NEXT:    movl 28(%rsp), %ecx
; CHECK-X64-NEXT:    cmpl $176, %ecx
; CHECK-X64-NEXT:    jae LBB0_16
; CHECK-X64-NEXT:  ## %bb.15: ## %entry
; CHECK-X64-NEXT:    movq 40(%rsp), %rax
; CHECK-X64-NEXT:    addq %rcx, %rax
; CHECK-X64-NEXT:    addl $16, %ecx
; CHECK-X64-NEXT:    movl %ecx, 28(%rsp)
; CHECK-X64-NEXT:    jmp LBB0_17
; CHECK-X64-NEXT:  LBB0_16: ## %entry
; CHECK-X64-NEXT:    movq 32(%rsp), %rax
; CHECK-X64-NEXT:    movq %rax, %rcx
; CHECK-X64-NEXT:    addq $8, %rcx
; CHECK-X64-NEXT:    movq %rcx, 32(%rsp)
; CHECK-X64-NEXT:  LBB0_17: ## %entry
; CHECK-X64-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; CHECK-X64-NEXT:    movl (%rsp), %ecx
; CHECK-X64-NEXT:    cmpl $48, %ecx
; CHECK-X64-NEXT:    jae LBB0_19
; CHECK-X64-NEXT:  ## %bb.18: ## %entry
; CHECK-X64-NEXT:    movq 16(%rsp), %rax
; CHECK-X64-NEXT:    addq %rcx, %rax
; CHECK-X64-NEXT:    addl $8, %ecx
; CHECK-X64-NEXT:    movl %ecx, (%rsp)
; CHECK-X64-NEXT:    jmp LBB0_20
; CHECK-X64-NEXT:  LBB0_19: ## %entry
; CHECK-X64-NEXT:    movq 8(%rsp), %rax
; CHECK-X64-NEXT:    movq %rax, %rcx
; CHECK-X64-NEXT:    addq $8, %rcx
; CHECK-X64-NEXT:    movq %rcx, 8(%rsp)
; CHECK-X64-NEXT:  LBB0_20: ## %entry
; CHECK-X64-NEXT:    movl (%rax), %r8d
; CHECK-X64-NEXT:    movl 24(%rsp), %eax
; CHECK-X64-NEXT:    cmpl $48, %eax
; CHECK-X64-NEXT:    jae LBB0_22
; CHECK-X64-NEXT:  ## %bb.21: ## %entry
; CHECK-X64-NEXT:    addl $8, %eax
; CHECK-X64-NEXT:    movl %eax, 24(%rsp)
; CHECK-X64-NEXT:    jmp LBB0_23
; CHECK-X64-NEXT:  LBB0_22: ## %entry
; CHECK-X64-NEXT:    movq 32(%rsp), %rax
; CHECK-X64-NEXT:    addq $8, %rax
; CHECK-X64-NEXT:    movq %rax, 32(%rsp)
; CHECK-X64-NEXT:  LBB0_23: ## %entry
; CHECK-X64-NEXT:    movl (%rsp), %eax
; CHECK-X64-NEXT:    cmpl $48, %eax
; CHECK-X64-NEXT:    jae LBB0_25
; CHECK-X64-NEXT:  ## %bb.24: ## %entry
; CHECK-X64-NEXT:    addl $8, %eax
; CHECK-X64-NEXT:    movl %eax, (%rsp)
; CHECK-X64-NEXT:    jmp LBB0_26
; CHECK-X64-NEXT:  LBB0_25: ## %entry
; CHECK-X64-NEXT:    movq 8(%rsp), %rax
; CHECK-X64-NEXT:    addq $8, %rax
; CHECK-X64-NEXT:    movq %rax, 8(%rsp)
; CHECK-X64-NEXT:  LBB0_26: ## %entry
; CHECK-X64-NEXT:    movl 24(%rsp), %ecx
; CHECK-X64-NEXT:    cmpl $48, %ecx
; CHECK-X64-NEXT:    jae LBB0_28
; CHECK-X64-NEXT:  ## %bb.27: ## %entry
; CHECK-X64-NEXT:    movq 40(%rsp), %rax
; CHECK-X64-NEXT:    addq %rcx, %rax
; CHECK-X64-NEXT:    addl $8, %ecx
; CHECK-X64-NEXT:    movl %ecx, 24(%rsp)
; CHECK-X64-NEXT:    jmp LBB0_29
; CHECK-X64-NEXT:  LBB0_28: ## %entry
; CHECK-X64-NEXT:    movq 32(%rsp), %rax
; CHECK-X64-NEXT:    movq %rax, %rcx
; CHECK-X64-NEXT:    addq $8, %rcx
; CHECK-X64-NEXT:    movq %rcx, 32(%rsp)
; CHECK-X64-NEXT:  LBB0_29: ## %entry
; CHECK-X64-NEXT:    movq (%rax), %rcx
; CHECK-X64-NEXT:    movl (%rsp), %edx
; CHECK-X64-NEXT:    cmpl $48, %edx
; CHECK-X64-NEXT:    jae LBB0_31
; CHECK-X64-NEXT:  ## %bb.30: ## %entry
; CHECK-X64-NEXT:    movq 16(%rsp), %rax
; CHECK-X64-NEXT:    addq %rdx, %rax
; CHECK-X64-NEXT:    addl $8, %edx
; CHECK-X64-NEXT:    movl %edx, (%rsp)
; CHECK-X64-NEXT:    jmp LBB0_32
; CHECK-X64-NEXT:  LBB0_31: ## %entry
; CHECK-X64-NEXT:    movq 8(%rsp), %rax
; CHECK-X64-NEXT:    movq %rax, %rdx
; CHECK-X64-NEXT:    addq $8, %rdx
; CHECK-X64-NEXT:    movq %rdx, 8(%rsp)
; CHECK-X64-NEXT:  LBB0_32: ## %entry
; CHECK-X64-NEXT:    movl (%rax), %edx
; CHECK-X64-NEXT:    movl 24(%rsp), %eax
; CHECK-X64-NEXT:    cmpl $48, %eax
; CHECK-X64-NEXT:    jae LBB0_34
; CHECK-X64-NEXT:  ## %bb.33: ## %entry
; CHECK-X64-NEXT:    addl $8, %eax
; CHECK-X64-NEXT:    movl %eax, 24(%rsp)
; CHECK-X64-NEXT:    jmp LBB0_35
; CHECK-X64-NEXT:  LBB0_34: ## %entry
; CHECK-X64-NEXT:    movq 32(%rsp), %rax
; CHECK-X64-NEXT:    addq $8, %rax
; CHECK-X64-NEXT:    movq %rax, 32(%rsp)
; CHECK-X64-NEXT:  LBB0_35: ## %entry
; CHECK-X64-NEXT:    movl 4(%rsp), %eax
; CHECK-X64-NEXT:    cmpl $176, %eax
; CHECK-X64-NEXT:    jae LBB0_37
; CHECK-X64-NEXT:  ## %bb.36: ## %entry
; CHECK-X64-NEXT:    addl $16, %eax
; CHECK-X64-NEXT:    movl %eax, 4(%rsp)
; CHECK-X64-NEXT:    jmp LBB0_38
; CHECK-X64-NEXT:  LBB0_37: ## %entry
; CHECK-X64-NEXT:    movq 8(%rsp), %rax
; CHECK-X64-NEXT:    addq $8, %rax
; CHECK-X64-NEXT:    movq %rax, 8(%rsp)
; CHECK-X64-NEXT:  LBB0_38: ## %entry
; CHECK-X64-NEXT:    movl 28(%rsp), %esi
; CHECK-X64-NEXT:    cmpl $176, %esi
; CHECK-X64-NEXT:    jae LBB0_40
; CHECK-X64-NEXT:  ## %bb.39: ## %entry
; CHECK-X64-NEXT:    movq 40(%rsp), %rax
; CHECK-X64-NEXT:    addq %rsi, %rax
; CHECK-X64-NEXT:    addl $16, %esi
; CHECK-X64-NEXT:    movl %esi, 28(%rsp)
; CHECK-X64-NEXT:    jmp LBB0_41
; CHECK-X64-NEXT:  LBB0_40: ## %entry
; CHECK-X64-NEXT:    movq 32(%rsp), %rax
; CHECK-X64-NEXT:    movq %rax, %rsi
; CHECK-X64-NEXT:    addq $8, %rsi
; CHECK-X64-NEXT:    movq %rsi, 32(%rsp)
; CHECK-X64-NEXT:  LBB0_41: ## %entry
; CHECK-X64-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-X64-NEXT:    movl (%rsp), %esi
; CHECK-X64-NEXT:    cmpl $48, %esi
; CHECK-X64-NEXT:    jae LBB0_43
; CHECK-X64-NEXT:  ## %bb.42: ## %entry
; CHECK-X64-NEXT:    movq 16(%rsp), %rax
; CHECK-X64-NEXT:    addq %rsi, %rax
; CHECK-X64-NEXT:    addl $8, %esi
; CHECK-X64-NEXT:    movl %esi, (%rsp)
; CHECK-X64-NEXT:    jmp LBB0_44
; CHECK-X64-NEXT:  LBB0_43: ## %entry
; CHECK-X64-NEXT:    movq 8(%rsp), %rax
; CHECK-X64-NEXT:    movq %rax, %rsi
; CHECK-X64-NEXT:    addq $8, %rsi
; CHECK-X64-NEXT:    movq %rsi, 8(%rsp)
; CHECK-X64-NEXT:  LBB0_44: ## %entry
; CHECK-X64-NEXT:    movl (%rax), %esi
; CHECK-X64-NEXT:    movl 24(%rsp), %eax
; CHECK-X64-NEXT:    cmpl $48, %eax
; CHECK-X64-NEXT:    jae LBB0_46
; CHECK-X64-NEXT:  ## %bb.45: ## %entry
; CHECK-X64-NEXT:    addl $8, %eax
; CHECK-X64-NEXT:    movl %eax, 24(%rsp)
; CHECK-X64-NEXT:    jmp LBB0_47
; CHECK-X64-NEXT:  LBB0_46: ## %entry
; CHECK-X64-NEXT:    movq 32(%rsp), %rax
; CHECK-X64-NEXT:    addq $8, %rax
; CHECK-X64-NEXT:    movq %rax, 32(%rsp)
; CHECK-X64-NEXT:  LBB0_47: ## %entry
; CHECK-X64-NEXT:    movabsq $_.str, %rdi
; CHECK-X64-NEXT:    movabsq $_printf, %rbx
; CHECK-X64-NEXT:    movb $2, %al
; CHECK-X64-NEXT:    pushq %r10
; CHECK-X64-NEXT:    pushq %r11
; CHECK-X64-NEXT:    callq *%rbx
; CHECK-X64-NEXT:    addq $240, %rsp
; CHECK-X64-NEXT:    popq %rbx
; CHECK-X64-NEXT:    retq
entry:
  %ap1 = alloca %struct.va_list
  %ap2 = alloca %struct.va_list
  %ap1p = bitcast %struct.va_list* %ap1 to i8*
  %ap2p = bitcast %struct.va_list* %ap2 to i8*
  tail call void @llvm.va_start(i8* %ap1p)
  %arg1 = va_arg i8* %ap1p, i32
  %arg2 = va_arg i8* %ap1p, i32
  %arg3 = va_arg i8* %ap1p, i32
  tail call void @llvm.va_copy(i8* %ap2p, i8* %ap1p)
  %arg4.1 = va_arg i8* %ap1p, double
  %arg4.2 = va_arg i8* %ap2p, double
  %arg5.1 = va_arg i8* %ap1p, i32
  %arg5.2 = va_arg i8* %ap2p, i32
  %arg6.1 = va_arg i8* %ap1p, i64
  %arg6.2 = va_arg i8* %ap2p, i64
  %arg7.1 = va_arg i8* %ap1p, i32
  %arg7.2 = va_arg i8* %ap2p, i32
  %arg8.1 = va_arg i8* %ap1p, double
  %arg8.2 = va_arg i8* %ap2p, double
  %arg9.1 = va_arg i8* %ap1p, i32
  %arg9.2 = va_arg i8* %ap2p, i32
  %result = tail call i32 (i8*, ...) @printf (i8* getelementptr ([38 x i8], [38 x i8]* @.str, i32 0, i64 0), i32 %arg9.1, double %arg8.2, i32 %arg7.1, i64 %arg6.2, i32 %arg5.1, double %arg4.2, i32 %arg3, i32 %arg2, i32 %arg1) nounwind
  tail call void @llvm.va_end(i8* %ap2p)
  tail call void @llvm.va_end(i8* %ap1p)
  ret void
}

define i32 @main() nounwind {
; CHECK-X64-LABEL: main:
; CHECK-X64:       ## %bb.0: ## %entry
; CHECK-X64-NEXT:    pushq %rax
; CHECK-X64-NEXT:    movl $12, (%rsp)
; CHECK-X64-NEXT:    movabsq $_func, %r10
; CHECK-X64-NEXT:    movabsq $LCPI1_0, %rax
; CHECK-X64-NEXT:    movsd {{.*#+}} xmm0 = mem[0],zero
; CHECK-X64-NEXT:    movabsq $LCPI1_1, %rax
; CHECK-X64-NEXT:    movsd {{.*#+}} xmm1 = mem[0],zero
; CHECK-X64-NEXT:    movabsq $123456677890, %r8 ## imm = 0x1CBE976802
; CHECK-X64-NEXT:    movl $1, %edi
; CHECK-X64-NEXT:    movl $2, %esi
; CHECK-X64-NEXT:    movl $3, %edx
; CHECK-X64-NEXT:    movl $-10, %ecx
; CHECK-X64-NEXT:    movl $120, %r9d
; CHECK-X64-NEXT:    movb $2, %al
; CHECK-X64-NEXT:    callq *%r10
; CHECK-X64-NEXT:    xorl %eax, %eax
; CHECK-X64-NEXT:    popq %rcx
; CHECK-X64-NEXT:    retq
entry:
  tail call void (...) @func(i32 1, i32 2, i32 3, double 4.500000e+15, i32 -10, i64 123456677890, i32 120, double 0x3FF3EB8520000000, i32 12) nounwind
  ret i32 0
}
