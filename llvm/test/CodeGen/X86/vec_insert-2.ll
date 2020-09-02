; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown -mattr=+sse2,-sse4.1 | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+sse2,-sse4.1 | FileCheck %s --check-prefix=X64

define <4 x float> @t1(float %s, <4 x float> %tmp) nounwind {
; X32-LABEL: t1:
; X32:       # %bb.0:
; X32-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; X32-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,1],xmm0[2,3]
; X32-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,0]
; X32-NEXT:    retl
;
; X64-LABEL: t1:
; X64:       # %bb.0:
; X64-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,3]
; X64-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,1],xmm0[2,0]
; X64-NEXT:    movaps %xmm1, %xmm0
; X64-NEXT:    retq
  %tmp1 = insertelement <4 x float> %tmp, float %s, i32 3
  ret <4 x float> %tmp1
}

define <4 x i32> @t2(i32 %s, <4 x i32> %tmp) nounwind {
; X32-LABEL: t2:
; X32:       # %bb.0:
; X32-NEXT:    movss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; X32-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,1],xmm0[2,3]
; X32-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,0]
; X32-NEXT:    retl
;
; X64-LABEL: t2:
; X64:       # %bb.0:
; X64-NEXT:    movd %edi, %xmm1
; X64-NEXT:    shufps {{.*#+}} xmm1 = xmm1[0,1],xmm0[2,3]
; X64-NEXT:    shufps {{.*#+}} xmm0 = xmm0[0,1],xmm1[2,0]
; X64-NEXT:    retq
  %tmp1 = insertelement <4 x i32> %tmp, i32 %s, i32 3
  ret <4 x i32> %tmp1
}

define <2 x double> @t3(double %s, <2 x double> %tmp) nounwind {
; X32-LABEL: t3:
; X32:       # %bb.0:
; X32-NEXT:    movhps {{.*#+}} xmm0 = xmm0[0,1],mem[0,1]
; X32-NEXT:    retl
;
; X64-LABEL: t3:
; X64:       # %bb.0:
; X64-NEXT:    movlhps {{.*#+}} xmm1 = xmm1[0],xmm0[0]
; X64-NEXT:    movaps %xmm1, %xmm0
; X64-NEXT:    retq
  %tmp1 = insertelement <2 x double> %tmp, double %s, i32 1
  ret <2 x double> %tmp1
}

define <8 x i16> @t4(i16 %s, <8 x i16> %tmp) nounwind {
; X32-LABEL: t4:
; X32:       # %bb.0:
; X32-NEXT:    pinsrw $5, {{[0-9]+}}(%esp), %xmm0
; X32-NEXT:    retl
;
; X64-LABEL: t4:
; X64:       # %bb.0:
; X64-NEXT:    pinsrw $5, %edi, %xmm0
; X64-NEXT:    retq
  %tmp1 = insertelement <8 x i16> %tmp, i16 %s, i32 5
  ret <8 x i16> %tmp1
}
