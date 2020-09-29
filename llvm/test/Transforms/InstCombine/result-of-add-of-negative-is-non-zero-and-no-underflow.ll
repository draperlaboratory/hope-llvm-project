; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

declare void @use8(i8)

declare void @use1(i1)
declare void @llvm.assume(i1)

; Here we don't know that at least one of the values being added is non-zero
define i1 @t0_bad(i8 %base, i8 %offset) {
; CHECK-LABEL: @t0_bad(
; CHECK-NEXT:    [[ADJUSTED:%.*]] = add i8 [[BASE:%.*]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[NOT_NULL:%.*]] = icmp ne i8 [[ADJUSTED]], 0
; CHECK-NEXT:    [[NO_UNDERFLOW:%.*]] = icmp ult i8 [[ADJUSTED]], [[BASE]]
; CHECK-NEXT:    [[R:%.*]] = and i1 [[NOT_NULL]], [[NO_UNDERFLOW]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %adjusted = add i8 %base, %offset
  call void @use8(i8 %adjusted)
  %not_null = icmp ne i8 %adjusted, 0
  %no_underflow = icmp ult i8 %adjusted, %base
  %r = and i1 %not_null, %no_underflow
  ret i1 %r
}

; Ok, base is non-zero.
define i1 @t1(i8 %base, i8 %offset) {
; CHECK-LABEL: @t1(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i8 [[BASE:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[ADJUSTED:%.*]] = add i8 [[BASE]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[TMP1:%.*]] = sub i8 0, [[BASE]]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ult i8 [[TMP1]], [[OFFSET]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp = icmp slt i8 %base, 0
  call void @llvm.assume(i1 %cmp)

  %adjusted = add i8 %base, %offset
  call void @use8(i8 %adjusted)
  %not_null = icmp ne i8 %adjusted, 0
  %no_underflow = icmp ult i8 %adjusted, %base
  %r = and i1 %not_null, %no_underflow
  ret i1 %r
}

; Ok, offset is non-zero.
define i1 @t2(i8 %base, i8 %offset) {
; CHECK-LABEL: @t2(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i8 [[OFFSET:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[ADJUSTED:%.*]] = add i8 [[BASE:%.*]], [[OFFSET]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[TMP1:%.*]] = sub i8 0, [[OFFSET]]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ult i8 [[TMP1]], [[BASE]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp = icmp slt i8 %offset, 0
  call void @llvm.assume(i1 %cmp)

  %adjusted = add i8 %base, %offset
  call void @use8(i8 %adjusted)
  %not_null = icmp ne i8 %adjusted, 0
  %no_underflow = icmp ult i8 %adjusted, %base
  %r = and i1 %not_null, %no_underflow
  ret i1 %r
}

; We need to produce extra instruction, so one of icmp's must go away.
define i1 @t3_oneuse0(i8 %base, i8 %offset) {
; CHECK-LABEL: @t3_oneuse0(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i8 [[BASE:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[ADJUSTED:%.*]] = add i8 [[BASE]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[NOT_NULL:%.*]] = icmp ne i8 [[ADJUSTED]], 0
; CHECK-NEXT:    call void @use1(i1 [[NOT_NULL]])
; CHECK-NEXT:    [[TMP1:%.*]] = sub i8 0, [[BASE]]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ult i8 [[TMP1]], [[OFFSET]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp = icmp slt i8 %base, 0
  call void @llvm.assume(i1 %cmp)

  %adjusted = add i8 %base, %offset
  call void @use8(i8 %adjusted)
  %not_null = icmp ne i8 %adjusted, 0
  call void @use1(i1 %not_null)
  %no_underflow = icmp ult i8 %adjusted, %base
  %r = and i1 %not_null, %no_underflow
  ret i1 %r
}
define i1 @t4_oneuse1(i8 %base, i8 %offset) {
; CHECK-LABEL: @t4_oneuse1(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i8 [[BASE:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[ADJUSTED:%.*]] = add i8 [[BASE]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[NO_UNDERFLOW:%.*]] = icmp ult i8 [[ADJUSTED]], [[BASE]]
; CHECK-NEXT:    call void @use1(i1 [[NO_UNDERFLOW]])
; CHECK-NEXT:    [[TMP1:%.*]] = sub i8 0, [[BASE]]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ult i8 [[TMP1]], [[OFFSET]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp = icmp slt i8 %base, 0
  call void @llvm.assume(i1 %cmp)

  %adjusted = add i8 %base, %offset
  call void @use8(i8 %adjusted)
  %not_null = icmp ne i8 %adjusted, 0
  %no_underflow = icmp ult i8 %adjusted, %base
  call void @use1(i1 %no_underflow)
  %r = and i1 %not_null, %no_underflow
  ret i1 %r
}
define i1 @t5_oneuse2_bad(i8 %base, i8 %offset) {
; CHECK-LABEL: @t5_oneuse2_bad(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i8 [[BASE:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[ADJUSTED:%.*]] = add i8 [[BASE]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[NOT_NULL:%.*]] = icmp ne i8 [[ADJUSTED]], 0
; CHECK-NEXT:    call void @use1(i1 [[NOT_NULL]])
; CHECK-NEXT:    [[NO_UNDERFLOW:%.*]] = icmp ult i8 [[ADJUSTED]], [[BASE]]
; CHECK-NEXT:    call void @use1(i1 [[NO_UNDERFLOW]])
; CHECK-NEXT:    [[R:%.*]] = and i1 [[NOT_NULL]], [[NO_UNDERFLOW]]
; CHECK-NEXT:    ret i1 [[R]]
;
  %cmp = icmp slt i8 %base, 0
  call void @llvm.assume(i1 %cmp)

  %adjusted = add i8 %base, %offset
  call void @use8(i8 %adjusted)
  %not_null = icmp ne i8 %adjusted, 0
  call void @use1(i1 %not_null)
  %no_underflow = icmp ult i8 %adjusted, %base
  call void @use1(i1 %no_underflow)
  %r = and i1 %not_null, %no_underflow
  ret i1 %r
}

define i1 @t6_commutativity0(i8 %base, i8 %offset) {
; CHECK-LABEL: @t6_commutativity0(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i8 [[BASE:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[ADJUSTED:%.*]] = add i8 [[BASE]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[TMP1:%.*]] = sub i8 0, [[BASE]]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ult i8 [[TMP1]], [[OFFSET]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp = icmp slt i8 %base, 0
  call void @llvm.assume(i1 %cmp)

  %adjusted = add i8 %base, %offset
  call void @use8(i8 %adjusted)
  %not_null = icmp ne i8 %adjusted, 0
  %no_underflow = icmp ult i8 %adjusted, %base
  %r = and i1 %no_underflow, %not_null ; swapped
  ret i1 %r
}
define i1 @t7_commutativity1(i8 %base, i8 %offset) {
; CHECK-LABEL: @t7_commutativity1(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i8 [[BASE:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[ADJUSTED:%.*]] = add i8 [[BASE]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[TMP1:%.*]] = sub i8 0, [[BASE]]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ult i8 [[TMP1]], [[OFFSET]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp = icmp slt i8 %base, 0
  call void @llvm.assume(i1 %cmp)

  %adjusted = add i8 %base, %offset
  call void @use8(i8 %adjusted)
  %not_null = icmp ne i8 %adjusted, 0
  %no_underflow = icmp ugt i8 %base, %adjusted ; swapped
  %r = and i1 %not_null, %no_underflow
  ret i1 %r
}
define i1 @t7_commutativity3(i8 %base, i8 %offset) {
; CHECK-LABEL: @t7_commutativity3(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i8 [[BASE:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[ADJUSTED:%.*]] = add i8 [[BASE]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[TMP1:%.*]] = sub i8 0, [[BASE]]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ult i8 [[TMP1]], [[OFFSET]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp = icmp slt i8 %base, 0
  call void @llvm.assume(i1 %cmp)

  %adjusted = add i8 %base, %offset
  call void @use8(i8 %adjusted)
  %not_null = icmp ne i8 %adjusted, 0
  %no_underflow = icmp ugt i8 %base, %adjusted ; swapped
  %r = and i1 %no_underflow, %not_null ; swapped
  ret i1 %r
}

; We could have the opposite question, did we get null or overflow happened?
define i1 @t8(i8 %base, i8 %offset) {
; CHECK-LABEL: @t8(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i8 [[BASE:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[ADJUSTED:%.*]] = add i8 [[BASE]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[TMP1:%.*]] = sub i8 0, [[BASE]]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp uge i8 [[TMP1]], [[OFFSET]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp = icmp slt i8 %base, 0
  call void @llvm.assume(i1 %cmp)

  %adjusted = add i8 %base, %offset
  call void @use8(i8 %adjusted)
  %not_null = icmp eq i8 %adjusted, 0
  %no_underflow = icmp uge i8 %adjusted, %base
  %r = or i1 %not_null, %no_underflow
  ret i1 %r
}

; The comparison can be with any of the values being added.
define i1 @t9(i8 %base, i8 %offset) {
; CHECK-LABEL: @t9(
; CHECK-NEXT:    [[CMP:%.*]] = icmp slt i8 [[BASE:%.*]], 0
; CHECK-NEXT:    call void @llvm.assume(i1 [[CMP]])
; CHECK-NEXT:    [[ADJUSTED:%.*]] = add i8 [[BASE]], [[OFFSET:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[ADJUSTED]])
; CHECK-NEXT:    [[TMP1:%.*]] = sub i8 0, [[BASE]]
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ult i8 [[TMP1]], [[OFFSET]]
; CHECK-NEXT:    ret i1 [[TMP2]]
;
  %cmp = icmp slt i8 %base, 0
  call void @llvm.assume(i1 %cmp)

  %adjusted = add i8 %base, %offset
  call void @use8(i8 %adjusted)
  %not_null = icmp ne i8 %adjusted, 0
  %no_underflow = icmp ult i8 %adjusted, %offset
  %r = and i1 %not_null, %no_underflow
  ret i1 %r
}
