; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -instcombine < %s | FileCheck %s
target datalayout = "E-m:e-i64:64-n32:64"
target triple = "powerpc64-unknown-linux-gnu"

@f.a = private unnamed_addr constant [1 x i32] [i32 12], align 4
@f.b = private unnamed_addr constant [1 x i32] [i32 55], align 4
@f.c = linkonce unnamed_addr alias [1 x i32], [1 x i32]* @f.b

define signext i32 @test1(i32 signext %x) #0 {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    ret i32 12
;
  %idxprom = sext i32 %x to i64
  %arrayidx = getelementptr inbounds [1 x i32], [1 x i32]* @f.a, i64 0, i64 %idxprom
  %r = load i32, i32* %arrayidx, align 4
  ret i32 %r
}

declare void @foo(i64* %p)
define void @test2(i32 signext %x, i64 %v) #0 {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    [[P:%.*]] = alloca i64, align 8
; CHECK-NEXT:    store i64 [[V:%.*]], i64* [[P]], align 8
; CHECK-NEXT:    call void @foo(i64* nonnull [[P]]) #1
; CHECK-NEXT:    ret void
;
  %p = alloca i64
  %idxprom = sext i32 %x to i64
  %arrayidx = getelementptr inbounds i64, i64* %p, i64 %idxprom
  store i64 %v, i64* %arrayidx
  call void @foo(i64* %p)
  ret void
}

define signext i32 @test3(i32 signext %x, i1 %y) #0 {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[P:%.*]] = select i1 [[Y:%.*]], [1 x i32]* @f.a, [1 x i32]* @f.b
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [1 x i32], [1 x i32]* [[P]], i64 0, i64 0
; CHECK-NEXT:    [[R:%.*]] = load i32, i32* [[TMP1]], align 4
; CHECK-NEXT:    ret i32 [[R]]
;
  %idxprom = sext i32 %x to i64
  %p = select i1 %y, [1 x i32]* @f.a, [1 x i32]* @f.b
  %arrayidx = getelementptr inbounds [1 x i32], [1 x i32]* %p, i64 0, i64 %idxprom
  %r = load i32, i32* %arrayidx, align 4
  ret i32 %r
}

define signext i32 @test4(i32 signext %x, i1 %y) #0 {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    [[IDXPROM:%.*]] = sext i32 [[X:%.*]] to i64
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [1 x i32], [1 x i32]* @f.c, i64 0, i64 [[IDXPROM]]
; CHECK-NEXT:    [[R:%.*]] = load i32, i32* [[ARRAYIDX]], align 4
; CHECK-NEXT:    ret i32 [[R]]
;
  %idxprom = sext i32 %x to i64
  %arrayidx = getelementptr inbounds [1 x i32], [1 x i32]* @f.c, i64 0, i64 %idxprom
  %r = load i32, i32* %arrayidx, align 4
  ret i32 %r
}

attributes #0 = { nounwind readnone }

