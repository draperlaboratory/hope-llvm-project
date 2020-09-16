; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -basic-aa -slp-vectorizer -dce -S -mtriple=x86_64-apple-macosx10.8.0 -mcpu=corei7-avx | FileCheck %s

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.7.0"

@.str = private unnamed_addr constant [6 x i8] c"bingo\00", align 1

define void @reduce_compare(double* nocapture %A, i32 %n) {
; CHECK-LABEL: @reduce_compare(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CONV:%.*]] = sitofp i32 [[N:%.*]] to double
; CHECK-NEXT:    [[TMP0:%.*]] = insertelement <2 x double> undef, double [[CONV]], i32 0
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <2 x double> [[TMP0]], double [[CONV]], i32 1
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[INDVARS_IV_NEXT:%.*]], [[FOR_INC:%.*]] ]
; CHECK-NEXT:    [[TMP2:%.*]] = shl nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds double, double* [[A:%.*]], i64 [[TMP2]]
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast double* [[ARRAYIDX]] to <2 x double>*
; CHECK-NEXT:    [[TMP4:%.*]] = load <2 x double>, <2 x double>* [[TMP3]], align 8
; CHECK-NEXT:    [[TMP5:%.*]] = fmul <2 x double> [[TMP1]], [[TMP4]]
; CHECK-NEXT:    [[TMP6:%.*]] = fmul <2 x double> [[TMP5]], <double 7.000000e+00, double 4.000000e+00>
; CHECK-NEXT:    [[TMP7:%.*]] = fadd <2 x double> [[TMP6]], <double 5.000000e+00, double 9.000000e+00>
; CHECK-NEXT:    [[TMP8:%.*]] = extractelement <2 x double> [[TMP7]], i32 0
; CHECK-NEXT:    [[TMP9:%.*]] = extractelement <2 x double> [[TMP7]], i32 1
; CHECK-NEXT:    [[CMP11:%.*]] = fcmp ogt double [[TMP8]], [[TMP9]]
; CHECK-NEXT:    br i1 [[CMP11]], label [[IF_THEN:%.*]], label [[FOR_INC]]
; CHECK:       if.then:
; CHECK-NEXT:    [[CALL:%.*]] = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str, i64 0, i64 0))
; CHECK-NEXT:    br label [[FOR_INC]]
; CHECK:       for.inc:
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[LFTR_WIDEIV:%.*]] = trunc i64 [[INDVARS_IV_NEXT]] to i32
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp eq i32 [[LFTR_WIDEIV]], 100
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[FOR_END:%.*]], label [[FOR_BODY]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
;
entry:
  %conv = sitofp i32 %n to double
  br label %for.body

for.body:                                         ; preds = %for.inc, %entry
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.inc ]
  %0 = shl nsw i64 %indvars.iv, 1
  %arrayidx = getelementptr inbounds double, double* %A, i64 %0
  %1 = load double, double* %arrayidx, align 8
  %mul1 = fmul double %conv, %1
  %mul2 = fmul double %mul1, 7.000000e+00
  %add = fadd double %mul2, 5.000000e+00
  %2 = or i64 %0, 1
  %arrayidx6 = getelementptr inbounds double, double* %A, i64 %2
  %3 = load double, double* %arrayidx6, align 8
  %mul8 = fmul double %conv, %3
  %mul9 = fmul double %mul8, 4.000000e+00
  %add10 = fadd double %mul9, 9.000000e+00
  %cmp11 = fcmp ogt double %add, %add10
  br i1 %cmp11, label %if.then, label %for.inc

if.then:                                          ; preds = %for.body
  %call = tail call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str, i64 0, i64 0))
  br label %for.inc

for.inc:                                          ; preds = %for.body, %if.then
  %indvars.iv.next = add i64 %indvars.iv, 1
  %lftr.wideiv = trunc i64 %indvars.iv.next to i32
  %exitcond = icmp eq i32 %lftr.wideiv, 100
  br i1 %exitcond, label %for.end, label %for.body

for.end:                                          ; preds = %for.inc
  ret void
}

declare i32 @printf(i8* nocapture, ...)

; PR41312 - the order of the reduction ops should not prevent forming a reduction.
; The 'wrong' member of the reduction requires a greater cost if grouped with the
; other candidates in the reduction because it does not have matching predicate
; and/or constant operand.

define float @merge_anyof_v4f32_wrong_first(<4 x float> %x) {
; CHECK-LABEL: @merge_anyof_v4f32_wrong_first(
; CHECK-NEXT:    [[X0:%.*]] = extractelement <4 x float> [[X:%.*]], i32 0
; CHECK-NEXT:    [[X1:%.*]] = extractelement <4 x float> [[X]], i32 1
; CHECK-NEXT:    [[X2:%.*]] = extractelement <4 x float> [[X]], i32 2
; CHECK-NEXT:    [[X3:%.*]] = extractelement <4 x float> [[X]], i32 3
; CHECK-NEXT:    [[CMP3WRONG:%.*]] = fcmp olt float [[X3]], 4.200000e+01
; CHECK-NEXT:    [[CMP0:%.*]] = fcmp ogt float [[X0]], 1.000000e+00
; CHECK-NEXT:    [[CMP1:%.*]] = fcmp ogt float [[X1]], 1.000000e+00
; CHECK-NEXT:    [[CMP2:%.*]] = fcmp ogt float [[X2]], 1.000000e+00
; CHECK-NEXT:    [[CMP3:%.*]] = fcmp ogt float [[X3]], 1.000000e+00
; CHECK-NEXT:    [[OR03:%.*]] = or i1 [[CMP0]], [[CMP3WRONG]]
; CHECK-NEXT:    [[OR031:%.*]] = or i1 [[OR03]], [[CMP1]]
; CHECK-NEXT:    [[OR0312:%.*]] = or i1 [[OR031]], [[CMP2]]
; CHECK-NEXT:    [[OR03123:%.*]] = or i1 [[OR0312]], [[CMP3]]
; CHECK-NEXT:    [[R:%.*]] = select i1 [[OR03123]], float -1.000000e+00, float 1.000000e+00
; CHECK-NEXT:    ret float [[R]]
;
  %x0 = extractelement <4 x float> %x, i32 0
  %x1 = extractelement <4 x float> %x, i32 1
  %x2 = extractelement <4 x float> %x, i32 2
  %x3 = extractelement <4 x float> %x, i32 3
  %cmp3wrong = fcmp olt float %x3, 42.0
  %cmp0 = fcmp ogt float %x0, 1.0
  %cmp1 = fcmp ogt float %x1, 1.0
  %cmp2 = fcmp ogt float %x2, 1.0
  %cmp3 = fcmp ogt float %x3, 1.0
  %or03 = or i1 %cmp0, %cmp3wrong
  %or031 = or i1 %or03, %cmp1
  %or0312 = or i1 %or031, %cmp2
  %or03123 = or i1 %or0312, %cmp3
  %r = select i1 %or03123, float -1.0, float 1.0
  ret float %r
}

define float @merge_anyof_v4f32_wrong_last(<4 x float> %x) {
; CHECK-LABEL: @merge_anyof_v4f32_wrong_last(
; CHECK-NEXT:    [[TMP1:%.*]] = extractelement <4 x float> [[X:%.*]], i32 3
; CHECK-NEXT:    [[CMP3WRONG:%.*]] = fcmp olt float [[TMP1]], 4.200000e+01
; CHECK-NEXT:    [[TMP2:%.*]] = fcmp ogt <4 x float> [[X]], <float 1.000000e+00, float 1.000000e+00, float 1.000000e+00, float 1.000000e+00>
; CHECK-NEXT:    [[TMP3:%.*]] = call i1 @llvm.experimental.vector.reduce.or.v4i1(<4 x i1> [[TMP2]])
; CHECK-NEXT:    [[TMP4:%.*]] = or i1 [[TMP3]], [[CMP3WRONG]]
; CHECK-NEXT:    [[R:%.*]] = select i1 [[TMP4]], float -1.000000e+00, float 1.000000e+00
; CHECK-NEXT:    ret float [[R]]
;
  %x0 = extractelement <4 x float> %x, i32 0
  %x1 = extractelement <4 x float> %x, i32 1
  %x2 = extractelement <4 x float> %x, i32 2
  %x3 = extractelement <4 x float> %x, i32 3
  %cmp3wrong = fcmp olt float %x3, 42.0
  %cmp0 = fcmp ogt float %x0, 1.0
  %cmp1 = fcmp ogt float %x1, 1.0
  %cmp2 = fcmp ogt float %x2, 1.0
  %cmp3 = fcmp ogt float %x3, 1.0
  %or03 = or i1 %cmp0, %cmp3
  %or031 = or i1 %or03, %cmp1
  %or0312 = or i1 %or031, %cmp2
  %or03123 = or i1 %or0312, %cmp3wrong
  %r = select i1 %or03123, float -1.0, float 1.0
  ret float %r
}

define i32 @merge_anyof_v4i32_wrong_middle(<4 x i32> %x) {
; CHECK-LABEL: @merge_anyof_v4i32_wrong_middle(
; CHECK-NEXT:    [[X0:%.*]] = extractelement <4 x i32> [[X:%.*]], i32 0
; CHECK-NEXT:    [[X1:%.*]] = extractelement <4 x i32> [[X]], i32 1
; CHECK-NEXT:    [[X2:%.*]] = extractelement <4 x i32> [[X]], i32 2
; CHECK-NEXT:    [[X3:%.*]] = extractelement <4 x i32> [[X]], i32 3
; CHECK-NEXT:    [[CMP3WRONG:%.*]] = icmp slt i32 [[X3]], 42
; CHECK-NEXT:    [[CMP0:%.*]] = icmp sgt i32 [[X0]], 1
; CHECK-NEXT:    [[CMP1:%.*]] = icmp sgt i32 [[X1]], 1
; CHECK-NEXT:    [[CMP2:%.*]] = icmp sgt i32 [[X2]], 1
; CHECK-NEXT:    [[CMP3:%.*]] = icmp sgt i32 [[X3]], 1
; CHECK-NEXT:    [[OR03:%.*]] = or i1 [[CMP0]], [[CMP3]]
; CHECK-NEXT:    [[OR033:%.*]] = or i1 [[OR03]], [[CMP3WRONG]]
; CHECK-NEXT:    [[OR0332:%.*]] = or i1 [[OR033]], [[CMP2]]
; CHECK-NEXT:    [[OR03321:%.*]] = or i1 [[OR0332]], [[CMP1]]
; CHECK-NEXT:    [[R:%.*]] = select i1 [[OR03321]], i32 -1, i32 1
; CHECK-NEXT:    ret i32 [[R]]
;
  %x0 = extractelement <4 x i32> %x, i32 0
  %x1 = extractelement <4 x i32> %x, i32 1
  %x2 = extractelement <4 x i32> %x, i32 2
  %x3 = extractelement <4 x i32> %x, i32 3
  %cmp3wrong = icmp slt i32 %x3, 42
  %cmp0 = icmp sgt i32 %x0, 1
  %cmp1 = icmp sgt i32 %x1, 1
  %cmp2 = icmp sgt i32 %x2, 1
  %cmp3 = icmp sgt i32 %x3, 1
  %or03 = or i1 %cmp0, %cmp3
  %or033 = or i1 %or03, %cmp3wrong
  %or0332 = or i1 %or033, %cmp2
  %or03321 = or i1 %or0332, %cmp1
  %r = select i1 %or03321, i32 -1, i32 1
  ret i32 %r
}

define i32 @merge_anyof_v4i32_wrong_middle_better_rdx(<4 x i32> %x, <4 x i32> %y) {
; CHECK-LABEL: @merge_anyof_v4i32_wrong_middle_better_rdx(
; CHECK-NEXT:    [[X0:%.*]] = extractelement <4 x i32> [[X:%.*]], i32 0
; CHECK-NEXT:    [[X1:%.*]] = extractelement <4 x i32> [[X]], i32 1
; CHECK-NEXT:    [[X2:%.*]] = extractelement <4 x i32> [[X]], i32 2
; CHECK-NEXT:    [[X3:%.*]] = extractelement <4 x i32> [[X]], i32 3
; CHECK-NEXT:    [[Y0:%.*]] = extractelement <4 x i32> [[Y:%.*]], i32 0
; CHECK-NEXT:    [[Y1:%.*]] = extractelement <4 x i32> [[Y]], i32 1
; CHECK-NEXT:    [[Y2:%.*]] = extractelement <4 x i32> [[Y]], i32 2
; CHECK-NEXT:    [[Y3:%.*]] = extractelement <4 x i32> [[Y]], i32 3
; CHECK-NEXT:    [[CMP1:%.*]] = icmp sgt i32 [[X1]], [[Y1]]
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <4 x i32> undef, i32 [[X0]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = insertelement <4 x i32> [[TMP1]], i32 [[X3]], i32 1
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <4 x i32> [[TMP2]], i32 [[Y3]], i32 2
; CHECK-NEXT:    [[TMP4:%.*]] = insertelement <4 x i32> [[TMP3]], i32 [[X2]], i32 3
; CHECK-NEXT:    [[TMP5:%.*]] = insertelement <4 x i32> undef, i32 [[Y0]], i32 0
; CHECK-NEXT:    [[TMP6:%.*]] = insertelement <4 x i32> [[TMP5]], i32 [[Y3]], i32 1
; CHECK-NEXT:    [[TMP7:%.*]] = insertelement <4 x i32> [[TMP6]], i32 [[X3]], i32 2
; CHECK-NEXT:    [[TMP8:%.*]] = insertelement <4 x i32> [[TMP7]], i32 [[Y2]], i32 3
; CHECK-NEXT:    [[TMP9:%.*]] = icmp sgt <4 x i32> [[TMP4]], [[TMP8]]
; CHECK-NEXT:    [[TMP10:%.*]] = call i1 @llvm.experimental.vector.reduce.or.v4i1(<4 x i1> [[TMP9]])
; CHECK-NEXT:    [[TMP11:%.*]] = or i1 [[TMP10]], [[CMP1]]
; CHECK-NEXT:    [[R:%.*]] = select i1 [[TMP11]], i32 -1, i32 1
; CHECK-NEXT:    ret i32 [[R]]
;
  %x0 = extractelement <4 x i32> %x, i32 0
  %x1 = extractelement <4 x i32> %x, i32 1
  %x2 = extractelement <4 x i32> %x, i32 2
  %x3 = extractelement <4 x i32> %x, i32 3
  %y0 = extractelement <4 x i32> %y, i32 0
  %y1 = extractelement <4 x i32> %y, i32 1
  %y2 = extractelement <4 x i32> %y, i32 2
  %y3 = extractelement <4 x i32> %y, i32 3
  %cmp3wrong = icmp slt i32 %x3, %y3
  %cmp0 = icmp sgt i32 %x0, %y0
  %cmp1 = icmp sgt i32 %x1, %y1
  %cmp2 = icmp sgt i32 %x2, %y2
  %cmp3 = icmp sgt i32 %x3, %y3
  %or03 = or i1 %cmp0, %cmp3
  %or033 = or i1 %or03, %cmp3wrong
  %or0332 = or i1 %or033, %cmp2
  %or03321 = or i1 %or0332, %cmp1
  %r = select i1 %or03321, i32 -1, i32 1
  ret i32 %r
}
