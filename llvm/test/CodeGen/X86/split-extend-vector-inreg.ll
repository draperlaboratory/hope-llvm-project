; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown -mattr=+avx | FileCheck %s --check-prefixes=CHECK,X86
; RUN: llc < %s -mtriple=x86_64-unknown -mattr=+avx | FileCheck %s --check-prefixes=CHECK,X64

define <4 x i64> @autogen_SD88863() {
; CHECK-LABEL: autogen_SD88863:
; CHECK:       # %bb.0: # %BB
; CHECK-NEXT:    vpermilps {{.*#+}} xmm0 = xmm0[2,3,2,3]
; CHECK-NEXT:    vinsertf128 $1, %xmm0, %ymm0, %ymm0
; CHECK-NEXT:    vxorps %xmm1, %xmm1, %xmm1
; CHECK-NEXT:    vblendps {{.*#+}} ymm0 = ymm1[0,1,2,3],ymm0[4,5],ymm1[6,7]
; CHECK-NEXT:    movb $1, %al
; CHECK-NEXT:    .p2align 4, 0x90
; CHECK-NEXT:  .LBB0_1: # %CF
; CHECK-NEXT:    # =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    testb %al, %al
; CHECK-NEXT:    jne .LBB0_1
; CHECK-NEXT:  # %bb.2: # %CF240
; CHECK-NEXT:    ret{{[l|q]}}
BB:
  %I26 = insertelement <4 x i64> undef, i64 undef, i32 2
  br label %CF

CF:
  %E66 = extractelement <4 x i64> %I26, i32 1
  %I68 = insertelement <4 x i64> zeroinitializer, i64 %E66, i32 2
  %Cmp72 = icmp eq i32 0, 0
  br i1 %Cmp72, label %CF, label %CF240

CF240:
  ret <4 x i64> %I68
}
