; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-pc-win32 -mcpu=core-avx2 | FileCheck %s --check-prefix=FMA
; RUN: llc < %s -mtriple=x86_64-pc-win32 -mattr=+fma | FileCheck %s --check-prefix=FMA
; RUN: llc < %s -mcpu=bdver2 -mtriple=x86_64-pc-win32 -mattr=-fma4 | FileCheck %s --check-prefix=FMA

attributes #0 = { nounwind }

declare <4 x float> @llvm.x86.fma.vfmadd.ss(<4 x float>, <4 x float>, <4 x float>) nounwind readnone
define <4 x float> @test_x86_fmadd_baa_ss(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fmadd_baa_ss:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rdx), %xmm0
; FMA-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; FMA-NEXT:    vfmadd213ss {{.*#+}} xmm0 = (xmm1 * xmm0) + xmm1
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmadd.ss(<4 x float> %b, <4 x float> %a, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fmadd_aba_ss(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fmadd_aba_ss:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %xmm0
; FMA-NEXT:    vfmadd132ss {{.*#+}} xmm0 = (xmm0 * mem) + xmm0
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmadd.ss(<4 x float> %a, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fmadd_bba_ss(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fmadd_bba_ss:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rdx), %xmm0
; FMA-NEXT:    vfmadd213ss {{.*#+}} xmm0 = (xmm0 * xmm0) + mem
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmadd.ss(<4 x float> %b, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

declare <4 x float> @llvm.x86.fma.vfmadd.ps(<4 x float>, <4 x float>, <4 x float>) nounwind readnone
define <4 x float> @test_x86_fmadd_baa_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fmadd_baa_ps:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %xmm0
; FMA-NEXT:    vfmadd132ps {{.*#+}} xmm0 = (xmm0 * mem) + xmm0
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmadd.ps(<4 x float> %b, <4 x float> %a, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fmadd_aba_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fmadd_aba_ps:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %xmm0
; FMA-NEXT:    vfmadd231ps {{.*#+}} xmm0 = (xmm0 * mem) + xmm0
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmadd.ps(<4 x float> %a, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fmadd_bba_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fmadd_bba_ps:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rdx), %xmm0
; FMA-NEXT:    vfmadd213ps {{.*#+}} xmm0 = (xmm0 * xmm0) + mem
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmadd.ps(<4 x float> %b, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

declare <8 x float> @llvm.x86.fma.vfmadd.ps.256(<8 x float>, <8 x float>, <8 x float>) nounwind readnone
define <8 x float> @test_x86_fmadd_baa_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA-LABEL: test_x86_fmadd_baa_ps_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %ymm0
; FMA-NEXT:    vfmadd132ps {{.*#+}} ymm0 = (ymm0 * mem) + ymm0
; FMA-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfmadd.ps.256(<8 x float> %b, <8 x float> %a, <8 x float> %a) nounwind
  ret <8 x float> %res
}

define <8 x float> @test_x86_fmadd_aba_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA-LABEL: test_x86_fmadd_aba_ps_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %ymm0
; FMA-NEXT:    vfmadd231ps {{.*#+}} ymm0 = (ymm0 * mem) + ymm0
; FMA-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfmadd.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %a) nounwind
  ret <8 x float> %res
}

define <8 x float> @test_x86_fmadd_bba_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA-LABEL: test_x86_fmadd_bba_ps_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rdx), %ymm0
; FMA-NEXT:    vfmadd213ps {{.*#+}} ymm0 = (ymm0 * ymm0) + mem
; FMA-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfmadd.ps.256(<8 x float> %b, <8 x float> %b, <8 x float> %a) nounwind
  ret <8 x float> %res
}

declare <2 x double> @llvm.x86.fma.vfmadd.sd(<2 x double>, <2 x double>, <2 x double>) nounwind readnone
define <2 x double> @test_x86_fmadd_baa_sd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fmadd_baa_sd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rdx), %xmm0
; FMA-NEXT:    vmovsd {{.*#+}} xmm1 = mem[0],zero
; FMA-NEXT:    vfmadd213sd {{.*#+}} xmm0 = (xmm1 * xmm0) + xmm1
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmadd.sd(<2 x double> %b, <2 x double> %a, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fmadd_aba_sd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fmadd_aba_sd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %xmm0
; FMA-NEXT:    vfmadd132sd {{.*#+}} xmm0 = (xmm0 * mem) + xmm0
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmadd.sd(<2 x double> %a, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fmadd_bba_sd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fmadd_bba_sd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rdx), %xmm0
; FMA-NEXT:    vfmadd213sd {{.*#+}} xmm0 = (xmm0 * xmm0) + mem
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmadd.sd(<2 x double> %b, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

declare <2 x double> @llvm.x86.fma.vfmadd.pd(<2 x double>, <2 x double>, <2 x double>) nounwind readnone
define <2 x double> @test_x86_fmadd_baa_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fmadd_baa_pd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %xmm0
; FMA-NEXT:    vfmadd132pd {{.*#+}} xmm0 = (xmm0 * mem) + xmm0
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmadd.pd(<2 x double> %b, <2 x double> %a, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fmadd_aba_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fmadd_aba_pd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %xmm0
; FMA-NEXT:    vfmadd231pd {{.*#+}} xmm0 = (xmm0 * mem) + xmm0
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmadd.pd(<2 x double> %a, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fmadd_bba_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fmadd_bba_pd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rdx), %xmm0
; FMA-NEXT:    vfmadd213pd {{.*#+}} xmm0 = (xmm0 * xmm0) + mem
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmadd.pd(<2 x double> %b, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

declare <4 x double> @llvm.x86.fma.vfmadd.pd.256(<4 x double>, <4 x double>, <4 x double>) nounwind readnone
define <4 x double> @test_x86_fmadd_baa_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA-LABEL: test_x86_fmadd_baa_pd_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %ymm0
; FMA-NEXT:    vfmadd132pd {{.*#+}} ymm0 = (ymm0 * mem) + ymm0
; FMA-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfmadd.pd.256(<4 x double> %b, <4 x double> %a, <4 x double> %a) nounwind
  ret <4 x double> %res
}

define <4 x double> @test_x86_fmadd_aba_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA-LABEL: test_x86_fmadd_aba_pd_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %ymm0
; FMA-NEXT:    vfmadd231pd {{.*#+}} ymm0 = (ymm0 * mem) + ymm0
; FMA-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfmadd.pd.256(<4 x double> %a, <4 x double> %b, <4 x double> %a) nounwind
  ret <4 x double> %res
}

define <4 x double> @test_x86_fmadd_bba_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA-LABEL: test_x86_fmadd_bba_pd_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rdx), %ymm0
; FMA-NEXT:    vfmadd213pd {{.*#+}} ymm0 = (ymm0 * ymm0) + mem
; FMA-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfmadd.pd.256(<4 x double> %b, <4 x double> %b, <4 x double> %a) nounwind
  ret <4 x double> %res
}


declare <4 x float> @llvm.x86.fma.vfnmadd.ss(<4 x float>, <4 x float>, <4 x float>) nounwind readnone
define <4 x float> @test_x86_fnmadd_baa_ss(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_baa_ss:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rdx), %xmm0
; FMA-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; FMA-NEXT:    vfnmadd213ss {{.*#+}} xmm0 = -(xmm1 * xmm0) + xmm1
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmadd.ss(<4 x float> %b, <4 x float> %a, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fnmadd_aba_ss(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_aba_ss:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %xmm0
; FMA-NEXT:    vfnmadd132ss {{.*#+}} xmm0 = -(xmm0 * mem) + xmm0
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmadd.ss(<4 x float> %a, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fnmadd_bba_ss(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_bba_ss:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rdx), %xmm0
; FMA-NEXT:    vfnmadd213ss {{.*#+}} xmm0 = -(xmm0 * xmm0) + mem
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmadd.ss(<4 x float> %b, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

declare <4 x float> @llvm.x86.fma.vfnmadd.ps(<4 x float>, <4 x float>, <4 x float>) nounwind readnone
define <4 x float> @test_x86_fnmadd_baa_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_baa_ps:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %xmm0
; FMA-NEXT:    vfnmadd132ps {{.*#+}} xmm0 = -(xmm0 * mem) + xmm0
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmadd.ps(<4 x float> %b, <4 x float> %a, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fnmadd_aba_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_aba_ps:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %xmm0
; FMA-NEXT:    vfnmadd231ps {{.*#+}} xmm0 = -(xmm0 * mem) + xmm0
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmadd.ps(<4 x float> %a, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fnmadd_bba_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_bba_ps:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rdx), %xmm0
; FMA-NEXT:    vfnmadd213ps {{.*#+}} xmm0 = -(xmm0 * xmm0) + mem
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmadd.ps(<4 x float> %b, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

declare <8 x float> @llvm.x86.fma.vfnmadd.ps.256(<8 x float>, <8 x float>, <8 x float>) nounwind readnone
define <8 x float> @test_x86_fnmadd_baa_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_baa_ps_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %ymm0
; FMA-NEXT:    vfnmadd132ps {{.*#+}} ymm0 = -(ymm0 * mem) + ymm0
; FMA-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfnmadd.ps.256(<8 x float> %b, <8 x float> %a, <8 x float> %a) nounwind
  ret <8 x float> %res
}

define <8 x float> @test_x86_fnmadd_aba_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_aba_ps_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %ymm0
; FMA-NEXT:    vfnmadd231ps {{.*#+}} ymm0 = -(ymm0 * mem) + ymm0
; FMA-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfnmadd.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %a) nounwind
  ret <8 x float> %res
}

define <8 x float> @test_x86_fnmadd_bba_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_bba_ps_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rdx), %ymm0
; FMA-NEXT:    vfnmadd213ps {{.*#+}} ymm0 = -(ymm0 * ymm0) + mem
; FMA-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfnmadd.ps.256(<8 x float> %b, <8 x float> %b, <8 x float> %a) nounwind
  ret <8 x float> %res
}

declare <2 x double> @llvm.x86.fma.vfnmadd.sd(<2 x double>, <2 x double>, <2 x double>) nounwind readnone
define <2 x double> @test_x86_fnmadd_baa_sd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_baa_sd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rdx), %xmm0
; FMA-NEXT:    vmovsd {{.*#+}} xmm1 = mem[0],zero
; FMA-NEXT:    vfnmadd213sd {{.*#+}} xmm0 = -(xmm1 * xmm0) + xmm1
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmadd.sd(<2 x double> %b, <2 x double> %a, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fnmadd_aba_sd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_aba_sd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %xmm0
; FMA-NEXT:    vfnmadd132sd {{.*#+}} xmm0 = -(xmm0 * mem) + xmm0
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmadd.sd(<2 x double> %a, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fnmadd_bba_sd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_bba_sd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rdx), %xmm0
; FMA-NEXT:    vfnmadd213sd {{.*#+}} xmm0 = -(xmm0 * xmm0) + mem
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmadd.sd(<2 x double> %b, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

declare <2 x double> @llvm.x86.fma.vfnmadd.pd(<2 x double>, <2 x double>, <2 x double>) nounwind readnone
define <2 x double> @test_x86_fnmadd_baa_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_baa_pd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %xmm0
; FMA-NEXT:    vfnmadd132pd {{.*#+}} xmm0 = -(xmm0 * mem) + xmm0
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmadd.pd(<2 x double> %b, <2 x double> %a, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fnmadd_aba_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_aba_pd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %xmm0
; FMA-NEXT:    vfnmadd231pd {{.*#+}} xmm0 = -(xmm0 * mem) + xmm0
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmadd.pd(<2 x double> %a, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fnmadd_bba_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_bba_pd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rdx), %xmm0
; FMA-NEXT:    vfnmadd213pd {{.*#+}} xmm0 = -(xmm0 * xmm0) + mem
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmadd.pd(<2 x double> %b, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

declare <4 x double> @llvm.x86.fma.vfnmadd.pd.256(<4 x double>, <4 x double>, <4 x double>) nounwind readnone
define <4 x double> @test_x86_fnmadd_baa_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_baa_pd_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %ymm0
; FMA-NEXT:    vfnmadd132pd {{.*#+}} ymm0 = -(ymm0 * mem) + ymm0
; FMA-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfnmadd.pd.256(<4 x double> %b, <4 x double> %a, <4 x double> %a) nounwind
  ret <4 x double> %res
}

define <4 x double> @test_x86_fnmadd_aba_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_aba_pd_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %ymm0
; FMA-NEXT:    vfnmadd231pd {{.*#+}} ymm0 = -(ymm0 * mem) + ymm0
; FMA-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfnmadd.pd.256(<4 x double> %a, <4 x double> %b, <4 x double> %a) nounwind
  ret <4 x double> %res
}

define <4 x double> @test_x86_fnmadd_bba_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmadd_bba_pd_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rdx), %ymm0
; FMA-NEXT:    vfnmadd213pd {{.*#+}} ymm0 = -(ymm0 * ymm0) + mem
; FMA-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfnmadd.pd.256(<4 x double> %b, <4 x double> %b, <4 x double> %a) nounwind
  ret <4 x double> %res
}

declare <4 x float> @llvm.x86.fma.vfmsub.ss(<4 x float>, <4 x float>, <4 x float>) nounwind readnone
define <4 x float> @test_x86_fmsub_baa_ss(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fmsub_baa_ss:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rdx), %xmm0
; FMA-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; FMA-NEXT:    vfmsub213ss {{.*#+}} xmm0 = (xmm1 * xmm0) - xmm1
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmsub.ss(<4 x float> %b, <4 x float> %a, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fmsub_aba_ss(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fmsub_aba_ss:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %xmm0
; FMA-NEXT:    vfmsub132ss {{.*#+}} xmm0 = (xmm0 * mem) - xmm0
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmsub.ss(<4 x float> %a, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fmsub_bba_ss(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fmsub_bba_ss:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rdx), %xmm0
; FMA-NEXT:    vfmsub213ss {{.*#+}} xmm0 = (xmm0 * xmm0) - mem
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmsub.ss(<4 x float> %b, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

declare <4 x float> @llvm.x86.fma.vfmsub.ps(<4 x float>, <4 x float>, <4 x float>) nounwind readnone
define <4 x float> @test_x86_fmsub_baa_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fmsub_baa_ps:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %xmm0
; FMA-NEXT:    vfmsub132ps {{.*#+}} xmm0 = (xmm0 * mem) - xmm0
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmsub.ps(<4 x float> %b, <4 x float> %a, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fmsub_aba_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fmsub_aba_ps:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %xmm0
; FMA-NEXT:    vfmsub231ps {{.*#+}} xmm0 = (xmm0 * mem) - xmm0
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmsub.ps(<4 x float> %a, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fmsub_bba_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fmsub_bba_ps:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rdx), %xmm0
; FMA-NEXT:    vfmsub213ps {{.*#+}} xmm0 = (xmm0 * xmm0) - mem
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfmsub.ps(<4 x float> %b, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

declare <8 x float> @llvm.x86.fma.vfmsub.ps.256(<8 x float>, <8 x float>, <8 x float>) nounwind readnone
define <8 x float> @test_x86_fmsub_baa_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA-LABEL: test_x86_fmsub_baa_ps_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %ymm0
; FMA-NEXT:    vfmsub132ps {{.*#+}} ymm0 = (ymm0 * mem) - ymm0
; FMA-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfmsub.ps.256(<8 x float> %b, <8 x float> %a, <8 x float> %a) nounwind
  ret <8 x float> %res
}

define <8 x float> @test_x86_fmsub_aba_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA-LABEL: test_x86_fmsub_aba_ps_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %ymm0
; FMA-NEXT:    vfmsub231ps {{.*#+}} ymm0 = (ymm0 * mem) - ymm0
; FMA-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfmsub.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %a) nounwind
  ret <8 x float> %res
}

define <8 x float> @test_x86_fmsub_bba_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA-LABEL: test_x86_fmsub_bba_ps_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rdx), %ymm0
; FMA-NEXT:    vfmsub213ps {{.*#+}} ymm0 = (ymm0 * ymm0) - mem
; FMA-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfmsub.ps.256(<8 x float> %b, <8 x float> %b, <8 x float> %a) nounwind
  ret <8 x float> %res
}

declare <2 x double> @llvm.x86.fma.vfmsub.sd(<2 x double>, <2 x double>, <2 x double>) nounwind readnone
define <2 x double> @test_x86_fmsub_baa_sd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fmsub_baa_sd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rdx), %xmm0
; FMA-NEXT:    vmovsd {{.*#+}} xmm1 = mem[0],zero
; FMA-NEXT:    vfmsub213sd {{.*#+}} xmm0 = (xmm1 * xmm0) - xmm1
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmsub.sd(<2 x double> %b, <2 x double> %a, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fmsub_aba_sd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fmsub_aba_sd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %xmm0
; FMA-NEXT:    vfmsub132sd {{.*#+}} xmm0 = (xmm0 * mem) - xmm0
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmsub.sd(<2 x double> %a, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fmsub_bba_sd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fmsub_bba_sd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rdx), %xmm0
; FMA-NEXT:    vfmsub213sd {{.*#+}} xmm0 = (xmm0 * xmm0) - mem
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmsub.sd(<2 x double> %b, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

declare <2 x double> @llvm.x86.fma.vfmsub.pd(<2 x double>, <2 x double>, <2 x double>) nounwind readnone
define <2 x double> @test_x86_fmsub_baa_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fmsub_baa_pd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %xmm0
; FMA-NEXT:    vfmsub132pd {{.*#+}} xmm0 = (xmm0 * mem) - xmm0
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmsub.pd(<2 x double> %b, <2 x double> %a, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fmsub_aba_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fmsub_aba_pd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %xmm0
; FMA-NEXT:    vfmsub231pd {{.*#+}} xmm0 = (xmm0 * mem) - xmm0
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmsub.pd(<2 x double> %a, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fmsub_bba_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fmsub_bba_pd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rdx), %xmm0
; FMA-NEXT:    vfmsub213pd {{.*#+}} xmm0 = (xmm0 * xmm0) - mem
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfmsub.pd(<2 x double> %b, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

declare <4 x double> @llvm.x86.fma.vfmsub.pd.256(<4 x double>, <4 x double>, <4 x double>) nounwind readnone
define <4 x double> @test_x86_fmsub_baa_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA-LABEL: test_x86_fmsub_baa_pd_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %ymm0
; FMA-NEXT:    vfmsub132pd {{.*#+}} ymm0 = (ymm0 * mem) - ymm0
; FMA-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfmsub.pd.256(<4 x double> %b, <4 x double> %a, <4 x double> %a) nounwind
  ret <4 x double> %res
}

define <4 x double> @test_x86_fmsub_aba_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA-LABEL: test_x86_fmsub_aba_pd_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %ymm0
; FMA-NEXT:    vfmsub231pd {{.*#+}} ymm0 = (ymm0 * mem) - ymm0
; FMA-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfmsub.pd.256(<4 x double> %a, <4 x double> %b, <4 x double> %a) nounwind
  ret <4 x double> %res
}

define <4 x double> @test_x86_fmsub_bba_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA-LABEL: test_x86_fmsub_bba_pd_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rdx), %ymm0
; FMA-NEXT:    vfmsub213pd {{.*#+}} ymm0 = (ymm0 * ymm0) - mem
; FMA-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfmsub.pd.256(<4 x double> %b, <4 x double> %b, <4 x double> %a) nounwind
  ret <4 x double> %res
}


declare <4 x float> @llvm.x86.fma.vfnmsub.ss(<4 x float>, <4 x float>, <4 x float>) nounwind readnone
define <4 x float> @test_x86_fnmsub_baa_ss(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_baa_ss:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rdx), %xmm0
; FMA-NEXT:    vmovss {{.*#+}} xmm1 = mem[0],zero,zero,zero
; FMA-NEXT:    vfnmsub213ss {{.*#+}} xmm0 = -(xmm1 * xmm0) - xmm1
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmsub.ss(<4 x float> %b, <4 x float> %a, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fnmsub_aba_ss(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_aba_ss:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %xmm0
; FMA-NEXT:    vfnmsub132ss {{.*#+}} xmm0 = -(xmm0 * mem) - xmm0
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmsub.ss(<4 x float> %a, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fnmsub_bba_ss(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_bba_ss:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rdx), %xmm0
; FMA-NEXT:    vfnmsub213ss {{.*#+}} xmm0 = -(xmm0 * xmm0) - mem
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmsub.ss(<4 x float> %b, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

declare <4 x float> @llvm.x86.fma.vfnmsub.ps(<4 x float>, <4 x float>, <4 x float>) nounwind readnone
define <4 x float> @test_x86_fnmsub_baa_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_baa_ps:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %xmm0
; FMA-NEXT:    vfnmsub132ps {{.*#+}} xmm0 = -(xmm0 * mem) - xmm0
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmsub.ps(<4 x float> %b, <4 x float> %a, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fnmsub_aba_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_aba_ps:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %xmm0
; FMA-NEXT:    vfnmsub231ps {{.*#+}} xmm0 = -(xmm0 * mem) - xmm0
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmsub.ps(<4 x float> %a, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

define <4 x float> @test_x86_fnmsub_bba_ps(<4 x float> %a, <4 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_bba_ps:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rdx), %xmm0
; FMA-NEXT:    vfnmsub213ps {{.*#+}} xmm0 = -(xmm0 * xmm0) - mem
; FMA-NEXT:    retq
  %res = call <4 x float> @llvm.x86.fma.vfnmsub.ps(<4 x float> %b, <4 x float> %b, <4 x float> %a) nounwind
  ret <4 x float> %res
}

declare <8 x float> @llvm.x86.fma.vfnmsub.ps.256(<8 x float>, <8 x float>, <8 x float>) nounwind readnone
define <8 x float> @test_x86_fnmsub_baa_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_baa_ps_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %ymm0
; FMA-NEXT:    vfnmsub132ps {{.*#+}} ymm0 = -(ymm0 * mem) - ymm0
; FMA-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfnmsub.ps.256(<8 x float> %b, <8 x float> %a, <8 x float> %a) nounwind
  ret <8 x float> %res
}

define <8 x float> @test_x86_fnmsub_aba_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_aba_ps_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rcx), %ymm0
; FMA-NEXT:    vfnmsub231ps {{.*#+}} ymm0 = -(ymm0 * mem) - ymm0
; FMA-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfnmsub.ps.256(<8 x float> %a, <8 x float> %b, <8 x float> %a) nounwind
  ret <8 x float> %res
}

define <8 x float> @test_x86_fnmsub_bba_ps_y(<8 x float> %a, <8 x float> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_bba_ps_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovaps (%rdx), %ymm0
; FMA-NEXT:    vfnmsub213ps {{.*#+}} ymm0 = -(ymm0 * ymm0) - mem
; FMA-NEXT:    retq
  %res = call <8 x float> @llvm.x86.fma.vfnmsub.ps.256(<8 x float> %b, <8 x float> %b, <8 x float> %a) nounwind
  ret <8 x float> %res
}

declare <2 x double> @llvm.x86.fma.vfnmsub.sd(<2 x double>, <2 x double>, <2 x double>) nounwind readnone
define <2 x double> @test_x86_fnmsub_baa_sd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_baa_sd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rdx), %xmm0
; FMA-NEXT:    vmovsd {{.*#+}} xmm1 = mem[0],zero
; FMA-NEXT:    vfnmsub213sd {{.*#+}} xmm0 = -(xmm1 * xmm0) - xmm1
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmsub.sd(<2 x double> %b, <2 x double> %a, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fnmsub_aba_sd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_aba_sd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %xmm0
; FMA-NEXT:    vfnmsub132sd {{.*#+}} xmm0 = -(xmm0 * mem) - xmm0
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmsub.sd(<2 x double> %a, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fnmsub_bba_sd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_bba_sd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rdx), %xmm0
; FMA-NEXT:    vfnmsub213sd {{.*#+}} xmm0 = -(xmm0 * xmm0) - mem
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmsub.sd(<2 x double> %b, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

declare <2 x double> @llvm.x86.fma.vfnmsub.pd(<2 x double>, <2 x double>, <2 x double>) nounwind readnone
define <2 x double> @test_x86_fnmsub_baa_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_baa_pd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %xmm0
; FMA-NEXT:    vfnmsub132pd {{.*#+}} xmm0 = -(xmm0 * mem) - xmm0
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmsub.pd(<2 x double> %b, <2 x double> %a, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fnmsub_aba_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_aba_pd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %xmm0
; FMA-NEXT:    vfnmsub231pd {{.*#+}} xmm0 = -(xmm0 * mem) - xmm0
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmsub.pd(<2 x double> %a, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

define <2 x double> @test_x86_fnmsub_bba_pd(<2 x double> %a, <2 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_bba_pd:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rdx), %xmm0
; FMA-NEXT:    vfnmsub213pd {{.*#+}} xmm0 = -(xmm0 * xmm0) - mem
; FMA-NEXT:    retq
  %res = call <2 x double> @llvm.x86.fma.vfnmsub.pd(<2 x double> %b, <2 x double> %b, <2 x double> %a) nounwind
  ret <2 x double> %res
}

declare <4 x double> @llvm.x86.fma.vfnmsub.pd.256(<4 x double>, <4 x double>, <4 x double>) nounwind readnone
define <4 x double> @test_x86_fnmsub_baa_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_baa_pd_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %ymm0
; FMA-NEXT:    vfnmsub132pd {{.*#+}} ymm0 = -(ymm0 * mem) - ymm0
; FMA-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfnmsub.pd.256(<4 x double> %b, <4 x double> %a, <4 x double> %a) nounwind
  ret <4 x double> %res
}

define <4 x double> @test_x86_fnmsub_aba_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_aba_pd_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rcx), %ymm0
; FMA-NEXT:    vfnmsub231pd {{.*#+}} ymm0 = -(ymm0 * mem) - ymm0
; FMA-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfnmsub.pd.256(<4 x double> %a, <4 x double> %b, <4 x double> %a) nounwind
  ret <4 x double> %res
}

define <4 x double> @test_x86_fnmsub_bba_pd_y(<4 x double> %a, <4 x double> %b) #0 {
; FMA-LABEL: test_x86_fnmsub_bba_pd_y:
; FMA:       # %bb.0:
; FMA-NEXT:    vmovapd (%rdx), %ymm0
; FMA-NEXT:    vfnmsub213pd {{.*#+}} ymm0 = -(ymm0 * ymm0) - mem
; FMA-NEXT:    retq
  %res = call <4 x double> @llvm.x86.fma.vfnmsub.pd.256(<4 x double> %b, <4 x double> %b, <4 x double> %a) nounwind
  ret <4 x double> %res
}

