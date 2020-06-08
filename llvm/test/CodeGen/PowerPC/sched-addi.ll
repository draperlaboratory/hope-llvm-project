; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -mtriple=powerpc64le-unknown-linux-gnu -mcpu=pwr9 < %s | FileCheck -check-prefix=CHECK-P9 %s
; RUN: llc -verify-machineinstrs -mtriple=powerpc64le-unknown-linux-gnu -mcpu=pwr9 -ppc-postra-bias-addi=false < %s |\
; RUN:   FileCheck -check-prefix=CHECK-P9-NO-HEURISTIC %s

%_type_of_scalars = type <{ [16 x i8], double, [152 x i8] }>
%_elem_type_of_x = type <{ double }>
%_elem_type_of_a = type <{ double }>

@scalars = common local_unnamed_addr global %_type_of_scalars zeroinitializer, align 16

define void @test([0 x %_elem_type_of_x]* noalias %.x, [0 x %_elem_type_of_a]* %.a, i64* noalias %.n) {
; CHECK-P9-LABEL: test:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    ld 5, 0(5)
; CHECK-P9-NEXT:    addis 6, 2, scalars@toc@ha
; CHECK-P9-NEXT:    addi 6, 6, scalars@toc@l
; CHECK-P9-NEXT:    addi 6, 6, 16
; CHECK-P9-NEXT:    rldicr 5, 5, 0, 58
; CHECK-P9-NEXT:    addi 5, 5, -32
; CHECK-P9-NEXT:    rldicl 5, 5, 59, 5
; CHECK-P9-NEXT:    addi 5, 5, 1
; CHECK-P9-NEXT:    lxvdsx 0, 0, 6
; CHECK-P9-NEXT:    mtctr 5
; CHECK-P9-NEXT:    .p2align 4
; CHECK-P9-NEXT:  .LBB0_1: # %vector.body
; CHECK-P9-NEXT:    #
; CHECK-P9-NEXT:    lxv 1, 16(4)
; CHECK-P9-NEXT:    lxv 2, 0(4)
; CHECK-P9-NEXT:    lxv 3, 48(4)
; CHECK-P9-NEXT:    lxv 4, 32(4)
; CHECK-P9-NEXT:    xvmuldp 2, 2, 0
; CHECK-P9-NEXT:    lxv 5, 240(4)
; CHECK-P9-NEXT:    lxv 6, 224(4)
; CHECK-P9-NEXT:    xvmuldp 1, 1, 0
; CHECK-P9-NEXT:    xvmuldp 4, 4, 0
; CHECK-P9-NEXT:    xvmuldp 3, 3, 0
; CHECK-P9-NEXT:    xvmuldp 5, 5, 0
; CHECK-P9-NEXT:    stxv 1, 16(3)
; CHECK-P9-NEXT:    stxv 3, 48(3)
; CHECK-P9-NEXT:    stxv 4, 32(3)
; CHECK-P9-NEXT:    stxv 5, 240(3)
; CHECK-P9-NEXT:    addi 4, 4, 256
; CHECK-P9-NEXT:    xvmuldp 6, 6, 0
; CHECK-P9-NEXT:    stxv 2, 0(3)
; CHECK-P9-NEXT:    stxv 6, 224(3)
; CHECK-P9-NEXT:    addi 3, 3, 256
; CHECK-P9-NEXT:    bdnz .LBB0_1
; CHECK-P9-NEXT:  # %bb.2: # %return.block
; CHECK-P9-NEXT:    blr
;
; CHECK-P9-NO-HEURISTIC-LABEL: test:
; CHECK-P9-NO-HEURISTIC:       # %bb.0: # %entry
; CHECK-P9-NO-HEURISTIC-NEXT:    ld 5, 0(5)
; CHECK-P9-NO-HEURISTIC-NEXT:    addis 6, 2, scalars@toc@ha
; CHECK-P9-NO-HEURISTIC-NEXT:    addi 6, 6, scalars@toc@l
; CHECK-P9-NO-HEURISTIC-NEXT:    rldicr 5, 5, 0, 58
; CHECK-P9-NO-HEURISTIC-NEXT:    addi 6, 6, 16
; CHECK-P9-NO-HEURISTIC-NEXT:    addi 5, 5, -32
; CHECK-P9-NO-HEURISTIC-NEXT:    rldicl 5, 5, 59, 5
; CHECK-P9-NO-HEURISTIC-NEXT:    addi 5, 5, 1
; CHECK-P9-NO-HEURISTIC-NEXT:    lxvdsx 0, 0, 6
; CHECK-P9-NO-HEURISTIC-NEXT:    mtctr 5
; CHECK-P9-NO-HEURISTIC-NEXT:    .p2align 4
; CHECK-P9-NO-HEURISTIC-NEXT:  .LBB0_1: # %vector.body
; CHECK-P9-NO-HEURISTIC-NEXT:    #
; CHECK-P9-NO-HEURISTIC-NEXT:    lxv 1, 16(4)
; CHECK-P9-NO-HEURISTIC-NEXT:    lxv 2, 0(4)
; CHECK-P9-NO-HEURISTIC-NEXT:    lxv 3, 48(4)
; CHECK-P9-NO-HEURISTIC-NEXT:    lxv 4, 32(4)
; CHECK-P9-NO-HEURISTIC-NEXT:    xvmuldp 2, 2, 0
; CHECK-P9-NO-HEURISTIC-NEXT:    lxv 5, 240(4)
; CHECK-P9-NO-HEURISTIC-NEXT:    lxv 6, 224(4)
; CHECK-P9-NO-HEURISTIC-NEXT:    xvmuldp 1, 1, 0
; CHECK-P9-NO-HEURISTIC-NEXT:    xvmuldp 4, 4, 0
; CHECK-P9-NO-HEURISTIC-NEXT:    xvmuldp 3, 3, 0
; CHECK-P9-NO-HEURISTIC-NEXT:    xvmuldp 6, 6, 0
; CHECK-P9-NO-HEURISTIC-NEXT:    xvmuldp 5, 5, 0
; CHECK-P9-NO-HEURISTIC-NEXT:    stxv 1, 16(3)
; CHECK-P9-NO-HEURISTIC-NEXT:    stxv 2, 0(3)
; CHECK-P9-NO-HEURISTIC-NEXT:    stxv 3, 48(3)
; CHECK-P9-NO-HEURISTIC-NEXT:    stxv 4, 32(3)
; CHECK-P9-NO-HEURISTIC-NEXT:    stxv 5, 240(3)
; CHECK-P9-NO-HEURISTIC-NEXT:    stxv 6, 224(3)
; CHECK-P9-NO-HEURISTIC-NEXT:    addi 4, 4, 256
; CHECK-P9-NO-HEURISTIC-NEXT:    addi 3, 3, 256
; CHECK-P9-NO-HEURISTIC-NEXT:    bdnz .LBB0_1
; CHECK-P9-NO-HEURISTIC-NEXT:  # %bb.2: # %return.block
; CHECK-P9-NO-HEURISTIC-NEXT:    blr
entry:
  %x_rvo_based_addr_3 = getelementptr inbounds [0 x %_elem_type_of_x], [0 x %_elem_type_of_x]* %.x, i64 0, i64 -1
  %a_rvo_based_addr_5 = getelementptr inbounds [0 x %_elem_type_of_a], [0 x %_elem_type_of_a]* %.a, i64 0, i64 -1
  %_val_n_ = load i64, i64* %.n, align 8
  %_val_c1_ = load double, double* getelementptr inbounds (%_type_of_scalars, %_type_of_scalars* @scalars, i64 0, i32 1), align 16
  %n.vec = and i64 %_val_n_, -32
  %broadcast.splatinsert26 = insertelement <4 x double> undef, double %_val_c1_, i32 0
  %broadcast.splat27 = shufflevector <4 x double> %broadcast.splatinsert26, <4 x double> undef, <4 x i32> zeroinitializer
  br label %vector.body

vector.body:
  %index = phi i64 [ 0, %entry ], [ %index.next, %vector.body ]
   %offset.idx = or i64 %index, 1
  %0 = getelementptr %_elem_type_of_x, %_elem_type_of_x* %x_rvo_based_addr_3, i64 %offset.idx, i32 0
  %1 = getelementptr %_elem_type_of_a, %_elem_type_of_a* %a_rvo_based_addr_5, i64 %offset.idx, i32 0
  %2 = bitcast double* %1 to <4 x double>*
  %wide.load = load <4 x double>, <4 x double>* %2, align 8
  %3 = getelementptr double, double* %1, i64 4
  %4 = bitcast double* %3 to <4 x double>*
  %wide.load19 = load <4 x double>, <4 x double>* %4, align 8
  %5 = getelementptr double, double* %1, i64 8
  %6 = bitcast double* %5 to <4 x double>*
  %wide.load20 = load <4 x double>, <4 x double>* %6, align 8
  %7 = getelementptr double, double* %1, i64 12
  %8 = bitcast double* %7 to <4 x double>*
  %wide.load21 = load <4 x double>, <4 x double>* %8, align 8
  %9 = getelementptr double, double* %1, i64 16
  %10 = bitcast double* %9 to <4 x double>*
  %wide.load22 = load <4 x double>, <4 x double>* %10, align 8
  %11 = getelementptr double, double* %1, i64 20
  %12 = bitcast double* %11 to <4 x double>*
  %wide.load23 = load <4 x double>, <4 x double>* %12, align 8
  %13 = getelementptr double, double* %1, i64 24
  %14 = bitcast double* %13 to <4 x double>*
  %wide.load24 = load <4 x double>, <4 x double>* %14, align 8
  %15 = getelementptr double, double* %1, i64 28
  %16 = bitcast double* %15 to <4 x double>*
  %wide.load25 = load <4 x double>, <4 x double>* %16, align 8
  %17 = fmul fast <4 x double> %wide.load, %broadcast.splat27
  %18 = fmul fast <4 x double> %wide.load19, %broadcast.splat27
  %19 = fmul fast <4 x double> %wide.load20, %broadcast.splat27
  %20 = fmul fast <4 x double> %wide.load21, %broadcast.splat27
  %21 = fmul fast <4 x double> %wide.load22, %broadcast.splat27
  %22 = fmul fast <4 x double> %wide.load23, %broadcast.splat27
  %23 = fmul fast <4 x double> %wide.load24, %broadcast.splat27
  %24 = fmul fast <4 x double> %wide.load25, %broadcast.splat27
  %25 = bitcast double* %0 to <4 x double>*
  store <4 x double> %17, <4 x double>* %25, align 8
  %26 = getelementptr double, double* %0, i64 4
  %27 = bitcast double* %26 to <4 x double>*
  store <4 x double> %18, <4 x double>* %27, align 8
  %28 = getelementptr double, double* %0, i64 8
  %29 = bitcast double* %28 to <4 x double>*
  %30 = getelementptr double, double* %0, i64 12
  %31 = bitcast double* %30 to <4 x double>*
  %32 = getelementptr double, double* %0, i64 16
  %33 = bitcast double* %32 to <4 x double>*
  %34 = getelementptr double, double* %0, i64 20
  %35 = bitcast double* %34 to <4 x double>*
  %36 = getelementptr double, double* %0, i64 24
  %37 = bitcast double* %36 to <4 x double>*
  %38 = getelementptr double, double* %0, i64 28
  %39 = bitcast double* %38 to <4 x double>*
  store <4 x double> %24, <4 x double>* %39, align 8
  %index.next = add i64 %index, 32
  %cm = icmp eq i64 %index.next, %n.vec
  br i1 %cm, label %return.block, label %vector.body

return.block:
  ret void
}

