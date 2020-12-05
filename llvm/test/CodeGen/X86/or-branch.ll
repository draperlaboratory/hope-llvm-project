; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i386-unknown-unknown -jump-is-expensive=0 | FileCheck %s --check-prefix=JUMP2
; RUN: llc < %s -mtriple=i386-unknown-unknown -jump-is-expensive=1 | FileCheck %s --check-prefix=JUMP1

define void @foo(i32 %X, i32 %Y, i32 %Z) nounwind {
; JUMP2-LABEL: foo:
; JUMP2:       # %bb.0: # %entry
; JUMP2-NEXT:    cmpl $5, {{[0-9]+}}(%esp)
; JUMP2-NEXT:    jl .LBB0_3
; JUMP2-NEXT:  # %bb.1: # %entry
; JUMP2-NEXT:    cmpl $0, {{[0-9]+}}(%esp)
; JUMP2-NEXT:    je .LBB0_3
; JUMP2-NEXT:  # %bb.2: # %UnifiedReturnBlock
; JUMP2-NEXT:    retl
; JUMP2-NEXT:  .LBB0_3: # %cond_true
; JUMP2-NEXT:    jmp bar@PLT # TAILCALL
;
; JUMP1-LABEL: foo:
; JUMP1:       # %bb.0: # %entry
; JUMP1-NEXT:    cmpl $0, {{[0-9]+}}(%esp)
; JUMP1-NEXT:    setne %al
; JUMP1-NEXT:    cmpl $4, {{[0-9]+}}(%esp)
; JUMP1-NEXT:    setg %cl
; JUMP1-NEXT:    testb %al, %cl
; JUMP1-NEXT:    jne .LBB0_1
; JUMP1-NEXT:  # %bb.2: # %cond_true
; JUMP1-NEXT:    jmp bar@PLT # TAILCALL
; JUMP1-NEXT:  .LBB0_1: # %UnifiedReturnBlock
; JUMP1-NEXT:    retl
entry:
  %tmp1 = icmp eq i32 %X, 0
  %tmp3 = icmp slt i32 %Y, 5
  %tmp4 = or i1 %tmp3, %tmp1
  br i1 %tmp4, label %cond_true, label %UnifiedReturnBlock

cond_true:
  %tmp5 = tail call i32 (...) @bar( )
  ret void

UnifiedReturnBlock:
  ret void
}

; If the branch is unpredictable, don't add another branch
; regardless of whether they are expensive or not.

define void @unpredictable(i32 %X, i32 %Y, i32 %Z) nounwind {
; JUMP2-LABEL: unpredictable:
; JUMP2:       # %bb.0: # %entry
; JUMP2-NEXT:    cmpl $0, {{[0-9]+}}(%esp)
; JUMP2-NEXT:    setne %al
; JUMP2-NEXT:    cmpl $4, {{[0-9]+}}(%esp)
; JUMP2-NEXT:    setg %cl
; JUMP2-NEXT:    testb %al, %cl
; JUMP2-NEXT:    jne .LBB1_1
; JUMP2-NEXT:  # %bb.2: # %cond_true
; JUMP2-NEXT:    jmp bar@PLT # TAILCALL
; JUMP2-NEXT:  .LBB1_1: # %UnifiedReturnBlock
; JUMP2-NEXT:    retl
;
; JUMP1-LABEL: unpredictable:
; JUMP1:       # %bb.0: # %entry
; JUMP1-NEXT:    cmpl $0, {{[0-9]+}}(%esp)
; JUMP1-NEXT:    setne %al
; JUMP1-NEXT:    cmpl $4, {{[0-9]+}}(%esp)
; JUMP1-NEXT:    setg %cl
; JUMP1-NEXT:    testb %al, %cl
; JUMP1-NEXT:    jne .LBB1_1
; JUMP1-NEXT:  # %bb.2: # %cond_true
; JUMP1-NEXT:    jmp bar@PLT # TAILCALL
; JUMP1-NEXT:  .LBB1_1: # %UnifiedReturnBlock
; JUMP1-NEXT:    retl
entry:
  %tmp1 = icmp eq i32 %X, 0
  %tmp3 = icmp slt i32 %Y, 5
  %tmp4 = or i1 %tmp3, %tmp1
  br i1 %tmp4, label %cond_true, label %UnifiedReturnBlock, !unpredictable !0

cond_true:
  %tmp5 = tail call i32 (...) @bar( )
  ret void

UnifiedReturnBlock:
  ret void
}

declare i32 @bar(...)

!0 = !{}

