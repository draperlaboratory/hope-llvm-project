; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -correlated-propagation -S | FileCheck %s

target datalayout = "e-m:e-p:32:32-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv7m-arm-none-eabi"

define void @h(i32* nocapture %p, i32 %x) local_unnamed_addr #0 {
; CHECK-LABEL: @h(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt i32 [[X:%.*]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[IF_THEN:%.*]], label [[IF_END:%.*]]
; CHECK:       if.then:
; CHECK-NEXT:    [[REM21:%.*]] = urem i32 [[X]], 10
; CHECK-NEXT:    store i32 [[REM21]], i32* [[P:%.*]], align 4
; CHECK-NEXT:    br label [[IF_END]]
; CHECK:       if.end:
; CHECK-NEXT:    ret void
;
entry:

  %cmp = icmp sgt i32 %x, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:
  %rem2 = srem i32 %x, 10
  store i32 %rem2, i32* %p, align 4
  br label %if.end

if.end:
  ret void
}

; looping case where loop has exactly one block
; at the point of srem, we know that %a is always greater than 0,
; because of the assume before it, so we can transform it to urem.
declare void @llvm.assume(i1)
define void @test4(i32 %n) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP:%.*]] = icmp sgt i32 [[N:%.*]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[LOOP:%.*]], label [[EXIT:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[A:%.*]] = phi i32 [ [[N]], [[ENTRY:%.*]] ], [ [[REM1:%.*]], [[LOOP]] ]
; CHECK-NEXT:    [[COND:%.*]] = icmp sgt i32 [[A]], 4
; CHECK-NEXT:    call void @llvm.assume(i1 [[COND]])
; CHECK-NEXT:    [[REM1]] = urem i32 [[A]], 6
; CHECK-NEXT:    [[LOOPCOND:%.*]] = icmp sgt i32 [[REM1]], 8
; CHECK-NEXT:    br i1 [[LOOPCOND]], label [[LOOP]], label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret void
;
entry:
  %cmp = icmp sgt i32 %n, 0
  br i1 %cmp, label %loop, label %exit

loop:
  %a = phi i32 [ %n, %entry ], [ %rem, %loop ]
  %cond = icmp sgt i32 %a, 4
  call void @llvm.assume(i1 %cond)
  %rem = srem i32 %a, 6
  %loopcond = icmp sgt i32 %rem, 8
  br i1 %loopcond, label %loop, label %exit

exit:
  ret void
}

; Now, let's try various domain combinations for operands.

define i8 @test5_pos_pos(i8 %x, i8 %y) {
; CHECK-LABEL: @test5_pos_pos(
; CHECK-NEXT:    [[C0:%.*]] = icmp sge i8 [[X:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[C0]])
; CHECK-NEXT:    [[C1:%.*]] = icmp sge i8 [[Y:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[C1]])
; CHECK-NEXT:    [[REM1:%.*]] = urem i8 [[X]], [[Y]]
; CHECK-NEXT:    ret i8 [[REM1]]
;
  %c0 = icmp sge i8 %x, 0
  call void @llvm.assume(i1 %c0)
  %c1 = icmp sge i8 %y, 0
  call void @llvm.assume(i1 %c1)

  %rem = srem i8 %x, %y
  ret i8 %rem
}
define i8 @test6_pos_neg(i8 %x, i8 %y) {
; CHECK-LABEL: @test6_pos_neg(
; CHECK-NEXT:    [[C0:%.*]] = icmp sge i8 [[X:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[C0]])
; CHECK-NEXT:    [[C1:%.*]] = icmp sle i8 [[Y:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[C1]])
; CHECK-NEXT:    [[Y_NONNEG:%.*]] = sub i8 0, [[Y]]
; CHECK-NEXT:    [[REM1:%.*]] = urem i8 [[X]], [[Y_NONNEG]]
; CHECK-NEXT:    ret i8 [[REM1]]
;
  %c0 = icmp sge i8 %x, 0
  call void @llvm.assume(i1 %c0)
  %c1 = icmp sle i8 %y, 0
  call void @llvm.assume(i1 %c1)

  %rem = srem i8 %x, %y
  ret i8 %rem
}
define i8 @test7_neg_pos(i8 %x, i8 %y) {
; CHECK-LABEL: @test7_neg_pos(
; CHECK-NEXT:    [[C0:%.*]] = icmp sle i8 [[X:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[C0]])
; CHECK-NEXT:    [[C1:%.*]] = icmp sge i8 [[Y:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[C1]])
; CHECK-NEXT:    [[X_NONNEG:%.*]] = sub i8 0, [[X]]
; CHECK-NEXT:    [[REM1:%.*]] = urem i8 [[X_NONNEG]], [[Y]]
; CHECK-NEXT:    [[REM1_NEG:%.*]] = sub i8 0, [[REM1]]
; CHECK-NEXT:    ret i8 [[REM1_NEG]]
;
  %c0 = icmp sle i8 %x, 0
  call void @llvm.assume(i1 %c0)
  %c1 = icmp sge i8 %y, 0
  call void @llvm.assume(i1 %c1)

  %rem = srem i8 %x, %y
  ret i8 %rem
}
define i8 @test8_neg_neg(i8 %x, i8 %y) {
; CHECK-LABEL: @test8_neg_neg(
; CHECK-NEXT:    [[C0:%.*]] = icmp sle i8 [[X:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[C0]])
; CHECK-NEXT:    [[C1:%.*]] = icmp sle i8 [[Y:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[C1]])
; CHECK-NEXT:    [[X_NONNEG:%.*]] = sub i8 0, [[X]]
; CHECK-NEXT:    [[Y_NONNEG:%.*]] = sub i8 0, [[Y]]
; CHECK-NEXT:    [[REM1:%.*]] = urem i8 [[X_NONNEG]], [[Y_NONNEG]]
; CHECK-NEXT:    [[REM1_NEG:%.*]] = sub i8 0, [[REM1]]
; CHECK-NEXT:    ret i8 [[REM1_NEG]]
;
  %c0 = icmp sle i8 %x, 0
  call void @llvm.assume(i1 %c0)
  %c1 = icmp sle i8 %y, 0
  call void @llvm.assume(i1 %c1)

  %rem = srem i8 %x, %y
  ret i8 %rem
}

; After making remainder unsigned, can we narrow it?
define i16 @test9_narrow(i16 %x, i16 %y) {
; CHECK-LABEL: @test9_narrow(
; CHECK-NEXT:    [[C0:%.*]] = icmp ult i16 [[X:%.*]], 128
; CHECK-NEXT:    call void @llvm.assume(i1 [[C0]])
; CHECK-NEXT:    [[C1:%.*]] = icmp ult i16 [[Y:%.*]], 128
; CHECK-NEXT:    call void @llvm.assume(i1 [[C1]])
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    [[REM1_LHS_TRUNC:%.*]] = trunc i16 [[X]] to i8
; CHECK-NEXT:    [[REM1_RHS_TRUNC:%.*]] = trunc i16 [[Y]] to i8
; CHECK-NEXT:    [[REM12:%.*]] = urem i8 [[REM1_LHS_TRUNC]], [[REM1_RHS_TRUNC]]
; CHECK-NEXT:    [[REM1_ZEXT:%.*]] = zext i8 [[REM12]] to i16
; CHECK-NEXT:    ret i16 [[REM1_ZEXT]]
;
  %c0 = icmp ult i16 %x, 128
  call void @llvm.assume(i1 %c0)
  %c1 = icmp ult i16 %y, 128
  call void @llvm.assume(i1 %c1)
  br label %end

end:
  %rem = srem i16 %x, %y
  ret i16 %rem
}

; Ok, but what about narrowing srem in general?

; If both operands are i15, it's uncontroversial - we can truncate to i16
define i64 @test11_i15_i15(i64 %x, i64 %y) {
; CHECK-LABEL: @test11_i15_i15(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp sle i64 [[X:%.*]], 16383
; CHECK-NEXT:    call void @llvm.assume(i1 [[C0]])
; CHECK-NEXT:    [[C1:%.*]] = icmp sge i64 [[X]], -16384
; CHECK-NEXT:    call void @llvm.assume(i1 [[C1]])
; CHECK-NEXT:    [[C2:%.*]] = icmp sle i64 [[Y:%.*]], 16383
; CHECK-NEXT:    call void @llvm.assume(i1 [[C2]])
; CHECK-NEXT:    [[C3:%.*]] = icmp sge i64 [[Y]], -16384
; CHECK-NEXT:    call void @llvm.assume(i1 [[C3]])
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    [[DIV_LHS_TRUNC:%.*]] = trunc i64 [[X]] to i16
; CHECK-NEXT:    [[DIV_RHS_TRUNC:%.*]] = trunc i64 [[Y]] to i16
; CHECK-NEXT:    [[DIV1:%.*]] = srem i16 [[DIV_LHS_TRUNC]], [[DIV_RHS_TRUNC]]
; CHECK-NEXT:    [[DIV_SEXT:%.*]] = sext i16 [[DIV1]] to i64
; CHECK-NEXT:    ret i64 [[DIV_SEXT]]
;
entry:
  %c0 = icmp sle i64 %x, 16383
  call void @llvm.assume(i1 %c0)
  %c1 = icmp sge i64 %x, -16384
  call void @llvm.assume(i1 %c1)

  %c2 = icmp sle i64 %y, 16383
  call void @llvm.assume(i1 %c2)
  %c3 = icmp sge i64 %y, -16384
  call void @llvm.assume(i1 %c3)
  br label %end

end:
  %div = srem i64 %x, %y
  ret i64 %div
}

; But if operands are i16, we can only truncate to i32, because we can't
; rule out UB of  i16 INT_MIN s/ i16 -1
define i64 @test12_i16_i16(i64 %x, i64 %y) {
; CHECK-LABEL: @test12_i16_i16(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp sle i64 [[X:%.*]], 32767
; CHECK-NEXT:    call void @llvm.assume(i1 [[C0]])
; CHECK-NEXT:    [[C1:%.*]] = icmp sge i64 [[X]], -32768
; CHECK-NEXT:    call void @llvm.assume(i1 [[C1]])
; CHECK-NEXT:    [[C2:%.*]] = icmp sle i64 [[Y:%.*]], 32767
; CHECK-NEXT:    call void @llvm.assume(i1 [[C2]])
; CHECK-NEXT:    [[C3:%.*]] = icmp sge i64 [[Y]], -32768
; CHECK-NEXT:    call void @llvm.assume(i1 [[C3]])
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    [[DIV_LHS_TRUNC:%.*]] = trunc i64 [[X]] to i32
; CHECK-NEXT:    [[DIV_RHS_TRUNC:%.*]] = trunc i64 [[Y]] to i32
; CHECK-NEXT:    [[DIV1:%.*]] = srem i32 [[DIV_LHS_TRUNC]], [[DIV_RHS_TRUNC]]
; CHECK-NEXT:    [[DIV_SEXT:%.*]] = sext i32 [[DIV1]] to i64
; CHECK-NEXT:    ret i64 [[DIV_SEXT]]
;
entry:
  %c0 = icmp sle i64 %x, 32767
  call void @llvm.assume(i1 %c0)
  %c1 = icmp sge i64 %x, -32768
  call void @llvm.assume(i1 %c1)

  %c2 = icmp sle i64 %y, 32767
  call void @llvm.assume(i1 %c2)
  %c3 = icmp sge i64 %y, -32768
  call void @llvm.assume(i1 %c3)
  br label %end

end:
  %div = srem i64 %x, %y
  ret i64 %div
}

; But if divident is i16, and divisor is u15, then we know that i16 is UB-safe.
define i64 @test13_i16_u15(i64 %x, i64 %y) {
; CHECK-LABEL: @test13_i16_u15(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp sle i64 [[X:%.*]], 32767
; CHECK-NEXT:    call void @llvm.assume(i1 [[C0]])
; CHECK-NEXT:    [[C1:%.*]] = icmp sge i64 [[X]], -32768
; CHECK-NEXT:    call void @llvm.assume(i1 [[C1]])
; CHECK-NEXT:    [[C2:%.*]] = icmp ule i64 [[Y:%.*]], 32767
; CHECK-NEXT:    call void @llvm.assume(i1 [[C2]])
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    [[DIV_LHS_TRUNC:%.*]] = trunc i64 [[X]] to i16
; CHECK-NEXT:    [[DIV_RHS_TRUNC:%.*]] = trunc i64 [[Y]] to i16
; CHECK-NEXT:    [[DIV1:%.*]] = srem i16 [[DIV_LHS_TRUNC]], [[DIV_RHS_TRUNC]]
; CHECK-NEXT:    [[DIV_SEXT:%.*]] = sext i16 [[DIV1]] to i64
; CHECK-NEXT:    ret i64 [[DIV_SEXT]]
;
entry:
  %c0 = icmp sle i64 %x, 32767
  call void @llvm.assume(i1 %c0)
  %c1 = icmp sge i64 %x, -32768
  call void @llvm.assume(i1 %c1)

  %c2 = icmp ule i64 %y, 32767
  call void @llvm.assume(i1 %c2)
  br label %end

end:
  %div = srem i64 %x, %y
  ret i64 %div
}

; And likewise, if we know that if the divident is never i16 INT_MIN,
; we can truncate to i16.
define i64 @test14_i16safe_i16(i64 %x, i64 %y) {
; CHECK-LABEL: @test14_i16safe_i16(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp sle i64 [[X:%.*]], 32767
; CHECK-NEXT:    call void @llvm.assume(i1 [[C0]])
; CHECK-NEXT:    [[C1:%.*]] = icmp sgt i64 [[X]], -32768
; CHECK-NEXT:    call void @llvm.assume(i1 [[C1]])
; CHECK-NEXT:    [[C2:%.*]] = icmp sle i64 [[Y:%.*]], 32767
; CHECK-NEXT:    call void @llvm.assume(i1 [[C2]])
; CHECK-NEXT:    [[C3:%.*]] = icmp sge i64 [[Y]], -32768
; CHECK-NEXT:    call void @llvm.assume(i1 [[C3]])
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    [[DIV_LHS_TRUNC:%.*]] = trunc i64 [[X]] to i16
; CHECK-NEXT:    [[DIV_RHS_TRUNC:%.*]] = trunc i64 [[Y]] to i16
; CHECK-NEXT:    [[DIV1:%.*]] = srem i16 [[DIV_LHS_TRUNC]], [[DIV_RHS_TRUNC]]
; CHECK-NEXT:    [[DIV_SEXT:%.*]] = sext i16 [[DIV1]] to i64
; CHECK-NEXT:    ret i64 [[DIV_SEXT]]
;
entry:
  %c0 = icmp sle i64 %x, 32767
  call void @llvm.assume(i1 %c0)
  %c1 = icmp sgt i64 %x, -32768
  call void @llvm.assume(i1 %c1)

  %c2 = icmp sle i64 %y, 32767
  call void @llvm.assume(i1 %c2)
  %c3 = icmp sge i64 %y, -32768
  call void @llvm.assume(i1 %c3)
  br label %end

end:
  %div = srem i64 %x, %y
  ret i64 %div
}

; Of course, both of the conditions can happen at once.
define i64 @test15_i16safe_u15(i64 %x, i64 %y) {
; CHECK-LABEL: @test15_i16safe_u15(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp sle i64 [[X:%.*]], 32767
; CHECK-NEXT:    call void @llvm.assume(i1 [[C0]])
; CHECK-NEXT:    [[C1:%.*]] = icmp sgt i64 [[X]], -32768
; CHECK-NEXT:    call void @llvm.assume(i1 [[C1]])
; CHECK-NEXT:    [[C2:%.*]] = icmp ule i64 [[Y:%.*]], 32767
; CHECK-NEXT:    call void @llvm.assume(i1 [[C2]])
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    [[DIV_LHS_TRUNC:%.*]] = trunc i64 [[X]] to i16
; CHECK-NEXT:    [[DIV_RHS_TRUNC:%.*]] = trunc i64 [[Y]] to i16
; CHECK-NEXT:    [[DIV1:%.*]] = srem i16 [[DIV_LHS_TRUNC]], [[DIV_RHS_TRUNC]]
; CHECK-NEXT:    [[DIV_SEXT:%.*]] = sext i16 [[DIV1]] to i64
; CHECK-NEXT:    ret i64 [[DIV_SEXT]]
;
entry:
  %c0 = icmp sle i64 %x, 32767
  call void @llvm.assume(i1 %c0)
  %c1 = icmp sgt i64 %x, -32768
  call void @llvm.assume(i1 %c1)

  %c2 = icmp ule i64 %y, 32767
  call void @llvm.assume(i1 %c2)
  br label %end

end:
  %div = srem i64 %x, %y
  ret i64 %div
}

; We at most truncate to i8
define i64 @test16_i4_i4(i64 %x, i64 %y) {
; CHECK-LABEL: @test16_i4_i4(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp sle i64 [[X:%.*]], 3
; CHECK-NEXT:    call void @llvm.assume(i1 [[C0]])
; CHECK-NEXT:    [[C1:%.*]] = icmp sge i64 [[X]], -4
; CHECK-NEXT:    call void @llvm.assume(i1 [[C1]])
; CHECK-NEXT:    [[C2:%.*]] = icmp sle i64 [[Y:%.*]], 3
; CHECK-NEXT:    call void @llvm.assume(i1 [[C2]])
; CHECK-NEXT:    [[C3:%.*]] = icmp sge i64 [[Y]], -4
; CHECK-NEXT:    call void @llvm.assume(i1 [[C3]])
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    [[DIV_LHS_TRUNC:%.*]] = trunc i64 [[X]] to i8
; CHECK-NEXT:    [[DIV_RHS_TRUNC:%.*]] = trunc i64 [[Y]] to i8
; CHECK-NEXT:    [[DIV1:%.*]] = srem i8 [[DIV_LHS_TRUNC]], [[DIV_RHS_TRUNC]]
; CHECK-NEXT:    [[DIV_SEXT:%.*]] = sext i8 [[DIV1]] to i64
; CHECK-NEXT:    ret i64 [[DIV_SEXT]]
;
entry:
  %c0 = icmp sle i64 %x, 3
  call void @llvm.assume(i1 %c0)
  %c1 = icmp sge i64 %x, -4
  call void @llvm.assume(i1 %c1)

  %c2 = icmp sle i64 %y, 3
  call void @llvm.assume(i1 %c2)
  %c3 = icmp sge i64 %y, -4
  call void @llvm.assume(i1 %c3)
  br label %end

end:
  %div = srem i64 %x, %y
  ret i64 %div
}

; And we round up to the powers of two
define i64 @test17_i9_i9(i64 %x, i64 %y) {
; CHECK-LABEL: @test17_i9_i9(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp sle i64 [[X:%.*]], 255
; CHECK-NEXT:    call void @llvm.assume(i1 [[C0]])
; CHECK-NEXT:    [[C1:%.*]] = icmp sge i64 [[X]], -256
; CHECK-NEXT:    call void @llvm.assume(i1 [[C1]])
; CHECK-NEXT:    [[C2:%.*]] = icmp sle i64 [[Y:%.*]], 255
; CHECK-NEXT:    call void @llvm.assume(i1 [[C2]])
; CHECK-NEXT:    [[C3:%.*]] = icmp sge i64 [[Y]], -256
; CHECK-NEXT:    call void @llvm.assume(i1 [[C3]])
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    [[DIV_LHS_TRUNC:%.*]] = trunc i64 [[X]] to i16
; CHECK-NEXT:    [[DIV_RHS_TRUNC:%.*]] = trunc i64 [[Y]] to i16
; CHECK-NEXT:    [[DIV1:%.*]] = srem i16 [[DIV_LHS_TRUNC]], [[DIV_RHS_TRUNC]]
; CHECK-NEXT:    [[DIV_SEXT:%.*]] = sext i16 [[DIV1]] to i64
; CHECK-NEXT:    ret i64 [[DIV_SEXT]]
;
entry:
  %c0 = icmp sle i64 %x, 255
  call void @llvm.assume(i1 %c0)
  %c1 = icmp sge i64 %x, -256
  call void @llvm.assume(i1 %c1)

  %c2 = icmp sle i64 %y, 255
  call void @llvm.assume(i1 %c2)
  %c3 = icmp sge i64 %y, -256
  call void @llvm.assume(i1 %c3)
  br label %end

end:
  %div = srem i64 %x, %y
  ret i64 %div
}

; Don't widen the operation to the next power of two if it wasn't a power of two.
define i9 @test18_i9_i9(i9 %x, i9 %y) {
; CHECK-LABEL: @test18_i9_i9(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp sle i9 [[X:%.*]], 255
; CHECK-NEXT:    call void @llvm.assume(i1 [[C0]])
; CHECK-NEXT:    [[C1:%.*]] = icmp sge i9 [[X]], -256
; CHECK-NEXT:    call void @llvm.assume(i1 [[C1]])
; CHECK-NEXT:    [[C2:%.*]] = icmp sle i9 [[Y:%.*]], 255
; CHECK-NEXT:    call void @llvm.assume(i1 [[C2]])
; CHECK-NEXT:    [[C3:%.*]] = icmp sge i9 [[Y]], -256
; CHECK-NEXT:    call void @llvm.assume(i1 [[C3]])
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    [[DIV:%.*]] = srem i9 [[X]], [[Y]]
; CHECK-NEXT:    ret i9 [[DIV]]
;
entry:
  %c0 = icmp sle i9 %x, 255
  call void @llvm.assume(i1 %c0)
  %c1 = icmp sge i9 %x, -256
  call void @llvm.assume(i1 %c1)

  %c2 = icmp sle i9 %y, 255
  call void @llvm.assume(i1 %c2)
  %c3 = icmp sge i9 %y, -256
  call void @llvm.assume(i1 %c3)
  br label %end

end:
  %div = srem i9 %x, %y
  ret i9 %div
}
define i10 @test19_i10_i10(i10 %x, i10 %y) {
; CHECK-LABEL: @test19_i10_i10(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp sle i10 [[X:%.*]], 255
; CHECK-NEXT:    call void @llvm.assume(i1 [[C0]])
; CHECK-NEXT:    [[C1:%.*]] = icmp sge i10 [[X]], -256
; CHECK-NEXT:    call void @llvm.assume(i1 [[C1]])
; CHECK-NEXT:    [[C2:%.*]] = icmp sle i10 [[Y:%.*]], 255
; CHECK-NEXT:    call void @llvm.assume(i1 [[C2]])
; CHECK-NEXT:    [[C3:%.*]] = icmp sge i10 [[Y]], -256
; CHECK-NEXT:    call void @llvm.assume(i1 [[C3]])
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    [[DIV:%.*]] = srem i10 [[X]], [[Y]]
; CHECK-NEXT:    ret i10 [[DIV]]
;
entry:
  %c0 = icmp sle i10 %x, 255
  call void @llvm.assume(i1 %c0)
  %c1 = icmp sge i10 %x, -256
  call void @llvm.assume(i1 %c1)

  %c2 = icmp sle i10 %y, 255
  call void @llvm.assume(i1 %c2)
  %c3 = icmp sge i10 %y, -256
  call void @llvm.assume(i1 %c3)
  br label %end

end:
  %div = srem i10 %x, %y
  ret i10 %div
}

; Note that we need to take the maximal bitwidth, in which both of the operands are representable!
define i64 @test20_i16_i18(i64 %x, i64 %y) {
; CHECK-LABEL: @test20_i16_i18(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp sle i64 [[X:%.*]], 16383
; CHECK-NEXT:    call void @llvm.assume(i1 [[C0]])
; CHECK-NEXT:    [[C1:%.*]] = icmp sge i64 [[X]], -16384
; CHECK-NEXT:    call void @llvm.assume(i1 [[C1]])
; CHECK-NEXT:    [[C2:%.*]] = icmp sle i64 [[Y:%.*]], 65535
; CHECK-NEXT:    call void @llvm.assume(i1 [[C2]])
; CHECK-NEXT:    [[C3:%.*]] = icmp sge i64 [[Y]], -65536
; CHECK-NEXT:    call void @llvm.assume(i1 [[C3]])
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    [[DIV_LHS_TRUNC:%.*]] = trunc i64 [[X]] to i32
; CHECK-NEXT:    [[DIV_RHS_TRUNC:%.*]] = trunc i64 [[Y]] to i32
; CHECK-NEXT:    [[DIV1:%.*]] = srem i32 [[DIV_LHS_TRUNC]], [[DIV_RHS_TRUNC]]
; CHECK-NEXT:    [[DIV_SEXT:%.*]] = sext i32 [[DIV1]] to i64
; CHECK-NEXT:    ret i64 [[DIV_SEXT]]
;
entry:
  %c0 = icmp sle i64 %x, 16383
  call void @llvm.assume(i1 %c0)
  %c1 = icmp sge i64 %x, -16384
  call void @llvm.assume(i1 %c1)

  %c2 = icmp sle i64 %y, 65535
  call void @llvm.assume(i1 %c2)
  %c3 = icmp sge i64 %y, -65536
  call void @llvm.assume(i1 %c3)
  br label %end

end:
  %div = srem i64 %x, %y
  ret i64 %div
}
define i64 @test21_i18_i16(i64 %x, i64 %y) {
; CHECK-LABEL: @test21_i18_i16(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[C0:%.*]] = icmp sle i64 [[X:%.*]], 65535
; CHECK-NEXT:    call void @llvm.assume(i1 [[C0]])
; CHECK-NEXT:    [[C1:%.*]] = icmp sge i64 [[X]], -65536
; CHECK-NEXT:    call void @llvm.assume(i1 [[C1]])
; CHECK-NEXT:    [[C2:%.*]] = icmp sle i64 [[Y:%.*]], 16383
; CHECK-NEXT:    call void @llvm.assume(i1 [[C2]])
; CHECK-NEXT:    [[C3:%.*]] = icmp sge i64 [[Y]], -16384
; CHECK-NEXT:    call void @llvm.assume(i1 [[C3]])
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       end:
; CHECK-NEXT:    [[DIV_LHS_TRUNC:%.*]] = trunc i64 [[X]] to i32
; CHECK-NEXT:    [[DIV_RHS_TRUNC:%.*]] = trunc i64 [[Y]] to i32
; CHECK-NEXT:    [[DIV1:%.*]] = srem i32 [[DIV_LHS_TRUNC]], [[DIV_RHS_TRUNC]]
; CHECK-NEXT:    [[DIV_SEXT:%.*]] = sext i32 [[DIV1]] to i64
; CHECK-NEXT:    ret i64 [[DIV_SEXT]]
;
entry:
  %c0 = icmp sle i64 %x, 65535
  call void @llvm.assume(i1 %c0)
  %c1 = icmp sge i64 %x, -65536
  call void @llvm.assume(i1 %c1)

  %c2 = icmp sle i64 %y, 16383
  call void @llvm.assume(i1 %c2)
  %c3 = icmp sge i64 %y, -16384
  call void @llvm.assume(i1 %c3)
  br label %end

end:
  %div = srem i64 %x, %y
  ret i64 %div
}
