; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -aa-pipeline=basic-aa -passes=indvars,indvars -S -verify-loop-lcssa %s | FileCheck %s

; Make sure SCEVExpander does not crash and introduce unnecessary LCSSA PHI nodes.
; The tests are a collection of cases with crashes when preserving LCSSA PHI
; nodes directly in SCEVExpander.

declare i1 @cond() readnone

define void @test1(i8 %x, [512 x i8]* %ptr) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[LAND_LHS_TRUE:%.*]]
; CHECK:       land.lhs.true:
; CHECK-NEXT:    br label [[WHILE_COND22:%.*]]
; CHECK:       while.cond22:
; CHECK-NEXT:    [[C_1:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[C_1]], label [[WHILE_COND22]], label [[WHILE_COND29_PREHEADER:%.*]]
; CHECK:       while.cond29.preheader:
; CHECK-NEXT:    br label [[WHILE_BODY35:%.*]]
; CHECK:       while.body35:
; CHECK-NEXT:    [[I_1107:%.*]] = phi i32 [ [[I_9:%.*]], [[IF_END224:%.*]] ], [ 0, [[WHILE_COND29_PREHEADER]] ]
; CHECK-NEXT:    br label [[WHILE_COND192:%.*]]
; CHECK:       while.cond192:
; CHECK-NEXT:    switch i8 [[X:%.*]], label [[WHILE_BODY205:%.*]] [
; CHECK-NEXT:    i8 59, label [[WHILE_COND215_PREHEADER:%.*]]
; CHECK-NEXT:    i8 10, label [[IF_END224_LOOPEXIT1:%.*]]
; CHECK-NEXT:    ]
; CHECK:       while.cond215.preheader:
; CHECK-NEXT:    br label [[WHILE_COND215:%.*]]
; CHECK:       while.body205:
; CHECK-NEXT:    br label [[WHILE_COND192]]
; CHECK:       while.cond215:
; CHECK-NEXT:    [[I_8_IN:%.*]] = phi i32 [ [[I_8:%.*]], [[WHILE_COND215]] ], [ [[I_1107]], [[WHILE_COND215_PREHEADER]] ]
; CHECK-NEXT:    [[I_8]] = add nsw i32 [[I_8_IN]], 1
; CHECK-NEXT:    [[IDXPROM216:%.*]] = sext i32 [[I_8]] to i64
; CHECK-NEXT:    [[ARRAYIDX217:%.*]] = getelementptr inbounds [512 x i8], [512 x i8]* [[PTR:%.*]], i64 0, i64 [[IDXPROM216]]
; CHECK-NEXT:    [[C_2:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[C_2]], label [[WHILE_COND215]], label [[IF_END224_LOOPEXIT:%.*]]
; CHECK:       if.end224.loopexit:
; CHECK-NEXT:    [[I_8_LCSSA:%.*]] = phi i32 [ [[I_8]], [[WHILE_COND215]] ]
; CHECK-NEXT:    br label [[IF_END224]]
; CHECK:       if.end224.loopexit1:
; CHECK-NEXT:    br label [[IF_END224]]
; CHECK:       if.end224:
; CHECK-NEXT:    [[I_9]] = phi i32 [ [[I_8_LCSSA]], [[IF_END224_LOOPEXIT]] ], [ [[I_1107]], [[IF_END224_LOOPEXIT1]] ]
; CHECK-NEXT:    [[C_3:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[C_3]], label [[WHILE_END225:%.*]], label [[WHILE_BODY35]]
; CHECK:       while.end225:
; CHECK-NEXT:    br label [[LAND_LHS_TRUE]]
;
entry:
  br label %land.lhs.true

land.lhs.true:                                    ; preds = %while.end225, %entry
  br label %while.cond22

while.cond22:                                     ; preds = %while.cond22, %land.lhs.true
  %c.1 = call i1 @cond()
  br i1 %c.1, label %while.cond22, label %while.cond29.preheader

while.cond29.preheader:                           ; preds = %while.cond22
  br label %while.body35

while.body35:                                     ; preds = %if.end224, %while.cond29.preheader
  %i.1107 = phi i32 [ %i.9, %if.end224 ], [ 0, %while.cond29.preheader ]
  br label %while.cond192

while.cond192:                                    ; preds = %while.body205, %while.body35
  %i.7 = phi i32 [ %i.1107, %while.body35 ], [ %inc206, %while.body205 ]
  switch i8 %x, label %while.body205 [
  i8 59, label %while.cond215
  i8 10, label %if.end224
  ]

while.body205:                                    ; preds = %while.cond192
  %inc206 = add nsw i32 %i.7, 1
  br label %while.cond192

while.cond215:                                    ; preds = %while.cond215, %while.cond192
  %i.8.in = phi i32 [ %i.8, %while.cond215 ], [ %i.7, %while.cond192 ]
  %i.8 = add nsw i32 %i.8.in, 1
  %idxprom216 = sext i32 %i.8 to i64
  %arrayidx217 = getelementptr inbounds [512 x i8], [512 x i8]* %ptr, i64 0, i64 %idxprom216
  %c.2 = call i1 @cond()
  br i1 %c.2, label %while.cond215, label %if.end224

if.end224:                                        ; preds = %while.cond215, %while.cond192
  %i.9 = phi i32 [ %i.8, %while.cond215 ], [ %i.7, %while.cond192 ]
  %c.3 = call i1 @cond()
  br i1 %c.3, label %while.end225, label %while.body35

while.end225:                                     ; preds = %if.end224
  br label %land.lhs.true
}

define void @test2(i16 %x)  {
; CHECK-LABEL: @test2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C_1:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[C_1]], label [[FOR_COND_PREHEADER:%.*]], label [[RETURN:%.*]]
; CHECK:       for.cond.preheader:
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    switch i16 [[X:%.*]], label [[RETURN_LOOPEXIT1:%.*]] [
; CHECK-NEXT:    i16 41, label [[FOR_END:%.*]]
; CHECK-NEXT:    i16 43, label [[FOR_COND]]
; CHECK-NEXT:    ]
; CHECK:       for.end:
; CHECK-NEXT:    [[I_0_LCSSA2:%.*]] = phi i32 [ 0, [[FOR_COND]] ]
; CHECK-NEXT:    [[CMP8243:%.*]] = icmp sgt i32 [[I_0_LCSSA2]], 0
; CHECK-NEXT:    br i1 [[CMP8243]], label [[FOR_BODY84_PREHEADER:%.*]], label [[RETURN]]
; CHECK:       for.body84.preheader:
; CHECK-NEXT:    br label [[FOR_BODY84:%.*]]
; CHECK:       for.body84:
; CHECK-NEXT:    [[C_2:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[C_2]], label [[IF_END106:%.*]], label [[RETURN_LOOPEXIT:%.*]]
; CHECK:       if.end106:
; CHECK-NEXT:    br i1 false, label [[FOR_BODY84]], label [[RETURN_LOOPEXIT]]
; CHECK:       return.loopexit:
; CHECK-NEXT:    br label [[RETURN]]
; CHECK:       return.loopexit1:
; CHECK-NEXT:    br label [[RETURN]]
; CHECK:       return:
; CHECK-NEXT:    ret void
;
entry:
  %c.1 = call i1 @cond()
  br i1 %c.1, label %for.cond, label %return

for.cond:                                         ; preds = %for.cond, %entry
  %i.0 = phi i32 [ %sub, %for.cond ], [ 0, %entry ]
  %sub = add nsw i32 %i.0, -1
  switch i16 %x, label %return [
  i16 41, label %for.end
  i16 43, label %for.cond
  ]

for.end:                                          ; preds = %for.cond
  %cmp8243 = icmp sgt i32 %i.0, 0
  br i1 %cmp8243, label %for.body84, label %return

for.body84:                                       ; preds = %if.end106, %for.end
  %i.144 = phi i32 [ %inc, %if.end106 ], [ 0, %for.end ]
  %c.2 = call i1 @cond()
  br i1 %c.2, label %if.end106, label %return

if.end106:                                        ; preds = %for.body84
  %inc = add nuw nsw i32 %i.144, 1
  %cmp82 = icmp slt i32 %inc, %i.0
  br i1 %cmp82, label %for.body84, label %return

return:                                           ; preds = %if.end106, %for.body84, %for.end, %for.cond, %entry
  ret void
}

declare i32 @get.i32() readnone

define void @test3(i32* %ptr) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[WHILE_BODY:%.*]]
; CHECK:       while.body:
; CHECK-NEXT:    br label [[FOR_BODY1208:%.*]]
; CHECK:       for.body1208:
; CHECK-NEXT:    [[M_0804:%.*]] = phi i32 [ 1, [[WHILE_BODY]] ], [ [[INC1499:%.*]], [[FOR_INC1498:%.*]] ]
; CHECK-NEXT:    [[V:%.*]] = call i32 @get.i32()
; CHECK-NEXT:    [[CMP1358:%.*]] = icmp eq i32 [[V]], 0
; CHECK-NEXT:    br i1 [[CMP1358]], label [[IF_THEN1360:%.*]], label [[FOR_INC1498]]
; CHECK:       if.then1360:
; CHECK-NEXT:    [[M_0804_LCSSA:%.*]] = phi i32 [ [[M_0804]], [[FOR_BODY1208]] ]
; CHECK-NEXT:    br label [[FOR_COND1390:%.*]]
; CHECK:       for.cond1390:
; CHECK-NEXT:    [[M_2_IN:%.*]] = phi i32 [ [[M_0804_LCSSA]], [[IF_THEN1360]] ], [ 0, [[FOR_BODY1394:%.*]] ]
; CHECK-NEXT:    [[C_2:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[C_2]], label [[FOR_BODY1394]], label [[FOR_END1469:%.*]]
; CHECK:       for.body1394:
; CHECK-NEXT:    br label [[FOR_COND1390]]
; CHECK:       for.end1469:
; CHECK-NEXT:    [[M_2_IN_LCSSA:%.*]] = phi i32 [ [[M_2_IN]], [[FOR_COND1390]] ]
; CHECK-NEXT:    store i32 [[M_2_IN_LCSSA]], i32* [[PTR:%.*]], align 4
; CHECK-NEXT:    br label [[WHILE_BODY]]
; CHECK:       for.inc1498:
; CHECK-NEXT:    [[INC1499]] = add nuw nsw i32 [[M_0804]], 1
; CHECK-NEXT:    br label [[FOR_BODY1208]]
;
entry:
  br label %while.body

while.body:                                       ; preds = %for.end1469, %entry
  br label %for.body1208

for.body1208:                                     ; preds = %for.inc1498, %while.body
  %m.0804 = phi i32 [ 1, %while.body ], [ %inc1499, %for.inc1498 ]
  %v = call i32 @get.i32()
  %cmp1358 = icmp eq i32 %v, 0
  br i1 %cmp1358, label %if.then1360, label %for.inc1498

if.then1360:                                      ; preds = %for.body1208
  br label %for.cond1390

for.cond1390:                                     ; preds = %for.body1394, %if.then1360
  %m.2.in = phi i32 [ %m.0804, %if.then1360 ], [ 0, %for.body1394 ]
  %c.2 = call i1 @cond()
  br i1 %c.2, label %for.body1394, label %for.end1469

for.body1394:                                     ; preds = %for.cond1390
  br label %for.cond1390

for.end1469:                                      ; preds = %for.cond1390
  store i32 %m.2.in, i32* %ptr, align 4
  br label %while.body

for.inc1498:                                      ; preds = %for.body1208
  %inc1499 = add nuw nsw i32 %m.0804, 1
  br label %for.body1208
}

define void @test4(i32* %ptr) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[WHILE_BODY:%.*]]
; CHECK:       while.body:
; CHECK-NEXT:    br label [[FOR_COND1204_PREHEADER:%.*]]
; CHECK:       for.cond1204.preheader:
; CHECK-NEXT:    [[C_1:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[C_1]], label [[IF_THEN1504:%.*]], label [[FOR_BODY1208_LR_PH:%.*]]
; CHECK:       for.body1208.lr.ph:
; CHECK-NEXT:    br label [[FOR_BODY1208:%.*]]
; CHECK:       for.body1208:
; CHECK-NEXT:    [[TMP0:%.*]] = phi i32 [ 0, [[FOR_BODY1208_LR_PH]] ], [ [[TMP1:%.*]], [[FOR_INC1498:%.*]] ]
; CHECK-NEXT:    [[M_0804:%.*]] = phi i32 [ 1, [[FOR_BODY1208_LR_PH]] ], [ [[INC1499:%.*]], [[FOR_INC1498]] ]
; CHECK-NEXT:    [[IDXPROM1212:%.*]] = zext i32 [[M_0804]] to i64
; CHECK-NEXT:    [[V:%.*]] = call i32 @get.i32()
; CHECK-NEXT:    [[CMP1215:%.*]] = icmp eq i32 0, [[V]]
; CHECK-NEXT:    [[YPOS1223:%.*]] = getelementptr inbounds i32, i32* [[PTR:%.*]], i64 [[IDXPROM1212]]
; CHECK-NEXT:    br i1 [[CMP1215]], label [[IF_THEN1217:%.*]], label [[IF_ELSE1351:%.*]]
; CHECK:       if.then1217:
; CHECK-NEXT:    [[M_0804_LCSSA:%.*]] = phi i32 [ [[M_0804]], [[FOR_BODY1208]] ]
; CHECK-NEXT:    br label [[FOR_COND1247:%.*]]
; CHECK:       for.cond1247:
; CHECK-NEXT:    [[M_1_IN:%.*]] = phi i32 [ [[M_0804_LCSSA]], [[IF_THEN1217]] ], [ [[M_1:%.*]], [[IF_THEN1260:%.*]] ]
; CHECK-NEXT:    [[M_1]] = add nuw nsw i32 [[M_1_IN]], 1
; CHECK-NEXT:    br label [[FOR_BODY1251:%.*]]
; CHECK:       for.body1251:
; CHECK-NEXT:    [[IDXPROM1255:%.*]] = zext i32 [[M_1]] to i64
; CHECK-NEXT:    [[XPOS1257:%.*]] = getelementptr inbounds i32, i32* [[PTR]], i64 [[IDXPROM1255]]
; CHECK-NEXT:    [[C_2:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[C_2]], label [[IF_THEN1260]], label [[FOR_END1326:%.*]]
; CHECK:       if.then1260:
; CHECK-NEXT:    br label [[FOR_COND1247]]
; CHECK:       for.end1326:
; CHECK-NEXT:    br label [[IF_END1824:%.*]]
; CHECK:       if.else1351:
; CHECK-NEXT:    [[V_2:%.*]] = call i32 @get.i32()
; CHECK-NEXT:    [[CMP1358:%.*]] = icmp eq i32 [[V_2]], 0
; CHECK-NEXT:    br i1 [[CMP1358]], label [[IF_THEN1360:%.*]], label [[FOR_INC1498]]
; CHECK:       if.then1360:
; CHECK-NEXT:    [[DOTLCSSA2:%.*]] = phi i32 [ [[TMP0]], [[IF_ELSE1351]] ]
; CHECK-NEXT:    [[M_0804_LCSSA1:%.*]] = phi i32 [ [[M_0804]], [[IF_ELSE1351]] ]
; CHECK-NEXT:    [[CMP1392:%.*]] = icmp slt i32 [[M_0804_LCSSA1]], [[DOTLCSSA2]]
; CHECK-NEXT:    unreachable
; CHECK:       for.inc1498:
; CHECK-NEXT:    [[INC1499]] = add nuw nsw i32 [[M_0804]], 1
; CHECK-NEXT:    [[TMP1]] = load i32, i32* [[PTR]], align 8
; CHECK-NEXT:    br label [[FOR_BODY1208]]
; CHECK:       if.then1504:
; CHECK-NEXT:    unreachable
; CHECK:       if.end1824:
; CHECK-NEXT:    br label [[WHILE_BODY]]
;
entry:
  br label %while.body

while.body:                                       ; preds = %if.end1824, %entry
  br label %for.cond1204.preheader

for.cond1204.preheader:                           ; preds = %while.body
  %c.1 = call i1 @cond()
  br i1 %c.1, label %if.then1504, label %for.body1208.lr.ph

for.body1208.lr.ph:                               ; preds = %for.cond1204.preheader
  br label %for.body1208

for.body1208:                                     ; preds = %for.inc1498, %for.body1208.lr.ph
  %0 = phi i32 [ 0, %for.body1208.lr.ph ], [ %1, %for.inc1498 ]
  %m.0804 = phi i32 [ 1, %for.body1208.lr.ph ], [ %inc1499, %for.inc1498 ]
  %idxprom1212 = zext i32 %m.0804 to i64
  %v = call i32 @get.i32()
  %cmp1215 = icmp eq i32 0, %v
  %ypos1223 = getelementptr inbounds i32, i32* %ptr , i64 %idxprom1212
  br i1 %cmp1215, label %if.then1217, label %if.else1351

if.then1217:                                      ; preds = %for.body1208
  br label %for.cond1247

for.cond1247:                                     ; preds = %if.then1260, %if.then1217
  %m.1.in = phi i32 [ %m.0804, %if.then1217 ], [ %m.1, %if.then1260 ]
  %m.1 = add nuw nsw i32 %m.1.in, 1
  %cmp1249 = icmp slt i32 %m.1.in, %0
  br label %for.body1251

for.body1251:                                     ; preds = %for.cond1247
  %idxprom1255 = zext i32 %m.1 to i64
  %xpos1257 = getelementptr inbounds i32, i32* %ptr, i64 %idxprom1255
  %c.2 = call i1 @cond()
  br i1 %c.2, label %if.then1260, label %for.end1326

if.then1260:                                      ; preds = %for.body1251
  br label %for.cond1247

for.end1326:                                      ; preds = %for.body1251
  br label %if.end1824

if.else1351:                                      ; preds = %for.body1208
  %v.2 = call i32 @get.i32()
  %cmp1358 = icmp eq i32 %v.2, 0
  br i1 %cmp1358, label %if.then1360, label %for.inc1498

if.then1360:                                      ; preds = %if.else1351
  %cmp1392 = icmp slt i32 %m.0804, %0
  unreachable

for.inc1498:                                      ; preds = %if.else1351
  %inc1499 = add nuw nsw i32 %m.0804, 1
  %1 = load i32, i32* %ptr, align 8
  br label %for.body1208

if.then1504:                                      ; preds = %for.cond1204.preheader
  unreachable

if.end1824:                                       ; preds = %for.end1326
  br label %while.body
}

define void @test5(i8* %header, i32 %conv, i8 %n) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[POS_42:%.*]] = phi i32 [ 0, [[ENTRY:%.*]] ], [ [[ADD85:%.*]], [[FOR_INC:%.*]] ]
; CHECK-NEXT:    br label [[FOR_INNER:%.*]]
; CHECK:       for.inner:
; CHECK-NEXT:    [[I_0_I:%.*]] = phi i32 [ 0, [[FOR_BODY]] ], [ [[INC_I:%.*]], [[FOR_INNER]] ]
; CHECK-NEXT:    [[INC_I]] = add nuw nsw i32 [[I_0_I]], 1
; CHECK-NEXT:    [[CMP7_I:%.*]] = icmp slt i8 [[N:%.*]], 0
; CHECK-NEXT:    br i1 [[CMP7_I]], label [[FOR_INNER]], label [[FOR_INNER_EXIT:%.*]]
; CHECK:       for.inner.exit:
; CHECK-NEXT:    [[INC_I_LCSSA:%.*]] = phi i32 [ [[INC_I]], [[FOR_INNER]] ]
; CHECK-NEXT:    br label [[FOR_INNER_2:%.*]]
; CHECK:       for.inner.2:
; CHECK-NEXT:    [[I_0_I1:%.*]] = phi i32 [ 0, [[FOR_INNER_EXIT]] ], [ [[INC_I3:%.*]], [[FOR_INNER_2]] ]
; CHECK-NEXT:    [[INC_I3]] = add nuw nsw i32 [[I_0_I1]], 1
; CHECK-NEXT:    [[CMP7_I4:%.*]] = icmp slt i8 [[N]], 0
; CHECK-NEXT:    br i1 [[CMP7_I4]], label [[FOR_INNER_2]], label [[FOR_INC]]
; CHECK:       for.inc:
; CHECK-NEXT:    [[INC_I3_LCSSA:%.*]] = phi i32 [ [[INC_I3]], [[FOR_INNER_2]] ]
; CHECK-NEXT:    [[ADD71:%.*]] = add i32 [[POS_42]], [[INC_I_LCSSA]]
; CHECK-NEXT:    [[ADD85]] = add i32 [[ADD71]], [[INC_I3_LCSSA]]
; CHECK-NEXT:    br i1 false, label [[FOR_BODY]], label [[WHILE_COND_PREHEADER:%.*]]
; CHECK:       while.cond.preheader:
; CHECK-NEXT:    [[ADD85_LCSSA:%.*]] = phi i32 [ [[ADD85]], [[FOR_INC]] ]
; CHECK-NEXT:    [[SHL:%.*]] = shl nuw nsw i32 [[CONV:%.*]], 2
; CHECK-NEXT:    br label [[WHILE_COND:%.*]]
; CHECK:       while.cond:
; CHECK-NEXT:    [[POS_8:%.*]] = phi i32 [ [[INC114:%.*]], [[WHILE_BODY:%.*]] ], [ [[ADD85_LCSSA]], [[WHILE_COND_PREHEADER]] ]
; CHECK-NEXT:    [[CMP112:%.*]] = icmp ult i32 [[POS_8]], [[SHL]]
; CHECK-NEXT:    br i1 [[CMP112]], label [[WHILE_BODY]], label [[CLEANUP122:%.*]]
; CHECK:       while.body:
; CHECK-NEXT:    [[INC114]] = add nuw i32 [[POS_8]], 1
; CHECK-NEXT:    [[C_1:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[C_1]], label [[WHILE_COND]], label [[CLEANUP122]]
; CHECK:       cleanup122:
; CHECK-NEXT:    ret void
;
entry:
  %shl = shl nuw nsw i32 %conv, 2
  br label %for.body

for.body:                                         ; preds = %entry, %for.inc
  %pos.42 = phi i32 [ 0, %entry ], [ %add85, %for.inc ]
  br label %for.inner

for.inner:                                       ; preds = %for.body.i, %for.body
  %i.0.i = phi i32 [ 0, %for.body ], [ %inc.i, %for.inner ]
  %inc.i = add nuw nsw i32 %i.0.i, 1
  %cmp7.i = icmp slt i8 %n, 0
  br i1 %cmp7.i, label %for.inner, label %for.inner.exit

for.inner.exit:                                   ; preds = %for.body.i
  %add71 = add i32 %pos.42, %inc.i
  br label %for.inner.2

for.inner.2:                                      ; preds = %for.body.i6, %cleanup.cont74
  %i.0.i1 = phi i32 [ 0, %for.inner.exit ], [ %inc.i3, %for.inner.2]
  %inc.i3 = add nuw nsw i32 %i.0.i1, 1
  %cmp7.i4 = icmp slt i8 %n, 0
  br i1 %cmp7.i4, label %for.inner.2, label %for.inc

for.inc:                                          ; preds = %for.body.i6
  %add85 = add i32 %add71, %inc.i3
  br i1 false, label %for.body, label %while.cond.preheader

while.cond.preheader:                             ; preds = %for.inc
  br label %while.cond

while.cond:                                       ; preds = %while.cond.preheader, %while.body
  %pos.8 = phi i32 [ %inc114, %while.body ], [ %add85, %while.cond.preheader ]
  %cmp112 = icmp ult i32 %pos.8, %shl
  br i1 %cmp112, label %while.body, label %cleanup122

while.body:                                       ; preds = %while.cond
  %inc114 = add nuw i32 %pos.8, 1
  %c.1 = call i1 @cond()
  br i1 %c.1, label %while.cond, label %cleanup122

cleanup122:                                       ; preds = %while.body, %while.cond
  ret void
}

define void @test6(i8 %x) {
; CHECK-LABEL: @test6(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C_1:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[C_1]], label [[LAND_RHS:%.*]], label [[WHILE_END316:%.*]]
; CHECK:       land.rhs:
; CHECK-NEXT:    br label [[WHILE_BODY35:%.*]]
; CHECK:       while.body35:
; CHECK-NEXT:    br label [[WHILE_COND192:%.*]]
; CHECK:       while.cond192:
; CHECK-NEXT:    switch i8 [[X:%.*]], label [[WHILE_BODY205:%.*]] [
; CHECK-NEXT:    i8 59, label [[WHILE_COND215_PREHEADER:%.*]]
; CHECK-NEXT:    i8 10, label [[IF_END224:%.*]]
; CHECK-NEXT:    ]
; CHECK:       while.cond215.preheader:
; CHECK-NEXT:    [[I_7_LCSSA:%.*]] = phi i32 [ 0, [[WHILE_COND192]] ]
; CHECK-NEXT:    br label [[WHILE_COND215:%.*]]
; CHECK:       while.body205:
; CHECK-NEXT:    br label [[WHILE_COND192]]
; CHECK:       while.cond215:
; CHECK-NEXT:    [[I_8_IN:%.*]] = phi i32 [ [[I_8:%.*]], [[WHILE_COND215]] ], [ [[I_7_LCSSA]], [[WHILE_COND215_PREHEADER]] ]
; CHECK-NEXT:    [[I_8]] = add nuw nsw i32 [[I_8_IN]], 1
; CHECK-NEXT:    [[IDXPROM216:%.*]] = sext i32 [[I_8]] to i64
; CHECK-NEXT:    [[ARRAYIDX217:%.*]] = getelementptr inbounds [512 x i8], [512 x i8]* null, i64 0, i64 [[IDXPROM216]]
; CHECK-NEXT:    br label [[WHILE_COND215]]
; CHECK:       if.end224:
; CHECK-NEXT:    [[C_2:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[C_2]], label [[WHILE_END225:%.*]], label [[WHILE_BODY35]]
; CHECK:       while.end225:
; CHECK-NEXT:    unreachable
; CHECK:       while.end316:
; CHECK-NEXT:    ret void
;
entry:
  %c.1 = call i1 @cond()
  br i1 %c.1, label %land.rhs, label %while.end316

land.rhs:                                         ; preds = %entry
  br label %while.body35

while.body35:                                     ; preds = %if.end224, %land.rhs
  br label %while.cond192

while.cond192:                                    ; preds = %while.body205, %while.body35
  %i.7 = phi i32 [ 0, %while.body35 ], [ %inc206, %while.body205 ]
  switch i8 %x, label %while.body205 [
  i8 59, label %while.cond215
  i8 10, label %if.end224
  ]

while.body205:                                    ; preds = %while.cond192
  %inc206 = add nsw i32 %i.7, 1
  br label %while.cond192

while.cond215:                                    ; preds = %while.cond215, %while.cond192
  %i.8.in = phi i32 [ %i.8, %while.cond215 ], [ %i.7, %while.cond192 ]
  %i.8 = add nsw i32 %i.8.in, 1
  %idxprom216 = sext i32 %i.8 to i64
  %arrayidx217 = getelementptr inbounds [512 x i8], [512 x i8]* null, i64 0, i64 %idxprom216
  br label %while.cond215

if.end224:                                        ; preds = %while.cond192
  %c.2 = call i1 @cond()
  br i1 %c.2, label %while.end225, label %while.body35

while.end225:                                     ; preds = %if.end224
  unreachable

while.end316:                                     ; preds = %entry
  ret void
}

define void @test7(i32* %ptr) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[WHILE_BODY:%.*]]
; CHECK:       while.body:
; CHECK-NEXT:    br label [[FOR_BODY1208:%.*]]
; CHECK:       for.body1208:
; CHECK-NEXT:    [[TMP0:%.*]] = phi i32 [ undef, [[WHILE_BODY]] ], [ [[TMP1:%.*]], [[FOR_INC1498:%.*]] ]
; CHECK-NEXT:    [[M_048:%.*]] = phi i32 [ 1, [[WHILE_BODY]] ], [ [[INC1499:%.*]], [[FOR_INC1498]] ]
; CHECK-NEXT:    [[IDXPROM1212:%.*]] = zext i32 [[M_048]] to i64
; CHECK-NEXT:    [[XPOS1214:%.*]] = getelementptr inbounds i32, i32* [[PTR:%.*]], i64 [[IDXPROM1212]]
; CHECK-NEXT:    [[V_1:%.*]] = call i32 @get.i32()
; CHECK-NEXT:    [[CMP1215:%.*]] = icmp eq i32 0, [[V_1]]
; CHECK-NEXT:    br i1 [[CMP1215]], label [[IF_THEN1217:%.*]], label [[IF_ELSE1351:%.*]]
; CHECK:       if.then1217:
; CHECK-NEXT:    [[DOTLCSSA:%.*]] = phi i32 [ [[TMP0]], [[FOR_BODY1208]] ]
; CHECK-NEXT:    [[M_048_LCSSA:%.*]] = phi i32 [ [[M_048]], [[FOR_BODY1208]] ]
; CHECK-NEXT:    [[CMP1249_NOT_NOT:%.*]] = icmp slt i32 [[M_048_LCSSA]], [[DOTLCSSA]]
; CHECK-NEXT:    unreachable
; CHECK:       if.else1351:
; CHECK-NEXT:    [[CMP1358:%.*]] = icmp eq i32 0, undef
; CHECK-NEXT:    br i1 [[CMP1358]], label [[IF_THEN1360:%.*]], label [[FOR_INC1498]]
; CHECK:       if.then1360:
; CHECK-NEXT:    [[M_048_LCSSA1:%.*]] = phi i32 [ [[M_048]], [[IF_ELSE1351]] ]
; CHECK-NEXT:    br label [[FOR_COND1390:%.*]]
; CHECK:       for.cond1390:
; CHECK-NEXT:    [[M_2_IN:%.*]] = phi i32 [ [[M_048_LCSSA1]], [[IF_THEN1360]] ], [ [[M_2:%.*]], [[IF_THEN1403:%.*]] ]
; CHECK-NEXT:    [[M_2]] = add nuw nsw i32 [[M_2_IN]], 1
; CHECK-NEXT:    [[IDXPROM1398:%.*]] = zext i32 [[M_2]] to i64
; CHECK-NEXT:    br label [[IF_THEN1403]]
; CHECK:       if.then1403:
; CHECK-NEXT:    [[XPOS1409:%.*]] = getelementptr inbounds i32, i32* [[PTR]], i64 [[IDXPROM1398]]
; CHECK-NEXT:    [[C_1:%.*]] = call i1 @cond()
; CHECK-NEXT:    br i1 [[C_1]], label [[FOR_COND1390]], label [[FOR_END1469:%.*]]
; CHECK:       for.end1469:
; CHECK-NEXT:    br label [[IF_END1824:%.*]]
; CHECK:       for.inc1498:
; CHECK-NEXT:    [[INC1499]] = add nuw nsw i32 [[M_048]], 1
; CHECK-NEXT:    [[TMP1]] = load i32, i32* undef, align 8
; CHECK-NEXT:    br label [[FOR_BODY1208]]
; CHECK:       if.end1824:
; CHECK-NEXT:    br label [[WHILE_BODY]]
;
entry:
  br label %while.body

while.body:                                       ; preds = %if.end1824, %entry
  br label %for.body1208

for.body1208:                                     ; preds = %for.inc1498, %while.body
  %0 = phi i32 [ undef, %while.body ], [ %1, %for.inc1498 ]
  %m.048 = phi i32 [ 1, %while.body ], [ %inc1499, %for.inc1498 ]
  %idxprom1212 = zext i32 %m.048 to i64
  %xpos1214 = getelementptr inbounds i32, i32* %ptr, i64 %idxprom1212
  %v.1 = call i32 @get.i32()
  %cmp1215 = icmp eq i32 0, %v.1
  br i1 %cmp1215, label %if.then1217, label %if.else1351

if.then1217:                                      ; preds = %for.body1208
  %cmp1249.not.not = icmp slt i32 %m.048, %0
  unreachable

if.else1351:                                      ; preds = %for.body1208
  %cmp1358 = icmp eq i32 0, undef
  br i1 %cmp1358, label %if.then1360, label %for.inc1498

if.then1360:                                      ; preds = %if.else1351
  br label %for.cond1390

for.cond1390:                                     ; preds = %if.then1403, %if.then1360
  %m.2.in = phi i32 [ %m.048, %if.then1360 ], [ %m.2, %if.then1403 ]
  %m.2 = add nuw nsw i32 %m.2.in, 1
  %cmp1392.not.not = icmp slt i32 %m.2.in, %0
  %idxprom1398 = zext i32 %m.2 to i64
  br label %if.then1403

if.then1403:                                      ; preds = %for.cond1390
  %xpos1409 = getelementptr inbounds i32, i32* %ptr, i64 %idxprom1398
  %c.1 = call i1 @cond()
  br i1 %c.1, label %for.cond1390, label %for.end1469

for.end1469:                                      ; preds = %if.then1403
  br label %if.end1824

for.inc1498:                                      ; preds = %if.else1351
  %inc1499 = add nuw nsw i32 %m.048, 1
  %1 = load i32, i32* undef, align 8
  br label %for.body1208

if.end1824:                                       ; preds = %for.end1469
  br label %while.body
}
