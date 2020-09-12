; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.1 | FileCheck %s --check-prefix=ALL --check-prefix=SSE --check-prefix=SSE41
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefix=ALL --check-prefix=AVX --check-prefix=AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512bw | FileCheck %s --check-prefix=ALL --check-prefix=AVX512 --check-prefix=AVX512BW
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512bw,+avx512vl | FileCheck %s --check-prefix=ALL --check-prefix=AVX512 --check-prefix=AVX512VL

;
; vXf32
;

define float @test_v2f32(<2 x float> %a0) {
; SSE2-LABEL: test_v2f32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movaps %xmm0, %xmm2
; SSE2-NEXT:    shufps {{.*#+}} xmm2 = xmm2[1,1],xmm0[1,1]
; SSE2-NEXT:    movaps %xmm0, %xmm1
; SSE2-NEXT:    cmpunordss %xmm0, %xmm1
; SSE2-NEXT:    movaps %xmm1, %xmm3
; SSE2-NEXT:    andps %xmm2, %xmm3
; SSE2-NEXT:    maxss %xmm0, %xmm2
; SSE2-NEXT:    andnps %xmm2, %xmm1
; SSE2-NEXT:    orps %xmm3, %xmm1
; SSE2-NEXT:    movaps %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v2f32:
; SSE41:       # %bb.0:
; SSE41-NEXT:    movshdup {{.*#+}} xmm2 = xmm0[1,1,3,3]
; SSE41-NEXT:    movaps %xmm0, %xmm1
; SSE41-NEXT:    cmpunordss %xmm0, %xmm1
; SSE41-NEXT:    movaps %xmm1, %xmm3
; SSE41-NEXT:    andps %xmm2, %xmm3
; SSE41-NEXT:    maxss %xmm0, %xmm2
; SSE41-NEXT:    andnps %xmm2, %xmm1
; SSE41-NEXT:    orps %xmm3, %xmm1
; SSE41-NEXT:    movaps %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: test_v2f32:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; AVX-NEXT:    vmaxss %xmm0, %xmm1, %xmm2
; AVX-NEXT:    vcmpunordss %xmm0, %xmm0, %xmm0
; AVX-NEXT:    vblendvps %xmm0, %xmm1, %xmm2, %xmm0
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v2f32:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovshdup {{.*#+}} xmm2 = xmm0[1,1,3,3]
; AVX512-NEXT:    vmaxss %xmm0, %xmm2, %xmm1
; AVX512-NEXT:    vcmpunordss %xmm0, %xmm0, %k1
; AVX512-NEXT:    vmovss %xmm2, %xmm1, %xmm1 {%k1}
; AVX512-NEXT:    vmovaps %xmm1, %xmm0
; AVX512-NEXT:    retq
  %1 = call nnan float @llvm.experimental.vector.reduce.fmax.v2f32(<2 x float> %a0)
  ret float %1
}

define float @test_v4f32(<4 x float> %a0) {
; SSE2-LABEL: test_v4f32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movaps %xmm0, %xmm1
; SSE2-NEXT:    shufps {{.*#+}} xmm1 = xmm1[3,3],xmm0[3,3]
; SSE2-NEXT:    movaps %xmm0, %xmm2
; SSE2-NEXT:    unpckhpd {{.*#+}} xmm2 = xmm2[1],xmm0[1]
; SSE2-NEXT:    movaps %xmm0, %xmm3
; SSE2-NEXT:    shufps {{.*#+}} xmm3 = xmm3[1,1],xmm0[1,1]
; SSE2-NEXT:    maxss %xmm3, %xmm0
; SSE2-NEXT:    maxss %xmm2, %xmm0
; SSE2-NEXT:    maxss %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v4f32:
; SSE41:       # %bb.0:
; SSE41-NEXT:    movaps %xmm0, %xmm1
; SSE41-NEXT:    shufps {{.*#+}} xmm1 = xmm1[3,3],xmm0[3,3]
; SSE41-NEXT:    movaps %xmm0, %xmm2
; SSE41-NEXT:    unpckhpd {{.*#+}} xmm2 = xmm2[1],xmm0[1]
; SSE41-NEXT:    movshdup {{.*#+}} xmm3 = xmm0[1,1,3,3]
; SSE41-NEXT:    maxss %xmm3, %xmm0
; SSE41-NEXT:    maxss %xmm2, %xmm0
; SSE41-NEXT:    maxss %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: test_v4f32:
; AVX:       # %bb.0:
; AVX-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[3,3,3,3]
; AVX-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm0[1,0]
; AVX-NEXT:    vmovshdup {{.*#+}} xmm3 = xmm0[1,1,3,3]
; AVX-NEXT:    vmaxss %xmm3, %xmm0, %xmm0
; AVX-NEXT:    vmaxss %xmm2, %xmm0, %xmm0
; AVX-NEXT:    vmaxss %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v4f32:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpermilps {{.*#+}} xmm1 = xmm0[3,3,3,3]
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm0[1,0]
; AVX512-NEXT:    vmovshdup {{.*#+}} xmm3 = xmm0[1,1,3,3]
; AVX512-NEXT:    vmaxss %xmm3, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm2, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    retq
  %1 = call nnan float @llvm.experimental.vector.reduce.fmax.v4f32(<4 x float> %a0)
  ret float %1
}

define float @test_v8f32(<8 x float> %a0) {
; SSE2-LABEL: test_v8f32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    maxps %xmm1, %xmm0
; SSE2-NEXT:    movaps %xmm0, %xmm2
; SSE2-NEXT:    shufps {{.*#+}} xmm2 = xmm2[1,1],xmm0[1,1]
; SSE2-NEXT:    movaps %xmm0, %xmm1
; SSE2-NEXT:    maxss %xmm2, %xmm1
; SSE2-NEXT:    movaps %xmm0, %xmm2
; SSE2-NEXT:    unpckhpd {{.*#+}} xmm2 = xmm2[1],xmm0[1]
; SSE2-NEXT:    maxss %xmm2, %xmm1
; SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,3,3,3]
; SSE2-NEXT:    maxss %xmm0, %xmm1
; SSE2-NEXT:    movaps %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v8f32:
; SSE41:       # %bb.0:
; SSE41-NEXT:    maxps %xmm1, %xmm0
; SSE41-NEXT:    movshdup {{.*#+}} xmm2 = xmm0[1,1,3,3]
; SSE41-NEXT:    movaps %xmm0, %xmm1
; SSE41-NEXT:    maxss %xmm2, %xmm1
; SSE41-NEXT:    movaps %xmm0, %xmm2
; SSE41-NEXT:    unpckhpd {{.*#+}} xmm2 = xmm2[1],xmm0[1]
; SSE41-NEXT:    maxss %xmm2, %xmm1
; SSE41-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,3,3,3]
; SSE41-NEXT:    maxss %xmm0, %xmm1
; SSE41-NEXT:    movaps %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: test_v8f32:
; AVX:       # %bb.0:
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX-NEXT:    vpermilps {{.*#+}} xmm2 = xmm1[3,3,3,3]
; AVX-NEXT:    vpermilpd {{.*#+}} xmm3 = xmm1[1,0]
; AVX-NEXT:    vmovshdup {{.*#+}} xmm4 = xmm1[1,1,3,3]
; AVX-NEXT:    vpermilps {{.*#+}} xmm5 = xmm0[3,3,3,3]
; AVX-NEXT:    vpermilpd {{.*#+}} xmm6 = xmm0[1,0]
; AVX-NEXT:    vmovshdup {{.*#+}} xmm7 = xmm0[1,1,3,3]
; AVX-NEXT:    vmaxss %xmm7, %xmm0, %xmm0
; AVX-NEXT:    vmaxss %xmm6, %xmm0, %xmm0
; AVX-NEXT:    vmaxss %xmm5, %xmm0, %xmm0
; AVX-NEXT:    vmaxss %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vmaxss %xmm4, %xmm0, %xmm0
; AVX-NEXT:    vmaxss %xmm3, %xmm0, %xmm0
; AVX-NEXT:    vmaxss %xmm2, %xmm0, %xmm0
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v8f32:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX512-NEXT:    vpermilps {{.*#+}} xmm2 = xmm1[3,3,3,3]
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm3 = xmm1[1,0]
; AVX512-NEXT:    vmovshdup {{.*#+}} xmm4 = xmm1[1,1,3,3]
; AVX512-NEXT:    vpermilps {{.*#+}} xmm5 = xmm0[3,3,3,3]
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm6 = xmm0[1,0]
; AVX512-NEXT:    vmovshdup {{.*#+}} xmm7 = xmm0[1,1,3,3]
; AVX512-NEXT:    vmaxss %xmm7, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm6, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm5, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm4, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm3, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm2, %xmm0, %xmm0
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = call nnan float @llvm.experimental.vector.reduce.fmax.v8f32(<8 x float> %a0)
  ret float %1
}

define float @test_v16f32(<16 x float> %a0) {
; SSE2-LABEL: test_v16f32:
; SSE2:       # %bb.0:
; SSE2-NEXT:    maxps %xmm3, %xmm1
; SSE2-NEXT:    maxps %xmm2, %xmm0
; SSE2-NEXT:    maxps %xmm1, %xmm0
; SSE2-NEXT:    movaps %xmm0, %xmm2
; SSE2-NEXT:    shufps {{.*#+}} xmm2 = xmm2[1,1],xmm0[1,1]
; SSE2-NEXT:    movaps %xmm0, %xmm1
; SSE2-NEXT:    maxss %xmm2, %xmm1
; SSE2-NEXT:    movaps %xmm0, %xmm2
; SSE2-NEXT:    unpckhpd {{.*#+}} xmm2 = xmm2[1],xmm0[1]
; SSE2-NEXT:    maxss %xmm2, %xmm1
; SSE2-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,3,3,3]
; SSE2-NEXT:    maxss %xmm0, %xmm1
; SSE2-NEXT:    movaps %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v16f32:
; SSE41:       # %bb.0:
; SSE41-NEXT:    maxps %xmm3, %xmm1
; SSE41-NEXT:    maxps %xmm2, %xmm0
; SSE41-NEXT:    maxps %xmm1, %xmm0
; SSE41-NEXT:    movshdup {{.*#+}} xmm2 = xmm0[1,1,3,3]
; SSE41-NEXT:    movaps %xmm0, %xmm1
; SSE41-NEXT:    maxss %xmm2, %xmm1
; SSE41-NEXT:    movaps %xmm0, %xmm2
; SSE41-NEXT:    unpckhpd {{.*#+}} xmm2 = xmm2[1],xmm0[1]
; SSE41-NEXT:    maxss %xmm2, %xmm1
; SSE41-NEXT:    shufps {{.*#+}} xmm0 = xmm0[3,3,3,3]
; SSE41-NEXT:    maxss %xmm0, %xmm1
; SSE41-NEXT:    movaps %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: test_v16f32:
; AVX:       # %bb.0:
; AVX-NEXT:    vmaxps %ymm1, %ymm0, %ymm0
; AVX-NEXT:    vmovshdup {{.*#+}} xmm1 = xmm0[1,1,3,3]
; AVX-NEXT:    vmaxss %xmm1, %xmm0, %xmm1
; AVX-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm0[1,0]
; AVX-NEXT:    vmaxss %xmm2, %xmm1, %xmm1
; AVX-NEXT:    vpermilps {{.*#+}} xmm2 = xmm0[3,3,3,3]
; AVX-NEXT:    vmaxss %xmm2, %xmm1, %xmm1
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX-NEXT:    vmaxss %xmm0, %xmm1, %xmm1
; AVX-NEXT:    vmovshdup {{.*#+}} xmm2 = xmm0[1,1,3,3]
; AVX-NEXT:    vmaxss %xmm2, %xmm1, %xmm1
; AVX-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm0[1,0]
; AVX-NEXT:    vmaxss %xmm2, %xmm1, %xmm1
; AVX-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[3,3,3,3]
; AVX-NEXT:    vmaxss %xmm0, %xmm1, %xmm0
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v16f32:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vextractf32x4 $3, %zmm0, %xmm1
; AVX512-NEXT:    vpermilps {{.*#+}} xmm8 = xmm1[3,3,3,3]
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm9 = xmm1[1,0]
; AVX512-NEXT:    vmovshdup {{.*#+}} xmm10 = xmm1[1,1,3,3]
; AVX512-NEXT:    vextractf32x4 $2, %zmm0, %xmm5
; AVX512-NEXT:    vpermilps {{.*#+}} xmm11 = xmm5[3,3,3,3]
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm12 = xmm5[1,0]
; AVX512-NEXT:    vmovshdup {{.*#+}} xmm13 = xmm5[1,1,3,3]
; AVX512-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX512-NEXT:    vpermilps {{.*#+}} xmm14 = xmm3[3,3,3,3]
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm15 = xmm3[1,0]
; AVX512-NEXT:    vmovshdup {{.*#+}} xmm7 = xmm3[1,1,3,3]
; AVX512-NEXT:    vpermilps {{.*#+}} xmm2 = xmm0[3,3,3,3]
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm4 = xmm0[1,0]
; AVX512-NEXT:    vmovshdup {{.*#+}} xmm6 = xmm0[1,1,3,3]
; AVX512-NEXT:    vmaxss %xmm6, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm4, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm2, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm3, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm7, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm15, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm14, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm5, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm13, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm12, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm11, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm10, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm9, %xmm0, %xmm0
; AVX512-NEXT:    vmaxss %xmm8, %xmm0, %xmm0
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = call nnan float @llvm.experimental.vector.reduce.fmax.v16f32(<16 x float> %a0)
  ret float %1
}

;
; vXf64
;

define double @test_v2f64(<2 x double> %a0) {
; SSE-LABEL: test_v2f64:
; SSE:       # %bb.0:
; SSE-NEXT:    movapd %xmm0, %xmm1
; SSE-NEXT:    unpckhpd {{.*#+}} xmm1 = xmm1[1],xmm0[1]
; SSE-NEXT:    maxsd %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v2f64:
; AVX:       # %bb.0:
; AVX-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX-NEXT:    vmaxsd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v2f64:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX512-NEXT:    vmaxsd %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    retq
  %1 = call nnan double @llvm.experimental.vector.reduce.fmax.v2f64(<2 x double> %a0)
  ret double %1
}

define double @test_v3f64(<3 x double> %a0) {
; SSE2-LABEL: test_v3f64:
; SSE2:       # %bb.0:
; SSE2-NEXT:    unpcklpd {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE2-NEXT:    shufpd {{.*#+}} xmm2 = xmm2[0],mem[1]
; SSE2-NEXT:    movapd %xmm2, %xmm1
; SSE2-NEXT:    maxpd %xmm0, %xmm1
; SSE2-NEXT:    cmpunordpd %xmm0, %xmm0
; SSE2-NEXT:    andpd %xmm0, %xmm2
; SSE2-NEXT:    andnpd %xmm1, %xmm0
; SSE2-NEXT:    orpd %xmm2, %xmm0
; SSE2-NEXT:    pshufd {{.*#+}} xmm2 = xmm0[2,3,2,3]
; SSE2-NEXT:    movapd %xmm0, %xmm1
; SSE2-NEXT:    cmpunordsd %xmm0, %xmm1
; SSE2-NEXT:    movapd %xmm1, %xmm3
; SSE2-NEXT:    andpd %xmm2, %xmm3
; SSE2-NEXT:    maxsd %xmm0, %xmm2
; SSE2-NEXT:    andnpd %xmm2, %xmm1
; SSE2-NEXT:    orpd %xmm3, %xmm1
; SSE2-NEXT:    movapd %xmm1, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: test_v3f64:
; SSE41:       # %bb.0:
; SSE41-NEXT:    unpcklpd {{.*#+}} xmm0 = xmm0[0],xmm1[0]
; SSE41-NEXT:    blendpd {{.*#+}} xmm2 = xmm2[0],mem[1]
; SSE41-NEXT:    movapd %xmm2, %xmm1
; SSE41-NEXT:    maxpd %xmm0, %xmm1
; SSE41-NEXT:    cmpunordpd %xmm0, %xmm0
; SSE41-NEXT:    blendvpd %xmm0, %xmm2, %xmm1
; SSE41-NEXT:    movapd %xmm1, %xmm2
; SSE41-NEXT:    unpckhpd {{.*#+}} xmm2 = xmm2[1],xmm1[1]
; SSE41-NEXT:    movapd %xmm1, %xmm0
; SSE41-NEXT:    cmpunordsd %xmm1, %xmm0
; SSE41-NEXT:    movapd %xmm0, %xmm3
; SSE41-NEXT:    andpd %xmm2, %xmm3
; SSE41-NEXT:    maxsd %xmm1, %xmm2
; SSE41-NEXT:    andnpd %xmm2, %xmm0
; SSE41-NEXT:    orpd %xmm3, %xmm0
; SSE41-NEXT:    retq
;
; AVX-LABEL: test_v3f64:
; AVX:       # %bb.0:
; AVX-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX-NEXT:    vmaxsd %xmm0, %xmm1, %xmm2
; AVX-NEXT:    vcmpunordsd %xmm0, %xmm0, %xmm3
; AVX-NEXT:    vblendvpd %xmm3, %xmm1, %xmm2, %xmm1
; AVX-NEXT:    vcmpunordsd %xmm1, %xmm1, %xmm2
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX-NEXT:    vmaxsd %xmm1, %xmm0, %xmm1
; AVX-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v3f64:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX512-NEXT:    vmaxsd %xmm0, %xmm1, %xmm2
; AVX512-NEXT:    vcmpunordsd %xmm0, %xmm0, %k1
; AVX512-NEXT:    vmovsd %xmm1, %xmm2, %xmm2 {%k1}
; AVX512-NEXT:    vcmpunordsd %xmm2, %xmm2, %k1
; AVX512-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX512-NEXT:    vmaxsd %xmm2, %xmm1, %xmm0
; AVX512-NEXT:    vmovsd %xmm1, %xmm0, %xmm0 {%k1}
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = call nnan double @llvm.experimental.vector.reduce.fmax.v3f64(<3 x double> %a0)
  ret double %1
}

define double @test_v4f64(<4 x double> %a0) {
; SSE-LABEL: test_v4f64:
; SSE:       # %bb.0:
; SSE-NEXT:    maxpd %xmm1, %xmm0
; SSE-NEXT:    movapd %xmm0, %xmm1
; SSE-NEXT:    unpckhpd {{.*#+}} xmm1 = xmm1[1],xmm0[1]
; SSE-NEXT:    maxsd %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v4f64:
; AVX:       # %bb.0:
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm1[1,0]
; AVX-NEXT:    vpermilpd {{.*#+}} xmm3 = xmm0[1,0]
; AVX-NEXT:    vmaxsd %xmm3, %xmm0, %xmm0
; AVX-NEXT:    vmaxsd %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vmaxsd %xmm2, %xmm0, %xmm0
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v4f64:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm1[1,0]
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm3 = xmm0[1,0]
; AVX512-NEXT:    vmaxsd %xmm3, %xmm0, %xmm0
; AVX512-NEXT:    vmaxsd %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vmaxsd %xmm2, %xmm0, %xmm0
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = call nnan double @llvm.experimental.vector.reduce.fmax.v4f64(<4 x double> %a0)
  ret double %1
}

define double @test_v8f64(<8 x double> %a0) {
; SSE-LABEL: test_v8f64:
; SSE:       # %bb.0:
; SSE-NEXT:    maxpd %xmm3, %xmm1
; SSE-NEXT:    maxpd %xmm2, %xmm0
; SSE-NEXT:    maxpd %xmm1, %xmm0
; SSE-NEXT:    movapd %xmm0, %xmm1
; SSE-NEXT:    unpckhpd {{.*#+}} xmm1 = xmm1[1],xmm0[1]
; SSE-NEXT:    maxsd %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v8f64:
; AVX:       # %bb.0:
; AVX-NEXT:    vmaxpd %ymm1, %ymm0, %ymm0
; AVX-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX-NEXT:    vmaxsd %xmm1, %xmm0, %xmm1
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX-NEXT:    vmaxsd %xmm0, %xmm1, %xmm1
; AVX-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX-NEXT:    vmaxsd %xmm0, %xmm1, %xmm0
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v8f64:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vextractf32x4 $3, %zmm0, %xmm1
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm1[1,0]
; AVX512-NEXT:    vextractf32x4 $2, %zmm0, %xmm3
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm4 = xmm3[1,0]
; AVX512-NEXT:    vextractf128 $1, %ymm0, %xmm5
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm6 = xmm5[1,0]
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm7 = xmm0[1,0]
; AVX512-NEXT:    vmaxsd %xmm7, %xmm0, %xmm0
; AVX512-NEXT:    vmaxsd %xmm5, %xmm0, %xmm0
; AVX512-NEXT:    vmaxsd %xmm6, %xmm0, %xmm0
; AVX512-NEXT:    vmaxsd %xmm3, %xmm0, %xmm0
; AVX512-NEXT:    vmaxsd %xmm4, %xmm0, %xmm0
; AVX512-NEXT:    vmaxsd %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vmaxsd %xmm2, %xmm0, %xmm0
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = call nnan double @llvm.experimental.vector.reduce.fmax.v8f64(<8 x double> %a0)
  ret double %1
}

define double @test_v16f64(<16 x double> %a0) {
; SSE-LABEL: test_v16f64:
; SSE:       # %bb.0:
; SSE-NEXT:    maxpd %xmm7, %xmm3
; SSE-NEXT:    maxpd %xmm5, %xmm1
; SSE-NEXT:    maxpd %xmm3, %xmm1
; SSE-NEXT:    maxpd %xmm6, %xmm2
; SSE-NEXT:    maxpd %xmm4, %xmm0
; SSE-NEXT:    maxpd %xmm2, %xmm0
; SSE-NEXT:    maxpd %xmm1, %xmm0
; SSE-NEXT:    movapd %xmm0, %xmm1
; SSE-NEXT:    unpckhpd {{.*#+}} xmm1 = xmm1[1],xmm0[1]
; SSE-NEXT:    maxsd %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v16f64:
; AVX:       # %bb.0:
; AVX-NEXT:    vmaxpd %ymm3, %ymm1, %ymm1
; AVX-NEXT:    vmaxpd %ymm2, %ymm0, %ymm0
; AVX-NEXT:    vmaxpd %ymm1, %ymm0, %ymm0
; AVX-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX-NEXT:    vmaxsd %xmm1, %xmm0, %xmm1
; AVX-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX-NEXT:    vmaxsd %xmm0, %xmm1, %xmm1
; AVX-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX-NEXT:    vmaxsd %xmm0, %xmm1, %xmm0
; AVX-NEXT:    vzeroupper
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v16f64:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmaxpd %zmm1, %zmm0, %zmm0
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm1 = xmm0[1,0]
; AVX512-NEXT:    vmaxsd %xmm1, %xmm0, %xmm1
; AVX512-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX512-NEXT:    vmaxsd %xmm2, %xmm1, %xmm1
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm2[1,0]
; AVX512-NEXT:    vmaxsd %xmm2, %xmm1, %xmm1
; AVX512-NEXT:    vextractf32x4 $2, %zmm0, %xmm2
; AVX512-NEXT:    vmaxsd %xmm2, %xmm1, %xmm1
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm2 = xmm2[1,0]
; AVX512-NEXT:    vmaxsd %xmm2, %xmm1, %xmm1
; AVX512-NEXT:    vextractf32x4 $3, %zmm0, %xmm0
; AVX512-NEXT:    vmaxsd %xmm0, %xmm1, %xmm1
; AVX512-NEXT:    vpermilpd {{.*#+}} xmm0 = xmm0[1,0]
; AVX512-NEXT:    vmaxsd %xmm0, %xmm1, %xmm0
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = call nnan double @llvm.experimental.vector.reduce.fmax.v16f64(<16 x double> %a0)
  ret double %1
}

define half @test_v2f16(<2 x half> %a0) nounwind {
; SSE-LABEL: test_v2f16:
; SSE:       # %bb.0:
; SSE-NEXT:    pushq %rbx
; SSE-NEXT:    subq $16, %rsp
; SSE-NEXT:    movl %edi, %ebx
; SSE-NEXT:    movzwl %si, %edi
; SSE-NEXT:    callq __gnu_h2f_ieee
; SSE-NEXT:    movaps %xmm0, (%rsp) # 16-byte Spill
; SSE-NEXT:    movzwl %bx, %edi
; SSE-NEXT:    callq __gnu_h2f_ieee
; SSE-NEXT:    movaps %xmm0, %xmm1
; SSE-NEXT:    cmpunordss %xmm0, %xmm1
; SSE-NEXT:    movaps %xmm1, %xmm2
; SSE-NEXT:    movaps (%rsp), %xmm3 # 16-byte Reload
; SSE-NEXT:    andps %xmm3, %xmm2
; SSE-NEXT:    maxss %xmm0, %xmm3
; SSE-NEXT:    andnps %xmm3, %xmm1
; SSE-NEXT:    orps %xmm2, %xmm1
; SSE-NEXT:    movaps %xmm1, %xmm0
; SSE-NEXT:    callq __gnu_f2h_ieee
; SSE-NEXT:    addq $16, %rsp
; SSE-NEXT:    popq %rbx
; SSE-NEXT:    retq
;
; AVX-LABEL: test_v2f16:
; AVX:       # %bb.0:
; AVX-NEXT:    pushq %rbx
; AVX-NEXT:    subq $16, %rsp
; AVX-NEXT:    movl %esi, %ebx
; AVX-NEXT:    movzwl %di, %edi
; AVX-NEXT:    callq __gnu_h2f_ieee
; AVX-NEXT:    vmovss %xmm0, {{[-0-9]+}}(%r{{[sb]}}p) # 4-byte Spill
; AVX-NEXT:    movzwl %bx, %edi
; AVX-NEXT:    callq __gnu_h2f_ieee
; AVX-NEXT:    vmovss {{[-0-9]+}}(%r{{[sb]}}p), %xmm2 # 4-byte Reload
; AVX-NEXT:    # xmm2 = mem[0],zero,zero,zero
; AVX-NEXT:    vmaxss %xmm2, %xmm0, %xmm1
; AVX-NEXT:    vcmpunordss %xmm2, %xmm2, %xmm2
; AVX-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; AVX-NEXT:    callq __gnu_f2h_ieee
; AVX-NEXT:    addq $16, %rsp
; AVX-NEXT:    popq %rbx
; AVX-NEXT:    retq
;
; AVX512-LABEL: test_v2f16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    movzwl %di, %eax
; AVX512-NEXT:    vmovd %eax, %xmm0
; AVX512-NEXT:    vcvtph2ps %xmm0, %xmm0
; AVX512-NEXT:    movzwl %si, %eax
; AVX512-NEXT:    vmovd %eax, %xmm1
; AVX512-NEXT:    vcvtph2ps %xmm1, %xmm1
; AVX512-NEXT:    vmaxss %xmm0, %xmm1, %xmm2
; AVX512-NEXT:    vcmpunordss %xmm0, %xmm0, %k1
; AVX512-NEXT:    vmovss %xmm1, %xmm2, %xmm2 {%k1}
; AVX512-NEXT:    vcvtps2ph $4, %xmm2, %xmm0
; AVX512-NEXT:    vmovd %xmm0, %eax
; AVX512-NEXT:    # kill: def $ax killed $ax killed $eax
; AVX512-NEXT:    retq
  %1 = call nnan half @llvm.experimental.vector.reduce.fmax.v2f16(<2 x half> %a0)
  ret half %1
}
declare float @llvm.experimental.vector.reduce.fmax.v2f32(<2 x float>)
declare float @llvm.experimental.vector.reduce.fmax.v4f32(<4 x float>)
declare float @llvm.experimental.vector.reduce.fmax.v8f32(<8 x float>)
declare float @llvm.experimental.vector.reduce.fmax.v16f32(<16 x float>)

declare double @llvm.experimental.vector.reduce.fmax.v2f64(<2 x double>)
declare double @llvm.experimental.vector.reduce.fmax.v3f64(<3 x double>)
declare double @llvm.experimental.vector.reduce.fmax.v4f64(<4 x double>)
declare double @llvm.experimental.vector.reduce.fmax.v8f64(<8 x double>)
declare double @llvm.experimental.vector.reduce.fmax.v16f64(<16 x double>)

declare half @llvm.experimental.vector.reduce.fmax.v2f16(<2 x half>)
