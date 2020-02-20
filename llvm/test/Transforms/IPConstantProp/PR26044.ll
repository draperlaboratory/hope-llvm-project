; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt < %s -S -ipsccp | FileCheck %s
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define void @fn2(i32* %P) {
; CHECK-LABEL: define {{[^@]+}}@fn2
; CHECK-SAME: (i32* [[P:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[IF_END:%.*]]
; CHECK:       for.cond1:
; CHECK-NEXT:    br i1 false, label [[IF_END]], label [[IF_END]]
; CHECK:       if.end:
; CHECK-NEXT:    [[CALL:%.*]] = call i32 @fn1(i32 undef)
; CHECK-NEXT:    store i32 [[CALL]], i32* [[P]]
; CHECK-NEXT:    br label [[FOR_COND1:%.*]]
;
entry:
  br label %if.end

for.cond1:                                        ; preds = %if.end, %for.end
  br i1 undef, label %if.end, label %if.end

if.end:                                           ; preds = %lbl, %for.cond1
  %e.2 = phi i32* [ undef, %entry ], [ null, %for.cond1 ], [ null, %for.cond1 ]
  %0 = load i32, i32* %e.2, align 4
  %call = call i32 @fn1(i32 %0)
  store i32 %call, i32* %P
  br label %for.cond1
}

define internal i32 @fn1(i32 %p1) {
; CHECK-LABEL: define {{[^@]+}}@fn1
; CHECK-SAME: (i32 [[P1:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TOBOOL:%.*]] = icmp ne i32 undef, 0
; CHECK-NEXT:    [[COND:%.*]] = select i1 [[TOBOOL]], i32 undef, i32 undef
; CHECK-NEXT:    ret i32 [[COND]]
;
entry:
  %tobool = icmp ne i32 %p1, 0
  %cond = select i1 %tobool, i32 %p1, i32 %p1
  ret i32 %cond
}

define void @fn_no_null_opt(i32* %P) #0 {
; CHECK-LABEL: define {{[^@]+}}@fn_no_null_opt
; CHECK-SAME: (i32* [[P:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[IF_END:%.*]]
; CHECK:       for.cond1:
; CHECK-NEXT:    br i1 false, label [[IF_END]], label [[IF_END]]
; CHECK:       if.end:
; CHECK-NEXT:    [[TMP0:%.*]] = load i32, i32* null, align 4
; CHECK-NEXT:    [[CALL:%.*]] = call i32 @fn0(i32 [[TMP0]])
; CHECK-NEXT:    store i32 [[CALL]], i32* [[P]]
; CHECK-NEXT:    br label [[FOR_COND1:%.*]]
;
entry:
  br label %if.end

for.cond1:                                        ; preds = %if.end, %for.end
  br i1 undef, label %if.end, label %if.end

if.end:                                           ; preds = %lbl, %for.cond1
  %e.2 = phi i32* [ undef, %entry ], [ null, %for.cond1 ], [ null, %for.cond1 ]
  %0 = load i32, i32* %e.2, align 4
  %call = call i32 @fn0(i32 %0)
  store i32 %call, i32* %P
  br label %for.cond1
}

define internal i32 @fn0(i32 %p1) {
; CHECK-LABEL: define {{[^@]+}}@fn0
; CHECK-SAME: (i32 [[P1:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TOBOOL:%.*]] = icmp ne i32 [[P1]], 0
; CHECK-NEXT:    [[COND:%.*]] = select i1 [[TOBOOL]], i32 [[P1]], i32 [[P1]]
; CHECK-NEXT:    ret i32 [[COND]]
;
entry:
  %tobool = icmp ne i32 %p1, 0
  %cond = select i1 %tobool, i32 %p1, i32 %p1
  ret i32 %cond
}

attributes #0 = { "null-pointer-is-valid"="true" }
