; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=CHECK,AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefixes=CHECK,AVX2

declare i32 @llvm.x86.avx.movmsk.pd.256(<4 x double>)
declare i32 @llvm.x86.avx.movmsk.ps.256(<8 x float>)

; TODO - Use widest possible vector for movmsk comparisons

define i1 @movmskps_bitcast_v4f64(<4 x double> %a0) {
; CHECK-LABEL: movmskps_bitcast_v4f64:
; CHECK:       # %bb.0:
; CHECK-NEXT:    vxorpd %xmm1, %xmm1, %xmm1
; CHECK-NEXT:    vcmpeqpd %ymm1, %ymm0, %ymm0
; CHECK-NEXT:    vmovmskps %ymm0, %eax
; CHECK-NEXT:    testl %eax, %eax
; CHECK-NEXT:    sete %al
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %1 = fcmp oeq <4 x double> %a0, zeroinitializer
  %2 = sext <4 x i1> %1 to <4 x i64>
  %3 = bitcast <4 x i64> %2 to <8 x float>
  %4 = tail call i32 @llvm.x86.avx.movmsk.ps.256(<8 x float> %3)
  %5 = icmp eq i32 %4, 0
  ret i1 %5
}

;
; TODO - Avoid sign extension ops when just extracting the sign bits.
;

define i32 @movmskpd_cmpgt_v4i64(<4 x i64> %a0) {
; AVX1-LABEL: movmskpd_cmpgt_v4i64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX1-NEXT:    vpcmpgtq %xmm0, %xmm1, %xmm1
; AVX1-NEXT:    vblendpd {{.*#+}} ymm0 = ymm1[0,1],ymm0[2,3]
; AVX1-NEXT:    vmovmskpd %ymm0, %eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: movmskpd_cmpgt_v4i64:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovmskpd %ymm0, %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
  %1 = icmp sgt <4 x i64> zeroinitializer, %a0
  %2 = sext <4 x i1> %1 to <4 x i64>
  %3 = bitcast <4 x i64> %2 to <4 x double>
  %4 = tail call i32 @llvm.x86.avx.movmsk.pd.256(<4 x double> %3)
  ret i32 %4
}

define i32 @movmskps_ashr_v8i32(<8 x i32> %a0)  {
; AVX1-LABEL: movmskps_ashr_v8i32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpsrad $31, %xmm0, %xmm1
; AVX1-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5,6,7]
; AVX1-NEXT:    vmovmskps %ymm0, %eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: movmskps_ashr_v8i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovmskps %ymm0, %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
  %1 = ashr <8 x i32> %a0, <i32 31, i32 31, i32 31, i32 31, i32 31, i32 31, i32 31, i32 31>
  %2 = bitcast <8 x i32> %1 to <8 x float>
  %3 = tail call i32 @llvm.x86.avx.movmsk.ps.256(<8 x float> %2)
  ret i32 %3
}

define i32 @movmskps_sext_v4i64(<4 x i32> %a0)  {
; AVX1-LABEL: movmskps_sext_v4i64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpmovsxdq %xmm0, %xmm1
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; AVX1-NEXT:    vpmovsxdq %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    vmovmskpd %ymm0, %eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: movmskps_sext_v4i64:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpmovsxdq %xmm0, %ymm0
; AVX2-NEXT:    vmovmskpd %ymm0, %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
  %1 = sext <4 x i32> %a0 to <4 x i64>
  %2 = bitcast <4 x i64> %1 to <4 x double>
  %3 = tail call i32 @llvm.x86.avx.movmsk.pd.256(<4 x double> %2)
  ret i32 %3
}

define i32 @movmskps_sext_v8i32(<8 x i16> %a0)  {
; AVX1-LABEL: movmskps_sext_v8i32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpmovsxwd %xmm0, %xmm1
; AVX1-NEXT:    vpshufd {{.*#+}} xmm0 = xmm0[2,3,0,1]
; AVX1-NEXT:    vpmovsxwd %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm0, %ymm1, %ymm0
; AVX1-NEXT:    vmovmskps %ymm0, %eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: movmskps_sext_v8i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpmovsxwd %xmm0, %ymm0
; AVX2-NEXT:    vmovmskps %ymm0, %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
  %1 = sext <8 x i16> %a0 to <8 x i32>
  %2 = bitcast <8 x i32> %1 to <8 x float>
  %3 = tail call i32 @llvm.x86.avx.movmsk.ps.256(<8 x float> %2)
  ret i32 %3
}
