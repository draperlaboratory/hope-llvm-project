; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -basic-aa -tbaa -loop-unroll-and-jam -allow-unroll-and-jam -unroll-and-jam-count=4 -unroll-remainder < %s -S | FileCheck %s
; RUN: opt -aa-pipeline=type-based-aa,basic-aa -passes='loop-unroll-and-jam' -allow-unroll-and-jam -unroll-and-jam-count=4 -unroll-remainder < %s -S | FileCheck %s

target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"

; CHECK-LABEL: test1
; Tests for(i) { sum = 0; for(j) sum += B[j]; A[i] = sum; }
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne i32 [[J:%.*]], 0
; CHECK-NEXT:    [[CMPJ:%.*]] = icmp ne i32 [[I:%.*]], 0
; CHECK-NEXT:    [[OR_COND:%.*]] = and i1 [[CMP]], [[CMPJ]]
; CHECK-NEXT:    br i1 [[OR_COND]], label [[FOR_OUTER_PREHEADER:%.*]], label [[FOR_END:%.*]]
; CHECK:       for.outer.preheader:
; CHECK-NEXT:    [[TMP0:%.*]] = add i32 [[I]], -1
; CHECK-NEXT:    [[XTRAITER:%.*]] = and i32 [[I]], 3
; CHECK-NEXT:    [[TMP1:%.*]] = icmp ult i32 [[TMP0]], 3
; CHECK-NEXT:    br i1 [[TMP1]], label [[FOR_END_LOOPEXIT_UNR_LCSSA:%.*]], label [[FOR_OUTER_PREHEADER_NEW:%.*]]
; CHECK:       for.outer.preheader.new:
; CHECK-NEXT:    [[UNROLL_ITER:%.*]] = sub i32 [[I]], [[XTRAITER]]
; CHECK-NEXT:    br label [[FOR_OUTER:%.*]]
; CHECK:       for.outer:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ [[ADD8_3:%.*]], [[FOR_LATCH:%.*]] ], [ 0, [[FOR_OUTER_PREHEADER_NEW]] ]
; CHECK-NEXT:    [[NITER:%.*]] = phi i32 [ [[UNROLL_ITER]], [[FOR_OUTER_PREHEADER_NEW]] ], [ [[NITER_NSUB_3:%.*]], [[FOR_LATCH]] ]
; CHECK-NEXT:    [[ADD8:%.*]] = add nuw nsw i32 [[I]], 1
; CHECK-NEXT:    [[NITER_NSUB:%.*]] = sub i32 [[NITER]], 1
; CHECK-NEXT:    [[ADD8_1:%.*]] = add nuw nsw i32 [[ADD8]], 1
; CHECK-NEXT:    [[NITER_NSUB_1:%.*]] = sub i32 [[NITER_NSUB]], 1
; CHECK-NEXT:    [[ADD8_2:%.*]] = add nuw nsw i32 [[ADD8_1]], 1
; CHECK-NEXT:    [[NITER_NSUB_2:%.*]] = sub i32 [[NITER_NSUB_1]], 1
; CHECK-NEXT:    [[ADD8_3]] = add nuw i32 [[ADD8_2]], 1
; CHECK-NEXT:    [[NITER_NSUB_3]] = sub i32 [[NITER_NSUB_2]], 1
; CHECK-NEXT:    br label [[FOR_INNER:%.*]]
; CHECK:       for.inner:
; CHECK-NEXT:    [[J_0:%.*]] = phi i32 [ 0, [[FOR_OUTER]] ], [ [[INC:%.*]], [[FOR_INNER]] ]
; CHECK-NEXT:    [[SUM:%.*]] = phi i32 [ 0, [[FOR_OUTER]] ], [ [[ADD:%.*]], [[FOR_INNER]] ]
; CHECK-NEXT:    [[J_1:%.*]] = phi i32 [ 0, [[FOR_OUTER]] ], [ [[INC_1:%.*]], [[FOR_INNER]] ]
; CHECK-NEXT:    [[SUM_1:%.*]] = phi i32 [ 0, [[FOR_OUTER]] ], [ [[ADD_1:%.*]], [[FOR_INNER]] ]
; CHECK-NEXT:    [[J_2:%.*]] = phi i32 [ 0, [[FOR_OUTER]] ], [ [[INC_2:%.*]], [[FOR_INNER]] ]
; CHECK-NEXT:    [[SUM_2:%.*]] = phi i32 [ 0, [[FOR_OUTER]] ], [ [[ADD_2:%.*]], [[FOR_INNER]] ]
; CHECK-NEXT:    [[J_3:%.*]] = phi i32 [ 0, [[FOR_OUTER]] ], [ [[INC_3:%.*]], [[FOR_INNER]] ]
; CHECK-NEXT:    [[SUM_3:%.*]] = phi i32 [ 0, [[FOR_OUTER]] ], [ [[ADD_3:%.*]], [[FOR_INNER]] ]
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds i32, i32* [[B:%.*]], i32 [[J_0]]
; CHECK-NEXT:    [[TMP2:%.*]] = load i32, i32* [[ARRAYIDX]], align 4, !tbaa !0
; CHECK-NEXT:    [[ADD]] = add i32 [[TMP2]], [[SUM]]
; CHECK-NEXT:    [[INC]] = add nuw i32 [[J_0]], 1
; CHECK-NEXT:    [[ARRAYIDX_1:%.*]] = getelementptr inbounds i32, i32* [[B]], i32 [[J_1]]
; CHECK-NEXT:    [[TMP3:%.*]] = load i32, i32* [[ARRAYIDX_1]], align 4, !tbaa !0
; CHECK-NEXT:    [[ADD_1]] = add i32 [[TMP3]], [[SUM_1]]
; CHECK-NEXT:    [[INC_1]] = add nuw i32 [[J_1]], 1
; CHECK-NEXT:    [[ARRAYIDX_2:%.*]] = getelementptr inbounds i32, i32* [[B]], i32 [[J_2]]
; CHECK-NEXT:    [[TMP4:%.*]] = load i32, i32* [[ARRAYIDX_2]], align 4, !tbaa !0
; CHECK-NEXT:    [[ADD_2]] = add i32 [[TMP4]], [[SUM_2]]
; CHECK-NEXT:    [[INC_2]] = add nuw i32 [[J_2]], 1
; CHECK-NEXT:    [[ARRAYIDX_3:%.*]] = getelementptr inbounds i32, i32* [[B]], i32 [[J_3]]
; CHECK-NEXT:    [[TMP5:%.*]] = load i32, i32* [[ARRAYIDX_3]], align 4, !tbaa !0
; CHECK-NEXT:    [[ADD_3]] = add i32 [[TMP5]], [[SUM_3]]
; CHECK-NEXT:    [[INC_3]] = add nuw i32 [[J_3]], 1
; CHECK-NEXT:    [[EXITCOND_3:%.*]] = icmp eq i32 [[INC_3]], [[J]]
; CHECK-NEXT:    br i1 [[EXITCOND_3]], label [[FOR_LATCH]], label [[FOR_INNER]]
; CHECK:       for.latch:
; CHECK-NEXT:    [[ADD_LCSSA:%.*]] = phi i32 [ [[ADD]], [[FOR_INNER]] ]
; CHECK-NEXT:    [[ADD_LCSSA_1:%.*]] = phi i32 [ [[ADD_1]], [[FOR_INNER]] ]
; CHECK-NEXT:    [[ADD_LCSSA_2:%.*]] = phi i32 [ [[ADD_2]], [[FOR_INNER]] ]
; CHECK-NEXT:    [[ADD_LCSSA_3:%.*]] = phi i32 [ [[ADD_3]], [[FOR_INNER]] ]
; CHECK-NEXT:    [[ARRAYIDX6:%.*]] = getelementptr inbounds i32, i32* [[A:%.*]], i32 [[I]]
; CHECK-NEXT:    store i32 [[ADD_LCSSA]], i32* [[ARRAYIDX6]], align 4, !tbaa !0
; CHECK-NEXT:    [[ARRAYIDX6_1:%.*]] = getelementptr inbounds i32, i32* [[A]], i32 [[ADD8]]
; CHECK-NEXT:    store i32 [[ADD_LCSSA_1]], i32* [[ARRAYIDX6_1]], align 4, !tbaa !0
; CHECK-NEXT:    [[ARRAYIDX6_2:%.*]] = getelementptr inbounds i32, i32* [[A]], i32 [[ADD8_1]]
; CHECK-NEXT:    store i32 [[ADD_LCSSA_2]], i32* [[ARRAYIDX6_2]], align 4, !tbaa !0
; CHECK-NEXT:    [[ARRAYIDX6_3:%.*]] = getelementptr inbounds i32, i32* [[A]], i32 [[ADD8_2]]
; CHECK-NEXT:    store i32 [[ADD_LCSSA_3]], i32* [[ARRAYIDX6_3]], align 4, !tbaa !0
; CHECK-NEXT:    [[NITER_NCMP_3:%.*]] = icmp eq i32 [[NITER_NSUB_3]], 0
; CHECK-NEXT:    br i1 [[NITER_NCMP_3]], label [[FOR_END_LOOPEXIT_UNR_LCSSA_LOOPEXIT:%.*]], label [[FOR_OUTER]], !llvm.loop !4
; CHECK:       for.end.loopexit.unr-lcssa.loopexit:
; CHECK-NEXT:    [[I_UNR_PH:%.*]] = phi i32 [ [[ADD8_3]], [[FOR_LATCH]] ]
; CHECK-NEXT:    br label [[FOR_END_LOOPEXIT_UNR_LCSSA]]
; CHECK:       for.end.loopexit.unr-lcssa:
; CHECK-NEXT:    [[I_UNR:%.*]] = phi i32 [ 0, [[FOR_OUTER_PREHEADER]] ], [ [[I_UNR_PH]], [[FOR_END_LOOPEXIT_UNR_LCSSA_LOOPEXIT]] ]
; CHECK-NEXT:    [[LCMP_MOD:%.*]] = icmp ne i32 [[XTRAITER]], 0
; CHECK-NEXT:    br i1 [[LCMP_MOD]], label [[FOR_OUTER_EPIL_PREHEADER:%.*]], label [[FOR_END_LOOPEXIT:%.*]]
; CHECK:       for.outer.epil.preheader:
; CHECK-NEXT:    br label [[FOR_OUTER_EPIL:%.*]]
; CHECK:       for.outer.epil:
; CHECK-NEXT:    br label [[FOR_INNER_EPIL:%.*]]
; CHECK:       for.inner.epil:
; CHECK-NEXT:    [[J_EPIL:%.*]] = phi i32 [ 0, [[FOR_OUTER_EPIL]] ], [ [[INC_EPIL:%.*]], [[FOR_INNER_EPIL]] ]
; CHECK-NEXT:    [[SUM_EPIL:%.*]] = phi i32 [ 0, [[FOR_OUTER_EPIL]] ], [ [[ADD_EPIL:%.*]], [[FOR_INNER_EPIL]] ]
; CHECK-NEXT:    [[ARRAYIDX_EPIL:%.*]] = getelementptr inbounds i32, i32* [[B]], i32 [[J_EPIL]]
; CHECK-NEXT:    [[TMP6:%.*]] = load i32, i32* [[ARRAYIDX_EPIL]], align 4, !tbaa !0
; CHECK-NEXT:    [[ADD_EPIL]] = add i32 [[TMP6]], [[SUM_EPIL]]
; CHECK-NEXT:    [[INC_EPIL]] = add nuw i32 [[J_EPIL]], 1
; CHECK-NEXT:    [[EXITCOND_EPIL:%.*]] = icmp eq i32 [[INC_EPIL]], [[J]]
; CHECK-NEXT:    br i1 [[EXITCOND_EPIL]], label [[FOR_LATCH_EPIL:%.*]], label [[FOR_INNER_EPIL]]
; CHECK:       for.latch.epil:
; CHECK-NEXT:    [[ADD_LCSSA_EPIL:%.*]] = phi i32 [ [[ADD_EPIL]], [[FOR_INNER_EPIL]] ]
; CHECK-NEXT:    [[ARRAYIDX6_EPIL:%.*]] = getelementptr inbounds i32, i32* [[A]], i32 [[I_UNR]]
; CHECK-NEXT:    store i32 [[ADD_LCSSA_EPIL]], i32* [[ARRAYIDX6_EPIL]], align 4, !tbaa !0
; CHECK-NEXT:    [[ADD8_EPIL:%.*]] = add nuw i32 [[I_UNR]], 1
; CHECK-NEXT:    [[EPIL_ITER_SUB:%.*]] = sub i32 [[XTRAITER]], 1
; CHECK-NEXT:    [[EPIL_ITER_CMP:%.*]] = icmp ne i32 [[EPIL_ITER_SUB]], 0
; CHECK-NEXT:    br i1 [[EPIL_ITER_CMP]], label [[FOR_OUTER_EPIL_1:%.*]], label [[FOR_END_LOOPEXIT_EPILOG_LCSSA:%.*]]
; CHECK:       for.end.loopexit.epilog-lcssa:
; CHECK-NEXT:    br label [[FOR_END_LOOPEXIT]]
; CHECK:       for.end.loopexit:
; CHECK-NEXT:    br label [[FOR_END]]
; CHECK:       for.end:
; CHECK-NEXT:    ret void
; CHECK:       for.outer.epil.1:
; CHECK-NEXT:    br label [[FOR_INNER_EPIL_1:%.*]]
; CHECK:       for.inner.epil.1:
; CHECK-NEXT:    [[J_EPIL_1:%.*]] = phi i32 [ 0, [[FOR_OUTER_EPIL_1]] ], [ [[INC_EPIL_1:%.*]], [[FOR_INNER_EPIL_1]] ]
; CHECK-NEXT:    [[SUM_EPIL_1:%.*]] = phi i32 [ 0, [[FOR_OUTER_EPIL_1]] ], [ [[ADD_EPIL_1:%.*]], [[FOR_INNER_EPIL_1]] ]
; CHECK-NEXT:    [[ARRAYIDX_EPIL_1:%.*]] = getelementptr inbounds i32, i32* [[B]], i32 [[J_EPIL_1]]
; CHECK-NEXT:    [[TMP7:%.*]] = load i32, i32* [[ARRAYIDX_EPIL_1]], align 4, !tbaa !0
; CHECK-NEXT:    [[ADD_EPIL_1]] = add i32 [[TMP7]], [[SUM_EPIL_1]]
; CHECK-NEXT:    [[INC_EPIL_1]] = add nuw i32 [[J_EPIL_1]], 1
; CHECK-NEXT:    [[EXITCOND_EPIL_1:%.*]] = icmp eq i32 [[INC_EPIL_1]], [[J]]
; CHECK-NEXT:    br i1 [[EXITCOND_EPIL_1]], label [[FOR_LATCH_EPIL_1:%.*]], label [[FOR_INNER_EPIL_1]]
; CHECK:       for.latch.epil.1:
; CHECK-NEXT:    [[ADD_LCSSA_EPIL_1:%.*]] = phi i32 [ [[ADD_EPIL_1]], [[FOR_INNER_EPIL_1]] ]
; CHECK-NEXT:    [[ARRAYIDX6_EPIL_1:%.*]] = getelementptr inbounds i32, i32* [[A]], i32 [[ADD8_EPIL]]
; CHECK-NEXT:    store i32 [[ADD_LCSSA_EPIL_1]], i32* [[ARRAYIDX6_EPIL_1]], align 4, !tbaa !0
; CHECK-NEXT:    [[ADD8_EPIL_1:%.*]] = add nuw i32 [[ADD8_EPIL]], 1
; CHECK-NEXT:    [[EPIL_ITER_SUB_1:%.*]] = sub i32 [[EPIL_ITER_SUB]], 1
; CHECK-NEXT:    [[EPIL_ITER_CMP_1:%.*]] = icmp ne i32 [[EPIL_ITER_SUB_1]], 0
; CHECK-NEXT:    br i1 [[EPIL_ITER_CMP_1]], label [[FOR_OUTER_EPIL_2:%.*]], label [[FOR_END_LOOPEXIT_EPILOG_LCSSA]]
; CHECK:       for.outer.epil.2:
; CHECK-NEXT:    br label [[FOR_INNER_EPIL_2:%.*]]
; CHECK:       for.inner.epil.2:
; CHECK-NEXT:    [[J_EPIL_2:%.*]] = phi i32 [ 0, [[FOR_OUTER_EPIL_2]] ], [ [[INC_EPIL_2:%.*]], [[FOR_INNER_EPIL_2]] ]
; CHECK-NEXT:    [[SUM_EPIL_2:%.*]] = phi i32 [ 0, [[FOR_OUTER_EPIL_2]] ], [ [[ADD_EPIL_2:%.*]], [[FOR_INNER_EPIL_2]] ]
; CHECK-NEXT:    [[ARRAYIDX_EPIL_2:%.*]] = getelementptr inbounds i32, i32* [[B]], i32 [[J_EPIL_2]]
; CHECK-NEXT:    [[TMP8:%.*]] = load i32, i32* [[ARRAYIDX_EPIL_2]], align 4, !tbaa !0
; CHECK-NEXT:    [[ADD_EPIL_2]] = add i32 [[TMP8]], [[SUM_EPIL_2]]
; CHECK-NEXT:    [[INC_EPIL_2]] = add nuw i32 [[J_EPIL_2]], 1
; CHECK-NEXT:    [[EXITCOND_EPIL_2:%.*]] = icmp eq i32 [[INC_EPIL_2]], [[J]]
; CHECK-NEXT:    br i1 [[EXITCOND_EPIL_2]], label [[FOR_LATCH_EPIL_2:%.*]], label [[FOR_INNER_EPIL_2]]
; CHECK:       for.latch.epil.2:
; CHECK-NEXT:    [[ADD_LCSSA_EPIL_2:%.*]] = phi i32 [ [[ADD_EPIL_2]], [[FOR_INNER_EPIL_2]] ]
; CHECK-NEXT:    [[ARRAYIDX6_EPIL_2:%.*]] = getelementptr inbounds i32, i32* [[A]], i32 [[ADD8_EPIL_1]]
; CHECK-NEXT:    store i32 [[ADD_LCSSA_EPIL_2]], i32* [[ARRAYIDX6_EPIL_2]], align 4, !tbaa !0
; CHECK-NEXT:    [[ADD8_EPIL_2:%.*]] = add nuw i32 [[ADD8_EPIL_1]], 1
; CHECK-NEXT:    [[EPIL_ITER_SUB_2:%.*]] = sub i32 [[EPIL_ITER_SUB_1]], 1
; CHECK-NEXT:    br label [[FOR_END_LOOPEXIT_EPILOG_LCSSA]]
define void @test1(i32 %I, i32 %J, i32* noalias nocapture %A, i32* noalias nocapture readonly %B) #0 {
entry:
  %cmp = icmp ne i32 %J, 0
  %cmpJ = icmp ne i32 %I, 0
  %or.cond = and i1 %cmp, %cmpJ
  br i1 %or.cond, label %for.outer.preheader, label %for.end

for.outer.preheader:
  br label %for.outer

for.outer:
  %i = phi i32 [ %add8, %for.latch ], [ 0, %for.outer.preheader ]
  br label %for.inner

for.inner:
  %j = phi i32 [ 0, %for.outer ], [ %inc, %for.inner ]
  %sum = phi i32 [ 0, %for.outer ], [ %add, %for.inner ]
  %arrayidx = getelementptr inbounds i32, i32* %B, i32 %j
  %0 = load i32, i32* %arrayidx, align 4, !tbaa !5
  %add = add i32 %0, %sum
  %inc = add nuw i32 %j, 1
  %exitcond = icmp eq i32 %inc, %J
  br i1 %exitcond, label %for.latch, label %for.inner

for.latch:
  %add.lcssa = phi i32 [ %add, %for.inner ]
  %arrayidx6 = getelementptr inbounds i32, i32* %A, i32 %i
  store i32 %add.lcssa, i32* %arrayidx6, align 4, !tbaa !5
  %add8 = add nuw i32 %i, 1
  %exitcond25 = icmp eq i32 %add8, %I
  br i1 %exitcond25, label %for.end.loopexit, label %for.outer

for.end.loopexit:
  br label %for.end

for.end:
  ret void
}


; CHECK-LABEL: test2
; Tests for(i) { sum = A[i]; for(j) sum += B[j]; A[i] = sum; }
; A[i] load/store dependency should not block unroll-and-jam
; CHECK: for.outer:
; CHECK:   %i = phi i32 [ %add9.3, %for.latch ], [ 0, %for.outer.preheader.new ]
; CHECK:   %niter = phi i32 [ %unroll_iter, %for.outer.preheader.new ], [ %niter.nsub.3, %for.latch ]
; CHECK:   br label %for.inner
; CHECK: for.inner:
; CHECK:   %j = phi i32 [ 0, %for.outer ], [ %inc, %for.inner ]
; CHECK:   %sum = phi i32 [ %2, %for.outer ], [ %add, %for.inner ]
; CHECK:   %j.1 = phi i32 [ 0, %for.outer ], [ %inc.1, %for.inner ]
; CHECK:   %sum.1 = phi i32 [ %3, %for.outer ], [ %add.1, %for.inner ]
; CHECK:   %j.2 = phi i32 [ 0, %for.outer ], [ %inc.2, %for.inner ]
; CHECK:   %sum.2 = phi i32 [ %4, %for.outer ], [ %add.2, %for.inner ]
; CHECK:   %j.3 = phi i32 [ 0, %for.outer ], [ %inc.3, %for.inner ]
; CHECK:   %sum.3 = phi i32 [ %5, %for.outer ], [ %add.3, %for.inner ]
; CHECK:   br i1 %exitcond.3, label %for.latch, label %for.inner
; CHECK: for.latch:
; CHECK:   %add.lcssa = phi i32 [ %add, %for.inner ]
; CHECK:   %add.lcssa.1 = phi i32 [ %add.1, %for.inner ]
; CHECK:   %add.lcssa.2 = phi i32 [ %add.2, %for.inner ]
; CHECK:   %add.lcssa.3 = phi i32 [ %add.3, %for.inner ]
; CHECK:   br i1 %niter.ncmp.3, label %for.end10.loopexit.unr-lcssa.loopexit, label %for.outer
; CHECK: for.end10.loopexit.unr-lcssa.loopexit:
define void @test2(i32 %I, i32 %J, i32* noalias nocapture %A, i32* noalias nocapture readonly %B) #0 {
entry:
  %cmp = icmp ne i32 %J, 0
  %cmp125 = icmp ne i32 %I, 0
  %or.cond = and i1 %cmp, %cmp125
  br i1 %or.cond, label %for.outer.preheader, label %for.end10

for.outer.preheader:
  br label %for.outer

for.outer:
  %i = phi i32 [ %add9, %for.latch ], [ 0, %for.outer.preheader ]
  %arrayidx = getelementptr inbounds i32, i32* %A, i32 %i
  %0 = load i32, i32* %arrayidx, align 4, !tbaa !5
  br label %for.inner

for.inner:
  %j = phi i32 [ 0, %for.outer ], [ %inc, %for.inner ]
  %sum = phi i32 [ %0, %for.outer ], [ %add, %for.inner ]
  %arrayidx6 = getelementptr inbounds i32, i32* %B, i32 %j
  %1 = load i32, i32* %arrayidx6, align 4, !tbaa !5
  %add = add i32 %1, %sum
  %inc = add nuw i32 %j, 1
  %exitcond = icmp eq i32 %inc, %J
  br i1 %exitcond, label %for.latch, label %for.inner

for.latch:
  %add.lcssa = phi i32 [ %add, %for.inner ]
  store i32 %add.lcssa, i32* %arrayidx, align 4, !tbaa !5
  %add9 = add nuw i32 %i, 1
  %exitcond28 = icmp eq i32 %add9, %I
  br i1 %exitcond28, label %for.end10.loopexit, label %for.outer

for.end10.loopexit:
  br label %for.end10

for.end10:
  ret void
}


; CHECK-LABEL: test3
; Tests Complete unroll-and-jam of the outer loop
; CHECK: for.outer:
; CHECK:   br label %for.inner
; CHECK: for.inner:
; CHECK:   %j = phi i32 [ 0, %for.outer ], [ %inc, %for.inner ]
; CHECK:   %sum = phi i32 [ 0, %for.outer ], [ %add, %for.inner ]
; CHECK:   %j.1 = phi i32 [ 0, %for.outer ], [ %inc.1, %for.inner ]
; CHECK:   %sum.1 = phi i32 [ 0, %for.outer ], [ %add.1, %for.inner ]
; CHECK:   %j.2 = phi i32 [ 0, %for.outer ], [ %inc.2, %for.inner ]
; CHECK:   %sum.2 = phi i32 [ 0, %for.outer ], [ %add.2, %for.inner ]
; CHECK:   %j.3 = phi i32 [ 0, %for.outer ], [ %inc.3, %for.inner ]
; CHECK:   %sum.3 = phi i32 [ 0, %for.outer ], [ %add.3, %for.inner ]
; CHECK:   br i1 %exitcond.3, label %for.latch, label %for.inner
; CHECK: for.latch:
; CHECK:   %add.lcssa = phi i32 [ %add, %for.inner ]
; CHECK:   %add.lcssa.1 = phi i32 [ %add.1, %for.inner ]
; CHECK:   %add.lcssa.2 = phi i32 [ %add.2, %for.inner ]
; CHECK:   %add.lcssa.3 = phi i32 [ %add.3, %for.inner ]
; CHECK:   br label %for.end
; CHECK: for.end:
define void @test3(i32 %I, i32 %J, i32* noalias nocapture %A, i32* noalias nocapture readonly %B) #0 {
entry:
  %cmp = icmp eq i32 %J, 0
  br i1 %cmp, label %for.end, label %for.preheader

for.preheader:
  br label %for.outer

for.outer:
  %i = phi i32 [ %add8, %for.latch ], [ 0, %for.preheader ]
  br label %for.inner

for.inner:
  %j = phi i32 [ 0, %for.outer ], [ %inc, %for.inner ]
  %sum = phi i32 [ 0, %for.outer ], [ %add, %for.inner ]
  %arrayidx = getelementptr inbounds i32, i32* %B, i32 %j
  %0 = load i32, i32* %arrayidx, align 4, !tbaa !5
  %sub = add i32 %sum, 10
  %add = sub i32 %sub, %0
  %inc = add nuw i32 %j, 1
  %exitcond = icmp eq i32 %inc, %J
  br i1 %exitcond, label %for.latch, label %for.inner

for.latch:
  %arrayidx6 = getelementptr inbounds i32, i32* %A, i32 %i
  store i32 %add, i32* %arrayidx6, align 4, !tbaa !5
  %add8 = add nuw nsw i32 %i, 1
  %exitcond23 = icmp eq i32 %add8, 4
  br i1 %exitcond23, label %for.end, label %for.outer

for.end:
  ret void
}


; CHECK-LABEL: test4
; Tests Complete unroll-and-jam with a trip count of 1
; CHECK: for.outer:
; CHECK:   br label %for.inner
; CHECK: for.inner:
; CHECK:   %j = phi i32 [ 0, %for.outer ], [ %inc, %for.inner ]
; CHECK:   %sum = phi i32 [ 0, %for.outer ], [ %add, %for.inner ]
; CHECK:   br i1 %exitcond, label %for.latch, label %for.inner
; CHECK: for.latch:
; CHECK:   %add.lcssa = phi i32 [ %add, %for.inner ]
; CHECK:   br label %for.end
; CHECK: for.end:
define void @test4(i32 %I, i32 %J, i32* noalias nocapture %A, i32* noalias nocapture readonly %B) #0 {
entry:
  %cmp = icmp eq i32 %J, 0
  br i1 %cmp, label %for.end, label %for.preheader

for.preheader:
  br label %for.outer

for.outer:
  %i = phi i32 [ %add8, %for.latch ], [ 0, %for.preheader ]
  br label %for.inner

for.inner:
  %j = phi i32 [ 0, %for.outer ], [ %inc, %for.inner ]
  %sum = phi i32 [ 0, %for.outer ], [ %add, %for.inner ]
  %arrayidx = getelementptr inbounds i32, i32* %B, i32 %j
  %0 = load i32, i32* %arrayidx, align 4, !tbaa !5
  %sub = add i32 %sum, 10
  %add = sub i32 %sub, %0
  %inc = add nuw i32 %j, 1
  %exitcond = icmp eq i32 %inc, %J
  br i1 %exitcond, label %for.latch, label %for.inner

for.latch:
  %arrayidx6 = getelementptr inbounds i32, i32* %A, i32 %i
  store i32 %add, i32* %arrayidx6, align 4, !tbaa !5
  %add8 = add nuw nsw i32 %i, 1
  %exitcond23 = icmp eq i32 %add8, 1
  br i1 %exitcond23, label %for.end, label %for.outer

for.end:
  ret void
}


; CHECK-LABEL: test5
; Multiple SubLoopBlocks
; CHECK: for.outer:
; CHECK:   br label %for.inner
; CHECK: for.inner:
; CHECK:   %inc8.sink15 = phi i32 [ 0, %for.outer ], [ %inc8, %for.inc.1 ]
; CHECK:   %inc8.sink15.1 = phi i32 [ 0, %for.outer ], [ %inc8.1, %for.inc.1 ]
; CHECK:   br label %for.inner2
; CHECK: for.inner2:
; CHECK:   br i1 %tobool, label %for.cond4, label %for.inc
; CHECK: for.cond4:
; CHECK:   br i1 %tobool.1, label %for.cond4a, label %for.inc
; CHECK: for.cond4a:
; CHECK:   br label %for.inc
; CHECK: for.inc:
; CHECK:   br i1 %tobool.11, label %for.cond4.1, label %for.inc.1
; CHECK: for.latch:
; CHECK:   br label %for.end
; CHECK: for.end:
; CHECK:   ret i32 0
; CHECK: for.cond4.1:
; CHECK:   br i1 %tobool.1.1, label %for.cond4a.1, label %for.inc.1
; CHECK: for.cond4a.1:
; CHECK:   br label %for.inc.1
; CHECK: for.inc.1:
; CHECK:   br i1 %exitcond.1, label %for.latch, label %for.inner
@a = hidden global [1 x i32] zeroinitializer, align 4
define i32 @test5() #0 {
entry:
  br label %for.outer

for.outer:
  %.sink16 = phi i32 [ 0, %entry ], [ %add, %for.latch ]
  br label %for.inner

for.inner:
  %inc8.sink15 = phi i32 [ 0, %for.outer ], [ %inc8, %for.inc ]
  br label %for.inner2

for.inner2:
  %l1 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @a, i32 0, i32 0), align 4
  %tobool = icmp eq i32 %l1, 0
  br i1 %tobool, label %for.cond4, label %for.inc

for.cond4:
  %l0 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @a, i32 1, i32 0), align 4
  %tobool.1 = icmp eq i32 %l0, 0
  br i1 %tobool.1, label %for.cond4a, label %for.inc

for.cond4a:
  br label %for.inc

for.inc:
  %l2 = phi i32 [ 0, %for.inner2 ], [ 1, %for.cond4 ], [ 2, %for.cond4a ]
  %inc8 = add nuw nsw i32 %inc8.sink15, 1
  %exitcond = icmp eq i32 %inc8, 3
  br i1 %exitcond, label %for.latch, label %for.inner

for.latch:
  %.lcssa = phi i32 [ %l2, %for.inc ]
  %conv11 = and i32 %.sink16, 255
  %add = add nuw nsw i32 %conv11, 4
  %cmp = icmp eq i32 %add, 8
  br i1 %cmp, label %for.end, label %for.outer

for.end:
  %.lcssa.lcssa = phi i32 [ %.lcssa, %for.latch ]
  ret i32 0
}


; CHECK-LABEL: test6
; Test odd uses of phi nodes
; CHECK: for.outer:
; CHECK:   br label %for.inner
; CHECK: for.inner:
; CHECK:   br i1 %exitcond.3, label %for.inner, label %for.latch
; CHECK: for.latch:
; CHECK:   br label %for.end
; CHECK: for.end:
; CHECK:   ret i32 0
@f = hidden global i32 0, align 4
define i32 @test6() #0 {
entry:
  %f.promoted10 = load i32, i32* @f, align 4, !tbaa !5
  br label %for.outer

for.outer:
  %p0 = phi i32 [ %f.promoted10, %entry ], [ 2, %for.latch ]
  %inc5.sink9 = phi i32 [ 2, %entry ], [ %inc5, %for.latch ]
  br label %for.inner

for.inner:
  %p1 = phi i32 [ %p0, %for.outer ], [ 2, %for.inner ]
  %inc.sink8 = phi i32 [ 0, %for.outer ], [ %inc, %for.inner ]
  %inc = add nuw nsw i32 %inc.sink8, 1
  %exitcond = icmp ne i32 %inc, 7
  br i1 %exitcond, label %for.inner, label %for.latch

for.latch:
  %.lcssa = phi i32 [ %p1, %for.inner ]
  %inc5 = add nuw nsw i32 %inc5.sink9, 1
  %exitcond11 = icmp ne i32 %inc5, 7
  br i1 %exitcond11, label %for.outer, label %for.end

for.end:
  %.lcssa.lcssa = phi i32 [ %.lcssa, %for.latch ]
  %inc.lcssa.lcssa = phi i32 [ 7, %for.latch ]
  ret i32 0
}


; CHECK-LABEL: test7
; Has a positive dependency between two stores. Still valid.
; The negative dependecy is in unroll-and-jam-disabled.ll
; CHECK: for.outer:
; CHECK:   %i = phi i32 [ %add.3, %for.latch ], [ 0, %for.preheader.new ]
; CHECK:   %niter = phi i32 [ %unroll_iter, %for.preheader.new ], [ %niter.nsub.3, %for.latch ]
; CHECK:   br label %for.inner
; CHECK: for.latch:
; CHECK:   %add9.lcssa = phi i32 [ %add9, %for.inner ]
; CHECK:   %add9.lcssa.1 = phi i32 [ %add9.1, %for.inner ]
; CHECK:   %add9.lcssa.2 = phi i32 [ %add9.2, %for.inner ]
; CHECK:   %add9.lcssa.3 = phi i32 [ %add9.3, %for.inner ]
; CHECK:   br i1 %niter.ncmp.3, label %for.end.loopexit.unr-lcssa.loopexit, label %for.outer
; CHECK: for.inner:
; CHECK:   %sum = phi i32 [ 0, %for.outer ], [ %add9, %for.inner ]
; CHECK:   %j = phi i32 [ 0, %for.outer ], [ %add10, %for.inner ]
; CHECK:   %sum.1 = phi i32 [ 0, %for.outer ], [ %add9.1, %for.inner ]
; CHECK:   %j.1 = phi i32 [ 0, %for.outer ], [ %add10.1, %for.inner ]
; CHECK:   %sum.2 = phi i32 [ 0, %for.outer ], [ %add9.2, %for.inner ]
; CHECK:   %j.2 = phi i32 [ 0, %for.outer ], [ %add10.2, %for.inner ]
; CHECK:   %sum.3 = phi i32 [ 0, %for.outer ], [ %add9.3, %for.inner ]
; CHECK:   %j.3 = phi i32 [ 0, %for.outer ], [ %add10.3, %for.inner ]
; CHECK:   br i1 %exitcond.3, label %for.latch, label %for.inner
; CHECK: for.end.loopexit.unr-lcssa.loopexit:
define void @test7(i32 %I, i32 %J, i32* noalias nocapture %A, i32* noalias nocapture readonly %B) #0 {
entry:
  %cmp = icmp ne i32 %J, 0
  %cmp128 = icmp ne i32 %I, 0
  %or.cond = and i1 %cmp128, %cmp
  br i1 %or.cond, label %for.preheader, label %for.end

for.preheader:
  br label %for.outer

for.outer:
  %i = phi i32 [ %add, %for.latch ], [ 0, %for.preheader ]
  %arrayidx = getelementptr inbounds i32, i32* %A, i32 %i
  store i32 0, i32* %arrayidx, align 4, !tbaa !5
  %add = add nuw i32 %i, 1
  %arrayidx2 = getelementptr inbounds i32, i32* %A, i32 %add
  store i32 2, i32* %arrayidx2, align 4, !tbaa !5
  br label %for.inner

for.latch:
  store i32 %add9, i32* %arrayidx, align 4, !tbaa !5
  %exitcond30 = icmp eq i32 %add, %I
  br i1 %exitcond30, label %for.end, label %for.outer

for.inner:
  %sum = phi i32 [ 0, %for.outer ], [ %add9, %for.inner ]
  %j = phi i32 [ 0, %for.outer ], [ %add10, %for.inner ]
  %arrayidx7 = getelementptr inbounds i32, i32* %B, i32 %j
  %l1 = load i32, i32* %arrayidx7, align 4, !tbaa !5
  %add9 = add i32 %l1, %sum
  %add10 = add nuw i32 %j, 1
  %exitcond = icmp eq i32 %add10, %J
  br i1 %exitcond, label %for.latch, label %for.inner

for.end:
  ret void
}


; CHECK-LABEL: test8
; Same as test7 with an extra outer loop nest
; CHECK: for.outest:
; CHECK:   br label %for.outer
; CHECK: for.outer:
; CHECK:   %i = phi i32 [ %add.3, %for.latch ], [ 0, %for.outest.new ]
; CHECK:   %niter = phi i32 [ %unroll_iter, %for.outest.new ], [ %niter.nsub.3, %for.latch ]
; CHECK:   br label %for.inner
; CHECK: for.inner:
; CHECK:   %sum = phi i32 [ 0, %for.outer ], [ %add9, %for.inner ]
; CHECK:   %j = phi i32 [ 0, %for.outer ], [ %add10, %for.inner ]
; CHECK:   %sum.1 = phi i32 [ 0, %for.outer ], [ %add9.1, %for.inner ]
; CHECK:   %j.1 = phi i32 [ 0, %for.outer ], [ %add10.1, %for.inner ]
; CHECK:   %sum.2 = phi i32 [ 0, %for.outer ], [ %add9.2, %for.inner ]
; CHECK:   %j.2 = phi i32 [ 0, %for.outer ], [ %add10.2, %for.inner ]
; CHECK:   %sum.3 = phi i32 [ 0, %for.outer ], [ %add9.3, %for.inner ]
; CHECK:   %j.3 = phi i32 [ 0, %for.outer ], [ %add10.3, %for.inner ]
; CHECK:   br i1 %exitcond.3, label %for.latch, label %for.inner
; CHECK: for.latch:
; CHECK:   %add9.lcssa = phi i32 [ %add9, %for.inner ]
; CHECK:   %add9.lcssa.1 = phi i32 [ %add9.1, %for.inner ]
; CHECK:   %add9.lcssa.2 = phi i32 [ %add9.2, %for.inner ]
; CHECK:   %add9.lcssa.3 = phi i32 [ %add9.3, %for.inner ]
; CHECK:   br i1 %niter.ncmp.3, label %for.cleanup.unr-lcssa.loopexit, label %for.outer
; CHECK: for.cleanup.epilog-lcssa:
; CHECK:   br label %for.cleanup
; CHECK: for.cleanup:
; CHECK:   br i1 %exitcond41, label %for.end.loopexit, label %for.outest
; CHECK: for.end.loopexit:
; CHECK:   br label %for.end
define void @test8(i32 %I, i32 %J, i32* noalias nocapture %A, i32* noalias nocapture readonly %B) #0 {
entry:
  %cmp = icmp eq i32 %J, 0
  %cmp336 = icmp eq i32 %I, 0
  %or.cond = or i1 %cmp, %cmp336
  br i1 %or.cond, label %for.end, label %for.preheader

for.preheader:
  br label %for.outest

for.outest:
  %x.038 = phi i32 [ %inc, %for.cleanup ], [ 0, %for.preheader ]
  br label %for.outer

for.outer:
  %i = phi i32 [ %add, %for.latch ], [ 0, %for.outest ]
  %arrayidx = getelementptr inbounds i32, i32* %A, i32 %i
  store i32 0, i32* %arrayidx, align 4, !tbaa !5
  %add = add nuw i32 %i, 1
  %arrayidx6 = getelementptr inbounds i32, i32* %A, i32 %add
  store i32 2, i32* %arrayidx6, align 4, !tbaa !5
  br label %for.inner

for.inner:
  %sum = phi i32 [ 0, %for.outer ], [ %add9, %for.inner ]
  %j = phi i32 [ 0, %for.outer ], [ %add10, %for.inner ]
  %arrayidx11 = getelementptr inbounds i32, i32* %B, i32 %j
  %l1 = load i32, i32* %arrayidx11, align 4, !tbaa !5
  %add9 = add i32 %l1, %sum
  %add10 = add nuw i32 %j, 1
  %exitcond = icmp eq i32 %add10, %J
  br i1 %exitcond, label %for.latch, label %for.inner

for.latch:
  store i32 %add9, i32* %arrayidx, align 4, !tbaa !5
  %exitcond39 = icmp eq i32 %add, %I
  br i1 %exitcond39, label %for.cleanup, label %for.outer

for.cleanup:
  %inc = add nuw nsw i32 %x.038, 1
  %exitcond41 = icmp eq i32 %inc, 5
  br i1 %exitcond41, label %for.end, label %for.outest

for.end:
  ret void
}


; CHECK-LABEL: test9
; Same as test1 with tbaa, not noalias
; CHECK: for.outer:
; CHECK:   %i = phi i32 [ %add8.3, %for.latch ], [ 0, %for.outer.preheader.new ]
; CHECK:   %niter = phi i32 [ %unroll_iter, %for.outer.preheader.new ], [ %niter.nsub.3, %for.latch ]
; CHECK:   br label %for.inner
; CHECK: for.inner:
; CHECK:   %j = phi i32 [ 0, %for.outer ], [ %inc, %for.inner ]
; CHECK:   %sum = phi i32 [ 0, %for.outer ], [ %add, %for.inner ]
; CHECK:   %j.1 = phi i32 [ 0, %for.outer ], [ %inc.1, %for.inner ]
; CHECK:   %sum.1 = phi i32 [ 0, %for.outer ], [ %add.1, %for.inner ]
; CHECK:   %j.2 = phi i32 [ 0, %for.outer ], [ %inc.2, %for.inner ]
; CHECK:   %sum.2 = phi i32 [ 0, %for.outer ], [ %add.2, %for.inner ]
; CHECK:   %j.3 = phi i32 [ 0, %for.outer ], [ %inc.3, %for.inner ]
; CHECK:   %sum.3 = phi i32 [ 0, %for.outer ], [ %add.3, %for.inner ]
; CHECK:   br i1 %exitcond.3, label %for.latch, label %for.inner
; CHECK: for.latch:
; CHECK:   %add.lcssa = phi i32 [ %add, %for.inner ]
; CHECK:   %add.lcssa.1 = phi i32 [ %add.1, %for.inner ]
; CHECK:   %add.lcssa.2 = phi i32 [ %add.2, %for.inner ]
; CHECK:   %add.lcssa.3 = phi i32 [ %add.3, %for.inner ]
; CHECK:   br i1 %niter.ncmp.3, label %for.end.loopexit.unr-lcssa.loopexit, label %for.outer
; CHECK: for.end.loopexit.unr-lcssa.loopexit:
define void @test9(i32 %I, i32 %J, i32* nocapture %A, i16* nocapture readonly %B) #0 {
entry:
  %cmp = icmp ne i32 %J, 0
  %cmpJ = icmp ne i32 %I, 0
  %or.cond = and i1 %cmp, %cmpJ
  br i1 %or.cond, label %for.outer.preheader, label %for.end

for.outer.preheader:
  br label %for.outer

for.outer:
  %i = phi i32 [ %add8, %for.latch ], [ 0, %for.outer.preheader ]
  br label %for.inner

for.inner:
  %j = phi i32 [ 0, %for.outer ], [ %inc, %for.inner ]
  %sum = phi i32 [ 0, %for.outer ], [ %add, %for.inner ]
  %arrayidx = getelementptr inbounds i16, i16* %B, i32 %j
  %0 = load i16, i16* %arrayidx, align 4, !tbaa !9
  %sext = sext i16 %0 to i32
  %add = add i32 %sext, %sum
  %inc = add nuw i32 %j, 1
  %exitcond = icmp eq i32 %inc, %J
  br i1 %exitcond, label %for.latch, label %for.inner

for.latch:
  %add.lcssa = phi i32 [ %add, %for.inner ]
  %arrayidx6 = getelementptr inbounds i32, i32* %A, i32 %i
  store i32 %add.lcssa, i32* %arrayidx6, align 4, !tbaa !5
  %add8 = add nuw i32 %i, 1
  %exitcond25 = icmp eq i32 %add8, %I
  br i1 %exitcond25, label %for.end.loopexit, label %for.outer

for.end.loopexit:
  br label %for.end

for.end:
  ret void
}


; CHECK-LABEL: test10
; Be careful not to incorrectly update the exit phi nodes
; CHECK: %dec.lcssa.lcssa.ph.ph = phi i64 [ 0, %for.inc24 ]
%struct.a = type { i64 }
@g = common global %struct.a zeroinitializer, align 8
@c = common global [1 x i8] zeroinitializer, align 1
define signext i16 @test10(i32 %k) #0 {
entry:
  %0 = load i8, i8* getelementptr inbounds ([1 x i8], [1 x i8]* @c, i64 0, i64 0), align 1
  %tobool9 = icmp eq i8 %0, 0
  %tobool13 = icmp ne i32 %k, 0
  br label %for.body

for.body:
  %storemerge82 = phi i64 [ 0, %entry ], [ %inc25, %for.inc24 ]
  br label %for.body2

for.body2:
  %storemerge = phi i64 [ 4, %for.body ], [ %dec, %for.inc21 ]
  br i1 %tobool9, label %for.body2.split, label %for.body2.split2

for.body2.split2:
  br i1 %tobool13, label %for.inc21, label %for.inc21.if

for.body2.split:
  br i1 %tobool13, label %for.inc21, label %for.inc21.then

for.inc21.if:
  %storemerge.1 = phi i64 [ 0, %for.body2.split2 ]
  br label %for.inc21

for.inc21.then:
  %storemerge.2 = phi i64 [ 0, %for.body2.split ]
  %storemerge.3 = phi i32 [ 0, %for.body2.split ]
  br label %for.inc21

for.inc21:
  %storemerge.4 = phi i64 [ %storemerge.1, %for.inc21.if ], [ %storemerge.2, %for.inc21.then ], [ 4, %for.body2.split2 ], [ 4, %for.body2.split ]
  %storemerge.5 = phi i32 [ 0, %for.inc21.if ], [ %storemerge.3, %for.inc21.then ], [ 0, %for.body2.split2 ], [ 0, %for.body2.split ]
  %dec = add nsw i64 %storemerge, -1
  %tobool = icmp eq i64 %dec, 0
  br i1 %tobool, label %for.inc24, label %for.body2

for.inc24:
  %storemerge.4.lcssa = phi i64 [ %storemerge.4, %for.inc21 ]
  %storemerge.5.lcssa = phi i32 [ %storemerge.5, %for.inc21 ]
  %inc25 = add nuw nsw i64 %storemerge82, 1
  %exitcond = icmp ne i64 %inc25, 5
  br i1 %exitcond, label %for.body, label %for.end26

for.end26:
  %dec.lcssa.lcssa = phi i64 [ 0, %for.inc24 ]
  %storemerge.4.lcssa.lcssa = phi i64 [ %storemerge.4.lcssa, %for.inc24 ]
  %storemerge.5.lcssa.lcssa = phi i32 [ %storemerge.5.lcssa, %for.inc24 ]
  store i64 %dec.lcssa.lcssa, i64* getelementptr inbounds (%struct.a, %struct.a* @g, i64 0, i32 0), align 8
  ret i16 0
}


!5 = !{!6, !6, i64 0}
!6 = !{!"int", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C/C++ TBAA"}
!9 = !{!10, !10, i64 0}
!10 = !{!"short", !7, i64 0}
