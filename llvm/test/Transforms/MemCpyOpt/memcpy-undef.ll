; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -basic-aa -memcpyopt -S -enable-memcpyopt-memoryssa=0 | FileCheck %s
; RUN: opt < %s -basic-aa -memcpyopt -S -enable-memcpyopt-memoryssa=1 -verify-memoryssa | FileCheck %s

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.8.0"

%struct.foo = type { i8, [7 x i8], i32 }

; Check that the memcpy is removed.
define i32 @test1(%struct.foo* nocapture %foobie) nounwind noinline ssp uwtable {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    [[BLETCH_SROA_1:%.*]] = alloca [7 x i8], align 1
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [[STRUCT_FOO:%.*]], %struct.foo* [[FOOBIE:%.*]], i64 0, i32 0
; CHECK-NEXT:    store i8 98, i8* [[TMP1]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds [[STRUCT_FOO]], %struct.foo* [[FOOBIE]], i64 0, i32 1, i64 0
; CHECK-NEXT:    [[TMP3:%.*]] = getelementptr inbounds [7 x i8], [7 x i8]* [[BLETCH_SROA_1]], i64 0, i64 0
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[STRUCT_FOO]], %struct.foo* [[FOOBIE]], i64 0, i32 2
; CHECK-NEXT:    store i32 20, i32* [[TMP4]], align 4
; CHECK-NEXT:    ret i32 undef
;
  %bletch.sroa.1 = alloca [7 x i8], align 1
  %1 = getelementptr inbounds %struct.foo, %struct.foo* %foobie, i64 0, i32 0
  store i8 98, i8* %1, align 4
  %2 = getelementptr inbounds %struct.foo, %struct.foo* %foobie, i64 0, i32 1, i64 0
  %3 = getelementptr inbounds [7 x i8], [7 x i8]* %bletch.sroa.1, i64 0, i64 0
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %2, i8* %3, i64 7, i1 false)
  %4 = getelementptr inbounds %struct.foo, %struct.foo* %foobie, i64 0, i32 2
  store i32 20, i32* %4, align 4
  ret i32 undef
}

; Check that the memcpy is removed.
define void @test2(i8* sret(i8) noalias nocapture %out, i8* %in) nounwind noinline ssp uwtable {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    call void @llvm.lifetime.start.p0i8(i64 8, i8* [[IN:%.*]])
; CHECK-NEXT:    ret void
;
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %in)
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %out, i8* %in, i64 8, i1 false)
  ret void
}

; Check that the memcpy is not removed.
define void @test3(i8* sret(i8) noalias nocapture %out, i8* %in) nounwind noinline ssp uwtable {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    call void @llvm.lifetime.start.p0i8(i64 4, i8* [[IN:%.*]])
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* [[OUT:%.*]], i8* [[IN]], i64 8, i1 false)
; CHECK-NEXT:    ret void
;
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %in)
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %out, i8* %in, i64 8, i1 false)
  ret void
}

; Check that the memcpy is not removed.
define void @test_lifetime_may_alias(i8* %lifetime, i8* %src, i8* %dst) {
; CHECK-LABEL: @test_lifetime_may_alias(
; CHECK-NEXT:    call void @llvm.lifetime.start.p0i8(i64 8, i8* [[LIFETIME:%.*]])
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* [[DST:%.*]], i8* [[SRC:%.*]], i64 8, i1 false)
; CHECK-NEXT:    ret void
;
  call void @llvm.lifetime.start.p0i8(i64 8, i8* %lifetime)
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %dst, i8* %src, i64 8, i1 false)
  ret void
}

declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture, i64, i1) nounwind

declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) nounwind
