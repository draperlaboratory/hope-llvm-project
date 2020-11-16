; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -disable-peephole -mcpu=core-avx2 -show-mc-encoding | FileCheck %s --check-prefix=AVX2
; RUN: llc < %s -disable-peephole -mcpu=skx -show-mc-encoding | FileCheck %s --check-prefix=AVX512

target triple = "x86_64-unknown-unknown"

declare <4 x float> @llvm.x86.fma.vfmadd.ss(<4 x float>, <4 x float>, <4 x float>)
declare <4 x float> @llvm.x86.fma.vfmsub.ss(<4 x float>, <4 x float>, <4 x float>)
declare <4 x float> @llvm.x86.fma.vfnmadd.ss(<4 x float>, <4 x float>, <4 x float>)
declare <4 x float> @llvm.x86.fma.vfnmsub.ss(<4 x float>, <4 x float>, <4 x float>)

declare <2 x double> @llvm.x86.fma.vfmadd.sd(<2 x double>, <2 x double>, <2 x double>)
declare <2 x double> @llvm.x86.fma.vfmsub.sd(<2 x double>, <2 x double>, <2 x double>)
declare <2 x double> @llvm.x86.fma.vfnmadd.sd(<2 x double>, <2 x double>, <2 x double>)
declare <2 x double> @llvm.x86.fma.vfnmsub.sd(<2 x double>, <2 x double>, <2 x double>)

define void @fmadd_aab_ss(float* %a, float* %b) {
; AVX2-LABEL: fmadd_aab_ss:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovss (%rdi), %xmm0 # encoding: [0xc5,0xfa,0x10,0x07]
; AVX2-NEXT:    # xmm0 = mem[0],zero,zero,zero
; AVX2-NEXT:    vfmadd213ss (%rsi), %xmm0, %xmm0 # encoding: [0xc4,0xe2,0x79,0xa9,0x06]
; AVX2-NEXT:    # xmm0 = (xmm0 * xmm0) + mem
; AVX2-NEXT:    vmovss %xmm0, (%rdi) # encoding: [0xc5,0xfa,0x11,0x07]
; AVX2-NEXT:    retq # encoding: [0xc3]
;
; AVX512-LABEL: fmadd_aab_ss:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovss (%rdi), %xmm0 # EVEX TO VEX Compression encoding: [0xc5,0xfa,0x10,0x07]
; AVX512-NEXT:    # xmm0 = mem[0],zero,zero,zero
; AVX512-NEXT:    vfmadd213ss (%rsi), %xmm0, %xmm0 # EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0xa9,0x06]
; AVX512-NEXT:    # xmm0 = (xmm0 * xmm0) + mem
; AVX512-NEXT:    vmovss %xmm0, (%rdi) # EVEX TO VEX Compression encoding: [0xc5,0xfa,0x11,0x07]
; AVX512-NEXT:    retq # encoding: [0xc3]
  %a.val = load float, float* %a
  %av0 = insertelement <4 x float> undef, float %a.val, i32 0
  %av1 = insertelement <4 x float> %av0, float 0.000000e+00, i32 1
  %av2 = insertelement <4 x float> %av1, float 0.000000e+00, i32 2
  %av  = insertelement <4 x float> %av2, float 0.000000e+00, i32 3

  %b.val = load float, float* %b
  %bv0 = insertelement <4 x float> undef, float %b.val, i32 0
  %bv1 = insertelement <4 x float> %bv0, float 0.000000e+00, i32 1
  %bv2 = insertelement <4 x float> %bv1, float 0.000000e+00, i32 2
  %bv  = insertelement <4 x float> %bv2, float 0.000000e+00, i32 3

  %vr = call <4 x float> @llvm.x86.fma.vfmadd.ss(<4 x float> %av, <4 x float> %av, <4 x float> %bv)

  %sr = extractelement <4 x float> %vr, i32 0
  store float %sr, float* %a
  ret void
}

define void @fmadd_aba_ss(float* %a, float* %b) {
; AVX2-LABEL: fmadd_aba_ss:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovss (%rdi), %xmm0 # encoding: [0xc5,0xfa,0x10,0x07]
; AVX2-NEXT:    # xmm0 = mem[0],zero,zero,zero
; AVX2-NEXT:    vfmadd231ss (%rsi), %xmm0, %xmm0 # encoding: [0xc4,0xe2,0x79,0xb9,0x06]
; AVX2-NEXT:    # xmm0 = (xmm0 * mem) + xmm0
; AVX2-NEXT:    vmovss %xmm0, (%rdi) # encoding: [0xc5,0xfa,0x11,0x07]
; AVX2-NEXT:    retq # encoding: [0xc3]
;
; AVX512-LABEL: fmadd_aba_ss:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovss (%rdi), %xmm0 # EVEX TO VEX Compression encoding: [0xc5,0xfa,0x10,0x07]
; AVX512-NEXT:    # xmm0 = mem[0],zero,zero,zero
; AVX512-NEXT:    vfmadd231ss (%rsi), %xmm0, %xmm0 # EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0xb9,0x06]
; AVX512-NEXT:    # xmm0 = (xmm0 * mem) + xmm0
; AVX512-NEXT:    vmovss %xmm0, (%rdi) # EVEX TO VEX Compression encoding: [0xc5,0xfa,0x11,0x07]
; AVX512-NEXT:    retq # encoding: [0xc3]
  %a.val = load float, float* %a
  %av0 = insertelement <4 x float> undef, float %a.val, i32 0
  %av1 = insertelement <4 x float> %av0, float 0.000000e+00, i32 1
  %av2 = insertelement <4 x float> %av1, float 0.000000e+00, i32 2
  %av  = insertelement <4 x float> %av2, float 0.000000e+00, i32 3

  %b.val = load float, float* %b
  %bv0 = insertelement <4 x float> undef, float %b.val, i32 0
  %bv1 = insertelement <4 x float> %bv0, float 0.000000e+00, i32 1
  %bv2 = insertelement <4 x float> %bv1, float 0.000000e+00, i32 2
  %bv  = insertelement <4 x float> %bv2, float 0.000000e+00, i32 3

  %vr = call <4 x float> @llvm.x86.fma.vfmadd.ss(<4 x float> %av, <4 x float> %bv, <4 x float> %av)

  %sr = extractelement <4 x float> %vr, i32 0
  store float %sr, float* %a
  ret void
}

define void @fmsub_aab_ss(float* %a, float* %b) {
; AVX2-LABEL: fmsub_aab_ss:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovss (%rdi), %xmm0 # encoding: [0xc5,0xfa,0x10,0x07]
; AVX2-NEXT:    # xmm0 = mem[0],zero,zero,zero
; AVX2-NEXT:    vfmsub213ss (%rsi), %xmm0, %xmm0 # encoding: [0xc4,0xe2,0x79,0xab,0x06]
; AVX2-NEXT:    # xmm0 = (xmm0 * xmm0) - mem
; AVX2-NEXT:    vmovss %xmm0, (%rdi) # encoding: [0xc5,0xfa,0x11,0x07]
; AVX2-NEXT:    retq # encoding: [0xc3]
;
; AVX512-LABEL: fmsub_aab_ss:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovss (%rdi), %xmm0 # EVEX TO VEX Compression encoding: [0xc5,0xfa,0x10,0x07]
; AVX512-NEXT:    # xmm0 = mem[0],zero,zero,zero
; AVX512-NEXT:    vfmsub213ss (%rsi), %xmm0, %xmm0 # EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0xab,0x06]
; AVX512-NEXT:    # xmm0 = (xmm0 * xmm0) - mem
; AVX512-NEXT:    vmovss %xmm0, (%rdi) # EVEX TO VEX Compression encoding: [0xc5,0xfa,0x11,0x07]
; AVX512-NEXT:    retq # encoding: [0xc3]
  %a.val = load float, float* %a
  %av0 = insertelement <4 x float> undef, float %a.val, i32 0
  %av1 = insertelement <4 x float> %av0, float 0.000000e+00, i32 1
  %av2 = insertelement <4 x float> %av1, float 0.000000e+00, i32 2
  %av  = insertelement <4 x float> %av2, float 0.000000e+00, i32 3

  %b.val = load float, float* %b
  %bv0 = insertelement <4 x float> undef, float %b.val, i32 0
  %bv1 = insertelement <4 x float> %bv0, float 0.000000e+00, i32 1
  %bv2 = insertelement <4 x float> %bv1, float 0.000000e+00, i32 2
  %bv  = insertelement <4 x float> %bv2, float 0.000000e+00, i32 3

  %vr = call <4 x float> @llvm.x86.fma.vfmsub.ss(<4 x float> %av, <4 x float> %av, <4 x float> %bv)

  %sr = extractelement <4 x float> %vr, i32 0
  store float %sr, float* %a
  ret void
}

define void @fmsub_aba_ss(float* %a, float* %b) {
; AVX2-LABEL: fmsub_aba_ss:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovss (%rdi), %xmm0 # encoding: [0xc5,0xfa,0x10,0x07]
; AVX2-NEXT:    # xmm0 = mem[0],zero,zero,zero
; AVX2-NEXT:    vfmsub231ss (%rsi), %xmm0, %xmm0 # encoding: [0xc4,0xe2,0x79,0xbb,0x06]
; AVX2-NEXT:    # xmm0 = (xmm0 * mem) - xmm0
; AVX2-NEXT:    vmovss %xmm0, (%rdi) # encoding: [0xc5,0xfa,0x11,0x07]
; AVX2-NEXT:    retq # encoding: [0xc3]
;
; AVX512-LABEL: fmsub_aba_ss:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovss (%rdi), %xmm0 # EVEX TO VEX Compression encoding: [0xc5,0xfa,0x10,0x07]
; AVX512-NEXT:    # xmm0 = mem[0],zero,zero,zero
; AVX512-NEXT:    vfmsub231ss (%rsi), %xmm0, %xmm0 # EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0xbb,0x06]
; AVX512-NEXT:    # xmm0 = (xmm0 * mem) - xmm0
; AVX512-NEXT:    vmovss %xmm0, (%rdi) # EVEX TO VEX Compression encoding: [0xc5,0xfa,0x11,0x07]
; AVX512-NEXT:    retq # encoding: [0xc3]
  %a.val = load float, float* %a
  %av0 = insertelement <4 x float> undef, float %a.val, i32 0
  %av1 = insertelement <4 x float> %av0, float 0.000000e+00, i32 1
  %av2 = insertelement <4 x float> %av1, float 0.000000e+00, i32 2
  %av  = insertelement <4 x float> %av2, float 0.000000e+00, i32 3

  %b.val = load float, float* %b
  %bv0 = insertelement <4 x float> undef, float %b.val, i32 0
  %bv1 = insertelement <4 x float> %bv0, float 0.000000e+00, i32 1
  %bv2 = insertelement <4 x float> %bv1, float 0.000000e+00, i32 2
  %bv  = insertelement <4 x float> %bv2, float 0.000000e+00, i32 3

  %vr = call <4 x float> @llvm.x86.fma.vfmsub.ss(<4 x float> %av, <4 x float> %bv, <4 x float> %av)

  %sr = extractelement <4 x float> %vr, i32 0
  store float %sr, float* %a
  ret void
}

define void @fnmadd_aab_ss(float* %a, float* %b) {
; AVX2-LABEL: fnmadd_aab_ss:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovss (%rdi), %xmm0 # encoding: [0xc5,0xfa,0x10,0x07]
; AVX2-NEXT:    # xmm0 = mem[0],zero,zero,zero
; AVX2-NEXT:    vfnmadd213ss (%rsi), %xmm0, %xmm0 # encoding: [0xc4,0xe2,0x79,0xad,0x06]
; AVX2-NEXT:    # xmm0 = -(xmm0 * xmm0) + mem
; AVX2-NEXT:    vmovss %xmm0, (%rdi) # encoding: [0xc5,0xfa,0x11,0x07]
; AVX2-NEXT:    retq # encoding: [0xc3]
;
; AVX512-LABEL: fnmadd_aab_ss:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovss (%rdi), %xmm0 # EVEX TO VEX Compression encoding: [0xc5,0xfa,0x10,0x07]
; AVX512-NEXT:    # xmm0 = mem[0],zero,zero,zero
; AVX512-NEXT:    vfnmadd213ss (%rsi), %xmm0, %xmm0 # EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0xad,0x06]
; AVX512-NEXT:    # xmm0 = -(xmm0 * xmm0) + mem
; AVX512-NEXT:    vmovss %xmm0, (%rdi) # EVEX TO VEX Compression encoding: [0xc5,0xfa,0x11,0x07]
; AVX512-NEXT:    retq # encoding: [0xc3]
  %a.val = load float, float* %a
  %av0 = insertelement <4 x float> undef, float %a.val, i32 0
  %av1 = insertelement <4 x float> %av0, float 0.000000e+00, i32 1
  %av2 = insertelement <4 x float> %av1, float 0.000000e+00, i32 2
  %av  = insertelement <4 x float> %av2, float 0.000000e+00, i32 3

  %b.val = load float, float* %b
  %bv0 = insertelement <4 x float> undef, float %b.val, i32 0
  %bv1 = insertelement <4 x float> %bv0, float 0.000000e+00, i32 1
  %bv2 = insertelement <4 x float> %bv1, float 0.000000e+00, i32 2
  %bv  = insertelement <4 x float> %bv2, float 0.000000e+00, i32 3

  %vr = call <4 x float> @llvm.x86.fma.vfnmadd.ss(<4 x float> %av, <4 x float> %av, <4 x float> %bv)

  %sr = extractelement <4 x float> %vr, i32 0
  store float %sr, float* %a
  ret void
}

define void @fnmadd_aba_ss(float* %a, float* %b) {
; AVX2-LABEL: fnmadd_aba_ss:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovss (%rdi), %xmm0 # encoding: [0xc5,0xfa,0x10,0x07]
; AVX2-NEXT:    # xmm0 = mem[0],zero,zero,zero
; AVX2-NEXT:    vfnmadd231ss (%rsi), %xmm0, %xmm0 # encoding: [0xc4,0xe2,0x79,0xbd,0x06]
; AVX2-NEXT:    # xmm0 = -(xmm0 * mem) + xmm0
; AVX2-NEXT:    vmovss %xmm0, (%rdi) # encoding: [0xc5,0xfa,0x11,0x07]
; AVX2-NEXT:    retq # encoding: [0xc3]
;
; AVX512-LABEL: fnmadd_aba_ss:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovss (%rdi), %xmm0 # EVEX TO VEX Compression encoding: [0xc5,0xfa,0x10,0x07]
; AVX512-NEXT:    # xmm0 = mem[0],zero,zero,zero
; AVX512-NEXT:    vfnmadd231ss (%rsi), %xmm0, %xmm0 # EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0xbd,0x06]
; AVX512-NEXT:    # xmm0 = -(xmm0 * mem) + xmm0
; AVX512-NEXT:    vmovss %xmm0, (%rdi) # EVEX TO VEX Compression encoding: [0xc5,0xfa,0x11,0x07]
; AVX512-NEXT:    retq # encoding: [0xc3]
  %a.val = load float, float* %a
  %av0 = insertelement <4 x float> undef, float %a.val, i32 0
  %av1 = insertelement <4 x float> %av0, float 0.000000e+00, i32 1
  %av2 = insertelement <4 x float> %av1, float 0.000000e+00, i32 2
  %av  = insertelement <4 x float> %av2, float 0.000000e+00, i32 3

  %b.val = load float, float* %b
  %bv0 = insertelement <4 x float> undef, float %b.val, i32 0
  %bv1 = insertelement <4 x float> %bv0, float 0.000000e+00, i32 1
  %bv2 = insertelement <4 x float> %bv1, float 0.000000e+00, i32 2
  %bv  = insertelement <4 x float> %bv2, float 0.000000e+00, i32 3

  %vr = call <4 x float> @llvm.x86.fma.vfnmadd.ss(<4 x float> %av, <4 x float> %bv, <4 x float> %av)

  %sr = extractelement <4 x float> %vr, i32 0
  store float %sr, float* %a
  ret void
}

define void @fnmsub_aab_ss(float* %a, float* %b) {
; AVX2-LABEL: fnmsub_aab_ss:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovss (%rdi), %xmm0 # encoding: [0xc5,0xfa,0x10,0x07]
; AVX2-NEXT:    # xmm0 = mem[0],zero,zero,zero
; AVX2-NEXT:    vfnmsub213ss (%rsi), %xmm0, %xmm0 # encoding: [0xc4,0xe2,0x79,0xaf,0x06]
; AVX2-NEXT:    # xmm0 = -(xmm0 * xmm0) - mem
; AVX2-NEXT:    vmovss %xmm0, (%rdi) # encoding: [0xc5,0xfa,0x11,0x07]
; AVX2-NEXT:    retq # encoding: [0xc3]
;
; AVX512-LABEL: fnmsub_aab_ss:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovss (%rdi), %xmm0 # EVEX TO VEX Compression encoding: [0xc5,0xfa,0x10,0x07]
; AVX512-NEXT:    # xmm0 = mem[0],zero,zero,zero
; AVX512-NEXT:    vfnmsub213ss (%rsi), %xmm0, %xmm0 # EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0xaf,0x06]
; AVX512-NEXT:    # xmm0 = -(xmm0 * xmm0) - mem
; AVX512-NEXT:    vmovss %xmm0, (%rdi) # EVEX TO VEX Compression encoding: [0xc5,0xfa,0x11,0x07]
; AVX512-NEXT:    retq # encoding: [0xc3]
  %a.val = load float, float* %a
  %av0 = insertelement <4 x float> undef, float %a.val, i32 0
  %av1 = insertelement <4 x float> %av0, float 0.000000e+00, i32 1
  %av2 = insertelement <4 x float> %av1, float 0.000000e+00, i32 2
  %av  = insertelement <4 x float> %av2, float 0.000000e+00, i32 3

  %b.val = load float, float* %b
  %bv0 = insertelement <4 x float> undef, float %b.val, i32 0
  %bv1 = insertelement <4 x float> %bv0, float 0.000000e+00, i32 1
  %bv2 = insertelement <4 x float> %bv1, float 0.000000e+00, i32 2
  %bv  = insertelement <4 x float> %bv2, float 0.000000e+00, i32 3

  %vr = call <4 x float> @llvm.x86.fma.vfnmsub.ss(<4 x float> %av, <4 x float> %av, <4 x float> %bv)

  %sr = extractelement <4 x float> %vr, i32 0
  store float %sr, float* %a
  ret void
}

define void @fnmsub_aba_ss(float* %a, float* %b) {
; AVX2-LABEL: fnmsub_aba_ss:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovss (%rdi), %xmm0 # encoding: [0xc5,0xfa,0x10,0x07]
; AVX2-NEXT:    # xmm0 = mem[0],zero,zero,zero
; AVX2-NEXT:    vfnmsub231ss (%rsi), %xmm0, %xmm0 # encoding: [0xc4,0xe2,0x79,0xbf,0x06]
; AVX2-NEXT:    # xmm0 = -(xmm0 * mem) - xmm0
; AVX2-NEXT:    vmovss %xmm0, (%rdi) # encoding: [0xc5,0xfa,0x11,0x07]
; AVX2-NEXT:    retq # encoding: [0xc3]
;
; AVX512-LABEL: fnmsub_aba_ss:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovss (%rdi), %xmm0 # EVEX TO VEX Compression encoding: [0xc5,0xfa,0x10,0x07]
; AVX512-NEXT:    # xmm0 = mem[0],zero,zero,zero
; AVX512-NEXT:    vfnmsub231ss (%rsi), %xmm0, %xmm0 # EVEX TO VEX Compression encoding: [0xc4,0xe2,0x79,0xbf,0x06]
; AVX512-NEXT:    # xmm0 = -(xmm0 * mem) - xmm0
; AVX512-NEXT:    vmovss %xmm0, (%rdi) # EVEX TO VEX Compression encoding: [0xc5,0xfa,0x11,0x07]
; AVX512-NEXT:    retq # encoding: [0xc3]
  %a.val = load float, float* %a
  %av0 = insertelement <4 x float> undef, float %a.val, i32 0
  %av1 = insertelement <4 x float> %av0, float 0.000000e+00, i32 1
  %av2 = insertelement <4 x float> %av1, float 0.000000e+00, i32 2
  %av  = insertelement <4 x float> %av2, float 0.000000e+00, i32 3

  %b.val = load float, float* %b
  %bv0 = insertelement <4 x float> undef, float %b.val, i32 0
  %bv1 = insertelement <4 x float> %bv0, float 0.000000e+00, i32 1
  %bv2 = insertelement <4 x float> %bv1, float 0.000000e+00, i32 2
  %bv  = insertelement <4 x float> %bv2, float 0.000000e+00, i32 3

  %vr = call <4 x float> @llvm.x86.fma.vfnmsub.ss(<4 x float> %av, <4 x float> %bv, <4 x float> %av)

  %sr = extractelement <4 x float> %vr, i32 0
  store float %sr, float* %a
  ret void
}

define void @fmadd_aab_sd(double* %a, double* %b) {
; AVX2-LABEL: fmadd_aab_sd:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovsd (%rdi), %xmm0 # encoding: [0xc5,0xfb,0x10,0x07]
; AVX2-NEXT:    # xmm0 = mem[0],zero
; AVX2-NEXT:    vfmadd213sd (%rsi), %xmm0, %xmm0 # encoding: [0xc4,0xe2,0xf9,0xa9,0x06]
; AVX2-NEXT:    # xmm0 = (xmm0 * xmm0) + mem
; AVX2-NEXT:    vmovsd %xmm0, (%rdi) # encoding: [0xc5,0xfb,0x11,0x07]
; AVX2-NEXT:    retq # encoding: [0xc3]
;
; AVX512-LABEL: fmadd_aab_sd:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovsd (%rdi), %xmm0 # EVEX TO VEX Compression encoding: [0xc5,0xfb,0x10,0x07]
; AVX512-NEXT:    # xmm0 = mem[0],zero
; AVX512-NEXT:    vfmadd213sd (%rsi), %xmm0, %xmm0 # EVEX TO VEX Compression encoding: [0xc4,0xe2,0xf9,0xa9,0x06]
; AVX512-NEXT:    # xmm0 = (xmm0 * xmm0) + mem
; AVX512-NEXT:    vmovsd %xmm0, (%rdi) # EVEX TO VEX Compression encoding: [0xc5,0xfb,0x11,0x07]
; AVX512-NEXT:    retq # encoding: [0xc3]
  %a.val = load double, double* %a
  %av0 = insertelement <2 x double> undef, double %a.val, i32 0
  %av  = insertelement <2 x double> %av0, double 0.000000e+00, i32 1

  %b.val = load double, double* %b
  %bv0 = insertelement <2 x double> undef, double %b.val, i32 0
  %bv  = insertelement <2 x double> %bv0, double 0.000000e+00, i32 1

  %vr = call <2 x double> @llvm.x86.fma.vfmadd.sd(<2 x double> %av, <2 x double> %av, <2 x double> %bv)

  %sr = extractelement <2 x double> %vr, i32 0
  store double %sr, double* %a
  ret void
}

define void @fmadd_aba_sd(double* %a, double* %b) {
; AVX2-LABEL: fmadd_aba_sd:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovsd (%rdi), %xmm0 # encoding: [0xc5,0xfb,0x10,0x07]
; AVX2-NEXT:    # xmm0 = mem[0],zero
; AVX2-NEXT:    vfmadd231sd (%rsi), %xmm0, %xmm0 # encoding: [0xc4,0xe2,0xf9,0xb9,0x06]
; AVX2-NEXT:    # xmm0 = (xmm0 * mem) + xmm0
; AVX2-NEXT:    vmovsd %xmm0, (%rdi) # encoding: [0xc5,0xfb,0x11,0x07]
; AVX2-NEXT:    retq # encoding: [0xc3]
;
; AVX512-LABEL: fmadd_aba_sd:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovsd (%rdi), %xmm0 # EVEX TO VEX Compression encoding: [0xc5,0xfb,0x10,0x07]
; AVX512-NEXT:    # xmm0 = mem[0],zero
; AVX512-NEXT:    vfmadd231sd (%rsi), %xmm0, %xmm0 # EVEX TO VEX Compression encoding: [0xc4,0xe2,0xf9,0xb9,0x06]
; AVX512-NEXT:    # xmm0 = (xmm0 * mem) + xmm0
; AVX512-NEXT:    vmovsd %xmm0, (%rdi) # EVEX TO VEX Compression encoding: [0xc5,0xfb,0x11,0x07]
; AVX512-NEXT:    retq # encoding: [0xc3]
  %a.val = load double, double* %a
  %av0 = insertelement <2 x double> undef, double %a.val, i32 0
  %av  = insertelement <2 x double> %av0, double 0.000000e+00, i32 1

  %b.val = load double, double* %b
  %bv0 = insertelement <2 x double> undef, double %b.val, i32 0
  %bv  = insertelement <2 x double> %bv0, double 0.000000e+00, i32 1

  %vr = call <2 x double> @llvm.x86.fma.vfmadd.sd(<2 x double> %av, <2 x double> %bv, <2 x double> %av)

  %sr = extractelement <2 x double> %vr, i32 0
  store double %sr, double* %a
  ret void
}

define void @fmsub_aab_sd(double* %a, double* %b) {
; AVX2-LABEL: fmsub_aab_sd:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovsd (%rdi), %xmm0 # encoding: [0xc5,0xfb,0x10,0x07]
; AVX2-NEXT:    # xmm0 = mem[0],zero
; AVX2-NEXT:    vfmsub213sd (%rsi), %xmm0, %xmm0 # encoding: [0xc4,0xe2,0xf9,0xab,0x06]
; AVX2-NEXT:    # xmm0 = (xmm0 * xmm0) - mem
; AVX2-NEXT:    vmovsd %xmm0, (%rdi) # encoding: [0xc5,0xfb,0x11,0x07]
; AVX2-NEXT:    retq # encoding: [0xc3]
;
; AVX512-LABEL: fmsub_aab_sd:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovsd (%rdi), %xmm0 # EVEX TO VEX Compression encoding: [0xc5,0xfb,0x10,0x07]
; AVX512-NEXT:    # xmm0 = mem[0],zero
; AVX512-NEXT:    vfmsub213sd (%rsi), %xmm0, %xmm0 # EVEX TO VEX Compression encoding: [0xc4,0xe2,0xf9,0xab,0x06]
; AVX512-NEXT:    # xmm0 = (xmm0 * xmm0) - mem
; AVX512-NEXT:    vmovsd %xmm0, (%rdi) # EVEX TO VEX Compression encoding: [0xc5,0xfb,0x11,0x07]
; AVX512-NEXT:    retq # encoding: [0xc3]
  %a.val = load double, double* %a
  %av0 = insertelement <2 x double> undef, double %a.val, i32 0
  %av  = insertelement <2 x double> %av0, double 0.000000e+00, i32 1

  %b.val = load double, double* %b
  %bv0 = insertelement <2 x double> undef, double %b.val, i32 0
  %bv  = insertelement <2 x double> %bv0, double 0.000000e+00, i32 1

  %vr = call <2 x double> @llvm.x86.fma.vfmsub.sd(<2 x double> %av, <2 x double> %av, <2 x double> %bv)

  %sr = extractelement <2 x double> %vr, i32 0
  store double %sr, double* %a
  ret void
}

define void @fmsub_aba_sd(double* %a, double* %b) {
; AVX2-LABEL: fmsub_aba_sd:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovsd (%rdi), %xmm0 # encoding: [0xc5,0xfb,0x10,0x07]
; AVX2-NEXT:    # xmm0 = mem[0],zero
; AVX2-NEXT:    vfmsub231sd (%rsi), %xmm0, %xmm0 # encoding: [0xc4,0xe2,0xf9,0xbb,0x06]
; AVX2-NEXT:    # xmm0 = (xmm0 * mem) - xmm0
; AVX2-NEXT:    vmovsd %xmm0, (%rdi) # encoding: [0xc5,0xfb,0x11,0x07]
; AVX2-NEXT:    retq # encoding: [0xc3]
;
; AVX512-LABEL: fmsub_aba_sd:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovsd (%rdi), %xmm0 # EVEX TO VEX Compression encoding: [0xc5,0xfb,0x10,0x07]
; AVX512-NEXT:    # xmm0 = mem[0],zero
; AVX512-NEXT:    vfmsub231sd (%rsi), %xmm0, %xmm0 # EVEX TO VEX Compression encoding: [0xc4,0xe2,0xf9,0xbb,0x06]
; AVX512-NEXT:    # xmm0 = (xmm0 * mem) - xmm0
; AVX512-NEXT:    vmovsd %xmm0, (%rdi) # EVEX TO VEX Compression encoding: [0xc5,0xfb,0x11,0x07]
; AVX512-NEXT:    retq # encoding: [0xc3]
  %a.val = load double, double* %a
  %av0 = insertelement <2 x double> undef, double %a.val, i32 0
  %av  = insertelement <2 x double> %av0, double 0.000000e+00, i32 1

  %b.val = load double, double* %b
  %bv0 = insertelement <2 x double> undef, double %b.val, i32 0
  %bv  = insertelement <2 x double> %bv0, double 0.000000e+00, i32 1

  %vr = call <2 x double> @llvm.x86.fma.vfmsub.sd(<2 x double> %av, <2 x double> %bv, <2 x double> %av)

  %sr = extractelement <2 x double> %vr, i32 0
  store double %sr, double* %a
  ret void
}

define void @fnmadd_aab_sd(double* %a, double* %b) {
; AVX2-LABEL: fnmadd_aab_sd:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovsd (%rdi), %xmm0 # encoding: [0xc5,0xfb,0x10,0x07]
; AVX2-NEXT:    # xmm0 = mem[0],zero
; AVX2-NEXT:    vfnmadd213sd (%rsi), %xmm0, %xmm0 # encoding: [0xc4,0xe2,0xf9,0xad,0x06]
; AVX2-NEXT:    # xmm0 = -(xmm0 * xmm0) + mem
; AVX2-NEXT:    vmovsd %xmm0, (%rdi) # encoding: [0xc5,0xfb,0x11,0x07]
; AVX2-NEXT:    retq # encoding: [0xc3]
;
; AVX512-LABEL: fnmadd_aab_sd:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovsd (%rdi), %xmm0 # EVEX TO VEX Compression encoding: [0xc5,0xfb,0x10,0x07]
; AVX512-NEXT:    # xmm0 = mem[0],zero
; AVX512-NEXT:    vfnmadd213sd (%rsi), %xmm0, %xmm0 # EVEX TO VEX Compression encoding: [0xc4,0xe2,0xf9,0xad,0x06]
; AVX512-NEXT:    # xmm0 = -(xmm0 * xmm0) + mem
; AVX512-NEXT:    vmovsd %xmm0, (%rdi) # EVEX TO VEX Compression encoding: [0xc5,0xfb,0x11,0x07]
; AVX512-NEXT:    retq # encoding: [0xc3]
  %a.val = load double, double* %a
  %av0 = insertelement <2 x double> undef, double %a.val, i32 0
  %av  = insertelement <2 x double> %av0, double 0.000000e+00, i32 1

  %b.val = load double, double* %b
  %bv0 = insertelement <2 x double> undef, double %b.val, i32 0
  %bv  = insertelement <2 x double> %bv0, double 0.000000e+00, i32 1

  %vr = call <2 x double> @llvm.x86.fma.vfnmadd.sd(<2 x double> %av, <2 x double> %av, <2 x double> %bv)

  %sr = extractelement <2 x double> %vr, i32 0
  store double %sr, double* %a
  ret void
}

define void @fnmadd_aba_sd(double* %a, double* %b) {
; AVX2-LABEL: fnmadd_aba_sd:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovsd (%rdi), %xmm0 # encoding: [0xc5,0xfb,0x10,0x07]
; AVX2-NEXT:    # xmm0 = mem[0],zero
; AVX2-NEXT:    vfnmadd231sd (%rsi), %xmm0, %xmm0 # encoding: [0xc4,0xe2,0xf9,0xbd,0x06]
; AVX2-NEXT:    # xmm0 = -(xmm0 * mem) + xmm0
; AVX2-NEXT:    vmovsd %xmm0, (%rdi) # encoding: [0xc5,0xfb,0x11,0x07]
; AVX2-NEXT:    retq # encoding: [0xc3]
;
; AVX512-LABEL: fnmadd_aba_sd:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovsd (%rdi), %xmm0 # EVEX TO VEX Compression encoding: [0xc5,0xfb,0x10,0x07]
; AVX512-NEXT:    # xmm0 = mem[0],zero
; AVX512-NEXT:    vfnmadd231sd (%rsi), %xmm0, %xmm0 # EVEX TO VEX Compression encoding: [0xc4,0xe2,0xf9,0xbd,0x06]
; AVX512-NEXT:    # xmm0 = -(xmm0 * mem) + xmm0
; AVX512-NEXT:    vmovsd %xmm0, (%rdi) # EVEX TO VEX Compression encoding: [0xc5,0xfb,0x11,0x07]
; AVX512-NEXT:    retq # encoding: [0xc3]
  %a.val = load double, double* %a
  %av0 = insertelement <2 x double> undef, double %a.val, i32 0
  %av  = insertelement <2 x double> %av0, double 0.000000e+00, i32 1

  %b.val = load double, double* %b
  %bv0 = insertelement <2 x double> undef, double %b.val, i32 0
  %bv  = insertelement <2 x double> %bv0, double 0.000000e+00, i32 1

  %vr = call <2 x double> @llvm.x86.fma.vfnmadd.sd(<2 x double> %av, <2 x double> %bv, <2 x double> %av)

  %sr = extractelement <2 x double> %vr, i32 0
  store double %sr, double* %a
  ret void
}

define void @fnmsub_aab_sd(double* %a, double* %b) {
; AVX2-LABEL: fnmsub_aab_sd:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovsd (%rdi), %xmm0 # encoding: [0xc5,0xfb,0x10,0x07]
; AVX2-NEXT:    # xmm0 = mem[0],zero
; AVX2-NEXT:    vfnmsub213sd (%rsi), %xmm0, %xmm0 # encoding: [0xc4,0xe2,0xf9,0xaf,0x06]
; AVX2-NEXT:    # xmm0 = -(xmm0 * xmm0) - mem
; AVX2-NEXT:    vmovsd %xmm0, (%rdi) # encoding: [0xc5,0xfb,0x11,0x07]
; AVX2-NEXT:    retq # encoding: [0xc3]
;
; AVX512-LABEL: fnmsub_aab_sd:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovsd (%rdi), %xmm0 # EVEX TO VEX Compression encoding: [0xc5,0xfb,0x10,0x07]
; AVX512-NEXT:    # xmm0 = mem[0],zero
; AVX512-NEXT:    vfnmsub213sd (%rsi), %xmm0, %xmm0 # EVEX TO VEX Compression encoding: [0xc4,0xe2,0xf9,0xaf,0x06]
; AVX512-NEXT:    # xmm0 = -(xmm0 * xmm0) - mem
; AVX512-NEXT:    vmovsd %xmm0, (%rdi) # EVEX TO VEX Compression encoding: [0xc5,0xfb,0x11,0x07]
; AVX512-NEXT:    retq # encoding: [0xc3]
  %a.val = load double, double* %a
  %av0 = insertelement <2 x double> undef, double %a.val, i32 0
  %av  = insertelement <2 x double> %av0, double 0.000000e+00, i32 1

  %b.val = load double, double* %b
  %bv0 = insertelement <2 x double> undef, double %b.val, i32 0
  %bv  = insertelement <2 x double> %bv0, double 0.000000e+00, i32 1

  %vr = call <2 x double> @llvm.x86.fma.vfnmsub.sd(<2 x double> %av, <2 x double> %av, <2 x double> %bv)

  %sr = extractelement <2 x double> %vr, i32 0
  store double %sr, double* %a
  ret void
}

define void @fnmsub_aba_sd(double* %a, double* %b) {
; AVX2-LABEL: fnmsub_aba_sd:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovsd (%rdi), %xmm0 # encoding: [0xc5,0xfb,0x10,0x07]
; AVX2-NEXT:    # xmm0 = mem[0],zero
; AVX2-NEXT:    vfnmsub231sd (%rsi), %xmm0, %xmm0 # encoding: [0xc4,0xe2,0xf9,0xbf,0x06]
; AVX2-NEXT:    # xmm0 = -(xmm0 * mem) - xmm0
; AVX2-NEXT:    vmovsd %xmm0, (%rdi) # encoding: [0xc5,0xfb,0x11,0x07]
; AVX2-NEXT:    retq # encoding: [0xc3]
;
; AVX512-LABEL: fnmsub_aba_sd:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vmovsd (%rdi), %xmm0 # EVEX TO VEX Compression encoding: [0xc5,0xfb,0x10,0x07]
; AVX512-NEXT:    # xmm0 = mem[0],zero
; AVX512-NEXT:    vfnmsub231sd (%rsi), %xmm0, %xmm0 # EVEX TO VEX Compression encoding: [0xc4,0xe2,0xf9,0xbf,0x06]
; AVX512-NEXT:    # xmm0 = -(xmm0 * mem) - xmm0
; AVX512-NEXT:    vmovsd %xmm0, (%rdi) # EVEX TO VEX Compression encoding: [0xc5,0xfb,0x11,0x07]
; AVX512-NEXT:    retq # encoding: [0xc3]
  %a.val = load double, double* %a
  %av0 = insertelement <2 x double> undef, double %a.val, i32 0
  %av  = insertelement <2 x double> %av0, double 0.000000e+00, i32 1

  %b.val = load double, double* %b
  %bv0 = insertelement <2 x double> undef, double %b.val, i32 0
  %bv  = insertelement <2 x double> %bv0, double 0.000000e+00, i32 1

  %vr = call <2 x double> @llvm.x86.fma.vfnmsub.sd(<2 x double> %av, <2 x double> %bv, <2 x double> %av)

  %sr = extractelement <2 x double> %vr, i32 0
  store double %sr, double* %a
  ret void
}


