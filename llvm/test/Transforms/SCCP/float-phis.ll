; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -sccp -S | FileCheck %s

declare void @use(i1)

define void @test(i1 %c) {
; CHECK-LABEL: @test(
; CHECK-NEXT:    br label [[DO_BODY:%.*]]
; CHECK:       do.body:
; CHECK-NEXT:    br i1 [[C:%.*]], label [[DO_BODY]], label [[FOR_COND41:%.*]]
; CHECK:       for.cond41:
; CHECK-NEXT:    call void @use(i1 true)
; CHECK-NEXT:    br label [[FOR_COND41]]
;
  br label %do.body

do.body:                                          ; preds = %do.body, %entry
  br i1 %c, label %do.body, label %for.cond41

for.cond41:                                       ; preds = %for.cond41, %do.body
  %mid.0 = phi float [ 0.000000e+00, %for.cond41 ], [ undef, %do.body ]
  %fc = fcmp oeq float %mid.0, 0.000000e+00
  call void @use(i1 %fc)

  br label %for.cond41
}
