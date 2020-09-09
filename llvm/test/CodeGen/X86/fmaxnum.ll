; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2    | FileCheck %s --check-prefixes=CHECK,SSE,SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.1  | FileCheck %s --check-prefixes=CHECK,SSE,SSE4
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx     | FileCheck %s --check-prefixes=CHECK,AVX,AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f | FileCheck %s --check-prefixes=CHECK,AVX,AVX512

declare float @fmaxf(float, float)
declare double @fmax(double, double)
declare x86_fp80 @fmaxl(x86_fp80, x86_fp80)
declare float @llvm.maxnum.f32(float, float)
declare double @llvm.maxnum.f64(double, double)
declare x86_fp80 @llvm.maxnum.f80(x86_fp80, x86_fp80)

declare <2 x float> @llvm.maxnum.v2f32(<2 x float>, <2 x float>)
declare <4 x float> @llvm.maxnum.v4f32(<4 x float>, <4 x float>)
declare <8 x float> @llvm.maxnum.v8f32(<8 x float>, <8 x float>)
declare <16 x float> @llvm.maxnum.v16f32(<16 x float>, <16 x float>)
declare <2 x double> @llvm.maxnum.v2f64(<2 x double>, <2 x double>)
declare <4 x double> @llvm.maxnum.v4f64(<4 x double>, <4 x double>)
declare <8 x double> @llvm.maxnum.v8f64(<8 x double>, <8 x double>)

; FIXME: As the vector tests show, the SSE run shouldn't need this many moves.

define float @test_fmaxf(float %x, float %y) {
; SSE-LABEL: test_fmaxf:
; SSE:       # %bb.0:
; SSE-NEXT:    movaps %xmm0, %xmm2
; SSE-NEXT:    cmpunordss %xmm0, %xmm2
; SSE-NEXT:    movaps %xmm2, %xmm3
; SSE-NEXT:    andps %xmm1, %xmm3
; SSE-NEXT:    maxss %xmm0, %xmm1
; SSE-NEXT:    andnps %xmm1, %xmm2
; SSE-NEXT:    orps %xmm3, %xmm2
; SSE-NEXT:    movaps %xmm2, %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: test_fmaxf:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmaxss %xmm0, %xmm1, %xmm2
; AVX1-NEXT:    vcmpunordss %xmm0, %xmm0, %xmm0
; AVX1-NEXT:    vblendvps %xmm0, %xmm1, %xmm2, %xmm0
; AVX1-NEXT:    retq
;
; AVX512-LABEL: test_fmaxf:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmaxss %xmm0, %xmm1, %xmm2
; AVX512-NEXT:    vcmpunordss %xmm0, %xmm0, %k1
; AVX512-NEXT:    vmovss %xmm1, %xmm2, %xmm2 {%k1}
; AVX512-NEXT:    vmovaps %xmm2, %xmm0
; AVX512-NEXT:    retq
  %z = call float @fmaxf(float %x, float %y) readnone
  ret float %z
}

define float @test_fmaxf_minsize(float %x, float %y) minsize {
; CHECK-LABEL: test_fmaxf_minsize:
; CHECK:       # %bb.0:
; CHECK-NEXT:    jmp fmaxf # TAILCALL
  %z = call float @fmaxf(float %x, float %y) readnone
  ret float %z
}

; FIXME: As the vector tests show, the SSE run shouldn't need this many moves.

define double @test_fmax(double %x, double %y) {
; SSE-LABEL: test_fmax:
; SSE:       # %bb.0:
; SSE-NEXT:    movapd %xmm0, %xmm2
; SSE-NEXT:    cmpunordsd %xmm0, %xmm2
; SSE-NEXT:    movapd %xmm2, %xmm3
; SSE-NEXT:    andpd %xmm1, %xmm3
; SSE-NEXT:    maxsd %xmm0, %xmm1
; SSE-NEXT:    andnpd %xmm1, %xmm2
; SSE-NEXT:    orpd %xmm3, %xmm2
; SSE-NEXT:    movapd %xmm2, %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: test_fmax:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmaxsd %xmm0, %xmm1, %xmm2
; AVX1-NEXT:    vcmpunordsd %xmm0, %xmm0, %xmm0
; AVX1-NEXT:    vblendvpd %xmm0, %xmm1, %xmm2, %xmm0
; AVX1-NEXT:    retq
;
; AVX512-LABEL: test_fmax:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmaxsd %xmm0, %xmm1, %xmm2
; AVX512-NEXT:    vcmpunordsd %xmm0, %xmm0, %k1
; AVX512-NEXT:    vmovsd %xmm1, %xmm2, %xmm2 {%k1}
; AVX512-NEXT:    vmovapd %xmm2, %xmm0
; AVX512-NEXT:    retq
  %z = call double @fmax(double %x, double %y) readnone
  ret double %z
}

define x86_fp80 @test_fmaxl(x86_fp80 %x, x86_fp80 %y) {
; CHECK-LABEL: test_fmaxl:
; CHECK:       # %bb.0:
; CHECK-NEXT:    subq $40, %rsp
; CHECK-NEXT:    .cfi_def_cfa_offset 48
; CHECK-NEXT:    fldt {{[0-9]+}}(%rsp)
; CHECK-NEXT:    fldt {{[0-9]+}}(%rsp)
; CHECK-NEXT:    fstpt {{[0-9]+}}(%rsp)
; CHECK-NEXT:    fstpt (%rsp)
; CHECK-NEXT:    callq fmaxl
; CHECK-NEXT:    addq $40, %rsp
; CHECK-NEXT:    .cfi_def_cfa_offset 8
; CHECK-NEXT:    retq
  %z = call x86_fp80 @fmaxl(x86_fp80 %x, x86_fp80 %y) readnone
  ret x86_fp80 %z
}

define float @test_intrinsic_fmaxf(float %x, float %y) {
; SSE-LABEL: test_intrinsic_fmaxf:
; SSE:       # %bb.0:
; SSE-NEXT:    movaps %xmm0, %xmm2
; SSE-NEXT:    cmpunordss %xmm0, %xmm2
; SSE-NEXT:    movaps %xmm2, %xmm3
; SSE-NEXT:    andps %xmm1, %xmm3
; SSE-NEXT:    maxss %xmm0, %xmm1
; SSE-NEXT:    andnps %xmm1, %xmm2
; SSE-NEXT:    orps %xmm3, %xmm2
; SSE-NEXT:    movaps %xmm2, %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: test_intrinsic_fmaxf:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmaxss %xmm0, %xmm1, %xmm2
; AVX1-NEXT:    vcmpunordss %xmm0, %xmm0, %xmm0
; AVX1-NEXT:    vblendvps %xmm0, %xmm1, %xmm2, %xmm0
; AVX1-NEXT:    retq
;
; AVX512-LABEL: test_intrinsic_fmaxf:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmaxss %xmm0, %xmm1, %xmm2
; AVX512-NEXT:    vcmpunordss %xmm0, %xmm0, %k1
; AVX512-NEXT:    vmovss %xmm1, %xmm2, %xmm2 {%k1}
; AVX512-NEXT:    vmovaps %xmm2, %xmm0
; AVX512-NEXT:    retq
  %z = call float @llvm.maxnum.f32(float %x, float %y) readnone
  ret float %z
}

define double @test_intrinsic_fmax(double %x, double %y) {
; SSE-LABEL: test_intrinsic_fmax:
; SSE:       # %bb.0:
; SSE-NEXT:    movapd %xmm0, %xmm2
; SSE-NEXT:    cmpunordsd %xmm0, %xmm2
; SSE-NEXT:    movapd %xmm2, %xmm3
; SSE-NEXT:    andpd %xmm1, %xmm3
; SSE-NEXT:    maxsd %xmm0, %xmm1
; SSE-NEXT:    andnpd %xmm1, %xmm2
; SSE-NEXT:    orpd %xmm3, %xmm2
; SSE-NEXT:    movapd %xmm2, %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: test_intrinsic_fmax:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmaxsd %xmm0, %xmm1, %xmm2
; AVX1-NEXT:    vcmpunordsd %xmm0, %xmm0, %xmm0
; AVX1-NEXT:    vblendvpd %xmm0, %xmm1, %xmm2, %xmm0
; AVX1-NEXT:    retq
;
; AVX512-LABEL: test_intrinsic_fmax:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmaxsd %xmm0, %xmm1, %xmm2
; AVX512-NEXT:    vcmpunordsd %xmm0, %xmm0, %k1
; AVX512-NEXT:    vmovsd %xmm1, %xmm2, %xmm2 {%k1}
; AVX512-NEXT:    vmovapd %xmm2, %xmm0
; AVX512-NEXT:    retq
  %z = call double @llvm.maxnum.f64(double %x, double %y) readnone
  ret double %z
}

define x86_fp80 @test_intrinsic_fmaxl(x86_fp80 %x, x86_fp80 %y) {
; CHECK-LABEL: test_intrinsic_fmaxl:
; CHECK:       # %bb.0:
; CHECK-NEXT:    subq $40, %rsp
; CHECK-NEXT:    .cfi_def_cfa_offset 48
; CHECK-NEXT:    fldt {{[0-9]+}}(%rsp)
; CHECK-NEXT:    fldt {{[0-9]+}}(%rsp)
; CHECK-NEXT:    fstpt {{[0-9]+}}(%rsp)
; CHECK-NEXT:    fstpt (%rsp)
; CHECK-NEXT:    callq fmaxl
; CHECK-NEXT:    addq $40, %rsp
; CHECK-NEXT:    .cfi_def_cfa_offset 8
; CHECK-NEXT:    retq
  %z = call x86_fp80 @llvm.maxnum.f80(x86_fp80 %x, x86_fp80 %y) readnone
  ret x86_fp80 %z
}

define <2 x float> @test_intrinsic_fmax_v2f32(<2 x float> %x, <2 x float> %y) {
; SSE2-LABEL: test_intrinsic_fmax_v2f32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movaps %xmm1, %xmm2
; SSE2-NEXT:    maxps %xmm0, %xmm2
; SSE2-NEXT:    cmpunordps %xmm0, %xmm0
; SSE2-NEXT:    andps %xmm0, %xmm1
; SSE2-NEXT:    andnps %xmm2, %xmm0
; SSE2-NEXT:    orps %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test_intrinsic_fmax_v2f32:
; SSE4:       # %bb.0:
; SSE4-NEXT:    movaps %xmm1, %xmm2
; SSE4-NEXT:    maxps %xmm0, %xmm2
; SSE4-NEXT:    cmpunordps %xmm0, %xmm0
; SSE4-NEXT:    blendvps %xmm0, %xmm1, %xmm2
; SSE4-NEXT:    movaps %xmm2, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test_intrinsic_fmax_v2f32:
; AVX:       # %bb.0:
; AVX-NEXT:    vmaxps %xmm0, %xmm1, %xmm2
; AVX-NEXT:    vcmpunordps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    vblendvps %xmm0, %xmm1, %xmm2, %xmm0
; AVX-NEXT:    retq
  %z = call <2 x float> @llvm.maxnum.v2f32(<2 x float> %x, <2 x float> %y) readnone
  ret <2 x float> %z
}

define <4 x float> @test_intrinsic_fmax_v4f32(<4 x float> %x, <4 x float> %y) {
; SSE2-LABEL: test_intrinsic_fmax_v4f32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movaps %xmm1, %xmm2
; SSE2-NEXT:    maxps %xmm0, %xmm2
; SSE2-NEXT:    cmpunordps %xmm0, %xmm0
; SSE2-NEXT:    andps %xmm0, %xmm1
; SSE2-NEXT:    andnps %xmm2, %xmm0
; SSE2-NEXT:    orps %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test_intrinsic_fmax_v4f32:
; SSE4:       # %bb.0:
; SSE4-NEXT:    movaps %xmm1, %xmm2
; SSE4-NEXT:    maxps %xmm0, %xmm2
; SSE4-NEXT:    cmpunordps %xmm0, %xmm0
; SSE4-NEXT:    blendvps %xmm0, %xmm1, %xmm2
; SSE4-NEXT:    movaps %xmm2, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test_intrinsic_fmax_v4f32:
; AVX:       # %bb.0:
; AVX-NEXT:    vmaxps %xmm0, %xmm1, %xmm2
; AVX-NEXT:    vcmpunordps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    vblendvps %xmm0, %xmm1, %xmm2, %xmm0
; AVX-NEXT:    retq
  %z = call <4 x float> @llvm.maxnum.v4f32(<4 x float> %x, <4 x float> %y) readnone
  ret <4 x float> %z
}

define <8 x float> @test_intrinsic_fmax_v8f32(<8 x float> %x, <8 x float> %y) {
; SSE2-LABEL: test_intrinsic_fmax_v8f32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movaps %xmm2, %xmm4
; SSE2-NEXT:    maxps %xmm0, %xmm4
; SSE2-NEXT:    cmpunordps %xmm0, %xmm0
; SSE2-NEXT:    andps %xmm0, %xmm2
; SSE2-NEXT:    andnps %xmm4, %xmm0
; SSE2-NEXT:    orps %xmm2, %xmm0
; SSE2-NEXT:    movaps %xmm3, %xmm2
; SSE2-NEXT:    maxps %xmm1, %xmm2
; SSE2-NEXT:    cmpunordps %xmm1, %xmm1
; SSE2-NEXT:    andps %xmm1, %xmm3
; SSE2-NEXT:    andnps %xmm2, %xmm1
; SSE2-NEXT:    orps %xmm3, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test_intrinsic_fmax_v8f32:
; SSE4:       # %bb.0:
; SSE4-NEXT:    movaps %xmm1, %xmm5
; SSE4-NEXT:    movaps %xmm2, %xmm4
; SSE4-NEXT:    maxps %xmm0, %xmm4
; SSE4-NEXT:    cmpunordps %xmm0, %xmm0
; SSE4-NEXT:    blendvps %xmm0, %xmm2, %xmm4
; SSE4-NEXT:    movaps %xmm3, %xmm1
; SSE4-NEXT:    maxps %xmm5, %xmm1
; SSE4-NEXT:    cmpunordps %xmm5, %xmm5
; SSE4-NEXT:    movaps %xmm5, %xmm0
; SSE4-NEXT:    blendvps %xmm0, %xmm3, %xmm1
; SSE4-NEXT:    movaps %xmm4, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test_intrinsic_fmax_v8f32:
; AVX:       # %bb.0:
; AVX-NEXT:    vmaxps %ymm0, %ymm1, %ymm2
; AVX-NEXT:    vcmpunordps %ymm0, %ymm0, %ymm0
; AVX-NEXT:    vblendvps %ymm0, %ymm1, %ymm2, %ymm0
; AVX-NEXT:    retq
  %z = call <8 x float> @llvm.maxnum.v8f32(<8 x float> %x, <8 x float> %y) readnone
  ret <8 x float> %z
}

define <16 x float> @test_intrinsic_fmax_v16f32(<16 x float> %x, <16 x float> %y) {
; SSE2-LABEL: test_intrinsic_fmax_v16f32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movaps %xmm4, %xmm8
; SSE2-NEXT:    maxps %xmm0, %xmm8
; SSE2-NEXT:    cmpunordps %xmm0, %xmm0
; SSE2-NEXT:    andps %xmm0, %xmm4
; SSE2-NEXT:    andnps %xmm8, %xmm0
; SSE2-NEXT:    orps %xmm4, %xmm0
; SSE2-NEXT:    movaps %xmm5, %xmm4
; SSE2-NEXT:    maxps %xmm1, %xmm4
; SSE2-NEXT:    cmpunordps %xmm1, %xmm1
; SSE2-NEXT:    andps %xmm1, %xmm5
; SSE2-NEXT:    andnps %xmm4, %xmm1
; SSE2-NEXT:    orps %xmm5, %xmm1
; SSE2-NEXT:    movaps %xmm6, %xmm4
; SSE2-NEXT:    maxps %xmm2, %xmm4
; SSE2-NEXT:    cmpunordps %xmm2, %xmm2
; SSE2-NEXT:    andps %xmm2, %xmm6
; SSE2-NEXT:    andnps %xmm4, %xmm2
; SSE2-NEXT:    orps %xmm6, %xmm2
; SSE2-NEXT:    movaps %xmm7, %xmm4
; SSE2-NEXT:    maxps %xmm3, %xmm4
; SSE2-NEXT:    cmpunordps %xmm3, %xmm3
; SSE2-NEXT:    andps %xmm3, %xmm7
; SSE2-NEXT:    andnps %xmm4, %xmm3
; SSE2-NEXT:    orps %xmm7, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test_intrinsic_fmax_v16f32:
; SSE4:       # %bb.0:
; SSE4-NEXT:    movaps %xmm3, %xmm8
; SSE4-NEXT:    movaps %xmm2, %xmm9
; SSE4-NEXT:    movaps %xmm1, %xmm2
; SSE4-NEXT:    movaps %xmm4, %xmm10
; SSE4-NEXT:    maxps %xmm0, %xmm10
; SSE4-NEXT:    cmpunordps %xmm0, %xmm0
; SSE4-NEXT:    blendvps %xmm0, %xmm4, %xmm10
; SSE4-NEXT:    movaps %xmm5, %xmm1
; SSE4-NEXT:    maxps %xmm2, %xmm1
; SSE4-NEXT:    cmpunordps %xmm2, %xmm2
; SSE4-NEXT:    movaps %xmm2, %xmm0
; SSE4-NEXT:    blendvps %xmm0, %xmm5, %xmm1
; SSE4-NEXT:    movaps %xmm6, %xmm2
; SSE4-NEXT:    maxps %xmm9, %xmm2
; SSE4-NEXT:    cmpunordps %xmm9, %xmm9
; SSE4-NEXT:    movaps %xmm9, %xmm0
; SSE4-NEXT:    blendvps %xmm0, %xmm6, %xmm2
; SSE4-NEXT:    movaps %xmm7, %xmm3
; SSE4-NEXT:    maxps %xmm8, %xmm3
; SSE4-NEXT:    cmpunordps %xmm8, %xmm8
; SSE4-NEXT:    movaps %xmm8, %xmm0
; SSE4-NEXT:    blendvps %xmm0, %xmm7, %xmm3
; SSE4-NEXT:    movaps %xmm10, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test_intrinsic_fmax_v16f32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmaxps %ymm0, %ymm2, %ymm4
; AVX1-NEXT:    vcmpunordps %ymm0, %ymm0, %ymm0
; AVX1-NEXT:    vblendvps %ymm0, %ymm2, %ymm4, %ymm0
; AVX1-NEXT:    vmaxps %ymm1, %ymm3, %ymm2
; AVX1-NEXT:    vcmpunordps %ymm1, %ymm1, %ymm1
; AVX1-NEXT:    vblendvps %ymm1, %ymm3, %ymm2, %ymm1
; AVX1-NEXT:    retq
;
; AVX512-LABEL: test_intrinsic_fmax_v16f32:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmaxps %zmm0, %zmm1, %zmm2
; AVX512-NEXT:    vcmpunordps %zmm0, %zmm0, %k1
; AVX512-NEXT:    vmovaps %zmm1, %zmm2 {%k1}
; AVX512-NEXT:    vmovaps %zmm2, %zmm0
; AVX512-NEXT:    retq
  %z = call <16 x float> @llvm.maxnum.v16f32(<16 x float> %x, <16 x float> %y) readnone
  ret <16 x float> %z
}

define <2 x double> @test_intrinsic_fmax_v2f64(<2 x double> %x, <2 x double> %y) {
; SSE2-LABEL: test_intrinsic_fmax_v2f64:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movapd %xmm1, %xmm2
; SSE2-NEXT:    maxpd %xmm0, %xmm2
; SSE2-NEXT:    cmpunordpd %xmm0, %xmm0
; SSE2-NEXT:    andpd %xmm0, %xmm1
; SSE2-NEXT:    andnpd %xmm2, %xmm0
; SSE2-NEXT:    orpd %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test_intrinsic_fmax_v2f64:
; SSE4:       # %bb.0:
; SSE4-NEXT:    movapd %xmm1, %xmm2
; SSE4-NEXT:    maxpd %xmm0, %xmm2
; SSE4-NEXT:    cmpunordpd %xmm0, %xmm0
; SSE4-NEXT:    blendvpd %xmm0, %xmm1, %xmm2
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test_intrinsic_fmax_v2f64:
; AVX:       # %bb.0:
; AVX-NEXT:    vmaxpd %xmm0, %xmm1, %xmm2
; AVX-NEXT:    vcmpunordpd %xmm0, %xmm0, %xmm0
; AVX-NEXT:    vblendvpd %xmm0, %xmm1, %xmm2, %xmm0
; AVX-NEXT:    retq
  %z = call <2 x double> @llvm.maxnum.v2f64(<2 x double> %x, <2 x double> %y) readnone
  ret <2 x double> %z
}

define <4 x double> @test_intrinsic_fmax_v4f64(<4 x double> %x, <4 x double> %y) {
; SSE2-LABEL: test_intrinsic_fmax_v4f64:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movapd %xmm2, %xmm4
; SSE2-NEXT:    maxpd %xmm0, %xmm4
; SSE2-NEXT:    cmpunordpd %xmm0, %xmm0
; SSE2-NEXT:    andpd %xmm0, %xmm2
; SSE2-NEXT:    andnpd %xmm4, %xmm0
; SSE2-NEXT:    orpd %xmm2, %xmm0
; SSE2-NEXT:    movapd %xmm3, %xmm2
; SSE2-NEXT:    maxpd %xmm1, %xmm2
; SSE2-NEXT:    cmpunordpd %xmm1, %xmm1
; SSE2-NEXT:    andpd %xmm1, %xmm3
; SSE2-NEXT:    andnpd %xmm2, %xmm1
; SSE2-NEXT:    orpd %xmm3, %xmm1
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test_intrinsic_fmax_v4f64:
; SSE4:       # %bb.0:
; SSE4-NEXT:    movapd %xmm1, %xmm5
; SSE4-NEXT:    movapd %xmm2, %xmm4
; SSE4-NEXT:    maxpd %xmm0, %xmm4
; SSE4-NEXT:    cmpunordpd %xmm0, %xmm0
; SSE4-NEXT:    blendvpd %xmm0, %xmm2, %xmm4
; SSE4-NEXT:    movapd %xmm3, %xmm1
; SSE4-NEXT:    maxpd %xmm5, %xmm1
; SSE4-NEXT:    cmpunordpd %xmm5, %xmm5
; SSE4-NEXT:    movapd %xmm5, %xmm0
; SSE4-NEXT:    blendvpd %xmm0, %xmm3, %xmm1
; SSE4-NEXT:    movapd %xmm4, %xmm0
; SSE4-NEXT:    retq
;
; AVX-LABEL: test_intrinsic_fmax_v4f64:
; AVX:       # %bb.0:
; AVX-NEXT:    vmaxpd %ymm0, %ymm1, %ymm2
; AVX-NEXT:    vcmpunordpd %ymm0, %ymm0, %ymm0
; AVX-NEXT:    vblendvpd %ymm0, %ymm1, %ymm2, %ymm0
; AVX-NEXT:    retq
  %z = call <4 x double> @llvm.maxnum.v4f64(<4 x double> %x, <4 x double> %y) readnone
  ret <4 x double> %z
}

define <8 x double> @test_intrinsic_fmax_v8f64(<8 x double> %x, <8 x double> %y) {
; SSE2-LABEL: test_intrinsic_fmax_v8f64:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movapd %xmm4, %xmm8
; SSE2-NEXT:    maxpd %xmm0, %xmm8
; SSE2-NEXT:    cmpunordpd %xmm0, %xmm0
; SSE2-NEXT:    andpd %xmm0, %xmm4
; SSE2-NEXT:    andnpd %xmm8, %xmm0
; SSE2-NEXT:    orpd %xmm4, %xmm0
; SSE2-NEXT:    movapd %xmm5, %xmm4
; SSE2-NEXT:    maxpd %xmm1, %xmm4
; SSE2-NEXT:    cmpunordpd %xmm1, %xmm1
; SSE2-NEXT:    andpd %xmm1, %xmm5
; SSE2-NEXT:    andnpd %xmm4, %xmm1
; SSE2-NEXT:    orpd %xmm5, %xmm1
; SSE2-NEXT:    movapd %xmm6, %xmm4
; SSE2-NEXT:    maxpd %xmm2, %xmm4
; SSE2-NEXT:    cmpunordpd %xmm2, %xmm2
; SSE2-NEXT:    andpd %xmm2, %xmm6
; SSE2-NEXT:    andnpd %xmm4, %xmm2
; SSE2-NEXT:    orpd %xmm6, %xmm2
; SSE2-NEXT:    movapd %xmm7, %xmm4
; SSE2-NEXT:    maxpd %xmm3, %xmm4
; SSE2-NEXT:    cmpunordpd %xmm3, %xmm3
; SSE2-NEXT:    andpd %xmm3, %xmm7
; SSE2-NEXT:    andnpd %xmm4, %xmm3
; SSE2-NEXT:    orpd %xmm7, %xmm3
; SSE2-NEXT:    retq
;
; SSE4-LABEL: test_intrinsic_fmax_v8f64:
; SSE4:       # %bb.0:
; SSE4-NEXT:    movapd %xmm3, %xmm8
; SSE4-NEXT:    movapd %xmm2, %xmm9
; SSE4-NEXT:    movapd %xmm1, %xmm2
; SSE4-NEXT:    movapd %xmm4, %xmm10
; SSE4-NEXT:    maxpd %xmm0, %xmm10
; SSE4-NEXT:    cmpunordpd %xmm0, %xmm0
; SSE4-NEXT:    blendvpd %xmm0, %xmm4, %xmm10
; SSE4-NEXT:    movapd %xmm5, %xmm1
; SSE4-NEXT:    maxpd %xmm2, %xmm1
; SSE4-NEXT:    cmpunordpd %xmm2, %xmm2
; SSE4-NEXT:    movapd %xmm2, %xmm0
; SSE4-NEXT:    blendvpd %xmm0, %xmm5, %xmm1
; SSE4-NEXT:    movapd %xmm6, %xmm2
; SSE4-NEXT:    maxpd %xmm9, %xmm2
; SSE4-NEXT:    cmpunordpd %xmm9, %xmm9
; SSE4-NEXT:    movapd %xmm9, %xmm0
; SSE4-NEXT:    blendvpd %xmm0, %xmm6, %xmm2
; SSE4-NEXT:    movapd %xmm7, %xmm3
; SSE4-NEXT:    maxpd %xmm8, %xmm3
; SSE4-NEXT:    cmpunordpd %xmm8, %xmm8
; SSE4-NEXT:    movapd %xmm8, %xmm0
; SSE4-NEXT:    blendvpd %xmm0, %xmm7, %xmm3
; SSE4-NEXT:    movapd %xmm10, %xmm0
; SSE4-NEXT:    retq
;
; AVX1-LABEL: test_intrinsic_fmax_v8f64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmaxpd %ymm0, %ymm2, %ymm4
; AVX1-NEXT:    vcmpunordpd %ymm0, %ymm0, %ymm0
; AVX1-NEXT:    vblendvpd %ymm0, %ymm2, %ymm4, %ymm0
; AVX1-NEXT:    vmaxpd %ymm1, %ymm3, %ymm2
; AVX1-NEXT:    vcmpunordpd %ymm1, %ymm1, %ymm1
; AVX1-NEXT:    vblendvpd %ymm1, %ymm3, %ymm2, %ymm1
; AVX1-NEXT:    retq
;
; AVX512-LABEL: test_intrinsic_fmax_v8f64:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmaxpd %zmm0, %zmm1, %zmm2
; AVX512-NEXT:    vcmpunordpd %zmm0, %zmm0, %k1
; AVX512-NEXT:    vmovapd %zmm1, %zmm2 {%k1}
; AVX512-NEXT:    vmovapd %zmm2, %zmm0
; AVX512-NEXT:    retq
  %z = call <8 x double> @llvm.maxnum.v8f64(<8 x double> %x, <8 x double> %y) readnone
  ret <8 x double> %z
}

; The IR-level FMF propagate to the node. With nnan, there's no need to blend.

define double @maxnum_intrinsic_nnan_fmf_f64(double %a, double %b) {
; SSE-LABEL: maxnum_intrinsic_nnan_fmf_f64:
; SSE:       # %bb.0:
; SSE-NEXT:    maxsd %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: maxnum_intrinsic_nnan_fmf_f64:
; AVX:       # %bb.0:
; AVX-NEXT:    vmaxsd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %r = tail call nnan double @llvm.maxnum.f64(double %a, double %b)
  ret double %r
}

; Make sure vectors work too.

define <4 x float> @maxnum_intrinsic_nnan_fmf_f432(<4 x float> %a, <4 x float> %b) {
; SSE-LABEL: maxnum_intrinsic_nnan_fmf_f432:
; SSE:       # %bb.0:
; SSE-NEXT:    maxps %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: maxnum_intrinsic_nnan_fmf_f432:
; AVX:       # %bb.0:
; AVX-NEXT:    vmaxps %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %r = tail call nnan <4 x float> @llvm.maxnum.v4f32(<4 x float> %a, <4 x float> %b)
  ret <4 x float> %r
}

; Current (but legacy someday): a function-level attribute should also enable the fold.

define float @maxnum_intrinsic_nnan_attr_f32(float %a, float %b) #0 {
; SSE-LABEL: maxnum_intrinsic_nnan_attr_f32:
; SSE:       # %bb.0:
; SSE-NEXT:    maxss %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: maxnum_intrinsic_nnan_attr_f32:
; AVX:       # %bb.0:
; AVX-NEXT:    vmaxss %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %r = tail call float @llvm.maxnum.f32(float %a, float %b)
  ret float %r
}

; Make sure vectors work too.

define <2 x double> @maxnum_intrinsic_nnan_attr_f64(<2 x double> %a, <2 x double> %b) #0 {
; SSE-LABEL: maxnum_intrinsic_nnan_attr_f64:
; SSE:       # %bb.0:
; SSE-NEXT:    maxpd %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: maxnum_intrinsic_nnan_attr_f64:
; AVX:       # %bb.0:
; AVX-NEXT:    vmaxpd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %r = tail call <2 x double> @llvm.maxnum.v2f64(<2 x double> %a, <2 x double> %b)
  ret <2 x double> %r
}

define float @test_maxnum_const_op1(float %x) {
; SSE-LABEL: test_maxnum_const_op1:
; SSE:       # %bb.0:
; SSE-NEXT:    maxss {{.*}}(%rip), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test_maxnum_const_op1:
; AVX:       # %bb.0:
; AVX-NEXT:    vmaxss {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    retq
  %r = call float @llvm.maxnum.f32(float 1.0, float %x)
  ret float %r
}

define float @test_maxnum_const_op2(float %x) {
; SSE-LABEL: test_maxnum_const_op2:
; SSE:       # %bb.0:
; SSE-NEXT:    maxss {{.*}}(%rip), %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test_maxnum_const_op2:
; AVX:       # %bb.0:
; AVX-NEXT:    vmaxss {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    retq
  %r = call float @llvm.maxnum.f32(float %x, float 1.0)
  ret float %r
}

define float @test_maxnum_const_nan(float %x) {
; SSE-LABEL: test_maxnum_const_nan:
; SSE:       # %bb.0:
; SSE-NEXT:    movss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; SSE-NEXT:    movaps %xmm0, %xmm1
; SSE-NEXT:    cmpunordss %xmm0, %xmm1
; SSE-NEXT:    movaps %xmm1, %xmm3
; SSE-NEXT:    andps %xmm2, %xmm3
; SSE-NEXT:    maxss %xmm0, %xmm2
; SSE-NEXT:    andnps %xmm2, %xmm1
; SSE-NEXT:    orps %xmm3, %xmm1
; SSE-NEXT:    movaps %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX1-LABEL: test_maxnum_const_nan:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; AVX1-NEXT:    vmaxss %xmm0, %xmm1, %xmm2
; AVX1-NEXT:    vcmpunordss %xmm0, %xmm0, %xmm0
; AVX1-NEXT:    vblendvps %xmm0, %xmm1, %xmm2, %xmm0
; AVX1-NEXT:    retq
;
; AVX512-LABEL: test_maxnum_const_nan:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovss {{.*#+}} xmm2 = mem[0],zero,zero,zero
; AVX512-NEXT:    vmaxss %xmm0, %xmm2, %xmm1
; AVX512-NEXT:    vcmpunordss %xmm0, %xmm0, %k1
; AVX512-NEXT:    vmovss %xmm2, %xmm1, %xmm1 {%k1}
; AVX512-NEXT:    vmovaps %xmm1, %xmm0
; AVX512-NEXT:    retq
  %r = call float @llvm.maxnum.f32(float %x, float 0x7fff000000000000)
  ret float %r
}

attributes #0 = { "no-nans-fp-math"="true" }

