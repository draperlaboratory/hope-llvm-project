; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-pc-elfiamcu | FileCheck %s

%struct.st12_t = type { i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, i32 }

define i32 @test_ints(i32 %a, i32 %b, i32 %c, i32 %d) #0 {
; CHECK-LABEL: test_ints:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addl %edx, %eax
; CHECK-NEXT:    imull %ecx, %eax
; CHECK-NEXT:    addl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    retl
entry:
  %r1 = add i32 %b, %a
  %r2 = mul i32 %c, %r1
  %r3 = add i32 %d, %r2
  ret i32 %r3
}

define i32 @test_floats(i32 %a, i32 %b, float %c, float %d) #0 {
; CHECK-LABEL: test_floats:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addl %edx, %eax
; CHECK-NEXT:    imull %ecx, %eax
; CHECK-NEXT:    addl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    retl
entry:
  %ci = bitcast float %c to i32
  %di = bitcast float %d to i32
  %r1 = add i32 %b, %a
  %r2 = mul i32 %ci, %r1
  %r3 = add i32 %di, %r2
  ret i32 %r3
}

define double @test_doubles(double %d1, double %d2) #0 {
; CHECK-LABEL: test_doubles:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    adcl {{[0-9]+}}(%esp), %edx
; CHECK-NEXT:    retl
entry:
    %d1i = bitcast double %d1 to i64
    %d2i = bitcast double %d2 to i64
    %r = add i64 %d1i, %d2i
    %rd = bitcast i64 %r to double
    ret double %rd
}

define double @test_mixed_doubles(double %d2, i32 %i) #0 {
; CHECK-LABEL: test_mixed_doubles:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    addl %ecx, %eax
; CHECK-NEXT:    adcl $0, %edx
; CHECK-NEXT:    retl
entry:
    %iext = zext i32 %i to i64
    %d2i = bitcast double %d2 to i64
    %r = add i64 %iext, %d2i
    %rd = bitcast i64 %r to double
    ret double %rd
}

define void @ret_large_struct(%struct.st12_t* noalias nocapture sret(%struct.st12_t) %agg.result, %struct.st12_t* byval(%struct.st12_t) nocapture readonly align 4 %r) #0 {
; CHECK-LABEL: ret_large_struct:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pushl %esi
; CHECK-NEXT:    movl %eax, %esi
; CHECK-NEXT:    leal {{[0-9]+}}(%esp), %edx
; CHECK-NEXT:    movl $48, %ecx
; CHECK-NEXT:    calll memcpy
; CHECK-NEXT:    movl %esi, %eax
; CHECK-NEXT:    popl %esi
; CHECK-NEXT:    retl
entry:
  %0 = bitcast %struct.st12_t* %agg.result to i8*
  %1 = bitcast %struct.st12_t* %r to i8*
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %0, i8* %1, i32 48, i1 false)
  ret void
}

define i32 @var_args(i32 %i1, ...) #0 {
; CHECK-LABEL: var_args:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    retl
entry:
  ret i32 %i1
}

%struct.S = type { i8 }

define i32 @test_lib_args(float %a, float %b) #0 {
; CHECK-LABEL: test_lib_args:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edx, %eax
; CHECK-NEXT:    calll __fixsfsi
; CHECK-NEXT:    retl
  %ret = fptosi float %b to i32
  ret i32 %ret
}

define i32 @test_fp128(fp128* %ptr) #0 {
; CHECK-LABEL: test_fp128:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pushl 12(%eax)
; CHECK-NEXT:    pushl 8(%eax)
; CHECK-NEXT:    pushl 4(%eax)
; CHECK-NEXT:    pushl (%eax)
; CHECK-NEXT:    calll __fixtfsi
; CHECK-NEXT:    addl $16, %esp
; CHECK-NEXT:    retl
  %v = load fp128, fp128* %ptr
  %ret = fptosi fp128 %v to i32
  ret i32 %ret
}

declare void @llvm.memcpy.p0i8.p0i8.i32(i8* nocapture, i8* nocapture readonly, i32, i1) #1

define void @test_alignment_d() #0 {
; CHECK-LABEL: test_alignment_d:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    subl $8, %esp
; CHECK-NEXT:    movl $1073741824, {{[0-9]+}}(%esp) # imm = 0x40000000
; CHECK-NEXT:    movl $0, (%esp)
; CHECK-NEXT:    movl %esp, %eax
; CHECK-NEXT:    calll food
; CHECK-NEXT:    addl $8, %esp
; CHECK-NEXT:    retl
entry:
  %d = alloca double
  store double 2.000000e+00, double* %d
  call void @food(double* inreg %d)
  ret void
}

define void @test_alignment_i() #0 {
; CHECK-LABEL: test_alignment_i:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    subl $8, %esp
; CHECK-NEXT:    movl $0, {{[0-9]+}}(%esp)
; CHECK-NEXT:    movl $2, (%esp)
; CHECK-NEXT:    movl %esp, %eax
; CHECK-NEXT:    calll fooi
; CHECK-NEXT:    addl $8, %esp
; CHECK-NEXT:    retl
entry:
  %i = alloca i64
  store i64 2, i64* %i
  call void @fooi(i64* inreg %i)
  ret void
}

define void @test_alignment_s() #0 {
; CHECK-LABEL: test_alignment_s:
; CHECK:       # %bb.0:
; CHECK-NEXT:    pushl %eax
; CHECK-NEXT:    movl %esp, %eax
; CHECK-NEXT:    calll foos
; CHECK-NEXT:    popl %eax
; CHECK-NEXT:    retl
  %s = alloca %struct.S, align 4
  call void @foos(%struct.S* inreg %s)
  ret void
}

define void @test_alignment_fp() #0 {
; CHECK-LABEL: test_alignment_fp:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    subl $16, %esp
; CHECK-NEXT:    movl $1073741824, {{[0-9]+}}(%esp) # imm = 0x40000000
; CHECK-NEXT:    movl $0, {{[0-9]+}}(%esp)
; CHECK-NEXT:    movl $0, {{[0-9]+}}(%esp)
; CHECK-NEXT:    movl $0, (%esp)
; CHECK-NEXT:    movl %esp, %eax
; CHECK-NEXT:    calll foofp
; CHECK-NEXT:    addl $16, %esp
; CHECK-NEXT:    retl
entry:
  %f = alloca fp128
  store fp128 0xL00000000000000004000000000000000, fp128* %f
  call void @foofp(fp128* inreg %f)
  ret void
}

declare void @food(double* inreg)
declare void @fooi(i64* inreg)
declare void @foos(%struct.S* inreg)
declare void @foofp(fp128* inreg)

attributes #0 = { nounwind "use-soft-float"="true"}
attributes #1 = { nounwind argmemonly }
