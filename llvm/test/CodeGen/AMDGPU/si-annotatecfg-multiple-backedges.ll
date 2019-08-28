; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -mtriple=amdgcn-- -S -structurizecfg -si-annotate-control-flow %s | FileCheck -check-prefix=OPT %s

; This test is designed to check that the backedge from a prior block won't
; reset the variable introduced to record and accumulate the number of threads
; which have already exited the loop.

define amdgpu_kernel void @multiple_backedges(i32 %arg, i32* %arg1) {
; OPT-LABEL: @multiple_backedges(
; OPT-NEXT:  entry:
; OPT-NEXT:    [[TMP:%.*]] = tail call i32 @llvm.amdgcn.workitem.id.x()
; OPT-NEXT:    [[TMP2:%.*]] = shl nsw i32 [[ARG:%.*]], 1
; OPT-NEXT:    br label [[LOOP:%.*]]
; OPT:       loop:
; OPT-NEXT:    [[PHI_BROKEN1:%.*]] = phi i64 [ [[TMP7:%.*]], [[LOOP_END:%.*]] ], [ [[PHI_BROKEN1]], [[LOOP]] ], [ 0, [[ENTRY:%.*]] ]
; OPT-NEXT:    [[PHI_BROKEN:%.*]] = phi i64 [ 0, [[LOOP_END]] ], [ [[TMP0:%.*]], [[LOOP]] ], [ 0, [[ENTRY]] ]
; OPT-NEXT:    [[TMP4:%.*]] = phi i32 [ 0, [[ENTRY]] ], [ [[TMP5:%.*]], [[LOOP]] ], [ 0, [[LOOP_END]] ]
; OPT-NEXT:    [[TMP5]] = add nsw i32 [[TMP4]], [[TMP]]
; OPT-NEXT:    [[TMP6:%.*]] = icmp slt i32 [[ARG]], [[TMP5]]
; OPT-NEXT:    [[TMP0]] = call i64 @llvm.amdgcn.if.break.i64.i64(i1 [[TMP6]], i64 [[PHI_BROKEN]])
; OPT-NEXT:    [[TMP1:%.*]] = call i1 @llvm.amdgcn.loop.i64(i64 [[TMP0]])
; OPT-NEXT:    br i1 [[TMP1]], label [[LOOP_END]], label [[LOOP]]
; OPT:       loop_end:
; OPT-NEXT:    call void @llvm.amdgcn.end.cf.i64(i64 [[TMP0]])
; OPT-NEXT:    [[EXIT:%.*]] = icmp sgt i32 [[TMP5]], [[TMP2]]
; OPT-NEXT:    [[TMP7]] = call i64 @llvm.amdgcn.if.break.i64.i64(i1 [[EXIT]], i64 [[PHI_BROKEN1]])
; OPT-NEXT:    [[TMP3:%.*]] = call i1 @llvm.amdgcn.loop.i64(i64 [[TMP7]])
; OPT-NEXT:    br i1 [[TMP3]], label [[LOOP_EXIT:%.*]], label [[LOOP]]
; OPT:       loop_exit:
; OPT-NEXT:    call void @llvm.amdgcn.end.cf.i64(i64 [[TMP7]])
; OPT-NEXT:    [[TMP12:%.*]] = zext i32 [[TMP]] to i64
; OPT-NEXT:    [[TMP13:%.*]] = getelementptr inbounds i32, i32* [[ARG1:%.*]], i64 [[TMP12]]
; OPT-NEXT:    [[TMP14:%.*]] = addrspacecast i32* [[TMP13]] to i32 addrspace(1)*
; OPT-NEXT:    store i32 [[TMP5]], i32 addrspace(1)* [[TMP14]], align 4
; OPT-NEXT:    ret void
;
entry:
  %tmp = tail call i32 @llvm.amdgcn.workitem.id.x()
  %tmp2 = shl nsw i32 %arg, 1
  br label %loop

loop:
  %tmp4 = phi i32 [ 0, %entry ], [ %tmp5, %loop ], [ 0, %loop_end ]
  %tmp5 = add nsw i32 %tmp4, %tmp
  %tmp6 = icmp slt i32 %arg, %tmp5
  br i1 %tmp6, label %loop_end, label %loop

loop_end:
  %exit = icmp sgt i32 %tmp5, %tmp2
  br i1 %exit, label %loop_exit, label %loop

loop_exit:
  %tmp12 = zext i32 %tmp to i64
  %tmp13 = getelementptr inbounds i32, i32* %arg1, i64 %tmp12
  %tmp14 = addrspacecast i32* %tmp13 to i32 addrspace(1)*
  store i32 %tmp5, i32 addrspace(1)* %tmp14, align 4
  ret void
}

; Function Attrs: nounwind readnone speculatable
declare i32 @llvm.amdgcn.workitem.id.x()
