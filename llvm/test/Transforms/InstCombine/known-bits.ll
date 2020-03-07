; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -instcombine -expensive-combines=0 < %s | FileCheck %s --check-prefixes=CHECK,EXPENSIVE-OFF
; RUN: opt -S -instcombine -expensive-combines=1 < %s | FileCheck %s --check-prefixes=CHECK,EXPENSIVE-ON

define void @test_shl(i1 %x) {
; CHECK-LABEL: @test_shl(
; CHECK-NEXT:    call void @sink(i8 0)
; CHECK-NEXT:    ret void
;
  %y = zext i1 %x to i8
  %z = shl i8 64, %y
  %a = and i8 %z, 1
  call void @sink(i8 %a)
  ret void
}

define void @test_lshr(i1 %x) {
; CHECK-LABEL: @test_lshr(
; CHECK-NEXT:    call void @sink(i8 0)
; CHECK-NEXT:    ret void
;
  %y = zext i1 %x to i8
  %z = lshr i8 64, %y
  %a = and i8 %z, 1
  call void @sink(i8 %a)
  ret void
}

define void @test_ashr(i1 %x) {
; CHECK-LABEL: @test_ashr(
; CHECK-NEXT:    call void @sink(i8 0)
; CHECK-NEXT:    ret void
;
  %y = zext i1 %x to i8
  %z = ashr i8 -16, %y
  %a = and i8 %z, 3
  call void @sink(i8 %a)
  ret void
}

define void @test_udiv(i8 %x) {
; CHECK-LABEL: @test_udiv(
; CHECK-NEXT:    call void @sink(i8 0)
; CHECK-NEXT:    ret void
;
  %y = udiv i8 10, %x
  %z = and i8 %y, 64
  call void @sink(i8 %z)
  ret void
}

declare void @sink(i8)
