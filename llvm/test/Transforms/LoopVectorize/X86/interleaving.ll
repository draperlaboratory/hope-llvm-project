; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -mtriple=x86_64-pc_linux -loop-vectorize -instcombine < %s | FileCheck %s --check-prefix=SSE
; RUN: opt -S -mtriple=x86_64-pc_linux -loop-vectorize -instcombine -mcpu=sandybridge < %s | FileCheck %s --check-prefix=AVX
; RUN: opt -S -mtriple=x86_64-pc_linux -loop-vectorize -instcombine -mcpu=haswell < %s | FileCheck %s --check-prefix=AVX
; RUN: opt -S -mtriple=x86_64-pc_linux -loop-vectorize -instcombine -mcpu=slm < %s | FileCheck %s --check-prefix=SSE
; RUN: opt -S -mtriple=x86_64-pc_linux -loop-vectorize -instcombine -mcpu=atom < %s | FileCheck %s --check-prefix=SSE

define void @foo(i32* noalias nocapture %a, i32* noalias nocapture readonly %b) {
; SSE-LABEL: @foo(
; SSE-NEXT:  entry:
; SSE-NEXT:    br label [[FOR_BODY:%.*]]
; SSE:       for.cond.cleanup:
; SSE-NEXT:    ret void
; SSE:       for.body:
; SSE-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ]
; SSE-NEXT:    [[TMP0:%.*]] = shl nuw nsw i64 [[INDVARS_IV]], 1
; SSE-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, i32* [[B:%.*]], i64 [[TMP0]]
; SSE-NEXT:    [[TMP1:%.*]] = load i32, i32* [[ARRAYIDX]], align 4
; SSE-NEXT:    [[TMP2:%.*]] = or i64 [[TMP0]], 1
; SSE-NEXT:    [[ARRAYIDX3:%.*]] = getelementptr inbounds i32, i32* [[B]], i64 [[TMP2]]
; SSE-NEXT:    [[TMP3:%.*]] = load i32, i32* [[ARRAYIDX3]], align 4
; SSE-NEXT:    [[ADD4:%.*]] = add nsw i32 [[TMP3]], [[TMP1]]
; SSE-NEXT:    [[ARRAYIDX6:%.*]] = getelementptr inbounds i32, i32* [[A:%.*]], i64 [[INDVARS_IV]]
; SSE-NEXT:    store i32 [[ADD4]], i32* [[ARRAYIDX6]], align 4
; SSE-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; SSE-NEXT:    [[EXITCOND:%.*]] = icmp eq i64 [[INDVARS_IV_NEXT]], 1024
; SSE-NEXT:    br i1 [[EXITCOND]], label [[FOR_COND_CLEANUP:%.*]], label [[FOR_BODY]]
;
; AVX-LABEL: @foo(
; AVX-NEXT:  entry:
; AVX-NEXT:    br i1 false, label [[SCALAR_PH:%.*]], label [[VECTOR_PH:%.*]]
; AVX:       vector.ph:
; AVX-NEXT:    br label [[VECTOR_BODY:%.*]]
; AVX:       vector.body:
; AVX-NEXT:    [[INDEX:%.*]] = phi i64 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; AVX-NEXT:    [[TMP0:%.*]] = shl nsw i64 [[INDEX]], 1
; AVX-NEXT:    [[TMP1:%.*]] = getelementptr inbounds i32, i32* [[B:%.*]], i64 [[TMP0]]
; AVX-NEXT:    [[TMP2:%.*]] = bitcast i32* [[TMP1]] to <8 x i32>*
; AVX-NEXT:    [[WIDE_VEC:%.*]] = load <8 x i32>, <8 x i32>* [[TMP2]], align 4
; AVX-NEXT:    [[STRIDED_VEC:%.*]] = shufflevector <8 x i32> [[WIDE_VEC]], <8 x i32> poison, <4 x i32> <i32 0, i32 2, i32 4, i32 6>
; AVX-NEXT:    [[STRIDED_VEC1:%.*]] = shufflevector <8 x i32> [[WIDE_VEC]], <8 x i32> poison, <4 x i32> <i32 1, i32 3, i32 5, i32 7>
; AVX-NEXT:    [[TMP3:%.*]] = add nsw <4 x i32> [[STRIDED_VEC1]], [[STRIDED_VEC]]
; AVX-NEXT:    [[TMP4:%.*]] = getelementptr inbounds i32, i32* [[A:%.*]], i64 [[INDEX]]
; AVX-NEXT:    [[TMP5:%.*]] = bitcast i32* [[TMP4]] to <4 x i32>*
; AVX-NEXT:    store <4 x i32> [[TMP3]], <4 x i32>* [[TMP5]], align 4
; AVX-NEXT:    [[INDEX_NEXT]] = add i64 [[INDEX]], 4
; AVX-NEXT:    [[TMP6:%.*]] = icmp eq i64 [[INDEX_NEXT]], 1024
; AVX-NEXT:    br i1 [[TMP6]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], [[LOOP0:!llvm.loop !.*]]
; AVX:       middle.block:
; AVX-NEXT:    br i1 true, label [[FOR_COND_CLEANUP:%.*]], label [[SCALAR_PH]]
; AVX:       scalar.ph:
; AVX-NEXT:    br label [[FOR_BODY:%.*]]
; AVX:       for.cond.cleanup:
; AVX-NEXT:    ret void
; AVX:       for.body:
; AVX-NEXT:    br i1 undef, label [[FOR_COND_CLEANUP]], label [[FOR_BODY]], [[LOOP2:!llvm.loop !.*]]
;
entry:
  br label %for.body

for.cond.cleanup:                                 ; preds = %for.body
  ret void

for.body:                                         ; preds = %for.body, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %0 = shl nsw i64 %indvars.iv, 1
  %arrayidx = getelementptr inbounds i32, i32* %b, i64 %0
  %1 = load i32, i32* %arrayidx, align 4
  %2 = or i64 %0, 1
  %arrayidx3 = getelementptr inbounds i32, i32* %b, i64 %2
  %3 = load i32, i32* %arrayidx3, align 4
  %add4 = add nsw i32 %3, %1
  %arrayidx6 = getelementptr inbounds i32, i32* %a, i64 %indvars.iv
  store i32 %add4, i32* %arrayidx6, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %exitcond = icmp eq i64 %indvars.iv.next, 1024
  br i1 %exitcond, label %for.cond.cleanup, label %for.body
}
