; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt -attributor -attributor-manifest-internal -attributor-disable=false -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=7 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_NPM,NOT_CGSCC_OPM,NOT_TUNIT_NPM,IS__TUNIT____,IS________OPM,IS__TUNIT_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal -attributor-disable=false -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=7 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_OPM,NOT_CGSCC_NPM,NOT_TUNIT_OPM,IS__TUNIT____,IS________NPM,IS__TUNIT_NPM
; RUN: opt -attributor-cgscc -attributor-manifest-internal -attributor-disable=false -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_NPM,IS__CGSCC____,IS________OPM,IS__CGSCC_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal -attributor-disable=false -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_OPM,IS__CGSCC____,IS________NPM,IS__CGSCC_NPM
; XFAIL: *

; TEST 1 - negative.

; void *G;
; void *foo(){
;   void *V = malloc(4);
;   G = V;
;   return V;
; }

@G = external global i8*

define i8* @foo() {
; CHECK-LABEL: define {{[^@]+}}@foo()
; CHECK-NEXT:    [[TMP1:%.*]] = tail call noalias i8* @malloc(i64 4)
; CHECK-NEXT:    store i8* [[TMP1]], i8** @G, align 8
; CHECK-NEXT:    ret i8* [[TMP1]]
;
  %1 = tail call noalias i8* @malloc(i64 4)
  store i8* %1, i8** @G, align 8
  ret i8* %1
}

declare noalias i8* @malloc(i64)

; TEST 2
; call noalias function in return instruction.

define i8* @return_noalias(){
; CHECK-LABEL: define {{[^@]+}}@return_noalias()
; CHECK-NEXT:    [[TMP1:%.*]] = tail call noalias i8* @malloc(i64 4)
; CHECK-NEXT:    ret i8* [[TMP1]]
;
  %1 = tail call noalias i8* @malloc(i64 4)
  ret i8* %1
}

define void @nocapture(i8* %a){
; CHECK-LABEL: define {{[^@]+}}@nocapture
; CHECK-SAME: (i8* nocapture nofree readnone [[A:%.*]])
; CHECK-NEXT:    ret void
;
  ret void
}

define i8* @return_noalias_looks_like_capture(){
; CHECK-LABEL: define {{[^@]+}}@return_noalias_looks_like_capture()
; CHECK-NEXT:    [[TMP1:%.*]] = tail call noalias i8* @malloc(i64 4)
; CHECK-NEXT:    ret i8* [[TMP1]]
;
  %1 = tail call noalias i8* @malloc(i64 4)
  call void @nocapture(i8* %1)
  ret i8* %1
}

define i16* @return_noalias_casted(){
; CHECK-LABEL: define {{[^@]+}}@return_noalias_casted()
; CHECK-NEXT:    [[TMP1:%.*]] = tail call noalias i8* @malloc(i64 4)
; CHECK-NEXT:    [[C:%.*]] = bitcast i8* [[TMP1]] to i16*
; CHECK-NEXT:    ret i16* [[C]]
;
  %1 = tail call noalias i8* @malloc(i64 4)
  %c = bitcast i8* %1 to i16*
  ret i16* %c
}

declare i8* @alias()

; TEST 3
define i8* @call_alias(){
; CHECK-LABEL: define {{[^@]+}}@call_alias()
; CHECK-NEXT:    [[TMP1:%.*]] = tail call i8* @alias()
; CHECK-NEXT:    ret i8* [[TMP1]]
;
  %1 = tail call i8* @alias()
  ret i8* %1
}

; TEST 4
; void *baz();
; void *foo(int a);
;
; void *bar()  {
;   foo(0);
;    return baz();
; }
;
; void *foo(int a)  {
;   if (a)
;   bar();
;   return malloc(4);
; }

define i8* @bar() nounwind uwtable {
; CHECK-LABEL: define {{[^@]+}}@bar()
; CHECK-NEXT:    [[TMP1:%.*]] = tail call i8* (...) @baz()
; CHECK-NEXT:    ret i8* [[TMP1]]
;
  %1 = tail call i8* (...) @baz()
  ret i8* %1
}

define i8* @foo1(i32 %0) nounwind uwtable {
; CHECK-LABEL: define {{[^@]+}}@foo1
; CHECK-SAME: (i32 [[TMP0:%.*]])
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP0]], 0
; CHECK-NEXT:    br i1 [[TMP2]], label [[TMP5:%.*]], label [[TMP3:%.*]]
; CHECK:       3:
; CHECK-NEXT:    [[TMP4:%.*]] = tail call i8* (...) @baz()
; CHECK-NEXT:    br label [[TMP5]]
; CHECK:       5:
; CHECK-NEXT:    [[TMP6:%.*]] = tail call noalias i8* @malloc(i64 4)
; CHECK-NEXT:    ret i8* [[TMP6]]
;
  %2 = icmp eq i32 %0, 0
  br i1 %2, label %5, label %3

3:                                                ; preds = %1
  %4 = tail call i8* (...) @baz()
  br label %5

5:                                                ; preds = %1, %3
  %6 = tail call noalias i8* @malloc(i64 4)
  ret i8* %6
}

declare i8* @baz(...) nounwind uwtable

; TEST 5

; Returning global pointer. Should not be noalias.
define i8** @getter() {
; CHECK-LABEL: define {{[^@]+}}@getter()
; CHECK-NEXT:    ret i8** @G
;
  ret i8** @G
}

; Returning global pointer. Should not be noalias.
define i8** @calle1(){
; CHECK-LABEL: define {{[^@]+}}@calle1()
; CHECK-NEXT:    ret i8** @G
;
  %1 = call i8** @getter()
  ret i8** %1
}

; TEST 6
declare noalias i8* @strdup(i8* nocapture) nounwind

define i8* @test6() nounwind uwtable ssp {
; CHECK-LABEL: define {{[^@]+}}@test6()
; CHECK-NEXT:    [[X:%.*]] = alloca [2 x i8], align 1
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [2 x i8], [2 x i8]* [[X]], i64 0, i64 0
; CHECK-NEXT:    store i8 97, i8* [[ARRAYIDX]], align 1
; CHECK-NEXT:    [[ARRAYIDX1:%.*]] = getelementptr inbounds [2 x i8], [2 x i8]* [[X]], i64 0, i64 1
; CHECK-NEXT:    store i8 0, i8* [[ARRAYIDX1]], align 1
; CHECK-NEXT:    [[CALL:%.*]] = call noalias i8* @strdup(i8* nonnull dereferenceable(2) [[ARRAYIDX]])
; CHECK-NEXT:    ret i8* [[CALL]]
;
  %x = alloca [2 x i8], align 1
  %arrayidx = getelementptr inbounds [2 x i8], [2 x i8]* %x, i64 0, i64 0
  store i8 97, i8* %arrayidx, align 1
  %arrayidx1 = getelementptr inbounds [2 x i8], [2 x i8]* %x, i64 0, i64 1
  store i8 0, i8* %arrayidx1, align 1
  %call = call noalias i8* @strdup(i8* %arrayidx) nounwind
  ret i8* %call
}

; TEST 7

define i8* @test7() nounwind {
; CHECK-LABEL: define {{[^@]+}}@test7()
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = call noalias i8* @malloc(i64 4)
; CHECK-NEXT:    [[TOBOOL:%.*]] = icmp eq i8* [[A]], null
; CHECK-NEXT:    br i1 [[TOBOOL]], label [[RETURN:%.*]], label [[IF_END:%.*]]
; CHECK:       if.end:
; CHECK-NEXT:    store i8 7, i8* [[A]]
; CHECK-NEXT:    br label [[RETURN]]
; CHECK:       return:
; CHECK-NEXT:    [[RETVAL_0:%.*]] = phi i8* [ [[A]], [[IF_END]] ], [ null, [[ENTRY:%.*]] ]
; CHECK-NEXT:    ret i8* [[RETVAL_0]]
;
entry:
  %A = call noalias i8* @malloc(i64 4) nounwind
  %tobool = icmp eq i8* %A, null
  br i1 %tobool, label %return, label %if.end

if.end:
  store i8 7, i8* %A
  br label %return

return:
  %retval.0 = phi i8* [ %A, %if.end ], [ null, %entry ]
  ret i8* %retval.0
}

; TEST 8

define i8* @test8(i32* %0) nounwind uwtable {
; CHECK-LABEL: define {{[^@]+}}@test8
; CHECK-SAME: (i32* [[TMP0:%.*]])
; CHECK-NEXT:    [[TMP2:%.*]] = tail call noalias i8* @malloc(i64 4)
; CHECK-NEXT:    [[TMP3:%.*]] = icmp ne i32* [[TMP0]], null
; CHECK-NEXT:    br i1 [[TMP3]], label [[TMP4:%.*]], label [[TMP5:%.*]]
; CHECK:       4:
; CHECK-NEXT:    store i8 10, i8* [[TMP2]]
; CHECK-NEXT:    br label [[TMP5]]
; CHECK:       5:
; CHECK-NEXT:    ret i8* [[TMP2]]
;
  %2 = tail call noalias i8* @malloc(i64 4)
  %3 = icmp ne i32* %0, null
  br i1 %3, label %4, label %5

4:                                                ; preds = %1
  store i8 10, i8* %2
  br label %5

5:                                                ; preds = %1, %4
  ret i8* %2
}

; TEST 9
; Simple Argument Test
declare void @use_i8(i8* nocapture)
define internal void @test9a(i8* %a, i8* %b) {
; CHECK-LABEL: define {{[^@]+}}@test9a()
; CHECK-NEXT:    call void @use_i8(i8* noalias align 536870912 null)
; CHECK-NEXT:    ret void
;
  call void @use_i8(i8* null)
  ret void
}
define internal void @test9b(i8* %a, i8* %b) {
; FIXME: %b should be noalias
; CHECK-LABEL: define {{[^@]+}}@test9b
; CHECK-SAME: (i8* noalias nocapture [[A:%.*]], i8* nocapture [[B:%.*]])
; CHECK-NEXT:    call void @use_i8(i8* noalias nocapture [[A]])
; CHECK-NEXT:    call void @use_i8(i8* nocapture [[B]])
; CHECK-NEXT:    ret void
;
  call void @use_i8(i8* %a)
  call void @use_i8(i8* %b)
  ret void
}
define internal void @test9c(i8* %a, i8* %b, i8* %c) {
; CHECK-LABEL: define {{[^@]+}}@test9c
; CHECK-SAME: (i8* noalias nocapture [[A:%.*]], i8* nocapture [[B:%.*]], i8* nocapture [[C:%.*]])
; CHECK-NEXT:    call void @use_i8(i8* noalias nocapture [[A]])
; CHECK-NEXT:    call void @use_i8(i8* nocapture [[B]])
; CHECK-NEXT:    call void @use_i8(i8* nocapture [[C]])
; CHECK-NEXT:    ret void
;
  call void @use_i8(i8* %a)
  call void @use_i8(i8* %b)
  call void @use_i8(i8* %c)
  ret void
}
define void @test9_helper(i8* %a, i8* %b) {
; IS__TUNIT____-LABEL: define {{[^@]+}}@test9_helper
; IS__TUNIT____-SAME: (i8* nocapture [[A:%.*]], i8* nocapture [[B:%.*]])
; IS__TUNIT____-NEXT:    tail call void @test9a()
; IS__TUNIT____-NEXT:    tail call void @test9a()
; IS__TUNIT____-NEXT:    tail call void @test9b(i8* noalias nocapture [[A]], i8* nocapture [[B]])
; IS__TUNIT____-NEXT:    tail call void @test9b(i8* noalias nocapture [[B]], i8* noalias nocapture [[A]])
; IS__TUNIT____-NEXT:    tail call void @test9c(i8* noalias nocapture [[A]], i8* nocapture [[B]], i8* nocapture [[B]])
; IS__TUNIT____-NEXT:    tail call void @test9c(i8* noalias nocapture [[B]], i8* noalias nocapture [[A]], i8* noalias nocapture [[A]])
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____-LABEL: define {{[^@]+}}@test9_helper
; IS__CGSCC____-SAME: (i8* nocapture [[A:%.*]], i8* nocapture [[B:%.*]])
; IS__CGSCC____-NEXT:    tail call void @test9a()
; IS__CGSCC____-NEXT:    tail call void @test9a()
; IS__CGSCC____-NEXT:    tail call void @test9b(i8* noalias [[A]], i8* [[B]])
; IS__CGSCC____-NEXT:    tail call void @test9b(i8* noalias [[B]], i8* noalias [[A]])
; IS__CGSCC____-NEXT:    tail call void @test9c(i8* noalias [[A]], i8* [[B]], i8* [[B]])
; IS__CGSCC____-NEXT:    tail call void @test9c(i8* noalias nocapture [[B]], i8* noalias [[A]], i8* noalias nocapture [[A]])
; IS__CGSCC____-NEXT:    ret void
;
  tail call void @test9a(i8* noalias %a, i8* %b)
  tail call void @test9a(i8* noalias %b, i8* noalias %a)
  tail call void @test9b(i8* noalias %a, i8* %b)
  tail call void @test9b(i8* noalias %b, i8* noalias %a)
  tail call void @test9c(i8* noalias %a, i8* %b, i8* %b)
  tail call void @test9c(i8* noalias %b, i8* noalias %a, i8* noalias %a)
  ret void
}


; TEST 10
; Simple CallSite Test

declare void @test10_helper_1(i8* %a)
define void @test10_helper_2(i8* noalias %a) {
; CHECK-LABEL: define {{[^@]+}}@test10_helper_2
; CHECK-SAME: (i8* noalias [[A:%.*]])
; CHECK-NEXT:    tail call void @test10_helper_1(i8* [[A]])
; CHECK-NEXT:    ret void
;
  tail call void @test10_helper_1(i8* %a)
  ret void
}
define void @test10(i8* noalias %a) {
; CHECK-LABEL: define {{[^@]+}}@test10
; CHECK-SAME: (i8* noalias [[A:%.*]])
; CHECK-NEXT:    tail call void @test10_helper_1(i8* [[A]])
; CHECK-NEXT:    tail call void @test10_helper_2(i8* noalias [[A]])
; CHECK-NEXT:    ret void
;
; FIXME: missing noalias
  tail call void @test10_helper_1(i8* %a)

  tail call void @test10_helper_2(i8* %a)
  ret void
}

; TEST 11
; CallSite Test

declare void @test11_helper(i8* %a, i8 *%b)
define void @test11(i8* noalias %a) {
; CHECK-LABEL: define {{[^@]+}}@test11
; CHECK-SAME: (i8* noalias [[A:%.*]])
; CHECK-NEXT:    tail call void @test11_helper(i8* [[A]], i8* [[A]])
; CHECK-NEXT:    ret void
;
  tail call void @test11_helper(i8* %a, i8* %a)
  ret void
}


; TEST 12
; CallSite Argument
declare void @use_nocapture(i8* nocapture)
declare void @use(i8*)
define void @test12_1() {
; IS________OPM-LABEL: define {{[^@]+}}@test12_1()
; IS________OPM-NEXT:    [[A:%.*]] = alloca i8, align 4
; IS________OPM-NEXT:    [[B:%.*]] = tail call noalias i8* @malloc(i64 4)
; IS________OPM-NEXT:    tail call void @use_nocapture(i8* noalias nonnull align 4 dereferenceable(1) [[A]])
; IS________OPM-NEXT:    tail call void @use_nocapture(i8* noalias nonnull align 4 dereferenceable(1) [[A]])
; IS________OPM-NEXT:    tail call void @use_nocapture(i8* noalias [[B]])
; IS________OPM-NEXT:    tail call void @use_nocapture(i8* noalias [[B]])
; IS________OPM-NEXT:    ret void
;
; IS________NPM-LABEL: define {{[^@]+}}@test12_1()
; IS________NPM-NEXT:    [[A:%.*]] = alloca i8, align 4
; IS________NPM-NEXT:    [[B:%.*]] = tail call noalias i8* @malloc(i64 4)
; IS________NPM-NEXT:    tail call void @use_nocapture(i8* noalias nonnull align 4 dereferenceable(1) [[A]])
; IS________NPM-NEXT:    tail call void @use_nocapture(i8* noalias nonnull align 4 dereferenceable(1) [[A]])
; IS________NPM-NEXT:    tail call void @use_nocapture(i8* noalias nocapture [[B]])
; IS________NPM-NEXT:    tail call void @use_nocapture(i8* noalias nocapture [[B]])
; IS________NPM-NEXT:    ret void
;
  %A = alloca i8, align 4
  %B = tail call noalias i8* @malloc(i64 4)
  tail call void @use_nocapture(i8* %A)
  tail call void @use_nocapture(i8* %A)
  tail call void @use_nocapture(i8* %B)
  tail call void @use_nocapture(i8* %B)
  ret void
}

define void @test12_2(){
; IS________OPM-LABEL: define {{[^@]+}}@test12_2()
; IS________OPM-NEXT:    [[A:%.*]] = tail call noalias i8* @malloc(i64 4)
; IS________OPM-NEXT:    tail call void @use_nocapture(i8* noalias nocapture [[A]])
; IS________OPM-NEXT:    tail call void @use_nocapture(i8* noalias nocapture [[A]])
; IS________OPM-NEXT:    tail call void @use(i8* [[A]])
; IS________OPM-NEXT:    tail call void @use_nocapture(i8* [[A]])
; IS________OPM-NEXT:    ret void
;
; IS________NPM-LABEL: define {{[^@]+}}@test12_2()
; IS________NPM-NEXT:    [[A:%.*]] = tail call noalias i8* @malloc(i64 4)
; IS________NPM-NEXT:    tail call void @use_nocapture(i8* noalias nocapture [[A]])
; IS________NPM-NEXT:    tail call void @use_nocapture(i8* noalias nocapture [[A]])
; IS________NPM-NEXT:    tail call void @use(i8* [[A]])
; IS________NPM-NEXT:    tail call void @use_nocapture(i8* nocapture [[A]])
; IS________NPM-NEXT:    ret void
;
; FIXME: This should be @use_nocapture(i8* noalias [[A]])
; FIXME: This should be @use_nocapture(i8* noalias nocapture [[A]])
  %A = tail call noalias i8* @malloc(i64 4)
  tail call void @use_nocapture(i8* %A)
  tail call void @use_nocapture(i8* %A)
  tail call void @use(i8* %A)
  tail call void @use_nocapture(i8* %A)
  ret void
}

declare void @two_args(i8* nocapture , i8* nocapture)
define void @test12_3(){
; IS________OPM-LABEL: define {{[^@]+}}@test12_3()
; IS________OPM-NEXT:    [[A:%.*]] = tail call noalias i8* @malloc(i64 4)
; IS________OPM-NEXT:    tail call void @two_args(i8* [[A]], i8* [[A]])
; IS________OPM-NEXT:    ret void
;
; IS________NPM-LABEL: define {{[^@]+}}@test12_3()
; IS________NPM-NEXT:    [[A:%.*]] = tail call noalias i8* @malloc(i64 4)
; IS________NPM-NEXT:    tail call void @two_args(i8* nocapture [[A]], i8* nocapture [[A]])
; IS________NPM-NEXT:    ret void
;
  %A = tail call noalias i8* @malloc(i64 4)
  tail call void @two_args(i8* %A, i8* %A)
  ret void
}

define void @test12_4(){
; IS________OPM-LABEL: define {{[^@]+}}@test12_4()
; IS________OPM-NEXT:    [[A:%.*]] = tail call noalias i8* @malloc(i64 4)
; IS________OPM-NEXT:    [[B:%.*]] = tail call noalias i8* @malloc(i64 4)
; IS________OPM-NEXT:    [[A_0:%.*]] = getelementptr i8, i8* [[A]], i64 0
; IS________OPM-NEXT:    [[A_1:%.*]] = getelementptr i8, i8* [[A]], i64 1
; IS________OPM-NEXT:    [[B_0:%.*]] = getelementptr i8, i8* [[B]], i64 0
; IS________OPM-NEXT:    tail call void @two_args(i8* [[A]], i8* [[B]])
; IS________OPM-NEXT:    tail call void @two_args(i8* [[A]], i8* [[A_0]])
; IS________OPM-NEXT:    tail call void @two_args(i8* [[A]], i8* [[A_1]])
; IS________OPM-NEXT:    tail call void @two_args(i8* [[A_0]], i8* [[B_0]])
; IS________OPM-NEXT:    ret void
;
; IS________NPM-LABEL: define {{[^@]+}}@test12_4()
; IS________NPM-NEXT:    [[A:%.*]] = tail call noalias i8* @malloc(i64 4)
; IS________NPM-NEXT:    [[B:%.*]] = tail call noalias i8* @malloc(i64 4)
; IS________NPM-NEXT:    [[A_0:%.*]] = getelementptr i8, i8* [[A]], i64 0
; IS________NPM-NEXT:    [[A_1:%.*]] = getelementptr i8, i8* [[A]], i64 1
; IS________NPM-NEXT:    [[B_0:%.*]] = getelementptr i8, i8* [[B]], i64 0
; IS________NPM-NEXT:    tail call void @two_args(i8* noalias nocapture [[A]], i8* noalias nocapture [[B]])
; IS________NPM-NEXT:    tail call void @two_args(i8* nocapture [[A]], i8* nocapture [[A_0]])
; IS________NPM-NEXT:    tail call void @two_args(i8* nocapture [[A]], i8* nocapture [[A_1]])
; IS________NPM-NEXT:    tail call void @two_args(i8* nocapture [[A_0]], i8* nocapture [[B_0]])
; IS________NPM-NEXT:    ret void
;
  %A = tail call noalias i8* @malloc(i64 4)
  %B = tail call noalias i8* @malloc(i64 4)
  %A_0 = getelementptr i8, i8* %A, i64 0
  %A_1 = getelementptr i8, i8* %A, i64 1
  %B_0 = getelementptr i8, i8* %B, i64 0

  tail call void @two_args(i8* %A, i8* %B)

  tail call void @two_args(i8* %A, i8* %A_0)

  tail call void @two_args(i8* %A, i8* %A_1)

; FIXME: This should be @two_args(i8* noalias nocapture %A_0, i8* noalias nocapture %B_0)
  tail call void @two_args(i8* %A_0, i8* %B_0)
  ret void
}

; TEST 13
define void @use_i8_internal(i8* %a) {
; CHECK-LABEL: define {{[^@]+}}@use_i8_internal
; CHECK-SAME: (i8* nocapture [[A:%.*]])
; CHECK-NEXT:    call void @use_i8(i8* nocapture [[A]])
; CHECK-NEXT:    ret void
;
  call void @use_i8(i8* %a)
  ret void
}

define void @test13_use_noalias(){
; NOT_CGSCC_OPM-LABEL: define {{[^@]+}}@test13_use_noalias()
; NOT_CGSCC_OPM-NEXT:    [[M1:%.*]] = tail call noalias i8* @malloc(i64 4)
; NOT_CGSCC_OPM-NEXT:    [[C1:%.*]] = bitcast i8* [[M1]] to i16*
; NOT_CGSCC_OPM-NEXT:    [[C2:%.*]] = bitcast i16* [[C1]] to i8*
; NOT_CGSCC_OPM-NEXT:    call void @use_i8_internal(i8* noalias nocapture [[C2]])
; NOT_CGSCC_OPM-NEXT:    ret void
;
; IS__CGSCC_OPM-LABEL: define {{[^@]+}}@test13_use_noalias()
; IS__CGSCC_OPM-NEXT:    [[M1:%.*]] = tail call noalias i8* @malloc(i64 4)
; IS__CGSCC_OPM-NEXT:    [[C1:%.*]] = bitcast i8* [[M1]] to i16*
; IS__CGSCC_OPM-NEXT:    [[C2:%.*]] = bitcast i16* [[C1]] to i8*
; IS__CGSCC_OPM-NEXT:    call void @use_i8_internal(i8* noalias [[C2]])
; IS__CGSCC_OPM-NEXT:    ret void
;
  %m1 = tail call noalias i8* @malloc(i64 4)
  %c1 = bitcast i8* %m1 to i16*
  %c2 = bitcast i16* %c1 to i8*
  call void @use_i8_internal(i8* %c2)
  ret void
}

define void @test13_use_alias(){
; IS________OPM-LABEL: define {{[^@]+}}@test13_use_alias()
; IS________OPM-NEXT:    [[M1:%.*]] = tail call noalias i8* @malloc(i64 4)
; IS________OPM-NEXT:    [[C1:%.*]] = bitcast i8* [[M1]] to i16*
; IS________OPM-NEXT:    [[C2A:%.*]] = bitcast i16* [[C1]] to i8*
; IS________OPM-NEXT:    [[C2B:%.*]] = bitcast i16* [[C1]] to i8*
; IS________OPM-NEXT:    call void @use_i8_internal(i8* [[C2A]])
; IS________OPM-NEXT:    call void @use_i8_internal(i8* [[C2B]])
; IS________OPM-NEXT:    ret void
;
; IS________NPM-LABEL: define {{[^@]+}}@test13_use_alias()
; IS________NPM-NEXT:    [[M1:%.*]] = tail call noalias i8* @malloc(i64 4)
; IS________NPM-NEXT:    [[C1:%.*]] = bitcast i8* [[M1]] to i16*
; IS________NPM-NEXT:    [[C2A:%.*]] = bitcast i16* [[C1]] to i8*
; IS________NPM-NEXT:    [[C2B:%.*]] = bitcast i16* [[C1]] to i8*
; IS________NPM-NEXT:    call void @use_i8_internal(i8* nocapture [[C2A]])
; IS________NPM-NEXT:    call void @use_i8_internal(i8* nocapture [[C2B]])
; IS________NPM-NEXT:    ret void
;
  %m1 = tail call noalias i8* @malloc(i64 4)
  %c1 = bitcast i8* %m1 to i16*
  %c2a = bitcast i16* %c1 to i8*
  %c2b = bitcast i16* %c1 to i8*
  call void @use_i8_internal(i8* %c2a)
  call void @use_i8_internal(i8* %c2b)
  ret void
}

; TEST 14 i2p casts
define internal i32 @p2i(i32* %arg) {
; IS__TUNIT____-LABEL: define {{[^@]+}}@p2i
; IS__TUNIT____-SAME: (i32* noalias nofree readnone [[ARG:%.*]])
; IS__TUNIT____-NEXT:    [[P2I:%.*]] = ptrtoint i32* [[ARG]] to i32
; IS__TUNIT____-NEXT:    ret i32 [[P2I]]
;
; IS__CGSCC____-LABEL: define {{[^@]+}}@p2i
; IS__CGSCC____-SAME: (i32* nofree readnone [[ARG:%.*]])
; IS__CGSCC____-NEXT:    [[P2I:%.*]] = ptrtoint i32* [[ARG]] to i32
; IS__CGSCC____-NEXT:    ret i32 [[P2I]]
;
  %p2i = ptrtoint i32* %arg to i32
  ret i32 %p2i
}

define i32 @i2p(i32* %arg) {
; IS__TUNIT____-LABEL: define {{[^@]+}}@i2p
; IS__TUNIT____-SAME: (i32* nofree readonly [[ARG:%.*]])
; IS__TUNIT____-NEXT:    [[C:%.*]] = call i32 @p2i(i32* noalias nofree readnone [[ARG]])
; IS__TUNIT____-NEXT:    [[I2P:%.*]] = inttoptr i32 [[C]] to i8*
; IS__TUNIT____-NEXT:    [[BC:%.*]] = bitcast i8* [[I2P]] to i32*
; IS__TUNIT____-NEXT:    [[CALL:%.*]] = call i32 @ret(i32* nofree readonly align 4 [[BC]])
; IS__TUNIT____-NEXT:    ret i32 [[CALL]]
;
; IS__CGSCC____-LABEL: define {{[^@]+}}@i2p
; IS__CGSCC____-SAME: (i32* nofree readonly [[ARG:%.*]])
; IS__CGSCC____-NEXT:    [[C:%.*]] = call i32 @p2i(i32* noalias nofree readnone [[ARG]])
; IS__CGSCC____-NEXT:    [[I2P:%.*]] = inttoptr i32 [[C]] to i8*
; IS__CGSCC____-NEXT:    [[BC:%.*]] = bitcast i8* [[I2P]] to i32*
; IS__CGSCC____-NEXT:    [[CALL:%.*]] = call i32 @ret(i32* nofree nonnull readonly align 4 dereferenceable(4) [[BC]])
; IS__CGSCC____-NEXT:    ret i32 [[CALL]]
;
  %c = call i32 @p2i(i32* %arg)
  %i2p = inttoptr i32 %c to i8*
  %bc = bitcast i8* %i2p to i32*
  %call = call i32 @ret(i32* %bc)
  ret i32 %call
}
define internal i32 @ret(i32* %arg) {
; CHECK-LABEL: define {{[^@]+}}@ret
; CHECK-SAME: (i32* nocapture nofree nonnull readonly align 4 dereferenceable(4) [[ARG:%.*]])
; CHECK-NEXT:    [[L:%.*]] = load i32, i32* [[ARG]], align 4
; CHECK-NEXT:    ret i32 [[L]]
;
  %l = load i32, i32* %arg
  ret i32 %l
}

; Test to propagate noalias where value is assumed to be no-capture in all the
; uses possibly executed before this callsite.
; IR referred from musl/src/strtod.c file

%struct._IO_FILE = type { i32, i8*, i8*, i32 (%struct._IO_FILE*)*, i8*, i8*, i8*, i8*, i32 (%struct._IO_FILE*, i8*, i32)*, i32 (%struct._IO_FILE*, i8*, i32)*, i64 (%struct._IO_FILE*, i64, i32)*, i8*, i32, %struct._IO_FILE*, %struct._IO_FILE*, i32, i32, i32, i16, i8, i8, i32, i32, i8*, i64, i8*, i8*, i8*, [4 x i8], i64, i64, %struct._IO_FILE*, %struct._IO_FILE*, %struct.__locale_struct*, [4 x i8] }
%struct.__locale_struct = type { [6 x %struct.__locale_map*] }
%struct.__locale_map = type opaque

; Function Attrs: nounwind optsize
define internal fastcc double @strtox(i8* %s, i8** %p, i32 %prec) unnamed_addr {
; IS__TUNIT____-LABEL: define {{[^@]+}}@strtox
; IS__TUNIT____-SAME: (i8* noalias [[S:%.*]]) unnamed_addr
; IS__TUNIT____-NEXT:  entry:
; IS__TUNIT____-NEXT:    [[F:%.*]] = alloca [[STRUCT__IO_FILE:%.*]], align 8
; IS__TUNIT____-NEXT:    [[TMP0:%.*]] = bitcast %struct._IO_FILE* [[F]] to i8*
; IS__TUNIT____-NEXT:    call void @llvm.lifetime.start.p0i8(i64 144, i8* nonnull align 8 dereferenceable(240) [[TMP0]])
; IS__TUNIT____-NEXT:    [[CALL:%.*]] = call i32 bitcast (i32 (...)* @sh_fromstring to i32 (%struct._IO_FILE*, i8*)*)(%struct._IO_FILE* nonnull align 8 dereferenceable(240) [[F]], i8* [[S]])
; IS__TUNIT____-NEXT:    call void @__shlim(%struct._IO_FILE* nonnull align 8 dereferenceable(240) [[F]], i64 0)
; IS__TUNIT____-NEXT:    [[CALL1:%.*]] = call double @__floatscan(%struct._IO_FILE* nonnull align 8 dereferenceable(240) [[F]], i32 1, i32 1)
; IS__TUNIT____-NEXT:    call void @llvm.lifetime.end.p0i8(i64 144, i8* nonnull align 8 dereferenceable(240) [[TMP0]])
; IS__TUNIT____-NEXT:    ret double [[CALL1]]
;
; IS__CGSCC____-LABEL: define {{[^@]+}}@strtox
; IS__CGSCC____-SAME: (i8* [[S:%.*]]) unnamed_addr
; IS__CGSCC____-NEXT:  entry:
; IS__CGSCC____-NEXT:    [[F:%.*]] = alloca [[STRUCT__IO_FILE:%.*]], align 8
; IS__CGSCC____-NEXT:    [[TMP0:%.*]] = bitcast %struct._IO_FILE* [[F]] to i8*
; IS__CGSCC____-NEXT:    call void @llvm.lifetime.start.p0i8(i64 144, i8* nonnull align 8 dereferenceable(240) [[TMP0]])
; IS__CGSCC____-NEXT:    [[CALL:%.*]] = call i32 bitcast (i32 (...)* @sh_fromstring to i32 (%struct._IO_FILE*, i8*)*)(%struct._IO_FILE* nonnull align 8 dereferenceable(240) [[F]], i8* [[S]])
; IS__CGSCC____-NEXT:    call void @__shlim(%struct._IO_FILE* nonnull align 8 dereferenceable(240) [[F]], i64 0)
; IS__CGSCC____-NEXT:    [[CALL1:%.*]] = call double @__floatscan(%struct._IO_FILE* nonnull align 8 dereferenceable(240) [[F]], i32 1, i32 1)
; IS__CGSCC____-NEXT:    call void @llvm.lifetime.end.p0i8(i64 144, i8* nonnull align 8 dereferenceable(240) [[TMP0]])
; IS__CGSCC____-NEXT:    ret double [[CALL1]]
;
entry:
  %f = alloca %struct._IO_FILE, align 8
  %0 = bitcast %struct._IO_FILE* %f to i8*
  call void @llvm.lifetime.start.p0i8(i64 144, i8* nonnull %0)
  %call = call i32 bitcast (i32 (...)* @sh_fromstring to i32 (%struct._IO_FILE*, i8*)*)(%struct._IO_FILE* nonnull %f, i8* %s)
  call void @__shlim(%struct._IO_FILE* nonnull %f, i64 0)
  %call1 = call double @__floatscan(%struct._IO_FILE* nonnull %f, i32 %prec, i32 1)
  call void @llvm.lifetime.end.p0i8(i64 144, i8* nonnull %0)

  ret double %call1
}

; Function Attrs: nounwind optsize
define dso_local double @strtod(i8* noalias %s, i8** noalias %p) {
; CHECK-LABEL: define {{[^@]+}}@strtod
; CHECK-SAME: (i8* noalias [[S:%.*]], i8** noalias nocapture nofree readnone [[P:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CALL:%.*]] = tail call fastcc double @strtox(i8* noalias [[S]])
; CHECK-NEXT:    ret double [[CALL]]
;
entry:
  %call = tail call fastcc double @strtox(i8* %s, i8** %p, i32 1)
  ret double %call
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture)

; Function Attrs: optsize
declare dso_local i32 @sh_fromstring(...) local_unnamed_addr

; Function Attrs: optsize
declare dso_local void @__shlim(%struct._IO_FILE*, i64) local_unnamed_addr

; Function Attrs: optsize
declare dso_local double @__floatscan(%struct._IO_FILE*, i32, i32) local_unnamed_addr

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture)

; Test 15
; propagate noalias to some callsite arguments that there is no possibly reachable capture before it

@alias_of_p = external global i32*

define void @make_alias(i32* %p) {
; CHECK-LABEL: define {{[^@]+}}@make_alias
; CHECK-SAME: (i32* nofree writeonly [[P:%.*]])
; CHECK-NEXT:    store i32* [[P]], i32** @alias_of_p, align 8
; CHECK-NEXT:    ret void
;
  store i32* %p, i32** @alias_of_p
  ret void
}

define void @only_store(i32* %p) {
; CHECK-LABEL: define {{[^@]+}}@only_store
; CHECK-SAME: (i32* nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[P:%.*]])
; CHECK-NEXT:    store i32 0, i32* [[P]], align 4
; CHECK-NEXT:    ret void
;
  store i32 0, i32* %p
  ret void
}

; CHECK-LABEL define void @test15_caller(i32* noalias %p, i32 %c)
define void @test15_caller(i32* noalias %p, i32 %c) {
; IS__TUNIT____-LABEL: define {{[^@]+}}@test15_caller
; IS__TUNIT____-SAME: (i32* noalias nofree writeonly [[P:%.*]], i32 [[C:%.*]])
; IS__TUNIT____-NEXT:    [[TOBOOL:%.*]] = icmp eq i32 [[C]], 0
; IS__TUNIT____-NEXT:    br i1 [[TOBOOL]], label [[IF_END:%.*]], label [[IF_THEN:%.*]]
; IS__TUNIT____:       if.then:
; IS__TUNIT____-NEXT:    tail call void @only_store(i32* noalias nocapture nofree writeonly align 4 [[P]])
; IS__TUNIT____-NEXT:    br label [[IF_END]]
; IS__TUNIT____:       if.end:
; IS__TUNIT____-NEXT:    tail call void @make_alias(i32* nofree writeonly [[P]])
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____-LABEL: define {{[^@]+}}@test15_caller
; IS__CGSCC____-SAME: (i32* noalias nofree writeonly [[P:%.*]], i32 [[C:%.*]])
; IS__CGSCC____-NEXT:    [[TOBOOL:%.*]] = icmp eq i32 [[C]], 0
; IS__CGSCC____-NEXT:    br i1 [[TOBOOL]], label [[IF_END:%.*]], label [[IF_THEN:%.*]]
; IS__CGSCC____:       if.then:
; IS__CGSCC____-NEXT:    tail call void @only_store(i32* noalias nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[P]])
; IS__CGSCC____-NEXT:    br label [[IF_END]]
; IS__CGSCC____:       if.end:
; IS__CGSCC____-NEXT:    tail call void @make_alias(i32* nofree writeonly [[P]])
; IS__CGSCC____-NEXT:    ret void
;
  %tobool = icmp eq i32 %c, 0
  br i1 %tobool, label %if.end, label %if.then

; CHECK tail call void @only_store(i32* noalias %p)
; CHECK tail call void @make_alias(i32* %p)

if.then:
  tail call void @only_store(i32* %p)
  br label %if.end

if.end:
  tail call void @make_alias(i32* %p)
  ret void
}

; Test 16
;
; __attribute__((noinline)) static void test16_sub(int * restrict p, int c1, int c2) {
;   if (c1) {
;     only_store(p);
;     make_alias(p);
;   }
;   if (!c2) {
;     only_store(p);
;   }
; }
; void test16_caller(int * restrict p, int c) {
;   test16_sub(p, c, c);
; }

; CHECK-LABEL define internal void @test16_sub(i32* noalias %p, i32 %c1, i32 %c2)
define internal void @test16_sub(i32* noalias %p, i32 %c1, i32 %c2) {
; IS__TUNIT____-LABEL: define {{[^@]+}}@test16_sub
; IS__TUNIT____-SAME: (i32* noalias nofree writeonly [[P:%.*]], i32 [[C1:%.*]], i32 [[C2:%.*]])
; IS__TUNIT____-NEXT:    [[TOBOOL:%.*]] = icmp eq i32 [[C1]], 0
; IS__TUNIT____-NEXT:    br i1 [[TOBOOL]], label [[IF_END:%.*]], label [[IF_THEN:%.*]]
; IS__TUNIT____:       if.then:
; IS__TUNIT____-NEXT:    tail call void @only_store(i32* noalias nocapture nofree writeonly align 4 [[P]])
; IS__TUNIT____-NEXT:    tail call void @make_alias(i32* nofree writeonly align 4 [[P]])
; IS__TUNIT____-NEXT:    br label [[IF_END]]
; IS__TUNIT____:       if.end:
; IS__TUNIT____-NEXT:    [[TOBOOL1:%.*]] = icmp eq i32 [[C2]], 0
; IS__TUNIT____-NEXT:    br i1 [[TOBOOL1]], label [[IF_THEN2:%.*]], label [[IF_END3:%.*]]
; IS__TUNIT____:       if.then2:
; IS__TUNIT____-NEXT:    tail call void @only_store(i32* nofree writeonly align 4 [[P]])
; IS__TUNIT____-NEXT:    br label [[IF_END3]]
; IS__TUNIT____:       if.end3:
; IS__TUNIT____-NEXT:    ret void
;
; IS__CGSCC____-LABEL: define {{[^@]+}}@test16_sub
; IS__CGSCC____-SAME: (i32* noalias nofree writeonly [[P:%.*]], i32 [[C1:%.*]], i32 [[C2:%.*]])
; IS__CGSCC____-NEXT:    [[TOBOOL:%.*]] = icmp eq i32 [[C1]], 0
; IS__CGSCC____-NEXT:    br i1 [[TOBOOL]], label [[IF_END:%.*]], label [[IF_THEN:%.*]]
; IS__CGSCC____:       if.then:
; IS__CGSCC____-NEXT:    tail call void @only_store(i32* noalias nocapture nofree nonnull writeonly align 4 dereferenceable(4) [[P]])
; IS__CGSCC____-NEXT:    tail call void @make_alias(i32* nofree nonnull writeonly align 4 dereferenceable(4) [[P]])
; IS__CGSCC____-NEXT:    br label [[IF_END]]
; IS__CGSCC____:       if.end:
; IS__CGSCC____-NEXT:    [[TOBOOL1:%.*]] = icmp eq i32 [[C2]], 0
; IS__CGSCC____-NEXT:    br i1 [[TOBOOL1]], label [[IF_THEN2:%.*]], label [[IF_END3:%.*]]
; IS__CGSCC____:       if.then2:
; IS__CGSCC____-NEXT:    tail call void @only_store(i32* nofree nonnull writeonly align 4 dereferenceable(4) [[P]])
; IS__CGSCC____-NEXT:    br label [[IF_END3]]
; IS__CGSCC____:       if.end3:
; IS__CGSCC____-NEXT:    ret void
;
  %tobool = icmp eq i32 %c1, 0
  br i1 %tobool, label %if.end, label %if.then

; CHECK tail call void @only_store(i32* noalias %p)
if.then:
  tail call void @only_store(i32* %p)
  tail call void @make_alias(i32* %p)
  br label %if.end
if.end:

  %tobool1 = icmp eq i32 %c2, 0
  br i1 %tobool1, label %if.then2, label %if.end3

; FIXME: this should be tail @only_store(i32* noalias %p)
;        when test16_caller is called, c1 always equals to c2. (Note that linkage is internal)
;        Therefore, only one of the two conditions of if statementes will be fulfilled.
; CHECK tail call void @only_store(i32* %p)
if.then2:
  tail call void @only_store(i32* %p)
  br label %if.end3
if.end3:

  ret void
}

define void @test16_caller(i32* %p, i32 %c) {
; CHECK-LABEL: define {{[^@]+}}@test16_caller
; CHECK-SAME: (i32* nofree writeonly [[P:%.*]], i32 [[C:%.*]])
; CHECK-NEXT:    tail call void @test16_sub(i32* noalias nofree writeonly [[P]], i32 [[C]], i32 [[C]])
; CHECK-NEXT:    ret void
;
  tail call void @test16_sub(i32* %p, i32 %c, i32 %c)
  ret void
}
