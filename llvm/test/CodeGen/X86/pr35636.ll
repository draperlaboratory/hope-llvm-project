; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=haswell | FileCheck %s --check-prefix=HSW
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mcpu=znver1 | FileCheck %s --check-prefix=ZN

define void @_Z15uint64_to_asciimPc(i64 %arg) {
; HSW-LABEL: _Z15uint64_to_asciimPc:
; HSW:       # %bb.0: # %bb
; HSW-NEXT:    movabsq $811296384146066817, %rax # imm = 0xB424DC35095CD81
; HSW-NEXT:    movq %rdi, %rdx
; HSW-NEXT:    mulxq %rax, %rax, %rax
; HSW-NEXT:    shrq $42, %rax
; HSW-NEXT:    imulq $281474977, %rax, %rax # imm = 0x10C6F7A1
; HSW-NEXT:    shrq $20, %rax
; HSW-NEXT:    leal (%rax,%rax,4), %eax
; HSW-NEXT:    addl $5, %eax
; HSW-NEXT:    andl $134217727, %eax # imm = 0x7FFFFFF
; HSW-NEXT:    leal (%rax,%rax,4), %eax
; HSW-NEXT:    shrl $26, %eax
; HSW-NEXT:    orb $48, %al
; HSW-NEXT:    movb %al, (%rax)
; HSW-NEXT:    retq
;
; ZN-LABEL: _Z15uint64_to_asciimPc:
; ZN:       # %bb.0: # %bb
; ZN-NEXT:    movabsq $811296384146066817, %rax # imm = 0xB424DC35095CD81
; ZN-NEXT:    movq %rdi, %rdx
; ZN-NEXT:    mulxq %rax, %rax, %rax
; ZN-NEXT:    shrq $42, %rax
; ZN-NEXT:    imulq $281474977, %rax, %rax # imm = 0x10C6F7A1
; ZN-NEXT:    shrq $20, %rax
; ZN-NEXT:    leal 5(%rax,%rax,4), %eax
; ZN-NEXT:    andl $134217727, %eax # imm = 0x7FFFFFF
; ZN-NEXT:    leal (%rax,%rax,4), %eax
; ZN-NEXT:    shrl $26, %eax
; ZN-NEXT:    orb $48, %al
; ZN-NEXT:    movb %al, (%rax)
; ZN-NEXT:    retq
bb:
  %tmp = udiv i64 %arg, 100000000000000
  %tmp1 = mul nuw nsw i64 %tmp, 281474977
  %tmp2 = lshr i64 %tmp1, 20
  %tmp3 = trunc i64 %tmp2 to i32
  %tmp4 = add nuw nsw i32 %tmp3, 1
  %tmp5 = and i32 %tmp4, 268435455
  %tmp6 = mul nuw nsw i32 %tmp5, 5
  %tmp7 = and i32 %tmp6, 134217727
  %tmp8 = mul nuw nsw i32 %tmp7, 5
  %tmp9 = lshr i32 %tmp8, 26
  %tmp10 = trunc i32 %tmp9 to i8
  %tmp11 = or i8 %tmp10, 48
  store i8 %tmp11, i8* undef, align 1
  ret void
}
