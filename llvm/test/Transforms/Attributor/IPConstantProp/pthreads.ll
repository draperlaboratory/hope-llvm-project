; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt -attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=7 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_NPM,NOT_CGSCC_OPM,NOT_TUNIT_NPM,IS__TUNIT____,IS________OPM,IS__TUNIT_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=7 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_OPM,NOT_CGSCC_NPM,NOT_TUNIT_OPM,IS__TUNIT____,IS________NPM,IS__TUNIT_NPM
; RUN: opt -attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_NPM,IS__CGSCC____,IS________OPM,IS__CGSCC_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_OPM,IS__CGSCC____,IS________NPM,IS__CGSCC_NPM
;
;    #include <pthread.h>
;
;    void *GlobalVPtr;
;
;    static void *foo(void *arg) { return arg; }
;    static void *bar(void *arg) { return arg; }
;
;    int main() {
;      pthread_t thread;
;      pthread_create(&thread, NULL, foo, NULL);
;      pthread_create(&thread, NULL, bar, &GlobalVPtr);
;      return 0;
;    }
;
; Verify the constant values NULL and &GlobalVPtr are propagated into foo and
; bar, respectively.
;
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

%union.pthread_attr_t = type { i64, [48 x i8] }

@GlobalVPtr = common dso_local global i8* null, align 8

; FIXME: nocapture & noalias for @GlobalVPtr in %call1
; FIXME: nocapture & noalias for %alloc2 in %call3

define dso_local i32 @main() {
; IS__TUNIT____-LABEL: define {{[^@]+}}@main()
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    [[ALLOC1:%.*]] = alloca i8, align 8
; IS__TUNIT____-NEXT:    [[ALLOC2:%.*]] = alloca i8, align 8
; IS__TUNIT____-NEXT:    [[THREAD:%.*]] = alloca i64, align 8
; IS__TUNIT____-NEXT:    [[CALL:%.*]] = call i32 @pthread_create(i64* nonnull align 8 dereferenceable(8) [[THREAD]], %union.pthread_attr_t* noalias nocapture align 536870912 null, i8* (i8*)* nonnull @foo, i8* noalias nocapture nofree readnone align 536870912 undef)
; IS__TUNIT____-NEXT:    [[CALL1:%.*]] = call i32 @pthread_create(i64* nonnull align 8 dereferenceable(8) [[THREAD]], %union.pthread_attr_t* noalias nocapture align 536870912 null, i8* (i8*)* nonnull @bar, i8* noalias nofree nonnull readnone align 8 dereferenceable(8) "no-capture-maybe-returned" undef)
; IS__TUNIT____-NEXT:    [[CALL2:%.*]] = call i32 @pthread_create(i64* nonnull align 8 dereferenceable(8) [[THREAD]], %union.pthread_attr_t* noalias nocapture align 536870912 null, i8* (i8*)* nonnull @baz, i8* noalias nocapture nofree nonnull readnone align 8 dereferenceable(1) [[ALLOC1]])
; IS__TUNIT____-NEXT:    [[CALL3:%.*]] = call i32 @pthread_create(i64* nonnull align 8 dereferenceable(8) [[THREAD]], %union.pthread_attr_t* noalias nocapture align 536870912 null, i8* (i8*)* nonnull @buz, i8* noalias nofree nonnull readnone align 8 dereferenceable(1) "no-capture-maybe-returned" [[ALLOC2]])
; IS__TUNIT____-NEXT:    ret i32 0
;
; IS__CGSCC_OPM-LABEL: define {{[^@]+}}@main()
; IS__CGSCC_OPM-NEXT:  entry:
; IS__CGSCC_OPM-NEXT:    [[ALLOC1:%.*]] = alloca i8, align 8
; IS__CGSCC_OPM-NEXT:    [[ALLOC2:%.*]] = alloca i8, align 8
; IS__CGSCC_OPM-NEXT:    [[THREAD:%.*]] = alloca i64, align 8
; IS__CGSCC_OPM-NEXT:    [[CALL:%.*]] = call i32 @pthread_create(i64* nonnull align 8 dereferenceable(8) [[THREAD]], %union.pthread_attr_t* noalias nocapture align 536870912 null, i8* (i8*)* nonnull @foo, i8* noalias nocapture align 536870912 null)
; IS__CGSCC_OPM-NEXT:    [[CALL1:%.*]] = call i32 @pthread_create(i64* nonnull align 8 dereferenceable(8) [[THREAD]], %union.pthread_attr_t* noalias nocapture align 536870912 null, i8* (i8*)* nonnull @bar, i8* nonnull align 8 dereferenceable(8) bitcast (i8** @GlobalVPtr to i8*))
; IS__CGSCC_OPM-NEXT:    [[CALL2:%.*]] = call i32 @pthread_create(i64* nonnull align 8 dereferenceable(8) [[THREAD]], %union.pthread_attr_t* noalias nocapture align 536870912 null, i8* (i8*)* nonnull @baz, i8* nocapture nonnull align 8 dereferenceable(1) [[ALLOC1]])
; IS__CGSCC_OPM-NEXT:    [[CALL3:%.*]] = call i32 @pthread_create(i64* nonnull align 8 dereferenceable(8) [[THREAD]], %union.pthread_attr_t* noalias nocapture align 536870912 null, i8* (i8*)* nonnull @buz, i8* nonnull align 8 dereferenceable(1) [[ALLOC2]])
; IS__CGSCC_OPM-NEXT:    ret i32 0
;
; IS__CGSCC_NPM-LABEL: define {{[^@]+}}@main()
; IS__CGSCC_NPM-NEXT:  entry:
; IS__CGSCC_NPM-NEXT:    [[ALLOC1:%.*]] = alloca i8, align 8
; IS__CGSCC_NPM-NEXT:    [[ALLOC2:%.*]] = alloca i8, align 8
; IS__CGSCC_NPM-NEXT:    [[THREAD:%.*]] = alloca i64, align 8
; IS__CGSCC_NPM-NEXT:    [[CALL:%.*]] = call i32 @pthread_create(i64* nonnull align 8 dereferenceable(8) [[THREAD]], %union.pthread_attr_t* noalias nocapture align 536870912 null, i8* (i8*)* nonnull @foo, i8* noalias nocapture nofree readnone align 536870912 null)
; IS__CGSCC_NPM-NEXT:    [[CALL1:%.*]] = call i32 @pthread_create(i64* nonnull align 8 dereferenceable(8) [[THREAD]], %union.pthread_attr_t* noalias nocapture align 536870912 null, i8* (i8*)* nonnull @bar, i8* noalias nofree nonnull readnone align 8 dereferenceable(8) bitcast (i8** @GlobalVPtr to i8*))
; IS__CGSCC_NPM-NEXT:    [[CALL2:%.*]] = call i32 @pthread_create(i64* nonnull align 8 dereferenceable(8) [[THREAD]], %union.pthread_attr_t* noalias nocapture align 536870912 null, i8* (i8*)* nonnull @baz, i8* noalias nocapture nofree nonnull readnone align 8 dereferenceable(1) [[ALLOC1]])
; IS__CGSCC_NPM-NEXT:    [[CALL3:%.*]] = call i32 @pthread_create(i64* nonnull align 8 dereferenceable(8) [[THREAD]], %union.pthread_attr_t* noalias nocapture align 536870912 null, i8* (i8*)* nonnull @buz, i8* noalias nofree nonnull readnone align 8 dereferenceable(1) [[ALLOC2]])
; IS__CGSCC_NPM-NEXT:    ret i32 0
;
entry:
  %alloc1 = alloca i8, align 8
  %alloc2 = alloca i8, align 8
  %thread = alloca i64, align 8
  %call = call i32 @pthread_create(i64* nonnull %thread, %union.pthread_attr_t* null, i8* (i8*)* nonnull @foo, i8* null)
  %call1 = call i32 @pthread_create(i64* nonnull %thread, %union.pthread_attr_t* null, i8* (i8*)* nonnull @bar, i8* bitcast (i8** @GlobalVPtr to i8*))
  %call2 = call i32 @pthread_create(i64* nonnull %thread, %union.pthread_attr_t* null, i8* (i8*)* nonnull @baz, i8* nocapture %alloc1)
  %call3 = call i32 @pthread_create(i64* nonnull %thread, %union.pthread_attr_t* null, i8* (i8*)* nonnull @buz, i8* %alloc2)
  ret i32 0
}

declare !callback !0 dso_local i32 @pthread_create(i64*, %union.pthread_attr_t*, i8* (i8*)*, i8*)

define internal i8* @foo(i8* %arg) {
; CHECK-LABEL: define {{[^@]+}}@foo
; CHECK-SAME: (i8* noalias nofree readnone returned align 536870912 "no-capture-maybe-returned" [[ARG:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret i8* null
;
entry:
  ret i8* %arg
}

define internal i8* @bar(i8* %arg) {
; IS__TUNIT____-LABEL: define {{[^@]+}}@bar
; IS__TUNIT____-SAME: (i8* noalias nofree nonnull readnone returned align 8 dereferenceable(8) "no-capture-maybe-returned" [[ARG:%.*]])
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    ret i8* bitcast (i8** @GlobalVPtr to i8*)
;
; IS__CGSCC_OPM-LABEL: define {{[^@]+}}@bar
; IS__CGSCC_OPM-SAME: (i8* nofree nonnull readnone returned align 8 dereferenceable(8) "no-capture-maybe-returned" [[ARG:%.*]])
; IS__CGSCC_OPM-NEXT:  entry:
; IS__CGSCC_OPM-NEXT:    ret i8* bitcast (i8** @GlobalVPtr to i8*)
;
; IS__CGSCC_NPM-LABEL: define {{[^@]+}}@bar
; IS__CGSCC_NPM-SAME: (i8* nofree readnone returned "no-capture-maybe-returned" [[ARG:%.*]])
; IS__CGSCC_NPM-NEXT:  entry:
; IS__CGSCC_NPM-NEXT:    ret i8* bitcast (i8** @GlobalVPtr to i8*)
;
entry:
  ret i8* %arg
}

define internal i8* @baz(i8* %arg) {
; IS__TUNIT____-LABEL: define {{[^@]+}}@baz
; IS__TUNIT____-SAME: (i8* noalias nofree nonnull readnone returned align 8 dereferenceable(1) "no-capture-maybe-returned" [[ARG:%.*]])
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    ret i8* [[ARG]]
;
; IS__CGSCC____-LABEL: define {{[^@]+}}@baz
; IS__CGSCC____-SAME: (i8* nofree nonnull readnone returned align 8 dereferenceable(1) "no-capture-maybe-returned" [[ARG:%.*]])
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    ret i8* [[ARG]]
;
entry:
  ret i8* %arg
}

define internal i8* @buz(i8* %arg) {
; IS__TUNIT____-LABEL: define {{[^@]+}}@buz
; IS__TUNIT____-SAME: (i8* noalias nofree nonnull readnone returned align 8 dereferenceable(1) "no-capture-maybe-returned" [[ARG:%.*]])
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    ret i8* [[ARG]]
;
; IS__CGSCC____-LABEL: define {{[^@]+}}@buz
; IS__CGSCC____-SAME: (i8* nofree nonnull readnone returned align 8 dereferenceable(1) "no-capture-maybe-returned" [[ARG:%.*]])
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    ret i8* [[ARG]]
;
entry:
  ret i8* %arg
}

!1 = !{i64 2, i64 3, i1 false}
!0 = !{!1}
