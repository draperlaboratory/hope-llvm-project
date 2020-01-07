; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -ppc-vsr-nums-as-vr -mtriple=powerpc64-unknown-linux-gnu \
; RUN:       -verify-machineinstrs -ppc-asm-full-reg-names -mcpu=pwr9 --ppc-enable-pipeliner \
; RUN:       | FileCheck %s

@x = dso_local local_unnamed_addr global <{ i32, i32, i32, i32, [1020 x i32] }> <{ i32 1, i32 2, i32 3, i32 4, [1020 x i32] zeroinitializer }>, align 4
@y = dso_local global [1024 x i32] zeroinitializer, align 4

define dso_local i32* @foo() local_unnamed_addr {
; CHECK-LABEL: foo:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addis r5, r2, x@toc@ha
; CHECK-NEXT:    addis r6, r2, y@toc@ha
; CHECK-NEXT:    li r7, 340
; CHECK-NEXT:    addi r5, r5, x@toc@l
; CHECK-NEXT:    addi r5, r5, -8
; CHECK-NEXT:    addi r3, r6, y@toc@l
; CHECK-NEXT:    lwz r6, y@toc@l(r6)
; CHECK-NEXT:    mtctr r7
; CHECK-NEXT:    addi r4, r3, -8
; CHECK-NEXT:    lwzu r7, 12(r5)
; CHECK-NEXT:    maddld r6, r7, r7, r6
; CHECK-NEXT:    lwz r7, 4(r5)
; CHECK-NEXT:    stwu r6, 12(r4)
; CHECK-NEXT:    maddld r6, r7, r7, r6
; CHECK-NEXT:    lwz r7, 8(r5)
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  .LBB0_1: # %for.body
; CHECK-NEXT:    #
; CHECK-NEXT:    maddld r7, r7, r7, r6
; CHECK-NEXT:    lwzu r8, 12(r5)
; CHECK-NEXT:    stw r6, 4(r4)
; CHECK-NEXT:    lwz r6, 4(r5)
; CHECK-NEXT:    maddld r8, r8, r8, r7
; CHECK-NEXT:    stw r7, 8(r4)
; CHECK-NEXT:    lwz r7, 8(r5)
; CHECK-NEXT:    maddld r6, r6, r6, r8
; CHECK-NEXT:    stwu r8, 12(r4)
; CHECK-NEXT:    bdnz .LBB0_1
; CHECK-NEXT:  # %bb.2:
; CHECK-NEXT:    maddld r5, r7, r7, r6
; CHECK-NEXT:    stw r6, 4(r4)
; CHECK-NEXT:    stw r5, 8(r4)
; CHECK-NEXT:    blr
entry:
  %.pre = load i32, i32* getelementptr inbounds ([1024 x i32], [1024 x i32]* @y, i64 0, i64 0), align 4
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body
  ret i32* getelementptr inbounds ([1024 x i32], [1024 x i32]* @y, i64 0, i64 0)

for.body:                                         ; preds = %for.body, %entry
  %0 = phi i32 [ %.pre, %entry ], [ %add.2, %for.body ]
  %indvars.iv = phi i64 [ 1, %entry ], [ %indvars.iv.next.2, %for.body ]
  %arrayidx2 = getelementptr inbounds [1024 x i32], [1024 x i32]* bitcast (<{ i32, i32, i32, i32, [1020 x i32] }>* @x to [1024 x i32]*), i64 0, i64 %indvars.iv
  %1 = load i32, i32* %arrayidx2, align 4
  %mul = mul nsw i32 %1, %1
  %add = add nsw i32 %mul, %0
  %arrayidx6 = getelementptr inbounds [1024 x i32], [1024 x i32]* @y, i64 0, i64 %indvars.iv
  store i32 %add, i32* %arrayidx6, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %arrayidx2.1 = getelementptr inbounds [1024 x i32], [1024 x i32]* bitcast (<{ i32, i32, i32, i32, [1020 x i32] }>* @x to [1024 x i32]*), i64 0, i64 %indvars.iv.next
  %2 = load i32, i32* %arrayidx2.1, align 4
  %mul.1 = mul nsw i32 %2, %2
  %add.1 = add nsw i32 %mul.1, %add
  %arrayidx6.1 = getelementptr inbounds [1024 x i32], [1024 x i32]* @y, i64 0, i64 %indvars.iv.next
  store i32 %add.1, i32* %arrayidx6.1, align 4
  %indvars.iv.next.1 = add nuw nsw i64 %indvars.iv, 2
  %arrayidx2.2 = getelementptr inbounds [1024 x i32], [1024 x i32]* bitcast (<{ i32, i32, i32, i32, [1020 x i32] }>* @x to [1024 x i32]*), i64 0, i64 %indvars.iv.next.1
  %3 = load i32, i32* %arrayidx2.2, align 4
  %mul.2 = mul nsw i32 %3, %3
  %add.2 = add nsw i32 %mul.2, %add.1
  %arrayidx6.2 = getelementptr inbounds [1024 x i32], [1024 x i32]* @y, i64 0, i64 %indvars.iv.next.1
  store i32 %add.2, i32* %arrayidx6.2, align 4
  %indvars.iv.next.2 = add nuw nsw i64 %indvars.iv, 3
  %exitcond.2 = icmp eq i64 %indvars.iv.next.2, 1024
  br i1 %exitcond.2, label %for.cond.cleanup, label %for.body
}
