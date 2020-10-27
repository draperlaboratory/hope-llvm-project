; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -indvars -S < %s | FileCheck %s
; RUN: opt -passes=indvars -S < %s | FileCheck %s

; TODO: should be able to remove the range check basing on the following facts:
; 0 <= len <= MAX_INT [1];
; iv starts from len and goes down stopping at zero and [1], therefore
;   0 <= iv <= len [2];
; 3. In range_check_block, iv != 0 and [2], therefore
;   1 <= iv <= len [3];
; 4. iv.next = iv - 1 and [3], therefore
;   0 <= iv.next < len.
define void @test_predicated_simple_unsigned(i32* %p, i32* %arr) {
; CHECK-LABEL: @test_predicated_simple_unsigned(
; CHECK-NEXT:  preheader:
; CHECK-NEXT:    [[LEN:%.*]] = load i32, i32* [[P:%.*]], align 4, [[RNG0:!range !.*]]
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ [[LEN]], [[PREHEADER:%.*]] ], [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[ZERO_COND:%.*]] = icmp eq i32 [[IV]], 0
; CHECK-NEXT:    br i1 [[ZERO_COND]], label [[EXIT:%.*]], label [[RANGE_CHECK_BLOCK:%.*]]
; CHECK:       range_check_block:
; CHECK-NEXT:    [[IV_NEXT]] = sub i32 [[IV]], 1
; CHECK-NEXT:    [[RANGE_CHECK:%.*]] = icmp ult i32 [[IV_NEXT]], [[LEN]]
; CHECK-NEXT:    br i1 [[RANGE_CHECK]], label [[BACKEDGE]], label [[FAIL:%.*]]
; CHECK:       backedge:
; CHECK-NEXT:    [[EL_PTR:%.*]] = getelementptr i32, i32* [[P]], i32 [[IV]]
; CHECK-NEXT:    [[EL:%.*]] = load i32, i32* [[EL_PTR]], align 4
; CHECK-NEXT:    [[LOOP_COND:%.*]] = icmp eq i32 [[EL]], 0
; CHECK-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
; CHECK:       fail:
; CHECK-NEXT:    unreachable
;
preheader:
  %len = load i32, i32* %p, !range !0
  br label %loop

loop:
  %iv = phi i32 [%len, %preheader], [%iv.next, %backedge]
  %zero_cond = icmp eq i32 %iv, 0
  br i1 %zero_cond, label %exit, label %range_check_block

range_check_block:
  %iv.next = sub i32 %iv, 1
  %range_check = icmp ult i32 %iv.next, %len
  br i1 %range_check, label %backedge, label %fail

backedge:
  %el.ptr = getelementptr i32, i32* %p, i32 %iv
  %el = load i32, i32* %el.ptr
  %loop.cond = icmp eq i32 %el, 0
  br i1 %loop.cond, label %loop, label %exit

exit:
  ret void

fail:
  unreachable
}

define void @test_predicated_simple_signed(i32* %p, i32* %arr) {
; CHECK-LABEL: @test_predicated_simple_signed(
; CHECK-NEXT:  preheader:
; CHECK-NEXT:    [[LEN:%.*]] = load i32, i32* [[P:%.*]], align 4, [[RNG0]]
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ [[LEN]], [[PREHEADER:%.*]] ], [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[ZERO_COND:%.*]] = icmp eq i32 [[IV]], 0
; CHECK-NEXT:    br i1 [[ZERO_COND]], label [[EXIT:%.*]], label [[RANGE_CHECK_BLOCK:%.*]]
; CHECK:       range_check_block:
; CHECK-NEXT:    [[IV_NEXT]] = sub i32 [[IV]], 1
; CHECK-NEXT:    [[RANGE_CHECK:%.*]] = icmp slt i32 [[IV_NEXT]], [[LEN]]
; CHECK-NEXT:    br i1 [[RANGE_CHECK]], label [[BACKEDGE]], label [[FAIL:%.*]]
; CHECK:       backedge:
; CHECK-NEXT:    [[EL_PTR:%.*]] = getelementptr i32, i32* [[P]], i32 [[IV]]
; CHECK-NEXT:    [[EL:%.*]] = load i32, i32* [[EL_PTR]], align 4
; CHECK-NEXT:    [[LOOP_COND:%.*]] = icmp eq i32 [[EL]], 0
; CHECK-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
; CHECK:       fail:
; CHECK-NEXT:    unreachable
;
preheader:
  %len = load i32, i32* %p, !range !0
  br label %loop

loop:
  %iv = phi i32 [%len, %preheader], [%iv.next, %backedge]
  %zero_cond = icmp eq i32 %iv, 0
  br i1 %zero_cond, label %exit, label %range_check_block

range_check_block:
  %iv.next = sub i32 %iv, 1
  %range_check = icmp slt i32 %iv.next, %len
  br i1 %range_check, label %backedge, label %fail

backedge:
  %el.ptr = getelementptr i32, i32* %p, i32 %iv
  %el = load i32, i32* %el.ptr
  %loop.cond = icmp eq i32 %el, 0
  br i1 %loop.cond, label %loop, label %exit

exit:
  ret void

fail:
  unreachable
}

; Cannot remove checks because the range check fails on the last iteration.
define void @predicated_outside_loop_signed_neg(i32 %arg) nounwind #0 {
; CHECK-LABEL: @predicated_outside_loop_signed_neg(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SUB1:%.*]] = sub nsw i32 [[ARG:%.*]], 1
; CHECK-NEXT:    [[CMP1:%.*]] = icmp slt i32 0, [[SUB1]]
; CHECK-NEXT:    br i1 [[CMP1]], label [[OUTER_PREHEADER:%.*]], label [[EXIT:%.*]]
; CHECK:       outer.preheader:
; CHECK-NEXT:    br label [[OUTER:%.*]]
; CHECK:       outer:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ [[I_INC:%.*]], [[OUTER_INC:%.*]] ], [ 0, [[OUTER_PREHEADER]] ]
; CHECK-NEXT:    [[SUB2:%.*]] = sub nsw i32 [[ARG]], [[I]]
; CHECK-NEXT:    [[SUB3:%.*]] = sub nsw i32 [[SUB2]], 1
; CHECK-NEXT:    [[CMP2:%.*]] = icmp slt i32 0, [[SUB3]]
; CHECK-NEXT:    br i1 [[CMP2]], label [[INNER_PH:%.*]], label [[OUTER_INC]]
; CHECK:       inner.ph:
; CHECK-NEXT:    br label [[INNER:%.*]]
; CHECK:       inner:
; CHECK-NEXT:    br i1 false, label [[INNER]], label [[OUTER_INC_LOOPEXIT:%.*]]
; CHECK:       outer.inc.loopexit:
; CHECK-NEXT:    br label [[OUTER_INC]]
; CHECK:       outer.inc:
; CHECK-NEXT:    [[I_INC]] = add nuw nsw i32 [[I]], 1
; CHECK-NEXT:    br i1 false, label [[OUTER]], label [[EXIT_LOOPEXIT:%.*]]
; CHECK:       exit.loopexit:
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %sub1 = sub nsw i32 %arg, 1
  %cmp1 = icmp slt i32 0, %sub1
  br i1 %cmp1, label %outer, label %exit

outer:
  %i = phi i32 [ 0, %entry ], [ %i.inc, %outer.inc ]
  %sub2 = sub nsw i32 %arg, %i
  %sub3 = sub nsw i32 %sub2, 1
  %cmp2 = icmp slt i32 0, %sub3
  br i1 %cmp2, label %inner.ph, label %outer.inc

inner.ph:
  br label %inner

inner:
  %j = phi i32 [ 0, %inner.ph ], [ %j.inc, %inner ]
  %j.inc = add nsw i32 %j, 1
  %cmp3 = icmp slt i32 %j.inc, %sub3
  br i1 %cmp3, label %inner, label %outer.inc

outer.inc:
  %i.inc = add nsw i32 %i, 1
  %cmp4 = icmp slt i32 %i.inc, %arg
  br i1 %cmp4, label %outer, label %exit

exit:
  ret void
}

; Range check can be removed.
define void @predicated_outside_loop_signed_pos(i32 %arg) nounwind #0 {
; CHECK-LABEL: @predicated_outside_loop_signed_pos(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SUB1:%.*]] = sub nsw i32 [[ARG:%.*]], 1
; CHECK-NEXT:    [[CMP1:%.*]] = icmp slt i32 0, [[SUB1]]
; CHECK-NEXT:    br i1 [[CMP1]], label [[OUTER_PREHEADER:%.*]], label [[EXIT:%.*]]
; CHECK:       outer.preheader:
; CHECK-NEXT:    br label [[OUTER:%.*]]
; CHECK:       outer:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ [[I_INC:%.*]], [[OUTER_INC:%.*]] ], [ 0, [[OUTER_PREHEADER]] ]
; CHECK-NEXT:    [[SUB2:%.*]] = sub nsw i32 [[ARG]], [[I]]
; CHECK-NEXT:    [[SUB3:%.*]] = sub nsw i32 [[SUB2]], 1
; CHECK-NEXT:    [[CMP2:%.*]] = icmp slt i32 0, [[SUB3]]
; CHECK-NEXT:    br i1 [[CMP2]], label [[INNER_PH:%.*]], label [[OUTER_INC]]
; CHECK:       inner.ph:
; CHECK-NEXT:    br label [[INNER:%.*]]
; CHECK:       inner:
; CHECK-NEXT:    br i1 false, label [[INNER]], label [[OUTER_INC_LOOPEXIT:%.*]]
; CHECK:       outer.inc.loopexit:
; CHECK-NEXT:    br label [[OUTER_INC]]
; CHECK:       outer.inc:
; CHECK-NEXT:    [[I_INC]] = add nuw nsw i32 [[I]], 1
; CHECK-NEXT:    br i1 false, label [[OUTER]], label [[EXIT_LOOPEXIT:%.*]]
; CHECK:       exit.loopexit:
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %sub1 = sub nsw i32 %arg, 1
  %cmp1 = icmp slt i32 0, %sub1
  br i1 %cmp1, label %outer, label %exit

outer:
  %i = phi i32 [ 0, %entry ], [ %i.inc, %outer.inc ]
  %sub2 = sub nsw i32 %arg, %i
  %sub3 = sub nsw i32 %sub2, 1
  %cmp2 = icmp slt i32 0, %sub3
  br i1 %cmp2, label %inner.ph, label %outer.inc

inner.ph:
  br label %inner

inner:
  %j = phi i32 [ 0, %inner.ph ], [ %j.inc, %inner ]
  %j.inc = add nsw i32 %j, 1
  %cmp3 = icmp slt i32 %j.inc, %sub3
  br i1 %cmp3, label %inner, label %outer.inc

outer.inc:
  %i.inc = add nsw i32 %i, 1
  %cmp4 = icmp slt i32 %i.inc, %sub1
  br i1 %cmp4, label %outer, label %exit

exit:
  ret void
}

define void @predicated_outside_loop_unsigned(i32 %arg) nounwind #0 {
; CHECK-LABEL: @predicated_outside_loop_unsigned(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[SUB1:%.*]] = sub nsw i32 [[ARG:%.*]], 1
; CHECK-NEXT:    [[CMP1:%.*]] = icmp slt i32 0, [[SUB1]]
; CHECK-NEXT:    br i1 [[CMP1]], label [[OUTER_PREHEADER:%.*]], label [[EXIT:%.*]]
; CHECK:       outer.preheader:
; CHECK-NEXT:    br label [[OUTER:%.*]]
; CHECK:       outer:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ [[I_INC:%.*]], [[OUTER_INC:%.*]] ], [ 0, [[OUTER_PREHEADER]] ]
; CHECK-NEXT:    [[SUB2:%.*]] = sub nsw i32 [[ARG]], [[I]]
; CHECK-NEXT:    [[SUB3:%.*]] = sub nsw i32 [[SUB2]], 1
; CHECK-NEXT:    [[CMP2:%.*]] = icmp ult i32 0, [[SUB3]]
; CHECK-NEXT:    br i1 [[CMP2]], label [[INNER_PH:%.*]], label [[OUTER_INC]]
; CHECK:       inner.ph:
; CHECK-NEXT:    br label [[INNER:%.*]]
; CHECK:       inner:
; CHECK-NEXT:    br i1 false, label [[INNER]], label [[OUTER_INC_LOOPEXIT:%.*]]
; CHECK:       outer.inc.loopexit:
; CHECK-NEXT:    br label [[OUTER_INC]]
; CHECK:       outer.inc:
; CHECK-NEXT:    [[I_INC]] = add nuw nsw i32 [[I]], 1
; CHECK-NEXT:    br i1 false, label [[OUTER]], label [[EXIT_LOOPEXIT:%.*]]
; CHECK:       exit.loopexit:
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %sub1 = sub nsw i32 %arg, 1
  %cmp1 = icmp slt i32 0, %sub1
  br i1 %cmp1, label %outer, label %exit

outer:
  %i = phi i32 [ 0, %entry ], [ %i.inc, %outer.inc ]
  %sub2 = sub nsw i32 %arg, %i
  %sub3 = sub nsw i32 %sub2, 1
  %cmp2 = icmp ult i32 0, %sub3
  br i1 %cmp2, label %inner.ph, label %outer.inc

inner.ph:
  br label %inner

inner:
  %j = phi i32 [ 0, %inner.ph ], [ %j.inc, %inner ]
  %j.inc = add nsw i32 %j, 1
  %cmp3 = icmp slt i32 %j.inc, %sub3
  br i1 %cmp3, label %inner, label %outer.inc

outer.inc:
  %i.inc = add nsw i32 %i, 1
  %cmp4 = icmp slt i32 %i.inc, %arg
  br i1 %cmp4, label %outer, label %exit

exit:
  ret void
}

; Cannot remove checks because the range check fails on the last iteration.
define void @predicated_inside_loop_signed_neg(i32 %arg) nounwind #0 {
; CHECK-LABEL: @predicated_inside_loop_signed_neg(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[OUTER:%.*]]
; CHECK:       outer:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[I_INC:%.*]], [[OUTER_INC:%.*]] ]
; CHECK-NEXT:    [[SUB1:%.*]] = sub nsw i32 [[ARG:%.*]], 1
; CHECK-NEXT:    [[CMP1:%.*]] = icmp slt i32 0, [[SUB1]]
; CHECK-NEXT:    br i1 [[CMP1]], label [[GUARDED:%.*]], label [[EXIT:%.*]]
; CHECK:       guarded:
; CHECK-NEXT:    [[SUB2:%.*]] = sub nsw i32 [[ARG]], [[I]]
; CHECK-NEXT:    [[SUB3:%.*]] = sub nsw i32 [[SUB2]], 1
; CHECK-NEXT:    [[CMP2:%.*]] = icmp slt i32 0, [[SUB3]]
; CHECK-NEXT:    br i1 [[CMP2]], label [[INNER_PH:%.*]], label [[OUTER_INC]]
; CHECK:       inner.ph:
; CHECK-NEXT:    br label [[INNER:%.*]]
; CHECK:       inner:
; CHECK-NEXT:    br i1 false, label [[INNER]], label [[OUTER_INC_LOOPEXIT:%.*]]
; CHECK:       outer.inc.loopexit:
; CHECK-NEXT:    br label [[OUTER_INC]]
; CHECK:       outer.inc:
; CHECK-NEXT:    [[I_INC]] = add nuw nsw i32 [[I]], 1
; CHECK-NEXT:    [[CMP4:%.*]] = icmp slt i32 [[I_INC]], [[ARG]]
; CHECK-NEXT:    br i1 [[CMP4]], label [[OUTER]], label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %outer

outer:
  %i = phi i32 [ 0, %entry ], [ %i.inc, %outer.inc ]
  %sub1 = sub nsw i32 %arg, 1
  %cmp1 = icmp slt i32 0, %sub1
  br i1 %cmp1, label %guarded, label %exit

guarded:
  %sub2 = sub nsw i32 %arg, %i
  %sub3 = sub nsw i32 %sub2, 1
  %cmp2 = icmp slt i32 0, %sub3
  br i1 %cmp2, label %inner.ph, label %outer.inc

inner.ph:
  br label %inner

inner:
  %j = phi i32 [ 0, %inner.ph ], [ %j.inc, %inner ]
  %j.inc = add nsw i32 %j, 1
  %cmp3 = icmp slt i32 %j.inc, %sub3
  br i1 %cmp3, label %inner, label %outer.inc

outer.inc:
  %i.inc = add nsw i32 %i, 1
  %cmp4 = icmp slt i32 %i.inc, %arg
  br i1 %cmp4, label %outer, label %exit

exit:
  ret void
}

; Range check can be trivially removed.
define void @predicated_inside_loop_signed_pos(i32 %arg) nounwind #0 {
; CHECK-LABEL: @predicated_inside_loop_signed_pos(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[OUTER:%.*]]
; CHECK:       outer:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[I_INC:%.*]], [[OUTER_INC:%.*]] ]
; CHECK-NEXT:    [[SUB1:%.*]] = sub nsw i32 [[ARG:%.*]], 1
; CHECK-NEXT:    [[CMP1:%.*]] = icmp slt i32 0, [[SUB1]]
; CHECK-NEXT:    br i1 [[CMP1]], label [[GUARDED:%.*]], label [[EXIT:%.*]]
; CHECK:       guarded:
; CHECK-NEXT:    [[SUB2:%.*]] = sub nsw i32 [[ARG]], [[I]]
; CHECK-NEXT:    [[SUB3:%.*]] = sub nsw i32 [[SUB2]], 1
; CHECK-NEXT:    [[CMP2:%.*]] = icmp slt i32 0, [[SUB3]]
; CHECK-NEXT:    br i1 [[CMP2]], label [[INNER_PH:%.*]], label [[OUTER_INC]]
; CHECK:       inner.ph:
; CHECK-NEXT:    br label [[INNER:%.*]]
; CHECK:       inner:
; CHECK-NEXT:    br i1 false, label [[INNER]], label [[OUTER_INC_LOOPEXIT:%.*]]
; CHECK:       outer.inc.loopexit:
; CHECK-NEXT:    br label [[OUTER_INC]]
; CHECK:       outer.inc:
; CHECK-NEXT:    [[I_INC]] = add nuw nsw i32 [[I]], 1
; CHECK-NEXT:    [[CMP4:%.*]] = icmp slt i32 [[I_INC]], [[SUB1]]
; CHECK-NEXT:    br i1 [[CMP4]], label [[OUTER]], label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %outer

outer:
  %i = phi i32 [ 0, %entry ], [ %i.inc, %outer.inc ]
  %sub1 = sub nsw i32 %arg, 1
  %cmp1 = icmp slt i32 0, %sub1
  br i1 %cmp1, label %guarded, label %exit

guarded:
  %sub2 = sub nsw i32 %arg, %i
  %sub3 = sub nsw i32 %sub2, 1
  %cmp2 = icmp slt i32 0, %sub3
  br i1 %cmp2, label %inner.ph, label %outer.inc

inner.ph:
  br label %inner

inner:
  %j = phi i32 [ 0, %inner.ph ], [ %j.inc, %inner ]
  %j.inc = add nsw i32 %j, 1
  %cmp3 = icmp slt i32 %j.inc, %sub3
  br i1 %cmp3, label %inner, label %outer.inc

outer.inc:
  %i.inc = add nsw i32 %i, 1
  %cmp4 = icmp slt i32 %i.inc, %sub1
  br i1 %cmp4, label %outer, label %exit

exit:
  ret void
}

define void @predicated_inside_loop_unsigned(i32 %arg) nounwind #0 {
; CHECK-LABEL: @predicated_inside_loop_unsigned(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[OUTER:%.*]]
; CHECK:       outer:
; CHECK-NEXT:    [[I:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[I_INC:%.*]], [[OUTER_INC:%.*]] ]
; CHECK-NEXT:    [[SUB1:%.*]] = sub nsw i32 [[ARG:%.*]], 1
; CHECK-NEXT:    [[CMP1:%.*]] = icmp slt i32 0, [[SUB1]]
; CHECK-NEXT:    br i1 [[CMP1]], label [[GUARDED:%.*]], label [[EXIT:%.*]]
; CHECK:       guarded:
; CHECK-NEXT:    [[SUB2:%.*]] = sub nsw i32 [[ARG]], [[I]]
; CHECK-NEXT:    [[SUB3:%.*]] = sub nsw i32 [[SUB2]], 1
; CHECK-NEXT:    [[CMP2:%.*]] = icmp ult i32 0, [[SUB3]]
; CHECK-NEXT:    br i1 [[CMP2]], label [[INNER_PH:%.*]], label [[OUTER_INC]]
; CHECK:       inner.ph:
; CHECK-NEXT:    br label [[INNER:%.*]]
; CHECK:       inner:
; CHECK-NEXT:    br i1 false, label [[INNER]], label [[OUTER_INC_LOOPEXIT:%.*]]
; CHECK:       outer.inc.loopexit:
; CHECK-NEXT:    br label [[OUTER_INC]]
; CHECK:       outer.inc:
; CHECK-NEXT:    [[I_INC]] = add nuw nsw i32 [[I]], 1
; CHECK-NEXT:    [[CMP4:%.*]] = icmp slt i32 [[I_INC]], [[ARG]]
; CHECK-NEXT:    br i1 [[CMP4]], label [[OUTER]], label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  br label %outer

outer:
  %i = phi i32 [ 0, %entry ], [ %i.inc, %outer.inc ]
  %sub1 = sub nsw i32 %arg, 1
  %cmp1 = icmp slt i32 0, %sub1
  br i1 %cmp1, label %guarded, label %exit

guarded:
  %sub2 = sub nsw i32 %arg, %i
  %sub3 = sub nsw i32 %sub2, 1
  %cmp2 = icmp ult i32 0, %sub3
  br i1 %cmp2, label %inner.ph, label %outer.inc

inner.ph:
  br label %inner

inner:
  %j = phi i32 [ 0, %inner.ph ], [ %j.inc, %inner ]
  %j.inc = add nsw i32 %j, 1
  %cmp3 = icmp slt i32 %j.inc, %sub3
  br i1 %cmp3, label %inner, label %outer.inc

outer.inc:
  %i.inc = add nsw i32 %i, 1
  %cmp4 = icmp slt i32 %i.inc, %arg
  br i1 %cmp4, label %outer, label %exit

exit:
  ret void
}

define void @test_can_predicate_simple_unsigned(i32* %p, i32* %arr) {
; CHECK-LABEL: @test_can_predicate_simple_unsigned(
; CHECK-NEXT:  preheader:
; CHECK-NEXT:    [[LEN:%.*]] = load i32, i32* [[P:%.*]], align 4
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ [[LEN]], [[PREHEADER:%.*]] ], [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[ZERO_COND:%.*]] = icmp eq i32 [[IV]], 0
; CHECK-NEXT:    br i1 [[ZERO_COND]], label [[EXIT:%.*]], label [[RANGE_CHECK_BLOCK:%.*]]
; CHECK:       range_check_block:
; CHECK-NEXT:    [[IV_NEXT]] = sub i32 [[IV]], 1
; CHECK-NEXT:    [[RANGE_CHECK:%.*]] = icmp ult i32 [[IV_NEXT]], [[LEN]]
; CHECK-NEXT:    br i1 [[RANGE_CHECK]], label [[BACKEDGE]], label [[FAIL:%.*]]
; CHECK:       backedge:
; CHECK-NEXT:    [[EL_PTR:%.*]] = getelementptr i32, i32* [[P]], i32 [[IV]]
; CHECK-NEXT:    [[EL:%.*]] = load i32, i32* [[EL_PTR]], align 4
; CHECK-NEXT:    [[LOOP_COND:%.*]] = icmp eq i32 [[EL]], 0
; CHECK-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
; CHECK:       fail:
; CHECK-NEXT:    unreachable
;
preheader:
  %len = load i32, i32* %p
  br label %loop

loop:
  %iv = phi i32 [%len, %preheader], [%iv.next, %backedge]
  %zero_cond = icmp eq i32 %iv, 0
  br i1 %zero_cond, label %exit, label %range_check_block

range_check_block:
  %iv.next = sub i32 %iv, 1
  %range_check = icmp ult i32 %iv.next, %len
  br i1 %range_check, label %backedge, label %fail

backedge:
  %el.ptr = getelementptr i32, i32* %p, i32 %iv
  %el = load i32, i32* %el.ptr
  %loop.cond = icmp eq i32 %el, 0
  br i1 %loop.cond, label %loop, label %exit

exit:
  ret void

fail:
  unreachable
}

define void @test_can_predicate_simple_signed(i32* %p, i32* %arr) {
; CHECK-LABEL: @test_can_predicate_simple_signed(
; CHECK-NEXT:  preheader:
; CHECK-NEXT:    [[LEN:%.*]] = load i32, i32* [[P:%.*]], align 4
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i32 [ [[LEN]], [[PREHEADER:%.*]] ], [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[ZERO_COND:%.*]] = icmp eq i32 [[IV]], 0
; CHECK-NEXT:    br i1 [[ZERO_COND]], label [[EXIT:%.*]], label [[RANGE_CHECK_BLOCK:%.*]]
; CHECK:       range_check_block:
; CHECK-NEXT:    [[IV_NEXT]] = sub i32 [[IV]], 1
; CHECK-NEXT:    [[RANGE_CHECK:%.*]] = icmp slt i32 [[IV_NEXT]], [[LEN]]
; CHECK-NEXT:    br i1 [[RANGE_CHECK]], label [[BACKEDGE]], label [[FAIL:%.*]]
; CHECK:       backedge:
; CHECK-NEXT:    [[EL_PTR:%.*]] = getelementptr i32, i32* [[P]], i32 [[IV]]
; CHECK-NEXT:    [[EL:%.*]] = load i32, i32* [[EL_PTR]], align 4
; CHECK-NEXT:    [[LOOP_COND:%.*]] = icmp eq i32 [[EL]], 0
; CHECK-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
; CHECK:       fail:
; CHECK-NEXT:    unreachable
;
preheader:
  %len = load i32, i32* %p
  br label %loop

loop:
  %iv = phi i32 [%len, %preheader], [%iv.next, %backedge]
  %zero_cond = icmp eq i32 %iv, 0
  br i1 %zero_cond, label %exit, label %range_check_block

range_check_block:
  %iv.next = sub i32 %iv, 1
  %range_check = icmp slt i32 %iv.next, %len
  br i1 %range_check, label %backedge, label %fail

backedge:
  %el.ptr = getelementptr i32, i32* %p, i32 %iv
  %el = load i32, i32* %el.ptr
  %loop.cond = icmp eq i32 %el, 0
  br i1 %loop.cond, label %loop, label %exit

exit:
  ret void

fail:
  unreachable
}

define void @test_can_predicate_trunc_unsigned(i32* %p, i32* %arr) {
; CHECK-LABEL: @test_can_predicate_trunc_unsigned(
; CHECK-NEXT:  preheader:
; CHECK-NEXT:    [[LEN:%.*]] = load i32, i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[START:%.*]] = zext i32 [[LEN]] to i64
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[IV:%.*]] = phi i64 [ [[START]], [[PREHEADER:%.*]] ], [ [[IV_NEXT:%.*]], [[BACKEDGE:%.*]] ]
; CHECK-NEXT:    [[ZERO_COND:%.*]] = icmp eq i64 [[IV]], 0
; CHECK-NEXT:    br i1 [[ZERO_COND]], label [[EXIT:%.*]], label [[RANGE_CHECK_BLOCK:%.*]]
; CHECK:       range_check_block:
; CHECK-NEXT:    [[IV_NEXT]] = sub nsw i64 [[IV]], 1
; CHECK-NEXT:    [[NARROW:%.*]] = trunc i64 [[IV_NEXT]] to i32
; CHECK-NEXT:    [[RANGE_CHECK:%.*]] = icmp ult i32 [[NARROW]], [[LEN]]
; CHECK-NEXT:    br i1 [[RANGE_CHECK]], label [[BACKEDGE]], label [[FAIL:%.*]]
; CHECK:       backedge:
; CHECK-NEXT:    [[EL_PTR:%.*]] = getelementptr i32, i32* [[ARR:%.*]], i64 [[IV]]
; CHECK-NEXT:    [[EL:%.*]] = load i32, i32* [[EL_PTR]], align 4
; CHECK-NEXT:    [[LOOP_COND:%.*]] = icmp eq i32 [[EL]], 0
; CHECK-NEXT:    br i1 [[LOOP_COND]], label [[LOOP]], label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
; CHECK:       fail:
; CHECK-NEXT:    unreachable
;
preheader:
  %len = load i32, i32* %p
  %start = zext i32 %len to i64
  br label %loop

loop:
  %iv = phi i64 [%start, %preheader], [%iv.next, %backedge]
  %zero_cond = icmp eq i64 %iv, 0
  br i1 %zero_cond, label %exit, label %range_check_block

range_check_block:
  %iv.next = sub i64 %iv, 1
  %narrow = trunc i64 %iv.next to i32
  %range_check = icmp ult i32 %narrow, %len
  br i1 %range_check, label %backedge, label %fail

backedge:
  %el.ptr = getelementptr i32, i32* %arr, i64 %iv
  %el = load i32, i32* %el.ptr
  %loop.cond = icmp eq i32 %el, 0
  br i1 %loop.cond, label %loop, label %exit

exit:
  ret void

fail:
  unreachable
}

!0 = !{i32 0, i32 2147483647}
