; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -aggressive-instcombine -S | FileCheck %s

; PR37098 - https://bugs.llvm.org/show_bug.cgi?id=37098

define i32 @anyset_two_bit_mask(i32 %x) {
; CHECK-LABEL: @anyset_two_bit_mask(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[X:%.*]], 9
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i32 [[TMP1]], 0
; CHECK-NEXT:    [[TMP3:%.*]] = zext i1 [[TMP2]] to i32
; CHECK-NEXT:    ret i32 [[TMP3]]
;
  %s = lshr i32 %x, 3
  %o = or i32 %s, %x
  %r = and i32 %o, 1
  ret i32 %r
}

define <2 x i32> @anyset_two_bit_mask_uniform(<2 x i32> %x) {
; CHECK-LABEL: @anyset_two_bit_mask_uniform(
; CHECK-NEXT:    [[S:%.*]] = lshr <2 x i32> [[X:%.*]], <i32 3, i32 3>
; CHECK-NEXT:    [[O:%.*]] = or <2 x i32> [[S]], [[X]]
; CHECK-NEXT:    [[R:%.*]] = and <2 x i32> [[O]], <i32 1, i32 1>
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %s = lshr <2 x i32> %x, <i32 3, i32 3>
  %o = or <2 x i32> %s, %x
  %r = and <2 x i32> %o, <i32 1, i32 1>
  ret <2 x i32> %r
}

define i32 @anyset_four_bit_mask(i32 %x) {
; CHECK-LABEL: @anyset_four_bit_mask(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[X:%.*]], 297
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i32 [[TMP1]], 0
; CHECK-NEXT:    [[TMP3:%.*]] = zext i1 [[TMP2]] to i32
; CHECK-NEXT:    ret i32 [[TMP3]]
;
  %t1 = lshr i32 %x, 3
  %t2 = lshr i32 %x, 5
  %t3 = lshr i32 %x, 8
  %o1 = or i32 %t1, %x
  %o2 = or i32 %t2, %t3
  %o3 = or i32 %o1, %o2
  %r = and i32 %o3, 1
  ret i32 %r
}

define <2 x i32> @anyset_four_bit_mask_uniform(<2 x i32> %x) {
; CHECK-LABEL: @anyset_four_bit_mask_uniform(
; CHECK-NEXT:    [[T1:%.*]] = lshr <2 x i32> [[X:%.*]], <i32 3, i32 3>
; CHECK-NEXT:    [[T2:%.*]] = lshr <2 x i32> [[X]], <i32 5, i32 5>
; CHECK-NEXT:    [[T3:%.*]] = lshr <2 x i32> [[X]], <i32 8, i32 8>
; CHECK-NEXT:    [[O1:%.*]] = or <2 x i32> [[T1]], [[X]]
; CHECK-NEXT:    [[O2:%.*]] = or <2 x i32> [[T2]], [[T3]]
; CHECK-NEXT:    [[O3:%.*]] = or <2 x i32> [[O1]], [[O2]]
; CHECK-NEXT:    [[R:%.*]] = and <2 x i32> [[O3]], <i32 1, i32 1>
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %t1 = lshr <2 x i32> %x, <i32 3, i32 3>
  %t2 = lshr <2 x i32> %x, <i32 5, i32 5>
  %t3 = lshr <2 x i32> %x, <i32 8, i32 8>
  %o1 = or <2 x i32> %t1, %x
  %o2 = or <2 x i32> %t2, %t3
  %o3 = or <2 x i32> %o1, %o2
  %r = and <2 x i32> %o3, <i32 1, i32 1>
  ret <2 x i32> %r
}

; We're not testing the LSB here, so all of the 'or' operands are shifts.

define i32 @anyset_three_bit_mask_all_shifted_bits(i32 %x) {
; CHECK-LABEL: @anyset_three_bit_mask_all_shifted_bits(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[X:%.*]], 296
; CHECK-NEXT:    [[TMP2:%.*]] = icmp ne i32 [[TMP1]], 0
; CHECK-NEXT:    [[TMP3:%.*]] = zext i1 [[TMP2]] to i32
; CHECK-NEXT:    ret i32 [[TMP3]]
;
  %t1 = lshr i32 %x, 3
  %t2 = lshr i32 %x, 5
  %t3 = lshr i32 %x, 8
  %o2 = or i32 %t2, %t3
  %o3 = or i32 %t1, %o2
  %r = and i32 %o3, 1
  ret i32 %r
}

define <2 x i32> @anyset_three_bit_mask_all_shifted_bits_uniform(<2 x i32> %x) {
; CHECK-LABEL: @anyset_three_bit_mask_all_shifted_bits_uniform(
; CHECK-NEXT:    [[T1:%.*]] = lshr <2 x i32> [[X:%.*]], <i32 3, i32 3>
; CHECK-NEXT:    [[T2:%.*]] = lshr <2 x i32> [[X]], <i32 5, i32 5>
; CHECK-NEXT:    [[T3:%.*]] = lshr <2 x i32> [[X]], <i32 8, i32 8>
; CHECK-NEXT:    [[O2:%.*]] = or <2 x i32> [[T2]], [[T3]]
; CHECK-NEXT:    [[O3:%.*]] = or <2 x i32> [[T1]], [[O2]]
; CHECK-NEXT:    [[R:%.*]] = and <2 x i32> [[O3]], <i32 1, i32 1>
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %t1 = lshr <2 x i32> %x, <i32 3, i32 3>
  %t2 = lshr <2 x i32> %x, <i32 5, i32 5>
  %t3 = lshr <2 x i32> %x, <i32 8, i32 8>
  %o2 = or <2 x i32> %t2, %t3
  %o3 = or <2 x i32> %t1, %o2
  %r = and <2 x i32> %o3, <i32 1, i32 1>
  ret <2 x i32> %r
}

; Recognize the 'and' sibling pattern (all-bits-set). The 'and 1' may not be at the end.

define i32 @allset_two_bit_mask(i32 %x) {
; CHECK-LABEL: @allset_two_bit_mask(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[X:%.*]], 129
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 129
; CHECK-NEXT:    [[TMP3:%.*]] = zext i1 [[TMP2]] to i32
; CHECK-NEXT:    ret i32 [[TMP3]]
;
  %s = lshr i32 %x, 7
  %o = and i32 %s, %x
  %r = and i32 %o, 1
  ret i32 %r
}

define <2 x i32> @allset_two_bit_mask_uniform(<2 x i32> %x) {
; CHECK-LABEL: @allset_two_bit_mask_uniform(
; CHECK-NEXT:    [[S:%.*]] = lshr <2 x i32> [[X:%.*]], <i32 7, i32 7>
; CHECK-NEXT:    [[O:%.*]] = and <2 x i32> [[S]], [[X]]
; CHECK-NEXT:    [[R:%.*]] = and <2 x i32> [[O]], <i32 1, i32 1>
; CHECK-NEXT:    ret <2 x i32> [[R]]
;
  %s = lshr <2 x i32> %x, <i32 7, i32 7>
  %o = and <2 x i32> %s, %x
  %r = and <2 x i32> %o, <i32 1, i32 1>
  ret <2 x i32> %r
}

define i64 @allset_four_bit_mask(i64 %x) {
; CHECK-LABEL: @allset_four_bit_mask(
; CHECK-NEXT:    [[TMP1:%.*]] = and i64 [[X:%.*]], 30
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP1]], 30
; CHECK-NEXT:    [[TMP3:%.*]] = zext i1 [[TMP2]] to i64
; CHECK-NEXT:    ret i64 [[TMP3]]
;
  %t1 = lshr i64 %x, 1
  %t2 = lshr i64 %x, 2
  %t3 = lshr i64 %x, 3
  %t4 = lshr i64 %x, 4
  %a1 = and i64 %t4, 1
  %a2 = and i64 %t2, %a1
  %a3 = and i64 %a2, %t1
  %r = and i64 %a3, %t3
  ret i64 %r
}

declare void @use(i32)

; negative test - extra use means the transform would increase instruction count

define i32 @allset_two_bit_mask_multiuse(i32 %x) {
; CHECK-LABEL: @allset_two_bit_mask_multiuse(
; CHECK-NEXT:    [[S:%.*]] = lshr i32 [[X:%.*]], 7
; CHECK-NEXT:    [[O:%.*]] = and i32 [[S]], [[X]]
; CHECK-NEXT:    [[R:%.*]] = and i32 [[O]], 1
; CHECK-NEXT:    call void @use(i32 [[O]])
; CHECK-NEXT:    ret i32 [[R]]
;
  %s = lshr i32 %x, 7
  %o = and i32 %s, %x
  %r = and i32 %o, 1
  call void @use(i32 %o)
  ret i32 %r
}

; negative test - missing 'and 1' mask, so more than the low bit is used here

define i8 @allset_three_bit_mask_no_and1(i8 %x) {
; CHECK-LABEL: @allset_three_bit_mask_no_and1(
; CHECK-NEXT:    [[T1:%.*]] = lshr i8 [[X:%.*]], 1
; CHECK-NEXT:    [[T2:%.*]] = lshr i8 [[X]], 2
; CHECK-NEXT:    [[T3:%.*]] = lshr i8 [[X]], 3
; CHECK-NEXT:    [[A2:%.*]] = and i8 [[T1]], [[T2]]
; CHECK-NEXT:    [[R:%.*]] = and i8 [[A2]], [[T3]]
; CHECK-NEXT:    ret i8 [[R]]
;
  %t1 = lshr i8 %x, 1
  %t2 = lshr i8 %x, 2
  %t3 = lshr i8 %x, 3
  %a2 = and i8 %t1, %t2
  %r = and i8 %a2, %t3
  ret i8 %r
}

; This test demonstrates that the transform can be large. If the implementation
; is slow or explosive (stack overflow due to recursion), it should be made efficient.

define i64 @allset_40_bit_mask(i64 %x) {
; CHECK-LABEL: @allset_40_bit_mask(
; CHECK-NEXT:    [[TMP1:%.*]] = and i64 [[X:%.*]], 2199023255550
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i64 [[TMP1]], 2199023255550
; CHECK-NEXT:    [[TMP3:%.*]] = zext i1 [[TMP2]] to i64
; CHECK-NEXT:    ret i64 [[TMP3]]
;
  %t1 = lshr i64 %x, 1
  %t2 = lshr i64 %x, 2
  %t3 = lshr i64 %x, 3
  %t4 = lshr i64 %x, 4
  %t5 = lshr i64 %x, 5
  %t6 = lshr i64 %x, 6
  %t7 = lshr i64 %x, 7
  %t8 = lshr i64 %x, 8
  %t9 = lshr i64 %x, 9
  %t10 = lshr i64 %x, 10
  %t11 = lshr i64 %x, 11
  %t12 = lshr i64 %x, 12
  %t13 = lshr i64 %x, 13
  %t14 = lshr i64 %x, 14
  %t15 = lshr i64 %x, 15
  %t16 = lshr i64 %x, 16
  %t17 = lshr i64 %x, 17
  %t18 = lshr i64 %x, 18
  %t19 = lshr i64 %x, 19
  %t20 = lshr i64 %x, 20
  %t21 = lshr i64 %x, 21
  %t22 = lshr i64 %x, 22
  %t23 = lshr i64 %x, 23
  %t24 = lshr i64 %x, 24
  %t25 = lshr i64 %x, 25
  %t26 = lshr i64 %x, 26
  %t27 = lshr i64 %x, 27
  %t28 = lshr i64 %x, 28
  %t29 = lshr i64 %x, 29
  %t30 = lshr i64 %x, 30
  %t31 = lshr i64 %x, 31
  %t32 = lshr i64 %x, 32
  %t33 = lshr i64 %x, 33
  %t34 = lshr i64 %x, 34
  %t35 = lshr i64 %x, 35
  %t36 = lshr i64 %x, 36
  %t37 = lshr i64 %x, 37
  %t38 = lshr i64 %x, 38
  %t39 = lshr i64 %x, 39
  %t40 = lshr i64 %x, 40

  %a1 = and i64 %t1, 1
  %a2 = and i64 %t2, %a1
  %a3 = and i64 %t3, %a2
  %a4 = and i64 %t4, %a3
  %a5 = and i64 %t5, %a4
  %a6 = and i64 %t6, %a5
  %a7 = and i64 %t7, %a6
  %a8 = and i64 %t8, %a7
  %a9 = and i64 %t9, %a8
  %a10 = and i64 %t10, %a9
  %a11 = and i64 %t11, %a10
  %a12 = and i64 %t12, %a11
  %a13 = and i64 %t13, %a12
  %a14 = and i64 %t14, %a13
  %a15 = and i64 %t15, %a14
  %a16 = and i64 %t16, %a15
  %a17 = and i64 %t17, %a16
  %a18 = and i64 %t18, %a17
  %a19 = and i64 %t19, %a18
  %a20 = and i64 %t20, %a19
  %a21 = and i64 %t21, %a20
  %a22 = and i64 %t22, %a21
  %a23 = and i64 %t23, %a22
  %a24 = and i64 %t24, %a23
  %a25 = and i64 %t25, %a24
  %a26 = and i64 %t26, %a25
  %a27 = and i64 %t27, %a26
  %a28 = and i64 %t28, %a27
  %a29 = and i64 %t29, %a28
  %a30 = and i64 %t30, %a29
  %a31 = and i64 %t31, %a30
  %a32 = and i64 %t32, %a31
  %a33 = and i64 %t33, %a32
  %a34 = and i64 %t34, %a33
  %a35 = and i64 %t35, %a34
  %a36 = and i64 %t36, %a35
  %a37 = and i64 %t37, %a36
  %a38 = and i64 %t38, %a37
  %a39 = and i64 %t39, %a38
  %a40 = and i64 %t40, %a39

  ret i64 %a40
}

; Verify that unsimplified code doesn't crash:
; https://bugs.llvm.org/show_bug.cgi?id=37446

define i32 @PR37446(i32 %x) {
; CHECK-LABEL: @PR37446(
; CHECK-NEXT:    [[SHR:%.*]] = lshr i32 1, 33
; CHECK-NEXT:    [[AND:%.*]] = and i32 [[SHR]], 15
; CHECK-NEXT:    [[AND1:%.*]] = and i32 [[AND]], [[X:%.*]]
; CHECK-NEXT:    ret i32 [[AND1]]
;
  %shr = lshr i32 1, 33
  %and = and i32 %shr, 15
  %and1 = and i32 %and, %x
  ret i32 %and1
}

