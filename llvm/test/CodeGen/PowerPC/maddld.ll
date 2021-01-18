; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -mcpu=pwr9 -mtriple=powerpc64le-unknown-linux-gnu < %s | FileCheck %s --check-prefix=CHECK-P9
; RUN: llc -verify-machineinstrs -mcpu=pwr8 -mtriple=powerpc64-unknown-linux-gnu < %s | FileCheck %s --check-prefix=CHECK-P8
; RUN: llc -verify-machineinstrs -mcpu=pwr8 -mtriple=powerpc64-ibm-aix-xcoff -vec-extabi < %s | FileCheck %s --check-prefix=CHECK-P8

define signext i64 @maddld64(i64 signext %a, i64 signext %b) {
; CHECK-P9-LABEL: maddld64:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    maddld 3, 4, 3, 3
; CHECK-P9-NEXT:    blr
;
; CHECK-P8-LABEL: maddld64:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mulld 4, 4, 3
; CHECK-P8-NEXT:    add 3, 4, 3
; CHECK-P8-NEXT:    blr

entry:
  %mul = mul i64 %b, %a
  %add = add i64 %mul, %a
  ret i64 %add
}

define signext i32 @maddld32(i32 signext %a, i32 signext %b) {
; CHECK-P9-LABEL: maddld32:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    maddld 3, 4, 3, 3
; CHECK-P9-NEXT:    extsw 3, 3
; CHECK-P9-NEXT:    blr
;
; CHECK-P8-LABEL: maddld32:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mullw 4, 4, 3
; CHECK-P8-NEXT:    add 3, 4, 3
; CHECK-P8-NEXT:    extsw 3, 3
; CHECK-P8-NEXT:    blr

entry:
  %mul = mul i32 %b, %a
  %add = add i32 %mul, %a
  ret i32 %add
}

define signext i16 @maddld16(i16 signext %a, i16 signext %b, i16 signext %c) {
; CHECK-P9-LABEL: maddld16:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    maddld 3, 4, 3, 5
; CHECK-P9-NEXT:    extsh 3, 3
; CHECK-P9-NEXT:    blr
;
; CHECK-P8-LABEL: maddld16:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mullw 3, 4, 3
; CHECK-P8-NEXT:    add 3, 3, 5
; CHECK-P8-NEXT:    extsh 3, 3
; CHECK-P8-NEXT:    blr

entry:
  %mul = mul i16 %b, %a
  %add = add i16 %mul, %c
  ret i16 %add
}

define zeroext i32 @maddld32zeroext(i32 zeroext %a, i32 zeroext %b) {
; CHECK-P9-LABEL: maddld32zeroext:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    maddld 3, 4, 3, 3
; CHECK-P9-NEXT:    clrldi 3, 3, 32
; CHECK-P9-NEXT:    blr
;
; CHECK-P8-LABEL: maddld32zeroext:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mullw 4, 4, 3
; CHECK-P8-NEXT:    add 3, 4, 3
; CHECK-P8-NEXT:    clrldi 3, 3, 32
; CHECK-P8-NEXT:    blr

entry:
  %mul = mul i32 %b, %a
  %add = add i32 %mul, %a
  ret i32 %add
}

define signext i32 @maddld32nsw(i32 signext %a, i32 signext %b) {
; CHECK-P9-LABEL: maddld32nsw:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    maddld 3, 4, 3, 3
; CHECK-P9-NEXT:    extsw 3, 3
; CHECK-P9-NEXT:    blr
;
; CHECK-P8-LABEL: maddld32nsw:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mullw 4, 4, 3
; CHECK-P8-NEXT:    add 3, 4, 3
; CHECK-P8-NEXT:    extsw 3, 3
; CHECK-P8-NEXT:    blr

entry:
  %mul = mul nsw i32 %b, %a
  %add = add nsw i32 %mul, %a
  ret i32 %add
}

define zeroext i32 @maddld32nuw(i32 zeroext %a, i32 zeroext %b) {
; CHECK-P9-LABEL: maddld32nuw:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    maddld 3, 4, 3, 3
; CHECK-P9-NEXT:    clrldi 3, 3, 32
; CHECK-P9-NEXT:    blr
;
; CHECK-P8-LABEL: maddld32nuw:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mullw 4, 4, 3
; CHECK-P8-NEXT:    add 3, 4, 3
; CHECK-P8-NEXT:    clrldi 3, 3, 32
; CHECK-P8-NEXT:    blr

entry:
  %mul = mul nuw i32 %b, %a
  %add = add nuw i32 %mul, %a
  ret i32 %add
}

define signext i64 @maddld64_imm(i64 signext %a, i64 signext %b) {
; CHECK-P9-LABEL: maddld64_imm:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    mulli 4, 4, 13
; CHECK-P9-NEXT:    add 3, 4, 3
; CHECK-P9-NEXT:    blr
;
; CHECK-P8-LABEL: maddld64_imm:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mulli 4, 4, 13
; CHECK-P8-NEXT:    add 3, 4, 3
; CHECK-P8-NEXT:    blr
entry:
  %mul = mul i64 %b, 13
  %add = add i64 %mul, %a
  ret i64 %add
}

define signext i32 @maddld32_imm(i32 signext %a, i32 signext %b) {
; CHECK-P9-LABEL: maddld32_imm:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    mullw 3, 4, 3
; CHECK-P9-NEXT:    addi 3, 3, 13
; CHECK-P9-NEXT:    extsw 3, 3
; CHECK-P9-NEXT:    blr
;
; CHECK-P8-LABEL: maddld32_imm:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mullw 3, 4, 3
; CHECK-P8-NEXT:    addi 3, 3, 13
; CHECK-P8-NEXT:    extsw 3, 3
; CHECK-P8-NEXT:    blr
entry:
  %mul = mul i32 %b, %a
  %add = add i32 %mul, 13
  ret i32 %add
}

define signext i16 @maddld16_imm(i16 signext %a, i16 signext %b, i16 signext %c) {
; CHECK-P9-LABEL: maddld16_imm:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    mulli 3, 4, 13
; CHECK-P9-NEXT:    add 3, 3, 5
; CHECK-P9-NEXT:    extsh 3, 3
; CHECK-P9-NEXT:    blr
;
; CHECK-P8-LABEL: maddld16_imm:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mulli 3, 4, 13
; CHECK-P8-NEXT:    add 3, 3, 5
; CHECK-P8-NEXT:    extsh 3, 3
; CHECK-P8-NEXT:    blr
entry:
  %mul = mul i16 %b, 13
  %add = add i16 %mul, %c
  ret i16 %add
}

define zeroext i32 @maddld32zeroext_imm(i32 zeroext %a, i32 zeroext %b) {
; CHECK-P9-LABEL: maddld32zeroext_imm:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    mullw 3, 4, 3
; CHECK-P9-NEXT:    addi 3, 3, 13
; CHECK-P9-NEXT:    clrldi 3, 3, 32
; CHECK-P9-NEXT:    blr
;
; CHECK-P8-LABEL: maddld32zeroext_imm:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mullw 3, 4, 3
; CHECK-P8-NEXT:    addi 3, 3, 13
; CHECK-P8-NEXT:    clrldi 3, 3, 32
; CHECK-P8-NEXT:    blr
entry:
  %mul = mul i32 %b, %a
  %add = add i32 %mul, 13
  ret i32 %add
}

define signext i32 @maddld32nsw_imm(i32 signext %a, i32 signext %b) {
; CHECK-P9-LABEL: maddld32nsw_imm:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    mulli 4, 4, 13
; CHECK-P9-NEXT:    add 3, 4, 3
; CHECK-P9-NEXT:    extsw 3, 3
; CHECK-P9-NEXT:    blr
;
; CHECK-P8-LABEL: maddld32nsw_imm:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mulli 4, 4, 13
; CHECK-P8-NEXT:    add 3, 4, 3
; CHECK-P8-NEXT:    extsw 3, 3
; CHECK-P8-NEXT:    blr
entry:
  %mul = mul nsw i32 %b, 13
  %add = add nsw i32 %mul, %a
  ret i32 %add
}

define zeroext i32 @maddld32nuw_imm(i32 zeroext %a, i32 zeroext %b) {
; CHECK-P9-LABEL: maddld32nuw_imm:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    mullw 3, 4, 3
; CHECK-P9-NEXT:    addi 3, 3, 13
; CHECK-P9-NEXT:    clrldi 3, 3, 32
; CHECK-P9-NEXT:    blr
;
; CHECK-P8-LABEL: maddld32nuw_imm:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mullw 3, 4, 3
; CHECK-P8-NEXT:    addi 3, 3, 13
; CHECK-P8-NEXT:    clrldi 3, 3, 32
; CHECK-P8-NEXT:    blr
entry:
  %mul = mul nuw i32 %b, %a
  %add = add nuw i32 %mul, 13
  ret i32 %add
}

define zeroext i32 @maddld32nuw_imm_imm(i32 zeroext %b) {
; CHECK-P9-LABEL: maddld32nuw_imm_imm:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    mulli 3, 3, 18
; CHECK-P9-NEXT:    addi 3, 3, 13
; CHECK-P9-NEXT:    clrldi 3, 3, 32
; CHECK-P9-NEXT:    blr
;
; CHECK-P8-LABEL: maddld32nuw_imm_imm:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    mulli 3, 3, 18
; CHECK-P8-NEXT:    addi 3, 3, 13
; CHECK-P8-NEXT:    clrldi 3, 3, 32
; CHECK-P8-NEXT:    blr
entry:
  %mul = mul nuw i32 %b, 18
  %add = add nuw i32 %mul, 13
  ret i32 %add
}

define zeroext i32 @maddld32nuw_bigimm_imm(i32 zeroext %b) {
; CHECK-P9-LABEL: maddld32nuw_bigimm_imm:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    lis 4, 26127
; CHECK-P9-NEXT:    ori 4, 4, 63251
; CHECK-P9-NEXT:    mullw 3, 3, 4
; CHECK-P9-NEXT:    addi 3, 3, 13
; CHECK-P9-NEXT:    clrldi 3, 3, 32
; CHECK-P9-NEXT:    blr
;
; CHECK-P8-LABEL: maddld32nuw_bigimm_imm:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    lis 4, 26127
; CHECK-P8-NEXT:    ori 4, 4, 63251
; CHECK-P8-NEXT:    mullw 3, 3, 4
; CHECK-P8-NEXT:    addi 3, 3, 13
; CHECK-P8-NEXT:    clrldi 3, 3, 32
; CHECK-P8-NEXT:    blr
entry:
  %mul = mul nuw i32 %b, 1712322323
  %add = add nuw i32 %mul, 13
  ret i32 %add
}

define zeroext i32 @maddld32nuw_bigimm_bigimm(i32 zeroext %b) {
; CHECK-P9-LABEL: maddld32nuw_bigimm_bigimm:
; CHECK-P9:       # %bb.0: # %entry
; CHECK-P9-NEXT:    lis 4, -865
; CHECK-P9-NEXT:    lis 5, 26127
; CHECK-P9-NEXT:    ori 4, 4, 42779
; CHECK-P9-NEXT:    ori 5, 5, 63251
; CHECK-P9-NEXT:    maddld 3, 3, 5, 4
; CHECK-P9-NEXT:    clrldi 3, 3, 32
; CHECK-P9-NEXT:    blr
;
; CHECK-P8-LABEL: maddld32nuw_bigimm_bigimm:
; CHECK-P8:       # %bb.0: # %entry
; CHECK-P8-NEXT:    lis 4, 26127
; CHECK-P8-NEXT:    ori 4, 4, 63251
; CHECK-P8-NEXT:    mullw 3, 3, 4
; CHECK-P8-NEXT:    addi 3, 3, -22757
; CHECK-P8-NEXT:    addis 3, 3, -864
; CHECK-P8-NEXT:    clrldi 3, 3, 32
; CHECK-P8-NEXT:    blr



entry:
  %mul = mul nuw i32 %b, 1712322323
  %add = add nuw i32 %mul, 17123223323
  ret i32 %add
}
