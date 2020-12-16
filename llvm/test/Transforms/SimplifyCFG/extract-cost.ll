; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -simplifycfg -simplifycfg-require-and-preserve-domtree=1 -S  < %s | FileCheck %s

declare { i32, i1 } @llvm.uadd.with.overflow.i32(i32, i32) #1

define i32 @f(i32 %a, i32 %b) #0 {
; CHECK-LABEL: @f(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[UADD:%.*]] = tail call { i32, i1 } @llvm.uadd.with.overflow.i32(i32 [[A:%.*]], i32 [[B:%.*]])
; CHECK-NEXT:    [[CMP:%.*]] = extractvalue { i32, i1 } [[UADD]], 1
; CHECK-NEXT:    [[TMP0:%.*]] = extractvalue { i32, i1 } [[UADD]], 0
; CHECK-NEXT:    [[SPEC_SELECT:%.*]] = select i1 [[CMP]], i32 0, i32 [[TMP0]]
; CHECK-NEXT:    ret i32 [[SPEC_SELECT]]
;
entry:
  %uadd = tail call { i32, i1 } @llvm.uadd.with.overflow.i32(i32 %a, i32 %b)
  %cmp = extractvalue { i32, i1 } %uadd, 1
  br i1 %cmp, label %return, label %if.end

if.end:                                           ; preds = %entry
  %0 = extractvalue { i32, i1 } %uadd, 0
  br label %return

return:                                           ; preds = %entry, %if.end
  %retval.0 = phi i32 [ %0, %if.end ], [ 0, %entry ]
  ret i32 %retval.0
}

define i1 @PR32078(<4 x i32> %a, <4 x i32> %b) {
; CHECK-LABEL: @PR32078(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq <4 x i32> [[A:%.*]], [[B:%.*]]
; CHECK-NEXT:    [[CMP0:%.*]] = extractelement <4 x i1> [[CMP]], i32 0
; CHECK-NEXT:    [[CMP1:%.*]] = extractelement <4 x i1> [[CMP]], i32 1
; CHECK-NEXT:    [[CMP2:%.*]] = extractelement <4 x i1> [[CMP]], i32 2
; CHECK-NEXT:    [[CMP3:%.*]] = extractelement <4 x i1> [[CMP]], i32 3
; CHECK-NEXT:    [[CMP0_NOT:%.*]] = xor i1 [[CMP0]], true
; CHECK-NEXT:    [[CMP1_NOT:%.*]] = xor i1 [[CMP1]], true
; CHECK-NEXT:    [[BRMERGE:%.*]] = or i1 [[CMP0_NOT]], [[CMP1_NOT]]
; CHECK-NEXT:    br i1 [[BRMERGE]], label [[EXIT:%.*]], label [[CMP1_TRUE:%.*]]
; CHECK:       cmp1_true:
; CHECK-NEXT:    [[SPEC_SELECT:%.*]] = select i1 [[CMP2]], i1 [[CMP3]], i1 false
; CHECK-NEXT:    ret i1 [[SPEC_SELECT]]
; CHECK:       exit:
; CHECK-NEXT:    ret i1 false
;
entry:
  %cmp = icmp eq <4 x i32> %a, %b
  %cmp0 = extractelement <4 x i1> %cmp, i32 0
  %cmp1 = extractelement <4 x i1> %cmp, i32 1
  %cmp2 = extractelement <4 x i1> %cmp, i32 2
  %cmp3 = extractelement <4 x i1> %cmp, i32 3
  br i1 %cmp0, label %cmp0_true, label %exit

cmp0_true:
  br i1 %cmp1, label %cmp1_true, label %exit

cmp1_true:
  br i1 %cmp2, label %cmp2_true, label %exit

cmp2_true:
  br label %exit

exit:
  %r = phi i1 [ false, %cmp0_true ], [ false, %cmp1_true ], [ false, %entry ], [ %cmp3, %cmp2_true ]
  ret i1 %r
}
