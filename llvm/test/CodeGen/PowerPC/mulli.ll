; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --extra_scrub
; RUN: llc -verify-machineinstrs -mcpu=pwr9 -mtriple=powerpc64le-unknown-linux-gnu < %s | FileCheck %s

define i64 @test1(i64 %x) {
; CHECK-LABEL: test1:
; CHECK:       # %bb.0:
; CHECK-NEXT:    li 4, 625
; CHECK-NEXT:    sldi 4, 4, 36
; CHECK-NEXT:    mulld 3, 3, 4
; CHECK-NEXT:    blr
  %y = mul i64 %x, 42949672960000
  ret i64 %y
}

define i64 @test2(i64 %x) {
; CHECK-LABEL: test2:
; CHECK:       # %bb.0:
; CHECK-NEXT:    li 4, -625
; CHECK-NEXT:    sldi 4, 4, 36
; CHECK-NEXT:    mulld 3, 3, 4
; CHECK-NEXT:    blr
  %y = mul i64 %x, -42949672960000
  ret i64 %y
}

define i64 @test3(i64 %x) {
; CHECK-LABEL: test3:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lis 4, 74
; CHECK-NEXT:    ori 4, 4, 16384
; CHECK-NEXT:    mulld 3, 3, 4
; CHECK-NEXT:    blr
  %y = mul i64 %x, 4866048
  ret i64 %y
}

define i64 @test4(i64 %x) {
; CHECK-LABEL: test4:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lis 4, -75
; CHECK-NEXT:    ori 4, 4, 49152
; CHECK-NEXT:    mulld 3, 3, 4
; CHECK-NEXT:    blr
  %y = mul i64 %x, -4866048
  ret i64 %y
}

define i64 @test5(i64 %x) {
; CHECK-LABEL: test5:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lis 4, 16
; CHECK-NEXT:    ori 4, 4, 1
; CHECK-NEXT:    sldi 4, 4, 12
; CHECK-NEXT:    mulld 3, 3, 4
; CHECK-NEXT:    blr
  %y = mul i64 %x, 4294971392
  ret i64 %y
}

define i64 @test6(i64 %x) {
; CHECK-LABEL: test6:
; CHECK:       # %bb.0:
; CHECK-NEXT:    lis 4, -17
; CHECK-NEXT:    ori 4, 4, 65535
; CHECK-NEXT:    sldi 4, 4, 12
; CHECK-NEXT:    mulld 3, 3, 4
; CHECK-NEXT:    blr
  %y = mul i64 %x, -4294971392
  ret i64 %y
}
