; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686--   -mattr=sse2 | FileCheck %s --check-prefixes=ANY,X32-SSE2
; RUN: llc < %s -mtriple=x86_64-- -mattr=avx2 | FileCheck %s --check-prefixes=ANY,X64-AVX2

declare i8 @llvm.fshl.i8(i8, i8, i8)
declare i16 @llvm.fshl.i16(i16, i16, i16)
declare i32 @llvm.fshl.i32(i32, i32, i32)
declare i64 @llvm.fshl.i64(i64, i64, i64)
declare <4 x i32> @llvm.fshl.v4i32(<4 x i32>, <4 x i32>, <4 x i32>)

declare i8 @llvm.fshr.i8(i8, i8, i8)
declare i16 @llvm.fshr.i16(i16, i16, i16)
declare i32 @llvm.fshr.i32(i32, i32, i32)
declare i64 @llvm.fshr.i64(i64, i64, i64)
declare <4 x i32> @llvm.fshr.v4i32(<4 x i32>, <4 x i32>, <4 x i32>)

; General case - all operands can be variables

define i32 @fshl_i32(i32 %x, i32 %y, i32 %z) nounwind {
; X32-SSE2-LABEL: fshl_i32:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shldl %cl, %edx, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i32:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edx, %ecx
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-AVX2-NEXT:    shldl %cl, %esi, %eax
; X64-AVX2-NEXT:    retq
  %f = call i32 @llvm.fshl.i32(i32 %x, i32 %y, i32 %z)
  ret i32 %f
}

; Verify that weird types are minimally supported.
declare i37 @llvm.fshl.i37(i37, i37, i37)
define i37 @fshl_i37(i37 %x, i37 %y, i37 %z) nounwind {
; X32-SSE2-LABEL: fshl_i37:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    pushl %ebp
; X32-SSE2-NEXT:    pushl %ebx
; X32-SSE2-NEXT:    pushl %edi
; X32-SSE2-NEXT:    pushl %esi
; X32-SSE2-NEXT:    pushl %eax
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X32-SSE2-NEXT:    andl $31, %esi
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    andl $31, %eax
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; X32-SSE2-NEXT:    pushl $0
; X32-SSE2-NEXT:    pushl $37
; X32-SSE2-NEXT:    pushl %eax
; X32-SSE2-NEXT:    pushl {{[0-9]+}}(%esp)
; X32-SSE2-NEXT:    calll __umoddi3
; X32-SSE2-NEXT:    addl $16, %esp
; X32-SSE2-NEXT:    movl %eax, %ebx
; X32-SSE2-NEXT:    movl %edx, (%esp) # 4-byte Spill
; X32-SSE2-NEXT:    movl %ebp, %edx
; X32-SSE2-NEXT:    movl %ebx, %ecx
; X32-SSE2-NEXT:    shll %cl, %ebp
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shldl %cl, %edx, %eax
; X32-SSE2-NEXT:    xorl %ecx, %ecx
; X32-SSE2-NEXT:    testb $32, %bl
; X32-SSE2-NEXT:    cmovnel %ebp, %eax
; X32-SSE2-NEXT:    cmovnel %ecx, %ebp
; X32-SSE2-NEXT:    xorl %edx, %edx
; X32-SSE2-NEXT:    movb $37, %cl
; X32-SSE2-NEXT:    subb %bl, %cl
; X32-SSE2-NEXT:    shrdl %cl, %esi, %edi
; X32-SSE2-NEXT:    shrl %cl, %esi
; X32-SSE2-NEXT:    testb $32, %cl
; X32-SSE2-NEXT:    cmovnel %esi, %edi
; X32-SSE2-NEXT:    cmovnel %edx, %esi
; X32-SSE2-NEXT:    orl %eax, %esi
; X32-SSE2-NEXT:    orl %ebp, %edi
; X32-SSE2-NEXT:    orl %ebx, (%esp) # 4-byte Folded Spill
; X32-SSE2-NEXT:    cmovel {{[0-9]+}}(%esp), %edi
; X32-SSE2-NEXT:    cmovel {{[0-9]+}}(%esp), %esi
; X32-SSE2-NEXT:    movl %edi, %eax
; X32-SSE2-NEXT:    movl %esi, %edx
; X32-SSE2-NEXT:    addl $4, %esp
; X32-SSE2-NEXT:    popl %esi
; X32-SSE2-NEXT:    popl %edi
; X32-SSE2-NEXT:    popl %ebx
; X32-SSE2-NEXT:    popl %ebp
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i37:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movq %rdx, %r8
; X64-AVX2-NEXT:    movabsq $137438953471, %rax # imm = 0x1FFFFFFFFF
; X64-AVX2-NEXT:    andq %rax, %rsi
; X64-AVX2-NEXT:    andq %rax, %r8
; X64-AVX2-NEXT:    movabsq $-2492803253203993461, %rcx # imm = 0xDD67C8A60DD67C8B
; X64-AVX2-NEXT:    movq %r8, %rax
; X64-AVX2-NEXT:    mulq %rcx
; X64-AVX2-NEXT:    shrq $5, %rdx
; X64-AVX2-NEXT:    leaq (%rdx,%rdx,8), %rax
; X64-AVX2-NEXT:    leaq (%rdx,%rax,4), %rax
; X64-AVX2-NEXT:    subq %rax, %r8
; X64-AVX2-NEXT:    movq %rdi, %rax
; X64-AVX2-NEXT:    movl %r8d, %ecx
; X64-AVX2-NEXT:    shlq %cl, %rax
; X64-AVX2-NEXT:    movl $37, %ecx
; X64-AVX2-NEXT:    subl %r8d, %ecx
; X64-AVX2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-AVX2-NEXT:    shrq %cl, %rsi
; X64-AVX2-NEXT:    orq %rax, %rsi
; X64-AVX2-NEXT:    testq %r8, %r8
; X64-AVX2-NEXT:    cmoveq %rdi, %rsi
; X64-AVX2-NEXT:    movq %rsi, %rax
; X64-AVX2-NEXT:    retq
  %f = call i37 @llvm.fshl.i37(i37 %x, i37 %y, i37 %z)
  ret i37 %f
}

; extract(concat(0b1110000, 0b1111111) << 2) = 0b1000011

declare i7 @llvm.fshl.i7(i7, i7, i7)
define i7 @fshl_i7_const_fold() {
; ANY-LABEL: fshl_i7_const_fold:
; ANY:       # %bb.0:
; ANY-NEXT:    movb $67, %al
; ANY-NEXT:    ret{{[l|q]}}
  %f = call i7 @llvm.fshl.i7(i7 112, i7 127, i7 2)
  ret i7 %f
}

; With constant shift amount, this is 'shld' with constant operand.

define i32 @fshl_i32_const_shift(i32 %x, i32 %y) nounwind {
; X32-SSE2-LABEL: fshl_i32_const_shift:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shldl $9, %ecx, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i32_const_shift:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    shldl $9, %esi, %eax
; X64-AVX2-NEXT:    retq
  %f = call i32 @llvm.fshl.i32(i32 %x, i32 %y, i32 9)
  ret i32 %f
}

; Check modulo math on shift amount.

define i32 @fshl_i32_const_overshift(i32 %x, i32 %y) nounwind {
; X32-SSE2-LABEL: fshl_i32_const_overshift:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shldl $9, %ecx, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i32_const_overshift:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    shldl $9, %esi, %eax
; X64-AVX2-NEXT:    retq
  %f = call i32 @llvm.fshl.i32(i32 %x, i32 %y, i32 41)
  ret i32 %f
}

; 64-bit should also work.

define i64 @fshl_i64_const_overshift(i64 %x, i64 %y) nounwind {
; X32-SSE2-LABEL: fshl_i64_const_overshift:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X32-SSE2-NEXT:    shldl $9, %ecx, %edx
; X32-SSE2-NEXT:    shrdl $23, %ecx, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i64_const_overshift:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movq %rdi, %rax
; X64-AVX2-NEXT:    shldq $41, %rsi, %rax
; X64-AVX2-NEXT:    retq
  %f = call i64 @llvm.fshl.i64(i64 %x, i64 %y, i64 105)
  ret i64 %f
}

; This should work without any node-specific logic.

define i8 @fshl_i8_const_fold() nounwind {
; ANY-LABEL: fshl_i8_const_fold:
; ANY:       # %bb.0:
; ANY-NEXT:    movb $-128, %al
; ANY-NEXT:    ret{{[l|q]}}
  %f = call i8 @llvm.fshl.i8(i8 255, i8 0, i8 7)
  ret i8 %f
}

; Repeat everything for funnel shift right.

; General case - all operands can be variables

define i32 @fshr_i32(i32 %x, i32 %y, i32 %z) nounwind {
; X32-SSE2-LABEL: fshr_i32:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shrdl %cl, %edx, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i32:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edx, %ecx
; X64-AVX2-NEXT:    movl %esi, %eax
; X64-AVX2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-AVX2-NEXT:    shrdl %cl, %edi, %eax
; X64-AVX2-NEXT:    retq
  %f = call i32 @llvm.fshr.i32(i32 %x, i32 %y, i32 %z)
  ret i32 %f
}

; Verify that weird types are minimally supported.
declare i37 @llvm.fshr.i37(i37, i37, i37)
define i37 @fshr_i37(i37 %x, i37 %y, i37 %z) nounwind {
; X32-SSE2-LABEL: fshr_i37:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    pushl %ebp
; X32-SSE2-NEXT:    pushl %ebx
; X32-SSE2-NEXT:    pushl %edi
; X32-SSE2-NEXT:    pushl %esi
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X32-SSE2-NEXT:    andl $31, %esi
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    andl $31, %eax
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %edi
; X32-SSE2-NEXT:    pushl $0
; X32-SSE2-NEXT:    pushl $37
; X32-SSE2-NEXT:    pushl %eax
; X32-SSE2-NEXT:    pushl {{[0-9]+}}(%esp)
; X32-SSE2-NEXT:    calll __umoddi3
; X32-SSE2-NEXT:    addl $16, %esp
; X32-SSE2-NEXT:    movl %eax, %ebx
; X32-SSE2-NEXT:    movb $37, %cl
; X32-SSE2-NEXT:    subb %bl, %cl
; X32-SSE2-NEXT:    movl %ebp, %eax
; X32-SSE2-NEXT:    shll %cl, %ebp
; X32-SSE2-NEXT:    shldl %cl, %eax, %edi
; X32-SSE2-NEXT:    xorl %eax, %eax
; X32-SSE2-NEXT:    testb $32, %cl
; X32-SSE2-NEXT:    cmovnel %ebp, %edi
; X32-SSE2-NEXT:    cmovnel %eax, %ebp
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    movl %ebx, %ecx
; X32-SSE2-NEXT:    shrdl %cl, %esi, %eax
; X32-SSE2-NEXT:    shrl %cl, %esi
; X32-SSE2-NEXT:    testb $32, %bl
; X32-SSE2-NEXT:    cmovnel %esi, %eax
; X32-SSE2-NEXT:    movl $0, %ecx
; X32-SSE2-NEXT:    cmovnel %ecx, %esi
; X32-SSE2-NEXT:    orl %edi, %esi
; X32-SSE2-NEXT:    orl %ebp, %eax
; X32-SSE2-NEXT:    orl %ebx, %edx
; X32-SSE2-NEXT:    cmovel {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    cmovel {{[0-9]+}}(%esp), %esi
; X32-SSE2-NEXT:    movl %esi, %edx
; X32-SSE2-NEXT:    popl %esi
; X32-SSE2-NEXT:    popl %edi
; X32-SSE2-NEXT:    popl %ebx
; X32-SSE2-NEXT:    popl %ebp
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i37:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movq %rdx, %r8
; X64-AVX2-NEXT:    movabsq $137438953471, %rax # imm = 0x1FFFFFFFFF
; X64-AVX2-NEXT:    movq %rsi, %r9
; X64-AVX2-NEXT:    andq %rax, %r9
; X64-AVX2-NEXT:    andq %rax, %r8
; X64-AVX2-NEXT:    movabsq $-2492803253203993461, %rcx # imm = 0xDD67C8A60DD67C8B
; X64-AVX2-NEXT:    movq %r8, %rax
; X64-AVX2-NEXT:    mulq %rcx
; X64-AVX2-NEXT:    shrq $5, %rdx
; X64-AVX2-NEXT:    leaq (%rdx,%rdx,8), %rax
; X64-AVX2-NEXT:    leaq (%rdx,%rax,4), %rax
; X64-AVX2-NEXT:    subq %rax, %r8
; X64-AVX2-NEXT:    movl %r8d, %ecx
; X64-AVX2-NEXT:    shrq %cl, %r9
; X64-AVX2-NEXT:    movl $37, %ecx
; X64-AVX2-NEXT:    subl %r8d, %ecx
; X64-AVX2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-AVX2-NEXT:    shlq %cl, %rdi
; X64-AVX2-NEXT:    orq %r9, %rdi
; X64-AVX2-NEXT:    testq %r8, %r8
; X64-AVX2-NEXT:    cmoveq %rsi, %rdi
; X64-AVX2-NEXT:    movq %rdi, %rax
; X64-AVX2-NEXT:    retq
  %f = call i37 @llvm.fshr.i37(i37 %x, i37 %y, i37 %z)
  ret i37 %f
}

; extract(concat(0b1110000, 0b1111111) >> 2) = 0b0011111

declare i7 @llvm.fshr.i7(i7, i7, i7)
define i7 @fshr_i7_const_fold() nounwind {
; ANY-LABEL: fshr_i7_const_fold:
; ANY:       # %bb.0:
; ANY-NEXT:    movb $31, %al
; ANY-NEXT:    ret{{[l|q]}}
  %f = call i7 @llvm.fshr.i7(i7 112, i7 127, i7 2)
  ret i7 %f
}

; demanded bits tests

define i32 @fshl_i32_demandedbits(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshl_i32_demandedbits:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shldl $9, %ecx, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i32_demandedbits:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    shldl $9, %esi, %eax
; X64-AVX2-NEXT:    retq
  %x = or i32 %a0, 2147483648
  %y = or i32 %a1, 1
  %res = call i32 @llvm.fshl.i32(i32 %x, i32 %y, i32 9)
  ret i32 %res
}

define i32 @fshr_i32_demandedbits(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshr_i32_demandedbits:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shrdl $9, %ecx, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i32_demandedbits:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    shldl $23, %esi, %eax
; X64-AVX2-NEXT:    retq
  %x = or i32 %a0, 2147483648
  %y = or i32 %a1, 1
  %res = call i32 @llvm.fshr.i32(i32 %x, i32 %y, i32 9)
  ret i32 %res
}

; undef handling

define i32 @fshl_i32_undef0(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshl_i32_undef0:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shldl %cl, %eax, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i32_undef0:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %esi, %ecx
; X64-AVX2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-AVX2-NEXT:    shldl %cl, %edi, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshl.i32(i32 undef, i32 %a0, i32 %a1)
  ret i32 %res
}

define i32 @fshl_i32_undef0_msk(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshl_i32_undef0_msk:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-SSE2-NEXT:    andl $7, %ecx
; X32-SSE2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X32-SSE2-NEXT:    shldl %cl, %eax, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i32_undef0_msk:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %esi, %ecx
; X64-AVX2-NEXT:    andl $7, %ecx
; X64-AVX2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-AVX2-NEXT:    shldl %cl, %edi, %eax
; X64-AVX2-NEXT:    retq
  %m = and i32 %a1, 7
  %res = call i32 @llvm.fshl.i32(i32 undef, i32 %a0, i32 %m)
  ret i32 %res
}

define i32 @fshl_i32_undef0_cst(i32 %a0) nounwind {
; X32-SSE2-LABEL: fshl_i32_undef0_cst:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shrl $23, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i32_undef0_cst:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    shrl $23, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshl.i32(i32 undef, i32 %a0, i32 9)
  ret i32 %res
}

define i32 @fshl_i32_undef1(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshl_i32_undef1:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shldl %cl, %eax, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i32_undef1:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %esi, %ecx
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-AVX2-NEXT:    shldl %cl, %eax, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshl.i32(i32 %a0, i32 undef, i32 %a1)
  ret i32 %res
}

define i32 @fshl_i32_undef1_msk(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshl_i32_undef1_msk:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X32-SSE2-NEXT:    andb $7, %cl
; X32-SSE2-NEXT:    shll %cl, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i32_undef1_msk:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %esi, %ecx
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    andb $7, %cl
; X64-AVX2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-AVX2-NEXT:    shll %cl, %eax
; X64-AVX2-NEXT:    retq
  %m = and i32 %a1, 7
  %res = call i32 @llvm.fshl.i32(i32 %a0, i32 undef, i32 %m)
  ret i32 %res
}

define i32 @fshl_i32_undef1_cst(i32 %a0) nounwind {
; X32-SSE2-LABEL: fshl_i32_undef1_cst:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shll $9, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i32_undef1_cst:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    shll $9, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshl.i32(i32 %a0, i32 undef, i32 9)
  ret i32 %res
}

define i32 @fshl_i32_undef2(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshl_i32_undef2:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shldl %cl, %ecx, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i32_undef2:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    shldl %cl, %esi, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshl.i32(i32 %a0, i32 %a1, i32 undef)
  ret i32 %res
}

define i32 @fshr_i32_undef0(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshr_i32_undef0:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shrdl %cl, %eax, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i32_undef0:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %esi, %ecx
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-AVX2-NEXT:    shrdl %cl, %eax, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshr.i32(i32 undef, i32 %a0, i32 %a1)
  ret i32 %res
}

define i32 @fshr_i32_undef0_msk(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshr_i32_undef0_msk:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X32-SSE2-NEXT:    andb $7, %cl
; X32-SSE2-NEXT:    shrl %cl, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i32_undef0_msk:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %esi, %ecx
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    andb $7, %cl
; X64-AVX2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-AVX2-NEXT:    shrl %cl, %eax
; X64-AVX2-NEXT:    retq
  %m = and i32 %a1, 7
  %res = call i32 @llvm.fshr.i32(i32 undef, i32 %a0, i32 %m)
  ret i32 %res
}

define i32 @fshr_i32_undef0_cst(i32 %a0) nounwind {
; X32-SSE2-LABEL: fshr_i32_undef0_cst:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shrl $9, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i32_undef0_cst:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    shrl $9, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshr.i32(i32 undef, i32 %a0, i32 9)
  ret i32 %res
}

define i32 @fshr_i32_undef1(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshr_i32_undef1:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shrdl %cl, %eax, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i32_undef1:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %esi, %ecx
; X64-AVX2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-AVX2-NEXT:    shrdl %cl, %edi, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshr.i32(i32 %a0, i32 undef, i32 %a1)
  ret i32 %res
}

define i32 @fshr_i32_undef1_msk(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshr_i32_undef1_msk:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-SSE2-NEXT:    andl $7, %ecx
; X32-SSE2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X32-SSE2-NEXT:    shrdl %cl, %eax, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i32_undef1_msk:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %esi, %ecx
; X64-AVX2-NEXT:    andl $7, %ecx
; X64-AVX2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-AVX2-NEXT:    shrdl %cl, %edi, %eax
; X64-AVX2-NEXT:    retq
  %m = and i32 %a1, 7
  %res = call i32 @llvm.fshr.i32(i32 %a0, i32 undef, i32 %m)
  ret i32 %res
}

define i32 @fshr_i32_undef1_cst(i32 %a0) nounwind {
; X32-SSE2-LABEL: fshr_i32_undef1_cst:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shll $23, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i32_undef1_cst:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    shll $23, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshr.i32(i32 %a0, i32 undef, i32 9)
  ret i32 %res
}

define i32 @fshr_i32_undef2(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshr_i32_undef2:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shrdl %cl, %ecx, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i32_undef2:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %esi, %eax
; X64-AVX2-NEXT:    shrdl %cl, %edi, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshr.i32(i32 %a0, i32 %a1, i32 undef)
  ret i32 %res
}

; shift zero args

define i32 @fshl_i32_zero0(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshl_i32_zero0:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X32-SSE2-NEXT:    xorl %eax, %eax
; X32-SSE2-NEXT:    shldl %cl, %edx, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i32_zero0:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %esi, %ecx
; X64-AVX2-NEXT:    xorl %eax, %eax
; X64-AVX2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-AVX2-NEXT:    shldl %cl, %edi, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshl.i32(i32 0, i32 %a0, i32 %a1)
  ret i32 %res
}

define i32 @fshl_i32_zero0_cst(i32 %a0) nounwind {
; X32-SSE2-LABEL: fshl_i32_zero0_cst:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shrl $23, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i32_zero0_cst:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    shrl $23, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshl.i32(i32 0, i32 %a0, i32 9)
  ret i32 %res
}

define i32 @fshl_i32_zero1(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshl_i32_zero1:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    xorl %edx, %edx
; X32-SSE2-NEXT:    shldl %cl, %edx, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i32_zero1:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %esi, %ecx
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    xorl %edx, %edx
; X64-AVX2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-AVX2-NEXT:    shldl %cl, %edx, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshl.i32(i32 %a0, i32 0, i32 %a1)
  ret i32 %res
}

define i32 @fshl_i32_zero1_cst(i32 %a0) nounwind {
; X32-SSE2-LABEL: fshl_i32_zero1_cst:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shll $9, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i32_zero1_cst:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    shll $9, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshl.i32(i32 %a0, i32 0, i32 9)
  ret i32 %res
}

define i32 @fshr_i32_zero0(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshr_i32_zero0:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    xorl %edx, %edx
; X32-SSE2-NEXT:    shrdl %cl, %edx, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i32_zero0:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %esi, %ecx
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    xorl %edx, %edx
; X64-AVX2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-AVX2-NEXT:    shrdl %cl, %edx, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshr.i32(i32 0, i32 %a0, i32 %a1)
  ret i32 %res
}

define i32 @fshr_i32_zero0_cst(i32 %a0) nounwind {
; X32-SSE2-LABEL: fshr_i32_zero0_cst:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shrl $9, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i32_zero0_cst:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    shrl $9, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshr.i32(i32 0, i32 %a0, i32 9)
  ret i32 %res
}

define i32 @fshr_i32_zero1(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshr_i32_zero1:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X32-SSE2-NEXT:    xorl %eax, %eax
; X32-SSE2-NEXT:    shrdl %cl, %edx, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i32_zero1:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %esi, %ecx
; X64-AVX2-NEXT:    xorl %eax, %eax
; X64-AVX2-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-AVX2-NEXT:    shrdl %cl, %edi, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshr.i32(i32 %a0, i32 0, i32 %a1)
  ret i32 %res
}

define i32 @fshr_i32_zero1_cst(i32 %a0) nounwind {
; X32-SSE2-LABEL: fshr_i32_zero1_cst:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shll $23, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i32_zero1_cst:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    shll $23, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshr.i32(i32 %a0, i32 0, i32 9)
  ret i32 %res
}

; shift by zero

define i32 @fshl_i32_zero2(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshl_i32_zero2:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i32_zero2:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshl.i32(i32 %a0, i32 %a1, i32 0)
  ret i32 %res
}

define i32 @fshr_i32_zero2(i32 %a0, i32 %a1) nounwind {
; X32-SSE2-LABEL: fshr_i32_zero2:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i32_zero2:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %esi, %eax
; X64-AVX2-NEXT:    retq
  %res = call i32 @llvm.fshr.i32(i32 %a0, i32 %a1, i32 0)
  ret i32 %res
}

; With constant shift amount, this is 'shrd' or 'shld'.

define i32 @fshr_i32_const_shift(i32 %x, i32 %y) nounwind {
; X32-SSE2-LABEL: fshr_i32_const_shift:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shrdl $9, %ecx, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i32_const_shift:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    shldl $23, %esi, %eax
; X64-AVX2-NEXT:    retq
  %f = call i32 @llvm.fshr.i32(i32 %x, i32 %y, i32 9)
  ret i32 %f
}

; Check modulo math on shift amount. 41-32=9, but right-shift may became left, so 32-9=23.

define i32 @fshr_i32_const_overshift(i32 %x, i32 %y) nounwind {
; X32-SSE2-LABEL: fshr_i32_const_overshift:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    shrdl $9, %ecx, %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i32_const_overshift:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    shldl $23, %esi, %eax
; X64-AVX2-NEXT:    retq
  %f = call i32 @llvm.fshr.i32(i32 %x, i32 %y, i32 41)
  ret i32 %f
}

; 64-bit should also work. 105-64 = 41, but right-shift became left, so 64-41=23.

define i64 @fshr_i64_const_overshift(i64 %x, i64 %y) nounwind {
; X32-SSE2-LABEL: fshr_i64_const_overshift:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X32-SSE2-NEXT:    shrdl $9, %ecx, %eax
; X32-SSE2-NEXT:    shldl $23, %ecx, %edx
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i64_const_overshift:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movq %rdi, %rax
; X64-AVX2-NEXT:    shldq $23, %rsi, %rax
; X64-AVX2-NEXT:    retq
  %f = call i64 @llvm.fshr.i64(i64 %x, i64 %y, i64 105)
  ret i64 %f
}

; This should work without any node-specific logic.

define i8 @fshr_i8_const_fold() nounwind {
; ANY-LABEL: fshr_i8_const_fold:
; ANY:       # %bb.0:
; ANY-NEXT:    movb $-2, %al
; ANY-NEXT:    ret{{[l|q]}}
  %f = call i8 @llvm.fshr.i8(i8 255, i8 0, i8 7)
  ret i8 %f
}

define i32 @fshl_i32_shift_by_bitwidth(i32 %x, i32 %y) nounwind {
; X32-SSE2-LABEL: fshl_i32_shift_by_bitwidth:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshl_i32_shift_by_bitwidth:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %edi, %eax
; X64-AVX2-NEXT:    retq
  %f = call i32 @llvm.fshl.i32(i32 %x, i32 %y, i32 32)
  ret i32 %f
}

define i32 @fshr_i32_shift_by_bitwidth(i32 %x, i32 %y) nounwind {
; X32-SSE2-LABEL: fshr_i32_shift_by_bitwidth:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_i32_shift_by_bitwidth:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movl %esi, %eax
; X64-AVX2-NEXT:    retq
  %f = call i32 @llvm.fshr.i32(i32 %x, i32 %y, i32 32)
  ret i32 %f
}

define <4 x i32> @fshl_v4i32_shift_by_bitwidth(<4 x i32> %x, <4 x i32> %y) nounwind {
; ANY-LABEL: fshl_v4i32_shift_by_bitwidth:
; ANY:       # %bb.0:
; ANY-NEXT:    ret{{[l|q]}}
  %f = call <4 x i32> @llvm.fshl.v4i32(<4 x i32> %x, <4 x i32> %y, <4 x i32> <i32 32, i32 32, i32 32, i32 32>)
  ret <4 x i32> %f
}

define <4 x i32> @fshr_v4i32_shift_by_bitwidth(<4 x i32> %x, <4 x i32> %y) nounwind {
; X32-SSE2-LABEL: fshr_v4i32_shift_by_bitwidth:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    movaps %xmm1, %xmm0
; X32-SSE2-NEXT:    retl
;
; X64-AVX2-LABEL: fshr_v4i32_shift_by_bitwidth:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    vmovaps %xmm1, %xmm0
; X64-AVX2-NEXT:    retq
  %f = call <4 x i32> @llvm.fshr.v4i32(<4 x i32> %x, <4 x i32> %y, <4 x i32> <i32 32, i32 32, i32 32, i32 32>)
  ret <4 x i32> %f
}

%struct.S = type { [11 x i8], i8 }
define void @PR45265(i32 %0, %struct.S* nocapture readonly %1) nounwind {
; X32-SSE2-LABEL: PR45265:
; X32-SSE2:       # %bb.0:
; X32-SSE2-NEXT:    pushl %ebx
; X32-SSE2-NEXT:    pushl %edi
; X32-SSE2-NEXT:    pushl %esi
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X32-SSE2-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X32-SSE2-NEXT:    leal (%eax,%eax,2), %edx
; X32-SSE2-NEXT:    movzwl 8(%ecx,%edx,4), %esi
; X32-SSE2-NEXT:    movsbl 10(%ecx,%edx,4), %edi
; X32-SSE2-NEXT:    movl %edi, %ebx
; X32-SSE2-NEXT:    shll $16, %ebx
; X32-SSE2-NEXT:    orl %esi, %ebx
; X32-SSE2-NEXT:    movl 4(%ecx,%edx,4), %ecx
; X32-SSE2-NEXT:    shrdl $8, %ebx, %ecx
; X32-SSE2-NEXT:    xorl %eax, %ecx
; X32-SSE2-NEXT:    sarl $31, %eax
; X32-SSE2-NEXT:    sarl $31, %edi
; X32-SSE2-NEXT:    shldl $24, %ebx, %edi
; X32-SSE2-NEXT:    xorl %eax, %edi
; X32-SSE2-NEXT:    orl %edi, %ecx
; X32-SSE2-NEXT:    je .LBB44_2
; X32-SSE2-NEXT:  # %bb.1:
; X32-SSE2-NEXT:    popl %esi
; X32-SSE2-NEXT:    popl %edi
; X32-SSE2-NEXT:    popl %ebx
; X32-SSE2-NEXT:    retl
; X32-SSE2-NEXT:  .LBB44_2:
; X32-SSE2-NEXT:    popl %esi
; X32-SSE2-NEXT:    popl %edi
; X32-SSE2-NEXT:    popl %ebx
; X32-SSE2-NEXT:    jmp _Z3foov # TAILCALL
;
; X64-AVX2-LABEL: PR45265:
; X64-AVX2:       # %bb.0:
; X64-AVX2-NEXT:    movslq %edi, %rax
; X64-AVX2-NEXT:    leaq (%rax,%rax,2), %rcx
; X64-AVX2-NEXT:    movsbq 10(%rsi,%rcx,4), %rdx
; X64-AVX2-NEXT:    shlq $16, %rdx
; X64-AVX2-NEXT:    movzwl 8(%rsi,%rcx,4), %edi
; X64-AVX2-NEXT:    orq %rdx, %rdi
; X64-AVX2-NEXT:    movq (%rsi,%rcx,4), %rcx
; X64-AVX2-NEXT:    shrdq $40, %rdi, %rcx
; X64-AVX2-NEXT:    cmpq %rax, %rcx
; X64-AVX2-NEXT:    je .LBB44_2
; X64-AVX2-NEXT:  # %bb.1:
; X64-AVX2-NEXT:    retq
; X64-AVX2-NEXT:  .LBB44_2:
; X64-AVX2-NEXT:    jmp _Z3foov # TAILCALL
  %3 = sext i32 %0 to i64
  %4 = getelementptr inbounds %struct.S, %struct.S* %1, i64 %3
  %5 = bitcast %struct.S* %4 to i88*
  %6 = load i88, i88* %5, align 1
  %7 = ashr i88 %6, 40
  %8 = trunc i88 %7 to i64
  %9 = icmp eq i64 %8, %3
  br i1 %9, label %10, label %11

10:
  tail call void @_Z3foov()
  br label %11

11:
  ret void
}
declare dso_local void @_Z3foov()
