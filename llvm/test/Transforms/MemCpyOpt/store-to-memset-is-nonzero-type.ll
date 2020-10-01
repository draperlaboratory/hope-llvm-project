; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S < %s -memcpyopt | FileCheck %s

; Array

define void @array_zero([0 x i8]* %p) {
; CHECK-LABEL: @array_zero(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast [0 x i8]* [[P:%.*]] to i8*
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* align 1 [[TMP1]], i8 undef, i64 0, i1 false)
; CHECK-NEXT:    ret void
;
  store [0 x i8] zeroinitializer, [0 x i8]* %p
  ret void
}

define void @array_nonzero([1 x i8]* %p) {
; CHECK-LABEL: @array_nonzero(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast [1 x i8]* [[P:%.*]] to i8*
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* align 1 [[TMP1]], i8 0, i64 1, i1 false)
; CHECK-NEXT:    ret void
;
  store [1 x i8] zeroinitializer, [1 x i8]* %p
  ret void
}

; Structure

define void @struct_zero({ }* %p) {
; CHECK-LABEL: @struct_zero(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast {}* [[P:%.*]] to i8*
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* align 1 [[TMP1]], i8 undef, i64 0, i1 false)
; CHECK-NEXT:    ret void
;
  store { } zeroinitializer, { }* %p
  ret void
}
define void @struct_nonzero({ i8 }* %p) {
; CHECK-LABEL: @struct_nonzero(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast { i8 }* [[P:%.*]] to i8*
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* align 1 [[TMP1]], i8 0, i64 1, i1 false)
; CHECK-NEXT:    ret void
;
  store { i8 } zeroinitializer, { i8 }* %p
  ret void
}

; Vector

; Test only non-zero vector. Zero element vector is illegal

define void @vector_fixed_length_nonzero(<16 x i8>* %p) {
; CHECK-LABEL: @vector_fixed_length_nonzero(
; CHECK-NEXT:    [[TMP0:%.*]] = getelementptr <16 x i8>, <16 x i8>* [[P:%.*]], i64 0
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr <16 x i8>, <16 x i8>* [[P]], i64 1
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast <16 x i8>* [[TMP0]] to i8*
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* align 16 [[TMP1]], i8 0, i64 32, i1 false)
; CHECK-NEXT:    ret void
;
  %tmp0 = getelementptr <16 x i8>, <16 x i8>* %p, i64 0
  store <16 x i8> zeroinitializer, <16 x i8>* %tmp0
  %tmp1 = getelementptr <16 x i8>, <16 x i8>* %p, i64 1
  store <16 x i8> zeroinitializer, <16 x i8>* %tmp1
  ret void
}

define void @vector_scalable_nonzero(<vscale x 4 x i32>* %p) {
; CHECK-LABEL: @vector_scalable_nonzero(
; CHECK-NEXT:    store <vscale x 4 x i32> zeroinitializer, <vscale x 4 x i32>* [[P:%.*]], align 16
; CHECK-NEXT:    ret void
;
  store <vscale x 4 x i32> zeroinitializer, <vscale x 4 x i32>* %p
  ret void
}
