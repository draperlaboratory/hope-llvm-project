; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -ppc-asm-full-reg-names -verify-machineinstrs -mtriple=powerpc64 \
; RUN:   < %s | FileCheck --check-prefix=BE %s
; RUN: llc -ppc-asm-full-reg-names -verify-machineinstrs -mtriple=powerpc64le \
; RUN:   < %s | FileCheck --check-prefix=LE %s

define i32 @f(...) nounwind {
; BE-LABEL: f:
; BE:       # %bb.0: # %entry
; BE-NEXT:    li r3, 0
; BE-NEXT:    blr
;
; LE-LABEL: f:
; LE:       # %bb.0: # %entry
; LE-NEXT:    li r3, 0
; LE-NEXT:    blr
entry:
  ret i32 0
}

define i32 @f1(...) nounwind {
; BE-LABEL: f1:
; BE:       # %bb.0: # %entry
; BE-NEXT:    mr r11, r3
; BE-NEXT:    addi r12, r1, 48
; BE-NEXT:    li r3, 0
; BE-NEXT:    std r11, 48(r1)
; BE-NEXT:    std r4, 56(r1)
; BE-NEXT:    std r5, 64(r1)
; BE-NEXT:    std r6, 72(r1)
; BE-NEXT:    std r7, 80(r1)
; BE-NEXT:    std r8, 88(r1)
; BE-NEXT:    std r9, 96(r1)
; BE-NEXT:    std r10, 104(r1)
; BE-NEXT:    std r12, -8(r1)
; BE-NEXT:    blr
;
; LE-LABEL: f1:
; LE:       # %bb.0: # %entry
; LE-NEXT:    std r3, 32(r1)
; LE-NEXT:    std r4, 40(r1)
; LE-NEXT:    addi r4, r1, 32
; LE-NEXT:    li r3, 0
; LE-NEXT:    std r5, 48(r1)
; LE-NEXT:    std r6, 56(r1)
; LE-NEXT:    std r7, 64(r1)
; LE-NEXT:    std r8, 72(r1)
; LE-NEXT:    std r9, 80(r1)
; LE-NEXT:    std r10, 88(r1)
; LE-NEXT:    std r4, -8(r1)
; LE-NEXT:    blr
entry:
  %va = alloca i8*, align 8
  %va.cast = bitcast i8** %va to i8*
  call void @llvm.va_start(i8* %va.cast)
  ret i32 0
}

declare void @llvm.va_start(i8*) nounwind
