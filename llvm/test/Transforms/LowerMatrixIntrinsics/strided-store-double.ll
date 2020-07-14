; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -lower-matrix-intrinsics -S < %s | FileCheck %s
; RUN: opt -passes='lower-matrix-intrinsics' -S < %s | FileCheck %s

define void @strided_store_3x2(<6 x double> %in, double* %out) {
; CHECK-LABEL: @strided_store_3x2(
; CHECK-NEXT:    [[SPLIT:%.*]] = shufflevector <6 x double> [[IN:%.*]], <6 x double> undef, <3 x i32> <i32 0, i32 1, i32 2>
; CHECK-NEXT:    [[SPLIT1:%.*]] = shufflevector <6 x double> [[IN]], <6 x double> undef, <3 x i32> <i32 3, i32 4, i32 5>
; CHECK-NEXT:    [[VEC_CAST:%.*]] = bitcast double* [[OUT:%.*]] to <3 x double>*
; CHECK-NEXT:    store <3 x double> [[SPLIT]], <3 x double>* [[VEC_CAST]], align 8
; CHECK-NEXT:    [[VEC_GEP:%.*]] = getelementptr double, double* [[OUT]], i64 5
; CHECK-NEXT:    [[VEC_CAST2:%.*]] = bitcast double* [[VEC_GEP]] to <3 x double>*
; CHECK-NEXT:    store <3 x double> [[SPLIT1]], <3 x double>* [[VEC_CAST2]], align 8
; CHECK-NEXT:    ret void
;
  call void @llvm.matrix.column.major.store.v6f64(<6 x double> %in, double* %out, i64 5, i1 false, i32 3, i32 2)
  ret void
}

define void @strided_store_3x2_nonconst_stride(<6 x double> %in, i64 %stride, double* %out) {
; CHECK-LABEL: @strided_store_3x2_nonconst_stride(
; CHECK-NEXT:    [[SPLIT:%.*]] = shufflevector <6 x double> [[IN:%.*]], <6 x double> undef, <3 x i32> <i32 0, i32 1, i32 2>
; CHECK-NEXT:    [[SPLIT1:%.*]] = shufflevector <6 x double> [[IN]], <6 x double> undef, <3 x i32> <i32 3, i32 4, i32 5>
; CHECK-NEXT:    [[VEC_START:%.*]] = mul i64 0, [[STRIDE:%.*]]
; CHECK-NEXT:    [[VEC_GEP:%.*]] = getelementptr double, double* [[OUT:%.*]], i64 [[VEC_START]]
; CHECK-NEXT:    [[VEC_CAST:%.*]] = bitcast double* [[VEC_GEP]] to <3 x double>*
; CHECK-NEXT:    store <3 x double> [[SPLIT]], <3 x double>* [[VEC_CAST]], align 8
; CHECK-NEXT:    [[VEC_START2:%.*]] = mul i64 1, [[STRIDE]]
; CHECK-NEXT:    [[VEC_GEP3:%.*]] = getelementptr double, double* [[OUT]], i64 [[VEC_START2]]
; CHECK-NEXT:    [[VEC_CAST4:%.*]] = bitcast double* [[VEC_GEP3]] to <3 x double>*
; CHECK-NEXT:    store <3 x double> [[SPLIT1]], <3 x double>* [[VEC_CAST4]], align 8
; CHECK-NEXT:    ret void
;
  call void @llvm.matrix.column.major.store.v6f64(<6 x double> %in, double* %out, i64 %stride, i1 false, i32 3, i32 2)
  ret void
}

define void @strided_store_2x3(<10 x double> %in, double* %out) {
; CHECK-LABEL: @strided_store_2x3(
; CHECK-NEXT:    [[SPLIT:%.*]] = shufflevector <10 x double> [[IN:%.*]], <10 x double> undef, <2 x i32> <i32 0, i32 1>
; CHECK-NEXT:    [[SPLIT1:%.*]] = shufflevector <10 x double> [[IN]], <10 x double> undef, <2 x i32> <i32 2, i32 3>
; CHECK-NEXT:    [[SPLIT2:%.*]] = shufflevector <10 x double> [[IN]], <10 x double> undef, <2 x i32> <i32 4, i32 5>
; CHECK-NEXT:    [[SPLIT3:%.*]] = shufflevector <10 x double> [[IN]], <10 x double> undef, <2 x i32> <i32 6, i32 7>
; CHECK-NEXT:    [[SPLIT4:%.*]] = shufflevector <10 x double> [[IN]], <10 x double> undef, <2 x i32> <i32 8, i32 9>
; CHECK-NEXT:    [[VEC_CAST:%.*]] = bitcast double* [[OUT:%.*]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[SPLIT]], <2 x double>* [[VEC_CAST]], align 8
; CHECK-NEXT:    [[VEC_GEP:%.*]] = getelementptr double, double* [[OUT]], i64 4
; CHECK-NEXT:    [[VEC_CAST5:%.*]] = bitcast double* [[VEC_GEP]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[SPLIT1]], <2 x double>* [[VEC_CAST5]], align 8
; CHECK-NEXT:    [[VEC_GEP6:%.*]] = getelementptr double, double* [[OUT]], i64 8
; CHECK-NEXT:    [[VEC_CAST7:%.*]] = bitcast double* [[VEC_GEP6]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[SPLIT2]], <2 x double>* [[VEC_CAST7]], align 8
; CHECK-NEXT:    [[VEC_GEP8:%.*]] = getelementptr double, double* [[OUT]], i64 12
; CHECK-NEXT:    [[VEC_CAST9:%.*]] = bitcast double* [[VEC_GEP8]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[SPLIT3]], <2 x double>* [[VEC_CAST9]], align 8
; CHECK-NEXT:    [[VEC_GEP10:%.*]] = getelementptr double, double* [[OUT]], i64 16
; CHECK-NEXT:    [[VEC_CAST11:%.*]] = bitcast double* [[VEC_GEP10]] to <2 x double>*
; CHECK-NEXT:    store <2 x double> [[SPLIT4]], <2 x double>* [[VEC_CAST11]], align 8
; CHECK-NEXT:    ret void
;
  call void @llvm.matrix.column.major.store.v10f64(<10 x double> %in, double* %out, i64 4, i1 false, i32 2, i32 5)
  ret void
}

declare void @llvm.matrix.column.major.store.v6f64(<6 x double>, double*, i64, i1, i32, i32)
declare void @llvm.matrix.column.major.store.v10f64(<10 x double>, double*, i64, i1, i32, i32)

; CHECK: declare void @llvm.matrix.column.major.store.v6f64(<6 x double>, double* nocapture writeonly, i64, i1 immarg, i32 immarg, i32 immarg) #0 
; CHECK: declare void @llvm.matrix.column.major.store.v10f64(<10 x double>, double* nocapture writeonly, i64, i1 immarg, i32 immarg, i32 immarg) #0 
; CHECK: attributes #0 = { argmemonly nosync nounwind willreturn writeonly }
