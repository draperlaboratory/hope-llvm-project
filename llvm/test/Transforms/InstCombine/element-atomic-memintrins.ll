; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -instcombine -S < %s | FileCheck %s

;; ---- memset -----

; Ensure 0-length memset is removed
define void @test_memset_zero_length(i8* %dest) {
; CHECK-LABEL: @test_memset_zero_length(
; CHECK-NEXT:    ret void
;
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 1 %dest, i8 1, i32 0, i32 1)
  ret void
}

define void @test_memset_to_store(i8* %dest) {
; CHECK-LABEL: @test_memset_to_store(
; CHECK-NEXT:    store atomic i8 1, i8* [[DEST:%.*]] unordered, align 1
; CHECK-NEXT:    call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* nonnull align 1 [[DEST]], i8 1, i32 2, i32 1)
; CHECK-NEXT:    call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* nonnull align 1 [[DEST]], i8 1, i32 4, i32 1)
; CHECK-NEXT:    call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* nonnull align 1 [[DEST]], i8 1, i32 8, i32 1)
; CHECK-NEXT:    call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* nonnull align 1 [[DEST]], i8 1, i32 16, i32 1)
; CHECK-NEXT:    ret void
;
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 1 %dest, i8 1, i32 1, i32 1)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 1 %dest, i8 1, i32 2, i32 1)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 1 %dest, i8 1, i32 4, i32 1)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 1 %dest, i8 1, i32 8, i32 1)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 1 %dest, i8 1, i32 16, i32 1)
  ret void
}

define void @test_memset_to_store_2(i8* %dest) {
; CHECK-LABEL: @test_memset_to_store_2(
; CHECK-NEXT:    store atomic i8 1, i8* [[DEST:%.*]] unordered, align 2
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i8* [[DEST]] to i16*
; CHECK-NEXT:    store atomic i16 257, i16* [[TMP1]] unordered, align 2
; CHECK-NEXT:    call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* nonnull align 2 [[DEST]], i8 1, i32 4, i32 2)
; CHECK-NEXT:    call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* nonnull align 2 [[DEST]], i8 1, i32 8, i32 2)
; CHECK-NEXT:    call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* nonnull align 2 [[DEST]], i8 1, i32 16, i32 2)
; CHECK-NEXT:    ret void
;
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 2 %dest, i8 1, i32 1, i32 1)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 2 %dest, i8 1, i32 2, i32 2)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 2 %dest, i8 1, i32 4, i32 2)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 2 %dest, i8 1, i32 8, i32 2)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 2 %dest, i8 1, i32 16, i32 2)
  ret void
}

define void @test_memset_to_store_4(i8* %dest) {
; CHECK-LABEL: @test_memset_to_store_4(
; CHECK-NEXT:    store atomic i8 1, i8* [[DEST:%.*]] unordered, align 4
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i8* [[DEST]] to i16*
; CHECK-NEXT:    store atomic i16 257, i16* [[TMP1]] unordered, align 4
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8* [[DEST]] to i32*
; CHECK-NEXT:    store atomic i32 16843009, i32* [[TMP2]] unordered, align 4
; CHECK-NEXT:    call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* nonnull align 4 [[DEST]], i8 1, i32 8, i32 4)
; CHECK-NEXT:    call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* nonnull align 4 [[DEST]], i8 1, i32 16, i32 4)
; CHECK-NEXT:    ret void
;
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 4 %dest, i8 1, i32 1, i32 1)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 4 %dest, i8 1, i32 2, i32 2)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 4 %dest, i8 1, i32 4, i32 4)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 4 %dest, i8 1, i32 8, i32 4)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 4 %dest, i8 1, i32 16, i32 4)
  ret void
}

define void @test_memset_to_store_8(i8* %dest) {
; CHECK-LABEL: @test_memset_to_store_8(
; CHECK-NEXT:    store atomic i8 1, i8* [[DEST:%.*]] unordered, align 8
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i8* [[DEST]] to i16*
; CHECK-NEXT:    store atomic i16 257, i16* [[TMP1]] unordered, align 8
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8* [[DEST]] to i32*
; CHECK-NEXT:    store atomic i32 16843009, i32* [[TMP2]] unordered, align 8
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i8* [[DEST]] to i64*
; CHECK-NEXT:    store atomic i64 72340172838076673, i64* [[TMP3]] unordered, align 8
; CHECK-NEXT:    call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* nonnull align 8 [[DEST]], i8 1, i32 16, i32 8)
; CHECK-NEXT:    ret void
;
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 8 %dest, i8 1, i32 1, i32 1)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 8 %dest, i8 1, i32 2, i32 2)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 8 %dest, i8 1, i32 4, i32 4)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 8 %dest, i8 1, i32 8, i32 8)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 8 %dest, i8 1, i32 16, i32 8)
  ret void
}

define void @test_memset_to_store_16(i8* %dest) {
; CHECK-LABEL: @test_memset_to_store_16(
; CHECK-NEXT:    store atomic i8 1, i8* [[DEST:%.*]] unordered, align 16
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i8* [[DEST]] to i16*
; CHECK-NEXT:    store atomic i16 257, i16* [[TMP1]] unordered, align 16
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8* [[DEST]] to i32*
; CHECK-NEXT:    store atomic i32 16843009, i32* [[TMP2]] unordered, align 16
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i8* [[DEST]] to i64*
; CHECK-NEXT:    store atomic i64 72340172838076673, i64* [[TMP3]] unordered, align 16
; CHECK-NEXT:    call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* nonnull align 16 [[DEST]], i8 1, i32 16, i32 16)
; CHECK-NEXT:    ret void
;
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 16 %dest, i8 1, i32 1, i32 1)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 16 %dest, i8 1, i32 2, i32 2)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 16 %dest, i8 1, i32 4, i32 4)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 16 %dest, i8 1, i32 8, i32 8)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 16 %dest, i8 1, i32 16, i32 16)
  ret void
}

declare void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* nocapture writeonly, i8, i32, i32) nounwind argmemonly


;; =========================================
;; ----- memmove ------


@gconst = constant [32 x i8] c"0123456789012345678901234567890\00"
; Check that a memmove from a global constant is converted into a memcpy
define void @test_memmove_to_memcpy(i8* %dest) {
; CHECK-LABEL: @test_memmove_to_memcpy(
; CHECK-NEXT:    call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 1 [[DEST:%.*]], i8* align 16 getelementptr inbounds ([32 x i8], [32 x i8]* @gconst, i64 0, i64 0), i32 32, i32 1)
; CHECK-NEXT:    ret void
;
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 1 %dest, i8* align 1 getelementptr inbounds ([32 x i8], [32 x i8]* @gconst, i64 0, i64 0), i32 32, i32 1)
  ret void
}

define void @test_memmove_zero_length(i8* %dest, i8* %src) {
; CHECK-LABEL: @test_memmove_zero_length(
; CHECK-NEXT:    ret void
;
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 1 %dest, i8* align 1 %src, i32 0, i32 1)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 2 %dest, i8* align 2 %src, i32 0, i32 2)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 4 %dest, i8* align 4 %src, i32 0, i32 4)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 8 %dest, i8* align 8 %src, i32 0, i32 8)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %dest, i8* align 16 %src, i32 0, i32 16)
  ret void
}

; memmove with src==dest is removed
define void @test_memmove_removed(i8* %srcdest, i32 %sz) {
; CHECK-LABEL: @test_memmove_removed(
; CHECK-NEXT:    ret void
;
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 1 %srcdest, i8* align 1 %srcdest, i32 %sz, i32 1)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 2 %srcdest, i8* align 2 %srcdest, i32 %sz, i32 2)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 4 %srcdest, i8* align 4 %srcdest, i32 %sz, i32 4)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 8 %srcdest, i8* align 8 %srcdest, i32 %sz, i32 8)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %srcdest, i8* align 16 %srcdest, i32 %sz, i32 16)
  ret void
}

; memmove with a small constant length is converted to a load/store pair
define void @test_memmove_loadstore(i8* %dest, i8* %src) {
; CHECK-LABEL: @test_memmove_loadstore(
; CHECK-NEXT:    [[TMP1:%.*]] = load atomic i8, i8* [[SRC:%.*]] unordered, align 1
; CHECK-NEXT:    store atomic i8 [[TMP1]], i8* [[DEST:%.*]] unordered, align 1
; CHECK-NEXT:    call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 1 [[DEST]], i8* nonnull align 1 [[SRC]], i32 2, i32 1)
; CHECK-NEXT:    call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 1 [[DEST]], i8* nonnull align 1 [[SRC]], i32 4, i32 1)
; CHECK-NEXT:    call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 1 [[DEST]], i8* nonnull align 1 [[SRC]], i32 8, i32 1)
; CHECK-NEXT:    call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 1 [[DEST]], i8* nonnull align 1 [[SRC]], i32 16, i32 1)
; CHECK-NEXT:    ret void
;
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 1 %dest, i8* align 1 %src, i32 1, i32 1)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 1 %dest, i8* align 1 %src, i32 2, i32 1)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 1 %dest, i8* align 1 %src, i32 4, i32 1)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 1 %dest, i8* align 1 %src, i32 8, i32 1)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 1 %dest, i8* align 1 %src, i32 16, i32 1)
  ret void
}

define void @test_memmove_loadstore_2(i8* %dest, i8* %src) {
; CHECK-LABEL: @test_memmove_loadstore_2(
; CHECK-NEXT:    [[TMP1:%.*]] = load atomic i8, i8* [[SRC:%.*]] unordered, align 2
; CHECK-NEXT:    store atomic i8 [[TMP1]], i8* [[DEST:%.*]] unordered, align 2
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8* [[SRC]] to i16*
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i8* [[DEST]] to i16*
; CHECK-NEXT:    [[TMP4:%.*]] = load atomic i16, i16* [[TMP2]] unordered, align 2
; CHECK-NEXT:    store atomic i16 [[TMP4]], i16* [[TMP3]] unordered, align 2
; CHECK-NEXT:    call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 2 [[DEST]], i8* nonnull align 2 [[SRC]], i32 4, i32 2)
; CHECK-NEXT:    call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 2 [[DEST]], i8* nonnull align 2 [[SRC]], i32 8, i32 2)
; CHECK-NEXT:    call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 2 [[DEST]], i8* nonnull align 2 [[SRC]], i32 16, i32 2)
; CHECK-NEXT:    ret void
;
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 2 %dest, i8* align 2 %src, i32 1, i32 1)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 2 %dest, i8* align 2 %src, i32 2, i32 2)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 2 %dest, i8* align 2 %src, i32 4, i32 2)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 2 %dest, i8* align 2 %src, i32 8, i32 2)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 2 %dest, i8* align 2 %src, i32 16, i32 2)
  ret void
}

define void @test_memmove_loadstore_4(i8* %dest, i8* %src) {
; CHECK-LABEL: @test_memmove_loadstore_4(
; CHECK-NEXT:    [[TMP1:%.*]] = load atomic i8, i8* [[SRC:%.*]] unordered, align 4
; CHECK-NEXT:    store atomic i8 [[TMP1]], i8* [[DEST:%.*]] unordered, align 4
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8* [[SRC]] to i16*
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i8* [[DEST]] to i16*
; CHECK-NEXT:    [[TMP4:%.*]] = load atomic i16, i16* [[TMP2]] unordered, align 4
; CHECK-NEXT:    store atomic i16 [[TMP4]], i16* [[TMP3]] unordered, align 4
; CHECK-NEXT:    [[TMP5:%.*]] = bitcast i8* [[SRC]] to i32*
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast i8* [[DEST]] to i32*
; CHECK-NEXT:    [[TMP7:%.*]] = load atomic i32, i32* [[TMP5]] unordered, align 4
; CHECK-NEXT:    store atomic i32 [[TMP7]], i32* [[TMP6]] unordered, align 4
; CHECK-NEXT:    call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 4 [[DEST]], i8* nonnull align 4 [[SRC]], i32 8, i32 4)
; CHECK-NEXT:    call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 4 [[DEST]], i8* nonnull align 4 [[SRC]], i32 16, i32 4)
; CHECK-NEXT:    ret void
;
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 4 %dest, i8* align 4 %src, i32 1, i32 1)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 4 %dest, i8* align 4 %src, i32 2, i32 2)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 4 %dest, i8* align 4 %src, i32 4, i32 4)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 4 %dest, i8* align 4 %src, i32 8, i32 4)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 4 %dest, i8* align 4 %src, i32 16, i32 4)
  ret void
}

define void @test_memmove_loadstore_8(i8* %dest, i8* %src) {
; CHECK-LABEL: @test_memmove_loadstore_8(
; CHECK-NEXT:    [[TMP1:%.*]] = load atomic i8, i8* [[SRC:%.*]] unordered, align 8
; CHECK-NEXT:    store atomic i8 [[TMP1]], i8* [[DEST:%.*]] unordered, align 8
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8* [[SRC]] to i16*
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i8* [[DEST]] to i16*
; CHECK-NEXT:    [[TMP4:%.*]] = load atomic i16, i16* [[TMP2]] unordered, align 8
; CHECK-NEXT:    store atomic i16 [[TMP4]], i16* [[TMP3]] unordered, align 8
; CHECK-NEXT:    [[TMP5:%.*]] = bitcast i8* [[SRC]] to i32*
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast i8* [[DEST]] to i32*
; CHECK-NEXT:    [[TMP7:%.*]] = load atomic i32, i32* [[TMP5]] unordered, align 8
; CHECK-NEXT:    store atomic i32 [[TMP7]], i32* [[TMP6]] unordered, align 8
; CHECK-NEXT:    [[TMP8:%.*]] = bitcast i8* [[SRC]] to i64*
; CHECK-NEXT:    [[TMP9:%.*]] = bitcast i8* [[DEST]] to i64*
; CHECK-NEXT:    [[TMP10:%.*]] = load atomic i64, i64* [[TMP8]] unordered, align 8
; CHECK-NEXT:    store atomic i64 [[TMP10]], i64* [[TMP9]] unordered, align 8
; CHECK-NEXT:    call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 8 [[DEST]], i8* nonnull align 8 [[SRC]], i32 16, i32 8)
; CHECK-NEXT:    ret void
;
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 8 %dest, i8* align 8 %src, i32 1, i32 1)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 8 %dest, i8* align 8 %src, i32 2, i32 2)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 8 %dest, i8* align 8 %src, i32 4, i32 4)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 8 %dest, i8* align 8 %src, i32 8, i32 8)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 8 %dest, i8* align 8 %src, i32 16, i32 8)
  ret void
}

define void @test_memmove_loadstore_16(i8* %dest, i8* %src) {
; CHECK-LABEL: @test_memmove_loadstore_16(
; CHECK-NEXT:    [[TMP1:%.*]] = load atomic i8, i8* [[SRC:%.*]] unordered, align 16
; CHECK-NEXT:    store atomic i8 [[TMP1]], i8* [[DEST:%.*]] unordered, align 16
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8* [[SRC]] to i16*
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i8* [[DEST]] to i16*
; CHECK-NEXT:    [[TMP4:%.*]] = load atomic i16, i16* [[TMP2]] unordered, align 16
; CHECK-NEXT:    store atomic i16 [[TMP4]], i16* [[TMP3]] unordered, align 16
; CHECK-NEXT:    [[TMP5:%.*]] = bitcast i8* [[SRC]] to i32*
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast i8* [[DEST]] to i32*
; CHECK-NEXT:    [[TMP7:%.*]] = load atomic i32, i32* [[TMP5]] unordered, align 16
; CHECK-NEXT:    store atomic i32 [[TMP7]], i32* [[TMP6]] unordered, align 16
; CHECK-NEXT:    [[TMP8:%.*]] = bitcast i8* [[SRC]] to i64*
; CHECK-NEXT:    [[TMP9:%.*]] = bitcast i8* [[DEST]] to i64*
; CHECK-NEXT:    [[TMP10:%.*]] = load atomic i64, i64* [[TMP8]] unordered, align 16
; CHECK-NEXT:    store atomic i64 [[TMP10]], i64* [[TMP9]] unordered, align 16
; CHECK-NEXT:    call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 16 [[DEST]], i8* nonnull align 16 [[SRC]], i32 16, i32 16)
; CHECK-NEXT:    ret void
;
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %dest, i8* align 16 %src, i32 1, i32 1)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %dest, i8* align 16 %src, i32 2, i32 2)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %dest, i8* align 16 %src, i32 4, i32 4)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %dest, i8* align 16 %src, i32 8, i32 8)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %dest, i8* align 16 %src, i32 16, i32 16)
  ret void
}

declare void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* nocapture writeonly, i8* nocapture readonly, i32, i32) nounwind argmemonly

;; =========================================
;; ----- memcpy ------

define void @test_memcpy_zero_length(i8* %dest, i8* %src) {
; CHECK-LABEL: @test_memcpy_zero_length(
; CHECK-NEXT:    ret void
;
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 1 %dest, i8* align 1 %src, i32 0, i32 1)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 2 %dest, i8* align 2 %src, i32 0, i32 2)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 4 %dest, i8* align 4 %src, i32 0, i32 4)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 8 %dest, i8* align 8 %src, i32 0, i32 8)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %dest, i8* align 16 %src, i32 0, i32 16)
  ret void
}

; memcpy with src==dest is removed
define void @test_memcpy_removed(i8* %srcdest, i32 %sz) {
; CHECK-LABEL: @test_memcpy_removed(
; CHECK-NEXT:    ret void
;
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 1 %srcdest, i8* align 1 %srcdest, i32 %sz, i32 1)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 2 %srcdest, i8* align 2 %srcdest, i32 %sz, i32 2)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 4 %srcdest, i8* align 4 %srcdest, i32 %sz, i32 4)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 8 %srcdest, i8* align 8 %srcdest, i32 %sz, i32 8)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %srcdest, i8* align 16 %srcdest, i32 %sz, i32 16)
  ret void
}

; memcpy with a small constant length is converted to a load/store pair
define void @test_memcpy_loadstore(i8* %dest, i8* %src) {
; CHECK-LABEL: @test_memcpy_loadstore(
; CHECK-NEXT:    [[TMP1:%.*]] = load atomic i8, i8* [[SRC:%.*]] unordered, align 1
; CHECK-NEXT:    store atomic i8 [[TMP1]], i8* [[DEST:%.*]] unordered, align 1
; CHECK-NEXT:    call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 1 [[DEST]], i8* nonnull align 1 [[SRC]], i32 2, i32 1)
; CHECK-NEXT:    call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 1 [[DEST]], i8* nonnull align 1 [[SRC]], i32 4, i32 1)
; CHECK-NEXT:    call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 1 [[DEST]], i8* nonnull align 1 [[SRC]], i32 8, i32 1)
; CHECK-NEXT:    call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 1 [[DEST]], i8* nonnull align 1 [[SRC]], i32 16, i32 1)
; CHECK-NEXT:    ret void
;
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 1 %dest, i8* align 1 %src, i32 1, i32 1)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 1 %dest, i8* align 1 %src, i32 2, i32 1)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 1 %dest, i8* align 1 %src, i32 4, i32 1)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 1 %dest, i8* align 1 %src, i32 8, i32 1)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 1 %dest, i8* align 1 %src, i32 16, i32 1)
  ret void
}

define void @test_memcpy_loadstore_2(i8* %dest, i8* %src) {
; CHECK-LABEL: @test_memcpy_loadstore_2(
; CHECK-NEXT:    [[TMP1:%.*]] = load atomic i8, i8* [[SRC:%.*]] unordered, align 2
; CHECK-NEXT:    store atomic i8 [[TMP1]], i8* [[DEST:%.*]] unordered, align 2
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8* [[SRC]] to i16*
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i8* [[DEST]] to i16*
; CHECK-NEXT:    [[TMP4:%.*]] = load atomic i16, i16* [[TMP2]] unordered, align 2
; CHECK-NEXT:    store atomic i16 [[TMP4]], i16* [[TMP3]] unordered, align 2
; CHECK-NEXT:    call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 2 [[DEST]], i8* nonnull align 2 [[SRC]], i32 4, i32 2)
; CHECK-NEXT:    call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 2 [[DEST]], i8* nonnull align 2 [[SRC]], i32 8, i32 2)
; CHECK-NEXT:    call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 2 [[DEST]], i8* nonnull align 2 [[SRC]], i32 16, i32 2)
; CHECK-NEXT:    ret void
;
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 2 %dest, i8* align 2 %src, i32 1, i32 1)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 2 %dest, i8* align 2 %src, i32 2, i32 2)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 2 %dest, i8* align 2 %src, i32 4, i32 2)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 2 %dest, i8* align 2 %src, i32 8, i32 2)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 2 %dest, i8* align 2 %src, i32 16, i32 2)
  ret void
}

define void @test_memcpy_loadstore_4(i8* %dest, i8* %src) {
; CHECK-LABEL: @test_memcpy_loadstore_4(
; CHECK-NEXT:    [[TMP1:%.*]] = load atomic i8, i8* [[SRC:%.*]] unordered, align 4
; CHECK-NEXT:    store atomic i8 [[TMP1]], i8* [[DEST:%.*]] unordered, align 4
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8* [[SRC]] to i16*
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i8* [[DEST]] to i16*
; CHECK-NEXT:    [[TMP4:%.*]] = load atomic i16, i16* [[TMP2]] unordered, align 4
; CHECK-NEXT:    store atomic i16 [[TMP4]], i16* [[TMP3]] unordered, align 4
; CHECK-NEXT:    [[TMP5:%.*]] = bitcast i8* [[SRC]] to i32*
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast i8* [[DEST]] to i32*
; CHECK-NEXT:    [[TMP7:%.*]] = load atomic i32, i32* [[TMP5]] unordered, align 4
; CHECK-NEXT:    store atomic i32 [[TMP7]], i32* [[TMP6]] unordered, align 4
; CHECK-NEXT:    call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 4 [[DEST]], i8* nonnull align 4 [[SRC]], i32 8, i32 4)
; CHECK-NEXT:    call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 4 [[DEST]], i8* nonnull align 4 [[SRC]], i32 16, i32 4)
; CHECK-NEXT:    ret void
;
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 4 %dest, i8* align 4 %src, i32 1, i32 1)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 4 %dest, i8* align 4 %src, i32 2, i32 2)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 4 %dest, i8* align 4 %src, i32 4, i32 4)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 4 %dest, i8* align 4 %src, i32 8, i32 4)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 4 %dest, i8* align 4 %src, i32 16, i32 4)
  ret void
}

define void @test_memcpy_loadstore_8(i8* %dest, i8* %src) {
; CHECK-LABEL: @test_memcpy_loadstore_8(
; CHECK-NEXT:    [[TMP1:%.*]] = load atomic i8, i8* [[SRC:%.*]] unordered, align 8
; CHECK-NEXT:    store atomic i8 [[TMP1]], i8* [[DEST:%.*]] unordered, align 8
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8* [[SRC]] to i16*
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i8* [[DEST]] to i16*
; CHECK-NEXT:    [[TMP4:%.*]] = load atomic i16, i16* [[TMP2]] unordered, align 8
; CHECK-NEXT:    store atomic i16 [[TMP4]], i16* [[TMP3]] unordered, align 8
; CHECK-NEXT:    [[TMP5:%.*]] = bitcast i8* [[SRC]] to i32*
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast i8* [[DEST]] to i32*
; CHECK-NEXT:    [[TMP7:%.*]] = load atomic i32, i32* [[TMP5]] unordered, align 8
; CHECK-NEXT:    store atomic i32 [[TMP7]], i32* [[TMP6]] unordered, align 8
; CHECK-NEXT:    [[TMP8:%.*]] = bitcast i8* [[SRC]] to i64*
; CHECK-NEXT:    [[TMP9:%.*]] = bitcast i8* [[DEST]] to i64*
; CHECK-NEXT:    [[TMP10:%.*]] = load atomic i64, i64* [[TMP8]] unordered, align 8
; CHECK-NEXT:    store atomic i64 [[TMP10]], i64* [[TMP9]] unordered, align 8
; CHECK-NEXT:    call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 8 [[DEST]], i8* nonnull align 8 [[SRC]], i32 16, i32 8)
; CHECK-NEXT:    ret void
;
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 8 %dest, i8* align 8 %src, i32 1, i32 1)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 8 %dest, i8* align 8 %src, i32 2, i32 2)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 8 %dest, i8* align 8 %src, i32 4, i32 4)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 8 %dest, i8* align 8 %src, i32 8, i32 8)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 8 %dest, i8* align 8 %src, i32 16, i32 8)
  ret void
}

define void @test_memcpy_loadstore_16(i8* %dest, i8* %src) {
; CHECK-LABEL: @test_memcpy_loadstore_16(
; CHECK-NEXT:    [[TMP1:%.*]] = load atomic i8, i8* [[SRC:%.*]] unordered, align 16
; CHECK-NEXT:    store atomic i8 [[TMP1]], i8* [[DEST:%.*]] unordered, align 16
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8* [[SRC]] to i16*
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i8* [[DEST]] to i16*
; CHECK-NEXT:    [[TMP4:%.*]] = load atomic i16, i16* [[TMP2]] unordered, align 16
; CHECK-NEXT:    store atomic i16 [[TMP4]], i16* [[TMP3]] unordered, align 16
; CHECK-NEXT:    [[TMP5:%.*]] = bitcast i8* [[SRC]] to i32*
; CHECK-NEXT:    [[TMP6:%.*]] = bitcast i8* [[DEST]] to i32*
; CHECK-NEXT:    [[TMP7:%.*]] = load atomic i32, i32* [[TMP5]] unordered, align 16
; CHECK-NEXT:    store atomic i32 [[TMP7]], i32* [[TMP6]] unordered, align 16
; CHECK-NEXT:    [[TMP8:%.*]] = bitcast i8* [[SRC]] to i64*
; CHECK-NEXT:    [[TMP9:%.*]] = bitcast i8* [[DEST]] to i64*
; CHECK-NEXT:    [[TMP10:%.*]] = load atomic i64, i64* [[TMP8]] unordered, align 16
; CHECK-NEXT:    store atomic i64 [[TMP10]], i64* [[TMP9]] unordered, align 16
; CHECK-NEXT:    call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* nonnull align 16 [[DEST]], i8* nonnull align 16 [[SRC]], i32 16, i32 16)
; CHECK-NEXT:    ret void
;
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %dest, i8* align 16 %src, i32 1, i32 1)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %dest, i8* align 16 %src, i32 2, i32 2)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %dest, i8* align 16 %src, i32 4, i32 4)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %dest, i8* align 16 %src, i32 8, i32 8)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %dest, i8* align 16 %src, i32 16, i32 16)
  ret void
}

define void @test_undefined(i8* %dest, i8* %src) {
; CHECK-LABEL: @test_undefined(
entry:
  br i1 undef, label %ok, label %undefined
undefined:
; CHECK: undefined:
; CHECK-NEXT:    store i1 true, i1* undef
; CHECK-NEXT:    br label %ok
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %dest, i8* align 16 %src, i32 7, i32 4)
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %dest, i8* align 16 %src, i32 -8, i32 4)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %dest, i8* align 16 %src, i32 7, i32 4)
  call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i32(i8* align 16 %dest, i8* align 16 %src, i32 -8, i32 4)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 16 %dest, i8 1, i32 7, i32 4)
  call void @llvm.memset.element.unordered.atomic.p0i8.i32(i8* align 16 %dest, i8 1, i32 -8, i32 4)
  br label %ok
ok:
  ret void
}

declare void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i32(i8* nocapture writeonly, i8* nocapture readonly, i32, i32) nounwind argmemonly
