; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature
; RUN: opt -S -attributor -openmpopt -attributor-disable=false < %s | FileCheck %s
; RUN: opt -S -passes='attributor,cgscc(openmpopt)' -attributor-disable=false < %s | FileCheck %s
;
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"

%struct.ident_t = type { i32, i32, i32, i32, i8* }

@.str = private unnamed_addr constant [23 x i8] c";unknown;unknown;0;0;;\00", align 1
@0 = private unnamed_addr global %struct.ident_t { i32 0, i32 2, i32 0, i32 0, i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str, i32 0, i32 0) }, align 8
@1 = private unnamed_addr global %struct.ident_t { i32 0, i32 322, i32 0, i32 0, i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str, i32 0, i32 0) }, align 8
@.gomp_critical_user_.reduction.var = common global [8 x i32] zeroinitializer
@2 = private unnamed_addr global %struct.ident_t { i32 0, i32 18, i32 0, i32 0, i8* getelementptr inbounds ([23 x i8], [23 x i8]* @.str, i32 0, i32 0) }, align 8

;    void delete_parallel_0(void) {
;    #pragma omp parallel
;      { unknown_willreturn(); }
;    #pragma omp parallel
;      { readonly_willreturn(); }
;    #pragma omp parallel
;      { readnone_willreturn(); }
;    #pragma omp parallel
;      {}
;    }
;
; We delete all but the first of the parallel regions in this test.
define void @delete_parallel_0() {
; CHECK-LABEL: define {{[^@]+}}@delete_parallel_0()
; CHECK-NEXT:  entry:
; CHECK-NEXT:    call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull align 8 dereferenceable(24) @0, i32 0, void (i32*, i32*, ...)* nonnull bitcast (void (i32*, i32*)* @.omp_outlined.willreturn to void (i32*, i32*, ...)*))
; CHECK-NEXT:    ret void
;
entry:
  call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull @0, i32 0, void (i32*, i32*, ...)* bitcast (void (i32*, i32*)* @.omp_outlined.willreturn to void (i32*, i32*, ...)*))
  call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull @0, i32 0, void (i32*, i32*, ...)* bitcast (void (i32*, i32*)* @.omp_outlined.willreturn.0 to void (i32*, i32*, ...)*))
  call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull @0, i32 0, void (i32*, i32*, ...)* bitcast (void (i32*, i32*)* @.omp_outlined.willreturn.1 to void (i32*, i32*, ...)*))
  call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull @0, i32 0, void (i32*, i32*, ...)* bitcast (void (i32*, i32*)* @.omp_outlined.willreturn.2 to void (i32*, i32*, ...)*))
  ret void
}

define internal void @.omp_outlined.willreturn(i32* noalias %.global_tid., i32* noalias %.bound_tid.) {
entry:
  call void @unknown() willreturn
  ret void
}

define internal void @.omp_outlined.willreturn.0(i32* noalias %.global_tid., i32* noalias %.bound_tid.) willreturn {
entry:
  call void @readonly()
  ret void
}

define internal void @.omp_outlined.willreturn.1(i32* noalias %.global_tid., i32* noalias %.bound_tid.) {
entry:
  call void @readnone() willreturn
  ret void
}

define internal void @.omp_outlined.willreturn.2(i32* noalias %.global_tid., i32* noalias %.bound_tid.) {
entry:
  ret void
}

;    void delete_parallel_1(void) {
;    #pragma omp parallel
;      { unknown(); }
;    #pragma omp parallel
;      { readonly(); }
;    #pragma omp parallel
;      { readnone(); }
;    #pragma omp parallel
;      {}
;    }
;
; We delete only the last parallel regions in this test because the others might not return.
define void @delete_parallel_1() {
; CHECK-LABEL: define {{[^@]+}}@delete_parallel_1()
; CHECK-NEXT:  entry:
; CHECK-NEXT:    call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull align 8 dereferenceable(24) @0, i32 0, void (i32*, i32*, ...)* nonnull bitcast (void (i32*, i32*)* @.omp_outlined. to void (i32*, i32*, ...)*))
; CHECK-NEXT:    call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull align 8 dereferenceable(24) @0, i32 0, void (i32*, i32*, ...)* nonnull bitcast (void (i32*, i32*)* @.omp_outlined..0 to void (i32*, i32*, ...)*))
; CHECK-NEXT:    call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull align 8 dereferenceable(24) @0, i32 0, void (i32*, i32*, ...)* nonnull bitcast (void (i32*, i32*)* @.omp_outlined..1 to void (i32*, i32*, ...)*))
; CHECK-NEXT:    ret void
;
entry:
  call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull @0, i32 0, void (i32*, i32*, ...)* bitcast (void (i32*, i32*)* @.omp_outlined. to void (i32*, i32*, ...)*))
  call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull @0, i32 0, void (i32*, i32*, ...)* bitcast (void (i32*, i32*)* @.omp_outlined..0 to void (i32*, i32*, ...)*))
  call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull @0, i32 0, void (i32*, i32*, ...)* bitcast (void (i32*, i32*)* @.omp_outlined..1 to void (i32*, i32*, ...)*))
  call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull @0, i32 0, void (i32*, i32*, ...)* bitcast (void (i32*, i32*)* @.omp_outlined..2 to void (i32*, i32*, ...)*))
  ret void
}

define internal void @.omp_outlined.(i32* noalias %.global_tid., i32* noalias %.bound_tid.) {
entry:
  call void @unknown()
  ret void
}

define internal void @.omp_outlined..0(i32* noalias %.global_tid., i32* noalias %.bound_tid.) {
entry:
  call void @readonly()
  ret void
}

define internal void @.omp_outlined..1(i32* noalias %.global_tid., i32* noalias %.bound_tid.) {
entry:
  call void @readnone()
  ret void
}

define internal void @.omp_outlined..2(i32* noalias %.global_tid., i32* noalias %.bound_tid.) {
entry:
  ret void
}

;    void delete_parallel_2(void) {
;      int a = 0;
;    #pragma omp parallel
;      {
;        if (omp_get_thread_num() == 0)
;          ++a;
;      }
;    #pragma omp parallel
;      {
;    #pragma omp master
;        ++a;
;      }
;    #pragma omp parallel
;      {
;    #pragma omp single
;        ++a;
;      }
;    #pragma omp parallel reduction(+: a)
;      {
;        ++a;
;      }
;    }
;
; FIXME: We do not realize that `a` is dead and all accesses to it can be removed
;        making the parallel regions readonly and deletable.
define void @delete_parallel_2() {
; CHECK-LABEL: define {{[^@]+}}@delete_parallel_2()
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = alloca i32, align 4
; CHECK-NEXT:    [[TMP:%.*]] = bitcast i32* [[A]] to i8*
; CHECK-NEXT:    call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull align 4 dereferenceable(4) [[TMP]]) #0
; CHECK-NEXT:    store i32 0, i32* [[A]], align 4
; CHECK-NEXT:    call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull align 8 dereferenceable(24) @0, i32 1, void (i32*, i32*, ...)* nonnull bitcast (void (i32*, i32*, i32*)* @.omp_outlined..3 to void (i32*, i32*, ...)*), i32* nocapture nofree nonnull align 4 dereferenceable(4) [[A]])
; CHECK-NEXT:    call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull align 8 dereferenceable(24) @0, i32 1, void (i32*, i32*, ...)* nonnull bitcast (void (i32*, i32*, i32*)* @.omp_outlined..4 to void (i32*, i32*, ...)*), i32* nocapture nonnull align 4 dereferenceable(4) [[A]])
; CHECK-NEXT:    call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull align 8 dereferenceable(24) @0, i32 1, void (i32*, i32*, ...)* nonnull bitcast (void (i32*, i32*, i32*)* @.omp_outlined..5 to void (i32*, i32*, ...)*), i32* nocapture nonnull align 4 dereferenceable(4) [[A]])
; CHECK-NEXT:    call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull align 8 dereferenceable(24) @0, i32 1, void (i32*, i32*, ...)* nonnull bitcast (void (i32*, i32*, i32*)* @.omp_outlined..6 to void (i32*, i32*, ...)*), i32* nocapture nonnull align 4 dereferenceable(4) [[A]])
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i32* [[A]] to i8*
; CHECK-NEXT:    call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull [[TMP1]])
; CHECK-NEXT:    ret void
;
entry:
  %a = alloca i32, align 4
  %tmp = bitcast i32* %a to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %tmp)
  store i32 0, i32* %a, align 4
  call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull @0, i32 1, void (i32*, i32*, ...)* bitcast (void (i32*, i32*, i32*)* @.omp_outlined..3 to void (i32*, i32*, ...)*), i32* nonnull %a)
  call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull @0, i32 1, void (i32*, i32*, ...)* bitcast (void (i32*, i32*, i32*)* @.omp_outlined..4 to void (i32*, i32*, ...)*), i32* nonnull %a)
  call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull @0, i32 1, void (i32*, i32*, ...)* bitcast (void (i32*, i32*, i32*)* @.omp_outlined..5 to void (i32*, i32*, ...)*), i32* nonnull %a)
  call void (%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...) @__kmpc_fork_call(%struct.ident_t* nonnull @0, i32 1, void (i32*, i32*, ...)* bitcast (void (i32*, i32*, i32*)* @.omp_outlined..6 to void (i32*, i32*, ...)*), i32* nonnull %a)
  %tmp1 = bitcast i32* %a to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %tmp1)
  ret void
}

define internal void @.omp_outlined..3(i32* noalias %.global_tid., i32* noalias %.bound_tid., i32* dereferenceable(4) %a) {
entry:
  %call = call i32 @omp_get_thread_num()
  %cmp = icmp eq i32 %call, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  %tmp = load i32, i32* %a, align 4
  %inc = add nsw i32 %tmp, 1
  store i32 %inc, i32* %a, align 4
  br label %if.end

if.end:                                           ; preds = %if.then, %entry
  ret void
}

define internal void @.omp_outlined..4(i32* noalias %.global_tid., i32* noalias %.bound_tid., i32* dereferenceable(4) %a) {
entry:
  %tmp = load i32, i32* %.global_tid., align 4
  %tmp1 = call i32 @__kmpc_master(%struct.ident_t* nonnull @0, i32 %tmp)
  %tmp2 = icmp eq i32 %tmp1, 0
  br i1 %tmp2, label %omp_if.end, label %omp_if.then

omp_if.then:                                      ; preds = %entry
  %tmp3 = load i32, i32* %a, align 4
  %inc = add nsw i32 %tmp3, 1
  store i32 %inc, i32* %a, align 4
  call void @__kmpc_end_master(%struct.ident_t* nonnull @0, i32 %tmp)
  br label %omp_if.end

omp_if.end:                                       ; preds = %entry, %omp_if.then
  ret void
}

declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture)

declare i32 @omp_get_thread_num() inaccessiblememonly nofree nosync nounwind readonly

declare i32 @__kmpc_master(%struct.ident_t*, i32)

declare void @__kmpc_end_master(%struct.ident_t*, i32)

define internal void @.omp_outlined..5(i32* noalias %.global_tid., i32* noalias %.bound_tid., i32* dereferenceable(4) %a) {
entry:
  %omp_global_thread_num = call i32 @__kmpc_global_thread_num(%struct.ident_t* nonnull @0)
  %tmp = load i32, i32* %.global_tid., align 4
  %tmp1 = call i32 @__kmpc_single(%struct.ident_t* nonnull @0, i32 %tmp)
  %tmp2 = icmp eq i32 %tmp1, 0
  br i1 %tmp2, label %omp_if.end, label %omp_if.then

omp_if.then:                                      ; preds = %entry
  %tmp3 = load i32, i32* %a, align 4
  %inc = add nsw i32 %tmp3, 1
  store i32 %inc, i32* %a, align 4
  call void @__kmpc_end_single(%struct.ident_t* nonnull @0, i32 %tmp)
  br label %omp_if.end

omp_if.end:                                       ; preds = %entry, %omp_if.then
  call void @__kmpc_barrier(%struct.ident_t* nonnull @1, i32 %omp_global_thread_num) #6
  ret void
}

define internal void @.omp_outlined..6(i32* noalias %.global_tid., i32* noalias %.bound_tid., i32* dereferenceable(4) %a) {
entry:
  %a1 = alloca i32, align 4
  %.omp.reduction.red_list = alloca [1 x i8*], align 8
  %tmp = bitcast i32* %a1 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %tmp)
  store i32 1, i32* %a1, align 4
  %tmp1 = bitcast [1 x i8*]* %.omp.reduction.red_list to i32**
  store i32* %a1, i32** %tmp1, align 8
  %tmp2 = load i32, i32* %.global_tid., align 4
  %tmp3 = bitcast [1 x i8*]* %.omp.reduction.red_list to i8*
  %tmp4 = call i32 @__kmpc_reduce_nowait(%struct.ident_t* nonnull @2, i32 %tmp2, i32 1, i64 8, i8* nonnull %tmp3, void (i8*, i8*)* nonnull @.omp.reduction.reduction_func, [8 x i32]* nonnull @.gomp_critical_user_.reduction.var)
  switch i32 %tmp4, label %.omp.reduction.default [
    i32 1, label %.omp.reduction.case1
    i32 2, label %.omp.reduction.case2
  ]

.omp.reduction.case1:                             ; preds = %entry
  %tmp5 = load i32, i32* %a, align 4
  %tmp6 = load i32, i32* %a1, align 4
  %add = add nsw i32 %tmp5, %tmp6
  store i32 %add, i32* %a, align 4
  call void @__kmpc_end_reduce_nowait(%struct.ident_t* nonnull @2, i32 %tmp2, [8 x i32]* nonnull @.gomp_critical_user_.reduction.var)
  br label %.omp.reduction.default

.omp.reduction.case2:                             ; preds = %entry
  %tmp7 = load i32, i32* %a1, align 4
  %tmp8 = atomicrmw add i32* %a, i32 %tmp7 monotonic
  br label %.omp.reduction.default

.omp.reduction.default:                           ; preds = %.omp.reduction.case2, %.omp.reduction.case1, %entry
  %tmp9 = bitcast i32* %a1 to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %tmp9)
  ret void
}

define internal void @.omp.reduction.reduction_func(i8* %arg, i8* %arg1) {
entry:
  %tmp = bitcast i8* %arg1 to i32**
  %tmp2 = load i32*, i32** %tmp, align 8
  %tmp3 = bitcast i8* %arg to i32**
  %tmp4 = load i32*, i32** %tmp3, align 8
  %tmp5 = load i32, i32* %tmp4, align 4
  %tmp6 = load i32, i32* %tmp2, align 4
  %add = add nsw i32 %tmp5, %tmp6
  store i32 %add, i32* %tmp4, align 4
  ret void
}

declare i32 @__kmpc_single(%struct.ident_t*, i32)

declare void @__kmpc_end_single(%struct.ident_t*, i32)

declare void @__kmpc_barrier(%struct.ident_t*, i32)

declare i32 @__kmpc_global_thread_num(%struct.ident_t*) nofree nosync nounwind readonly

declare i32 @__kmpc_reduce_nowait(%struct.ident_t*, i32, i32, i64, i8*, void (i8*, i8*)*, [8 x i32]*)

declare void @__kmpc_end_reduce_nowait(%struct.ident_t*, i32, [8 x i32]*)

declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture)

declare !callback !2 void @__kmpc_fork_call(%struct.ident_t*, i32, void (i32*, i32*, ...)*, ...)

declare void @unknown()

declare void @readonly() readonly

declare void @readnone() readnone

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang"}
!2 = !{!3}
!3 = !{i64 2, i64 -1, i64 -1, i1 true}
!4 = !{!5, !5, i64 0}
!5 = !{!"int", !6, i64 0}
!6 = !{!"omnipotent char", !7, i64 0}
!7 = !{!"Simple C/C++ TBAA"}
