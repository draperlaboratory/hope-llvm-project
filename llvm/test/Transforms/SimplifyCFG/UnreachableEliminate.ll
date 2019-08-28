; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -simplifycfg -S | FileCheck %s

define void @test1(i1 %C, i1* %BP) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = xor i1 [[C:%.*]], true
; CHECK-NEXT:    call void @llvm.assume(i1 [[TMP0]])
; CHECK-NEXT:    ret void
;
entry:
  br i1 %C, label %T, label %F
T:
  store i1 %C, i1* %BP
  unreachable
F:
  ret void
}

define void @test2() personality i32 (...)* @__gxx_personality_v0 {
; CHECK-LABEL: @test2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    call void @test2()
; CHECK-NEXT:    ret void
;
entry:
  invoke void @test2( )
  to label %N unwind label %U
U:
  %res = landingpad { i8* }
  cleanup
  unreachable
N:
  ret void
}

declare i32 @__gxx_personality_v0(...)

define i32 @test3(i32 %v) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[COND:%.*]] = icmp eq i32 [[V:%.*]], 2
; CHECK-NEXT:    [[SPEC_SELECT:%.*]] = select i1 [[COND]], i32 2, i32 1
; CHECK-NEXT:    ret i32 [[SPEC_SELECT]]
;
entry:
  switch i32 %v, label %default [
  i32 1, label %U
  i32 2, label %T
  ]
default:
  ret i32 1
U:
  unreachable
T:
  ret i32 2
}


;; We can either convert the following control-flow to a select or remove the
;; unreachable control flow because of the undef store of null. Make sure we do
;; the latter.

define void @test5(i1 %cond, i8* %ptr) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = xor i1 [[COND:%.*]], true
; CHECK-NEXT:    call void @llvm.assume(i1 [[TMP0]])
; CHECK-NEXT:    store i8 2, i8* [[PTR:%.*]], align 8
; CHECK-NEXT:    ret void
;

entry:
  br i1 %cond, label %bb1, label %bb3

bb3:
  br label %bb2

bb1:
  br label %bb2

bb2:
  %ptr.2 = phi i8* [ %ptr, %bb3 ], [ null, %bb1 ]
  store i8 2, i8* %ptr.2, align 8
  ret void
}

define void @test5_no_null_opt(i1 %cond, i8* %ptr) #0 {
; CHECK-LABEL: @test5_no_null_opt(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[DOTPTR:%.*]] = select i1 [[COND:%.*]], i8* null, i8* [[PTR:%.*]]
; CHECK-NEXT:    store i8 2, i8* [[DOTPTR]], align 8
; CHECK-NEXT:    ret void
;

entry:
  br i1 %cond, label %bb1, label %bb3

bb3:
  br label %bb2

bb1:
  br label %bb2

bb2:
  %ptr.2 = phi i8* [ %ptr, %bb3 ], [ null, %bb1 ]
  store i8 2, i8* %ptr.2, align 8
  ret void
}

define void @test6(i1 %cond, i8* %ptr) {
; CHECK-LABEL: @test6(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = xor i1 [[COND:%.*]], true
; CHECK-NEXT:    call void @llvm.assume(i1 [[TMP0]])
; CHECK-NEXT:    store i8 2, i8* [[PTR:%.*]], align 8
; CHECK-NEXT:    ret void
;
entry:
  br i1 %cond, label %bb1, label %bb2

bb1:
  br label %bb2

bb2:
  %ptr.2 = phi i8* [ %ptr, %entry ], [ null, %bb1 ]
  store i8 2, i8* %ptr.2, align 8
  ret void
}

define void @test6_no_null_opt(i1 %cond, i8* %ptr) #0 {
; CHECK-LABEL: @test6_no_null_opt(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SPEC_SELECT:%.*]] = select i1 [[COND:%.*]], i8* null, i8* [[PTR:%.*]]
; CHECK-NEXT:    store i8 2, i8* [[SPEC_SELECT]], align 8
; CHECK-NEXT:    ret void
;
entry:
  br i1 %cond, label %bb1, label %bb2

bb1:
  br label %bb2

bb2:
  %ptr.2 = phi i8* [ %ptr, %entry ], [ null, %bb1 ]
  store i8 2, i8* %ptr.2, align 8
  ret void
}


define i32 @test7(i1 %X) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = xor i1 [[X:%.*]], true
; CHECK-NEXT:    call void @llvm.assume(i1 [[TMP0]])
; CHECK-NEXT:    ret i32 0
;
entry:
  br i1 %X, label %if, label %else

if:
  call void undef()
  br label %else

else:
  %phi = phi i32 [ 0, %entry ], [ 1, %if ]
  ret i32 %phi
}

define void @test8(i1 %X, void ()* %Y) {
; CHECK-LABEL: @test8(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = xor i1 [[X:%.*]], true
; CHECK-NEXT:    call void @llvm.assume(i1 [[TMP0]])
; CHECK-NEXT:    call void [[Y:%.*]]()
; CHECK-NEXT:    ret void
;
entry:
  br i1 %X, label %if, label %else

if:
  br label %else

else:
  %phi = phi void ()* [ %Y, %entry ], [ null, %if ]
  call void %phi()
  ret void
}

define void @test8_no_null_opt(i1 %X, void ()* %Y) #0 {
; CHECK-LABEL: @test8_no_null_opt(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SPEC_SELECT:%.*]] = select i1 [[X:%.*]], void ()* null, void ()* [[Y:%.*]]
; CHECK-NEXT:    call void [[SPEC_SELECT]]()
; CHECK-NEXT:    ret void
;
entry:
  br i1 %X, label %if, label %else

if:
  br label %else

else:
  %phi = phi void ()* [ %Y, %entry ], [ null, %if ]
  call void %phi()
  ret void
}

attributes #0 = { "null-pointer-is-valid"="true" }
