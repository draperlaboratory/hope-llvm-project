; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mcpu=corei7 -mattr=-f16c | FileCheck %s -check-prefix=CHECK -check-prefix=LIBCALL
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mcpu=corei7 -mattr=+f16c | FileCheck %s -check-prefix=CHECK -check-prefix=F16C
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mcpu=corei7 -mattr=-f16c,+soft-float | FileCheck %s -check-prefix=CHECK -check-prefix=SOFTFLOAT
; RUN: llc < %s -mtriple=x86_64-unknown-linux-gnu -mcpu=corei7 -mattr=+f16c,+soft-float | FileCheck %s -check-prefix=CHECK -check-prefix=SOFTFLOAT

; This is a test for float to half float conversions on x86-64.
;
; If flag -soft-float is set, or if there is no F16C support, then:
; 1) half float to float conversions are
;    translated into calls to __gnu_h2f_ieee defined
;    by the compiler runtime library;
; 2) float to half float conversions are translated into calls
;    to __gnu_f2h_ieee which expected to be defined by the
;    compiler runtime library.
;
; Otherwise (we have F16C support):
; 1) half float to float conversion are translated using
;    vcvtph2ps instructions;
; 2) float to half float conversions are translated using
;    vcvtps2ph instructions


define void @test1(float %src, i16* %dest) {
; LIBCALL-LABEL: test1:
; LIBCALL:       # %bb.0:
; LIBCALL-NEXT:    pushq %rbx
; LIBCALL-NEXT:    .cfi_def_cfa_offset 16
; LIBCALL-NEXT:    .cfi_offset %rbx, -16
; LIBCALL-NEXT:    movq %rdi, %rbx
; LIBCALL-NEXT:    callq __gnu_f2h_ieee
; LIBCALL-NEXT:    movw %ax, (%rbx)
; LIBCALL-NEXT:    popq %rbx
; LIBCALL-NEXT:    .cfi_def_cfa_offset 8
; LIBCALL-NEXT:    retq
;
; F16C-LABEL: test1:
; F16C:       # %bb.0:
; F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; F16C-NEXT:    vpextrw $0, %xmm0, (%rdi)
; F16C-NEXT:    retq
;
; SOFTFLOAT-LABEL: test1:
; SOFTFLOAT:       # %bb.0:
; SOFTFLOAT-NEXT:    pushq %rbx
; SOFTFLOAT-NEXT:    .cfi_def_cfa_offset 16
; SOFTFLOAT-NEXT:    .cfi_offset %rbx, -16
; SOFTFLOAT-NEXT:    movq %rsi, %rbx
; SOFTFLOAT-NEXT:    callq __gnu_f2h_ieee
; SOFTFLOAT-NEXT:    movw %ax, (%rbx)
; SOFTFLOAT-NEXT:    popq %rbx
; SOFTFLOAT-NEXT:    .cfi_def_cfa_offset 8
; SOFTFLOAT-NEXT:    retq
  %1 = tail call i16 @llvm.convert.to.fp16.f32(float %src)
  store i16 %1, i16* %dest, align 2
  ret void
}

define float @test2(i16* nocapture %src) {
; LIBCALL-LABEL: test2:
; LIBCALL:       # %bb.0:
; LIBCALL-NEXT:    movzwl (%rdi), %edi
; LIBCALL-NEXT:    jmp __gnu_h2f_ieee # TAILCALL
;
; F16C-LABEL: test2:
; F16C:       # %bb.0:
; F16C-NEXT:    movzwl (%rdi), %eax
; F16C-NEXT:    vmovd %eax, %xmm0
; F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; F16C-NEXT:    retq
;
; SOFTFLOAT-LABEL: test2:
; SOFTFLOAT:       # %bb.0:
; SOFTFLOAT-NEXT:    pushq %rax
; SOFTFLOAT-NEXT:    .cfi_def_cfa_offset 16
; SOFTFLOAT-NEXT:    movzwl (%rdi), %edi
; SOFTFLOAT-NEXT:    callq __gnu_h2f_ieee
; SOFTFLOAT-NEXT:    popq %rcx
; SOFTFLOAT-NEXT:    .cfi_def_cfa_offset 8
; SOFTFLOAT-NEXT:    retq
  %1 = load i16, i16* %src, align 2
  %2 = tail call float @llvm.convert.from.fp16.f32(i16 %1)
  ret float %2
}

define float @test3(float %src) nounwind uwtable readnone {
; LIBCALL-LABEL: test3:
; LIBCALL:       # %bb.0:
; LIBCALL-NEXT:    pushq %rax
; LIBCALL-NEXT:    .cfi_def_cfa_offset 16
; LIBCALL-NEXT:    callq __gnu_f2h_ieee
; LIBCALL-NEXT:    movzwl %ax, %edi
; LIBCALL-NEXT:    popq %rax
; LIBCALL-NEXT:    .cfi_def_cfa_offset 8
; LIBCALL-NEXT:    jmp __gnu_h2f_ieee # TAILCALL
;
; F16C-LABEL: test3:
; F16C:       # %bb.0:
; F16C-NEXT:    vcvtps2ph $4, %xmm0, %xmm0
; F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; F16C-NEXT:    retq
;
; SOFTFLOAT-LABEL: test3:
; SOFTFLOAT:       # %bb.0:
; SOFTFLOAT-NEXT:    pushq %rax
; SOFTFLOAT-NEXT:    .cfi_def_cfa_offset 16
; SOFTFLOAT-NEXT:    callq __gnu_f2h_ieee
; SOFTFLOAT-NEXT:    movzwl %ax, %edi
; SOFTFLOAT-NEXT:    callq __gnu_h2f_ieee
; SOFTFLOAT-NEXT:    popq %rcx
; SOFTFLOAT-NEXT:    .cfi_def_cfa_offset 8
; SOFTFLOAT-NEXT:    retq
  %1 = tail call i16 @llvm.convert.to.fp16.f32(float %src)
  %2 = tail call float @llvm.convert.from.fp16.f32(i16 %1)
  ret float %2
}

define double @test4(i16* nocapture %src) {
; LIBCALL-LABEL: test4:
; LIBCALL:       # %bb.0:
; LIBCALL-NEXT:    pushq %rax
; LIBCALL-NEXT:    .cfi_def_cfa_offset 16
; LIBCALL-NEXT:    movzwl (%rdi), %edi
; LIBCALL-NEXT:    callq __gnu_h2f_ieee
; LIBCALL-NEXT:    cvtss2sd %xmm0, %xmm0
; LIBCALL-NEXT:    popq %rax
; LIBCALL-NEXT:    .cfi_def_cfa_offset 8
; LIBCALL-NEXT:    retq
;
; F16C-LABEL: test4:
; F16C:       # %bb.0:
; F16C-NEXT:    movzwl (%rdi), %eax
; F16C-NEXT:    vmovd %eax, %xmm0
; F16C-NEXT:    vcvtph2ps %xmm0, %xmm0
; F16C-NEXT:    vcvtss2sd %xmm0, %xmm0, %xmm0
; F16C-NEXT:    retq
;
; SOFTFLOAT-LABEL: test4:
; SOFTFLOAT:       # %bb.0:
; SOFTFLOAT-NEXT:    pushq %rax
; SOFTFLOAT-NEXT:    .cfi_def_cfa_offset 16
; SOFTFLOAT-NEXT:    movzwl (%rdi), %edi
; SOFTFLOAT-NEXT:    callq __gnu_h2f_ieee
; SOFTFLOAT-NEXT:    movl %eax, %edi
; SOFTFLOAT-NEXT:    callq __extendsfdf2
; SOFTFLOAT-NEXT:    popq %rcx
; SOFTFLOAT-NEXT:    .cfi_def_cfa_offset 8
; SOFTFLOAT-NEXT:    retq
  %1 = load i16, i16* %src, align 2
  %2 = tail call double @llvm.convert.from.fp16.f64(i16 %1)
  ret double %2
}

define i16 @test5(double %src) {
; LIBCALL-LABEL: test5:
; LIBCALL:       # %bb.0:
; LIBCALL-NEXT:    jmp __truncdfhf2 # TAILCALL
;
; F16C-LABEL: test5:
; F16C:       # %bb.0:
; F16C-NEXT:    jmp __truncdfhf2 # TAILCALL
;
; SOFTFLOAT-LABEL: test5:
; SOFTFLOAT:       # %bb.0:
; SOFTFLOAT-NEXT:    pushq %rax
; SOFTFLOAT-NEXT:    .cfi_def_cfa_offset 16
; SOFTFLOAT-NEXT:    callq __truncdfhf2
; SOFTFLOAT-NEXT:    popq %rcx
; SOFTFLOAT-NEXT:    .cfi_def_cfa_offset 8
; SOFTFLOAT-NEXT:    retq
  %val = tail call i16 @llvm.convert.to.fp16.f64(double %src)
  ret i16 %val
}

declare float @llvm.convert.from.fp16.f32(i16) nounwind readnone
declare i16 @llvm.convert.to.fp16.f32(float) nounwind readnone
declare double @llvm.convert.from.fp16.f64(i16) nounwind readnone
declare i16 @llvm.convert.to.fp16.f64(double) nounwind readnone
