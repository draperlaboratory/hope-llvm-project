; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt -attributor -attributor-manifest-internal -attributor-disable=false -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=1 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_NPM,NOT_CGSCC_OPM,NOT_TUNIT_NPM,IS__TUNIT____,IS________OPM,IS__TUNIT_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal -attributor-disable=false -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=1 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_OPM,NOT_CGSCC_NPM,NOT_TUNIT_OPM,IS__TUNIT____,IS________NPM,IS__TUNIT_NPM
; RUN: opt -attributor-cgscc -attributor-manifest-internal -attributor-disable=false -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_NPM,IS__CGSCC____,IS________OPM,IS__CGSCC_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal -attributor-disable=false -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_OPM,IS__CGSCC____,IS________NPM,IS__CGSCC_NPM

%T = type { i32, i32, i32, i32 }
@G = constant %T { i32 0, i32 0, i32 17, i32 25 }

define internal i32 @test(%T* %p) {
; CHECK-LABEL: define {{[^@]+}}@test()
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A_GEP:%.*]] = getelementptr [[T:%.*]], %T* @G, i64 0, i32 3
; CHECK-NEXT:    [[B_GEP:%.*]] = getelementptr [[T]], %T* @G, i64 0, i32 2
; CHECK-NEXT:    [[A:%.*]] = load i32, i32* [[A_GEP]], align 4
; CHECK-NEXT:    [[B:%.*]] = load i32, i32* [[B_GEP]], align 4
; CHECK-NEXT:    [[V:%.*]] = add i32 [[A]], [[B]]
; CHECK-NEXT:    ret i32 [[V]]
;
entry:
  %a.gep = getelementptr %T, %T* %p, i64 0, i32 3
  %b.gep = getelementptr %T, %T* %p, i64 0, i32 2
  %a = load i32, i32* %a.gep
  %b = load i32, i32* %b.gep
  %v = add i32 %a, %b
  ret i32 %v
}

define i32 @caller() {
; CHECK-LABEL: define {{[^@]+}}@caller()
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[V:%.*]] = call i32 @test()
; CHECK-NEXT:    ret i32 [[V]]
;
entry:
  %v = call i32 @test(%T* @G)
  ret i32 %v
}
