; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown | FileCheck %s --check-prefixes=CHECK,X86,X86-FAST
; RUN: llc < %s -mtriple=i686-unknown-unknown -mattr=+slow-shld | FileCheck %s --check-prefixes=CHECK,X86,X86-SLOW
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s --check-prefixes=CHECK,X64,X64-FAST
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+slow-shld | FileCheck %s --check-prefixes=CHECK,X64,X64-SLOW

declare i8 @llvm.fshr.i8(i8, i8, i8) nounwind readnone
declare i16 @llvm.fshr.i16(i16, i16, i16) nounwind readnone
declare i32 @llvm.fshr.i32(i32, i32, i32) nounwind readnone
declare i64 @llvm.fshr.i64(i64, i64, i64) nounwind readnone

;
; Variable Funnel Shift
;

define i8 @var_shift_i8(i8 %x, i8 %y, i8 %z) nounwind {
; X86-LABEL: var_shift_i8:
; X86:       # %bb.0:
; X86-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X86-NEXT:    movzbl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    shll $8, %eax
; X86-NEXT:    orl %edx, %eax
; X86-NEXT:    andb $7, %cl
; X86-NEXT:    shrl %cl, %eax
; X86-NEXT:    # kill: def $al killed $al killed $eax
; X86-NEXT:    retl
;
; X64-LABEL: var_shift_i8:
; X64:       # %bb.0:
; X64-NEXT:    movl %edx, %ecx
; X64-NEXT:    shll $8, %edi
; X64-NEXT:    movzbl %sil, %eax
; X64-NEXT:    orl %edi, %eax
; X64-NEXT:    andb $7, %cl
; X64-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-NEXT:    shrl %cl, %eax
; X64-NEXT:    # kill: def $al killed $al killed $eax
; X64-NEXT:    retq
  %tmp = tail call i8 @llvm.fshr.i8(i8 %x, i8 %y, i8 %z)
  ret i8 %tmp
}

define i16 @var_shift_i16(i16 %x, i16 %y, i16 %z) nounwind {
; X86-FAST-LABEL: var_shift_i16:
; X86-FAST:       # %bb.0:
; X86-FAST-NEXT:    movzwl {{[0-9]+}}(%esp), %edx
; X86-FAST-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-FAST-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X86-FAST-NEXT:    andb $15, %cl
; X86-FAST-NEXT:    shrdw %cl, %dx, %ax
; X86-FAST-NEXT:    retl
;
; X86-SLOW-LABEL: var_shift_i16:
; X86-SLOW:       # %bb.0:
; X86-SLOW-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X86-SLOW-NEXT:    movzwl {{[0-9]+}}(%esp), %edx
; X86-SLOW-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SLOW-NEXT:    shll $16, %eax
; X86-SLOW-NEXT:    orl %edx, %eax
; X86-SLOW-NEXT:    andb $15, %cl
; X86-SLOW-NEXT:    shrl %cl, %eax
; X86-SLOW-NEXT:    # kill: def $ax killed $ax killed $eax
; X86-SLOW-NEXT:    retl
;
; X64-FAST-LABEL: var_shift_i16:
; X64-FAST:       # %bb.0:
; X64-FAST-NEXT:    movl %edx, %ecx
; X64-FAST-NEXT:    movl %esi, %eax
; X64-FAST-NEXT:    andb $15, %cl
; X64-FAST-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-FAST-NEXT:    shrdw %cl, %di, %ax
; X64-FAST-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-FAST-NEXT:    retq
;
; X64-SLOW-LABEL: var_shift_i16:
; X64-SLOW:       # %bb.0:
; X64-SLOW-NEXT:    movl %edx, %ecx
; X64-SLOW-NEXT:    shll $16, %edi
; X64-SLOW-NEXT:    movzwl %si, %eax
; X64-SLOW-NEXT:    orl %edi, %eax
; X64-SLOW-NEXT:    andb $15, %cl
; X64-SLOW-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-SLOW-NEXT:    shrl %cl, %eax
; X64-SLOW-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-SLOW-NEXT:    retq
  %tmp = tail call i16 @llvm.fshr.i16(i16 %x, i16 %y, i16 %z)
  ret i16 %tmp
}

define i32 @var_shift_i32(i32 %x, i32 %y, i32 %z) nounwind {
; X86-FAST-LABEL: var_shift_i32:
; X86-FAST:       # %bb.0:
; X86-FAST-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X86-FAST-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-FAST-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-FAST-NEXT:    shrdl %cl, %edx, %eax
; X86-FAST-NEXT:    retl
;
; X86-SLOW-LABEL: var_shift_i32:
; X86-SLOW:       # %bb.0:
; X86-SLOW-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SLOW-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X86-SLOW-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-SLOW-NEXT:    shrl %cl, %edx
; X86-SLOW-NEXT:    notb %cl
; X86-SLOW-NEXT:    addl %eax, %eax
; X86-SLOW-NEXT:    shll %cl, %eax
; X86-SLOW-NEXT:    orl %edx, %eax
; X86-SLOW-NEXT:    retl
;
; X64-FAST-LABEL: var_shift_i32:
; X64-FAST:       # %bb.0:
; X64-FAST-NEXT:    movl %edx, %ecx
; X64-FAST-NEXT:    movl %esi, %eax
; X64-FAST-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-FAST-NEXT:    shrdl %cl, %edi, %eax
; X64-FAST-NEXT:    retq
;
; X64-SLOW-LABEL: var_shift_i32:
; X64-SLOW:       # %bb.0:
; X64-SLOW-NEXT:    movl %edx, %ecx
; X64-SLOW-NEXT:    # kill: def $edi killed $edi def $rdi
; X64-SLOW-NEXT:    shrl %cl, %esi
; X64-SLOW-NEXT:    leal (%rdi,%rdi), %eax
; X64-SLOW-NEXT:    notb %cl
; X64-SLOW-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-SLOW-NEXT:    shll %cl, %eax
; X64-SLOW-NEXT:    orl %esi, %eax
; X64-SLOW-NEXT:    retq
  %tmp = tail call i32 @llvm.fshr.i32(i32 %x, i32 %y, i32 %z)
  ret i32 %tmp
}

define i32 @var_shift_i32_optsize(i32 %x, i32 %y, i32 %z) nounwind optsize {
; X86-LABEL: var_shift_i32_optsize:
; X86:       # %bb.0:
; X86-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    shrdl %cl, %edx, %eax
; X86-NEXT:    retl
;
; X64-LABEL: var_shift_i32_optsize:
; X64:       # %bb.0:
; X64-NEXT:    movl %edx, %ecx
; X64-NEXT:    movl %esi, %eax
; X64-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-NEXT:    shrdl %cl, %edi, %eax
; X64-NEXT:    retq
  %tmp = tail call i32 @llvm.fshr.i32(i32 %x, i32 %y, i32 %z)
  ret i32 %tmp
}

define i32 @var_shift_i32_pgso(i32 %x, i32 %y, i32 %z) nounwind !prof !14 {
; X86-LABEL: var_shift_i32_pgso:
; X86:       # %bb.0:
; X86-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X86-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    shrdl %cl, %edx, %eax
; X86-NEXT:    retl
;
; X64-LABEL: var_shift_i32_pgso:
; X64:       # %bb.0:
; X64-NEXT:    movl %edx, %ecx
; X64-NEXT:    movl %esi, %eax
; X64-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-NEXT:    shrdl %cl, %edi, %eax
; X64-NEXT:    retq
  %tmp = tail call i32 @llvm.fshr.i32(i32 %x, i32 %y, i32 %z)
  ret i32 %tmp
}

define i64 @var_shift_i64(i64 %x, i64 %y, i64 %z) nounwind {
; X86-FAST-LABEL: var_shift_i64:
; X86-FAST:       # %bb.0:
; X86-FAST-NEXT:    pushl %ebp
; X86-FAST-NEXT:    pushl %ebx
; X86-FAST-NEXT:    pushl %edi
; X86-FAST-NEXT:    pushl %esi
; X86-FAST-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-FAST-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; X86-FAST-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-FAST-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-FAST-NEXT:    movb {{[0-9]+}}(%esp), %bl
; X86-FAST-NEXT:    movb %bl, %ch
; X86-FAST-NEXT:    notb %ch
; X86-FAST-NEXT:    shldl $1, %eax, %edx
; X86-FAST-NEXT:    addl %eax, %eax
; X86-FAST-NEXT:    movb %ch, %cl
; X86-FAST-NEXT:    shldl %cl, %eax, %edx
; X86-FAST-NEXT:    movl %ebp, %edi
; X86-FAST-NEXT:    movb %bl, %cl
; X86-FAST-NEXT:    shrl %cl, %edi
; X86-FAST-NEXT:    shrdl %cl, %ebp, %esi
; X86-FAST-NEXT:    testb $32, %bl
; X86-FAST-NEXT:    je .LBB5_2
; X86-FAST-NEXT:  # %bb.1:
; X86-FAST-NEXT:    movl %edi, %esi
; X86-FAST-NEXT:    xorl %edi, %edi
; X86-FAST-NEXT:  .LBB5_2:
; X86-FAST-NEXT:    movb %ch, %cl
; X86-FAST-NEXT:    shll %cl, %eax
; X86-FAST-NEXT:    testb $32, %ch
; X86-FAST-NEXT:    je .LBB5_4
; X86-FAST-NEXT:  # %bb.3:
; X86-FAST-NEXT:    movl %eax, %edx
; X86-FAST-NEXT:    xorl %eax, %eax
; X86-FAST-NEXT:  .LBB5_4:
; X86-FAST-NEXT:    orl %edi, %edx
; X86-FAST-NEXT:    orl %esi, %eax
; X86-FAST-NEXT:    popl %esi
; X86-FAST-NEXT:    popl %edi
; X86-FAST-NEXT:    popl %ebx
; X86-FAST-NEXT:    popl %ebp
; X86-FAST-NEXT:    retl
;
; X86-SLOW-LABEL: var_shift_i64:
; X86-SLOW:       # %bb.0:
; X86-SLOW-NEXT:    pushl %ebp
; X86-SLOW-NEXT:    pushl %ebx
; X86-SLOW-NEXT:    pushl %edi
; X86-SLOW-NEXT:    pushl %esi
; X86-SLOW-NEXT:    pushl %eax
; X86-SLOW-NEXT:    movl {{[0-9]+}}(%esp), %ebp
; X86-SLOW-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-SLOW-NEXT:    movb {{[0-9]+}}(%esp), %bl
; X86-SLOW-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SLOW-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-SLOW-NEXT:    movl %eax, %edi
; X86-SLOW-NEXT:    andl $2147483647, %edi # imm = 0x7FFFFFFF
; X86-SLOW-NEXT:    movl %ebx, %ecx
; X86-SLOW-NEXT:    shrl %cl, %edi
; X86-SLOW-NEXT:    movl %eax, %ecx
; X86-SLOW-NEXT:    shrl $31, %ecx
; X86-SLOW-NEXT:    leal (%ecx,%edx,2), %edx
; X86-SLOW-NEXT:    movb %bl, %ch
; X86-SLOW-NEXT:    notb %ch
; X86-SLOW-NEXT:    movb %ch, %cl
; X86-SLOW-NEXT:    shll %cl, %edx
; X86-SLOW-NEXT:    movb %bl, %cl
; X86-SLOW-NEXT:    shrl %cl, %ebp
; X86-SLOW-NEXT:    movl %ebp, (%esp) # 4-byte Spill
; X86-SLOW-NEXT:    leal (%esi,%esi), %ebp
; X86-SLOW-NEXT:    movb %ch, %cl
; X86-SLOW-NEXT:    shll %cl, %ebp
; X86-SLOW-NEXT:    movb %bl, %cl
; X86-SLOW-NEXT:    shrl %cl, %esi
; X86-SLOW-NEXT:    testb $32, %bl
; X86-SLOW-NEXT:    jne .LBB5_1
; X86-SLOW-NEXT:  # %bb.2:
; X86-SLOW-NEXT:    orl (%esp), %ebp # 4-byte Folded Reload
; X86-SLOW-NEXT:    jmp .LBB5_3
; X86-SLOW-NEXT:  .LBB5_1:
; X86-SLOW-NEXT:    movl %esi, %ebp
; X86-SLOW-NEXT:    xorl %esi, %esi
; X86-SLOW-NEXT:  .LBB5_3:
; X86-SLOW-NEXT:    addl %eax, %eax
; X86-SLOW-NEXT:    movb %ch, %cl
; X86-SLOW-NEXT:    shll %cl, %eax
; X86-SLOW-NEXT:    testb $32, %ch
; X86-SLOW-NEXT:    jne .LBB5_4
; X86-SLOW-NEXT:  # %bb.5:
; X86-SLOW-NEXT:    orl %edi, %edx
; X86-SLOW-NEXT:    jmp .LBB5_6
; X86-SLOW-NEXT:  .LBB5_4:
; X86-SLOW-NEXT:    movl %eax, %edx
; X86-SLOW-NEXT:    xorl %eax, %eax
; X86-SLOW-NEXT:  .LBB5_6:
; X86-SLOW-NEXT:    orl %esi, %edx
; X86-SLOW-NEXT:    orl %ebp, %eax
; X86-SLOW-NEXT:    addl $4, %esp
; X86-SLOW-NEXT:    popl %esi
; X86-SLOW-NEXT:    popl %edi
; X86-SLOW-NEXT:    popl %ebx
; X86-SLOW-NEXT:    popl %ebp
; X86-SLOW-NEXT:    retl
;
; X64-FAST-LABEL: var_shift_i64:
; X64-FAST:       # %bb.0:
; X64-FAST-NEXT:    movq %rdx, %rcx
; X64-FAST-NEXT:    movq %rsi, %rax
; X64-FAST-NEXT:    # kill: def $cl killed $cl killed $rcx
; X64-FAST-NEXT:    shrdq %cl, %rdi, %rax
; X64-FAST-NEXT:    retq
;
; X64-SLOW-LABEL: var_shift_i64:
; X64-SLOW:       # %bb.0:
; X64-SLOW-NEXT:    movq %rdx, %rcx
; X64-SLOW-NEXT:    shrq %cl, %rsi
; X64-SLOW-NEXT:    leaq (%rdi,%rdi), %rax
; X64-SLOW-NEXT:    notb %cl
; X64-SLOW-NEXT:    # kill: def $cl killed $cl killed $rcx
; X64-SLOW-NEXT:    shlq %cl, %rax
; X64-SLOW-NEXT:    orq %rsi, %rax
; X64-SLOW-NEXT:    retq
  %tmp = tail call i64 @llvm.fshr.i64(i64 %x, i64 %y, i64 %z)
  ret i64 %tmp
}

;
; Const Funnel Shift
;

define i8 @const_shift_i8(i8 %x, i8 %y) nounwind {
; X86-LABEL: const_shift_i8:
; X86:       # %bb.0:
; X86-NEXT:    movb {{[0-9]+}}(%esp), %al
; X86-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X86-NEXT:    shrb $7, %cl
; X86-NEXT:    addb %al, %al
; X86-NEXT:    orb %cl, %al
; X86-NEXT:    retl
;
; X64-LABEL: const_shift_i8:
; X64:       # %bb.0:
; X64-NEXT:    # kill: def $edi killed $edi def $rdi
; X64-NEXT:    shrb $7, %sil
; X64-NEXT:    leal (%rdi,%rdi), %eax
; X64-NEXT:    orb %sil, %al
; X64-NEXT:    # kill: def $al killed $al killed $eax
; X64-NEXT:    retq
  %tmp = tail call i8 @llvm.fshr.i8(i8 %x, i8 %y, i8 7)
  ret i8 %tmp
}

define i16 @const_shift_i16(i16 %x, i16 %y) nounwind {
; X86-FAST-LABEL: const_shift_i16:
; X86-FAST:       # %bb.0:
; X86-FAST-NEXT:    movzwl {{[0-9]+}}(%esp), %ecx
; X86-FAST-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X86-FAST-NEXT:    shrdw $7, %cx, %ax
; X86-FAST-NEXT:    retl
;
; X86-SLOW-LABEL: const_shift_i16:
; X86-SLOW:       # %bb.0:
; X86-SLOW-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SLOW-NEXT:    movzwl {{[0-9]+}}(%esp), %ecx
; X86-SLOW-NEXT:    shrl $7, %ecx
; X86-SLOW-NEXT:    shll $9, %eax
; X86-SLOW-NEXT:    orl %ecx, %eax
; X86-SLOW-NEXT:    # kill: def $ax killed $ax killed $eax
; X86-SLOW-NEXT:    retl
;
; X64-FAST-LABEL: const_shift_i16:
; X64-FAST:       # %bb.0:
; X64-FAST-NEXT:    movl %esi, %eax
; X64-FAST-NEXT:    shrdw $7, %di, %ax
; X64-FAST-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-FAST-NEXT:    retq
;
; X64-SLOW-LABEL: const_shift_i16:
; X64-SLOW:       # %bb.0:
; X64-SLOW-NEXT:    movzwl %si, %eax
; X64-SLOW-NEXT:    shll $9, %edi
; X64-SLOW-NEXT:    shrl $7, %eax
; X64-SLOW-NEXT:    orl %edi, %eax
; X64-SLOW-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-SLOW-NEXT:    retq
  %tmp = tail call i16 @llvm.fshr.i16(i16 %x, i16 %y, i16 7)
  ret i16 %tmp
}

define i32 @const_shift_i32(i32 %x, i32 %y) nounwind {
; X86-FAST-LABEL: const_shift_i32:
; X86-FAST:       # %bb.0:
; X86-FAST-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-FAST-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-FAST-NEXT:    shrdl $7, %ecx, %eax
; X86-FAST-NEXT:    retl
;
; X86-SLOW-LABEL: const_shift_i32:
; X86-SLOW:       # %bb.0:
; X86-SLOW-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-SLOW-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-SLOW-NEXT:    shrl $7, %ecx
; X86-SLOW-NEXT:    shll $25, %eax
; X86-SLOW-NEXT:    orl %ecx, %eax
; X86-SLOW-NEXT:    retl
;
; X64-FAST-LABEL: const_shift_i32:
; X64-FAST:       # %bb.0:
; X64-FAST-NEXT:    movl %edi, %eax
; X64-FAST-NEXT:    shldl $25, %esi, %eax
; X64-FAST-NEXT:    retq
;
; X64-SLOW-LABEL: const_shift_i32:
; X64-SLOW:       # %bb.0:
; X64-SLOW-NEXT:    # kill: def $esi killed $esi def $rsi
; X64-SLOW-NEXT:    # kill: def $edi killed $edi def $rdi
; X64-SLOW-NEXT:    shrl $7, %esi
; X64-SLOW-NEXT:    shll $25, %edi
; X64-SLOW-NEXT:    leal (%rdi,%rsi), %eax
; X64-SLOW-NEXT:    retq
  %tmp = tail call i32 @llvm.fshr.i32(i32 %x, i32 %y, i32 7)
  ret i32 %tmp
}

define i64 @const_shift_i64(i64 %x, i64 %y) nounwind {
; X86-FAST-LABEL: const_shift_i64:
; X86-FAST:       # %bb.0:
; X86-FAST-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-FAST-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-FAST-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-FAST-NEXT:    shldl $25, %ecx, %edx
; X86-FAST-NEXT:    shrdl $7, %ecx, %eax
; X86-FAST-NEXT:    retl
;
; X86-SLOW-LABEL: const_shift_i64:
; X86-SLOW:       # %bb.0:
; X86-SLOW-NEXT:    pushl %esi
; X86-SLOW-NEXT:    movl {{[0-9]+}}(%esp), %edx
; X86-SLOW-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-SLOW-NEXT:    movl {{[0-9]+}}(%esp), %esi
; X86-SLOW-NEXT:    shrl $7, %ecx
; X86-SLOW-NEXT:    movl %esi, %eax
; X86-SLOW-NEXT:    shll $25, %eax
; X86-SLOW-NEXT:    orl %ecx, %eax
; X86-SLOW-NEXT:    shrl $7, %esi
; X86-SLOW-NEXT:    shll $25, %edx
; X86-SLOW-NEXT:    orl %esi, %edx
; X86-SLOW-NEXT:    popl %esi
; X86-SLOW-NEXT:    retl
;
; X64-FAST-LABEL: const_shift_i64:
; X64-FAST:       # %bb.0:
; X64-FAST-NEXT:    movq %rdi, %rax
; X64-FAST-NEXT:    shldq $57, %rsi, %rax
; X64-FAST-NEXT:    retq
;
; X64-SLOW-LABEL: const_shift_i64:
; X64-SLOW:       # %bb.0:
; X64-SLOW-NEXT:    shrq $7, %rsi
; X64-SLOW-NEXT:    shlq $57, %rdi
; X64-SLOW-NEXT:    leaq (%rdi,%rsi), %rax
; X64-SLOW-NEXT:    retq
  %tmp = tail call i64 @llvm.fshr.i64(i64 %x, i64 %y, i64 7)
  ret i64 %tmp
}

;
; Combine Consecutive Loads
;

define i8 @combine_fshr_load_i8(i8* %p) nounwind {
; X86-LABEL: combine_fshr_load_i8:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movb (%eax), %al
; X86-NEXT:    retl
;
; X64-LABEL: combine_fshr_load_i8:
; X64:       # %bb.0:
; X64-NEXT:    movb (%rdi), %al
; X64-NEXT:    retq
  %p1 = getelementptr i8, i8* %p, i32 1
  %ld0 = load i8, i8 *%p
  %ld1 = load i8, i8 *%p1
  %res = call i8 @llvm.fshr.i8(i8 %ld1, i8 %ld0, i8 8)
  ret i8 %res
}

define i16 @combine_fshr_load_i16(i16* %p) nounwind {
; X86-LABEL: combine_fshr_load_i16:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movzwl 1(%eax), %eax
; X86-NEXT:    retl
;
; X64-LABEL: combine_fshr_load_i16:
; X64:       # %bb.0:
; X64-NEXT:    movzwl 1(%rdi), %eax
; X64-NEXT:    retq
  %p0 = getelementptr i16, i16* %p, i32 0
  %p1 = getelementptr i16, i16* %p, i32 1
  %ld0 = load i16, i16 *%p0
  %ld1 = load i16, i16 *%p1
  %res = call i16 @llvm.fshr.i16(i16 %ld1, i16 %ld0, i16 8)
  ret i16 %res
}

define i32 @combine_fshr_load_i32(i32* %p) nounwind {
; X86-LABEL: combine_fshr_load_i32:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %eax
; X86-NEXT:    movl 9(%eax), %eax
; X86-NEXT:    retl
;
; X64-LABEL: combine_fshr_load_i32:
; X64:       # %bb.0:
; X64-NEXT:    movl 9(%rdi), %eax
; X64-NEXT:    retq
  %p0 = getelementptr i32, i32* %p, i32 2
  %p1 = getelementptr i32, i32* %p, i32 3
  %ld0 = load i32, i32 *%p0
  %ld1 = load i32, i32 *%p1
  %res = call i32 @llvm.fshr.i32(i32 %ld1, i32 %ld0, i32 8)
  ret i32 %res
}

define i64 @combine_fshr_load_i64(i64* %p) nounwind {
; X86-LABEL: combine_fshr_load_i64:
; X86:       # %bb.0:
; X86-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; X86-NEXT:    movl 11(%ecx), %eax
; X86-NEXT:    movl 15(%ecx), %edx
; X86-NEXT:    retl
;
; X64-LABEL: combine_fshr_load_i64:
; X64:       # %bb.0:
; X64-NEXT:    movq 11(%rdi), %rax
; X64-NEXT:    retq
  %p0 = getelementptr i64, i64* %p, i64 1
  %p1 = getelementptr i64, i64* %p, i64 2
  %ld0 = load i64, i64 *%p0
  %ld1 = load i64, i64 *%p1
  %res = call i64 @llvm.fshr.i64(i64 %ld1, i64 %ld0, i64 24)
  ret i64 %res
}

!llvm.module.flags = !{!0}
!0 = !{i32 1, !"ProfileSummary", !1}
!1 = !{!2, !3, !4, !5, !6, !7, !8, !9}
!2 = !{!"ProfileFormat", !"InstrProf"}
!3 = !{!"TotalCount", i64 10000}
!4 = !{!"MaxCount", i64 10}
!5 = !{!"MaxInternalCount", i64 1}
!6 = !{!"MaxFunctionCount", i64 1000}
!7 = !{!"NumCounts", i64 3}
!8 = !{!"NumFunctions", i64 3}
!9 = !{!"DetailedSummary", !10}
!10 = !{!11, !12, !13}
!11 = !{i32 10000, i64 100, i32 1}
!12 = !{i32 999000, i64 100, i32 1}
!13 = !{i32 999999, i64 1, i32 2}
!14 = !{!"function_entry_count", i64 0}
