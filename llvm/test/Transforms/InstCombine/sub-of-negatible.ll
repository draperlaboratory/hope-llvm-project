; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt %s -instcombine -S | FileCheck %s

declare void @use8(i8)
declare void @use_v2i4(<2 x i4>)

; Constant can be freely negated.
define i8 @t0(i8 %x) {
; CHECK-LABEL: @t0(
; CHECK-NEXT:    [[T0:%.*]] = add i8 [[X:%.*]], 42
; CHECK-NEXT:    ret i8 [[T0]]
;
  %t0 = sub i8 %x, -42
  ret i8 %t0
}

; Negation can be negated for free
define i8 @t1(i8 %x, i8 %y) {
; CHECK-LABEL: @t1(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[Y:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = add i8 [[X:%.*]], [[Y]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = sub i8 0, %y
  call void @use8(i8 %t0)
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}

; Shift-left can be negated if all uses can be updated
define i8 @t2(i8 %x, i8 %y) {
; CHECK-LABEL: @t2(
; CHECK-NEXT:    [[T0_NEG:%.*]] = shl i8 42, [[Y:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = add i8 [[T0_NEG]], [[X:%.*]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = shl i8 -42, %y
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}
define i8 @n2(i8 %x, i8 %y) {
; CHECK-LABEL: @n2(
; CHECK-NEXT:    [[T0:%.*]] = shl i8 -42, [[Y:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = sub i8 [[X:%.*]], [[T0]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = shl i8 -42, %y
  call void @use8(i8 %t0)
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}
define i8 @t3(i8 %x, i8 %y, i8 %z) {
; CHECK-LABEL: @t3(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[Z:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1_NEG:%.*]] = shl i8 [[Z]], [[Y:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i8 [[T1_NEG]], [[X:%.*]]
; CHECK-NEXT:    ret i8 [[T2]]
;
  %t0 = sub i8 0, %z
  call void @use8(i8 %t0)
  %t1 = shl i8 %t0, %y
  %t2 = sub i8 %x, %t1
  ret i8 %t2
}
define i8 @n3(i8 %x, i8 %y, i8 %z) {
; CHECK-LABEL: @n3(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[Z:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = shl i8 [[T0]], [[Y:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = sub i8 [[X:%.*]], [[T1]]
; CHECK-NEXT:    ret i8 [[T2]]
;
  %t0 = sub i8 0, %z
  call void @use8(i8 %t0)
  %t1 = shl i8 %t0, %y
  call void @use8(i8 %t1)
  %t2 = sub i8 %x, %t1
  ret i8 %t2
}

; Select can be negated if all it's operands can be negated and all the users of select can be updated
define i8 @t4(i8 %x, i1 %y) {
; CHECK-LABEL: @t4(
; CHECK-NEXT:    [[T0_NEG:%.*]] = select i1 [[Y:%.*]], i8 42, i8 -44
; CHECK-NEXT:    [[T1:%.*]] = add i8 [[T0_NEG]], [[X:%.*]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = select i1 %y, i8 -42, i8 44
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}
define i8 @n4(i8 %x, i1 %y) {
; CHECK-LABEL: @n4(
; CHECK-NEXT:    [[T0:%.*]] = select i1 [[Y:%.*]], i8 -42, i8 44
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = sub i8 [[X:%.*]], [[T0]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = select i1 %y, i8 -42, i8 44
  call void @use8(i8 %t0)
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}
define i8 @n5(i8 %x, i1 %y, i8 %z) {
; CHECK-LABEL: @n5(
; CHECK-NEXT:    [[T0:%.*]] = select i1 [[Y:%.*]], i8 -42, i8 [[Z:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = sub i8 [[X:%.*]], [[T0]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = select i1 %y, i8 -42, i8 %z
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}
define i8 @t6(i8 %x, i1 %y, i8 %z) {
; CHECK-LABEL: @t6(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[Z:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1_NEG:%.*]] = select i1 [[Y:%.*]], i8 42, i8 [[Z]]
; CHECK-NEXT:    [[T2:%.*]] = add i8 [[T1_NEG]], [[X:%.*]]
; CHECK-NEXT:    ret i8 [[T2]]
;
  %t0 = sub i8 0, %z
  call void @use8(i8 %t0)
  %t1 = select i1 %y, i8 -42, i8 %t0
  %t2 = sub i8 %x, %t1
  ret i8 %t2
}
define i8 @t7(i8 %x, i1 %y, i8 %z) {
; CHECK-LABEL: @t7(
; CHECK-NEXT:    [[T0_NEG:%.*]] = shl i8 -1, [[Z:%.*]]
; CHECK-NEXT:    [[T1_NEG:%.*]] = select i1 [[Y:%.*]], i8 0, i8 [[T0_NEG]]
; CHECK-NEXT:    [[T2:%.*]] = add i8 [[T1_NEG]], [[X:%.*]]
; CHECK-NEXT:    ret i8 [[T2]]
;
  %t0 = shl i8 1, %z
  %t1 = select i1 %y, i8 0, i8 %t0
  %t2 = sub i8 %x, %t1
  ret i8 %t2
}
define i8 @n8(i8 %x, i1 %y, i8 %z) {
; CHECK-LABEL: @n8(
; CHECK-NEXT:    [[T0:%.*]] = shl i8 1, [[Z:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = select i1 [[Y:%.*]], i8 0, i8 [[T0]]
; CHECK-NEXT:    [[T2:%.*]] = sub i8 [[X:%.*]], [[T1]]
; CHECK-NEXT:    ret i8 [[T2]]
;
  %t0 = shl i8 1, %z
  call void @use8(i8 %t0)
  %t1 = select i1 %y, i8 0, i8 %t0
  %t2 = sub i8 %x, %t1
  ret i8 %t2
}

; Subtraction can be negated by swapping its operands.
; x - (y - z) -> x - y + z -> x + (z - y)
define i8 @t9(i8 %x, i8 %y) {
; CHECK-LABEL: @t9(
; CHECK-NEXT:    [[T0_NEG:%.*]] = sub i8 [[X:%.*]], [[Y:%.*]]
; CHECK-NEXT:    ret i8 [[T0_NEG]]
;
  %t0 = sub i8 %y, %x
  %t1 = sub i8 0, %t0
  ret i8 %t1
}
define i8 @n10(i8 %x, i8 %y, i8 %z) {
; CHECK-LABEL: @n10(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = sub i8 0, [[T0]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = sub i8 %y, %x
  call void @use8(i8 %t0)
  %t1 = sub i8 0, %t0
  ret i8 %t1
}

; Addition can be negated if both operands can be negated
; x - (y + z) -> x - y - z -> x + ((-y) + (-z)))
define i8 @t12(i8 %x, i8 %y, i8 %z) {
; CHECK-LABEL: @t12(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[Y:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = sub i8 0, [[Z:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T1]])
; CHECK-NEXT:    [[TMP1:%.*]] = add i8 [[Y]], [[Z]]
; CHECK-NEXT:    [[T3:%.*]] = add i8 [[TMP1]], [[X:%.*]]
; CHECK-NEXT:    ret i8 [[T3]]
;
  %t0 = sub i8 0, %y
  call void @use8(i8 %t0)
  %t1 = sub i8 0, %z
  call void @use8(i8 %t1)
  %t2 = add i8 %t0, %t1
  %t3 = sub i8 %x, %t2
  ret i8 %t3
}
define i8 @n13(i8 %x, i8 %y, i8 %z) {
; CHECK-LABEL: @n13(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[Y:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1_NEG:%.*]] = sub i8 [[Y]], [[Z:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i8 [[T1_NEG]], [[X:%.*]]
; CHECK-NEXT:    ret i8 [[T2]]
;
  %t0 = sub i8 0, %y
  call void @use8(i8 %t0)
  %t1 = add i8 %t0, %z
  %t2 = sub i8 %x, %t1
  ret i8 %t2
}
define i8 @n14(i8 %x, i8 %y, i8 %z) {
; CHECK-LABEL: @n14(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[Y:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = sub i8 0, [[Z:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T1]])
; CHECK-NEXT:    [[TMP1:%.*]] = add i8 [[Y]], [[Z]]
; CHECK-NEXT:    [[T2:%.*]] = sub i8 0, [[TMP1]]
; CHECK-NEXT:    call void @use8(i8 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = add i8 [[TMP1]], [[X:%.*]]
; CHECK-NEXT:    ret i8 [[T3]]
;
  %t0 = sub i8 0, %y
  call void @use8(i8 %t0)
  %t1 = sub i8 0, %z
  call void @use8(i8 %t1)
  %t2 = add i8 %t0, %t1
  call void @use8(i8 %t2)
  %t3 = sub i8 %x, %t2
  ret i8 %t3
}

; Multiplication can be negated if either one of operands can be negated
; x - (y * z) -> x + ((-y) * z) or  x + ((-z) * y)
define i8 @t15(i8 %x, i8 %y, i8 %z) {
; CHECK-LABEL: @t15(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[Y:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1_NEG:%.*]] = mul i8 [[Y]], [[Z:%.*]]
; CHECK-NEXT:    [[T2:%.*]] = add i8 [[T1_NEG]], [[X:%.*]]
; CHECK-NEXT:    ret i8 [[T2]]
;
  %t0 = sub i8 0, %y
  call void @use8(i8 %t0)
  %t1 = mul i8 %t0, %z
  %t2 = sub i8 %x, %t1
  ret i8 %t2
}
define i8 @n16(i8 %x, i8 %y, i8 %z) {
; CHECK-LABEL: @n16(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[Y:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = mul i8 [[T0]], [[Z:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = sub i8 [[X:%.*]], [[T1]]
; CHECK-NEXT:    ret i8 [[T2]]
;
  %t0 = sub i8 0, %y
  call void @use8(i8 %t0)
  %t1 = mul i8 %t0, %z
  call void @use8(i8 %t1)
  %t2 = sub i8 %x, %t1
  ret i8 %t2
}

; Phi can be negated if all incoming values can be negated
define i8 @t16(i1 %c, i8 %x) {
; CHECK-LABEL: @t16(
; CHECK-NEXT:  begin:
; CHECK-NEXT:    br i1 [[C:%.*]], label [[THEN:%.*]], label [[ELSE:%.*]]
; CHECK:       then:
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       else:
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[Z_NEG:%.*]] = phi i8 [ [[X:%.*]], [[THEN]] ], [ 42, [[ELSE]] ]
; CHECK-NEXT:    ret i8 [[Z_NEG]]
;
begin:
  br i1 %c, label %then, label %else
then:
  %y = sub i8 0, %x
  br label %end
else:
  br label %end
end:
  %z = phi i8 [ %y, %then], [ -42, %else ]
  %n = sub i8 0, %z
  ret i8 %n
}
define i8 @n17(i1 %c, i8 %x) {
; CHECK-LABEL: @n17(
; CHECK-NEXT:  begin:
; CHECK-NEXT:    br i1 [[C:%.*]], label [[THEN:%.*]], label [[ELSE:%.*]]
; CHECK:       then:
; CHECK-NEXT:    [[Y:%.*]] = sub i8 0, [[X:%.*]]
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       else:
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[Z:%.*]] = phi i8 [ [[Y]], [[THEN]] ], [ -42, [[ELSE]] ]
; CHECK-NEXT:    call void @use8(i8 [[Z]])
; CHECK-NEXT:    [[N:%.*]] = sub i8 0, [[Z]]
; CHECK-NEXT:    ret i8 [[N]]
;
begin:
  br i1 %c, label %then, label %else
then:
  %y = sub i8 0, %x
  br label %end
else:
  br label %end
end:
  %z = phi i8 [ %y, %then], [ -42, %else ]
  call void @use8(i8 %z)
  %n = sub i8 0, %z
  ret i8 %n
}
define i8 @n19(i1 %c, i8 %x, i8 %y) {
; CHECK-LABEL: @n19(
; CHECK-NEXT:  begin:
; CHECK-NEXT:    br i1 [[C:%.*]], label [[THEN:%.*]], label [[ELSE:%.*]]
; CHECK:       then:
; CHECK-NEXT:    [[Z:%.*]] = sub i8 0, [[X:%.*]]
; CHECK-NEXT:    br label [[END:%.*]]
; CHECK:       else:
; CHECK-NEXT:    br label [[END]]
; CHECK:       end:
; CHECK-NEXT:    [[R:%.*]] = phi i8 [ [[Z]], [[THEN]] ], [ [[Y:%.*]], [[ELSE]] ]
; CHECK-NEXT:    [[N:%.*]] = sub i8 0, [[R]]
; CHECK-NEXT:    ret i8 [[N]]
;
begin:
  br i1 %c, label %then, label %else
then:
  %z = sub i8 0, %x
  br label %end
else:
  br label %end
end:
  %r = phi i8 [ %z, %then], [ %y, %else ]
  %n = sub i8 0, %r
  ret i8 %n
}

; truncation can be negated if it's operand can be negated
define i8 @t20(i8 %x, i16 %y) {
; CHECK-LABEL: @t20(
; CHECK-NEXT:    [[T0_NEG:%.*]] = shl i16 42, [[Y:%.*]]
; CHECK-NEXT:    [[T1_NEG:%.*]] = trunc i16 [[T0_NEG]] to i8
; CHECK-NEXT:    [[T2:%.*]] = add i8 [[T1_NEG]], [[X:%.*]]
; CHECK-NEXT:    ret i8 [[T2]]
;
  %t0 = shl i16 -42, %y
  %t1 = trunc i16 %t0 to i8
  %t2 = sub i8 %x, %t1
  ret i8 %t2
}
define i8 @n21(i8 %x, i16 %y) {
; CHECK-LABEL: @n21(
; CHECK-NEXT:    [[T0:%.*]] = shl i16 -42, [[Y:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = trunc i16 [[T0]] to i8
; CHECK-NEXT:    call void @use8(i8 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = sub i8 [[X:%.*]], [[T1]]
; CHECK-NEXT:    ret i8 [[T2]]
;
  %t0 = shl i16 -42, %y
  %t1 = trunc i16 %t0 to i8
  call void @use8(i8 %t1)
  %t2 = sub i8 %x, %t1
  ret i8 %t2
}

define i4 @negate_xor(i4 %x) {
; CHECK-LABEL: @negate_xor(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i4 [[X:%.*]], -6
; CHECK-NEXT:    [[O_NEG:%.*]] = add i4 [[TMP1]], 1
; CHECK-NEXT:    ret i4 [[O_NEG]]
;
  %o = xor i4 %x, 5
  %r = sub i4 0, %o
  ret i4 %r
}

define <2 x i4> @negate_xor_vec(<2 x i4> %x) {
; CHECK-LABEL: @negate_xor_vec(
; CHECK-NEXT:    [[TMP1:%.*]] = xor <2 x i4> [[X:%.*]], <i4 -6, i4 5>
; CHECK-NEXT:    [[O_NEG:%.*]] = add <2 x i4> [[TMP1]], <i4 1, i4 1>
; CHECK-NEXT:    ret <2 x i4> [[O_NEG]]
;
  %o = xor <2 x i4> %x, <i4 5, i4 10>
  %r = sub <2 x i4> zeroinitializer, %o
  ret <2 x i4> %r
}

define i8 @negate_xor_use(i8 %x) {
; CHECK-LABEL: @negate_xor_use(
; CHECK-NEXT:    [[O:%.*]] = xor i8 [[X:%.*]], 5
; CHECK-NEXT:    call void @use8(i8 [[O]])
; CHECK-NEXT:    [[R:%.*]] = sub i8 0, [[O]]
; CHECK-NEXT:    ret i8 [[R]]
;
  %o = xor i8 %x, 5
  call void @use8(i8 %o)
  %r = sub i8 0, %o
  ret i8 %r
}

define i4 @negate_shl_xor(i4 %x, i4 %y) {
; CHECK-LABEL: @negate_shl_xor(
; CHECK-NEXT:    [[TMP1:%.*]] = xor i4 [[X:%.*]], -6
; CHECK-NEXT:    [[O_NEG:%.*]] = add i4 [[TMP1]], 1
; CHECK-NEXT:    [[S_NEG:%.*]] = shl i4 [[O_NEG]], [[Y:%.*]]
; CHECK-NEXT:    ret i4 [[S_NEG]]
;
  %o = xor i4 %x, 5
  %s = shl i4 %o, %y
  %r = sub i4 0, %s
  ret i4 %r
}

define i8 @negate_shl_not_uses(i8 %x, i8 %y) {
; CHECK-LABEL: @negate_shl_not_uses(
; CHECK-NEXT:    [[O_NEG:%.*]] = add i8 [[X:%.*]], 1
; CHECK-NEXT:    [[O:%.*]] = xor i8 [[X]], -1
; CHECK-NEXT:    call void @use8(i8 [[O]])
; CHECK-NEXT:    [[S_NEG:%.*]] = shl i8 [[O_NEG]], [[Y:%.*]]
; CHECK-NEXT:    ret i8 [[S_NEG]]
;
  %o = xor i8 %x, -1
  call void @use8(i8 %o)
  %s = shl i8 %o, %y
  %r = sub i8 0, %s
  ret i8 %r
}

define <2 x i4> @negate_mul_not_uses_vec(<2 x i4> %x, <2 x i4> %y) {
; CHECK-LABEL: @negate_mul_not_uses_vec(
; CHECK-NEXT:    [[O_NEG:%.*]] = add <2 x i4> [[X:%.*]], <i4 1, i4 1>
; CHECK-NEXT:    [[O:%.*]] = xor <2 x i4> [[X]], <i4 -1, i4 -1>
; CHECK-NEXT:    call void @use_v2i4(<2 x i4> [[O]])
; CHECK-NEXT:    [[S_NEG:%.*]] = mul <2 x i4> [[O_NEG]], [[Y:%.*]]
; CHECK-NEXT:    ret <2 x i4> [[S_NEG]]
;
  %o = xor <2 x i4> %x, <i4 -1, i4 -1>
  call void @use_v2i4(<2 x i4> %o)
  %s = mul <2 x i4> %o, %y
  %r = sub <2 x i4> zeroinitializer, %s
  ret <2 x i4> %r
}

; signed division can be negated if divisor can be negated and is not 1/-1
define i8 @negate_sdiv(i8 %x, i8 %y) {
; CHECK-LABEL: @negate_sdiv(
; CHECK-NEXT:    [[T0_NEG:%.*]] = sdiv i8 [[Y:%.*]], -42
; CHECK-NEXT:    [[T1:%.*]] = add i8 [[T0_NEG]], [[X:%.*]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = sdiv i8 %y, 42
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}
define i8 @negate_sdiv_extrause(i8 %x, i8 %y) {
; CHECK-LABEL: @negate_sdiv_extrause(
; CHECK-NEXT:    [[T0:%.*]] = sdiv i8 [[Y:%.*]], 42
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = sub i8 [[X:%.*]], [[T0]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = sdiv i8 %y, 42
  call void @use8(i8 %t0)
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}
define i8 @negate_sdiv_extrause2(i8 %x, i8 %y) {
; CHECK-LABEL: @negate_sdiv_extrause2(
; CHECK-NEXT:    [[T0:%.*]] = sdiv i8 [[Y:%.*]], 42
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = sub nsw i8 0, [[T0]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = sdiv i8 %y, 42
  call void @use8(i8 %t0)
  %t1 = sub i8 0, %t0
  ret i8 %t1
}

; Right-shift sign bit smear is negatible.
define i8 @negate_ashr(i8 %x, i8 %y) {
; CHECK-LABEL: @negate_ashr(
; CHECK-NEXT:    [[T0_NEG:%.*]] = lshr i8 [[Y:%.*]], 7
; CHECK-NEXT:    [[T1:%.*]] = add i8 [[T0_NEG]], [[X:%.*]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = ashr i8 %y, 7
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}
define i8 @negate_lshr(i8 %x, i8 %y) {
; CHECK-LABEL: @negate_lshr(
; CHECK-NEXT:    [[T0_NEG:%.*]] = ashr i8 [[Y:%.*]], 7
; CHECK-NEXT:    [[T1:%.*]] = add i8 [[T0_NEG]], [[X:%.*]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = lshr i8 %y, 7
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}
define i8 @negate_ashr_extrause(i8 %x, i8 %y) {
; CHECK-LABEL: @negate_ashr_extrause(
; CHECK-NEXT:    [[T0:%.*]] = ashr i8 [[Y:%.*]], 7
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = sub i8 [[X:%.*]], [[T0]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = ashr i8 %y, 7
  call void @use8(i8 %t0)
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}
define i8 @negate_lshr_extrause(i8 %x, i8 %y) {
; CHECK-LABEL: @negate_lshr_extrause(
; CHECK-NEXT:    [[T0:%.*]] = lshr i8 [[Y:%.*]], 7
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = sub i8 [[X:%.*]], [[T0]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = lshr i8 %y, 7
  call void @use8(i8 %t0)
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}
define i8 @negate_ashr_wrongshift(i8 %x, i8 %y) {
; CHECK-LABEL: @negate_ashr_wrongshift(
; CHECK-NEXT:    [[T0:%.*]] = ashr i8 [[Y:%.*]], 6
; CHECK-NEXT:    [[T1:%.*]] = sub i8 [[X:%.*]], [[T0]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = ashr i8 %y, 6
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}
define i8 @negate_lshr_wrongshift(i8 %x, i8 %y) {
; CHECK-LABEL: @negate_lshr_wrongshift(
; CHECK-NEXT:    [[T0:%.*]] = lshr i8 [[Y:%.*]], 6
; CHECK-NEXT:    [[T1:%.*]] = sub i8 [[X:%.*]], [[T0]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = lshr i8 %y, 6
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}

; *ext of i1 is always negatible
define i8 @negate_sext(i8 %x, i1 %y) {
; CHECK-LABEL: @negate_sext(
; CHECK-NEXT:    [[T0_NEG:%.*]] = zext i1 [[Y:%.*]] to i8
; CHECK-NEXT:    [[T1:%.*]] = add i8 [[T0_NEG]], [[X:%.*]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = sext i1 %y to i8
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}
define i8 @negate_zext(i8 %x, i1 %y) {
; CHECK-LABEL: @negate_zext(
; CHECK-NEXT:    [[T0_NEG:%.*]] = sext i1 [[Y:%.*]] to i8
; CHECK-NEXT:    [[T1:%.*]] = add i8 [[T0_NEG]], [[X:%.*]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = zext i1 %y to i8
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}
define i8 @negate_sext_extrause(i8 %x, i1 %y) {
; CHECK-LABEL: @negate_sext_extrause(
; CHECK-NEXT:    [[T0:%.*]] = sext i1 [[Y:%.*]] to i8
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = sub i8 [[X:%.*]], [[T0]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = sext i1 %y to i8
  call void @use8(i8 %t0)
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}
define i8 @negate_zext_extrause(i8 %x, i1 %y) {
; CHECK-LABEL: @negate_zext_extrause(
; CHECK-NEXT:    [[T0:%.*]] = zext i1 [[Y:%.*]] to i8
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = sub i8 [[X:%.*]], [[T0]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = zext i1 %y to i8
  call void @use8(i8 %t0)
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}
define i8 @negate_sext_wrongwidth(i8 %x, i2 %y) {
; CHECK-LABEL: @negate_sext_wrongwidth(
; CHECK-NEXT:    [[T0:%.*]] = sext i2 [[Y:%.*]] to i8
; CHECK-NEXT:    [[T1:%.*]] = sub i8 [[X:%.*]], [[T0]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = sext i2 %y to i8
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}
define i8 @negate_zext_wrongwidth(i8 %x, i2 %y) {
; CHECK-LABEL: @negate_zext_wrongwidth(
; CHECK-NEXT:    [[T0:%.*]] = zext i2 [[Y:%.*]] to i8
; CHECK-NEXT:    [[T1:%.*]] = sub i8 [[X:%.*]], [[T0]]
; CHECK-NEXT:    ret i8 [[T1]]
;
  %t0 = zext i2 %y to i8
  %t1 = sub i8 %x, %t0
  ret i8 %t1
}

define <2 x i4> @negate_shufflevector_oneinput_reverse(<2 x i4> %x, <2 x i4> %y) {
; CHECK-LABEL: @negate_shufflevector_oneinput_reverse(
; CHECK-NEXT:    [[T0_NEG:%.*]] = shl <2 x i4> <i4 6, i4 -5>, [[X:%.*]]
; CHECK-NEXT:    [[T1_NEG:%.*]] = shufflevector <2 x i4> [[T0_NEG]], <2 x i4> undef, <2 x i32> <i32 1, i32 0>
; CHECK-NEXT:    [[T2:%.*]] = add <2 x i4> [[T1_NEG]], [[Y:%.*]]
; CHECK-NEXT:    ret <2 x i4> [[T2]]
;
  %t0 = shl <2 x i4> <i4 -6, i4 5>, %x
  %t1 = shufflevector <2 x i4> %t0, <2 x i4> undef, <2 x i32> <i32 1, i32 0>
  %t2 = sub <2 x i4> %y, %t1
  ret <2 x i4> %t2
}
define <2 x i4> @negate_shufflevector_oneinput_second_lane_is_undef(<2 x i4> %x, <2 x i4> %y) {
; CHECK-LABEL: @negate_shufflevector_oneinput_second_lane_is_undef(
; CHECK-NEXT:    [[T0_NEG:%.*]] = shl <2 x i4> <i4 6, i4 -5>, [[X:%.*]]
; CHECK-NEXT:    [[T1_NEG:%.*]] = shufflevector <2 x i4> [[T0_NEG]], <2 x i4> undef, <2 x i32> <i32 0, i32 undef>
; CHECK-NEXT:    [[T2:%.*]] = add <2 x i4> [[T1_NEG]], [[Y:%.*]]
; CHECK-NEXT:    ret <2 x i4> [[T2]]
;
  %t0 = shl <2 x i4> <i4 -6, i4 5>, %x
  %t1 = shufflevector <2 x i4> %t0, <2 x i4> undef, <2 x i32> <i32 0, i32 2>
  %t2 = sub <2 x i4> %y, %t1
  ret <2 x i4> %t2
}
define <2 x i4> @negate_shufflevector_twoinputs(<2 x i4> %x, <2 x i4> %y, <2 x i4> %z) {
; CHECK-LABEL: @negate_shufflevector_twoinputs(
; CHECK-NEXT:    [[T0_NEG:%.*]] = shl <2 x i4> <i4 6, i4 -5>, [[X:%.*]]
; CHECK-NEXT:    [[T1_NEG:%.*]] = add <2 x i4> [[Y:%.*]], <i4 undef, i4 1>
; CHECK-NEXT:    [[T2_NEG:%.*]] = shufflevector <2 x i4> [[T0_NEG]], <2 x i4> [[T1_NEG]], <2 x i32> <i32 0, i32 3>
; CHECK-NEXT:    [[T3:%.*]] = add <2 x i4> [[T2_NEG]], [[Z:%.*]]
; CHECK-NEXT:    ret <2 x i4> [[T3]]
;
  %t0 = shl <2 x i4> <i4 -6, i4 5>, %x
  %t1 = xor <2 x i4> %y, <i4 -1, i4 -1>
  %t2 = shufflevector <2 x i4> %t0, <2 x i4> %t1, <2 x i32> <i32 0, i32 3>
  %t3 = sub <2 x i4> %z, %t2
  ret <2 x i4> %t3
}
define <2 x i4> @negate_shufflevector_oneinput_extrause(<2 x i4> %x, <2 x i4> %y) {
; CHECK-LABEL: @negate_shufflevector_oneinput_extrause(
; CHECK-NEXT:    [[T0:%.*]] = shl <2 x i4> <i4 -6, i4 5>, [[X:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = shufflevector <2 x i4> [[T0]], <2 x i4> undef, <2 x i32> <i32 1, i32 0>
; CHECK-NEXT:    call void @use_v2i4(<2 x i4> [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = sub <2 x i4> [[Y:%.*]], [[T1]]
; CHECK-NEXT:    ret <2 x i4> [[T2]]
;
  %t0 = shl <2 x i4> <i4 -6, i4 5>, %x
  %t1 = shufflevector <2 x i4> %t0, <2 x i4> undef, <2 x i32> <i32 1, i32 0>
  call void @use_v2i4(<2 x i4> %t1)
  %t2 = sub <2 x i4> %y, %t1
  ret <2 x i4> %t2
}

; zext of non-negative can be negated
; sext of non-positive can be negated
define i16 @negation_of_zeroext_of_nonnegative(i8 %x) {
; CHECK-LABEL: @negation_of_zeroext_of_nonnegative(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[X:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = icmp sgt i8 [[T0]], -1
; CHECK-NEXT:    br i1 [[T1]], label [[NONNEG_BB:%.*]], label [[NEG_BB:%.*]]
; CHECK:       nonneg_bb:
; CHECK-NEXT:    [[T2:%.*]] = zext i8 [[T0]] to i16
; CHECK-NEXT:    [[T3:%.*]] = sub nsw i16 0, [[T2]]
; CHECK-NEXT:    ret i16 [[T3]]
; CHECK:       neg_bb:
; CHECK-NEXT:    ret i16 0
;
  %t0 = sub i8 0, %x
  %t1 = icmp sge i8 %t0, 0
  br i1 %t1, label %nonneg_bb, label %neg_bb

nonneg_bb:
  %t2 = zext i8 %t0 to i16
  %t3 = sub i16 0, %t2
  ret i16 %t3

neg_bb:
  ret i16 0
}
define i16 @negation_of_zeroext_of_positive(i8 %x) {
; CHECK-LABEL: @negation_of_zeroext_of_positive(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[X:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = icmp sgt i8 [[T0]], 0
; CHECK-NEXT:    br i1 [[T1]], label [[NONNEG_BB:%.*]], label [[NEG_BB:%.*]]
; CHECK:       nonneg_bb:
; CHECK-NEXT:    [[T2:%.*]] = zext i8 [[T0]] to i16
; CHECK-NEXT:    [[T3:%.*]] = sub nsw i16 0, [[T2]]
; CHECK-NEXT:    ret i16 [[T3]]
; CHECK:       neg_bb:
; CHECK-NEXT:    ret i16 0
;
  %t0 = sub i8 0, %x
  %t1 = icmp sgt i8 %t0, 0
  br i1 %t1, label %nonneg_bb, label %neg_bb

nonneg_bb:
  %t2 = zext i8 %t0 to i16
  %t3 = sub i16 0, %t2
  ret i16 %t3

neg_bb:
  ret i16 0
}
define i16 @negation_of_signext_of_negative(i8 %x) {
; CHECK-LABEL: @negation_of_signext_of_negative(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[X:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = icmp slt i8 [[T0]], 0
; CHECK-NEXT:    br i1 [[T1]], label [[NEG_BB:%.*]], label [[NONNEG_BB:%.*]]
; CHECK:       neg_bb:
; CHECK-NEXT:    [[T2:%.*]] = sext i8 [[T0]] to i16
; CHECK-NEXT:    [[T3:%.*]] = sub nsw i16 0, [[T2]]
; CHECK-NEXT:    ret i16 [[T3]]
; CHECK:       nonneg_bb:
; CHECK-NEXT:    ret i16 0
;
  %t0 = sub i8 0, %x
  %t1 = icmp slt i8 %t0, 0
  br i1 %t1, label %neg_bb, label %nonneg_bb

neg_bb:
  %t2 = sext i8 %t0 to i16
  %t3 = sub i16 0, %t2
  ret i16 %t3

nonneg_bb:
  ret i16 0
}
define i16 @negation_of_signext_of_nonpositive(i8 %x) {
; CHECK-LABEL: @negation_of_signext_of_nonpositive(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[X:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = icmp slt i8 [[T0]], 1
; CHECK-NEXT:    br i1 [[T1]], label [[NEG_BB:%.*]], label [[NONNEG_BB:%.*]]
; CHECK:       neg_bb:
; CHECK-NEXT:    [[T2:%.*]] = sext i8 [[T0]] to i16
; CHECK-NEXT:    [[T3:%.*]] = sub nsw i16 0, [[T2]]
; CHECK-NEXT:    ret i16 [[T3]]
; CHECK:       nonneg_bb:
; CHECK-NEXT:    ret i16 0
;
  %t0 = sub i8 0, %x
  %t1 = icmp sle i8 %t0, 0
  br i1 %t1, label %neg_bb, label %nonneg_bb

neg_bb:
  %t2 = sext i8 %t0 to i16
  %t3 = sub i16 0, %t2
  ret i16 %t3

nonneg_bb:
  ret i16 0
}
define i16 @negation_of_signext_of_nonnegative__wrong_cast(i8 %x) {
; CHECK-LABEL: @negation_of_signext_of_nonnegative__wrong_cast(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[X:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = icmp sgt i8 [[T0]], -1
; CHECK-NEXT:    br i1 [[T1]], label [[NONNEG_BB:%.*]], label [[NEG_BB:%.*]]
; CHECK:       nonneg_bb:
; CHECK-NEXT:    [[T2:%.*]] = sext i8 [[T0]] to i16
; CHECK-NEXT:    [[T3:%.*]] = sub nsw i16 0, [[T2]]
; CHECK-NEXT:    ret i16 [[T3]]
; CHECK:       neg_bb:
; CHECK-NEXT:    ret i16 0
;
  %t0 = sub i8 0, %x
  %t1 = icmp sge i8 %t0, 0
  br i1 %t1, label %nonneg_bb, label %neg_bb

nonneg_bb:
  %t2 = sext i8 %t0 to i16
  %t3 = sub i16 0, %t2
  ret i16 %t3

neg_bb:
  ret i16 0
}
define i16 @negation_of_zeroext_of_negative_wrongcast(i8 %x) {
; CHECK-LABEL: @negation_of_zeroext_of_negative_wrongcast(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[X:%.*]]
; CHECK-NEXT:    [[T1:%.*]] = icmp slt i8 [[T0]], 0
; CHECK-NEXT:    br i1 [[T1]], label [[NEG_BB:%.*]], label [[NONNEG_BB:%.*]]
; CHECK:       neg_bb:
; CHECK-NEXT:    [[T2:%.*]] = zext i8 [[T0]] to i16
; CHECK-NEXT:    [[T3:%.*]] = sub nsw i16 0, [[T2]]
; CHECK-NEXT:    ret i16 [[T3]]
; CHECK:       nonneg_bb:
; CHECK-NEXT:    ret i16 0
;
  %t0 = sub i8 0, %x
  %t1 = icmp slt i8 %t0, 0
  br i1 %t1, label %neg_bb, label %nonneg_bb

neg_bb:
  %t2 = zext i8 %t0 to i16
  %t3 = sub i16 0, %t2
  ret i16 %t3

nonneg_bb:
  ret i16 0
}

; 'or' of 1 and operand with no lowest bit set is 'inc'
define i8 @negation_of_increment_via_or_with_no_common_bits_set(i8 %x, i8 %y) {
; CHECK-LABEL: @negation_of_increment_via_or_with_no_common_bits_set(
; CHECK-NEXT:    [[T0:%.*]] = shl i8 [[Y:%.*]], 1
; CHECK-NEXT:    [[T1_NEG:%.*]] = xor i8 [[T0]], -1
; CHECK-NEXT:    [[T2:%.*]] = add i8 [[T1_NEG]], [[X:%.*]]
; CHECK-NEXT:    ret i8 [[T2]]
;
  %t0 = shl i8 %y, 1
  %t1 = or i8 %t0, 1
  %t2 = sub i8 %x, %t1
  ret i8 %t2
}
define i8 @negation_of_increment_via_or_with_no_common_bits_set_extrause(i8 %x, i8 %y) {
; CHECK-LABEL: @negation_of_increment_via_or_with_no_common_bits_set_extrause(
; CHECK-NEXT:    [[T0:%.*]] = shl i8 [[Y:%.*]], 1
; CHECK-NEXT:    [[T1:%.*]] = or i8 [[T0]], 1
; CHECK-NEXT:    call void @use8(i8 [[T1]])
; CHECK-NEXT:    [[T2:%.*]] = sub i8 [[X:%.*]], [[T1]]
; CHECK-NEXT:    ret i8 [[T2]]
;
  %t0 = shl i8 %y, 1
  %t1 = or i8 %t0, 1
  call void @use8(i8 %t1)
  %t2 = sub i8 %x, %t1
  ret i8 %t2
}
define i8 @negation_of_increment_via_or_common_bits_set(i8 %x, i8 %y) {
; CHECK-LABEL: @negation_of_increment_via_or_common_bits_set(
; CHECK-NEXT:    [[T0:%.*]] = shl i8 [[Y:%.*]], 1
; CHECK-NEXT:    [[T1:%.*]] = or i8 [[T0]], 3
; CHECK-NEXT:    [[T2:%.*]] = sub i8 [[X:%.*]], [[T1]]
; CHECK-NEXT:    ret i8 [[T2]]
;
  %t0 = shl i8 %y, 1
  %t1 = or i8 %t0, 3
  %t2 = sub i8 %x, %t1
  ret i8 %t2
}

; 'or' of operands with no common bits set is 'add'
define i8 @add_via_or_with_no_common_bits_set(i8 %x, i8 %y) {
; CHECK-LABEL: @add_via_or_with_no_common_bits_set(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[Y:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1_NEG:%.*]] = shl i8 [[Y]], 2
; CHECK-NEXT:    [[T2_NEG:%.*]] = add i8 [[T1_NEG]], -3
; CHECK-NEXT:    [[T3:%.*]] = add i8 [[T2_NEG]], [[X:%.*]]
; CHECK-NEXT:    ret i8 [[T3]]
;
  %t0 = sub i8 0, %y
  call void @use8(i8 %t0)
  %t1 = shl i8 %t0, 2
  %t2 = or i8 %t1, 3
  %t3 = sub i8 %x, %t2
  ret i8 %t3
}
define i8 @add_via_or_with_common_bit_maybe_set(i8 %x, i8 %y) {
; CHECK-LABEL: @add_via_or_with_common_bit_maybe_set(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[Y:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = shl i8 [[T0]], 2
; CHECK-NEXT:    [[T2:%.*]] = or i8 [[T1]], 4
; CHECK-NEXT:    [[T3:%.*]] = sub i8 [[X:%.*]], [[T2]]
; CHECK-NEXT:    ret i8 [[T3]]
;
  %t0 = sub i8 0, %y
  call void @use8(i8 %t0)
  %t1 = shl i8 %t0, 2
  %t2 = or i8 %t1, 4
  %t3 = sub i8 %x, %t2
  ret i8 %t3
}
define i8 @add_via_or_with_no_common_bits_set_extrause(i8 %x, i8 %y) {
; CHECK-LABEL: @add_via_or_with_no_common_bits_set_extrause(
; CHECK-NEXT:    [[T0:%.*]] = sub i8 0, [[Y:%.*]]
; CHECK-NEXT:    call void @use8(i8 [[T0]])
; CHECK-NEXT:    [[T1:%.*]] = shl i8 [[T0]], 2
; CHECK-NEXT:    [[T2:%.*]] = or i8 [[T1]], 3
; CHECK-NEXT:    call void @use8(i8 [[T2]])
; CHECK-NEXT:    [[T3:%.*]] = sub i8 [[X:%.*]], [[T2]]
; CHECK-NEXT:    ret i8 [[T3]]
;
  %t0 = sub i8 0, %y
  call void @use8(i8 %t0)
  %t1 = shl i8 %t0, 2
  %t2 = or i8 %t1, 3
  call void @use8(i8 %t2)
  %t3 = sub i8 %x, %t2
  ret i8 %t3
}
