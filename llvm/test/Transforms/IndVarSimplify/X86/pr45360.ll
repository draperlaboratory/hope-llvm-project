; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; TODO: Run under new PM after switch. The IR is the same but basic block labels are different.
; RUN: opt -S -O2 -scev-cheap-expansion-budget=1024 %s -enable-new-pm=0 | FileCheck %s

; See https://bugs.llvm.org/show_bug.cgi?id=45360
; This is reduced from that (runnable) test.
; The remainder operation is originally guarded, it never divides by zero.
; Indvars should not make it execute unconditionally.

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

@f = dso_local global i32 0, align 4
@a = dso_local global i32 0, align 4
@d = dso_local global i32 0, align 4
@c = dso_local global i32 0, align 4
@b = dso_local global i32 0, align 4
@e = dso_local global i32 0, align 4

define dso_local i32 @main() {
; CHECK-LABEL: @main(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[I6:%.*]] = load i32, i32* @a, align 4
; CHECK-NEXT:    [[I24:%.*]] = load i32, i32* @b, align 4
; CHECK-NEXT:    [[D_PROMOTED9:%.*]] = load i32, i32* @d, align 4
; CHECK-NEXT:    br label [[BB1:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    [[I8_LCSSA10:%.*]] = phi i32 [ [[D_PROMOTED9]], [[BB:%.*]] ], [ [[I8:%.*]], [[BB19_PREHEADER:%.*]] ]
; CHECK-NEXT:    [[I8]] = and i32 [[I8_LCSSA10]], [[I6]]
; CHECK-NEXT:    [[I21:%.*]] = icmp eq i32 [[I8]], 0
; CHECK-NEXT:    br i1 [[I21]], label [[BB13_PREHEADER_BB27_THREAD_SPLIT_CRIT_EDGE:%.*]], label [[BB19_PREHEADER]]
; CHECK:       bb19.preheader:
; CHECK-NEXT:    [[I26:%.*]] = urem i32 [[I24]], [[I8]]
; CHECK-NEXT:    store i32 [[I26]], i32* @e, align 4
; CHECK-NEXT:    [[I30_NOT:%.*]] = icmp eq i32 [[I26]], 0
; CHECK-NEXT:    br i1 [[I30_NOT]], label [[BB32_LOOPEXIT:%.*]], label [[BB1]]
; CHECK:       bb13.preheader.bb27.thread.split_crit_edge:
; CHECK-NEXT:    store i32 -1, i32* @f, align 4
; CHECK-NEXT:    store i32 0, i32* @d, align 4
; CHECK-NEXT:    store i32 0, i32* @c, align 4
; CHECK-NEXT:    br label [[BB32:%.*]]
; CHECK:       bb32.loopexit:
; CHECK-NEXT:    store i32 -1, i32* @f, align 4
; CHECK-NEXT:    store i32 [[I8]], i32* @d, align 4
; CHECK-NEXT:    br label [[BB32]]
; CHECK:       bb32:
; CHECK-NEXT:    [[C_SINK:%.*]] = phi i32* [ @c, [[BB32_LOOPEXIT]] ], [ @e, [[BB13_PREHEADER_BB27_THREAD_SPLIT_CRIT_EDGE]] ]
; CHECK-NEXT:    store i32 0, i32* [[C_SINK]], align 4
; CHECK-NEXT:    ret i32 0
;
bb:
  %i = alloca i32, align 4
  store i32 0, i32* %i, align 4
  br label %bb1

bb1:
  store i32 0, i32* @f, align 4
  br label %bb2

bb2:
  %i3 = load i32, i32* @f, align 4
  %i4 = icmp sge i32 %i3, 0
  br i1 %i4, label %bb5, label %bb12

bb5:
  %i6 = load i32, i32* @a, align 4
  %i7 = load i32, i32* @d, align 4
  %i8 = and i32 %i7, %i6
  store i32 %i8, i32* @d, align 4
  br label %bb9

bb9:
  %i10 = load i32, i32* @f, align 4
  %i11 = add nsw i32 %i10, -1
  store i32 %i11, i32* @f, align 4
  br label %bb2

bb12:
  store i32 0, i32* @c, align 4
  br label %bb13

bb13:
  %i14 = load i32, i32* @c, align 4
  %i15 = icmp sle i32 %i14, 0
  br i1 %i15, label %bb16, label %bb39

bb16:
  %i17 = load i32, i32* @f, align 4
  %i18 = icmp ne i32 %i17, 0
  br i1 %i18, label %bb19, label %bb34

bb19:
  %i20 = load i32, i32* @d, align 4
  %i21 = icmp eq i32 %i20, 0
  br i1 %i21, label %bb22, label %bb23

bb22:
  br label %bb27

bb23:
  %i24 = load i32, i32* @b, align 4
  %i25 = load i32, i32* @d, align 4
  %i26 = urem i32 %i24, %i25
  br label %bb27

bb27:
  %i28 = phi i32 [ 0, %bb22 ], [ %i26, %bb23 ]
  store i32 %i28, i32* @e, align 4
  %i29 = load i32, i32* @e, align 4
  %i30 = icmp ne i32 %i29, 0
  br i1 %i30, label %bb31, label %bb32

bb31:
  br label %bb33

bb32:
  ret i32 0

bb33:
  br label %bb35

bb34:
  store i32 0, i32* @d, align 4
  br label %bb35

bb35:
  br label %bb36

bb36:
  %i37 = load i32, i32* @c, align 4
  %i38 = add nsw i32 %i37, 1
  store i32 %i38, i32* @c, align 4
  br label %bb13

bb39:
  br label %bb1
}
