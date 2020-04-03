; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -indvars -S | FileCheck %s

target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64"

; IV with constant start, preinc and postinc sign extends, with and without NSW.
; IV rewrite only removes one sext. WidenIVs removes all three.
define void @postincConstIV(i8* %base, i32 %limit) nounwind {
; CHECK-LABEL: @postincConstIV(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = icmp sgt i32 [[LIMIT:%.*]], 0
; CHECK-NEXT:    [[SMAX:%.*]] = select i1 [[TMP0]], i32 [[LIMIT]], i32 0
; CHECK-NEXT:    [[TMP1:%.*]] = add nuw i32 [[SMAX]], 1
; CHECK-NEXT:    [[WIDE_TRIP_COUNT:%.*]] = zext i32 [[TMP1]] to i64
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[INDVARS_IV_NEXT:%.*]], [[LOOP]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[PREADR:%.*]] = getelementptr i8, i8* [[BASE:%.*]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    store i8 0, i8* [[PREADR]]
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[POSTADR:%.*]] = getelementptr i8, i8* [[BASE]], i64 [[INDVARS_IV_NEXT]]
; CHECK-NEXT:    store i8 0, i8* [[POSTADR]]
; CHECK-NEXT:    [[POSTADRNSW:%.*]] = getelementptr inbounds i8, i8* [[BASE]], i64 [[INDVARS_IV_NEXT]]
; CHECK-NEXT:    store i8 0, i8* [[POSTADRNSW]]
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i64 [[INDVARS_IV_NEXT]], [[WIDE_TRIP_COUNT]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    br label [[RETURN:%.*]]
; CHECK:       return:
; CHECK-NEXT:    ret void
;
entry:
  br label %loop
loop:
  %iv = phi i32 [ %postiv, %loop ], [ 0, %entry ]
  %ivnsw = phi i32 [ %postivnsw, %loop ], [ 0, %entry ]
  %preofs = sext i32 %iv to i64
  %preadr = getelementptr i8, i8* %base, i64 %preofs
  store i8 0, i8* %preadr
  %postiv = add i32 %iv, 1
  %postofs = sext i32 %postiv to i64
  %postadr = getelementptr i8, i8* %base, i64 %postofs
  store i8 0, i8* %postadr
  %postivnsw = add nsw i32 %ivnsw, 1
  %postofsnsw = sext i32 %postivnsw to i64
  %postadrnsw = getelementptr inbounds i8, i8* %base, i64 %postofsnsw
  store i8 0, i8* %postadrnsw
  %cond = icmp sgt i32 %limit, %iv
  br i1 %cond, label %loop, label %exit
exit:
  br label %return
return:
  ret void
}

; IV with nonconstant start, preinc and postinc sign extends,
; with and without NSW.
; As with postincConstIV, WidenIVs removes all three sexts.
define void @postincVarIV(i8* %base, i32 %init, i32 %limit) nounwind {
; CHECK-LABEL: @postincVarIV(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[PRECOND:%.*]] = icmp sgt i32 [[LIMIT:%.*]], [[INIT:%.*]]
; CHECK-NEXT:    br i1 [[PRECOND]], label [[LOOP_PREHEADER:%.*]], label [[RETURN:%.*]]
; CHECK:       loop.preheader:
; CHECK-NEXT:    [[TMP0:%.*]] = sext i32 [[INIT]] to i64
; CHECK-NEXT:    [[WIDE_TRIP_COUNT:%.*]] = sext i32 [[LIMIT]] to i64
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[TMP0]], [[LOOP_PREHEADER]] ], [ [[INDVARS_IV_NEXT:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[PREADR:%.*]] = getelementptr i8, i8* [[BASE:%.*]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    store i8 0, i8* [[PREADR]]
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[POSTADR:%.*]] = getelementptr i8, i8* [[BASE]], i64 [[INDVARS_IV_NEXT]]
; CHECK-NEXT:    store i8 0, i8* [[POSTADR]]
; CHECK-NEXT:    [[POSTADRNSW:%.*]] = getelementptr i8, i8* [[BASE]], i64 [[INDVARS_IV_NEXT]]
; CHECK-NEXT:    store i8 0, i8* [[POSTADRNSW]]
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i64 [[INDVARS_IV_NEXT]], [[WIDE_TRIP_COUNT]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[LOOP]], label [[EXIT:%.*]]
; CHECK:       exit:
; CHECK-NEXT:    br label [[RETURN]]
; CHECK:       return:
; CHECK-NEXT:    ret void
;
entry:
  %precond = icmp sgt i32 %limit, %init
  br i1 %precond, label %loop, label %return
loop:
  %iv = phi i32 [ %postiv, %loop ], [ %init, %entry ]
  %ivnsw = phi i32 [ %postivnsw, %loop ], [ %init, %entry ]
  %preofs = sext i32 %iv to i64
  %preadr = getelementptr i8, i8* %base, i64 %preofs
  store i8 0, i8* %preadr
  %postiv = add i32 %iv, 1
  %postofs = sext i32 %postiv to i64
  %postadr = getelementptr i8, i8* %base, i64 %postofs
  store i8 0, i8* %postadr
  %postivnsw = add nsw i32 %ivnsw, 1
  %postofsnsw = sext i32 %postivnsw to i64
  %postadrnsw = getelementptr i8, i8* %base, i64 %postofsnsw
  store i8 0, i8* %postadrnsw
  %cond = icmp sgt i32 %limit, %postiv
  br i1 %cond, label %loop, label %exit
exit:
  br label %return
return:
  ret void
}

; Test sign extend elimination in the inner and outer loop.
; %outercount is straightforward to widen, besides being in an outer loop.
; %innercount is currently blocked by lcssa, so is not widened.
; %inneriv can be widened only after proving it has no signed-overflow
;   based on the loop test.
define void @nestedIV(i8* %address, i32 %limit) nounwind {
; CHECK-LABEL: @nestedIV(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[LIMITDEC:%.*]] = add i32 [[LIMIT:%.*]], -1
; CHECK-NEXT:    [[TMP0:%.*]] = sext i32 [[LIMITDEC]] to i64
; CHECK-NEXT:    [[TMP1:%.*]] = icmp sgt i32 [[LIMIT]], 1
; CHECK-NEXT:    [[SMAX:%.*]] = select i1 [[TMP1]], i32 [[LIMIT]], i32 1
; CHECK-NEXT:    [[WIDE_TRIP_COUNT:%.*]] = zext i32 [[SMAX]] to i64
; CHECK-NEXT:    br label [[OUTERLOOP:%.*]]
; CHECK:       outerloop:
; CHECK-NEXT:    [[INDVARS_IV1:%.*]] = phi i64 [ [[INDVARS_IV_NEXT2:%.*]], [[OUTERMERGE:%.*]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[INNERCOUNT:%.*]] = phi i32 [ [[INNERCOUNT_MERGE:%.*]], [[OUTERMERGE]] ], [ 0, [[ENTRY]] ]
; CHECK-NEXT:    [[TMP2:%.*]] = add nsw i64 [[INDVARS_IV1]], -1
; CHECK-NEXT:    [[ADR1:%.*]] = getelementptr i8, i8* [[ADDRESS:%.*]], i64 [[TMP2]]
; CHECK-NEXT:    store i8 0, i8* [[ADR1]]
; CHECK-NEXT:    br label [[INNERPREHEADER:%.*]]
; CHECK:       innerpreheader:
; CHECK-NEXT:    [[INNERPRECMP:%.*]] = icmp sgt i32 [[LIMITDEC]], [[INNERCOUNT]]
; CHECK-NEXT:    br i1 [[INNERPRECMP]], label [[INNERLOOP_PREHEADER:%.*]], label [[OUTERMERGE]]
; CHECK:       innerloop.preheader:
; CHECK-NEXT:    [[TMP3:%.*]] = sext i32 [[INNERCOUNT]] to i64
; CHECK-NEXT:    br label [[INNERLOOP:%.*]]
; CHECK:       innerloop:
; CHECK-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ [[TMP3]], [[INNERLOOP_PREHEADER]] ], [ [[INDVARS_IV_NEXT:%.*]], [[INNERLOOP]] ]
; CHECK-NEXT:    [[INDVARS_IV_NEXT]] = add nsw i64 [[INDVARS_IV]], 1
; CHECK-NEXT:    [[ADR2:%.*]] = getelementptr i8, i8* [[ADDRESS]], i64 [[INDVARS_IV]]
; CHECK-NEXT:    store i8 0, i8* [[ADR2]]
; CHECK-NEXT:    [[ADR3:%.*]] = getelementptr i8, i8* [[ADDRESS]], i64 [[INDVARS_IV_NEXT]]
; CHECK-NEXT:    store i8 0, i8* [[ADR3]]
; CHECK-NEXT:    [[EXITCOND:%.*]] = icmp ne i64 [[INDVARS_IV_NEXT]], [[TMP0]]
; CHECK-NEXT:    br i1 [[EXITCOND]], label [[INNERLOOP]], label [[INNEREXIT:%.*]]
; CHECK:       innerexit:
; CHECK-NEXT:    [[INNERCOUNT_LCSSA_WIDE:%.*]] = phi i64 [ [[INDVARS_IV_NEXT]], [[INNERLOOP]] ]
; CHECK-NEXT:    [[TMP4:%.*]] = trunc i64 [[INNERCOUNT_LCSSA_WIDE]] to i32
; CHECK-NEXT:    br label [[OUTERMERGE]]
; CHECK:       outermerge:
; CHECK-NEXT:    [[INNERCOUNT_MERGE]] = phi i32 [ [[TMP4]], [[INNEREXIT]] ], [ [[INNERCOUNT]], [[INNERPREHEADER]] ]
; CHECK-NEXT:    [[ADR4:%.*]] = getelementptr i8, i8* [[ADDRESS]], i64 [[INDVARS_IV1]]
; CHECK-NEXT:    store i8 0, i8* [[ADR4]]
; CHECK-NEXT:    [[OFS5:%.*]] = sext i32 [[INNERCOUNT_MERGE]] to i64
; CHECK-NEXT:    [[ADR5:%.*]] = getelementptr i8, i8* [[ADDRESS]], i64 [[OFS5]]
; CHECK-NEXT:    store i8 0, i8* [[ADR5]]
; CHECK-NEXT:    [[INDVARS_IV_NEXT2]] = add nuw nsw i64 [[INDVARS_IV1]], 1
; CHECK-NEXT:    [[EXITCOND4:%.*]] = icmp ne i64 [[INDVARS_IV_NEXT2]], [[WIDE_TRIP_COUNT]]
; CHECK-NEXT:    br i1 [[EXITCOND4]], label [[OUTERLOOP]], label [[RETURN:%.*]]
; CHECK:       return:
; CHECK-NEXT:    ret void
;
entry:
  %limitdec = add i32 %limit, -1
  br label %outerloop

; Eliminate %ofs1 after widening outercount.
; IV rewriting hoists a gep into this block. We don't like that.
outerloop:
  %outercount   = phi i32 [ %outerpostcount, %outermerge ], [ 0, %entry ]
  %innercount = phi i32 [ %innercount.merge, %outermerge ], [ 0, %entry ]

  %outercountdec = add i32 %outercount, -1
  %ofs1 = sext i32 %outercountdec to i64
  %adr1 = getelementptr i8, i8* %address, i64 %ofs1
  store i8 0, i8* %adr1

  br label %innerpreheader

innerpreheader:
  %innerprecmp = icmp sgt i32 %limitdec, %innercount
  br i1 %innerprecmp, label %innerloop, label %outermerge

; Eliminate %ofs2 after widening inneriv.
; Eliminate %ofs3 after normalizing sext(innerpostiv)
; FIXME: We should check that indvars does not increase the number of
; IVs in this loop. sext elimination plus LFTR currently results in 2 final
; IVs. Waiting to remove LFTR.
innerloop:
  %inneriv = phi i32 [ %innerpostiv, %innerloop ], [ %innercount, %innerpreheader ]
  %innerpostiv = add i32 %inneriv, 1

  %ofs2 = sext i32 %inneriv to i64
  %adr2 = getelementptr i8, i8* %address, i64 %ofs2
  store i8 0, i8* %adr2

  %ofs3 = sext i32 %innerpostiv to i64
  %adr3 = getelementptr i8, i8* %address, i64 %ofs3
  store i8 0, i8* %adr3

  %innercmp = icmp sgt i32 %limitdec, %innerpostiv
  br i1 %innercmp, label %innerloop, label %innerexit

innerexit:
  %innercount.lcssa = phi i32 [ %innerpostiv, %innerloop ]
  br label %outermerge

; Eliminate %ofs4 after widening outercount
; TODO: Eliminate %ofs5 after removing lcssa
outermerge:
  %innercount.merge = phi i32 [ %innercount.lcssa, %innerexit ], [ %innercount, %innerpreheader ]

  %ofs4 = sext i32 %outercount to i64
  %adr4 = getelementptr i8, i8* %address, i64 %ofs4
  store i8 0, i8* %adr4

  %ofs5 = sext i32 %innercount.merge to i64
  %adr5 = getelementptr i8, i8* %address, i64 %ofs5
  store i8 0, i8* %adr5

  %outerpostcount = add i32 %outercount, 1
  %tmp47 = icmp slt i32 %outerpostcount, %limit
  br i1 %tmp47, label %outerloop, label %return

return:
  ret void
}
