; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -basic-aa -dse -enable-dse-memoryssa -S | FileCheck %s
; RUN: opt < %s -aa-pipeline=basic-aa -passes=dse -enable-dse-memoryssa -S | FileCheck %s
target datalayout = "E-p:64:64:64-a0:0:8-f32:32:32-f64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:32:64-v64:64:64-v128:128:128"

declare void @llvm.memset.p0i8.i64(i8* nocapture, i8, i64, i1) nounwind
declare void @llvm.memset.element.unordered.atomic.p0i8.i64(i8* nocapture, i8, i64, i32) nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture, i8* nocapture, i64, i1) nounwind
declare void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i64(i8* nocapture, i8* nocapture, i64, i32) nounwind
declare void @llvm.init.trampoline(i8*, i8*, i8*)

define void @test1(i32* %Q, i32* %P) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    store i32 0, i32* [[P:%.*]], align 4
; CHECK-NEXT:    ret void
;
  %DEAD = load i32, i32* %Q
  store i32 %DEAD, i32* %P
  store i32 0, i32* %P
  ret void
}

; PR8677
@g = global i32 1

define i32 @test3(i32* %g_addr) nounwind {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    [[G_VALUE:%.*]] = load i32, i32* [[G_ADDR:%.*]], align 4
; CHECK-NEXT:    store i32 -1, i32* @g, align 4
; CHECK-NEXT:    store i32 [[G_VALUE]], i32* [[G_ADDR]], align 4
; CHECK-NEXT:    [[TMP3:%.*]] = load i32, i32* @g, align 4
; CHECK-NEXT:    ret i32 [[TMP3]]
;
  %g_value = load i32, i32* %g_addr, align 4
  store i32 -1, i32* @g, align 4
  store i32 %g_value, i32* %g_addr, align 4
  %tmp3 = load i32, i32* @g, align 4
  ret i32 %tmp3
}


define void @test4(i32* %Q) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    [[A:%.*]] = load i32, i32* [[Q:%.*]], align 4
; CHECK-NEXT:    store volatile i32 [[A]], i32* [[Q]], align 4
; CHECK-NEXT:    ret void
;
  %a = load i32, i32* %Q
  store volatile i32 %a, i32* %Q
  ret void
}

; PR8576 - Should delete store of 10 even though p/q are may aliases.
define void @test2(i32 *%p, i32 *%q) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    store i32 20, i32* [[Q:%.*]], align 4
; CHECK-NEXT:    store i32 30, i32* [[P:%.*]], align 4
; CHECK-NEXT:    ret void
;
  store i32 10, i32* %p, align 4
  store i32 20, i32* %q, align 4
  store i32 30, i32* %p, align 4
  ret void
}

; Should delete store of 10 even though memset is a may-store to P (P and Q may
; alias).
define void @test6(i32 *%p, i8 *%q) {
; CHECK-LABEL: @test6(
; CHECK-NEXT:    call void @llvm.memset.p0i8.i64(i8* [[Q:%.*]], i8 42, i64 900, i1 false)
; CHECK-NEXT:    store i32 30, i32* [[P:%.*]], align 4
; CHECK-NEXT:    ret void
;
  store i32 10, i32* %p, align 4       ;; dead.
  call void @llvm.memset.p0i8.i64(i8* %q, i8 42, i64 900, i1 false)
  store i32 30, i32* %p, align 4
  ret void
}

; Should delete store of 10 even though memset is a may-store to P (P and Q may
; alias).
define void @test6_atomic(i32* align 4 %p, i8* align 4 %q) {
; CHECK-LABEL: @test6_atomic(
; CHECK-NEXT:    call void @llvm.memset.element.unordered.atomic.p0i8.i64(i8* align 4 [[Q:%.*]], i8 42, i64 900, i32 4)
; CHECK-NEXT:    store atomic i32 30, i32* [[P:%.*]] unordered, align 4
; CHECK-NEXT:    ret void
;
  store atomic i32 10, i32* %p unordered, align 4       ;; dead.
  call void @llvm.memset.element.unordered.atomic.p0i8.i64(i8* align 4 %q, i8 42, i64 900, i32 4)
  store atomic i32 30, i32* %p unordered, align 4
  ret void
}

; Should delete store of 10 even though memcpy is a may-store to P (P and Q may
; alias).
define void @test7(i32 *%p, i8 *%q, i8* noalias %r) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* [[Q:%.*]], i8* [[R:%.*]], i64 900, i1 false)
; CHECK-NEXT:    store i32 30, i32* [[P:%.*]], align 4
; CHECK-NEXT:    ret void
;
  store i32 10, i32* %p, align 4       ;; dead.
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %q, i8* %r, i64 900, i1 false)
  store i32 30, i32* %p, align 4
  ret void
}

; Should delete store of 10 even though memcpy is a may-store to P (P and Q may
; alias).
define void @test7_atomic(i32* align 4 %p, i8* align 4 %q, i8* noalias align 4 %r) {
; CHECK-LABEL: @test7_atomic(
; CHECK-NEXT:    call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i64(i8* align 4 [[Q:%.*]], i8* align 4 [[R:%.*]], i64 900, i32 4)
; CHECK-NEXT:    store atomic i32 30, i32* [[P:%.*]] unordered, align 4
; CHECK-NEXT:    ret void
;
  store atomic i32 10, i32* %p unordered, align 4       ;; dead.
  call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i64(i8* align 4 %q, i8* align 4 %r, i64 900, i32 4)
  store atomic i32 30, i32* %p unordered, align 4
  ret void
}

; Do not delete stores that are only partially killed.
define i32 @test8() {
; CHECK-LABEL: @test8(
; CHECK-NEXT:    [[V:%.*]] = alloca i32, align 4
; CHECK-NEXT:    store i32 1234567, i32* [[V]], align 4
; CHECK-NEXT:    [[X:%.*]] = load i32, i32* [[V]], align 4
; CHECK-NEXT:    ret i32 [[X]]
;
  %V = alloca i32
  store i32 1234567, i32* %V
  %V2 = bitcast i32* %V to i8*
  store i8 0, i8* %V2
  %X = load i32, i32* %V
  ret i32 %X

}

; Test for byval handling.
%struct.x = type { i32, i32, i32, i32 }
define void @test9(%struct.x* byval  %a) nounwind  {
; CHECK-LABEL: @test9(
; CHECK-NEXT:    ret void
;
  %tmp2 = getelementptr %struct.x, %struct.x* %a, i32 0, i32 0
  store i32 1, i32* %tmp2, align 4
  ret void
}

; Test for inalloca handling.
define void @test9_2(%struct.x* inalloca  %a) nounwind  {
; CHECK-LABEL: @test9_2(
; CHECK-NEXT:    ret void
;
  %tmp2 = getelementptr %struct.x, %struct.x* %a, i32 0, i32 0
  store i32 1, i32* %tmp2, align 4
  ret void
}

; Test for preallocated handling.
define void @test9_3(%struct.x* preallocated(%struct.x)  %a) nounwind  {
; CHECK-LABEL: @test9_3(
; CHECK-NEXT:    ret void
;
  %tmp2 = getelementptr %struct.x, %struct.x* %a, i32 0, i32 0
  store i32 1, i32* %tmp2, align 4
  ret void
}

; va_arg has fuzzy dependence, the store shouldn't be zapped.
define double @test10(i8* %X) {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    [[X_ADDR:%.*]] = alloca i8*, align 8
; CHECK-NEXT:    store i8* [[X:%.*]], i8** [[X_ADDR]], align 8
; CHECK-NEXT:    [[TMP_0:%.*]] = va_arg i8** [[X_ADDR]], double
; CHECK-NEXT:    ret double [[TMP_0]]
;
  %X_addr = alloca i8*
  store i8* %X, i8** %X_addr
  %tmp.0 = va_arg i8** %X_addr, double
  ret double %tmp.0
}

; %P doesn't escape, the DEAD instructions should be removed.
declare void @test13f()
define i32* @test13() {
; CHECK-LABEL: @test13(
; CHECK-NEXT:    [[PTR:%.*]] = tail call i8* @malloc(i32 4)
; CHECK-NEXT:    [[P:%.*]] = bitcast i8* [[PTR]] to i32*
; CHECK-NEXT:    call void @test13f()
; CHECK-NEXT:    store i32 0, i32* [[P]], align 4
; CHECK-NEXT:    ret i32* [[P]]
;
  %ptr = tail call i8* @malloc(i32 4)
  %P = bitcast i8* %ptr to i32*
  %DEAD = load i32, i32* %P
  %DEAD2 = add i32 %DEAD, 1
  store i32 %DEAD2, i32* %P
  call void @test13f( )
  store i32 0, i32* %P
  ret i32* %P
}

define i32 addrspace(1)* @test13_addrspacecast() {
; CHECK-LABEL: @test13_addrspacecast(
; CHECK-NEXT:    [[P:%.*]] = tail call i8* @malloc(i32 4)
; CHECK-NEXT:    [[P_BC:%.*]] = bitcast i8* [[P]] to i32*
; CHECK-NEXT:    [[P:%.*]] = addrspacecast i32* [[P_BC]] to i32 addrspace(1)*
; CHECK-NEXT:    call void @test13f()
; CHECK-NEXT:    store i32 0, i32 addrspace(1)* [[P]], align 4
; CHECK-NEXT:    ret i32 addrspace(1)* [[P]]
;
  %p = tail call i8* @malloc(i32 4)
  %p.bc = bitcast i8* %p to i32*
  %P = addrspacecast i32* %p.bc to i32 addrspace(1)*
  %DEAD = load i32, i32 addrspace(1)* %P
  %DEAD2 = add i32 %DEAD, 1
  store i32 %DEAD2, i32 addrspace(1)* %P
  call void @test13f( )
  store i32 0, i32 addrspace(1)* %P
  ret i32 addrspace(1)* %P
}


declare noalias i8* @malloc(i32)
declare noalias i8* @calloc(i32, i32)

define void @test14(i32* %Q) {
; CHECK-LABEL: @test14(
; CHECK-NEXT:    ret void
;
  %P = alloca i32
  %DEAD = load i32, i32* %Q
  store i32 %DEAD, i32* %P
  ret void

}

; The store here is not dead because the byval call reads it.
declare void @test19f({i32}* byval align 4 %P)

define void @test19({i32} * nocapture byval align 4 %arg5) nounwind ssp {
; CHECK-LABEL: @test19(
; CHECK-NEXT:  bb:
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr inbounds { i32 }, { i32 }* [[ARG5:%.*]], i32 0, i32 0
; CHECK-NEXT:    store i32 912, i32* [[TMP7]], align 4
; CHECK-NEXT:    call void @test19f({ i32 }* byval align 4 [[ARG5]])
; CHECK-NEXT:    ret void
;
bb:
  %tmp7 = getelementptr inbounds {i32}, {i32}* %arg5, i32 0, i32 0
  store i32 912, i32* %tmp7
  call void @test19f({i32}* byval align 4 %arg5)
  ret void

}

define void @test20() {
; CHECK-LABEL: @test20(
; CHECK-NEXT:    ret void
;
  %m = call i8* @malloc(i32 24)
  store i8 0, i8* %m
  ret void
}

define void @test21() {
; CHECK-LABEL: @test21(
; CHECK-NEXT:    ret void
;
  %m = call i8* @calloc(i32 9, i32 7)
  store i8 0, i8* %m
  ret void
}

define void @test22(i1 %i, i32 %k, i32 %m) nounwind {
; CHECK-LABEL: @test22(
; CHECK-NEXT:    ret void
;
  %k.addr = alloca i32
  %m.addr = alloca i32
  %k.addr.m.addr = select i1 %i, i32* %k.addr, i32* %m.addr
  store i32 0, i32* %k.addr.m.addr, align 4
  ret void
}

; PR13547
declare noalias i8* @strdup(i8* nocapture) nounwind
define noalias i8* @test23() nounwind uwtable ssp {
; CHECK-LABEL: @test23(
; CHECK-NEXT:    [[X:%.*]] = alloca [2 x i8], align 1
; CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds [2 x i8], [2 x i8]* [[X]], i64 0, i64 0
; CHECK-NEXT:    store i8 97, i8* [[ARRAYIDX]], align 1
; CHECK-NEXT:    [[ARRAYIDX1:%.*]] = getelementptr inbounds [2 x i8], [2 x i8]* [[X]], i64 0, i64 1
; CHECK-NEXT:    store i8 0, i8* [[ARRAYIDX1]], align 1
; CHECK-NEXT:    [[CALL:%.*]] = call i8* @strdup(i8* [[ARRAYIDX]]) #3
; CHECK-NEXT:    ret i8* [[CALL]]
;
  %x = alloca [2 x i8], align 1
  %arrayidx = getelementptr inbounds [2 x i8], [2 x i8]* %x, i64 0, i64 0
  store i8 97, i8* %arrayidx, align 1
  %arrayidx1 = getelementptr inbounds [2 x i8], [2 x i8]* %x, i64 0, i64 1
  store i8 0, i8* %arrayidx1, align 1
  %call = call i8* @strdup(i8* %arrayidx) nounwind
  ret i8* %call
}

; Make sure same sized store to later element is deleted
define void @test24([2 x i32]* %a, i32 %b, i32 %c) nounwind {
; CHECK-LABEL: @test24(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [2 x i32], [2 x i32]* [[A:%.*]], i64 0, i64 0
; CHECK-NEXT:    store i32 [[B:%.*]], i32* [[TMP1]], align 4
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr inbounds [2 x i32], [2 x i32]* [[A]], i64 0, i64 1
; CHECK-NEXT:    store i32 [[C:%.*]], i32* [[TMP2]], align 4
; CHECK-NEXT:    ret void
;
  %1 = getelementptr inbounds [2 x i32], [2 x i32]* %a, i64 0, i64 0
  store i32 0, i32* %1, align 4
  %2 = getelementptr inbounds [2 x i32], [2 x i32]* %a, i64 0, i64 1
  store i32 0, i32* %2, align 4
  %3 = getelementptr inbounds [2 x i32], [2 x i32]* %a, i64 0, i64 0
  store i32 %b, i32* %3, align 4
  %4 = getelementptr inbounds [2 x i32], [2 x i32]* %a, i64 0, i64 1
  store i32 %c, i32* %4, align 4
  ret void
}

; Check another case like PR13547 where strdup is not like malloc.
define i8* @test25(i8* %p) nounwind {
; CHECK-LABEL: @test25(
; CHECK-NEXT:    [[P_4:%.*]] = getelementptr i8, i8* [[P:%.*]], i64 4
; CHECK-NEXT:    [[TMP:%.*]] = load i8, i8* [[P_4]], align 1
; CHECK-NEXT:    store i8 0, i8* [[P_4]], align 1
; CHECK-NEXT:    [[Q:%.*]] = call i8* @strdup(i8* [[P]]) #6
; CHECK-NEXT:    store i8 [[TMP]], i8* [[P_4]], align 1
; CHECK-NEXT:    ret i8* [[Q]]
;
  %p.4 = getelementptr i8, i8* %p, i64 4
  %tmp = load i8, i8* %p.4, align 1
  store i8 0, i8* %p.4, align 1
  %q = call i8* @strdup(i8* %p) nounwind optsize
  store i8 %tmp, i8* %p.4, align 1
  ret i8* %q
}

; Don't remove redundant store because of may-aliased store.
define i32 @test28(i1 %c, i32* %p, i32* %p2, i32 %i) {
; CHECK-LABEL: @test28(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[V:%.*]] = load i32, i32* [[P:%.*]], align 4
; CHECK-NEXT:    store i32 [[I:%.*]], i32* [[P2:%.*]], align 4
; CHECK-NEXT:    br i1 [[C:%.*]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    store i32 [[V]], i32* [[P]], align 4
; CHECK-NEXT:    ret i32 0
;
entry:
  %v = load i32, i32* %p, align 4

  ; Might overwrite value at %p
  store i32 %i, i32* %p2, align 4
  br i1 %c, label %bb1, label %bb2
bb1:
  br label %bb3
bb2:
  br label %bb3
bb3:
  store i32 %v, i32* %p, align 4
  ret i32 0
}

; Don't remove redundant store because of may-aliased store.
define i32 @test29(i1 %c, i32* %p, i32* %p2, i32 %i) {
; CHECK-LABEL: @test29(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[V:%.*]] = load i32, i32* [[P:%.*]], align 4
; CHECK-NEXT:    br i1 [[C:%.*]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    store i32 [[I:%.*]], i32* [[P2:%.*]], align 4
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    store i32 [[V]], i32* [[P]], align 4
; CHECK-NEXT:    ret i32 0
;
entry:
  %v = load i32, i32* %p, align 4
  br i1 %c, label %bb1, label %bb2
bb1:
  br label %bb3
bb2:
  ; Might overwrite value at %p
  store i32 %i, i32* %p2, align 4
  br label %bb3
bb3:
  store i32 %v, i32* %p, align 4
  ret i32 0
}

declare void @unknown_func()

; Don't remove redundant store because of unknown call.
define i32 @test30(i1 %c, i32* %p, i32 %i) {
; CHECK-LABEL: @test30(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[V:%.*]] = load i32, i32* [[P:%.*]], align 4
; CHECK-NEXT:    br i1 [[C:%.*]], label [[BB1:%.*]], label [[BB2:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    br label [[BB3:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    call void @unknown_func()
; CHECK-NEXT:    br label [[BB3]]
; CHECK:       bb3:
; CHECK-NEXT:    store i32 [[V]], i32* [[P]], align 4
; CHECK-NEXT:    ret i32 0
;
entry:
  %v = load i32, i32* %p, align 4
  br i1 %c, label %bb1, label %bb2
bb1:
  br label %bb3
bb2:
  ; Might overwrite value at %p
  call void @unknown_func()
  br label %bb3
bb3:
  store i32 %v, i32* %p, align 4
  ret i32 0
}

; Don't remove redundant store in a loop with a may-alias store.
define i32 @test32(i1 %c, i32* %p, i32 %i) {
; CHECK-LABEL: @test32(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[V:%.*]] = load i32, i32* [[P:%.*]], align 4
; CHECK-NEXT:    br label [[BB1:%.*]]
; CHECK:       bb1:
; CHECK-NEXT:    store i32 [[V]], i32* [[P]], align 4
; CHECK-NEXT:    call void @unknown_func()
; CHECK-NEXT:    br i1 undef, label [[BB1]], label [[BB2:%.*]]
; CHECK:       bb2:
; CHECK-NEXT:    ret i32 0
;
entry:
  %v = load i32, i32* %p, align 4
  br label %bb1
bb1:
  store i32 %v, i32* %p, align 4
  ; Might read and overwrite value at %p
  call void @unknown_func()
  br i1 undef, label %bb1, label %bb2
bb2:
  ret i32 0
}

; TODO
; We can remove redundant store, as noalias %p guarantees that the function does
; only access it via %p. This also holds for the call to unknown_func even though
; it could unwind
define void @test34(i32* noalias %p) {
; CHECK-LABEL: @test34(
; CHECK-NEXT:    store i32 1, i32* [[P:%.*]], align 4
; CHECK-NEXT:    call void @unknown_func()
; CHECK-NEXT:    store i32 0, i32* [[P]], align 4
; CHECK-NEXT:    ret void
;
  store i32 1, i32* %p
  call void @unknown_func()
  store i32 0, i32* %p
  ret void
}

; Remove redundant store even with an unwinding function in the same block
define void @test35(i32* noalias %p) {
; CHECK-LABEL: @test35(
; CHECK-NEXT:    call void @unknown_func()
; CHECK-NEXT:    store i32 0, i32* [[P:%.*]], align 4
; CHECK-NEXT:    ret void
;
  call void @unknown_func()
  store i32 1, i32* %p
  store i32 0, i32* %p
  ret void
}

; We cannot optimize away the first memmove since %P could overlap with %Q.
define void @test36(i8* %P, i8* %Q) {
; CHECK-LABEL: @test36(
; CHECK-NEXT:    tail call void @llvm.memmove.p0i8.p0i8.i64(i8* [[P:%.*]], i8* [[Q:%.*]], i64 12, i1 false)
; CHECK-NEXT:    tail call void @llvm.memmove.p0i8.p0i8.i64(i8* [[P]], i8* [[Q]], i64 12, i1 false)
; CHECK-NEXT:    ret void
;

  tail call void @llvm.memmove.p0i8.p0i8.i64(i8* %P, i8* %Q, i64 12, i1 false)
  tail call void @llvm.memmove.p0i8.p0i8.i64(i8* %P, i8* %Q, i64 12, i1 false)
  ret void
}

define void @test36_atomic(i8* %P, i8* %Q) {
; CHECK-LABEL: @test36_atomic(
; CHECK-NEXT:    tail call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i64(i8* align 1 [[P:%.*]], i8* align 1 [[Q:%.*]], i64 12, i32 1)
; CHECK-NEXT:    tail call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i64(i8* align 1 [[P]], i8* align 1 [[Q]], i64 12, i32 1)
; CHECK-NEXT:    ret void
;

  tail call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i64(i8* align 1 %P, i8* align 1 %Q, i64 12, i32 1)
  tail call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i64(i8* align 1 %P, i8* align 1 %Q, i64 12, i32 1)
  ret void
}

define void @test37(i8* %P, i8* %Q, i8* %R) {
; CHECK-LABEL: @test37(
; CHECK-NEXT:    tail call void @llvm.memcpy.p0i8.p0i8.i64(i8* [[P:%.*]], i8* [[Q:%.*]], i64 12, i1 false)
; CHECK-NEXT:    tail call void @llvm.memmove.p0i8.p0i8.i64(i8* [[P]], i8* [[R:%.*]], i64 12, i1 false)
; CHECK-NEXT:    ret void
;

  tail call void @llvm.memcpy.p0i8.p0i8.i64(i8* %P, i8* %Q, i64 12, i1 false)
  tail call void @llvm.memmove.p0i8.p0i8.i64(i8* %P, i8* %R, i64 12, i1 false)
  ret void
}

define void @test37_atomic(i8* %P, i8* %Q, i8* %R) {
; CHECK-LABEL: @test37_atomic(
; CHECK-NEXT:    tail call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i64(i8* align 1 [[P:%.*]], i8* align 1 [[Q:%.*]], i64 12, i32 1)
; CHECK-NEXT:    tail call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i64(i8* align 1 [[P]], i8* align 1 [[R:%.*]], i64 12, i32 1)
; CHECK-NEXT:    ret void
;

  tail call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i64(i8* align 1 %P, i8* align 1 %Q, i64 12, i32 1)
  tail call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i64(i8* align 1 %P, i8* align 1 %R, i64 12, i32 1)
  ret void
}

; The memmove is dead, because memcpy arguments cannot overlap.
define void @test38(i8* %P, i8* %Q, i8* %R) {
; CHECK-LABEL: @test38(
; CHECK-NEXT:    tail call void @llvm.memcpy.p0i8.p0i8.i64(i8* [[P:%.*]], i8* [[R:%.*]], i64 12, i1 false)
; CHECK-NEXT:    ret void
;

  tail call void @llvm.memmove.p0i8.p0i8.i64(i8* %P, i8* %Q, i64 12, i1 false)
  tail call void @llvm.memcpy.p0i8.p0i8.i64(i8* %P, i8* %R, i64 12, i1 false)
  ret void
}

; The memmove is dead, because memcpy arguments cannot overlap.
define void @test38_atomic(i8* %P, i8* %Q, i8* %R) {
; CHECK-LABEL: @test38_atomic(
; CHECK-NEXT:    tail call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i64(i8* align 1 [[P:%.*]], i8* align 1 [[R:%.*]], i64 12, i32 1)
; CHECK-NEXT:    ret void
;

  tail call void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i64(i8* align 1 %P, i8* align 1 %Q, i64 12, i32 1)
  tail call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i64(i8* align 1 %P, i8* align 1 %R, i64 12, i32 1)
  ret void
}

define void @test39(i8* %P, i8* %Q, i8* %R) {
; CHECK-LABEL: @test39(
; CHECK-NEXT:    tail call void @llvm.memcpy.p0i8.p0i8.i64(i8* [[P:%.*]], i8* [[Q:%.*]], i64 12, i1 false)
; CHECK-NEXT:    tail call void @llvm.memcpy.p0i8.p0i8.i64(i8* [[P]], i8* [[R:%.*]], i64 8, i1 false)
; CHECK-NEXT:    ret void
;

  tail call void @llvm.memcpy.p0i8.p0i8.i64(i8* %P, i8* %Q, i64 12, i1 false)
  tail call void @llvm.memcpy.p0i8.p0i8.i64(i8* %P, i8* %R, i64 8, i1 false)
  ret void
}

define void @test39_atomic(i8* %P, i8* %Q, i8* %R) {
; CHECK-LABEL: @test39_atomic(
; CHECK-NEXT:    tail call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i64(i8* align 1 [[P:%.*]], i8* align 1 [[Q:%.*]], i64 12, i32 1)
; CHECK-NEXT:    tail call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i64(i8* align 1 [[P]], i8* align 1 [[R:%.*]], i64 8, i32 1)
; CHECK-NEXT:    ret void
;

  tail call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i64(i8* align 1 %P, i8* align 1 %Q, i64 12, i32 1)
  tail call void @llvm.memcpy.element.unordered.atomic.p0i8.p0i8.i64(i8* align 1 %P, i8* align 1 %R, i64 8, i32 1)
  ret void
}

declare void @llvm.memmove.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i1)
declare void @llvm.memmove.element.unordered.atomic.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i32)

declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) nounwind
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture) nounwind
define void @test40(i32** noalias %Pp, i32* noalias %Q)  {
; CHECK-LABEL: @test40(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[A:%.*]] = alloca i32, align 4
; CHECK-NEXT:    [[AC:%.*]] = bitcast i32* [[A]] to i8*
; CHECK-NEXT:    call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull [[AC]])
; CHECK-NEXT:    [[TMP0:%.*]] = bitcast i32** [[PP:%.*]] to i8**
; CHECK-NEXT:    [[PC:%.*]] = load i8*, i8** [[TMP0]], align 8
; CHECK-NEXT:    [[QC:%.*]] = bitcast i32* [[Q:%.*]] to i8*
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 4 [[AC]], i8* align 4 [[QC]], i64 4, i1 false)
; CHECK-NEXT:    call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 [[PC]], i8* nonnull align 4 [[AC]], i64 4, i1 true)
; CHECK-NEXT:    call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull [[AC]])
; CHECK-NEXT:    ret void
;
entry:
  %A = alloca i32, align 4
  %Ac = bitcast i32* %A to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %Ac)
  %0 = bitcast i32** %Pp to i8**
  %Pc = load i8*, i8** %0, align 8
  %Qc = bitcast i32* %Q to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 4 %Ac, i8* align 4 %Qc, i64 4, i1 false)
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 4 %Pc, i8* nonnull align 4 %Ac, i64 4, i1 true)
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %Ac)
  ret void
}

; I think this case is currently handled incorrectly by memdeps dse
; throwing should leave store i32 1, not remove from the free.
declare void @free(i8* nocapture)
define void @test41(i32* noalias %P) {
; CHECK-LABEL: @test41(
; CHECK-NEXT:    [[P2:%.*]] = bitcast i32* [[P:%.*]] to i8*
; CHECK-NEXT:    store i32 1, i32* [[P]], align 4
; CHECK-NEXT:    call void @unknown_func()
; CHECK-NEXT:    call void @free(i8* [[P2]])
; CHECK-NEXT:    ret void
;
  %P2 = bitcast i32* %P to i8*
  store i32 1, i32* %P
  call void @unknown_func()
  store i32 2, i32* %P
  call void @free(i8* %P2)
  ret void
}

define void @test42(i32* %P, i32* %Q) {
; CHECK-LABEL: @test42(
; CHECK-NEXT:    store i32 1, i32* [[P:%.*]], align 4
; CHECK-NEXT:    [[P2:%.*]] = bitcast i32* [[P]] to i8*
; CHECK-NEXT:    store i32 2, i32* [[Q:%.*]], align 4
; CHECK-NEXT:    store i8 3, i8* [[P2]], align 1
; CHECK-NEXT:    ret void
;
  store i32 1, i32* %P
  %P2 = bitcast i32* %P to i8*
  store i32 2, i32* %Q
  store i8 3, i8* %P2
  ret void
}

define void @test42a(i32* %P, i32* %Q) {
; CHECK-LABEL: @test42a(
; CHECK-NEXT:    store atomic i32 1, i32* [[P:%.*]] unordered, align 4
; CHECK-NEXT:    [[P2:%.*]] = bitcast i32* [[P]] to i8*
; CHECK-NEXT:    store atomic i32 2, i32* [[Q:%.*]] unordered, align 4
; CHECK-NEXT:    store atomic i8 3, i8* [[P2]] unordered, align 4
; CHECK-NEXT:    ret void
;
  store atomic i32 1, i32* %P unordered, align 4
  %P2 = bitcast i32* %P to i8*
  store atomic i32 2, i32* %Q unordered, align 4
  store atomic i8 3, i8* %P2 unordered, align 4
  ret void
}

define void @test43a(i32* %P, i32* noalias %Q) {
; CHECK-LABEL: @test43a(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    store atomic i32 50331649, i32* [[P:%.*]] unordered, align 4
; CHECK-NEXT:    store atomic i32 2, i32* [[Q:%.*]] unordered, align 4
; CHECK-NEXT:    ret void
;
entry:
  store atomic i32 1, i32* %P unordered, align 4
  %P2 = bitcast i32* %P to i8*
  store atomic i32 2, i32* %Q unordered, align 4
  store atomic i8 3, i8* %P2 unordered, align 4
  ret void
}

; Some tests where volatile may block removing a store.

; Here we can remove the first non-volatile store. We cannot remove the
; volatile store.
define void @test44_volatile(i32* %P) {
; CHECK-LABEL: @test44_volatile(
; CHECK-NEXT:    store volatile i32 2, i32* [[P:%.*]], align 4
; CHECK-NEXT:    store i32 3, i32* [[P]], align 4
; CHECK-NEXT:    ret void
;
  store i32 1, i32* %P, align 4
  store volatile i32 2, i32* %P, align 4
  store i32 3, i32* %P, align 4
  ret void
}

define void @test45_volatile(i32* %P) {
; CHECK-LABEL: @test45_volatile(
; CHECK-NEXT:    store volatile i32 2, i32* [[P]], align 4
; CHECK-NEXT:    store volatile i32 3, i32* [[P]], align 4
; CHECK-NEXT:    ret void
;
  store i32 1, i32* %P, align 4
  store volatile i32 2, i32* %P, align 4
  store volatile i32 3, i32* %P, align 4
  ret void
}

define void @test46_volatile(i32* %P) {
; CHECK-LABEL: @test46_volatile(
; CHECK-NEXT:    store volatile i32 2, i32* [[P:%.*]], align 4
; CHECK-NEXT:    store volatile i32 3, i32* [[P]], align 4
; CHECK-NEXT:    ret void
;
  store volatile i32 2, i32* %P, align 4
  store i32 1, i32* %P, align 4
  store volatile i32 3, i32* %P, align 4
  ret void
}

define void @test47_volatile(i32* %P) {
; CHECK-LABEL: @test47_volatile(
; CHECK-NEXT:    store volatile i32 2, i32* [[P:%.*]], align 4
; CHECK-NEXT:    store volatile i32 3, i32* [[P]], align 4
; CHECK-NEXT:    ret void
;
  store volatile i32 2, i32* %P, align 4
  store volatile i32 3, i32* %P, align 4
  ret void
}
