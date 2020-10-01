; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=aarch64-linux-gnu -mattr=+sve < %s 2>%t | FileCheck %s
; RUN: FileCheck --check-prefix=WARN --allow-empty %s <%t

; If this check fails please read test/CodeGen/AArch64/README for instructions on how to resolve it.
; WARN-NOT: warning

define <vscale x 8 x half> @fadd_nxv8f16(<vscale x 8 x half> %a, <vscale x 8 x half> %b) {
; CHECK-LABEL: fadd_nxv8f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd z0.h, z0.h, z1.h
; CHECK-NEXT:    ret
  %res = fadd <vscale x 8 x half> %a, %b
  ret <vscale x 8 x half> %res
}

define <vscale x 4 x half> @fadd_nxv4f16(<vscale x 4 x half> %a, <vscale x 4 x half> %b) {
; CHECK-LABEL: fadd_nxv4f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.s
; CHECK-NEXT:    fadd z0.h, p0/m, z0.h, z1.h
; CHECK-NEXT:    ret
  %res = fadd <vscale x 4 x half> %a, %b
  ret <vscale x 4 x half> %res
}

define <vscale x 2 x half> @fadd_nxv2f16(<vscale x 2 x half> %a, <vscale x 2 x half> %b) {
; CHECK-LABEL: fadd_nxv2f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fadd z0.h, p0/m, z0.h, z1.h
; CHECK-NEXT:    ret
  %res = fadd <vscale x 2 x half> %a, %b
  ret <vscale x 2 x half> %res
}

define <vscale x 4 x float> @fadd_nxv4f32(<vscale x 4 x float> %a, <vscale x 4 x float> %b) {
; CHECK-LABEL: fadd_nxv4f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd z0.s, z0.s, z1.s
; CHECK-NEXT:    ret
  %res = fadd <vscale x 4 x float> %a, %b
  ret <vscale x 4 x float> %res
}

define <vscale x 2 x float> @fadd_nxv2f32(<vscale x 2 x float> %a, <vscale x 2 x float> %b) {
; CHECK-LABEL: fadd_nxv2f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fadd z0.s, p0/m, z0.s, z1.s
; CHECK-NEXT:    ret
  %res = fadd <vscale x 2 x float> %a, %b
  ret <vscale x 2 x float> %res
}

define <vscale x 2 x double> @fadd_nxv2f64(<vscale x 2 x double> %a, <vscale x 2 x double> %b) {
; CHECK-LABEL: fadd_nxv2f64:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fadd z0.d, z0.d, z1.d
; CHECK-NEXT:    ret
  %res = fadd <vscale x 2 x double> %a, %b
  ret <vscale x 2 x double> %res
}

define <vscale x 8 x half> @fdiv_nxv8f16(<vscale x 8 x half> %a, <vscale x 8 x half> %b) {
; CHECK-LABEL: fdiv_nxv8f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.h
; CHECK-NEXT:    fdiv z0.h, p0/m, z0.h, z1.h
; CHECK-NEXT:    ret
  %res = fdiv <vscale x 8 x half> %a, %b
  ret <vscale x 8 x half> %res
}

define <vscale x 4 x half> @fdiv_nxv4f16(<vscale x 4 x half> %a, <vscale x 4 x half> %b) {
; CHECK-LABEL: fdiv_nxv4f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.s
; CHECK-NEXT:    fdiv z0.h, p0/m, z0.h, z1.h
; CHECK-NEXT:    ret
  %res = fdiv <vscale x 4 x half> %a, %b
  ret <vscale x 4 x half> %res
}

define <vscale x 2 x half> @fdiv_nxv2f16(<vscale x 2 x half> %a, <vscale x 2 x half> %b) {
; CHECK-LABEL: fdiv_nxv2f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fdiv z0.h, p0/m, z0.h, z1.h
; CHECK-NEXT:    ret
  %res = fdiv <vscale x 2 x half> %a, %b
  ret <vscale x 2 x half> %res
}

define <vscale x 4 x float> @fdiv_nxv4f32(<vscale x 4 x float> %a, <vscale x 4 x float> %b) {
; CHECK-LABEL: fdiv_nxv4f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.s
; CHECK-NEXT:    fdiv z0.s, p0/m, z0.s, z1.s
; CHECK-NEXT:    ret
  %res = fdiv <vscale x 4 x float> %a, %b
  ret <vscale x 4 x float> %res
}

define <vscale x 2 x float> @fdiv_nxv2f32(<vscale x 2 x float> %a, <vscale x 2 x float> %b) {
; CHECK-LABEL: fdiv_nxv2f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fdiv z0.s, p0/m, z0.s, z1.s
; CHECK-NEXT:    ret
  %res = fdiv <vscale x 2 x float> %a, %b
  ret <vscale x 2 x float> %res
}

define <vscale x 2 x double> @fdiv_nxv2f64(<vscale x 2 x double> %a, <vscale x 2 x double> %b) {
; CHECK-LABEL: fdiv_nxv2f64:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fdiv z0.d, p0/m, z0.d, z1.d
; CHECK-NEXT:    ret
  %res = fdiv <vscale x 2 x double> %a, %b
  ret <vscale x 2 x double> %res
}

define <vscale x 8 x half> @fsub_nxv8f16(<vscale x 8 x half> %a, <vscale x 8 x half> %b) {
; CHECK-LABEL: fsub_nxv8f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fsub z0.h, z0.h, z1.h
; CHECK-NEXT:    ret
  %res = fsub <vscale x 8 x half> %a, %b
  ret <vscale x 8 x half> %res
}

define <vscale x 4 x half> @fsub_nxv4f16(<vscale x 4 x half> %a, <vscale x 4 x half> %b) {
; CHECK-LABEL: fsub_nxv4f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.s
; CHECK-NEXT:    fsub z0.h, p0/m, z0.h, z1.h
; CHECK-NEXT:    ret
  %res = fsub <vscale x 4 x half> %a, %b
  ret <vscale x 4 x half> %res
}

define <vscale x 2 x half> @fsub_nxv2f16(<vscale x 2 x half> %a, <vscale x 2 x half> %b) {
; CHECK-LABEL: fsub_nxv2f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fsub z0.h, p0/m, z0.h, z1.h
; CHECK-NEXT:    ret
  %res = fsub <vscale x 2 x half> %a, %b
  ret <vscale x 2 x half> %res
}

define <vscale x 4 x float> @fsub_nxv4f32(<vscale x 4 x float> %a, <vscale x 4 x float> %b) {
; CHECK-LABEL: fsub_nxv4f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fsub z0.s, z0.s, z1.s
; CHECK-NEXT:    ret
  %res = fsub <vscale x 4 x float> %a, %b
  ret <vscale x 4 x float> %res
}

define <vscale x 2 x float> @fsub_nxv2f32(<vscale x 2 x float> %a, <vscale x 2 x float> %b) {
; CHECK-LABEL: fsub_nxv2f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fsub z0.s, p0/m, z0.s, z1.s
; CHECK-NEXT:    ret
  %res = fsub <vscale x 2 x float> %a, %b
  ret <vscale x 2 x float> %res
}

define <vscale x 2 x double> @fsub_nxv2f64(<vscale x 2 x double> %a, <vscale x 2 x double> %b) {
; CHECK-LABEL: fsub_nxv2f64:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fsub z0.d, z0.d, z1.d
; CHECK-NEXT:    ret
  %res = fsub <vscale x 2 x double> %a, %b
  ret <vscale x 2 x double> %res
}

define <vscale x 8 x half> @fmul_nxv8f16(<vscale x 8 x half> %a, <vscale x 8 x half> %b) {
; CHECK-LABEL: fmul_nxv8f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmul z0.h, z0.h, z1.h
; CHECK-NEXT:    ret
  %res = fmul <vscale x 8 x half> %a, %b
  ret <vscale x 8 x half> %res
}

define <vscale x 4 x half> @fmul_nxv4f16(<vscale x 4 x half> %a, <vscale x 4 x half> %b) {
; CHECK-LABEL: fmul_nxv4f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.s
; CHECK-NEXT:    fmul z0.h, p0/m, z0.h, z1.h
; CHECK-NEXT:    ret
  %res = fmul <vscale x 4 x half> %a, %b
  ret <vscale x 4 x half> %res
}

define <vscale x 2 x half> @fmul_nxv2f16(<vscale x 2 x half> %a, <vscale x 2 x half> %b) {
; CHECK-LABEL: fmul_nxv2f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fmul z0.h, p0/m, z0.h, z1.h
; CHECK-NEXT:    ret
  %res = fmul <vscale x 2 x half> %a, %b
  ret <vscale x 2 x half> %res
}

define <vscale x 4 x float> @fmul_nxv4f32(<vscale x 4 x float> %a, <vscale x 4 x float> %b) {
; CHECK-LABEL: fmul_nxv4f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmul z0.s, z0.s, z1.s
; CHECK-NEXT:    ret
  %res = fmul <vscale x 4 x float> %a, %b
  ret <vscale x 4 x float> %res
}

define <vscale x 2 x float> @fmul_nxv2f32(<vscale x 2 x float> %a, <vscale x 2 x float> %b) {
; CHECK-LABEL: fmul_nxv2f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fmul z0.s, p0/m, z0.s, z1.s
; CHECK-NEXT:    ret
  %res = fmul <vscale x 2 x float> %a, %b
  ret <vscale x 2 x float> %res
}

define <vscale x 2 x double> @fmul_nxv2f64(<vscale x 2 x double> %a, <vscale x 2 x double> %b) {
; CHECK-LABEL: fmul_nxv2f64:
; CHECK:       // %bb.0:
; CHECK-NEXT:    fmul z0.d, z0.d, z1.d
; CHECK-NEXT:    ret
  %res = fmul <vscale x 2 x double> %a, %b
  ret <vscale x 2 x double> %res
}

define <vscale x 8 x half> @fma_nxv8f16(<vscale x 8 x half> %a, <vscale x 8 x half> %b, <vscale x 8 x half> %c) {
; CHECK-LABEL: fma_nxv8f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.h
; CHECK-NEXT:    fmla z2.h, p0/m, z0.h, z1.h
; CHECK-NEXT:    mov z0.d, z2.d
; CHECK-NEXT:    ret
  %r = call <vscale x 8 x half> @llvm.fma.nxv8f16(<vscale x 8 x half> %a, <vscale x 8 x half> %b, <vscale x 8 x half> %c)
  ret <vscale x 8 x half> %r
}

define <vscale x 4 x half> @fma_nxv4f16(<vscale x 4 x half> %a, <vscale x 4 x half> %b, <vscale x 4 x half> %c) {
; CHECK-LABEL: fma_nxv4f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.s
; CHECK-NEXT:    fmla z2.h, p0/m, z0.h, z1.h
; CHECK-NEXT:    mov z0.d, z2.d
; CHECK-NEXT:    ret
  %r = call <vscale x 4 x half> @llvm.fma.nxv4f16(<vscale x 4 x half> %a, <vscale x 4 x half> %b, <vscale x 4 x half> %c)
  ret <vscale x 4 x half> %r
}

define <vscale x 2 x half> @fma_nxv2f16(<vscale x 2 x half> %a, <vscale x 2 x half> %b, <vscale x 2 x half> %c) {
; CHECK-LABEL: fma_nxv2f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fmla z2.h, p0/m, z0.h, z1.h
; CHECK-NEXT:    mov z0.d, z2.d
; CHECK-NEXT:    ret
  %r = call <vscale x 2 x half> @llvm.fma.nxv2f16(<vscale x 2 x half> %a, <vscale x 2 x half> %b, <vscale x 2 x half> %c)
  ret <vscale x 2 x half> %r
}

define <vscale x 4 x float> @fma_nxv4f32(<vscale x 4 x float> %a, <vscale x 4 x float> %b, <vscale x 4 x float> %c) {
; CHECK-LABEL: fma_nxv4f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.s
; CHECK-NEXT:    fmla z2.s, p0/m, z0.s, z1.s
; CHECK-NEXT:    mov z0.d, z2.d
; CHECK-NEXT:    ret
  %r = call <vscale x 4 x float> @llvm.fma.nxv4f32(<vscale x 4 x float> %a, <vscale x 4 x float> %b, <vscale x 4 x float> %c)
  ret <vscale x 4 x float> %r
}

define <vscale x 2 x float> @fma_nxv2f32(<vscale x 2 x float> %a, <vscale x 2 x float> %b, <vscale x 2 x float> %c) {
; CHECK-LABEL: fma_nxv2f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fmla z2.s, p0/m, z0.s, z1.s
; CHECK-NEXT:    mov z0.d, z2.d
; CHECK-NEXT:    ret
  %r = call <vscale x 2 x float> @llvm.fma.nxv2f32(<vscale x 2 x float> %a, <vscale x 2 x float> %b, <vscale x 2 x float> %c)
  ret <vscale x 2 x float> %r
}

define <vscale x 2 x double> @fma_nxv2f64_1(<vscale x 2 x double> %a, <vscale x 2 x double> %b, <vscale x 2 x double> %c) {
; CHECK-LABEL: fma_nxv2f64_1:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fmla z2.d, p0/m, z0.d, z1.d
; CHECK-NEXT:    mov z0.d, z2.d
; CHECK-NEXT:    ret
  %r = call <vscale x 2 x double> @llvm.fma.nxv2f64(<vscale x 2 x double> %a, <vscale x 2 x double> %b, <vscale x 2 x double> %c)
  ret <vscale x 2 x double> %r
}

define <vscale x 2 x double> @fma_nxv2f64_2(<vscale x 2 x double> %a, <vscale x 2 x double> %b, <vscale x 2 x double> %c) {
; CHECK-LABEL: fma_nxv2f64_2:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fmla z2.d, p0/m, z1.d, z0.d
; CHECK-NEXT:    mov z0.d, z2.d
; CHECK-NEXT:    ret
  %r = call <vscale x 2 x double> @llvm.fma.nxv2f64(<vscale x 2 x double> %b, <vscale x 2 x double> %a, <vscale x 2 x double> %c)
  ret <vscale x 2 x double> %r
}

define <vscale x 2 x double> @fma_nxv2f64_3(<vscale x 2 x double> %a, <vscale x 2 x double> %b, <vscale x 2 x double> %c) {
; CHECK-LABEL: fma_nxv2f64_3:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fmla z0.d, p0/m, z2.d, z1.d
; CHECK-NEXT:    ret
  %r = call <vscale x 2 x double> @llvm.fma.nxv2f64(<vscale x 2 x double> %c, <vscale x 2 x double> %b, <vscale x 2 x double> %a)
  ret <vscale x 2 x double> %r
}

define <vscale x 8 x half> @fneg_nxv8f16(<vscale x 8 x half> %a) {
; CHECK-LABEL: fneg_nxv8f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.h
; CHECK-NEXT:    fneg z0.h, p0/m, z0.h
; CHECK-NEXT:    ret
  %minus.one = insertelement <vscale x 8 x half> undef, half -1.0, i64 0
  %minus.one.vec = shufflevector <vscale x 8 x half> %minus.one, <vscale x 8 x half> undef, <vscale x 8 x i32> zeroinitializer
  %neg = fmul <vscale x 8 x half> %a, %minus.one.vec
  ret <vscale x 8 x half> %neg
}

define <vscale x 4 x half> @fneg_nxv4f16(<vscale x 4 x half> %a) {
; CHECK-LABEL: fneg_nxv4f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.s
; CHECK-NEXT:    fneg z0.h, p0/m, z0.h
; CHECK-NEXT:    ret
  %minus.one = insertelement <vscale x 4 x half> undef, half -1.0, i64 0
  %minus.one.vec = shufflevector <vscale x 4 x half> %minus.one, <vscale x 4 x half> undef, <vscale x 4 x i32> zeroinitializer
  %neg = fmul <vscale x 4 x half> %a, %minus.one.vec
  ret <vscale x 4 x half> %neg
}

define <vscale x 2 x half> @fneg_nxv2f16(<vscale x 2 x half> %a) {
; CHECK-LABEL: fneg_nxv2f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fneg z0.h, p0/m, z0.h
; CHECK-NEXT:    ret
  %minus.one = insertelement <vscale x 2 x half> undef, half -1.0, i64 0
  %minus.one.vec = shufflevector <vscale x 2 x half> %minus.one, <vscale x 2 x half> undef, <vscale x 2 x i32> zeroinitializer
  %neg = fmul <vscale x 2 x half> %a, %minus.one.vec
  ret <vscale x 2 x half> %neg
}

define <vscale x 4 x float> @fneg_nxv4f32(<vscale x 4 x float> %a) {
; CHECK-LABEL: fneg_nxv4f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.s
; CHECK-NEXT:    fneg z0.s, p0/m, z0.s
; CHECK-NEXT:    ret
  %minus.one = insertelement <vscale x 4 x float> undef, float -1.0, i64 0
  %minus.one.vec = shufflevector <vscale x 4 x float> %minus.one, <vscale x 4 x float> undef, <vscale x 4 x i32> zeroinitializer
  %neg = fmul <vscale x 4 x float> %a, %minus.one.vec
  ret <vscale x 4 x float> %neg
}

define <vscale x 2 x float> @fneg_nxv2f32(<vscale x 2 x float> %a) {
; CHECK-LABEL: fneg_nxv2f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fneg z0.s, p0/m, z0.s
; CHECK-NEXT:    ret
  %minus.one = insertelement <vscale x 2 x float> undef, float -1.0, i64 0
  %minus.one.vec = shufflevector <vscale x 2 x float> %minus.one, <vscale x 2 x float> undef, <vscale x 2 x i32> zeroinitializer
  %neg = fmul <vscale x 2 x float> %a, %minus.one.vec
  ret <vscale x 2 x float> %neg
}

define <vscale x 2 x double> @fneg_nxv2f64(<vscale x 2 x double> %a) {
; CHECK-LABEL: fneg_nxv2f64:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fneg z0.d, p0/m, z0.d
; CHECK-NEXT:    ret
  %minus.one = insertelement <vscale x 2 x double> undef, double -1.0, i64 0
  %minus.one.vec = shufflevector <vscale x 2 x double> %minus.one, <vscale x 2 x double> undef, <vscale x 2 x i32> zeroinitializer
  %neg = fmul <vscale x 2 x double> %a, %minus.one.vec
  ret <vscale x 2 x double> %neg
}

define <vscale x 8 x half> @frecps_h(<vscale x 8 x half> %a, <vscale x 8 x half> %b) {
; CHECK-LABEL: frecps_h:
; CHECK:       // %bb.0:
; CHECK-NEXT:    frecps z0.h, z0.h, z1.h
; CHECK-NEXT:    ret
  %res = call <vscale x 8 x half> @llvm.aarch64.sve.frecps.x.nxv8f16(<vscale x 8 x half> %a, <vscale x 8 x half> %b)
  ret <vscale x 8 x half> %res
}

define <vscale x 4 x float> @frecps_s(<vscale x 4 x float> %a, <vscale x 4 x float> %b) {
; CHECK-LABEL: frecps_s:
; CHECK:       // %bb.0:
; CHECK-NEXT:    frecps z0.s, z0.s, z1.s
; CHECK-NEXT:    ret
  %res = call <vscale x 4 x float> @llvm.aarch64.sve.frecps.x.nxv4f32(<vscale x 4 x float> %a, <vscale x 4 x float> %b)
  ret <vscale x 4 x float> %res
}

define <vscale x 2 x double> @frecps_d(<vscale x 2 x double> %a, <vscale x 2 x double> %b) {
; CHECK-LABEL: frecps_d:
; CHECK:       // %bb.0:
; CHECK-NEXT:    frecps z0.d, z0.d, z1.d
; CHECK-NEXT:    ret
  %res = call <vscale x 2 x double> @llvm.aarch64.sve.frecps.x.nxv2f64(<vscale x 2 x double> %a, <vscale x 2 x double> %b)
  ret <vscale x 2 x double> %res
}

define <vscale x 8 x half> @frsqrts_h(<vscale x 8 x half> %a, <vscale x 8 x half> %b) {
; CHECK-LABEL: frsqrts_h:
; CHECK:       // %bb.0:
; CHECK-NEXT:    frsqrts z0.h, z0.h, z1.h
; CHECK-NEXT:    ret
  %res = call <vscale x 8 x half> @llvm.aarch64.sve.frsqrts.x.nxv8f16(<vscale x 8 x half> %a, <vscale x 8 x half> %b)
  ret <vscale x 8 x half> %res
}

define <vscale x 4 x float> @frsqrts_s(<vscale x 4 x float> %a, <vscale x 4 x float> %b) {
; CHECK-LABEL: frsqrts_s:
; CHECK:       // %bb.0:
; CHECK-NEXT:    frsqrts z0.s, z0.s, z1.s
; CHECK-NEXT:    ret
  %res = call <vscale x 4 x float> @llvm.aarch64.sve.frsqrts.x.nxv4f32(<vscale x 4 x float> %a, <vscale x 4 x float> %b)
  ret <vscale x 4 x float> %res
}

define <vscale x 2 x double> @frsqrts_d(<vscale x 2 x double> %a, <vscale x 2 x double> %b) {
; CHECK-LABEL: frsqrts_d:
; CHECK:       // %bb.0:
; CHECK-NEXT:    frsqrts z0.d, z0.d, z1.d
; CHECK-NEXT:    ret
  %res = call <vscale x 2 x double> @llvm.aarch64.sve.frsqrts.x.nxv2f64(<vscale x 2 x double> %a, <vscale x 2 x double> %b)
  ret <vscale x 2 x double> %res
}

%complex = type { { double, double } }

define void @scalar_to_vector(%complex* %outval, <vscale x 2 x i1> %pred, <vscale x 2 x double> %in1, <vscale x 2 x double> %in2) {
; CHECK-LABEL: scalar_to_vector:
; CHECK:       // %bb.0:
; CHECK-NEXT:    faddv d0, p0, z0.d
; CHECK-NEXT:    faddv d1, p0, z1.d
; CHECK-NEXT:    mov v0.d[1], v1.d[0]
; CHECK-NEXT:    str q0, [x0]
; CHECK-NEXT:    ret
  %realp = getelementptr inbounds %complex, %complex* %outval, i64 0, i32 0, i32 0
  %imagp = getelementptr inbounds %complex, %complex* %outval, i64 0, i32 0, i32 1
  %1 = call double @llvm.aarch64.sve.faddv.nxv2f64(<vscale x 2 x i1> %pred, <vscale x 2 x double> %in1)
  %2 = call double @llvm.aarch64.sve.faddv.nxv2f64(<vscale x 2 x i1> %pred, <vscale x 2 x double> %in2)
  store double %1, double* %realp, align 8
  store double %2, double* %imagp, align 8
  ret void
}

define void @float_copy(<vscale x 4 x float>* %P1, <vscale x 4 x float>* %P2) {
; CHECK-LABEL: float_copy:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.s
; CHECK-NEXT:    ld1w { z0.s }, p0/z, [x0]
; CHECK-NEXT:    st1w { z0.s }, p0, [x1]
; CHECK-NEXT:    ret
  %A = load <vscale x 4 x float>, <vscale x 4 x float>* %P1, align 16
  store <vscale x 4 x float> %A, <vscale x 4 x float>* %P2, align 16
  ret void
}

; FSQRT

define <vscale x 8 x half> @fsqrt_nxv8f16(<vscale x 8 x half> %a) {
; CHECK-LABEL: fsqrt_nxv8f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.h
; CHECK-NEXT:    fsqrt z0.h, p0/m, z0.h
; CHECK-NEXT:    ret
  %res = call <vscale x 8 x half> @llvm.sqrt.nxv8f16(<vscale x 8 x half> %a)
  ret <vscale x 8 x half> %res
}

define <vscale x 4 x half> @fsqrt_nxv4f16(<vscale x 4 x half> %a) {
; CHECK-LABEL: fsqrt_nxv4f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.s
; CHECK-NEXT:    fsqrt z0.h, p0/m, z0.h
; CHECK-NEXT:    ret
  %res = call <vscale x 4 x half> @llvm.sqrt.nxv4f16(<vscale x 4 x half> %a)
  ret <vscale x 4 x half> %res
}

define <vscale x 2 x half> @fsqrt_nxv2f16(<vscale x 2 x half> %a) {
; CHECK-LABEL: fsqrt_nxv2f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fsqrt z0.h, p0/m, z0.h
; CHECK-NEXT:    ret
  %res = call <vscale x 2 x half> @llvm.sqrt.nxv2f16(<vscale x 2 x half> %a)
  ret <vscale x 2 x half> %res
}

define <vscale x 4 x float> @fsqrt_nxv4f32(<vscale x 4 x float> %a) {
; CHECK-LABEL: fsqrt_nxv4f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.s
; CHECK-NEXT:    fsqrt z0.s, p0/m, z0.s
; CHECK-NEXT:    ret
  %res = call <vscale x 4 x float> @llvm.sqrt.nxv4f32(<vscale x 4 x float> %a)
  ret <vscale x 4 x float> %res
}

define <vscale x 2 x float> @fsqrt_nxv2f32(<vscale x 2 x float> %a) {
; CHECK-LABEL: fsqrt_nxv2f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fsqrt z0.s, p0/m, z0.s
; CHECK-NEXT:    ret
  %res = call <vscale x 2 x float> @llvm.sqrt.nxv2f32(<vscale x 2 x float> %a)
  ret <vscale x 2 x float> %res
}

define <vscale x 2 x double> @fsqrt_nxv2f64(<vscale x 2 x double> %a) {
; CHECK-LABEL: fsqrt_nxv2f64:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fsqrt z0.d, p0/m, z0.d
; CHECK-NEXT:    ret
  %res = call <vscale x 2 x double> @llvm.sqrt.nxv2f64(<vscale x 2 x double> %a)
  ret <vscale x 2 x double> %res
}

; FABS

define <vscale x 8 x half> @fabs_nxv8f16(<vscale x 8 x half> %a) {
; CHECK-LABEL: fabs_nxv8f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.h
; CHECK-NEXT:    fabs z0.h, p0/m, z0.h
; CHECK-NEXT:    ret
  %res = call <vscale x 8 x half> @llvm.fabs.nxv8f16(<vscale x 8 x half> %a)
  ret <vscale x 8 x half> %res
}

define <vscale x 4 x half> @fabs_nxv4f16(<vscale x 4 x half> %a) {
; CHECK-LABEL: fabs_nxv4f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.s
; CHECK-NEXT:    fabs z0.h, p0/m, z0.h
; CHECK-NEXT:    ret
  %res = call <vscale x 4 x half> @llvm.fabs.nxv4f16(<vscale x 4 x half> %a)
  ret <vscale x 4 x half> %res
}

define <vscale x 2 x half> @fabs_nxv2f16(<vscale x 2 x half> %a) {
; CHECK-LABEL: fabs_nxv2f16:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fabs z0.h, p0/m, z0.h
; CHECK-NEXT:    ret
  %res = call <vscale x 2 x half> @llvm.fabs.nxv2f16(<vscale x 2 x half> %a)
  ret <vscale x 2 x half> %res
}

define <vscale x 4 x float> @fabs_nxv4f32(<vscale x 4 x float> %a) {
; CHECK-LABEL: fabs_nxv4f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.s
; CHECK-NEXT:    fabs z0.s, p0/m, z0.s
; CHECK-NEXT:    ret
  %res = call <vscale x 4 x float> @llvm.fabs.nxv4f32(<vscale x 4 x float> %a)
  ret <vscale x 4 x float> %res
}

define <vscale x 2 x float> @fabs_nxv2f32(<vscale x 2 x float> %a) {
; CHECK-LABEL: fabs_nxv2f32:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fabs z0.s, p0/m, z0.s
; CHECK-NEXT:    ret
  %res = call <vscale x 2 x float> @llvm.fabs.nxv2f32(<vscale x 2 x float> %a)
  ret <vscale x 2 x float> %res
}

define <vscale x 2 x double> @fabs_nxv2f64(<vscale x 2 x double> %a) {
; CHECK-LABEL: fabs_nxv2f64:
; CHECK:       // %bb.0:
; CHECK-NEXT:    ptrue p0.d
; CHECK-NEXT:    fabs z0.d, p0/m, z0.d
; CHECK-NEXT:    ret
  %res = call <vscale x 2 x double> @llvm.fabs.nxv2f64(<vscale x 2 x double> %a)
  ret <vscale x 2 x double> %res
}

declare <vscale x 8 x half> @llvm.aarch64.sve.frecps.x.nxv8f16(<vscale x 8 x half>, <vscale x 8 x half>)
declare <vscale x 4 x float>  @llvm.aarch64.sve.frecps.x.nxv4f32(<vscale x 4 x float> , <vscale x 4 x float>)
declare <vscale x 2 x double> @llvm.aarch64.sve.frecps.x.nxv2f64(<vscale x 2 x double>, <vscale x 2 x double>)

declare <vscale x 8 x half> @llvm.aarch64.sve.frsqrts.x.nxv8f16(<vscale x 8 x half>, <vscale x 8 x half>)
declare <vscale x 4 x float> @llvm.aarch64.sve.frsqrts.x.nxv4f32(<vscale x 4 x float>, <vscale x 4 x float>)
declare <vscale x 2 x double> @llvm.aarch64.sve.frsqrts.x.nxv2f64(<vscale x 2 x double>, <vscale x 2 x double>)

declare <vscale x 2 x double> @llvm.fma.nxv2f64(<vscale x 2 x double>, <vscale x 2 x double>, <vscale x 2 x double>)
declare <vscale x 4 x float> @llvm.fma.nxv4f32(<vscale x 4 x float>, <vscale x 4 x float>, <vscale x 4 x float>)
declare <vscale x 2 x float> @llvm.fma.nxv2f32(<vscale x 2 x float>, <vscale x 2 x float>, <vscale x 2 x float>)
declare <vscale x 8 x half> @llvm.fma.nxv8f16(<vscale x 8 x half>, <vscale x 8 x half>, <vscale x 8 x half>)
declare <vscale x 4 x half> @llvm.fma.nxv4f16(<vscale x 4 x half>, <vscale x 4 x half>, <vscale x 4 x half>)
declare <vscale x 2 x half> @llvm.fma.nxv2f16(<vscale x 2 x half>, <vscale x 2 x half>, <vscale x 2 x half>)

declare <vscale x 8 x half> @llvm.sqrt.nxv8f16( <vscale x 8 x half>)
declare <vscale x 4 x half> @llvm.sqrt.nxv4f16( <vscale x 4 x half>)
declare <vscale x 2 x half> @llvm.sqrt.nxv2f16( <vscale x 2 x half>)
declare <vscale x 4 x float> @llvm.sqrt.nxv4f32(<vscale x 4 x float>)
declare <vscale x 2 x float> @llvm.sqrt.nxv2f32(<vscale x 2 x float>)
declare <vscale x 2 x double> @llvm.sqrt.nxv2f64(<vscale x 2 x double>)

declare <vscale x 8 x half> @llvm.fabs.nxv8f16( <vscale x 8 x half>)
declare <vscale x 4 x half> @llvm.fabs.nxv4f16( <vscale x 4 x half>)
declare <vscale x 2 x half> @llvm.fabs.nxv2f16( <vscale x 2 x half>)
declare <vscale x 4 x float> @llvm.fabs.nxv4f32(<vscale x 4 x float>)
declare <vscale x 2 x float> @llvm.fabs.nxv2f32(<vscale x 2 x float>)
declare <vscale x 2 x double> @llvm.fabs.nxv2f64(<vscale x 2 x double>)

; Function Attrs: nounwind readnone
declare double @llvm.aarch64.sve.faddv.nxv2f64(<vscale x 2 x i1>, <vscale x 2 x double>) #2
