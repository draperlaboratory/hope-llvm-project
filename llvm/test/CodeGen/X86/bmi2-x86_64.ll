; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+bmi,+bmi2 | FileCheck %s --check-prefixes=CHECK

define i64 @bzhi64(i64 %x, i64 %y)   {
; CHECK-LABEL: bzhi64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    bzhiq %rsi, %rdi, %rax
; CHECK-NEXT:    retq
  %tmp = tail call i64 @llvm.x86.bmi.bzhi.64(i64 %x, i64 %y)
  ret i64 %tmp
}

define i64 @bzhi64_load(i64* %x, i64 %y)   {
; CHECK-LABEL: bzhi64_load:
; CHECK:       # %bb.0:
; CHECK-NEXT:    bzhiq %rsi, (%rdi), %rax
; CHECK-NEXT:    retq
  %x1 = load i64, i64* %x
  %tmp = tail call i64 @llvm.x86.bmi.bzhi.64(i64 %x1, i64 %y)
  ret i64 %tmp
}

declare i64 @llvm.x86.bmi.bzhi.64(i64, i64)

define i64 @pdep64(i64 %x, i64 %y)   {
; CHECK-LABEL: pdep64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pdepq %rsi, %rdi, %rax
; CHECK-NEXT:    retq
  %tmp = tail call i64 @llvm.x86.bmi.pdep.64(i64 %x, i64 %y)
  ret i64 %tmp
}

define i64 @pdep64_load(i64 %x, i64* %y)   {
; CHECK-LABEL: pdep64_load:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pdepq (%rsi), %rdi, %rax
; CHECK-NEXT:    retq
  %y1 = load i64, i64* %y
  %tmp = tail call i64 @llvm.x86.bmi.pdep.64(i64 %x, i64 %y1)
  ret i64 %tmp
}

define i64 @pdep64_anyext(i32 %x)   {
; CHECK-LABEL: pdep64_anyext:
; CHECK:       # %bb.0:
; CHECK-NEXT:    # kill: def $edi killed $edi def $rdi
; CHECK-NEXT:    movabsq $6148914691236517205, %rax # imm = 0x5555555555555555
; CHECK-NEXT:    pdepq %rax, %rdi, %rax
; CHECK-NEXT:    retq
  %x1 = sext i32 %x to i64
  %tmp = tail call i64 @llvm.x86.bmi.pdep.64(i64 %x1, i64 6148914691236517205)
  ret i64 %tmp
}

declare i64 @llvm.x86.bmi.pdep.64(i64, i64)

define i64 @pext64(i64 %x, i64 %y)   {
; CHECK-LABEL: pext64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pextq %rsi, %rdi, %rax
; CHECK-NEXT:    retq
  %tmp = tail call i64 @llvm.x86.bmi.pext.64(i64 %x, i64 %y)
  ret i64 %tmp
}

define i64 @pext64_load(i64 %x, i64* %y)   {
; CHECK-LABEL: pext64_load:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pextq (%rsi), %rdi, %rax
; CHECK-NEXT:    retq
  %y1 = load i64, i64* %y
  %tmp = tail call i64 @llvm.x86.bmi.pext.64(i64 %x, i64 %y1)
  ret i64 %tmp
}

define i64 @pext64_knownbits(i64 %x, i64 %y)   {
; CHECK-LABEL: pext64_knownbits:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movabsq $6148914691236517205, %rax # imm = 0x5555555555555555
; CHECK-NEXT:    pextq %rax, %rdi, %rax
; CHECK-NEXT:    movl %eax, %eax
; CHECK-NEXT:    retq
  %tmp = tail call i64 @llvm.x86.bmi.pext.64(i64 %x, i64 6148914691236517205)
  %tmp2 = and i64 %tmp, 4294967295
  ret i64 %tmp2
}

declare i64 @llvm.x86.bmi.pext.64(i64, i64)

define i64 @mulx64(i64 %x, i64 %y, i64* %p)   {
; CHECK-LABEL: mulx64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdx, %rcx
; CHECK-NEXT:    movq %rdi, %rdx
; CHECK-NEXT:    mulxq %rsi, %rax, %rdx
; CHECK-NEXT:    movq %rdx, (%rcx)
; CHECK-NEXT:    retq
  %x1 = zext i64 %x to i128
  %y1 = zext i64 %y to i128
  %r1 = mul i128 %x1, %y1
  %h1 = lshr i128 %r1, 64
  %h  = trunc i128 %h1 to i64
  %l  = trunc i128 %r1 to i64
  store i64 %h, i64* %p
  ret i64 %l
}

define i64 @mulx64_load(i64 %x, i64* %y, i64* %p)   {
; CHECK-LABEL: mulx64_load:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movq %rdx, %rcx
; CHECK-NEXT:    movq %rdi, %rdx
; CHECK-NEXT:    mulxq (%rsi), %rax, %rdx
; CHECK-NEXT:    movq %rdx, (%rcx)
; CHECK-NEXT:    retq
  %y1 = load i64, i64* %y
  %x2 = zext i64 %x to i128
  %y2 = zext i64 %y1 to i128
  %r1 = mul i128 %x2, %y2
  %h1 = lshr i128 %r1, 64
  %h  = trunc i128 %h1 to i64
  %l  = trunc i128 %r1 to i64
  store i64 %h, i64* %p
  ret i64 %l
}
