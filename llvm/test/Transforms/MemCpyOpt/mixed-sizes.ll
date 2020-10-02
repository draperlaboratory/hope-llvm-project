; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -memcpyopt -S | FileCheck %s
; Handle memcpy-memcpy dependencies of differing sizes correctly.

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

; Don't delete the second memcpy, even though there's an earlier
; memcpy with a larger size from the same address.

define i32 @foo(i1 %z) {
; CHECK-LABEL: @foo(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = alloca [10 x i32], align 4
; CHECK-NEXT:    [[S:%.*]] = alloca [10 x i32], align 4
; CHECK-NEXT:    [[TMP0:%.*]] = bitcast [10 x i32]* [[A]] to i8*
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast [10 x i32]* [[S]] to i8*
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* nonnull align 16 [[TMP1]], i8 0, i64 40, i1 false)
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [10 x i32], [10 x i32]* [[A]], i64 0, i64 0
; CHECK-NEXT:    store i32 1, i32* [[ARRAYIDX]], align 4
; CHECK-NEXT:    [[SCEVGEP:%.*]] = getelementptr [10 x i32], [10 x i32]* [[S]], i64 0, i64 1
; CHECK-NEXT:    [[SCEVGEP7:%.*]] = bitcast i32* [[SCEVGEP]] to i8*
; CHECK-NEXT:    br i1 [[Z:%.*]], label [[FOR_BODY3_LR_PH:%.*]], label [[FOR_INC7_1:%.*]]
; CHECK:       for.body3.lr.ph:
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 [[TMP0]], i8* align 4 [[SCEVGEP7]], i64 17179869180, i1 false)
; CHECK-NEXT:    br label [[FOR_INC7_1]]
; CHECK:       for.inc7.1:
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 [[TMP0]], i8* align 4 [[SCEVGEP7]], i64 4, i1 false)
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, i32* [[ARRAYIDX]], align 4
; CHECK-NEXT:    ret i32 [[TMP2]]
;
entry:
  %a = alloca [10 x i32]
  %s = alloca [10 x i32]
  %0 = bitcast [10 x i32]* %a to i8*
  %1 = bitcast [10 x i32]* %s to i8*
  call void @llvm.memset.p0i8.i64(i8* nonnull align 16 %1, i8 0, i64 40, i1 false)
  %arrayidx = getelementptr inbounds [10 x i32], [10 x i32]* %a, i64 0, i64 0
  store i32 1, i32* %arrayidx
  %scevgep = getelementptr [10 x i32], [10 x i32]* %s, i64 0, i64 1
  %scevgep7 = bitcast i32* %scevgep to i8*
  br i1 %z, label %for.body3.lr.ph, label %for.inc7.1

for.body3.lr.ph:                                  ; preds = %entry
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 %0, i8* align 4 %scevgep7, i64 17179869180, i1 false)
  br label %for.inc7.1

for.inc7.1:
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 %0, i8* align 4 %scevgep7, i64 4, i1 false)
  %2 = load i32, i32* %arrayidx
  ret i32 %2
}

declare void @llvm.memcpy.p0i8.p0i8.i64(i8*, i8*, i64, i1)
declare void @llvm.memset.p0i8.i64(i8*, i8, i64, i1)
