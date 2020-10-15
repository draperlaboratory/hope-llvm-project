; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -indvars -S "-data-layout=e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64" | FileCheck -check-prefix=PTR64 %s
; RUN: opt < %s -indvars -S "-data-layout=e-p:32:32:32-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-f32:32:32-f64:32:64-v64:64:64-v128:128:128-a0:0:64-f80:128:128-n8:16:32" | FileCheck -check-prefix=PTR32 %s
;
; PR11279: Assertion !IVLimit->getType()->isPointerTy()
;
; Test LinearFunctionTestReplace of a pointer-type loop counter. Note
; that BECount may or may not be a pointer type. A pointer type
; BECount doesn't really make sense, but that's what falls out of
; SCEV. Since it's an i8*, it has unit stride so we never adjust the
; SCEV expression in a way that would convert it to an integer type.

define i8 @testnullptrptr(i8* %buf, i8* %end) nounwind {
; PTR64-LABEL: @testnullptrptr(
; PTR64-NEXT:    br label [[LOOPGUARD:%.*]]
; PTR64:       loopguard:
; PTR64-NEXT:    [[GUARD:%.*]] = icmp ult i8* null, [[END:%.*]]
; PTR64-NEXT:    br i1 [[GUARD]], label [[PREHEADER:%.*]], label [[EXIT:%.*]]
; PTR64:       preheader:
; PTR64-NEXT:    br label [[LOOP:%.*]]
; PTR64:       loop:
; PTR64-NEXT:    [[P_01_US_US:%.*]] = phi i8* [ null, [[PREHEADER]] ], [ [[GEP:%.*]], [[LOOP]] ]
; PTR64-NEXT:    [[GEP]] = getelementptr inbounds i8, i8* [[P_01_US_US]], i64 1
; PTR64-NEXT:    [[SNEXT:%.*]] = load i8, i8* [[GEP]], align 1
; PTR64-NEXT:    [[EXITCOND:%.*]] = icmp ne i8* [[GEP]], [[END]]
; PTR64-NEXT:    br i1 [[EXITCOND]], label [[LOOP]], label [[EXIT_LOOPEXIT:%.*]]
; PTR64:       exit.loopexit:
; PTR64-NEXT:    [[SNEXT_LCSSA:%.*]] = phi i8 [ [[SNEXT]], [[LOOP]] ]
; PTR64-NEXT:    br label [[EXIT]]
; PTR64:       exit:
; PTR64-NEXT:    [[RET:%.*]] = phi i8 [ 0, [[LOOPGUARD]] ], [ [[SNEXT_LCSSA]], [[EXIT_LOOPEXIT]] ]
; PTR64-NEXT:    ret i8 [[RET]]
;
; PTR32-LABEL: @testnullptrptr(
; PTR32-NEXT:    br label [[LOOPGUARD:%.*]]
; PTR32:       loopguard:
; PTR32-NEXT:    [[GUARD:%.*]] = icmp ult i8* null, [[END:%.*]]
; PTR32-NEXT:    br i1 [[GUARD]], label [[PREHEADER:%.*]], label [[EXIT:%.*]]
; PTR32:       preheader:
; PTR32-NEXT:    br label [[LOOP:%.*]]
; PTR32:       loop:
; PTR32-NEXT:    [[P_01_US_US:%.*]] = phi i8* [ null, [[PREHEADER]] ], [ [[GEP:%.*]], [[LOOP]] ]
; PTR32-NEXT:    [[GEP]] = getelementptr inbounds i8, i8* [[P_01_US_US]], i64 1
; PTR32-NEXT:    [[SNEXT:%.*]] = load i8, i8* [[GEP]], align 1
; PTR32-NEXT:    [[EXITCOND:%.*]] = icmp ne i8* [[GEP]], [[END]]
; PTR32-NEXT:    br i1 [[EXITCOND]], label [[LOOP]], label [[EXIT_LOOPEXIT:%.*]]
; PTR32:       exit.loopexit:
; PTR32-NEXT:    [[SNEXT_LCSSA:%.*]] = phi i8 [ [[SNEXT]], [[LOOP]] ]
; PTR32-NEXT:    br label [[EXIT]]
; PTR32:       exit:
; PTR32-NEXT:    [[RET:%.*]] = phi i8 [ 0, [[LOOPGUARD]] ], [ [[SNEXT_LCSSA]], [[EXIT_LOOPEXIT]] ]
; PTR32-NEXT:    ret i8 [[RET]]
;
  br label %loopguard

loopguard:
  %guard = icmp ult i8* null, %end
  br i1 %guard, label %preheader, label %exit

preheader:
  br label %loop

loop:
  %p.01.us.us = phi i8* [ null, %preheader ], [ %gep, %loop ]
  %s = phi i8 [0, %preheader], [%snext, %loop]
  %gep = getelementptr inbounds i8, i8* %p.01.us.us, i64 1
  %snext = load i8, i8* %gep
  %cmp = icmp ult i8* %gep, %end
  br i1 %cmp, label %loop, label %exit

exit:
  %ret = phi i8 [0, %loopguard], [%snext, %loop]
  ret i8 %ret
}

define i8 @testptrptr(i8* %buf, i8* %end) nounwind {
; PTR64-LABEL: @testptrptr(
; PTR64-NEXT:    br label [[LOOPGUARD:%.*]]
; PTR64:       loopguard:
; PTR64-NEXT:    [[GUARD:%.*]] = icmp ult i8* [[BUF:%.*]], [[END:%.*]]
; PTR64-NEXT:    br i1 [[GUARD]], label [[PREHEADER:%.*]], label [[EXIT:%.*]]
; PTR64:       preheader:
; PTR64-NEXT:    br label [[LOOP:%.*]]
; PTR64:       loop:
; PTR64-NEXT:    [[P_01_US_US:%.*]] = phi i8* [ [[BUF]], [[PREHEADER]] ], [ [[GEP:%.*]], [[LOOP]] ]
; PTR64-NEXT:    [[GEP]] = getelementptr inbounds i8, i8* [[P_01_US_US]], i64 1
; PTR64-NEXT:    [[SNEXT:%.*]] = load i8, i8* [[GEP]], align 1
; PTR64-NEXT:    [[EXITCOND:%.*]] = icmp ne i8* [[GEP]], [[END]]
; PTR64-NEXT:    br i1 [[EXITCOND]], label [[LOOP]], label [[EXIT_LOOPEXIT:%.*]]
; PTR64:       exit.loopexit:
; PTR64-NEXT:    [[SNEXT_LCSSA:%.*]] = phi i8 [ [[SNEXT]], [[LOOP]] ]
; PTR64-NEXT:    br label [[EXIT]]
; PTR64:       exit:
; PTR64-NEXT:    [[RET:%.*]] = phi i8 [ 0, [[LOOPGUARD]] ], [ [[SNEXT_LCSSA]], [[EXIT_LOOPEXIT]] ]
; PTR64-NEXT:    ret i8 [[RET]]
;
; PTR32-LABEL: @testptrptr(
; PTR32-NEXT:    br label [[LOOPGUARD:%.*]]
; PTR32:       loopguard:
; PTR32-NEXT:    [[GUARD:%.*]] = icmp ult i8* [[BUF:%.*]], [[END:%.*]]
; PTR32-NEXT:    br i1 [[GUARD]], label [[PREHEADER:%.*]], label [[EXIT:%.*]]
; PTR32:       preheader:
; PTR32-NEXT:    br label [[LOOP:%.*]]
; PTR32:       loop:
; PTR32-NEXT:    [[P_01_US_US:%.*]] = phi i8* [ [[BUF]], [[PREHEADER]] ], [ [[GEP:%.*]], [[LOOP]] ]
; PTR32-NEXT:    [[GEP]] = getelementptr inbounds i8, i8* [[P_01_US_US]], i64 1
; PTR32-NEXT:    [[SNEXT:%.*]] = load i8, i8* [[GEP]], align 1
; PTR32-NEXT:    [[EXITCOND:%.*]] = icmp ne i8* [[GEP]], [[END]]
; PTR32-NEXT:    br i1 [[EXITCOND]], label [[LOOP]], label [[EXIT_LOOPEXIT:%.*]]
; PTR32:       exit.loopexit:
; PTR32-NEXT:    [[SNEXT_LCSSA:%.*]] = phi i8 [ [[SNEXT]], [[LOOP]] ]
; PTR32-NEXT:    br label [[EXIT]]
; PTR32:       exit:
; PTR32-NEXT:    [[RET:%.*]] = phi i8 [ 0, [[LOOPGUARD]] ], [ [[SNEXT_LCSSA]], [[EXIT_LOOPEXIT]] ]
; PTR32-NEXT:    ret i8 [[RET]]
;
  br label %loopguard

loopguard:
  %guard = icmp ult i8* %buf, %end
  br i1 %guard, label %preheader, label %exit

preheader:
  br label %loop

loop:
  %p.01.us.us = phi i8* [ %buf, %preheader ], [ %gep, %loop ]
  %s = phi i8 [0, %preheader], [%snext, %loop]
  %gep = getelementptr inbounds i8, i8* %p.01.us.us, i64 1
  %snext = load i8, i8* %gep
  %cmp = icmp ult i8* %gep, %end
  br i1 %cmp, label %loop, label %exit

exit:
  %ret = phi i8 [0, %loopguard], [%snext, %loop]
  ret i8 %ret
}

define i8 @testnullptrint(i8* %buf, i8* %end) nounwind {
; PTR64-LABEL: @testnullptrint(
; PTR64-NEXT:    br label [[LOOPGUARD:%.*]]
; PTR64:       loopguard:
; PTR64-NEXT:    [[BI:%.*]] = ptrtoint i8* [[BUF:%.*]] to i32
; PTR64-NEXT:    [[EI:%.*]] = ptrtoint i8* [[END:%.*]] to i32
; PTR64-NEXT:    [[CNT:%.*]] = sub i32 [[EI]], [[BI]]
; PTR64-NEXT:    [[GUARD:%.*]] = icmp ult i32 0, [[CNT]]
; PTR64-NEXT:    br i1 [[GUARD]], label [[PREHEADER:%.*]], label [[EXIT:%.*]]
; PTR64:       preheader:
; PTR64-NEXT:    [[TMP1:%.*]] = add i32 [[EI]], -1
; PTR64-NEXT:    [[TMP2:%.*]] = sub i32 [[TMP1]], [[BI]]
; PTR64-NEXT:    [[TMP3:%.*]] = zext i32 [[TMP2]] to i64
; PTR64-NEXT:    [[TMP4:%.*]] = add nuw nsw i64 [[TMP3]], 1
; PTR64-NEXT:    [[TMP5:%.*]] = inttoptr i64 [[TMP4]] to i8*
; PTR64-NEXT:    br label [[LOOP:%.*]]
; PTR64:       loop:
; PTR64-NEXT:    [[P_01_US_US:%.*]] = phi i8* [ null, [[PREHEADER]] ], [ [[GEP:%.*]], [[LOOP]] ]
; PTR64-NEXT:    [[GEP]] = getelementptr inbounds i8, i8* [[P_01_US_US]], i64 1
; PTR64-NEXT:    [[SNEXT:%.*]] = load i8, i8* [[GEP]], align 1
; PTR64-NEXT:    [[EXITCOND:%.*]] = icmp ne i8* [[GEP]], [[TMP5]]
; PTR64-NEXT:    br i1 [[EXITCOND]], label [[LOOP]], label [[EXIT_LOOPEXIT:%.*]]
; PTR64:       exit.loopexit:
; PTR64-NEXT:    [[SNEXT_LCSSA:%.*]] = phi i8 [ [[SNEXT]], [[LOOP]] ]
; PTR64-NEXT:    br label [[EXIT]]
; PTR64:       exit:
; PTR64-NEXT:    [[RET:%.*]] = phi i8 [ 0, [[LOOPGUARD]] ], [ [[SNEXT_LCSSA]], [[EXIT_LOOPEXIT]] ]
; PTR64-NEXT:    ret i8 [[RET]]
;
; PTR32-LABEL: @testnullptrint(
; PTR32-NEXT:    br label [[LOOPGUARD:%.*]]
; PTR32:       loopguard:
; PTR32-NEXT:    [[BI:%.*]] = ptrtoint i8* [[BUF:%.*]] to i32
; PTR32-NEXT:    [[EI:%.*]] = ptrtoint i8* [[END:%.*]] to i32
; PTR32-NEXT:    [[CNT:%.*]] = sub i32 [[EI]], [[BI]]
; PTR32-NEXT:    [[CNT1:%.*]] = inttoptr i32 [[CNT]] to i8*
; PTR32-NEXT:    [[GUARD:%.*]] = icmp ult i32 0, [[CNT]]
; PTR32-NEXT:    br i1 [[GUARD]], label [[PREHEADER:%.*]], label [[EXIT:%.*]]
; PTR32:       preheader:
; PTR32-NEXT:    br label [[LOOP:%.*]]
; PTR32:       loop:
; PTR32-NEXT:    [[P_01_US_US:%.*]] = phi i8* [ null, [[PREHEADER]] ], [ [[GEP:%.*]], [[LOOP]] ]
; PTR32-NEXT:    [[GEP]] = getelementptr inbounds i8, i8* [[P_01_US_US]], i64 1
; PTR32-NEXT:    [[SNEXT:%.*]] = load i8, i8* [[GEP]], align 1
; PTR32-NEXT:    [[EXITCOND:%.*]] = icmp ne i8* [[GEP]], [[CNT1]]
; PTR32-NEXT:    br i1 [[EXITCOND]], label [[LOOP]], label [[EXIT_LOOPEXIT:%.*]]
; PTR32:       exit.loopexit:
; PTR32-NEXT:    [[SNEXT_LCSSA:%.*]] = phi i8 [ [[SNEXT]], [[LOOP]] ]
; PTR32-NEXT:    br label [[EXIT]]
; PTR32:       exit:
; PTR32-NEXT:    [[RET:%.*]] = phi i8 [ 0, [[LOOPGUARD]] ], [ [[SNEXT_LCSSA]], [[EXIT_LOOPEXIT]] ]
; PTR32-NEXT:    ret i8 [[RET]]
;
  br label %loopguard

loopguard:
  %bi = ptrtoint i8* %buf to i32
  %ei = ptrtoint i8* %end to i32
  %cnt = sub i32 %ei, %bi
  %guard = icmp ult i32 0, %cnt
  br i1 %guard, label %preheader, label %exit

preheader:
  br label %loop

loop:
  %p.01.us.us = phi i8* [ null, %preheader ], [ %gep, %loop ]
  %iv = phi i32 [ 0, %preheader ], [ %ivnext, %loop ]
  %s = phi i8 [0, %preheader], [%snext, %loop]
  %gep = getelementptr inbounds i8, i8* %p.01.us.us, i64 1
  %snext = load i8, i8* %gep
  %ivnext = add i32 %iv, 1
  %cmp = icmp ult i32 %ivnext, %cnt
  br i1 %cmp, label %loop, label %exit

exit:
  %ret = phi i8 [0, %loopguard], [%snext, %loop]
  ret i8 %ret
}

define i8 @testptrint(i8* %buf, i8* %end) nounwind {
; PTR64-LABEL: @testptrint(
; PTR64-NEXT:    br label [[LOOPGUARD:%.*]]
; PTR64:       loopguard:
; PTR64-NEXT:    [[BI:%.*]] = ptrtoint i8* [[BUF:%.*]] to i32
; PTR64-NEXT:    [[EI:%.*]] = ptrtoint i8* [[END:%.*]] to i32
; PTR64-NEXT:    [[CNT:%.*]] = sub i32 [[EI]], [[BI]]
; PTR64-NEXT:    [[GUARD:%.*]] = icmp ult i32 [[BI]], [[CNT]]
; PTR64-NEXT:    br i1 [[GUARD]], label [[PREHEADER:%.*]], label [[EXIT:%.*]]
; PTR64:       preheader:
; PTR64-NEXT:    br label [[LOOP:%.*]]
; PTR64:       loop:
; PTR64-NEXT:    [[P_01_US_US:%.*]] = phi i8* [ [[BUF]], [[PREHEADER]] ], [ [[GEP:%.*]], [[LOOP]] ]
; PTR64-NEXT:    [[IV:%.*]] = phi i32 [ [[BI]], [[PREHEADER]] ], [ [[IVNEXT:%.*]], [[LOOP]] ]
; PTR64-NEXT:    [[GEP]] = getelementptr inbounds i8, i8* [[P_01_US_US]], i64 1
; PTR64-NEXT:    [[SNEXT:%.*]] = load i8, i8* [[GEP]], align 1
; PTR64-NEXT:    [[IVNEXT]] = add nuw i32 [[IV]], 1
; PTR64-NEXT:    [[EXITCOND:%.*]] = icmp ne i32 [[IVNEXT]], [[CNT]]
; PTR64-NEXT:    br i1 [[EXITCOND]], label [[LOOP]], label [[EXIT_LOOPEXIT:%.*]]
; PTR64:       exit.loopexit:
; PTR64-NEXT:    [[SNEXT_LCSSA:%.*]] = phi i8 [ [[SNEXT]], [[LOOP]] ]
; PTR64-NEXT:    br label [[EXIT]]
; PTR64:       exit:
; PTR64-NEXT:    [[RET:%.*]] = phi i8 [ 0, [[LOOPGUARD]] ], [ [[SNEXT_LCSSA]], [[EXIT_LOOPEXIT]] ]
; PTR64-NEXT:    ret i8 [[RET]]
;
; PTR32-LABEL: @testptrint(
; PTR32-NEXT:    br label [[LOOPGUARD:%.*]]
; PTR32:       loopguard:
; PTR32-NEXT:    [[BI:%.*]] = ptrtoint i8* [[BUF:%.*]] to i32
; PTR32-NEXT:    [[EI:%.*]] = ptrtoint i8* [[END:%.*]] to i32
; PTR32-NEXT:    [[CNT:%.*]] = sub i32 [[EI]], [[BI]]
; PTR32-NEXT:    [[GUARD:%.*]] = icmp ult i32 [[BI]], [[CNT]]
; PTR32-NEXT:    br i1 [[GUARD]], label [[PREHEADER:%.*]], label [[EXIT:%.*]]
; PTR32:       preheader:
; PTR32-NEXT:    br label [[LOOP:%.*]]
; PTR32:       loop:
; PTR32-NEXT:    [[P_01_US_US:%.*]] = phi i8* [ [[BUF]], [[PREHEADER]] ], [ [[GEP:%.*]], [[LOOP]] ]
; PTR32-NEXT:    [[IV:%.*]] = phi i32 [ [[BI]], [[PREHEADER]] ], [ [[IVNEXT:%.*]], [[LOOP]] ]
; PTR32-NEXT:    [[GEP]] = getelementptr inbounds i8, i8* [[P_01_US_US]], i64 1
; PTR32-NEXT:    [[SNEXT:%.*]] = load i8, i8* [[GEP]], align 1
; PTR32-NEXT:    [[IVNEXT]] = add nuw i32 [[IV]], 1
; PTR32-NEXT:    [[EXITCOND:%.*]] = icmp ne i32 [[IVNEXT]], [[CNT]]
; PTR32-NEXT:    br i1 [[EXITCOND]], label [[LOOP]], label [[EXIT_LOOPEXIT:%.*]]
; PTR32:       exit.loopexit:
; PTR32-NEXT:    [[SNEXT_LCSSA:%.*]] = phi i8 [ [[SNEXT]], [[LOOP]] ]
; PTR32-NEXT:    br label [[EXIT]]
; PTR32:       exit:
; PTR32-NEXT:    [[RET:%.*]] = phi i8 [ 0, [[LOOPGUARD]] ], [ [[SNEXT_LCSSA]], [[EXIT_LOOPEXIT]] ]
; PTR32-NEXT:    ret i8 [[RET]]
;
  br label %loopguard

loopguard:
  %bi = ptrtoint i8* %buf to i32
  %ei = ptrtoint i8* %end to i32
  %cnt = sub i32 %ei, %bi
  %guard = icmp ult i32 %bi, %cnt
  br i1 %guard, label %preheader, label %exit

preheader:
  br label %loop

loop:
  %p.01.us.us = phi i8* [ %buf, %preheader ], [ %gep, %loop ]
  %iv = phi i32 [ %bi, %preheader ], [ %ivnext, %loop ]
  %s = phi i8 [0, %preheader], [%snext, %loop]
  %gep = getelementptr inbounds i8, i8* %p.01.us.us, i64 1
  %snext = load i8, i8* %gep
  %ivnext = add i32 %iv, 1
  %cmp = icmp ult i32 %ivnext, %cnt
  br i1 %cmp, label %loop, label %exit

exit:
  %ret = phi i8 [0, %loopguard], [%snext, %loop]
  ret i8 %ret
}

; IV and BECount have two different pointer types here.
define void @testnullptr([512 x i8]* %base) nounwind {
; PTR64-LABEL: @testnullptr(
; PTR64-NEXT:  entry:
; PTR64-NEXT:    [[ADD_PTR1603:%.*]] = getelementptr [512 x i8], [512 x i8]* [[BASE:%.*]], i64 0, i64 512
; PTR64-NEXT:    br label [[PREHEADER:%.*]]
; PTR64:       preheader:
; PTR64-NEXT:    [[CMP1604192:%.*]] = icmp ult i8* undef, [[ADD_PTR1603]]
; PTR64-NEXT:    br i1 [[CMP1604192]], label [[FOR_BODY_PREHEADER:%.*]], label [[FOR_END1609:%.*]]
; PTR64:       for.body.preheader:
; PTR64-NEXT:    br label [[FOR_BODY:%.*]]
; PTR64:       for.body:
; PTR64-NEXT:    [[R_17193:%.*]] = phi i8* [ [[INCDEC_PTR1608:%.*]], [[FOR_BODY]] ], [ null, [[FOR_BODY_PREHEADER]] ]
; PTR64-NEXT:    [[INCDEC_PTR1608]] = getelementptr i8, i8* [[R_17193]], i64 1
; PTR64-NEXT:    [[CMP1604:%.*]] = icmp ult i8* [[INCDEC_PTR1608]], [[ADD_PTR1603]]
; PTR64-NEXT:    br i1 [[CMP1604]], label [[FOR_BODY]], label [[FOR_END1609_LOOPEXIT:%.*]]
; PTR64:       for.end1609.loopexit:
; PTR64-NEXT:    br label [[FOR_END1609]]
; PTR64:       for.end1609:
; PTR64-NEXT:    unreachable
;
; PTR32-LABEL: @testnullptr(
; PTR32-NEXT:  entry:
; PTR32-NEXT:    [[ADD_PTR1603:%.*]] = getelementptr [512 x i8], [512 x i8]* [[BASE:%.*]], i64 0, i64 512
; PTR32-NEXT:    br label [[PREHEADER:%.*]]
; PTR32:       preheader:
; PTR32-NEXT:    [[CMP1604192:%.*]] = icmp ult i8* undef, [[ADD_PTR1603]]
; PTR32-NEXT:    br i1 [[CMP1604192]], label [[FOR_BODY_PREHEADER:%.*]], label [[FOR_END1609:%.*]]
; PTR32:       for.body.preheader:
; PTR32-NEXT:    br label [[FOR_BODY:%.*]]
; PTR32:       for.body:
; PTR32-NEXT:    [[R_17193:%.*]] = phi i8* [ [[INCDEC_PTR1608:%.*]], [[FOR_BODY]] ], [ null, [[FOR_BODY_PREHEADER]] ]
; PTR32-NEXT:    [[INCDEC_PTR1608]] = getelementptr i8, i8* [[R_17193]], i64 1
; PTR32-NEXT:    [[CMP1604:%.*]] = icmp ult i8* [[INCDEC_PTR1608]], [[ADD_PTR1603]]
; PTR32-NEXT:    br i1 [[CMP1604]], label [[FOR_BODY]], label [[FOR_END1609_LOOPEXIT:%.*]]
; PTR32:       for.end1609.loopexit:
; PTR32-NEXT:    br label [[FOR_END1609]]
; PTR32:       for.end1609:
; PTR32-NEXT:    unreachable
;
entry:
  %add.ptr1603 = getelementptr [512 x i8], [512 x i8]* %base, i64 0, i64 512
  br label %preheader

preheader:
  %cmp1604192 = icmp ult i8* undef, %add.ptr1603
  br i1 %cmp1604192, label %for.body, label %for.end1609

for.body:
  %r.17193 = phi i8* [ %incdec.ptr1608, %for.body ], [ null, %preheader ]
  %incdec.ptr1608 = getelementptr i8, i8* %r.17193, i64 1
  %cmp1604 = icmp ult i8* %incdec.ptr1608, %add.ptr1603
  br i1 %cmp1604, label %for.body, label %for.end1609

for.end1609:
  unreachable
}
