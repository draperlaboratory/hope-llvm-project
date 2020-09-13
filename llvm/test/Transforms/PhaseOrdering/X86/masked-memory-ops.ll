; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -O2 -S                                        | FileCheck %s --check-prefixes=CHECK,OLDPM
; RUN: opt < %s -passes='default<O2>' -aa-pipeline=default -S | FileCheck %s --check-prefixes=CHECK,NEWPM

target triple = "x86_64--"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

declare void @llvm.x86.avx.maskstore.ps.256(i8*, <8 x i32>, <8 x float>) #0
declare void @llvm.masked.store.v8f32.p0v8f32(<8 x float>, <8 x float>*, i32, <8 x i1>)

; PR11210: If we have been able to replace a AVX/AVX2 masked store with a
; generic masked store intrinsic, then we should be able to remove dead
; masked stores.

define void @PR11210_v8f32_maskstore_maskstore(i8* %ptr, <8 x float> %x, <8 x float> %y, <8 x i32> %src) {
; CHECK-LABEL: @PR11210_v8f32_maskstore_maskstore(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt <8 x i32> [[SRC:%.*]], zeroinitializer
; CHECK-NEXT:    [[CASTVEC:%.*]] = bitcast i8* [[PTR:%.*]] to <8 x float>*
; CHECK-NEXT:    tail call void @llvm.masked.store.v8f32.p0v8f32(<8 x float> [[Y:%.*]], <8 x float>* [[CASTVEC]], i32 1, <8 x i1> [[CMP]])
; CHECK-NEXT:    ret void
;
  %cmp = icmp sgt <8 x i32> %src, zeroinitializer
  %mask = sext <8 x i1> %cmp to <8 x i32>
  call void @llvm.x86.avx.maskstore.ps.256(i8* %ptr, <8 x i32> %mask, <8 x float> %x)
  call void @llvm.x86.avx.maskstore.ps.256(i8* %ptr, <8 x i32> %mask, <8 x float> %y)
  ret void
}

; The contents of %mask are unknown so we don't replace this with a generic masked.store.
define void @PR11210_v8f32_maskstore_maskstore_raw_mask(i8* %ptr, <8 x float> %x, <8 x float> %y, <8 x i32> %mask) {
; CHECK-LABEL: @PR11210_v8f32_maskstore_maskstore_raw_mask(
; CHECK-NEXT:    tail call void @llvm.x86.avx.maskstore.ps.256(i8* [[PTR:%.*]], <8 x i32> [[MASK:%.*]], <8 x float> [[X:%.*]])
; CHECK-NEXT:    tail call void @llvm.x86.avx.maskstore.ps.256(i8* [[PTR]], <8 x i32> [[MASK]], <8 x float> [[Y:%.*]])
; CHECK-NEXT:    ret void
;
  call void @llvm.x86.avx.maskstore.ps.256(i8* %ptr, <8 x i32> %mask, <8 x float> %x)
  call void @llvm.x86.avx.maskstore.ps.256(i8* %ptr, <8 x i32> %mask, <8 x float> %y)
  ret void
}

; Mix AVX and generic masked stores.
define void @PR11210_v8f32_mstore_maskstore(i8* %ptr, <8 x float> %x, <8 x float> %y, <8 x i32> %src) {
; CHECK-LABEL: @PR11210_v8f32_mstore_maskstore(
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt <8 x i32> [[SRC:%.*]], zeroinitializer
; CHECK-NEXT:    [[PTRF:%.*]] = bitcast i8* [[PTR:%.*]] to <8 x float>*
; CHECK-NEXT:    tail call void @llvm.masked.store.v8f32.p0v8f32(<8 x float> [[Y:%.*]], <8 x float>* [[PTRF]], i32 1, <8 x i1> [[CMP]])
; CHECK-NEXT:    ret void
;
  %cmp = icmp sgt <8 x i32> %src, zeroinitializer
  %mask = sext <8 x i1> %cmp to <8 x i32>
  %ptrf = bitcast i8* %ptr to <8 x float>*
  tail call void @llvm.masked.store.v8f32.p0v8f32(<8 x float> %x, <8 x float>* %ptrf, i32 1, <8 x i1> %cmp)
  call void @llvm.x86.avx.maskstore.ps.256(i8* %ptr, <8 x i32> %mask, <8 x float> %y)
  ret void
}

