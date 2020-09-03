; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -ipsccp < %s | FileCheck %s

declare void @BB0_f()
declare void @BB1_f()

; Make sure we can eliminate what is in BB0 as we know that the indirectbr is going to BB1.
;
define void @indbrtest1() {
; CHECK-LABEL: @indbrtest1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[BB1:%.*]]
; CHECK:       BB1:
; CHECK-NEXT:    call void @BB1_f()
; CHECK-NEXT:    ret void
;
entry:
  indirectbr i8* blockaddress(@indbrtest1, %BB1), [label %BB0, label %BB1]
BB0:
  call void @BB0_f()
  br label %BB1
BB1:
  call void @BB1_f()
  ret void
}

; Make sure we can eliminate what is in BB0 as we know that the indirectbr is going to BB1
; by looking through the casts. The casts should be folded away when they are visited
; before the indirectbr instruction.
;
define void @indbrtest2() {
; CHECK-LABEL: @indbrtest2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[B:%.*]] = inttoptr i64 ptrtoint (i8* blockaddress(@indbrtest2, [[BB1:%.*]]) to i64) to i8*
; CHECK-NEXT:    [[C:%.*]] = bitcast i8* [[B]] to i8*
; CHECK-NEXT:    br label [[BB1]]
; CHECK:       BB1:
; CHECK-NEXT:    call void @BB1_f()
; CHECK-NEXT:    ret void
;
entry:
  %a = ptrtoint i8* blockaddress(@indbrtest2, %BB1) to i64
  %b = inttoptr i64 %a to i8*
  %c = bitcast i8* %b to i8*
  indirectbr i8* %b, [label %BB0, label %BB1]
BB0:
  call void @BB0_f()
  br label %BB1
BB1:
  call void @BB1_f()
  ret void
}

; Make sure we can not eliminate BB0 as we do not know the target of the indirectbr.

define void @indbrtest3(i8** %Q) {
; CHECK-LABEL: @indbrtest3(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[T:%.*]] = load i8*, i8** [[Q:%.*]], align 8
; CHECK-NEXT:    indirectbr i8* [[T]], [label [[BB0:%.*]], label %BB1]
; CHECK:       BB0:
; CHECK-NEXT:    call void @BB0_f()
; CHECK-NEXT:    br label [[BB1:%.*]]
; CHECK:       BB1:
; CHECK-NEXT:    call void @BB1_f()
; CHECK-NEXT:    ret void
;
entry:
  %t = load i8*, i8** %Q
  indirectbr i8* %t, [label %BB0, label %BB1]
BB0:
  call void @BB0_f()
  br label %BB1
BB1:
  call void @BB1_f()
  ret void
}

; Make sure we eliminate BB1 as we pick the first successor on undef.

define void @indbrtest4(i8** %Q) {
; CHECK-LABEL: @indbrtest4(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[BB0:%.*]]
; CHECK:       BB0:
; CHECK-NEXT:    call void @BB0_f()
; CHECK-NEXT:    ret void
;
entry:
  indirectbr i8* undef, [label %BB0, label %BB1]
BB0:
  call void @BB0_f()
  ret void
BB1:
  call void @BB1_f()
  ret void
}

define internal i32 @indbrtest5(i1 %c) {
; CHECK-LABEL: @indbrtest5(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[C:%.*]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    br label [[BRANCH_BLOCK:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    br label [[BRANCH_BLOCK]]
; CHECK:       branch.block:
; CHECK-NEXT:    [[ADDR:%.*]] = phi i8* [ blockaddress(@indbrtest5, [[TARGET1:%.*]]), [[BB1]] ], [ blockaddress(@indbrtest5, [[TARGET2:%.*]]), [[BB2]] ]
; CHECK-NEXT:    indirectbr i8* [[ADDR]], [label [[TARGET1]], label %target2]
; CHECK:       target1:
; CHECK-NEXT:    br label [[TARGET2]]
; CHECK:       target2:
; CHECK-NEXT:    ret i32 undef
;
entry:
  br i1 %c, label %bb1, label %bb2

bb1:
  br label %branch.block


bb2:
  br label %branch.block

branch.block:
  %addr = phi i8* [blockaddress(@indbrtest5, %target1), %bb1], [blockaddress(@indbrtest5, %target2), %bb2]
  indirectbr i8* %addr, [label %target1, label %target2]

target1:
  br label %target2

target2:
  ret i32 10
}


define i32 @indbrtest5_callee(i1 %c) {
; CHECK-LABEL: @indbrtest5_callee(
; CHECK-NEXT:    [[R:%.*]] = call i32 @indbrtest5(i1 [[C:%.*]])
; CHECK-NEXT:    ret i32 10
;
  %r = call i32 @indbrtest5(i1 %c)
  ret i32 %r
}

define i32 @indbr_duplicate_successors_phi(i1 %c, i32 %x) {
; CHECK-LABEL: @indbr_duplicate_successors_phi(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[C:%.*]], label [[INDBR:%.*]], label [[BB0:%.*]]
; CHECK:       indbr:
; CHECK-NEXT:    br label [[BB0]]
; CHECK:       BB0:
; CHECK-NEXT:    [[PHI:%.*]] = phi i32 [ [[X:%.*]], [[ENTRY:%.*]] ], [ 0, [[INDBR]] ]
; CHECK-NEXT:    ret i32 [[PHI]]
;
entry:
  br i1 %c, label %indbr, label %BB0

indbr:
  indirectbr i8* blockaddress(@indbr_duplicate_successors_phi, %BB0), [label %BB0, label %BB0, label %BB1]

BB0:
  %phi = phi i32 [ %x, %entry ], [ 0, %indbr ], [ 0, %indbr ]
  ret i32 %phi

BB1:
  ret i32 0
}
