; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -slp-vectorizer -instcombine -S -mtriple=x86_64-unknown-linux-gnu -mcpu=corei7 | FileCheck %s

define float @dotf(<4 x float> %x, <4 x float> %y) {
; CHECK-LABEL: @dotf(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = fmul fast <4 x float> [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = call fast float @llvm.vector.reduce.fadd.v4f32(float 0.000000e+00, <4 x float> [[TMP0]])
; CHECK-NEXT:    ret float [[TMP1]]
;
entry:
  %vecext = extractelement <4 x float> %x, i32 0
  %vecext1 = extractelement <4 x float> %y, i32 0
  %mul = fmul fast float %vecext, %vecext1
  %vecext.1 = extractelement <4 x float> %x, i32 1
  %vecext1.1 = extractelement <4 x float> %y, i32 1
  %mul.1 = fmul fast float %vecext.1, %vecext1.1
  %add.1 = fadd fast float %mul.1, %mul
  %vecext.2 = extractelement <4 x float> %x, i32 2
  %vecext1.2 = extractelement <4 x float> %y, i32 2
  %mul.2 = fmul fast float %vecext.2, %vecext1.2
  %add.2 = fadd fast float %mul.2, %add.1
  %vecext.3 = extractelement <4 x float> %x, i32 3
  %vecext1.3 = extractelement <4 x float> %y, i32 3
  %mul.3 = fmul fast float %vecext.3, %vecext1.3
  %add.3 = fadd fast float %mul.3, %add.2
  ret float %add.3
}

define double @dotd(<4 x double>* byval nocapture readonly align 32, <4 x double>* byval nocapture readonly align 32) {
; CHECK-LABEL: @dotd(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[X:%.*]] = load <4 x double>, <4 x double>* [[TMP0:%.*]], align 32
; CHECK-NEXT:    [[Y:%.*]] = load <4 x double>, <4 x double>* [[TMP1:%.*]], align 32
; CHECK-NEXT:    [[TMP2:%.*]] = fmul fast <4 x double> [[X]], [[Y]]
; CHECK-NEXT:    [[TMP3:%.*]] = call fast double @llvm.vector.reduce.fadd.v4f64(double 0.000000e+00, <4 x double> [[TMP2]])
; CHECK-NEXT:    ret double [[TMP3]]
;
entry:
  %x = load <4 x double>, <4 x double>* %0, align 32
  %y = load <4 x double>, <4 x double>* %1, align 32
  %vecext = extractelement <4 x double> %x, i32 0
  %vecext1 = extractelement <4 x double> %y, i32 0
  %mul = fmul fast double %vecext, %vecext1
  %vecext.1 = extractelement <4 x double> %x, i32 1
  %vecext1.1 = extractelement <4 x double> %y, i32 1
  %mul.1 = fmul fast double %vecext.1, %vecext1.1
  %add.1 = fadd fast double %mul.1, %mul
  %vecext.2 = extractelement <4 x double> %x, i32 2
  %vecext1.2 = extractelement <4 x double> %y, i32 2
  %mul.2 = fmul fast double %vecext.2, %vecext1.2
  %add.2 = fadd fast double %mul.2, %add.1
  %vecext.3 = extractelement <4 x double> %x, i32 3
  %vecext1.3 = extractelement <4 x double> %y, i32 3
  %mul.3 = fmul fast double %vecext.3, %vecext1.3
  %add.3 = fadd fast double %mul.3, %add.2
  ret double %add.3
}

define float @dotfq(<4 x float>* nocapture readonly %x, <4 x float>* nocapture readonly %y) {
; CHECK-LABEL: @dotfq(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = load <4 x float>, <4 x float>* [[X:%.*]], align 16
; CHECK-NEXT:    [[TMP1:%.*]] = load <4 x float>, <4 x float>* [[Y:%.*]], align 16
; CHECK-NEXT:    [[TMP2:%.*]] = fmul fast <4 x float> [[TMP1]], [[TMP0]]
; CHECK-NEXT:    [[TMP3:%.*]] = call fast float @llvm.vector.reduce.fadd.v4f32(float 0.000000e+00, <4 x float> [[TMP2]])
; CHECK-NEXT:    ret float [[TMP3]]
;
entry:
  %0 = load <4 x float>, <4 x float>* %x, align 16
  %1 = load <4 x float>, <4 x float>* %y, align 16
  %vecext = extractelement <4 x float> %0, i32 0
  %vecext1 = extractelement <4 x float> %1, i32 0
  %mul = fmul fast float %vecext1, %vecext
  %vecext.1 = extractelement <4 x float> %0, i32 1
  %vecext1.1 = extractelement <4 x float> %1, i32 1
  %mul.1 = fmul fast float %vecext1.1, %vecext.1
  %add.1 = fadd fast float %mul.1, %mul
  %vecext.2 = extractelement <4 x float> %0, i32 2
  %vecext1.2 = extractelement <4 x float> %1, i32 2
  %mul.2 = fmul fast float %vecext1.2, %vecext.2
  %add.2 = fadd fast float %mul.2, %add.1
  %vecext.3 = extractelement <4 x float> %0, i32 3
  %vecext1.3 = extractelement <4 x float> %1, i32 3
  %mul.3 = fmul fast float %vecext1.3, %vecext.3
  %add.3 = fadd fast float %mul.3, %add.2
  ret float %add.3
}

define double @dotdq(<4 x double>* nocapture readonly %x, <4 x double>* nocapture readonly %y) {
; CHECK-LABEL: @dotdq(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = load <4 x double>, <4 x double>* [[X:%.*]], align 32
; CHECK-NEXT:    [[TMP1:%.*]] = load <4 x double>, <4 x double>* [[Y:%.*]], align 32
; CHECK-NEXT:    [[TMP2:%.*]] = fmul fast <4 x double> [[TMP1]], [[TMP0]]
; CHECK-NEXT:    [[TMP3:%.*]] = call fast double @llvm.vector.reduce.fadd.v4f64(double 0.000000e+00, <4 x double> [[TMP2]])
; CHECK-NEXT:    ret double [[TMP3]]
;
entry:
  %0 = load <4 x double>, <4 x double>* %x, align 32
  %1 = load <4 x double>, <4 x double>* %y, align 32
  %vecext = extractelement <4 x double> %0, i32 0
  %vecext1 = extractelement <4 x double> %1, i32 0
  %mul = fmul fast double %vecext1, %vecext
  %vecext.1 = extractelement <4 x double> %0, i32 1
  %vecext1.1 = extractelement <4 x double> %1, i32 1
  %mul.1 = fmul fast double %vecext1.1, %vecext.1
  %add.1 = fadd fast double %mul.1, %mul
  %vecext.2 = extractelement <4 x double> %0, i32 2
  %vecext1.2 = extractelement <4 x double> %1, i32 2
  %mul.2 = fmul fast double %vecext1.2, %vecext.2
  %add.2 = fadd fast double %mul.2, %add.1
  %vecext.3 = extractelement <4 x double> %0, i32 3
  %vecext1.3 = extractelement <4 x double> %1, i32 3
  %mul.3 = fmul fast double %vecext1.3, %vecext.3
  %add.3 = fadd fast double %mul.3, %add.2
  ret double %add.3
}
