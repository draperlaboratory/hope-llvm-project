; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx       | FileCheck %s --check-prefix=AVX --check-prefix=AVX12F --check-prefix=AVX12 --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx2      | FileCheck %s --check-prefix=AVX --check-prefix=AVX12F --check-prefix=AVX12 --check-prefix=AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx512f   | FileCheck %s --check-prefix=AVX --check-prefix=AVX12F --check-prefix=AVX512 --check-prefix=AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx512vl  | FileCheck %s --check-prefix=AVX                       --check-prefix=AVX512 --check-prefix=AVX512VL

; The condition vector for BLENDV* only cares about the sign bit of each element.
; So in these tests, if we generate BLENDV*, we should be able to remove the redundant cmp op.

; Test 128-bit vectors for all legal element types.

define <16 x i8> @signbit_sel_v16i8(<16 x i8> %x, <16 x i8> %y, <16 x i8> %mask) {
; AVX-LABEL: signbit_sel_v16i8:
; AVX:       # %bb.0:
; AVX-NEXT:    vpblendvb %xmm2, %xmm0, %xmm1, %xmm0
; AVX-NEXT:    retq
  %tr = icmp slt <16 x i8> %mask, zeroinitializer
  %z = select <16 x i1> %tr, <16 x i8> %x, <16 x i8> %y
  ret <16 x i8> %z
}

; Sorry 16-bit, you're not important enough to support?

define <8 x i16> @signbit_sel_v8i16(<8 x i16> %x, <8 x i16> %y, <8 x i16> %mask) {
; AVX-LABEL: signbit_sel_v8i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX-NEXT:    vpcmpgtw %xmm2, %xmm3, %xmm2
; AVX-NEXT:    vpblendvb %xmm2, %xmm0, %xmm1, %xmm0
; AVX-NEXT:    retq
  %tr = icmp slt <8 x i16> %mask, zeroinitializer
  %z = select <8 x i1> %tr, <8 x i16> %x, <8 x i16> %y
  ret <8 x i16> %z
}

define <4 x i32> @signbit_sel_v4i32(<4 x i32> %x, <4 x i32> %y, <4 x i32> %mask) {
; AVX12-LABEL: signbit_sel_v4i32:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: signbit_sel_v4i32:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $xmm2 killed $xmm2 def $zmm2
; AVX512F-NEXT:    # kill: def $xmm1 killed $xmm1 def $zmm1
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 def $zmm0
; AVX512F-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512F-NEXT:    vpcmpgtd %zmm2, %zmm3, %k1
; AVX512F-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 killed $zmm0
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: signbit_sel_v4i32:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512VL-NEXT:    vpcmpgtd %xmm2, %xmm3, %k1
; AVX512VL-NEXT:    vpblendmd %xmm0, %xmm1, %xmm0 {%k1}
; AVX512VL-NEXT:    retq
  %tr = icmp slt <4 x i32> %mask, zeroinitializer
  %z = select <4 x i1> %tr, <4 x i32> %x, <4 x i32> %y
  ret <4 x i32> %z
}

define <2 x i64> @signbit_sel_v2i64(<2 x i64> %x, <2 x i64> %y, <2 x i64> %mask) {
; AVX12-LABEL: signbit_sel_v2i64:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: signbit_sel_v2i64:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $xmm2 killed $xmm2 def $zmm2
; AVX512F-NEXT:    # kill: def $xmm1 killed $xmm1 def $zmm1
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 def $zmm0
; AVX512F-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512F-NEXT:    vpcmpgtq %zmm2, %zmm3, %k1
; AVX512F-NEXT:    vpblendmq %zmm0, %zmm1, %zmm0 {%k1}
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 killed $zmm0
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: signbit_sel_v2i64:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512VL-NEXT:    vpcmpgtq %xmm2, %xmm3, %k1
; AVX512VL-NEXT:    vpblendmq %xmm0, %xmm1, %xmm0 {%k1}
; AVX512VL-NEXT:    retq
  %tr = icmp slt <2 x i64> %mask, zeroinitializer
  %z = select <2 x i1> %tr, <2 x i64> %x, <2 x i64> %y
  ret <2 x i64> %z
}

define <4 x float> @signbit_sel_v4f32(<4 x float> %x, <4 x float> %y, <4 x i32> %mask) {
; AVX12-LABEL: signbit_sel_v4f32:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: signbit_sel_v4f32:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $xmm2 killed $xmm2 def $zmm2
; AVX512F-NEXT:    # kill: def $xmm1 killed $xmm1 def $zmm1
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 def $zmm0
; AVX512F-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512F-NEXT:    vpcmpgtd %zmm2, %zmm3, %k1
; AVX512F-NEXT:    vblendmps %zmm0, %zmm1, %zmm0 {%k1}
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 killed $zmm0
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: signbit_sel_v4f32:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512VL-NEXT:    vpcmpgtd %xmm2, %xmm3, %k1
; AVX512VL-NEXT:    vblendmps %xmm0, %xmm1, %xmm0 {%k1}
; AVX512VL-NEXT:    retq
  %tr = icmp slt <4 x i32> %mask, zeroinitializer
  %z = select <4 x i1> %tr, <4 x float> %x, <4 x float> %y
  ret <4 x float> %z
}

define <2 x double> @signbit_sel_v2f64(<2 x double> %x, <2 x double> %y, <2 x i64> %mask) {
; AVX12-LABEL: signbit_sel_v2f64:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vblendvpd %xmm2, %xmm0, %xmm1, %xmm0
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: signbit_sel_v2f64:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $xmm2 killed $xmm2 def $zmm2
; AVX512F-NEXT:    # kill: def $xmm1 killed $xmm1 def $zmm1
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 def $zmm0
; AVX512F-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512F-NEXT:    vpcmpgtq %zmm2, %zmm3, %k1
; AVX512F-NEXT:    vblendmpd %zmm0, %zmm1, %zmm0 {%k1}
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 killed $zmm0
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: signbit_sel_v2f64:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512VL-NEXT:    vpcmpgtq %xmm2, %xmm3, %k1
; AVX512VL-NEXT:    vblendmpd %xmm0, %xmm1, %xmm0 {%k1}
; AVX512VL-NEXT:    retq
  %tr = icmp slt <2 x i64> %mask, zeroinitializer
  %z = select <2 x i1> %tr, <2 x double> %x, <2 x double> %y
  ret <2 x double> %z
}

; Test 256-bit vectors to see differences between AVX1 and AVX2.

define <32 x i8> @signbit_sel_v32i8(<32 x i8> %x, <32 x i8> %y, <32 x i8> %mask) {
; AVX1-LABEL: signbit_sel_v32i8:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpgtb %xmm3, %xmm4, %xmm3
; AVX1-NEXT:    vpcmpgtb %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm2, %ymm2
; AVX1-NEXT:    vandnps %ymm1, %ymm2, %ymm1
; AVX1-NEXT:    vandps %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    vorps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: signbit_sel_v32i8:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpblendvb %ymm2, %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: signbit_sel_v32i8:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpblendvb %ymm2, %ymm0, %ymm1, %ymm0
; AVX512-NEXT:    retq
  %tr = icmp slt <32 x i8> %mask, zeroinitializer
  %z = select <32 x i1> %tr, <32 x i8> %x, <32 x i8> %y
  ret <32 x i8> %z
}

; Sorry 16-bit, you'll never be important enough to support?

define <16 x i16> @signbit_sel_v16i16(<16 x i16> %x, <16 x i16> %y, <16 x i16> %mask) {
; AVX1-LABEL: signbit_sel_v16i16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpgtw %xmm3, %xmm4, %xmm3
; AVX1-NEXT:    vpcmpgtw %xmm2, %xmm4, %xmm2
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm2, %ymm2
; AVX1-NEXT:    vandnps %ymm1, %ymm2, %ymm1
; AVX1-NEXT:    vandps %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    vorps %ymm1, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: signbit_sel_v16i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpcmpgtw %ymm2, %ymm3, %ymm2
; AVX2-NEXT:    vpblendvb %ymm2, %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: signbit_sel_v16i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512-NEXT:    vpcmpgtw %ymm2, %ymm3, %ymm2
; AVX512-NEXT:    vpblendvb %ymm2, %ymm0, %ymm1, %ymm0
; AVX512-NEXT:    retq
  %tr = icmp slt <16 x i16> %mask, zeroinitializer
  %z = select <16 x i1> %tr, <16 x i16> %x, <16 x i16> %y
  ret <16 x i16> %z
}

define <8 x i32> @signbit_sel_v8i32(<8 x i32> %x, <8 x i32> %y, <8 x i32> %mask) {
; AVX12-LABEL: signbit_sel_v8i32:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vblendvps %ymm2, %ymm0, %ymm1, %ymm0
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: signbit_sel_v8i32:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $ymm2 killed $ymm2 def $zmm2
; AVX512F-NEXT:    # kill: def $ymm1 killed $ymm1 def $zmm1
; AVX512F-NEXT:    # kill: def $ymm0 killed $ymm0 def $zmm0
; AVX512F-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512F-NEXT:    vpcmpgtd %zmm2, %zmm3, %k1
; AVX512F-NEXT:    vpblendmd %zmm0, %zmm1, %zmm0 {%k1}
; AVX512F-NEXT:    # kill: def $ymm0 killed $ymm0 killed $zmm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: signbit_sel_v8i32:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512VL-NEXT:    vpcmpgtd %ymm2, %ymm3, %k1
; AVX512VL-NEXT:    vpblendmd %ymm0, %ymm1, %ymm0 {%k1}
; AVX512VL-NEXT:    retq
  %tr = icmp slt <8 x i32> %mask, zeroinitializer
  %z = select <8 x i1> %tr, <8 x i32> %x, <8 x i32> %y
  ret <8 x i32> %z
}

define <4 x i64> @signbit_sel_v4i64(<4 x i64> %x, <4 x i64> %y, <4 x i64> %mask) {
; AVX12-LABEL: signbit_sel_v4i64:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: signbit_sel_v4i64:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $ymm2 killed $ymm2 def $zmm2
; AVX512F-NEXT:    # kill: def $ymm1 killed $ymm1 def $zmm1
; AVX512F-NEXT:    # kill: def $ymm0 killed $ymm0 def $zmm0
; AVX512F-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512F-NEXT:    vpcmpgtq %zmm2, %zmm3, %k1
; AVX512F-NEXT:    vpblendmq %zmm0, %zmm1, %zmm0 {%k1}
; AVX512F-NEXT:    # kill: def $ymm0 killed $ymm0 killed $zmm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: signbit_sel_v4i64:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512VL-NEXT:    vpcmpgtq %ymm2, %ymm3, %k1
; AVX512VL-NEXT:    vpblendmq %ymm0, %ymm1, %ymm0 {%k1}
; AVX512VL-NEXT:    retq
  %tr = icmp slt <4 x i64> %mask, zeroinitializer
  %z = select <4 x i1> %tr, <4 x i64> %x, <4 x i64> %y
  ret <4 x i64> %z
}

define <4 x double> @signbit_sel_v4f64(<4 x double> %x, <4 x double> %y, <4 x i64> %mask) {
; AVX12-LABEL: signbit_sel_v4f64:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: signbit_sel_v4f64:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $ymm2 killed $ymm2 def $zmm2
; AVX512F-NEXT:    # kill: def $ymm1 killed $ymm1 def $zmm1
; AVX512F-NEXT:    # kill: def $ymm0 killed $ymm0 def $zmm0
; AVX512F-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512F-NEXT:    vpcmpgtq %zmm2, %zmm3, %k1
; AVX512F-NEXT:    vblendmpd %zmm0, %zmm1, %zmm0 {%k1}
; AVX512F-NEXT:    # kill: def $ymm0 killed $ymm0 killed $zmm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: signbit_sel_v4f64:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512VL-NEXT:    vpcmpgtq %ymm2, %ymm3, %k1
; AVX512VL-NEXT:    vblendmpd %ymm0, %ymm1, %ymm0 {%k1}
; AVX512VL-NEXT:    retq
  %tr = icmp slt <4 x i64> %mask, zeroinitializer
  %z = select <4 x i1> %tr, <4 x double> %x, <4 x double> %y
  ret <4 x double> %z
}

; Try a condition with a different type than the select operands.

define <4 x double> @signbit_sel_v4f64_small_mask(<4 x double> %x, <4 x double> %y, <4 x i32> %mask) {
; AVX1-LABEL: signbit_sel_v4f64_small_mask:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpmovsxdq %xmm2, %xmm3
; AVX1-NEXT:    vpshufd {{.*#+}} xmm2 = xmm2[2,3,0,1]
; AVX1-NEXT:    vpmovsxdq %xmm2, %xmm2
; AVX1-NEXT:    vinsertf128 $1, %xmm2, %ymm3, %ymm2
; AVX1-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: signbit_sel_v4f64_small_mask:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpmovsxdq %xmm2, %ymm2
; AVX2-NEXT:    vblendvpd %ymm2, %ymm0, %ymm1, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: signbit_sel_v4f64_small_mask:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $xmm2 killed $xmm2 def $zmm2
; AVX512F-NEXT:    # kill: def $ymm1 killed $ymm1 def $zmm1
; AVX512F-NEXT:    # kill: def $ymm0 killed $ymm0 def $zmm0
; AVX512F-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512F-NEXT:    vpcmpgtd %zmm2, %zmm3, %k1
; AVX512F-NEXT:    vblendmpd %zmm0, %zmm1, %zmm0 {%k1}
; AVX512F-NEXT:    # kill: def $ymm0 killed $ymm0 killed $zmm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: signbit_sel_v4f64_small_mask:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512VL-NEXT:    vpcmpgtd %xmm2, %xmm3, %k1
; AVX512VL-NEXT:    vblendmpd %ymm0, %ymm1, %ymm0 {%k1}
; AVX512VL-NEXT:    retq
  %tr = icmp slt <4 x i32> %mask, zeroinitializer
  %z = select <4 x i1> %tr, <4 x double> %x, <4 x double> %y
  ret <4 x double> %z
}

; Try a 512-bit vector to make sure AVX-512 is handled as expected.

define <8 x double> @signbit_sel_v8f64(<8 x double> %x, <8 x double> %y, <8 x i64> %mask) {
; AVX12-LABEL: signbit_sel_v8f64:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vblendvpd %ymm4, %ymm0, %ymm2, %ymm0
; AVX12-NEXT:    vblendvpd %ymm5, %ymm1, %ymm3, %ymm1
; AVX12-NEXT:    retq
;
; AVX512-LABEL: signbit_sel_v8f64:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512-NEXT:    vpcmpgtq %zmm2, %zmm3, %k1
; AVX512-NEXT:    vblendmpd %zmm0, %zmm1, %zmm0 {%k1}
; AVX512-NEXT:    retq
  %tr = icmp slt <8 x i64> %mask, zeroinitializer
  %z = select <8 x i1> %tr, <8 x double> %x, <8 x double> %y
  ret <8 x double> %z
}

; If we have a floating-point compare:
; (1) Don't die.
; (2) FIXME: If we don't care about signed-zero (and NaN?), the compare should still get folded.

define <4 x float> @signbit_sel_v4f32_fcmp(<4 x float> %x, <4 x float> %y, <4 x float> %mask) #0 {
; AVX12-LABEL: signbit_sel_v4f32_fcmp:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vxorps %xmm2, %xmm2, %xmm2
; AVX12-NEXT:    vcmpltps %xmm2, %xmm0, %xmm2
; AVX12-NEXT:    vblendvps %xmm2, %xmm0, %xmm1, %xmm0
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: signbit_sel_v4f32_fcmp:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $xmm1 killed $xmm1 def $zmm1
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 def $zmm0
; AVX512F-NEXT:    vxorps %xmm2, %xmm2, %xmm2
; AVX512F-NEXT:    vcmpltps %zmm2, %zmm0, %k1
; AVX512F-NEXT:    vblendmps %zmm0, %zmm1, %zmm0 {%k1}
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 killed $zmm0
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: signbit_sel_v4f32_fcmp:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vxorps %xmm2, %xmm2, %xmm2
; AVX512VL-NEXT:    vcmpltps %xmm2, %xmm0, %k1
; AVX512VL-NEXT:    vblendmps %xmm0, %xmm1, %xmm0 {%k1}
; AVX512VL-NEXT:    retq
  %cmp = fcmp olt <4 x float> %x, zeroinitializer
  %sel = select <4 x i1> %cmp, <4 x float> %x, <4 x float> %y
  ret <4 x float> %sel
}

define <4 x i64> @blend_splat1_mask_cond_v4i64(<4 x i64> %x, <4 x i64> %y, <4 x i64> %z) {
; AVX1-LABEL: blend_splat1_mask_cond_v4i64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpeqq %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpeqq %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm0, %ymm0
; AVX1-NEXT:    vblendvpd %ymm0, %ymm1, %ymm2, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: blend_splat1_mask_cond_v4i64:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpbroadcastq {{.*#+}} ymm3 = [1,1,1,1]
; AVX2-NEXT:    vpand %ymm3, %ymm0, %ymm0
; AVX2-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpcmpeqq %ymm3, %ymm0, %ymm0
; AVX2-NEXT:    vblendvpd %ymm0, %ymm1, %ymm2, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: blend_splat1_mask_cond_v4i64:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $ymm2 killed $ymm2 def $zmm2
; AVX512F-NEXT:    # kill: def $ymm1 killed $ymm1 def $zmm1
; AVX512F-NEXT:    # kill: def $ymm0 killed $ymm0 def $zmm0
; AVX512F-NEXT:    vptestnmq {{.*}}(%rip){1to8}, %zmm0, %k1
; AVX512F-NEXT:    vpblendmq %zmm1, %zmm2, %zmm0 {%k1}
; AVX512F-NEXT:    # kill: def $ymm0 killed $ymm0 killed $zmm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: blend_splat1_mask_cond_v4i64:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vptestnmq {{.*}}(%rip){1to4}, %ymm0, %k1
; AVX512VL-NEXT:    vpblendmq %ymm1, %ymm2, %ymm0 {%k1}
; AVX512VL-NEXT:    retq
  %a = and <4 x i64> %x, <i64 1, i64 1, i64 1, i64 1>
  %c = icmp eq <4 x i64> %a, zeroinitializer
  %r = select <4 x i1> %c, <4 x i64> %y, <4 x i64> %z
  ret <4 x i64> %r
}

define <4 x i32> @blend_splat1_mask_cond_v4i32(<4 x i32> %x, <4 x i32> %y, <4 x i32> %z) {
; AVX1-LABEL: blend_splat1_mask_cond_v4i32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX1-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vblendvps %xmm0, %xmm1, %xmm2, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: blend_splat1_mask_cond_v4i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpbroadcastd {{.*#+}} xmm3 = [1,1,1,1]
; AVX2-NEXT:    vpand %xmm3, %xmm0, %xmm0
; AVX2-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpcmpeqd %xmm3, %xmm0, %xmm0
; AVX2-NEXT:    vblendvps %xmm0, %xmm1, %xmm2, %xmm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: blend_splat1_mask_cond_v4i32:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $xmm2 killed $xmm2 def $zmm2
; AVX512F-NEXT:    # kill: def $xmm1 killed $xmm1 def $zmm1
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 def $zmm0
; AVX512F-NEXT:    vptestnmd {{.*}}(%rip){1to16}, %zmm0, %k1
; AVX512F-NEXT:    vpblendmd %zmm1, %zmm2, %zmm0 {%k1}
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 killed $zmm0
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: blend_splat1_mask_cond_v4i32:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vptestnmd {{.*}}(%rip){1to4}, %xmm0, %k1
; AVX512VL-NEXT:    vpblendmd %xmm1, %xmm2, %xmm0 {%k1}
; AVX512VL-NEXT:    retq
  %a = and <4 x i32> %x, <i32 1, i32 1, i32 1, i32 1>
  %c = icmp eq <4 x i32> %a, zeroinitializer
  %r = select <4 x i1> %c, <4 x i32> %y, <4 x i32> %z
  ret <4 x i32> %r
}

define <16 x i16> @blend_splat1_mask_cond_v16i16(<16 x i16> %x, <16 x i16> %y, <16 x i16> %z) {
; AVX1-LABEL: blend_splat1_mask_cond_v16i16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpeqw %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpeqw %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm0, %ymm0
; AVX1-NEXT:    vandnps %ymm2, %ymm0, %ymm2
; AVX1-NEXT:    vandps %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    vorps %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: blend_splat1_mask_cond_v16i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpcmpeqw %ymm3, %ymm0, %ymm0
; AVX2-NEXT:    vpblendvb %ymm0, %ymm1, %ymm2, %ymm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: blend_splat1_mask_cond_v16i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX512-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512-NEXT:    vpcmpeqw %ymm3, %ymm0, %ymm0
; AVX512-NEXT:    vpblendvb %ymm0, %ymm1, %ymm2, %ymm0
; AVX512-NEXT:    retq
  %a = and <16 x i16> %x, <i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1, i16 1>
  %c = icmp eq <16 x i16> %a, zeroinitializer
  %r = select <16 x i1> %c, <16 x i16> %y, <16 x i16> %z
  ret <16 x i16> %r
}

define <16 x i8> @blend_splat1_mask_cond_v16i8(<16 x i8> %x, <16 x i8> %y, <16 x i8> %z) {
; AVX-LABEL: blend_splat1_mask_cond_v16i8:
; AVX:       # %bb.0:
; AVX-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX-NEXT:    vpcmpeqb %xmm3, %xmm0, %xmm0
; AVX-NEXT:    vpblendvb %xmm0, %xmm1, %xmm2, %xmm0
; AVX-NEXT:    retq
  %a = and <16 x i8> %x, <i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1>
  %c = icmp eq <16 x i8> %a, zeroinitializer
  %r = select <16 x i1> %c, <16 x i8> %y, <16 x i8> %z
  ret <16 x i8> %r
}

define <2 x i64> @blend_splatmax_mask_cond_v2i64(<2 x i64> %x, <2 x i64> %y, <2 x i64> %z) {
; AVX12-LABEL: blend_splatmax_mask_cond_v2i64:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX12-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX12-NEXT:    vpcmpeqq %xmm3, %xmm0, %xmm0
; AVX12-NEXT:    vblendvpd %xmm0, %xmm1, %xmm2, %xmm0
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: blend_splatmax_mask_cond_v2i64:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $xmm2 killed $xmm2 def $zmm2
; AVX512F-NEXT:    # kill: def $xmm1 killed $xmm1 def $zmm1
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 def $zmm0
; AVX512F-NEXT:    vmovdqa {{.*#+}} xmm3 = [9223372036854775808,9223372036854775808]
; AVX512F-NEXT:    vptestnmq %zmm3, %zmm0, %k1
; AVX512F-NEXT:    vpblendmq %zmm1, %zmm2, %zmm0 {%k1}
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 killed $zmm0
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: blend_splatmax_mask_cond_v2i64:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vptestnmq {{.*}}(%rip), %xmm0, %k1
; AVX512VL-NEXT:    vpblendmq %xmm1, %xmm2, %xmm0 {%k1}
; AVX512VL-NEXT:    retq
  %a = and <2 x i64> %x, <i64 9223372036854775808, i64 9223372036854775808>
  %c = icmp eq <2 x i64> %a, zeroinitializer
  %r = select <2 x i1> %c, <2 x i64> %y, <2 x i64> %z
  ret <2 x i64> %r
}

define <8 x i32> @blend_splatmax_mask_cond_v8i32(<8 x i32> %x, <8 x i32> %y, <8 x i32> %z) {
; AVX1-LABEL: blend_splatmax_mask_cond_v8i32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpeqd %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpeqd %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm0, %ymm0
; AVX1-NEXT:    vblendvps %ymm0, %ymm1, %ymm2, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: blend_splatmax_mask_cond_v8i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpbroadcastd {{.*#+}} ymm3 = [2147483648,2147483648,2147483648,2147483648,2147483648,2147483648,2147483648,2147483648]
; AVX2-NEXT:    vpand %ymm3, %ymm0, %ymm0
; AVX2-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpcmpeqd %ymm3, %ymm0, %ymm0
; AVX2-NEXT:    vblendvps %ymm0, %ymm1, %ymm2, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: blend_splatmax_mask_cond_v8i32:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $ymm2 killed $ymm2 def $zmm2
; AVX512F-NEXT:    # kill: def $ymm1 killed $ymm1 def $zmm1
; AVX512F-NEXT:    # kill: def $ymm0 killed $ymm0 def $zmm0
; AVX512F-NEXT:    vptestnmd {{.*}}(%rip){1to16}, %zmm0, %k1
; AVX512F-NEXT:    vpblendmd %zmm1, %zmm2, %zmm0 {%k1}
; AVX512F-NEXT:    # kill: def $ymm0 killed $ymm0 killed $zmm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: blend_splatmax_mask_cond_v8i32:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vptestnmd {{.*}}(%rip){1to8}, %ymm0, %k1
; AVX512VL-NEXT:    vpblendmd %ymm1, %ymm2, %ymm0 {%k1}
; AVX512VL-NEXT:    retq
  %a = and <8 x i32> %x, <i32 2147483648, i32 2147483648, i32 2147483648, i32 2147483648, i32 2147483648, i32 2147483648, i32 2147483648, i32 2147483648>
  %c = icmp eq <8 x i32> %a, zeroinitializer
  %r = select <8 x i1> %c, <8 x i32> %y, <8 x i32> %z
  ret <8 x i32> %r
}

define <8 x i16> @blend_splatmax_mask_cond_v8i16(<8 x i16> %x, <8 x i16> %y, <8 x i16> %z) {
; AVX-LABEL: blend_splatmax_mask_cond_v8i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX-NEXT:    vpcmpeqw %xmm3, %xmm0, %xmm0
; AVX-NEXT:    vpblendvb %xmm0, %xmm1, %xmm2, %xmm0
; AVX-NEXT:    retq
  %a = and <8 x i16> %x, <i16 32768, i16 32768, i16 32768, i16 32768, i16 32768, i16 32768, i16 32768, i16 32768>
  %c = icmp eq <8 x i16> %a, zeroinitializer
  %r = select <8 x i1> %c, <8 x i16> %y, <8 x i16> %z
  ret <8 x i16> %r
}

define <32 x i8> @blend_splatmax_mask_cond_v32i8(<32 x i8> %x, <32 x i8> %y, <32 x i8> %z) {
; AVX1-LABEL: blend_splatmax_mask_cond_v32i8:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpeqb %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpeqb %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm0, %ymm0
; AVX1-NEXT:    vandnps %ymm2, %ymm0, %ymm2
; AVX1-NEXT:    vandps %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    vorps %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: blend_splatmax_mask_cond_v32i8:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpcmpeqb %ymm3, %ymm0, %ymm0
; AVX2-NEXT:    vpblendvb %ymm0, %ymm1, %ymm2, %ymm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: blend_splatmax_mask_cond_v32i8:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX512-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512-NEXT:    vpcmpeqb %ymm3, %ymm0, %ymm0
; AVX512-NEXT:    vpblendvb %ymm0, %ymm1, %ymm2, %ymm0
; AVX512-NEXT:    retq
  %a = and <32 x i8> %x, <i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128, i8 128>
  %c = icmp eq <32 x i8> %a, zeroinitializer
  %r = select <32 x i1> %c, <32 x i8> %y, <32 x i8> %z
  ret <32 x i8> %r
}

define <4 x i64> @blend_splat_mask_cond_v4i64(<4 x i64> %x, <4 x i64> %y, <4 x i64> %z) {
; AVX1-LABEL: blend_splat_mask_cond_v4i64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpeqq %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpeqq %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm0, %ymm0
; AVX1-NEXT:    vblendvpd %ymm0, %ymm1, %ymm2, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: blend_splat_mask_cond_v4i64:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpbroadcastq {{.*#+}} ymm3 = [2,2,2,2]
; AVX2-NEXT:    vpand %ymm3, %ymm0, %ymm0
; AVX2-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpcmpeqq %ymm3, %ymm0, %ymm0
; AVX2-NEXT:    vblendvpd %ymm0, %ymm1, %ymm2, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: blend_splat_mask_cond_v4i64:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $ymm2 killed $ymm2 def $zmm2
; AVX512F-NEXT:    # kill: def $ymm1 killed $ymm1 def $zmm1
; AVX512F-NEXT:    # kill: def $ymm0 killed $ymm0 def $zmm0
; AVX512F-NEXT:    vptestnmq {{.*}}(%rip){1to8}, %zmm0, %k1
; AVX512F-NEXT:    vpblendmq %zmm1, %zmm2, %zmm0 {%k1}
; AVX512F-NEXT:    # kill: def $ymm0 killed $ymm0 killed $zmm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: blend_splat_mask_cond_v4i64:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vptestnmq {{.*}}(%rip){1to4}, %ymm0, %k1
; AVX512VL-NEXT:    vpblendmq %ymm1, %ymm2, %ymm0 {%k1}
; AVX512VL-NEXT:    retq
  %a = and <4 x i64> %x, <i64 2, i64 2, i64 2, i64 2>
  %c = icmp eq <4 x i64> %a, zeroinitializer
  %r = select <4 x i1> %c, <4 x i64> %y, <4 x i64> %z
  ret <4 x i64> %r
}

define <4 x i32> @blend_splat_mask_cond_v4i32(<4 x i32> %x, <4 x i32> %y, <4 x i32> %z) {
; AVX1-LABEL: blend_splat_mask_cond_v4i32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX1-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpeqd %xmm3, %xmm0, %xmm0
; AVX1-NEXT:    vblendvps %xmm0, %xmm1, %xmm2, %xmm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: blend_splat_mask_cond_v4i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpbroadcastd {{.*#+}} xmm3 = [65536,65536,65536,65536]
; AVX2-NEXT:    vpand %xmm3, %xmm0, %xmm0
; AVX2-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpcmpeqd %xmm3, %xmm0, %xmm0
; AVX2-NEXT:    vblendvps %xmm0, %xmm1, %xmm2, %xmm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: blend_splat_mask_cond_v4i32:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $xmm2 killed $xmm2 def $zmm2
; AVX512F-NEXT:    # kill: def $xmm1 killed $xmm1 def $zmm1
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 def $zmm0
; AVX512F-NEXT:    vptestnmd {{.*}}(%rip){1to16}, %zmm0, %k1
; AVX512F-NEXT:    vpblendmd %zmm1, %zmm2, %zmm0 {%k1}
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 killed $zmm0
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: blend_splat_mask_cond_v4i32:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vptestnmd {{.*}}(%rip){1to4}, %xmm0, %k1
; AVX512VL-NEXT:    vpblendmd %xmm1, %xmm2, %xmm0 {%k1}
; AVX512VL-NEXT:    retq
  %a = and <4 x i32> %x, <i32 65536, i32 65536, i32 65536, i32 65536>
  %c = icmp eq <4 x i32> %a, zeroinitializer
  %r = select <4 x i1> %c, <4 x i32> %y, <4 x i32> %z
  ret <4 x i32> %r
}

define <16 x i16> @blend_splat_mask_cond_v16i16(<16 x i16> %x, <16 x i16> %y, <16 x i16> %z) {
; AVX1-LABEL: blend_splat_mask_cond_v16i16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpeqw %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpeqw %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm0, %ymm0
; AVX1-NEXT:    vandnps %ymm2, %ymm0, %ymm2
; AVX1-NEXT:    vandps %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    vorps %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: blend_splat_mask_cond_v16i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpcmpeqw %ymm3, %ymm0, %ymm0
; AVX2-NEXT:    vpblendvb %ymm0, %ymm1, %ymm2, %ymm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: blend_splat_mask_cond_v16i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX512-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512-NEXT:    vpcmpeqw %ymm3, %ymm0, %ymm0
; AVX512-NEXT:    vpblendvb %ymm0, %ymm1, %ymm2, %ymm0
; AVX512-NEXT:    retq
  %a = and <16 x i16> %x, <i16 1024, i16 1024, i16 1024, i16 1024, i16 1024, i16 1024, i16 1024, i16 1024, i16 1024, i16 1024, i16 1024, i16 1024, i16 1024, i16 1024, i16 1024, i16 1024>
  %c = icmp eq <16 x i16> %a, zeroinitializer
  %r = select <16 x i1> %c, <16 x i16> %y, <16 x i16> %z
  ret <16 x i16> %r
}

define <16 x i8> @blend_splat_mask_cond_v16i8(<16 x i8> %x, <16 x i8> %y, <16 x i8> %z) {
; AVX-LABEL: blend_splat_mask_cond_v16i8:
; AVX:       # %bb.0:
; AVX-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX-NEXT:    vpcmpeqb %xmm3, %xmm0, %xmm0
; AVX-NEXT:    vpblendvb %xmm0, %xmm1, %xmm2, %xmm0
; AVX-NEXT:    retq
  %a = and <16 x i8> %x, <i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4, i8 4>
  %c = icmp eq <16 x i8> %a, zeroinitializer
  %r = select <16 x i1> %c, <16 x i8> %y, <16 x i8> %z
  ret <16 x i8> %r
}

define <4 x i64> @blend_mask_cond_v4i64(<4 x i64> %x, <4 x i64> %y, <4 x i64> %z) {
; AVX1-LABEL: blend_mask_cond_v4i64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpeqq %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpeqq %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm0, %ymm0
; AVX1-NEXT:    vblendvpd %ymm0, %ymm1, %ymm2, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: blend_mask_cond_v4i64:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpcmpeqq %ymm3, %ymm0, %ymm0
; AVX2-NEXT:    vblendvpd %ymm0, %ymm1, %ymm2, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: blend_mask_cond_v4i64:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $ymm2 killed $ymm2 def $zmm2
; AVX512F-NEXT:    # kill: def $ymm1 killed $ymm1 def $zmm1
; AVX512F-NEXT:    # kill: def $ymm0 killed $ymm0 def $zmm0
; AVX512F-NEXT:    vmovdqa {{.*#+}} ymm3 = [2,4,8,16]
; AVX512F-NEXT:    vptestnmq %zmm3, %zmm0, %k1
; AVX512F-NEXT:    vpblendmq %zmm1, %zmm2, %zmm0 {%k1}
; AVX512F-NEXT:    # kill: def $ymm0 killed $ymm0 killed $zmm0
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: blend_mask_cond_v4i64:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vptestnmq {{.*}}(%rip), %ymm0, %k1
; AVX512VL-NEXT:    vpblendmq %ymm1, %ymm2, %ymm0 {%k1}
; AVX512VL-NEXT:    retq
  %a = and <4 x i64> %x, <i64 2, i64 4, i64 8, i64 16>
  %c = icmp eq <4 x i64> %a, zeroinitializer
  %r = select <4 x i1> %c, <4 x i64> %y, <4 x i64> %z
  ret <4 x i64> %r
}

define <4 x i32> @blend_mask_cond_v4i32(<4 x i32> %x, <4 x i32> %y, <4 x i32> %z) {
; AVX12-LABEL: blend_mask_cond_v4i32:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX12-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX12-NEXT:    vpcmpeqd %xmm3, %xmm0, %xmm0
; AVX12-NEXT:    vblendvps %xmm0, %xmm1, %xmm2, %xmm0
; AVX12-NEXT:    retq
;
; AVX512F-LABEL: blend_mask_cond_v4i32:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $xmm2 killed $xmm2 def $zmm2
; AVX512F-NEXT:    # kill: def $xmm1 killed $xmm1 def $zmm1
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 def $zmm0
; AVX512F-NEXT:    vmovdqa {{.*#+}} xmm3 = [65536,512,2,1]
; AVX512F-NEXT:    vptestnmd %zmm3, %zmm0, %k1
; AVX512F-NEXT:    vpblendmd %zmm1, %zmm2, %zmm0 {%k1}
; AVX512F-NEXT:    # kill: def $xmm0 killed $xmm0 killed $zmm0
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: blend_mask_cond_v4i32:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vptestnmd {{.*}}(%rip), %xmm0, %k1
; AVX512VL-NEXT:    vpblendmd %xmm1, %xmm2, %xmm0 {%k1}
; AVX512VL-NEXT:    retq
  %a = and <4 x i32> %x, <i32 65536, i32 512, i32 2, i32 1>
  %c = icmp eq <4 x i32> %a, zeroinitializer
  %r = select <4 x i1> %c, <4 x i32> %y, <4 x i32> %z
  ret <4 x i32> %r
}

define <16 x i16> @blend_mask_cond_v16i16(<16 x i16> %x, <16 x i16> %y, <16 x i16> %z) {
; AVX1-LABEL: blend_mask_cond_v16i16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vandps {{.*}}(%rip), %ymm0, %ymm0
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpeqw %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpeqw %xmm4, %xmm0, %xmm0
; AVX1-NEXT:    vinsertf128 $1, %xmm3, %ymm0, %ymm0
; AVX1-NEXT:    vandnps %ymm2, %ymm0, %ymm2
; AVX1-NEXT:    vandps %ymm0, %ymm1, %ymm0
; AVX1-NEXT:    vorps %ymm2, %ymm0, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: blend_mask_cond_v16i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX2-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX2-NEXT:    vpcmpeqw %ymm3, %ymm0, %ymm0
; AVX2-NEXT:    vpblendvb %ymm0, %ymm1, %ymm2, %ymm0
; AVX2-NEXT:    retq
;
; AVX512-LABEL: blend_mask_cond_v16i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpand {{.*}}(%rip), %ymm0, %ymm0
; AVX512-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX512-NEXT:    vpcmpeqw %ymm3, %ymm0, %ymm0
; AVX512-NEXT:    vpblendvb %ymm0, %ymm1, %ymm2, %ymm0
; AVX512-NEXT:    retq
  %a = and <16 x i16> %x, <i16 1, i16 2, i16 8, i16 4, i16 8, i16 2, i16 2, i16 2, i16 2, i16 8, i16 8, i16 64, i16 64, i16 1024, i16 4096, i16 1024>
  %c = icmp eq <16 x i16> %a, zeroinitializer
  %r = select <16 x i1> %c, <16 x i16> %y, <16 x i16> %z
  ret <16 x i16> %r
}

define <16 x i8> @blend_mask_cond_v16i8(<16 x i8> %x, <16 x i8> %y, <16 x i8> %z) {
; AVX-LABEL: blend_mask_cond_v16i8:
; AVX:       # %bb.0:
; AVX-NEXT:    vpand {{.*}}(%rip), %xmm0, %xmm0
; AVX-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX-NEXT:    vpcmpeqb %xmm3, %xmm0, %xmm0
; AVX-NEXT:    vpblendvb %xmm0, %xmm1, %xmm2, %xmm0
; AVX-NEXT:    retq
  %a = and <16 x i8> %x, <i8 1, i8 2, i8 4, i8 8, i8 16, i8 32, i8 64, i8 128, i8 4, i8 4, i8 4, i8 4, i8 2, i8 2, i8 2, i8 2>
  %c = icmp eq <16 x i8> %a, zeroinitializer
  %r = select <16 x i1> %c, <16 x i8> %y, <16 x i8> %z
  ret <16 x i8> %r
}

define void @PR46531(i32* %x, i32* %y, i32* %z) {
; AVX1-LABEL: PR46531:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovdqu (%rsi), %xmm0
; AVX1-NEXT:    vmovdqu (%rdx), %xmm1
; AVX1-NEXT:    vpor %xmm0, %xmm1, %xmm2
; AVX1-NEXT:    vpand {{.*}}(%rip), %xmm1, %xmm3
; AVX1-NEXT:    vpxor %xmm4, %xmm4, %xmm4
; AVX1-NEXT:    vpcmpeqd %xmm4, %xmm3, %xmm3
; AVX1-NEXT:    vpxor %xmm0, %xmm1, %xmm0
; AVX1-NEXT:    vblendvps %xmm3, %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vmovups %xmm0, (%rdi)
; AVX1-NEXT:    retq
;
; AVX2-LABEL: PR46531:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovdqu (%rsi), %xmm0
; AVX2-NEXT:    vmovdqu (%rdx), %xmm1
; AVX2-NEXT:    vpor %xmm0, %xmm1, %xmm2
; AVX2-NEXT:    vpbroadcastd {{.*#+}} xmm3 = [1,1,1,1]
; AVX2-NEXT:    vpand %xmm3, %xmm1, %xmm3
; AVX2-NEXT:    vpxor %xmm4, %xmm4, %xmm4
; AVX2-NEXT:    vpcmpeqd %xmm4, %xmm3, %xmm3
; AVX2-NEXT:    vpxor %xmm0, %xmm1, %xmm0
; AVX2-NEXT:    vblendvps %xmm3, %xmm2, %xmm0, %xmm0
; AVX2-NEXT:    vmovups %xmm0, (%rdi)
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: PR46531:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vmovdqu (%rsi), %xmm0
; AVX512F-NEXT:    vmovdqu (%rdx), %xmm1
; AVX512F-NEXT:    vpor %xmm0, %xmm1, %xmm2
; AVX512F-NEXT:    vptestnmd {{.*}}(%rip){1to16}, %zmm1, %k1
; AVX512F-NEXT:    vpxor %xmm0, %xmm1, %xmm0
; AVX512F-NEXT:    vmovdqa32 %zmm2, %zmm0 {%k1}
; AVX512F-NEXT:    vmovdqu %xmm0, (%rdi)
; AVX512F-NEXT:    vzeroupper
; AVX512F-NEXT:    retq
;
; AVX512VL-LABEL: PR46531:
; AVX512VL:       # %bb.0:
; AVX512VL-NEXT:    vmovdqu (%rsi), %xmm0
; AVX512VL-NEXT:    vmovdqu (%rdx), %xmm1
; AVX512VL-NEXT:    vptestnmd {{.*}}(%rip){1to4}, %xmm1, %k1
; AVX512VL-NEXT:    vpxor %xmm0, %xmm1, %xmm2
; AVX512VL-NEXT:    vpord %xmm0, %xmm1, %xmm2 {%k1}
; AVX512VL-NEXT:    vmovdqu %xmm2, (%rdi)
; AVX512VL-NEXT:    retq
  %vy = bitcast i32* %y to <4 x i32>*
  %a = load <4 x i32>, <4 x i32>* %vy, align 4
  %vz = bitcast i32* %z to <4 x i32>*
  %b = load <4 x i32>, <4 x i32>* %vz, align 4
  %or = or <4 x i32> %b, %a
  %and = and <4 x i32> %b, <i32 1, i32 1, i32 1, i32 1>
  %cmp = icmp eq <4 x i32> %and, zeroinitializer
  %xor = xor <4 x i32> %b, %a
  %sel = select <4 x i1> %cmp, <4 x i32> %or, <4 x i32> %xor
  %vx = bitcast i32* %x to <4 x i32>*
  store <4 x i32> %sel, <4 x i32>* %vx, align 4
  ret void
}

attributes #0 = { "no-nans-fp-math"="true" }
