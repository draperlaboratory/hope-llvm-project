; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -vector-combine -S -mtriple=x86_64-- -mattr=sse2 | FileCheck %s
; RUN: opt < %s -vector-combine -S -mtriple=x86_64-- -mattr=avx2 | FileCheck %s

declare void @use(<4 x i32>)
declare void @usef(<4 x float>)

; Eliminating an insert is profitable.

define <16 x i1> @ins0_ins0_i8(i8 %x, i8 %y) {
; CHECK-LABEL: @ins0_ins0_i8(
; CHECK-NEXT:    [[R_SCALAR:%.*]] = icmp eq i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = insertelement <16 x i1> undef, i1 [[R_SCALAR]], i64 0
; CHECK-NEXT:    ret <16 x i1> [[R]]
;
  %i0 = insertelement <16 x i8> undef, i8 %x, i32 0
  %i1 = insertelement <16 x i8> undef, i8 %y, i32 0
  %r = icmp eq <16 x i8> %i0, %i1
  ret <16 x i1> %r
}

; Eliminating an insert is still profitable. Mismatch types on index is ok.

define <8 x i1> @ins5_ins5_i16(i16 %x, i16 %y) {
; CHECK-LABEL: @ins5_ins5_i16(
; CHECK-NEXT:    [[R_SCALAR:%.*]] = icmp sgt i16 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = insertelement <8 x i1> undef, i1 [[R_SCALAR]], i64 5
; CHECK-NEXT:    ret <8 x i1> [[R]]
;
  %i0 = insertelement <8 x i16> undef, i16 %x, i8 5
  %i1 = insertelement <8 x i16> undef, i16 %y, i32 5
  %r = icmp sgt <8 x i16> %i0, %i1
  ret <8 x i1> %r
}

; The new vector constant is calculated by constant folding.

define <2 x i1> @ins1_ins1_i64(i64 %x, i64 %y) {
; CHECK-LABEL: @ins1_ins1_i64(
; CHECK-NEXT:    [[R_SCALAR:%.*]] = icmp sle i64 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = insertelement <2 x i1> <i1 true, i1 false>, i1 [[R_SCALAR]], i64 1
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %i0 = insertelement <2 x i64> zeroinitializer, i64 %x, i64 1
  %i1 = insertelement <2 x i64> <i64 1, i64 -1>, i64 %y, i32 1
  %r = icmp sle <2 x i64> %i0, %i1
  ret <2 x i1> %r
}

; The inserts are free, but it's still better to scalarize.

define <2 x i1> @ins0_ins0_f64(double %x, double %y) {
; CHECK-LABEL: @ins0_ins0_f64(
; CHECK-NEXT:    [[R_SCALAR:%.*]] = fcmp nnan ninf uge double [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = insertelement <2 x i1> <i1 true, i1 true>, i1 [[R_SCALAR]], i64 0
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %i0 = insertelement <2 x double> undef, double %x, i32 0
  %i1 = insertelement <2 x double> undef, double %y, i32 0
  %r = fcmp nnan ninf uge <2 x double> %i0, %i1
  ret <2 x i1> %r
}

; Negative test - mismatched indexes (but could fold this).

define <16 x i1> @ins1_ins0_i8(i8 %x, i8 %y) {
; CHECK-LABEL: @ins1_ins0_i8(
; CHECK-NEXT:    [[I0:%.*]] = insertelement <16 x i8> undef, i8 [[X:%.*]], i32 1
; CHECK-NEXT:    [[I1:%.*]] = insertelement <16 x i8> undef, i8 [[Y:%.*]], i32 0
; CHECK-NEXT:    [[R:%.*]] = icmp sle <16 x i8> [[I0]], [[I1]]
; CHECK-NEXT:    ret <16 x i1> [[R]]
;
  %i0 = insertelement <16 x i8> undef, i8 %x, i32 1
  %i1 = insertelement <16 x i8> undef, i8 %y, i32 0
  %r = icmp sle <16 x i8> %i0, %i1
  ret <16 x i1> %r
}

; Base vector does not have to be undef.

define <4 x i1> @ins0_ins0_i32(i32 %x, i32 %y) {
; CHECK-LABEL: @ins0_ins0_i32(
; CHECK-NEXT:    [[R_SCALAR:%.*]] = icmp ne i32 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = insertelement <4 x i1> undef, i1 [[R_SCALAR]], i64 0
; CHECK-NEXT:    ret <4 x i1> [[R]]
;
  %i0 = insertelement <4 x i32> zeroinitializer, i32 %x, i32 0
  %i1 = insertelement <4 x i32> undef, i32 %y, i32 0
  %r = icmp ne <4 x i32> %i0, %i1
  ret <4 x i1> %r
}

; Extra use is accounted for in cost calculation.

define <4 x i1> @ins0_ins0_i32_use(i32 %x, i32 %y) {
; CHECK-LABEL: @ins0_ins0_i32_use(
; CHECK-NEXT:    [[I0:%.*]] = insertelement <4 x i32> undef, i32 [[X:%.*]], i32 0
; CHECK-NEXT:    call void @use(<4 x i32> [[I0]])
; CHECK-NEXT:    [[R_SCALAR:%.*]] = icmp ugt i32 [[X]], [[Y:%.*]]
; CHECK-NEXT:    [[R:%.*]] = insertelement <4 x i1> undef, i1 [[R_SCALAR]], i64 0
; CHECK-NEXT:    ret <4 x i1> [[R]]
;
  %i0 = insertelement <4 x i32> undef, i32 %x, i32 0
  call void @use(<4 x i32> %i0)
  %i1 = insertelement <4 x i32> undef, i32 %y, i32 0
  %r = icmp ugt <4 x i32> %i0, %i1
  ret <4 x i1> %r
}

; Extra use is accounted for in cost calculation.

define <4 x i1> @ins1_ins1_f32_use(float %x, float %y) {
; CHECK-LABEL: @ins1_ins1_f32_use(
; CHECK-NEXT:    [[I1:%.*]] = insertelement <4 x float> undef, float [[Y:%.*]], i32 1
; CHECK-NEXT:    call void @usef(<4 x float> [[I1]])
; CHECK-NEXT:    [[R_SCALAR:%.*]] = fcmp ogt float [[X:%.*]], [[Y]]
; CHECK-NEXT:    [[R:%.*]] = insertelement <4 x i1> zeroinitializer, i1 [[R_SCALAR]], i64 1
; CHECK-NEXT:    ret <4 x i1> [[R]]
;
  %i0 = insertelement <4 x float> undef, float %x, i32 1
  %i1 = insertelement <4 x float> undef, float %y, i32 1
  call void @usef(<4 x float> %i1)
  %r = fcmp ogt <4 x float> %i0, %i1
  ret <4 x i1> %r
}

; If the scalar cmp is not cheaper than the vector cmp, extra uses can prevent the transform.

define <4 x i1> @ins2_ins2_f32_uses(float %x, float %y) {
; CHECK-LABEL: @ins2_ins2_f32_uses(
; CHECK-NEXT:    [[I0:%.*]] = insertelement <4 x float> undef, float [[X:%.*]], i32 2
; CHECK-NEXT:    call void @usef(<4 x float> [[I0]])
; CHECK-NEXT:    [[I1:%.*]] = insertelement <4 x float> undef, float [[Y:%.*]], i32 2
; CHECK-NEXT:    call void @usef(<4 x float> [[I1]])
; CHECK-NEXT:    [[R:%.*]] = fcmp oeq <4 x float> [[I0]], [[I1]]
; CHECK-NEXT:    ret <4 x i1> [[R]]
;
  %i0 = insertelement <4 x float> undef, float %x, i32 2
  call void @usef(<4 x float> %i0)
  %i1 = insertelement <4 x float> undef, float %y, i32 2
  call void @usef(<4 x float> %i1)
  %r = fcmp oeq <4 x float> %i0, %i1
  ret <4 x i1> %r
}

define <2 x i1> @constant_op1_i64(i64 %x) {
; CHECK-LABEL: @constant_op1_i64(
; CHECK-NEXT:    [[R_SCALAR:%.*]] = icmp ne i64 [[X:%.*]], 42
; CHECK-NEXT:    [[R:%.*]] = insertelement <2 x i1> undef, i1 [[R_SCALAR]], i64 0
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %ins = insertelement <2 x i64> undef, i64 %x, i32 0
  %r = icmp ne <2 x i64> %ins, <i64 42, i64 undef>
  ret <2 x i1> %r
}

define <2 x i1> @constant_op1_i64_not_undef_lane(i64 %x) {
; CHECK-LABEL: @constant_op1_i64_not_undef_lane(
; CHECK-NEXT:    [[R_SCALAR:%.*]] = icmp sge i64 [[X:%.*]], 42
; CHECK-NEXT:    [[R:%.*]] = insertelement <2 x i1> <i1 true, i1 true>, i1 [[R_SCALAR]], i64 0
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %ins = insertelement <2 x i64> undef, i64 %x, i32 0
  %r = icmp sge <2 x i64> %ins, <i64 42, i64 -42>
  ret <2 x i1> %r
}

; negative test - load prevents the transform

define <2 x i1> @constant_op1_i64_load(i64* %p) {
; CHECK-LABEL: @constant_op1_i64_load(
; CHECK-NEXT:    [[LD:%.*]] = load i64, i64* [[P:%.*]], align 4
; CHECK-NEXT:    [[INS:%.*]] = insertelement <2 x i64> undef, i64 [[LD]], i32 0
; CHECK-NEXT:    [[R:%.*]] = icmp eq <2 x i64> [[INS]], <i64 42, i64 -42>
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %ld = load i64, i64* %p
  %ins = insertelement <2 x i64> undef, i64 %ld, i32 0
  %r = icmp eq <2 x i64> %ins, <i64 42, i64 -42>
  ret <2 x i1> %r
}

define <4 x i1> @constant_op0_i32(i32 %x) {
; CHECK-LABEL: @constant_op0_i32(
; CHECK-NEXT:    [[R_SCALAR:%.*]] = icmp ult i32 -42, [[X:%.*]]
; CHECK-NEXT:    [[R:%.*]] = insertelement <4 x i1> zeroinitializer, i1 [[R_SCALAR]], i64 1
; CHECK-NEXT:    ret <4 x i1> [[R]]
;
  %ins = insertelement <4 x i32> undef, i32 %x, i32 1
  %r = icmp ult <4 x i32> <i32 undef, i32 -42, i32 undef, i32 undef>, %ins
  ret <4 x i1> %r
}

define <4 x i1> @constant_op0_i32_not_undef_lane(i32 %x) {
; CHECK-LABEL: @constant_op0_i32_not_undef_lane(
; CHECK-NEXT:    [[R_SCALAR:%.*]] = icmp ule i32 42, [[X:%.*]]
; CHECK-NEXT:    [[R:%.*]] = insertelement <4 x i1> <i1 true, i1 true, i1 true, i1 true>, i1 [[R_SCALAR]], i64 1
; CHECK-NEXT:    ret <4 x i1> [[R]]
;
  %ins = insertelement <4 x i32> undef, i32 %x, i32 1
  %r = icmp ule <4 x i32> <i32 1, i32 42, i32 42, i32 -42>, %ins
  ret <4 x i1> %r
}

define <2 x i1> @constant_op0_f64(double %x) {
; CHECK-LABEL: @constant_op0_f64(
; CHECK-NEXT:    [[R_SCALAR:%.*]] = fcmp fast olt double 4.200000e+01, [[X:%.*]]
; CHECK-NEXT:    [[R:%.*]] = insertelement <2 x i1> zeroinitializer, i1 [[R_SCALAR]], i64 0
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %ins = insertelement <2 x double> undef, double %x, i32 0
  %r = fcmp fast olt <2 x double> <double 42.0, double undef>, %ins
  ret <2 x i1> %r
}

define <2 x i1> @constant_op0_f64_not_undef_lane(double %x) {
; CHECK-LABEL: @constant_op0_f64_not_undef_lane(
; CHECK-NEXT:    [[R_SCALAR:%.*]] = fcmp nnan ueq double -4.200000e+01, [[X:%.*]]
; CHECK-NEXT:    [[R:%.*]] = insertelement <2 x i1> <i1 true, i1 true>, i1 [[R_SCALAR]], i64 1
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %ins = insertelement <2 x double> undef, double %x, i32 1
  %r = fcmp nnan ueq <2 x double> <double 42.0, double -42.0>, %ins
  ret <2 x i1> %r
}

define <2 x i1> @constant_op1_f64(double %x) {
; CHECK-LABEL: @constant_op1_f64(
; CHECK-NEXT:    [[R_SCALAR:%.*]] = fcmp one double [[X:%.*]], 4.200000e+01
; CHECK-NEXT:    [[R:%.*]] = insertelement <2 x i1> zeroinitializer, i1 [[R_SCALAR]], i64 1
; CHECK-NEXT:    ret <2 x i1> [[R]]
;
  %ins = insertelement <2 x double> undef, double %x, i32 1
  %r = fcmp one <2 x double> %ins, <double undef, double 42.0>
  ret <2 x i1> %r
}

define <4 x i1> @constant_op1_f32_not_undef_lane(float %x) {
; CHECK-LABEL: @constant_op1_f32_not_undef_lane(
; CHECK-NEXT:    [[R_SCALAR:%.*]] = fcmp uge float [[X:%.*]], 4.200000e+01
; CHECK-NEXT:    [[R:%.*]] = insertelement <4 x i1> <i1 true, i1 true, i1 true, i1 true>, i1 [[R_SCALAR]], i64 0
; CHECK-NEXT:    ret <4 x i1> [[R]]
;
  %ins = insertelement <4 x float> undef, float %x, i32 0
  %r = fcmp uge <4 x float> %ins, <float 42.0, float -42.0, float 0.0, float 1.0>
  ret <4 x i1> %r
}

; negative test - select prevents the transform

define <4 x float> @vec_select_use1(<4 x float> %x, <4 x float> %y, i32 %a, i32 %b) {
; CHECK-LABEL: @vec_select_use1(
; CHECK-NEXT:    [[VECA:%.*]] = insertelement <4 x i32> undef, i32 [[A:%.*]], i8 0
; CHECK-NEXT:    [[VECB:%.*]] = insertelement <4 x i32> undef, i32 [[B:%.*]], i8 0
; CHECK-NEXT:    [[COND:%.*]] = icmp eq <4 x i32> [[VECA]], [[VECB]]
; CHECK-NEXT:    [[R:%.*]] = select <4 x i1> [[COND]], <4 x float> [[X:%.*]], <4 x float> [[Y:%.*]]
; CHECK-NEXT:    ret <4 x float> [[R]]
;
  %veca = insertelement <4 x i32> undef, i32 %a, i8 0
  %vecb = insertelement <4 x i32> undef, i32 %b, i8 0
  %cond = icmp eq <4 x i32> %veca, %vecb
  %r = select <4 x i1> %cond, <4 x float> %x, <4 x float> %y
  ret <4 x float> %r
}

; negative test - select prevents the transform

define <4 x float> @vec_select_use2(<4 x float> %x, <4 x float> %y, float %a) {
; CHECK-LABEL: @vec_select_use2(
; CHECK-NEXT:    [[VECA:%.*]] = insertelement <4 x float> undef, float [[A:%.*]], i8 0
; CHECK-NEXT:    [[COND:%.*]] = fcmp oeq <4 x float> [[VECA]], zeroinitializer
; CHECK-NEXT:    [[R:%.*]] = select <4 x i1> [[COND]], <4 x float> [[X:%.*]], <4 x float> [[Y:%.*]]
; CHECK-NEXT:    ret <4 x float> [[R]]
;
  %veca = insertelement <4 x float> undef, float %a, i8 0
  %cond = fcmp oeq <4 x float> %veca, zeroinitializer
  %r = select <4 x i1> %cond, <4 x float> %x, <4 x float> %y
  ret <4 x float> %r
}

define <4 x i1> @vector_of_pointers(i32* %t1) {
; CHECK-LABEL: @vector_of_pointers(
; CHECK-NEXT:    [[T6_SCALAR:%.*]] = icmp ne i32* [[T1:%.*]], null
; CHECK-NEXT:    [[T6:%.*]] = insertelement <4 x i1> undef, i1 [[T6_SCALAR]], i64 0
; CHECK-NEXT:    ret <4 x i1> [[T6]]
;
  %t5 = insertelement <4 x i32*> undef, i32* %t1, i32 0
  %t6 = icmp ne <4 x i32*> %t5, zeroinitializer
  ret <4 x i1> %t6
}
