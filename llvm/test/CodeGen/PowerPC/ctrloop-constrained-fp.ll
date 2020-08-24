; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple powerpc64le < %s | FileCheck %s

; Check constrained ops converted to call
define void @test(double* %cast) {
; CHECK-LABEL: test:
; CHECK:       # %bb.0: # %root
; CHECK-NEXT:    mflr 0
; CHECK-NEXT:    .cfi_def_cfa_offset 64
; CHECK-NEXT:    .cfi_offset lr, 16
; CHECK-NEXT:    .cfi_offset r29, -24
; CHECK-NEXT:    .cfi_offset r30, -16
; CHECK-NEXT:    std 29, -24(1) # 8-byte Folded Spill
; CHECK-NEXT:    std 30, -16(1) # 8-byte Folded Spill
; CHECK-NEXT:    std 0, 16(1)
; CHECK-NEXT:    stdu 1, -64(1)
; CHECK-NEXT:    li 30, 0
; CHECK-NEXT:    addi 29, 3, -8
; CHECK-NEXT:    .p2align 5
; CHECK-NEXT:  .LBB0_1: # %for.body
; CHECK-NEXT:    #
; CHECK-NEXT:    lfdu 1, 8(29)
; CHECK-NEXT:    bl cos
; CHECK-NEXT:    nop
; CHECK-NEXT:    addi 30, 30, 8
; CHECK-NEXT:    stfdx 1, 0, 29
; CHECK-NEXT:    cmpldi 30, 2040
; CHECK-NEXT:    bne 0, .LBB0_1
; CHECK-NEXT:  # %bb.2: # %exit
; CHECK-NEXT:    addi 1, 1, 64
; CHECK-NEXT:    ld 0, 16(1)
; CHECK-NEXT:    ld 30, -16(1) # 8-byte Folded Reload
; CHECK-NEXT:    ld 29, -24(1) # 8-byte Folded Reload
; CHECK-NEXT:    mtlr 0
; CHECK-NEXT:    blr
root:
  br label %for.body

exit:
  ret void

for.body:
  %i = phi i64 [ 0, %root ], [ %next, %for.body ]
  %idx = getelementptr inbounds double, double* %cast, i64 %i
  %val = load double, double* %idx
  %cos = tail call nnan ninf nsz arcp double @llvm.experimental.constrained.cos.f64(double %val, metadata !"round.dynamic", metadata !"fpexcept.strict")
  store double %cos, double* %idx, align 8
  %next = add nuw nsw i64 %i, 1
  %cond = icmp eq i64 %next, 255
  br i1 %cond, label %exit, label %for.body
}

; Check constrained ops converted to native instruction
define void @test2(double* %cast) {
; CHECK-LABEL: test2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    li 4, 255
; CHECK-NEXT:    addi 3, 3, -8
; CHECK-NEXT:    mtctr 4
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  .LBB1_1: # %for.body
; CHECK-NEXT:    #
; CHECK-NEXT:    lfdu 0, 8(3)
; CHECK-NEXT:    xssqrtdp 0, 0
; CHECK-NEXT:    stfdx 0, 0, 3
; CHECK-NEXT:    bdnz .LBB1_1
; CHECK-NEXT:  # %bb.2: # %exit
; CHECK-NEXT:    blr
entry:
  br label %for.body

for.body:
  %i = phi i64 [ 0, %entry ], [ %next, %for.body ]
  %idx = getelementptr inbounds double, double* %cast, i64 %i
  %val = load double, double* %idx
  %cos = tail call nnan ninf nsz arcp double @llvm.experimental.constrained.sqrt.f64(double %val, metadata !"round.dynamic", metadata !"fpexcept.strict")
  store double %cos, double* %idx, align 8
  %next = add nuw nsw i64 %i, 1
  %cond = icmp eq i64 %next, 255
  br i1 %cond, label %exit, label %for.body

exit:
  ret void
}

declare double @llvm.experimental.constrained.cos.f64(double, metadata, metadata)
declare double @llvm.experimental.constrained.sqrt.f64(double, metadata, metadata)
