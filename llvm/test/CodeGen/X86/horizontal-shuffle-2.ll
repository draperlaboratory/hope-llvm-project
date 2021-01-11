; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-apple-darwin -mattr=+sse4.1 | FileCheck %s --check-prefix=SSE
; RUN: llc < %s -mtriple=i686-apple-darwin -mattr=+avx2 | FileCheck %s --check-prefix=AVX
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=+sse4.1 | FileCheck %s --check-prefix=SSE
; RUN: llc < %s -mtriple=x86_64-apple-darwin -mattr=+avx2 | FileCheck %s --check-prefix=AVX

define <4 x float> @test_unpacklo_hadd_v4f32(<4 x float> %0, <4 x float> %1, <4 x float> %2, <4 x float> %3) {
; SSE-LABEL: test_unpacklo_hadd_v4f32:
; SSE:       ## %bb.0:
; SSE-NEXT:    haddps %xmm2, %xmm0
; SSE-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,2,1,3]
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_unpacklo_hadd_v4f32:
; AVX:       ## %bb.0:
; AVX-NEXT:    vhaddps %xmm2, %xmm0, %xmm0
; AVX-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[0,2,1,3]
; AVX-NEXT:    ret{{[l|q]}}
  %5 = tail call <4 x float> @llvm.x86.sse3.hadd.ps(<4 x float> %0, <4 x float> %1) #4
  %6 = tail call <4 x float> @llvm.x86.sse3.hadd.ps(<4 x float> %2, <4 x float> %3) #4
  %7 = shufflevector <4 x float> %5, <4 x float> %6, <4 x i32> <i32 0, i32 4, i32 1, i32 5>
  ret <4 x float> %7
}

define <4 x float> @test_unpackhi_hadd_v4f32(<4 x float> %0, <4 x float> %1, <4 x float> %2, <4 x float> %3) {
; SSE-LABEL: test_unpackhi_hadd_v4f32:
; SSE:       ## %bb.0:
; SSE-NEXT:    movaps %xmm1, %xmm0
; SSE-NEXT:    haddps %xmm3, %xmm0
; SSE-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,2,1,3]
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_unpackhi_hadd_v4f32:
; AVX:       ## %bb.0:
; AVX-NEXT:    vhaddps %xmm3, %xmm1, %xmm0
; AVX-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[0,2,1,3]
; AVX-NEXT:    ret{{[l|q]}}
  %5 = tail call <4 x float> @llvm.x86.sse3.hadd.ps(<4 x float> %0, <4 x float> %1) #4
  %6 = tail call <4 x float> @llvm.x86.sse3.hadd.ps(<4 x float> %2, <4 x float> %3) #4
  %7 = shufflevector <4 x float> %5, <4 x float> %6, <4 x i32> <i32 2, i32 6, i32 3, i32 7>
  ret <4 x float> %7
}

define <4 x float> @test_unpacklo_hsub_v4f32(<4 x float> %0, <4 x float> %1, <4 x float> %2, <4 x float> %3) {
; SSE-LABEL: test_unpacklo_hsub_v4f32:
; SSE:       ## %bb.0:
; SSE-NEXT:    hsubps %xmm2, %xmm0
; SSE-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,2,1,3]
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_unpacklo_hsub_v4f32:
; AVX:       ## %bb.0:
; AVX-NEXT:    vhsubps %xmm2, %xmm0, %xmm0
; AVX-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[0,2,1,3]
; AVX-NEXT:    ret{{[l|q]}}
  %5 = tail call <4 x float> @llvm.x86.sse3.hsub.ps(<4 x float> %0, <4 x float> %1) #4
  %6 = tail call <4 x float> @llvm.x86.sse3.hsub.ps(<4 x float> %2, <4 x float> %3) #4
  %7 = shufflevector <4 x float> %5, <4 x float> %6, <4 x i32> <i32 0, i32 4, i32 1, i32 5>
  ret <4 x float> %7
}

define <4 x float> @test_unpackhi_hsub_v4f32(<4 x float> %0, <4 x float> %1, <4 x float> %2, <4 x float> %3) {
; SSE-LABEL: test_unpackhi_hsub_v4f32:
; SSE:       ## %bb.0:
; SSE-NEXT:    movaps %xmm1, %xmm0
; SSE-NEXT:    hsubps %xmm3, %xmm0
; SSE-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,2,1,3]
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_unpackhi_hsub_v4f32:
; AVX:       ## %bb.0:
; AVX-NEXT:    vhsubps %xmm3, %xmm1, %xmm0
; AVX-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[0,2,1,3]
; AVX-NEXT:    ret{{[l|q]}}
  %5 = tail call <4 x float> @llvm.x86.sse3.hsub.ps(<4 x float> %0, <4 x float> %1) #4
  %6 = tail call <4 x float> @llvm.x86.sse3.hsub.ps(<4 x float> %2, <4 x float> %3) #4
  %7 = shufflevector <4 x float> %5, <4 x float> %6, <4 x i32> <i32 2, i32 6, i32 3, i32 7>
  ret <4 x float> %7
}

define <4 x i32> @test_unpacklo_hadd_v4i32(<4 x i32> %0, <4 x i32> %1, <4 x i32> %2, <4 x i32> %3) {
; SSE-LABEL: test_unpacklo_hadd_v4i32:
; SSE:       ## %bb.0:
; SSE-NEXT:    phaddd %xmm2, %xmm0
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,1,3]
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_unpacklo_hadd_v4i32:
; AVX:       ## %bb.0:
; AVX-NEXT:    vphaddd %xmm2, %xmm0, %xmm0
; AVX-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,1,3]
; AVX-NEXT:    ret{{[l|q]}}
  %5 = tail call <4 x i32> @llvm.x86.ssse3.phadd.d.128(<4 x i32> %0, <4 x i32> %1) #5
  %6 = tail call <4 x i32> @llvm.x86.ssse3.phadd.d.128(<4 x i32> %2, <4 x i32> %3) #5
  %7 = shufflevector <4 x i32> %5, <4 x i32> %6, <4 x i32> <i32 0, i32 4, i32 1, i32 5>
  ret <4 x i32> %7
}

define <4 x i32> @test_unpackhi_hadd_v4i32(<4 x i32> %0, <4 x i32> %1, <4 x i32> %2, <4 x i32> %3) {
; SSE-LABEL: test_unpackhi_hadd_v4i32:
; SSE:       ## %bb.0:
; SSE-NEXT:    phaddd %xmm3, %xmm1
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[0,2,1,3]
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_unpackhi_hadd_v4i32:
; AVX:       ## %bb.0:
; AVX-NEXT:    vphaddd %xmm3, %xmm1, %xmm0
; AVX-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,1,3]
; AVX-NEXT:    ret{{[l|q]}}
  %5 = tail call <4 x i32> @llvm.x86.ssse3.phadd.d.128(<4 x i32> %0, <4 x i32> %1) #5
  %6 = tail call <4 x i32> @llvm.x86.ssse3.phadd.d.128(<4 x i32> %2, <4 x i32> %3) #5
  %7 = shufflevector <4 x i32> %5, <4 x i32> %6, <4 x i32> <i32 2, i32 6, i32 3, i32 7>
  ret <4 x i32> %7
}

define <4 x i32> @test_unpacklo_hsub_v4i32(<4 x i32> %0, <4 x i32> %1, <4 x i32> %2, <4 x i32> %3) {
; SSE-LABEL: test_unpacklo_hsub_v4i32:
; SSE:       ## %bb.0:
; SSE-NEXT:    phsubd %xmm2, %xmm0
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[0,2,1,3]
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_unpacklo_hsub_v4i32:
; AVX:       ## %bb.0:
; AVX-NEXT:    vphsubd %xmm2, %xmm0, %xmm0
; AVX-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,1,3]
; AVX-NEXT:    ret{{[l|q]}}
  %5 = tail call <4 x i32> @llvm.x86.ssse3.phsub.d.128(<4 x i32> %0, <4 x i32> %1) #5
  %6 = tail call <4 x i32> @llvm.x86.ssse3.phsub.d.128(<4 x i32> %2, <4 x i32> %3) #5
  %7 = shufflevector <4 x i32> %5, <4 x i32> %6, <4 x i32> <i32 0, i32 4, i32 1, i32 5>
  ret <4 x i32> %7
}

define <4 x i32> @test_unpackhi_hsub_v4i32(<4 x i32> %0, <4 x i32> %1, <4 x i32> %2, <4 x i32> %3) {
; SSE-LABEL: test_unpackhi_hsub_v4i32:
; SSE:       ## %bb.0:
; SSE-NEXT:    phsubd %xmm3, %xmm1
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm1[0,2,1,3]
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_unpackhi_hsub_v4i32:
; AVX:       ## %bb.0:
; AVX-NEXT:    vphsubd %xmm3, %xmm1, %xmm0
; AVX-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[0,2,1,3]
; AVX-NEXT:    ret{{[l|q]}}
  %5 = tail call <4 x i32> @llvm.x86.ssse3.phsub.d.128(<4 x i32> %0, <4 x i32> %1) #5
  %6 = tail call <4 x i32> @llvm.x86.ssse3.phsub.d.128(<4 x i32> %2, <4 x i32> %3) #5
  %7 = shufflevector <4 x i32> %5, <4 x i32> %6, <4 x i32> <i32 2, i32 6, i32 3, i32 7>
  ret <4 x i32> %7
}

;
; Special Case
;

define <4 x float> @test_unpacklo_hadd_v4f32_unary(<4 x float> %0) {
; SSE-LABEL: test_unpacklo_hadd_v4f32_unary:
; SSE:       ## %bb.0:
; SSE-NEXT:    haddps %xmm0, %xmm0
; SSE-NEXT:    unpcklps {{.*#+}} xmm0 = xmm0[0,0,1,1]
; SSE-NEXT:    ret{{[l|q]}}
;
; AVX-LABEL: test_unpacklo_hadd_v4f32_unary:
; AVX:       ## %bb.0:
; AVX-NEXT:    vhaddps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[0,0,1,1]
; AVX-NEXT:    ret{{[l|q]}}
  %2 = tail call <4 x float> @llvm.x86.sse3.hadd.ps(<4 x float> %0, <4 x float> %0) #4
  %3 = shufflevector <4 x float> %2, <4 x float> %2, <4 x i32> <i32 0, i32 4, i32 1, i32 5>
  ret <4 x float> %3
}

declare <4 x float> @llvm.x86.sse3.hadd.ps(<4 x float>, <4 x float>)
declare <4 x float> @llvm.x86.sse3.hsub.ps(<4 x float>, <4 x float>)
declare <2 x double> @llvm.x86.sse3.hadd.pd(<2 x double>, <2 x double>)
declare <2 x double> @llvm.x86.sse3.hsub.pd(<2 x double>, <2 x double>)

declare <8 x i16> @llvm.x86.ssse3.phadd.w.128(<8 x i16>, <8 x i16>)
declare <4 x i32> @llvm.x86.ssse3.phadd.d.128(<4 x i32>, <4 x i32>)
declare <8 x i16> @llvm.x86.ssse3.phsub.w.128(<8 x i16>, <8 x i16>)
declare <4 x i32> @llvm.x86.ssse3.phsub.d.128(<4 x i32>, <4 x i32>)

declare <16 x i8> @llvm.x86.sse2.packsswb.128(<8 x i16>, <8 x i16>)
declare <8 x i16> @llvm.x86.sse2.packssdw.128(<4 x i32>, <4 x i32>)
declare <16 x i8> @llvm.x86.sse2.packuswb.128(<8 x i16>, <8 x i16>)
declare <8 x i16> @llvm.x86.sse41.packusdw(<4 x i32>, <4 x i32>)
