; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt -attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=6 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_NPM,NOT_CGSCC_OPM,NOT_TUNIT_NPM,IS__TUNIT____,IS________OPM,IS__TUNIT_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=6 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_OPM,NOT_CGSCC_NPM,NOT_TUNIT_OPM,IS__TUNIT____,IS________NPM,IS__TUNIT_NPM
; RUN: opt -attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_NPM,IS__CGSCC____,IS________OPM,IS__CGSCC_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_OPM,IS__CGSCC____,IS________NPM,IS__CGSCC_NPM

target datalayout = "E-p:64:64:64-a0:0:8-f32:32:32-f64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-v64:64:64-v128:128:128"

%struct.ss = type { i32, i32 }

; Argpromote + sroa should change this to passing the two integers by value.
define internal i32 @f(%struct.ss* inalloca  %s) {
; IS__TUNIT____-LABEL: define {{[^@]+}}@f
; IS__TUNIT____-SAME: (%struct.ss* inalloca noalias nocapture nofree nonnull align 4 dereferenceable(8) [[S:%.*]])
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    [[F0:%.*]] = getelementptr [[STRUCT_SS:%.*]], %struct.ss* [[S]], i32 0, i32 0
; IS__TUNIT____-NEXT:    [[F1:%.*]] = getelementptr [[STRUCT_SS]], %struct.ss* [[S]], i32 0, i32 1
; IS__TUNIT____-NEXT:    [[A:%.*]] = load i32, i32* [[F0]], align 4
; IS__TUNIT____-NEXT:    [[B:%.*]] = load i32, i32* [[F1]], align 4
; IS__TUNIT____-NEXT:    [[R:%.*]] = add i32 [[A]], [[B]]
; IS__TUNIT____-NEXT:    ret i32 [[R]]
;
; IS__CGSCC____-LABEL: define {{[^@]+}}@f
; IS__CGSCC____-SAME: (%struct.ss* inalloca nocapture nofree nonnull align 4 dereferenceable(8) [[S:%.*]])
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    [[F0:%.*]] = getelementptr [[STRUCT_SS:%.*]], %struct.ss* [[S]], i32 0, i32 0
; IS__CGSCC____-NEXT:    [[F1:%.*]] = getelementptr [[STRUCT_SS]], %struct.ss* [[S]], i32 0, i32 1
; IS__CGSCC____-NEXT:    [[A:%.*]] = load i32, i32* [[F0]], align 4
; IS__CGSCC____-NEXT:    [[B:%.*]] = load i32, i32* [[F1]], align 4
; IS__CGSCC____-NEXT:    [[R:%.*]] = add i32 [[A]], [[B]]
; IS__CGSCC____-NEXT:    ret i32 [[R]]
;
entry:
  %f0 = getelementptr %struct.ss, %struct.ss* %s, i32 0, i32 0
  %f1 = getelementptr %struct.ss, %struct.ss* %s, i32 0, i32 1
  %a = load i32, i32* %f0, align 4
  %b = load i32, i32* %f1, align 4
  %r = add i32 %a, %b
  ret i32 %r
}

define i32 @main() {
; CHECK-LABEL: define {{[^@]+}}@main()
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[S:%.*]] = alloca inalloca [[STRUCT_SS:%.*]]
; CHECK-NEXT:    [[F0:%.*]] = getelementptr [[STRUCT_SS]], %struct.ss* [[S]], i32 0, i32 0
; CHECK-NEXT:    [[F1:%.*]] = getelementptr [[STRUCT_SS]], %struct.ss* [[S]], i32 0, i32 1
; CHECK-NEXT:    store i32 1, i32* [[F0]], align 4
; CHECK-NEXT:    store i32 2, i32* [[F1]], align 4
; CHECK-NEXT:    [[R:%.*]] = call i32 @f(%struct.ss* inalloca noalias nocapture nofree nonnull align 4 dereferenceable(8) [[S]])
; CHECK-NEXT:    ret i32 [[R]]
;
entry:
  %S = alloca inalloca %struct.ss
  %f0 = getelementptr %struct.ss, %struct.ss* %S, i32 0, i32 0
  %f1 = getelementptr %struct.ss, %struct.ss* %S, i32 0, i32 1
  store i32 1, i32* %f0, align 4
  store i32 2, i32* %f1, align 4
  %r = call i32 @f(%struct.ss* inalloca %S)
  ret i32 %r
}

; Argpromote can't promote %a because of the icmp use.
define internal i1 @g(%struct.ss* %a, %struct.ss* inalloca %b) nounwind  {
; IS__CGSCC____-LABEL: define {{[^@]+}}@g
; IS__CGSCC____-SAME: (%struct.ss* nocapture nofree nonnull readnone align 4 dereferenceable(8) [[A:%.*]], %struct.ss* inalloca nocapture nofree nonnull writeonly align 4 dereferenceable(8) [[B:%.*]])
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    ret i1 undef
;
entry:
  %c = icmp eq %struct.ss* %a, %b
  ret i1 %c
}

define i32 @test() {
; CHECK-LABEL: define {{[^@]+}}@test()
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret i32 0
;
entry:
  %S = alloca inalloca %struct.ss
  %c = call i1 @g(%struct.ss* %S, %struct.ss* inalloca %S)
  ret i32 0
}
