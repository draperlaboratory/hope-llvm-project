; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mcpu=pwr9 -ppc-asm-full-reg-names -ppc-vsr-nums-as-vr \
; RUN:   -mtriple=powerpc64-unknown-unknown < %s | FileCheck %s \
; RUN:   -check-prefix=P9
; RUN: llc -mcpu=pwr8 -ppc-asm-full-reg-names -ppc-vsr-nums-as-vr \
; RUN:   -mtriple=powerpc64le-unknown-unknown < %s | FileCheck %s \
; RUN:   -check-prefix=P8
define dso_local void @test(<2 x double>* nocapture %c, double* nocapture readonly %a) local_unnamed_addr {
; P9-LABEL: test:
; P9:       # %bb.0: # %entry
; P9-NEXT:    addi r4, r4, 24
; P9-NEXT:    lxvdsx vs0, 0, r4
; P9-NEXT:    stxv vs0, 0(r3)
; P9-NEXT:    blr
;
; P8-LABEL: test:
; P8:       # %bb.0: # %entry
; P8-NEXT:    addi r4, r4, 24
; P8-NEXT:    lxvdsx vs0, 0, r4
; P8-NEXT:    stxvd2x vs0, 0, r3
; P8-NEXT:    blr
entry:
  %arrayidx = getelementptr inbounds double, double* %a, i64 3
  %0 = load double, double* %arrayidx, align 8
  %splat.splatinsert.i = insertelement <2 x double> undef, double %0, i32 0
  %splat.splat.i = shufflevector <2 x double> %splat.splatinsert.i, <2 x double> undef, <2 x i32> zeroinitializer
  store <2 x double> %splat.splat.i, <2 x double>* %c, align 16
  ret void
}

define dso_local void @test2(<4 x float>* nocapture %c, float* nocapture readonly %a) local_unnamed_addr {
; P9-LABEL: test2:
; P9:       # %bb.0: # %entry
; P9-NEXT:    addi r4, r4, 12
; P9-NEXT:    lxvwsx vs0, 0, r4
; P9-NEXT:    stxv vs0, 0(r3)
; P9-NEXT:    blr
;
; P8-LABEL: test2:
; P8:       # %bb.0: # %entry
; P8-NEXT:    addi r4, r4, 12
; P8-NEXT:    lfiwzx f0, 0, r4
; P8-NEXT:    xxswapd vs0, f0
; P8-NEXT:    xxspltw v2, vs0, 3
; P8-NEXT:    stvx v2, 0, r3
; P8-NEXT:    blr
entry:
  %arrayidx = getelementptr inbounds float, float* %a, i64 3
  %0 = load float, float* %arrayidx, align 4
  %splat.splatinsert.i = insertelement <4 x float> undef, float %0, i32 0
  %splat.splat.i = shufflevector <4 x float> %splat.splatinsert.i, <4 x float> undef, <4 x i32> zeroinitializer
  store <4 x float> %splat.splat.i, <4 x float>* %c, align 16
  ret void
}

define dso_local void @test3(<4 x i32>* nocapture %c, i32* nocapture readonly %a) local_unnamed_addr {
; P9-LABEL: test3:
; P9:       # %bb.0: # %entry
; P9-NEXT:    addi r4, r4, 12
; P9-NEXT:    lxvwsx vs0, 0, r4
; P9-NEXT:    stxv vs0, 0(r3)
; P9-NEXT:    blr
;
; P8-LABEL: test3:
; P8:       # %bb.0: # %entry
; P8-NEXT:    addi r4, r4, 12
; P8-NEXT:    lfiwzx f0, 0, r4
; P8-NEXT:    xxswapd vs0, f0
; P8-NEXT:    xxspltw v2, vs0, 3
; P8-NEXT:    stvx v2, 0, r3
; P8-NEXT:    blr
entry:
  %arrayidx = getelementptr inbounds i32, i32* %a, i64 3
  %0 = load i32, i32* %arrayidx, align 4
  %splat.splatinsert.i = insertelement <4 x i32> undef, i32 %0, i32 0
  %splat.splat.i = shufflevector <4 x i32> %splat.splatinsert.i, <4 x i32> undef, <4 x i32> zeroinitializer
  store <4 x i32> %splat.splat.i, <4 x i32>* %c, align 16
  ret void
}

define dso_local void @test4(<2 x i64>* nocapture %c, i64* nocapture readonly %a) local_unnamed_addr {
; P9-LABEL: test4:
; P9:       # %bb.0: # %entry
; P9-NEXT:    addi r4, r4, 24
; P9-NEXT:    lxvdsx vs0, 0, r4
; P9-NEXT:    stxv vs0, 0(r3)
; P9-NEXT:    blr
;
; P8-LABEL: test4:
; P8:       # %bb.0: # %entry
; P8-NEXT:    addi r4, r4, 24
; P8-NEXT:    lxvdsx vs0, 0, r4
; P8-NEXT:    stxvd2x vs0, 0, r3
; P8-NEXT:    blr
entry:
  %arrayidx = getelementptr inbounds i64, i64* %a, i64 3
  %0 = load i64, i64* %arrayidx, align 8
  %splat.splatinsert.i = insertelement <2 x i64> undef, i64 %0, i32 0
  %splat.splat.i = shufflevector <2 x i64> %splat.splatinsert.i, <2 x i64> undef, <2 x i32> zeroinitializer
  store <2 x i64> %splat.splat.i, <2 x i64>* %c, align 16
  ret void
}

define <16 x i8> @unadjusted_lxvwsx(i32* %s, i32* %t) {
; P9-LABEL: unadjusted_lxvwsx:
; P9:       # %bb.0: # %entry
; P9-NEXT:    lxvwsx v2, 0, r3
; P9-NEXT:    blr
;
; P8-LABEL: unadjusted_lxvwsx:
; P8:       # %bb.0: # %entry
; P8-NEXT:    lfiwzx f0, 0, r3
; P8-NEXT:    xxswapd vs0, f0
; P8-NEXT:    xxspltw v2, vs0, 3
; P8-NEXT:    blr
  entry:
    %0 = bitcast i32* %s to <4 x i8>*
    %1 = load <4 x i8>, <4 x i8>* %0, align 4
    %2 = shufflevector <4 x i8> %1, <4 x i8> undef, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 0, i32 1, i32 2, i32 3, i32 0, i32 1, i32 2, i32 3, i32 0, i32 1, i32 2, i32 3>
    ret <16 x i8> %2
}

define <16 x i8> @adjusted_lxvwsx(i64* %s, i64* %t) {
; P9-LABEL: adjusted_lxvwsx:
; P9:       # %bb.0: # %entry
; P9-NEXT:    addi r3, r3, 4
; P9-NEXT:    lxvwsx v2, 0, r3
; P9-NEXT:    blr
;
; P8-LABEL: adjusted_lxvwsx:
; P8:       # %bb.0: # %entry
; P8-NEXT:    ld r3, 0(r3)
; P8-NEXT:    mtfprd f0, r3
; P8-NEXT:    xxswapd v2, vs0
; P8-NEXT:    xxspltw v2, v2, 2
; P8-NEXT:    blr
  entry:
    %0 = bitcast i64* %s to <8 x i8>*
    %1 = load <8 x i8>, <8 x i8>* %0, align 8
    %2 = shufflevector <8 x i8> %1, <8 x i8> undef, <16 x i32> <i32 4, i32 5, i32 6, i32 7, i32 4, i32 5, i32 6, i32 7, i32 4, i32 5, i32 6, i32 7, i32 4, i32 5, i32 6, i32 7>
    ret <16 x i8> %2
}

define <16 x i8> @unadjusted_lxvwsx_v16i8(<16 x i8> *%s, <16 x i8> %t) {
; P9-LABEL: unadjusted_lxvwsx_v16i8:
; P9:       # %bb.0: # %entry
; P9-NEXT:    lxvwsx v2, 0, r3
; P9-NEXT:    blr
;
; P8-LABEL: unadjusted_lxvwsx_v16i8:
; P8:       # %bb.0: # %entry
; P8-NEXT:    lvx v2, 0, r3
; P8-NEXT:    xxspltw v2, v2, 3
; P8-NEXT:    blr
  entry:
    %0 = load <16 x i8>, <16 x i8>* %s, align 16
    %1 = shufflevector <16 x i8> %0, <16 x i8> undef, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 0, i32 1, i32 2, i32 3, i32 0, i32 1, i32 2, i32 3, i32 0, i32 1, i32 2, i32 3>
    ret <16 x i8> %1
}

define <16 x i8> @adjusted_lxvwsx_v16i8(<16 x i8> *%s, <16 x i8> %t) {
; P9-LABEL: adjusted_lxvwsx_v16i8:
; P9:       # %bb.0: # %entry
; P9-NEXT:    addi r3, r3, 4
; P9-NEXT:    lxvwsx v2, 0, r3
; P9-NEXT:    blr
;
; P8-LABEL: adjusted_lxvwsx_v16i8:
; P8:       # %bb.0: # %entry
; P8-NEXT:    lvx v2, 0, r3
; P8-NEXT:    xxspltw v2, v2, 2
; P8-NEXT:    blr
  entry:
    %0 = load <16 x i8>, <16 x i8>* %s, align 16
    %1 = shufflevector <16 x i8> %0, <16 x i8> undef, <16 x i32> <i32 4, i32 5, i32 6, i32 7, i32 4, i32 5, i32 6, i32 7, i32 4, i32 5, i32 6, i32 7, i32 4, i32 5, i32 6, i32 7>
    ret <16 x i8> %1
}

define <16 x i8> @adjusted_lxvwsx_v16i8_2(<16 x i8> *%s, <16 x i8> %t) {
; P9-LABEL: adjusted_lxvwsx_v16i8_2:
; P9:       # %bb.0: # %entry
; P9-NEXT:    addi r3, r3, 8
; P9-NEXT:    lxvwsx v2, 0, r3
; P9-NEXT:    blr
;
; P8-LABEL: adjusted_lxvwsx_v16i8_2:
; P8:       # %bb.0: # %entry
; P8-NEXT:    lvx v2, 0, r3
; P8-NEXT:    xxspltw v2, v2, 1
; P8-NEXT:    blr
  entry:
    %0 = load <16 x i8>, <16 x i8>* %s, align 16
    %1 = shufflevector <16 x i8> %0, <16 x i8> undef, <16 x i32> <i32 8, i32 9, i32 10, i32 11, i32 8, i32 9, i32 10, i32 11, i32 8, i32 9, i32 10, i32 11, i32 8, i32 9, i32 10, i32 11>
    ret <16 x i8> %1
}

define <16 x i8> @adjusted_lxvwsx_v16i8_3(<16 x i8> *%s, <16 x i8> %t) {
; P9-LABEL: adjusted_lxvwsx_v16i8_3:
; P9:       # %bb.0: # %entry
; P9-NEXT:    addi r3, r3, 12
; P9-NEXT:    lxvwsx v2, 0, r3
; P9-NEXT:    blr
;
; P8-LABEL: adjusted_lxvwsx_v16i8_3:
; P8:       # %bb.0: # %entry
; P8-NEXT:    lvx v2, 0, r3
; P8-NEXT:    xxspltw v2, v2, 0
; P8-NEXT:    blr
  entry:
    %0 = load <16 x i8>, <16 x i8>* %s, align 16
    %1 = shufflevector <16 x i8> %0, <16 x i8> undef, <16 x i32> <i32 12, i32 13, i32 14, i32 15, i32 12, i32 13, i32 14, i32 15, i32 12, i32 13, i32 14, i32 15, i32 12, i32 13, i32 14, i32 15>
    ret <16 x i8> %1
}

define <16 x i8> @unadjusted_lxvdsx(i64* %s, i64* %t) {
; P9-LABEL: unadjusted_lxvdsx:
; P9:       # %bb.0: # %entry
; P9-NEXT:    lxvdsx v2, 0, r3
; P9-NEXT:    blr
;
; P8-LABEL: unadjusted_lxvdsx:
; P8:       # %bb.0: # %entry
; P8-NEXT:    lxvdsx v2, 0, r3
; P8-NEXT:    blr
  entry:
    %0 = bitcast i64* %s to <8 x i8>*
    %1 = load <8 x i8>, <8 x i8>* %0, align 8
    %2 = shufflevector <8 x i8> %1, <8 x i8> undef, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
    ret <16 x i8> %2
}

define <16 x i8> @unadjusted_lxvdsx_v16i8(<16 x i8> *%s, <16 x i8> %t) {
; P9-LABEL: unadjusted_lxvdsx_v16i8:
; P9:       # %bb.0: # %entry
; P9-NEXT:    lxvdsx v2, 0, r3
; P9-NEXT:    blr
;
; P8-LABEL: unadjusted_lxvdsx_v16i8:
; P8:       # %bb.0: # %entry
; P8-NEXT:    lxvdsx v2, 0, r3
; P8-NEXT:    blr
  entry:
    %0 = load <16 x i8>, <16 x i8>* %s, align 16
    %1 = shufflevector <16 x i8> %0, <16 x i8> undef, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
    ret <16 x i8> %1
}

define <16 x i8> @adjusted_lxvdsx_v16i8(<16 x i8> *%s, <16 x i8> %t) {
; P9-LABEL: adjusted_lxvdsx_v16i8:
; P9:       # %bb.0: # %entry
; P9-NEXT:    addi r3, r3, 8
; P9-NEXT:    lxvdsx v2, 0, r3
; P9-NEXT:    blr
;
; P8-LABEL: adjusted_lxvdsx_v16i8:
; P8:       # %bb.0: # %entry
; P8-NEXT:    addi r3, r3, 8
; P8-NEXT:    lxvdsx v2, 0, r3
; P8-NEXT:    blr
  entry:
    %0 = load <16 x i8>, <16 x i8>* %s, align 16
    %1 = shufflevector <16 x i8> %0, <16 x i8> undef, <16 x i32> <i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15, i32 8, i32 9, i32 10, i32 11, i32 12, i32 13, i32 14, i32 15>
    ret <16 x i8> %1
}
