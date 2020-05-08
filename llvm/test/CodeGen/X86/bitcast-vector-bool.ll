; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefixes=SSE2-SSSE3,SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+ssse3 | FileCheck %s --check-prefixes=SSE2-SSSE3,SSSE3
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=AVX12,AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefixes=AVX12,AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f,+avx512vl,+avx512bw | FileCheck %s --check-prefixes=AVX512

;
; 128-bit vectors
;

define i1 @bitcast_v2i64_to_v2i1(<2 x i64> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v2i64_to_v2i1:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    movmskpd %xmm0, %ecx
; SSE2-SSSE3-NEXT:    movl %ecx, %eax
; SSE2-SSSE3-NEXT:    shrb %al
; SSE2-SSSE3-NEXT:    addb %cl, %al
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: bitcast_v2i64_to_v2i1:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vmovmskpd %xmm0, %ecx
; AVX12-NEXT:    movl %ecx, %eax
; AVX12-NEXT:    shrb %al
; AVX12-NEXT:    addb %cl, %al
; AVX12-NEXT:    retq
;
; AVX512-LABEL: bitcast_v2i64_to_v2i1:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX512-NEXT:    vpcmpgtq %xmm0, %xmm1, %k0
; AVX512-NEXT:    kshiftrw $1, %k0, %k1
; AVX512-NEXT:    kmovd %k1, %ecx
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    retq
  %1 = icmp slt <2 x i64> %a0, zeroinitializer
  %2 = bitcast <2 x i1> %1 to <2 x i1>
  %3 = extractelement <2 x i1> %2, i32 0
  %4 = extractelement <2 x i1> %2, i32 1
  %5 = add i1 %3, %4
  ret i1 %5
}

define i2 @bitcast_v4i32_to_v2i2(<4 x i32> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v4i32_to_v2i2:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    movmskps %xmm0, %eax
; SSE2-SSSE3-NEXT:    movl %eax, %ecx
; SSE2-SSSE3-NEXT:    shrb $2, %cl
; SSE2-SSSE3-NEXT:    andb $3, %al
; SSE2-SSSE3-NEXT:    addb %cl, %al
; SSE2-SSSE3-NEXT:    # kill: def $al killed $al killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: bitcast_v4i32_to_v2i2:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vmovmskps %xmm0, %eax
; AVX12-NEXT:    movl %eax, %ecx
; AVX12-NEXT:    shrb $2, %cl
; AVX12-NEXT:    andb $3, %al
; AVX12-NEXT:    addb %cl, %al
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    retq
;
; AVX512-LABEL: bitcast_v4i32_to_v2i2:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX512-NEXT:    vpcmpgtd %xmm0, %xmm1, %k0
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    movl %eax, %ecx
; AVX512-NEXT:    shrb $2, %cl
; AVX512-NEXT:    andb $3, %al
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    retq
  %1 = icmp slt <4 x i32> %a0, zeroinitializer
  %2 = bitcast <4 x i1> %1 to <2 x i2>
  %3 = extractelement <2 x i2> %2, i32 0
  %4 = extractelement <2 x i2> %2, i32 1
  %5 = add i2 %3, %4
  ret i2 %5
}

define i4 @bitcast_v8i16_to_v2i4(<8 x i16> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v8i16_to_v2i4:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    packsswb %xmm0, %xmm0
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    movl %eax, %ecx
; SSE2-SSSE3-NEXT:    shrb $4, %cl
; SSE2-SSSE3-NEXT:    andb $15, %al
; SSE2-SSSE3-NEXT:    addb %cl, %al
; SSE2-SSSE3-NEXT:    # kill: def $al killed $al killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: bitcast_v8i16_to_v2i4:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vpacksswb %xmm0, %xmm0, %xmm0
; AVX12-NEXT:    vpmovmskb %xmm0, %eax
; AVX12-NEXT:    movl %eax, %ecx
; AVX12-NEXT:    shrb $4, %cl
; AVX12-NEXT:    andb $15, %al
; AVX12-NEXT:    addb %cl, %al
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    retq
;
; AVX512-LABEL: bitcast_v8i16_to_v2i4:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpmovw2m %xmm0, %k0
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    movl %eax, %ecx
; AVX512-NEXT:    shrb $4, %cl
; AVX512-NEXT:    andb $15, %al
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    retq
  %1 = icmp slt <8 x i16> %a0, zeroinitializer
  %2 = bitcast <8 x i1> %1 to <2 x i4>
  %3 = extractelement <2 x i4> %2, i32 0
  %4 = extractelement <2 x i4> %2, i32 1
  %5 = add i4 %3, %4
  ret i4 %5
}

define i8 @bitcast_v16i8_to_v2i8(<16 x i8> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v16i8_to_v2i8:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    movd %eax, %xmm0
; SSE2-SSSE3-NEXT:    movdqa %xmm0, -{{[0-9]+}}(%rsp)
; SSE2-SSSE3-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    addb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: bitcast_v16i8_to_v2i8:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vpmovmskb %xmm0, %ecx
; AVX12-NEXT:    movl %ecx, %eax
; AVX12-NEXT:    shrl $8, %eax
; AVX12-NEXT:    addb %cl, %al
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    retq
;
; AVX512-LABEL: bitcast_v16i8_to_v2i8:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpmovb2m %xmm0, %k0
; AVX512-NEXT:    kmovw %k0, -{{[0-9]+}}(%rsp)
; AVX512-NEXT:    vmovdqa -{{[0-9]+}}(%rsp), %xmm0
; AVX512-NEXT:    vmovd %xmm0, %ecx
; AVX512-NEXT:    vpextrb $1, %xmm0, %eax
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    retq
  %1 = icmp slt <16 x i8> %a0, zeroinitializer
  %2 = bitcast <16 x i1> %1 to <2 x i8>
  %3 = extractelement <2 x i8> %2, i32 0
  %4 = extractelement <2 x i8> %2, i32 1
  %5 = add i8 %3, %4
  ret i8 %5
}

;
; 256-bit vectors
;

define i2 @bitcast_v4i64_to_v2i2(<4 x i64> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v4i64_to_v2i2:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    packssdw %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    movmskps %xmm0, %eax
; SSE2-SSSE3-NEXT:    movl %eax, %ecx
; SSE2-SSSE3-NEXT:    shrb $2, %cl
; SSE2-SSSE3-NEXT:    andb $3, %al
; SSE2-SSSE3-NEXT:    addb %cl, %al
; SSE2-SSSE3-NEXT:    # kill: def $al killed $al killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: bitcast_v4i64_to_v2i2:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vmovmskpd %ymm0, %eax
; AVX12-NEXT:    movl %eax, %ecx
; AVX12-NEXT:    shrb $2, %cl
; AVX12-NEXT:    andb $3, %al
; AVX12-NEXT:    addb %cl, %al
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    vzeroupper
; AVX12-NEXT:    retq
;
; AVX512-LABEL: bitcast_v4i64_to_v2i2:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX512-NEXT:    vpcmpgtq %ymm0, %ymm1, %k0
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    movl %eax, %ecx
; AVX512-NEXT:    shrb $2, %cl
; AVX512-NEXT:    andb $3, %al
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = icmp slt <4 x i64> %a0, zeroinitializer
  %2 = bitcast <4 x i1> %1 to <2 x i2>
  %3 = extractelement <2 x i2> %2, i32 0
  %4 = extractelement <2 x i2> %2, i32 1
  %5 = add i2 %3, %4
  ret i2 %5
}

define i4 @bitcast_v8i32_to_v2i4(<8 x i32> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v8i32_to_v2i4:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    packssdw %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    packsswb %xmm0, %xmm0
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    movl %eax, %ecx
; SSE2-SSSE3-NEXT:    shrb $4, %cl
; SSE2-SSSE3-NEXT:    andb $15, %al
; SSE2-SSSE3-NEXT:    addb %cl, %al
; SSE2-SSSE3-NEXT:    # kill: def $al killed $al killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX12-LABEL: bitcast_v8i32_to_v2i4:
; AVX12:       # %bb.0:
; AVX12-NEXT:    vmovmskps %ymm0, %eax
; AVX12-NEXT:    movl %eax, %ecx
; AVX12-NEXT:    shrb $4, %cl
; AVX12-NEXT:    andb $15, %al
; AVX12-NEXT:    addb %cl, %al
; AVX12-NEXT:    # kill: def $al killed $al killed $eax
; AVX12-NEXT:    vzeroupper
; AVX12-NEXT:    retq
;
; AVX512-LABEL: bitcast_v8i32_to_v2i4:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX512-NEXT:    vpcmpgtd %ymm0, %ymm1, %k0
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    movl %eax, %ecx
; AVX512-NEXT:    shrb $4, %cl
; AVX512-NEXT:    andb $15, %al
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = icmp slt <8 x i32> %a0, zeroinitializer
  %2 = bitcast <8 x i1> %1 to <2 x i4>
  %3 = extractelement <2 x i4> %2, i32 0
  %4 = extractelement <2 x i4> %2, i32 1
  %5 = add i4 %3, %4
  ret i4 %5
}

define i8 @bitcast_v16i16_to_v2i8(<16 x i16> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v16i16_to_v2i8:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    packsswb %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    movd %eax, %xmm0
; SSE2-SSSE3-NEXT:    movdqa %xmm0, -{{[0-9]+}}(%rsp)
; SSE2-SSSE3-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    addb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: bitcast_v16i16_to_v2i8:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpacksswb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %ecx
; AVX1-NEXT:    movl %ecx, %eax
; AVX1-NEXT:    shrl $8, %eax
; AVX1-NEXT:    addb %cl, %al
; AVX1-NEXT:    # kill: def $al killed $al killed $eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: bitcast_v16i16_to_v2i8:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpacksswb %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpmovmskb %xmm0, %ecx
; AVX2-NEXT:    movl %ecx, %eax
; AVX2-NEXT:    shrl $8, %eax
; AVX2-NEXT:    addb %cl, %al
; AVX2-NEXT:    # kill: def $al killed $al killed $eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: bitcast_v16i16_to_v2i8:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpmovw2m %ymm0, %k0
; AVX512-NEXT:    kmovw %k0, -{{[0-9]+}}(%rsp)
; AVX512-NEXT:    vmovdqa -{{[0-9]+}}(%rsp), %xmm0
; AVX512-NEXT:    vmovd %xmm0, %ecx
; AVX512-NEXT:    vpextrb $1, %xmm0, %eax
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = icmp slt <16 x i16> %a0, zeroinitializer
  %2 = bitcast <16 x i1> %1 to <2 x i8>
  %3 = extractelement <2 x i8> %2, i32 0
  %4 = extractelement <2 x i8> %2, i32 1
  %5 = add i8 %3, %4
  ret i8 %5
}

define i16 @bitcast_v32i8_to_v2i16(<32 x i8> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v32i8_to_v2i16:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    pmovmskb %xmm1, %ecx
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    addl %ecx, %eax
; SSE2-SSSE3-NEXT:    # kill: def $ax killed $ax killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: bitcast_v32i8_to_v2i16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpmovmskb %xmm1, %ecx
; AVX1-NEXT:    vpmovmskb %xmm0, %eax
; AVX1-NEXT:    addl %ecx, %eax
; AVX1-NEXT:    # kill: def $ax killed $ax killed $eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: bitcast_v32i8_to_v2i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpmovmskb %ymm0, %ecx
; AVX2-NEXT:    movl %ecx, %eax
; AVX2-NEXT:    shrl $16, %eax
; AVX2-NEXT:    addl %ecx, %eax
; AVX2-NEXT:    # kill: def $ax killed $ax killed $eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: bitcast_v32i8_to_v2i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    pushq %rbp
; AVX512-NEXT:    movq %rsp, %rbp
; AVX512-NEXT:    andq $-32, %rsp
; AVX512-NEXT:    subq $32, %rsp
; AVX512-NEXT:    vpmovb2m %ymm0, %k0
; AVX512-NEXT:    kmovd %k0, (%rsp)
; AVX512-NEXT:    vmovdqa (%rsp), %xmm0
; AVX512-NEXT:    vmovd %xmm0, %ecx
; AVX512-NEXT:    vpextrw $1, %xmm0, %eax
; AVX512-NEXT:    addl %ecx, %eax
; AVX512-NEXT:    # kill: def $ax killed $ax killed $eax
; AVX512-NEXT:    movq %rbp, %rsp
; AVX512-NEXT:    popq %rbp
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = icmp slt <32 x i8> %a0, zeroinitializer
  %2 = bitcast <32 x i1> %1 to <2 x i16>
  %3 = extractelement <2 x i16> %2, i32 0
  %4 = extractelement <2 x i16> %2, i32 1
  %5 = add i16 %3, %4
  ret i16 %5
}

;
; 512-bit vectors
;

define i4 @bitcast_v8i64_to_v2i4(<8 x i64> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v8i64_to_v2i4:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    packssdw %xmm3, %xmm2
; SSE2-SSSE3-NEXT:    packssdw %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    packssdw %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    packsswb %xmm0, %xmm0
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    movl %eax, %ecx
; SSE2-SSSE3-NEXT:    shrb $4, %cl
; SSE2-SSSE3-NEXT:    andb $15, %al
; SSE2-SSSE3-NEXT:    addb %cl, %al
; SSE2-SSSE3-NEXT:    # kill: def $al killed $al killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: bitcast_v8i64_to_v2i4:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpxor %xmm3, %xmm3, %xmm3
; AVX1-NEXT:    vpcmpgtq %xmm2, %xmm3, %xmm2
; AVX1-NEXT:    vpcmpgtq %xmm0, %xmm3, %xmm0
; AVX1-NEXT:    vpackssdw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vpackssdw %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm0, %ymm0
; AVX1-NEXT:    vmovmskps %ymm0, %eax
; AVX1-NEXT:    movl %eax, %ecx
; AVX1-NEXT:    shrb $4, %cl
; AVX1-NEXT:    andb $15, %al
; AVX1-NEXT:    addb %cl, %al
; AVX1-NEXT:    # kill: def $al killed $al killed $eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: bitcast_v8i64_to_v2i4:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpackssdw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[0,2,1,3]
; AVX2-NEXT:    vmovmskps %ymm0, %eax
; AVX2-NEXT:    movl %eax, %ecx
; AVX2-NEXT:    shrb $4, %cl
; AVX2-NEXT:    andb $15, %al
; AVX2-NEXT:    addb %cl, %al
; AVX2-NEXT:    # kill: def $al killed $al killed $eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: bitcast_v8i64_to_v2i4:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX512-NEXT:    vpcmpgtq %zmm0, %zmm1, %k0
; AVX512-NEXT:    kmovd %k0, %eax
; AVX512-NEXT:    movl %eax, %ecx
; AVX512-NEXT:    shrb $4, %cl
; AVX512-NEXT:    andb $15, %al
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = icmp slt <8 x i64> %a0, zeroinitializer
  %2 = bitcast <8 x i1> %1 to <2 x i4>
  %3 = extractelement <2 x i4> %2, i32 0
  %4 = extractelement <2 x i4> %2, i32 1
  %5 = add i4 %3, %4
  ret i4 %5
}

define i8 @bitcast_v16i32_to_v2i8(<16 x i32> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v16i32_to_v2i8:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    packssdw %xmm3, %xmm2
; SSE2-SSSE3-NEXT:    packssdw %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    packsswb %xmm2, %xmm0
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    movd %eax, %xmm0
; SSE2-SSSE3-NEXT:    movdqa %xmm0, -{{[0-9]+}}(%rsp)
; SSE2-SSSE3-NEXT:    movb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    addb -{{[0-9]+}}(%rsp), %al
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: bitcast_v16i32_to_v2i8:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vpackssdw %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vpackssdw %xmm2, %xmm0, %xmm0
; AVX1-NEXT:    vpacksswb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %ecx
; AVX1-NEXT:    movl %ecx, %eax
; AVX1-NEXT:    shrl $8, %eax
; AVX1-NEXT:    addb %cl, %al
; AVX1-NEXT:    # kill: def $al killed $al killed $eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: bitcast_v16i32_to_v2i8:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpxor %xmm2, %xmm2, %xmm2
; AVX2-NEXT:    vpcmpgtd %ymm1, %ymm2, %ymm1
; AVX2-NEXT:    vpcmpgtd %ymm0, %ymm2, %ymm0
; AVX2-NEXT:    vpackssdw %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[0,2,1,3]
; AVX2-NEXT:    vextracti128 $1, %ymm0, %xmm1
; AVX2-NEXT:    vpacksswb %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vpmovmskb %xmm0, %ecx
; AVX2-NEXT:    movl %ecx, %eax
; AVX2-NEXT:    shrl $8, %eax
; AVX2-NEXT:    addb %cl, %al
; AVX2-NEXT:    # kill: def $al killed $al killed $eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: bitcast_v16i32_to_v2i8:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpxor %xmm1, %xmm1, %xmm1
; AVX512-NEXT:    vpcmpgtd %zmm0, %zmm1, %k0
; AVX512-NEXT:    kmovw %k0, -{{[0-9]+}}(%rsp)
; AVX512-NEXT:    vmovdqa -{{[0-9]+}}(%rsp), %xmm0
; AVX512-NEXT:    vmovd %xmm0, %ecx
; AVX512-NEXT:    vpextrb $1, %xmm0, %eax
; AVX512-NEXT:    addb %cl, %al
; AVX512-NEXT:    # kill: def $al killed $al killed $eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = icmp slt <16 x i32> %a0, zeroinitializer
  %2 = bitcast <16 x i1> %1 to <2 x i8>
  %3 = extractelement <2 x i8> %2, i32 0
  %4 = extractelement <2 x i8> %2, i32 1
  %5 = add i8 %3, %4
  ret i8 %5
}

define i16 @bitcast_v32i16_to_v2i16(<32 x i16> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v32i16_to_v2i16:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    packsswb %xmm3, %xmm2
; SSE2-SSSE3-NEXT:    pmovmskb %xmm2, %ecx
; SSE2-SSSE3-NEXT:    packsswb %xmm1, %xmm0
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    addl %ecx, %eax
; SSE2-SSSE3-NEXT:    # kill: def $ax killed $ax killed $eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: bitcast_v32i16_to_v2i16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vpacksswb %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpmovmskb %xmm1, %ecx
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm1
; AVX1-NEXT:    vpacksswb %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %eax
; AVX1-NEXT:    addl %ecx, %eax
; AVX1-NEXT:    # kill: def $ax killed $ax killed $eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: bitcast_v32i16_to_v2i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpacksswb %ymm1, %ymm0, %ymm0
; AVX2-NEXT:    vpermq {{.*#+}} ymm0 = ymm0[0,2,1,3]
; AVX2-NEXT:    vpmovmskb %ymm0, %ecx
; AVX2-NEXT:    movl %ecx, %eax
; AVX2-NEXT:    shrl $16, %eax
; AVX2-NEXT:    addl %ecx, %eax
; AVX2-NEXT:    # kill: def $ax killed $ax killed $eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: bitcast_v32i16_to_v2i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    pushq %rbp
; AVX512-NEXT:    movq %rsp, %rbp
; AVX512-NEXT:    andq $-32, %rsp
; AVX512-NEXT:    subq $32, %rsp
; AVX512-NEXT:    vpmovw2m %zmm0, %k0
; AVX512-NEXT:    kmovd %k0, (%rsp)
; AVX512-NEXT:    vmovdqa (%rsp), %xmm0
; AVX512-NEXT:    vmovd %xmm0, %ecx
; AVX512-NEXT:    vpextrw $1, %xmm0, %eax
; AVX512-NEXT:    addl %ecx, %eax
; AVX512-NEXT:    # kill: def $ax killed $ax killed $eax
; AVX512-NEXT:    movq %rbp, %rsp
; AVX512-NEXT:    popq %rbp
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = icmp slt <32 x i16> %a0, zeroinitializer
  %2 = bitcast <32 x i1> %1 to <2 x i16>
  %3 = extractelement <2 x i16> %2, i32 0
  %4 = extractelement <2 x i16> %2, i32 1
  %5 = add i16 %3, %4
  ret i16 %5
}

define i32 @bitcast_v64i8_to_v2i32(<64 x i8> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v64i8_to_v2i32:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    pmovmskb %xmm1, %ecx
; SSE2-SSSE3-NEXT:    shll $16, %ecx
; SSE2-SSSE3-NEXT:    orl %eax, %ecx
; SSE2-SSSE3-NEXT:    pmovmskb %xmm2, %eax
; SSE2-SSSE3-NEXT:    pmovmskb %xmm3, %edx
; SSE2-SSSE3-NEXT:    shll $16, %edx
; SSE2-SSSE3-NEXT:    orl %eax, %edx
; SSE2-SSSE3-NEXT:    shlq $32, %rdx
; SSE2-SSSE3-NEXT:    orq %rcx, %rdx
; SSE2-SSSE3-NEXT:    movq %rdx, %xmm0
; SSE2-SSSE3-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[1,1,2,3]
; SSE2-SSSE3-NEXT:    movd %xmm0, %eax
; SSE2-SSSE3-NEXT:    addl %ecx, %eax
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: bitcast_v64i8_to_v2i32:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpmovmskb %xmm1, %eax
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm1
; AVX1-NEXT:    vpmovmskb %xmm1, %ecx
; AVX1-NEXT:    shll $16, %ecx
; AVX1-NEXT:    orl %eax, %ecx
; AVX1-NEXT:    vpmovmskb %xmm0, %edx
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %eax
; AVX1-NEXT:    shll $16, %eax
; AVX1-NEXT:    orl %edx, %eax
; AVX1-NEXT:    addl %ecx, %eax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: bitcast_v64i8_to_v2i32:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpmovmskb %ymm1, %ecx
; AVX2-NEXT:    vpmovmskb %ymm0, %eax
; AVX2-NEXT:    addl %ecx, %eax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: bitcast_v64i8_to_v2i32:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpmovb2m %zmm0, %k0
; AVX512-NEXT:    kmovq %k0, -{{[0-9]+}}(%rsp)
; AVX512-NEXT:    vmovdqa -{{[0-9]+}}(%rsp), %xmm0
; AVX512-NEXT:    vmovd %xmm0, %ecx
; AVX512-NEXT:    vpextrd $1, %xmm0, %eax
; AVX512-NEXT:    addl %ecx, %eax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = icmp slt <64 x i8> %a0, zeroinitializer
  %2 = bitcast <64 x i1> %1 to <2 x i32>
  %3 = extractelement <2 x i32> %2, i32 0
  %4 = extractelement <2 x i32> %2, i32 1
  %5 = add i32 %3, %4
  ret i32 %5
}

define i64 @bitcast_v128i8_to_v2i64(<128 x i8> %a0) nounwind {
; SSE2-SSSE3-LABEL: bitcast_v128i8_to_v2i64:
; SSE2-SSSE3:       # %bb.0:
; SSE2-SSSE3-NEXT:    pmovmskb %xmm4, %eax
; SSE2-SSSE3-NEXT:    pmovmskb %xmm5, %ecx
; SSE2-SSSE3-NEXT:    shll $16, %ecx
; SSE2-SSSE3-NEXT:    orl %eax, %ecx
; SSE2-SSSE3-NEXT:    pmovmskb %xmm6, %eax
; SSE2-SSSE3-NEXT:    pmovmskb %xmm7, %edx
; SSE2-SSSE3-NEXT:    shll $16, %edx
; SSE2-SSSE3-NEXT:    orl %eax, %edx
; SSE2-SSSE3-NEXT:    shlq $32, %rdx
; SSE2-SSSE3-NEXT:    orq %rcx, %rdx
; SSE2-SSSE3-NEXT:    pmovmskb %xmm0, %eax
; SSE2-SSSE3-NEXT:    pmovmskb %xmm1, %ecx
; SSE2-SSSE3-NEXT:    shll $16, %ecx
; SSE2-SSSE3-NEXT:    orl %eax, %ecx
; SSE2-SSSE3-NEXT:    pmovmskb %xmm2, %esi
; SSE2-SSSE3-NEXT:    pmovmskb %xmm3, %eax
; SSE2-SSSE3-NEXT:    shll $16, %eax
; SSE2-SSSE3-NEXT:    orl %esi, %eax
; SSE2-SSSE3-NEXT:    shlq $32, %rax
; SSE2-SSSE3-NEXT:    orq %rcx, %rax
; SSE2-SSSE3-NEXT:    addq %rdx, %rax
; SSE2-SSSE3-NEXT:    retq
;
; AVX1-LABEL: bitcast_v128i8_to_v2i64:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vpmovmskb %xmm2, %eax
; AVX1-NEXT:    vextractf128 $1, %ymm2, %xmm2
; AVX1-NEXT:    vpmovmskb %xmm2, %edx
; AVX1-NEXT:    shll $16, %edx
; AVX1-NEXT:    orl %eax, %edx
; AVX1-NEXT:    vpmovmskb %xmm3, %eax
; AVX1-NEXT:    vextractf128 $1, %ymm3, %xmm2
; AVX1-NEXT:    vpmovmskb %xmm2, %ecx
; AVX1-NEXT:    shll $16, %ecx
; AVX1-NEXT:    orl %eax, %ecx
; AVX1-NEXT:    shlq $32, %rcx
; AVX1-NEXT:    orq %rdx, %rcx
; AVX1-NEXT:    vpmovmskb %xmm0, %eax
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %edx
; AVX1-NEXT:    shll $16, %edx
; AVX1-NEXT:    orl %eax, %edx
; AVX1-NEXT:    vpmovmskb %xmm1, %esi
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm0
; AVX1-NEXT:    vpmovmskb %xmm0, %eax
; AVX1-NEXT:    shll $16, %eax
; AVX1-NEXT:    orl %esi, %eax
; AVX1-NEXT:    shlq $32, %rax
; AVX1-NEXT:    orq %rdx, %rax
; AVX1-NEXT:    addq %rcx, %rax
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: bitcast_v128i8_to_v2i64:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpmovmskb %ymm3, %eax
; AVX2-NEXT:    shlq $32, %rax
; AVX2-NEXT:    vpmovmskb %ymm2, %ecx
; AVX2-NEXT:    orq %rax, %rcx
; AVX2-NEXT:    vpmovmskb %ymm1, %edx
; AVX2-NEXT:    shlq $32, %rdx
; AVX2-NEXT:    vpmovmskb %ymm0, %eax
; AVX2-NEXT:    orq %rdx, %rax
; AVX2-NEXT:    addq %rcx, %rax
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: bitcast_v128i8_to_v2i64:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpmovb2m %zmm1, %k0
; AVX512-NEXT:    kmovq %k0, %rcx
; AVX512-NEXT:    vpmovb2m %zmm0, %k0
; AVX512-NEXT:    kmovq %k0, %rax
; AVX512-NEXT:    addq %rcx, %rax
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = icmp slt <128 x i8> %a0, zeroinitializer
  %2 = bitcast <128 x i1> %1 to <2 x i64>
  %3 = extractelement <2 x i64> %2, i32 0
  %4 = extractelement <2 x i64> %2, i32 1
  %5 = add i64 %3, %4
  ret i64 %5
}
