; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -gvn -S < %s | FileCheck %s

target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128-ni:4"
target triple = "x86_64-unknown-linux-gnu"

define void @f0(i1 %alwaysFalse, i64 %val, i64* %loc) {
; CHECK-LABEL: @f0(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    store i64 [[VAL:%.*]], i64* [[LOC:%.*]], align 8
; CHECK-NEXT:    br i1 [[ALWAYSFALSE:%.*]], label [[NEVERTAKEN:%.*]], label [[ALWAYSTAKEN:%.*]]
; CHECK:       neverTaken:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast i64* [[LOC]] to i8 addrspace(4)**
; CHECK-NEXT:    [[PTR:%.*]] = load i8 addrspace(4)*, i8 addrspace(4)** [[LOC_BC]], align 8
; CHECK-NEXT:    store i8 5, i8 addrspace(4)* [[PTR]], align 1
; CHECK-NEXT:    ret void
; CHECK:       alwaysTaken:
; CHECK-NEXT:    ret void
;
  entry:
  store i64 %val, i64* %loc
  br i1 %alwaysFalse, label %neverTaken, label %alwaysTaken

  neverTaken:
  %loc.bc = bitcast i64* %loc to i8 addrspace(4)**
  %ptr = load i8 addrspace(4)*, i8 addrspace(4)** %loc.bc
  store i8 5, i8 addrspace(4)* %ptr
  ret void

  alwaysTaken:
  ret void
}

define i64 @f1(i1 %alwaysFalse, i8 addrspace(4)* %val, i8 addrspace(4)** %loc) {
; CHECK-LABEL: @f1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    store i8 addrspace(4)* [[VAL:%.*]], i8 addrspace(4)** [[LOC:%.*]], align 8
; CHECK-NEXT:    br i1 [[ALWAYSFALSE:%.*]], label [[NEVERTAKEN:%.*]], label [[ALWAYSTAKEN:%.*]]
; CHECK:       neverTaken:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast i8 addrspace(4)** [[LOC]] to i64*
; CHECK-NEXT:    [[INT:%.*]] = load i64, i64* [[LOC_BC]], align 8
; CHECK-NEXT:    ret i64 [[INT]]
; CHECK:       alwaysTaken:
; CHECK-NEXT:    ret i64 42
;
  entry:
  store i8 addrspace(4)* %val, i8 addrspace(4)** %loc
  br i1 %alwaysFalse, label %neverTaken, label %alwaysTaken

  neverTaken:
  %loc.bc = bitcast i8 addrspace(4)** %loc to i64*
  %int = load i64, i64* %loc.bc
  ret i64 %int

  alwaysTaken:
  ret i64 42
}

;; Note: For terseness, we stop using the %alwaysfalse trick for the
;; tests below and just exercise the bits of forwarding logic directly.

declare void @llvm.memset.p4i8.i64(i8 addrspace(4)* nocapture, i8, i64, i1) nounwind

; Can't forward as the load might be dead.  (Pretend we wrote out the alwaysfalse idiom above.)
define i8 addrspace(4)* @neg_forward_memset(i8 addrspace(4)* addrspace(4)* %loc) {
; CHECK-LABEL: @neg_forward_memset(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast i8 addrspace(4)* addrspace(4)* [[LOC:%.*]] to i8 addrspace(4)*
; CHECK-NEXT:    call void @llvm.memset.p4i8.i64(i8 addrspace(4)* align 4 [[LOC_BC]], i8 7, i64 8, i1 false)
; CHECK-NEXT:    [[REF:%.*]] = load i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* [[LOC]], align 8
; CHECK-NEXT:    ret i8 addrspace(4)* [[REF]]
;
  entry:
  %loc.bc = bitcast i8 addrspace(4)* addrspace(4)* %loc to i8 addrspace(4)*
  call void @llvm.memset.p4i8.i64(i8 addrspace(4)* align 4 %loc.bc, i8 7, i64 8, i1 false)
  %ref = load i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* %loc
  ret i8 addrspace(4)* %ref
}

define <1 x i8 addrspace(4)*> @neg_forward_memset_vload(<1 x i8 addrspace(4)*> addrspace(4)* %loc) {
; CHECK-LABEL: @neg_forward_memset_vload(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast <1 x i8 addrspace(4)*> addrspace(4)* [[LOC:%.*]] to i8 addrspace(4)*
; CHECK-NEXT:    call void @llvm.memset.p4i8.i64(i8 addrspace(4)* align 4 [[LOC_BC]], i8 7, i64 8, i1 false)
; CHECK-NEXT:    [[REF:%.*]] = load <1 x i8 addrspace(4)*>, <1 x i8 addrspace(4)*> addrspace(4)* [[LOC]], align 8
; CHECK-NEXT:    ret <1 x i8 addrspace(4)*> [[REF]]
;
  entry:
  %loc.bc = bitcast <1 x i8 addrspace(4)*> addrspace(4)* %loc to i8 addrspace(4)*
  call void @llvm.memset.p4i8.i64(i8 addrspace(4)* align 4 %loc.bc, i8 7, i64 8, i1 false)
  %ref = load <1 x i8 addrspace(4)*>, <1 x i8 addrspace(4)*> addrspace(4)* %loc
  ret <1 x i8 addrspace(4)*> %ref
}


; Can forward since we can do so w/o breaking types
define i8 addrspace(4)* @forward_memset_zero(i8 addrspace(4)* addrspace(4)* %loc) {
; CHECK-LABEL: @forward_memset_zero(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast i8 addrspace(4)* addrspace(4)* [[LOC:%.*]] to i8 addrspace(4)*
; CHECK-NEXT:    call void @llvm.memset.p4i8.i64(i8 addrspace(4)* align 4 [[LOC_BC]], i8 0, i64 8, i1 false)
; CHECK-NEXT:    ret i8 addrspace(4)* null
;
  entry:
  %loc.bc = bitcast i8 addrspace(4)* addrspace(4)* %loc to i8 addrspace(4)*
  call void @llvm.memset.p4i8.i64(i8 addrspace(4)* align 4 %loc.bc, i8 0, i64 8, i1 false)
  %ref = load i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* %loc
  ret i8 addrspace(4)* %ref
}

; Can't forward as the load might be dead.  (Pretend we wrote out the alwaysfalse idiom above.)
define i8 addrspace(4)* @neg_forward_store(i8 addrspace(4)* addrspace(4)* %loc) {
; CHECK-LABEL: @neg_forward_store(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast i8 addrspace(4)* addrspace(4)* [[LOC:%.*]] to i64 addrspace(4)*
; CHECK-NEXT:    store i64 5, i64 addrspace(4)* [[LOC_BC]], align 8
; CHECK-NEXT:    [[REF:%.*]] = load i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* [[LOC]], align 8
; CHECK-NEXT:    ret i8 addrspace(4)* [[REF]]
;
  entry:
  %loc.bc = bitcast i8 addrspace(4)* addrspace(4)* %loc to i64 addrspace(4)*
  store i64 5, i64 addrspace(4)* %loc.bc
  %ref = load i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* %loc
  ret i8 addrspace(4)* %ref
}

define <1 x i8 addrspace(4)*> @neg_forward_store_vload(<1 x i8 addrspace(4)*> addrspace(4)* %loc) {
; CHECK-LABEL: @neg_forward_store_vload(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast <1 x i8 addrspace(4)*> addrspace(4)* [[LOC:%.*]] to i64 addrspace(4)*
; CHECK-NEXT:    store i64 5, i64 addrspace(4)* [[LOC_BC]], align 8
; CHECK-NEXT:    [[REF:%.*]] = load <1 x i8 addrspace(4)*>, <1 x i8 addrspace(4)*> addrspace(4)* [[LOC]], align 8
; CHECK-NEXT:    ret <1 x i8 addrspace(4)*> [[REF]]
;
  entry:
  %loc.bc = bitcast <1 x i8 addrspace(4)*> addrspace(4)* %loc to i64 addrspace(4)*
  store i64 5, i64 addrspace(4)* %loc.bc
  %ref = load <1 x i8 addrspace(4)*>, <1 x i8 addrspace(4)*> addrspace(4)* %loc
  ret <1 x i8 addrspace(4)*> %ref
}

; Nulls have known bit patterns, so we can forward
define i8 addrspace(4)* @forward_store_zero(i8 addrspace(4)* addrspace(4)* %loc) {
; CHECK-LABEL: @forward_store_zero(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast i8 addrspace(4)* addrspace(4)* [[LOC:%.*]] to i64 addrspace(4)*
; CHECK-NEXT:    store i64 0, i64 addrspace(4)* [[LOC_BC]], align 8
; CHECK-NEXT:    ret i8 addrspace(4)* null
;
  entry:
  %loc.bc = bitcast i8 addrspace(4)* addrspace(4)* %loc to i64 addrspace(4)*
  store i64 0, i64 addrspace(4)* %loc.bc
  %ref = load i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* %loc
  ret i8 addrspace(4)* %ref
}

; Nulls have known bit patterns, so we can forward
define i8 addrspace(4)* @forward_store_zero2(i8 addrspace(4)* addrspace(4)* %loc) {
; CHECK-LABEL: @forward_store_zero2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast i8 addrspace(4)* addrspace(4)* [[LOC:%.*]] to <2 x i32> addrspace(4)*
; CHECK-NEXT:    store <2 x i32> zeroinitializer, <2 x i32> addrspace(4)* [[LOC_BC]], align 8
; CHECK-NEXT:    ret i8 addrspace(4)* null
;
  entry:
  %loc.bc = bitcast i8 addrspace(4)* addrspace(4)* %loc to <2 x i32> addrspace(4)*
  store <2 x i32> zeroinitializer, <2 x i32> addrspace(4)* %loc.bc
  %ref = load i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* %loc
  ret i8 addrspace(4)* %ref
}



@NonZeroConstant = constant <4 x i64> <i64 3, i64 3, i64 3, i64 3>
@NonZeroConstant2 = constant <4 x i64 addrspace(4)*> <
  i64 addrspace(4)* getelementptr (i64, i64 addrspace(4)* null, i32 3),
  i64 addrspace(4)* getelementptr (i64, i64 addrspace(4)* null, i32 3),
  i64 addrspace(4)* getelementptr (i64, i64 addrspace(4)* null, i32 3),
  i64 addrspace(4)* getelementptr (i64, i64 addrspace(4)* null, i32 3)>
@ZeroConstant = constant <4 x i64> zeroinitializer


; Can't forward as the load might be dead.  (Pretend we wrote out the alwaysfalse idiom above.)
define i8 addrspace(4)* @neg_forward_memcopy(i8 addrspace(4)* addrspace(4)* %loc) {
; CHECK-LABEL: @neg_forward_memcopy(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast i8 addrspace(4)* addrspace(4)* [[LOC:%.*]] to i8 addrspace(4)*
; CHECK-NEXT:    call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 [[LOC_BC]], i8* bitcast (<4 x i64>* @NonZeroConstant to i8*), i64 8, i1 false)
; CHECK-NEXT:    [[REF:%.*]] = load i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* [[LOC]], align 8
; CHECK-NEXT:    ret i8 addrspace(4)* [[REF]]
;
entry:
  %loc.bc = bitcast i8 addrspace(4)* addrspace(4)* %loc to i8 addrspace(4)*
  %src.bc = bitcast <4 x i64>* @NonZeroConstant to i8*
  call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 %loc.bc, i8* %src.bc, i64 8, i1 false)
  %ref = load i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* %loc
  ret i8 addrspace(4)* %ref
}

define i64 addrspace(4)* @neg_forward_memcopy2(i64 addrspace(4)* addrspace(4)* %loc) {
; CHECK-LABEL: @neg_forward_memcopy2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast i64 addrspace(4)* addrspace(4)* [[LOC:%.*]] to i8 addrspace(4)*
; CHECK-NEXT:    call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 [[LOC_BC]], i8* bitcast (<4 x i64>* @NonZeroConstant to i8*), i64 8, i1 false)
; CHECK-NEXT:    [[REF:%.*]] = load i64 addrspace(4)*, i64 addrspace(4)* addrspace(4)* [[LOC]], align 8
; CHECK-NEXT:    ret i64 addrspace(4)* [[REF]]
;
entry:
  %loc.bc = bitcast i64 addrspace(4)* addrspace(4)* %loc to i8 addrspace(4)*
  %src.bc = bitcast <4 x i64>* @NonZeroConstant to i8*
  call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 %loc.bc, i8* %src.bc, i64 8, i1 false)
  %ref = load i64 addrspace(4)*, i64 addrspace(4)* addrspace(4)* %loc
  ret i64 addrspace(4)* %ref
}

; TODO: missed optimization
define i8 addrspace(4)* @forward_memcopy(i8 addrspace(4)* addrspace(4)* %loc) {
; CHECK-LABEL: @forward_memcopy(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast i8 addrspace(4)* addrspace(4)* [[LOC:%.*]] to i8 addrspace(4)*
; CHECK-NEXT:    call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 [[LOC_BC]], i8* bitcast (<4 x i64 addrspace(4)*>* @NonZeroConstant2 to i8*), i64 8, i1 false)
; CHECK-NEXT:    [[REF:%.*]] = load i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* [[LOC]], align 8
; CHECK-NEXT:    ret i8 addrspace(4)* [[REF]]
;
entry:
  %loc.bc = bitcast i8 addrspace(4)* addrspace(4)* %loc to i8 addrspace(4)*
  %src.bc = bitcast <4 x i64 addrspace(4)*>* @NonZeroConstant2 to i8*
  call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 %loc.bc, i8* %src.bc, i64 8, i1 false)
  %ref = load i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* %loc
  ret i8 addrspace(4)* %ref
}

define i64 addrspace(4)* @forward_memcopy2(i64 addrspace(4)* addrspace(4)* %loc) {
; CHECK-LABEL: @forward_memcopy2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast i64 addrspace(4)* addrspace(4)* [[LOC:%.*]] to i8 addrspace(4)*
; CHECK-NEXT:    call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 [[LOC_BC]], i8* bitcast (<4 x i64 addrspace(4)*>* @NonZeroConstant2 to i8*), i64 8, i1 false)
; CHECK-NEXT:    ret i64 addrspace(4)* getelementptr (i64, i64 addrspace(4)* null, i32 3)
;
entry:
  %loc.bc = bitcast i64 addrspace(4)* addrspace(4)* %loc to i8 addrspace(4)*
  %src.bc = bitcast <4 x i64 addrspace(4)*>* @NonZeroConstant2 to i8*
  call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 %loc.bc, i8* %src.bc, i64 8, i1 false)
  %ref = load i64 addrspace(4)*, i64 addrspace(4)* addrspace(4)* %loc
  ret i64 addrspace(4)* %ref
}

define <1 x i8 addrspace(4)*> @neg_forward_memcpy_vload(<1 x i8 addrspace(4)*> addrspace(4)* %loc) {
; CHECK-LABEL: @neg_forward_memcpy_vload(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast <1 x i8 addrspace(4)*> addrspace(4)* [[LOC:%.*]] to i8 addrspace(4)*
; CHECK-NEXT:    call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 [[LOC_BC]], i8* bitcast (<4 x i64>* @NonZeroConstant to i8*), i64 8, i1 false)
; CHECK-NEXT:    [[REF:%.*]] = load <1 x i8 addrspace(4)*>, <1 x i8 addrspace(4)*> addrspace(4)* [[LOC]], align 8
; CHECK-NEXT:    ret <1 x i8 addrspace(4)*> [[REF]]
;
entry:
  %loc.bc = bitcast <1 x i8 addrspace(4)*> addrspace(4)* %loc to i8 addrspace(4)*
  %src.bc = bitcast <4 x i64>* @NonZeroConstant to i8*
  call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 %loc.bc, i8* %src.bc, i64 8, i1 false)
  %ref = load <1 x i8 addrspace(4)*>, <1 x i8 addrspace(4)*> addrspace(4)* %loc
  ret <1 x i8 addrspace(4)*> %ref
}

define <4 x i64 addrspace(4)*> @neg_forward_memcpy_vload2(<4 x i64 addrspace(4)*> addrspace(4)* %loc) {
; CHECK-LABEL: @neg_forward_memcpy_vload2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast <4 x i64 addrspace(4)*> addrspace(4)* [[LOC:%.*]] to i8 addrspace(4)*
; CHECK-NEXT:    call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 [[LOC_BC]], i8* bitcast (<4 x i64>* @NonZeroConstant to i8*), i64 32, i1 false)
; CHECK-NEXT:    [[REF:%.*]] = load <4 x i64 addrspace(4)*>, <4 x i64 addrspace(4)*> addrspace(4)* [[LOC]], align 32
; CHECK-NEXT:    ret <4 x i64 addrspace(4)*> [[REF]]
;
entry:
  %loc.bc = bitcast <4 x i64 addrspace(4)*> addrspace(4)* %loc to i8 addrspace(4)*
  %src.bc = bitcast <4 x i64>* @NonZeroConstant to i8*
  call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 %loc.bc, i8* %src.bc, i64 32, i1 false)
  %ref = load <4 x i64 addrspace(4)*>, <4 x i64 addrspace(4)*> addrspace(4)* %loc
  ret <4 x i64 addrspace(4)*> %ref
}

define <4 x i64> @neg_forward_memcpy_vload3(<4 x i64> addrspace(4)* %loc) {
; CHECK-LABEL: @neg_forward_memcpy_vload3(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast <4 x i64> addrspace(4)* [[LOC:%.*]] to i8 addrspace(4)*
; CHECK-NEXT:    call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 [[LOC_BC]], i8* bitcast (<4 x i64 addrspace(4)*>* @NonZeroConstant2 to i8*), i64 32, i1 false)
; CHECK-NEXT:    [[REF:%.*]] = load <4 x i64>, <4 x i64> addrspace(4)* [[LOC]], align 32
; CHECK-NEXT:    ret <4 x i64> [[REF]]
;
entry:
  %loc.bc = bitcast <4 x i64> addrspace(4)* %loc to i8 addrspace(4)*
  %src.bc = bitcast <4 x i64 addrspace(4)*>* @NonZeroConstant2 to i8*
  call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 %loc.bc, i8* %src.bc, i64 32, i1 false)
  %ref = load <4 x i64>, <4 x i64> addrspace(4)* %loc
  ret <4 x i64> %ref
}

define <1 x i64 addrspace(4)*> @forward_memcpy_vload3(<4 x i64 addrspace(4)*> addrspace(4)* %loc) {
; CHECK-LABEL: @forward_memcpy_vload3(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast <4 x i64 addrspace(4)*> addrspace(4)* [[LOC:%.*]] to i8 addrspace(4)*
; CHECK-NEXT:    call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 [[LOC_BC]], i8* bitcast (<4 x i64 addrspace(4)*>* @NonZeroConstant2 to i8*), i64 32, i1 false)
; CHECK-NEXT:    ret <1 x i64 addrspace(4)*> <i64 addrspace(4)* getelementptr (i64, i64 addrspace(4)* null, i32 3)>
;
entry:
  %loc.bc = bitcast <4 x i64 addrspace(4)*> addrspace(4)* %loc to i8 addrspace(4)*
  %src.bc = bitcast <4 x i64 addrspace(4)*>* @NonZeroConstant2 to i8*
  call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 %loc.bc, i8* %src.bc, i64 32, i1 false)
  %ref = load <4 x i64 addrspace(4)*>, <4 x i64 addrspace(4)*> addrspace(4)* %loc
  %val = extractelement <4 x i64 addrspace(4)*> %ref, i32 0
  %ret = insertelement <1 x i64 addrspace(4)*> undef, i64 addrspace(4)* %val, i32 0
  ret <1 x i64 addrspace(4)*> %ret
}

; Can forward since we can do so w/o breaking types
define i8 addrspace(4)* @forward_memcpy_zero(i8 addrspace(4)* addrspace(4)* %loc) {
; CHECK-LABEL: @forward_memcpy_zero(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast i8 addrspace(4)* addrspace(4)* [[LOC:%.*]] to i8 addrspace(4)*
; CHECK-NEXT:    call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 [[LOC_BC]], i8* bitcast (<4 x i64>* @ZeroConstant to i8*), i64 8, i1 false)
; CHECK-NEXT:    ret i8 addrspace(4)* null
;
entry:
  %loc.bc = bitcast i8 addrspace(4)* addrspace(4)* %loc to i8 addrspace(4)*
  %src.bc = bitcast <4 x i64>* @ZeroConstant to i8*
  call void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* align 4 %loc.bc, i8* %src.bc, i64 8, i1 false)
  %ref = load i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* %loc
  ret i8 addrspace(4)* %ref
}

declare void @llvm.memcpy.p4i8.p0i8.i64(i8 addrspace(4)* nocapture, i8* nocapture, i64, i1) nounwind


; Same as the neg_forward_store cases, but for non defs.
; (Pretend we wrote out the alwaysfalse idiom above.)
define i8 addrspace(4)* @neg_store_clobber(i8 addrspace(4)* addrspace(4)* %loc) {
; CHECK-LABEL: @neg_store_clobber(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast i8 addrspace(4)* addrspace(4)* [[LOC:%.*]] to <2 x i64> addrspace(4)*
; CHECK-NEXT:    store <2 x i64> <i64 4, i64 4>, <2 x i64> addrspace(4)* [[LOC_BC]], align 16
; CHECK-NEXT:    [[LOC_OFF:%.*]] = getelementptr i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* [[LOC]], i64 1
; CHECK-NEXT:    [[REF:%.*]] = load i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* [[LOC_OFF]], align 8
; CHECK-NEXT:    ret i8 addrspace(4)* [[REF]]
;
entry:
  %loc.bc = bitcast i8 addrspace(4)* addrspace(4)* %loc to <2 x i64> addrspace(4)*
  store <2 x i64> <i64 4, i64 4>, <2 x i64> addrspace(4)* %loc.bc
  %loc.off = getelementptr i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* %loc, i64 1
  %ref = load i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* %loc.off
  ret i8 addrspace(4)* %ref
}

declare void @use(<2 x i64>) inaccessiblememonly

; Same as the neg_forward_store cases, but for non defs.
; (Pretend we wrote out the alwaysfalse idiom above.)
define i8 addrspace(4)* @neg_load_clobber(i8 addrspace(4)* addrspace(4)* %loc) {
; CHECK-LABEL: @neg_load_clobber(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast i8 addrspace(4)* addrspace(4)* [[LOC:%.*]] to <2 x i64> addrspace(4)*
; CHECK-NEXT:    [[V:%.*]] = load <2 x i64>, <2 x i64> addrspace(4)* [[LOC_BC]], align 16
; CHECK-NEXT:    call void @use(<2 x i64> [[V]])
; CHECK-NEXT:    [[LOC_OFF:%.*]] = getelementptr i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* [[LOC]], i64 1
; CHECK-NEXT:    [[REF:%.*]] = load i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* [[LOC_OFF]], align 8
; CHECK-NEXT:    ret i8 addrspace(4)* [[REF]]
;
entry:
  %loc.bc = bitcast i8 addrspace(4)* addrspace(4)* %loc to <2 x i64> addrspace(4)*
  %v = load <2 x i64>, <2 x i64> addrspace(4)* %loc.bc
  call void @use(<2 x i64> %v)
  %loc.off = getelementptr i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* %loc, i64 1
  %ref = load i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* %loc.off
  ret i8 addrspace(4)* %ref
}

define i8 addrspace(4)* @store_clobber_zero(i8 addrspace(4)* addrspace(4)* %loc) {
; CHECK-LABEL: @store_clobber_zero(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LOC_BC:%.*]] = bitcast i8 addrspace(4)* addrspace(4)* [[LOC:%.*]] to <2 x i64> addrspace(4)*
; CHECK-NEXT:    store <2 x i64> zeroinitializer, <2 x i64> addrspace(4)* [[LOC_BC]], align 16
; CHECK-NEXT:    [[LOC_OFF:%.*]] = getelementptr i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* [[LOC]], i64 1
; CHECK-NEXT:    ret i8 addrspace(4)* null
;
entry:
  %loc.bc = bitcast i8 addrspace(4)* addrspace(4)* %loc to <2 x i64> addrspace(4)*
  store <2 x i64> zeroinitializer, <2 x i64> addrspace(4)* %loc.bc
  %loc.off = getelementptr i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* %loc, i64 1
  %ref = load i8 addrspace(4)*, i8 addrspace(4)* addrspace(4)* %loc.off
  ret i8 addrspace(4)* %ref
}


define void @smaller_vector(i8* %p) {
; CHECK-LABEL: @smaller_vector(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = bitcast i8* [[P:%.*]] to <4 x i64 addrspace(4)*>*
; CHECK-NEXT:    [[B:%.*]] = bitcast i8* [[P]] to <2 x i64 addrspace(4)*>*
; CHECK-NEXT:    [[V4:%.*]] = load <4 x i64 addrspace(4)*>, <4 x i64 addrspace(4)*>* [[A]], align 32
; CHECK-NEXT:    [[V2:%.*]] = load <2 x i64 addrspace(4)*>, <2 x i64 addrspace(4)*>* [[B]], align 32
; CHECK-NEXT:    call void @use.v2(<2 x i64 addrspace(4)*> [[V2]])
; CHECK-NEXT:    call void @use.v4(<4 x i64 addrspace(4)*> [[V4]])
; CHECK-NEXT:    ret void
;
entry:
  %a = bitcast i8* %p to <4 x i64 addrspace(4)*>*
  %b = bitcast i8* %p to <2 x i64 addrspace(4)*>*
  %v4 = load <4 x i64 addrspace(4)*>, <4 x i64 addrspace(4)*>* %a, align 32
  %v2 = load <2 x i64 addrspace(4)*>, <2 x i64 addrspace(4)*>* %b, align 32
  call void @use.v2(<2 x i64 addrspace(4)*> %v2)
  call void @use.v4(<4 x i64 addrspace(4)*> %v4)
  ret void
}

define i64 addrspace(4)* @vector_extract(i8* %p) {
; CHECK-LABEL: @vector_extract(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = bitcast i8* [[P:%.*]] to <4 x i64 addrspace(4)*>*
; CHECK-NEXT:    [[B:%.*]] = bitcast i8* [[P]] to i64 addrspace(4)**
; CHECK-NEXT:    [[V4:%.*]] = load <4 x i64 addrspace(4)*>, <4 x i64 addrspace(4)*>* [[A]], align 32
; CHECK-NEXT:    [[RES:%.*]] = load i64 addrspace(4)*, i64 addrspace(4)** [[B]], align 32
; CHECK-NEXT:    call void @use.v4(<4 x i64 addrspace(4)*> [[V4]])
; CHECK-NEXT:    ret i64 addrspace(4)* [[RES]]
;
entry:
  %a = bitcast i8* %p to <4 x i64 addrspace(4)*>*
  %b = bitcast i8* %p to i64 addrspace(4)**
  %v4 = load <4 x i64 addrspace(4)*>, <4 x i64 addrspace(4)*>* %a, align 32
  %res = load i64 addrspace(4)*, i64 addrspace(4)** %b, align 32
  call void @use.v4(<4 x i64 addrspace(4)*> %v4)
  ret i64 addrspace(4)* %res
}

declare void @use.v2(<2 x i64 addrspace(4)*>)
declare void @use.v4(<4 x i64 addrspace(4)*>)
