; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -slp-vectorizer < %s -S -o - -mtriple=x86_64-apple-macosx10.10.0 -mcpu=core2 | FileCheck %s

define void @_Z10fooConvertPDv4_xS0_S0_PKS_() {
; CHECK-LABEL: @_Z10fooConvertPDv4_xS0_S0_PKS_(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = extractelement <16 x half> undef, i32 4
; CHECK-NEXT:    [[TMP1:%.*]] = extractelement <16 x half> undef, i32 5
; CHECK-NEXT:    [[TMP2:%.*]] = insertelement <2 x half> poison, half [[TMP0]], i32 0
; CHECK-NEXT:    [[TMP3:%.*]] = insertelement <2 x half> [[TMP2]], half [[TMP1]], i32 1
; CHECK-NEXT:    [[TMP4:%.*]] = fpext <2 x half> [[TMP3]] to <2 x float>
; CHECK-NEXT:    [[TMP5:%.*]] = bitcast <2 x float> [[TMP4]] to <2 x i32>
; CHECK-NEXT:    [[TMP6:%.*]] = extractelement <2 x i32> [[TMP5]], i32 0
; CHECK-NEXT:    [[VECINS_I_4_I:%.*]] = insertelement <8 x i32> poison, i32 [[TMP6]], i32 4
; CHECK-NEXT:    [[TMP7:%.*]] = extractelement <2 x i32> [[TMP5]], i32 1
; CHECK-NEXT:    [[VECINS_I_5_I:%.*]] = insertelement <8 x i32> [[VECINS_I_4_I]], i32 [[TMP7]], i32 5
; CHECK-NEXT:    ret void
;
entry:
  %0 = extractelement <16 x half> undef, i32 4
  %conv.i.4.i = fpext half %0 to float
  %1 = bitcast float %conv.i.4.i to i32
  %vecins.i.4.i = insertelement <8 x i32> poison, i32 %1, i32 4
  %2 = extractelement <16 x half> undef, i32 5
  %conv.i.5.i = fpext half %2 to float
  %3 = bitcast float %conv.i.5.i to i32
  %vecins.i.5.i = insertelement <8 x i32> %vecins.i.4.i, i32 %3, i32 5
  ret void
}
