; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -simplifycfg -simplifycfg-require-and-preserve-domtree=1 < %s | FileCheck %s

declare void @zzz()

define i32 @lex(i1 %c0, i1 %c1, i32 %r0, i32 %r1, i32 %v) {
; CHECK-LABEL: @lex(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0_NOT:%.*]] = xor i1 [[C0:%.*]], true
; CHECK-NEXT:    [[C1_NOT:%.*]] = xor i1 [[C1:%.*]], true
; CHECK-NEXT:    [[BRMERGE:%.*]] = or i1 [[C0_NOT]], [[C1_NOT]]
; CHECK-NEXT:    [[R0_MUX:%.*]] = select i1 [[C0_NOT]], i32 [[R0:%.*]], i32 [[R1:%.*]]
; CHECK-NEXT:    br i1 [[BRMERGE]], label [[IF_THEN:%.*]], label [[DO_BODY:%.*]]
; CHECK:       if.then:
; CHECK-NEXT:    [[MERGE:%.*]] = phi i32 [ [[R0_MUX]], [[ENTRY:%.*]] ], [ [[R1]], [[DO_BODY]] ]
; CHECK-NEXT:    ret i32 [[MERGE]]
; CHECK:       do.body:
; CHECK-NEXT:    call void @zzz()
; CHECK-NEXT:    switch i32 [[V:%.*]], label [[IF_THEN]] [
; CHECK-NEXT:    i32 10, label [[DO_BODY]]
; CHECK-NEXT:    i32 32, label [[DO_BODY]]
; CHECK-NEXT:    i32 9, label [[DO_BODY]]
; CHECK-NEXT:    ]
;
entry:
  br i1 %c0, label %if.end, label %if.then

if.then:                                          ; preds = %entry
  ret i32 %r0

if.end:                                           ; preds = %entry
  br i1 %c1, label %do.body, label %do.end

do.body:                                          ; preds = %if.then193, %if.then193, %if.then193, %do.body, %do.body, %if.end
  call void @zzz()
  switch i32 %v, label %do.end [
  i32 10, label %if.then193
  i32 32, label %do.body
  i32 9, label %do.body
  ]

if.then193:                                       ; preds = %do.body
  switch i32 %v, label %do.end [
  i32 32, label %do.body
  i32 10, label %do.body
  i32 9, label %do.body
  ]

do.end:                                           ; preds = %if.then193, %do.body, %if.end
  ret i32 %r1
}
