; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -mtriple=powerpc64le-unknown-linux-gnu -O2 \
; RUN:     -ppc-asm-full-reg-names -mcpu=pwr10 < %s | FileCheck %s \
; RUN:     --check-prefixes=CHECK,CHECK-LE
; RUN: llc -verify-machineinstrs -mtriple=powerpc64-unknown-linux-gnu -O2 \
; RUN:     -ppc-asm-full-reg-names -mcpu=pwr10 < %s | FileCheck %s \
; RUN:     --check-prefixes=CHECK,CHECK-BE

; This file does not contain many test cases involving comparisons and logical
; comparisons (cmplwi, cmpldi). This is because alternative code is generated
; when there is a compare (logical or not), followed by a sign or zero extend.
; This codegen will be re-evaluated at a later time on whether or not it should
; be emitted on P10.

@globalVal = common local_unnamed_addr global i8 0, align 1
@globalVal2 = common local_unnamed_addr global i32 0, align 4
@globalVal3 = common local_unnamed_addr global i64 0, align 8
@globalVal4 = common local_unnamed_addr global i16 0, align 2

define signext i32 @setnbc1(i8 %a) {
; CHECK-LABEL: setnbc1:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extsb r3, r3
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, lt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i8 %a, 1
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @setnbc2(i32 %a) {
; CHECK-LABEL: setnbc2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, lt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i32 %a, 1
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @setnbc3(i64 %a) {
; CHECK-LABEL: setnbc3:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpdi r3, 1
; CHECK-NEXT:    setnbc r3, lt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i64 %a, 1
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @setnbc4(i16 %a) {
; CHECK-LABEL: setnbc4:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extsh r3, r3
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, lt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i16 %a, 1
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i64 @setnbc5(i8 %a) {
; CHECK-LABEL: setnbc5:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extsb r3, r3
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, lt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i8 %a, 1
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i64 @setnbc6(i32 %a) {
; CHECK-LABEL: setnbc6:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, lt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i32 %a, 1
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i64 @setnbc7(i64 %a) {
; CHECK-LABEL: setnbc7:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpdi r3, 1
; CHECK-NEXT:    setnbc r3, lt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i64 %a, 1
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i64 @setnbc8(i16 %a) {
; CHECK-LABEL: setnbc8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extsh r3, r3
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, lt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i16 %a, 1
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define void @setnbc9(i8 %a) {
; CHECK-LE-LABEL: setnbc9:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    extsb r3, r3
; CHECK-LE-NEXT:    cmpwi r3, 1
; CHECK-LE-NEXT:    setnbc r3, lt
; CHECK-LE-NEXT:    pstb r3, globalVal@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc9:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC0@toc@ha
; CHECK-BE-NEXT:    extsb r3, r3
; CHECK-BE-NEXT:    ld r4, .LC0@toc@l(r4)
; CHECK-BE-NEXT:    cmpwi r3, 1
; CHECK-BE-NEXT:    setnbc r3, lt
; CHECK-BE-NEXT:    stb r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp slt i8 %a, 1
  %conv1 = sext i1 %cmp to i8
  store i8 %conv1, i8* @globalVal, align 1
  ret void
}

define void @setnbc10(i32 %a) {
; CHECK-LE-LABEL: setnbc10:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    cmpwi r3, 1
; CHECK-LE-NEXT:    setnbc r3, lt
; CHECK-LE-NEXT:    pstw r3, globalVal2@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc10:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC1@toc@ha
; CHECK-BE-NEXT:    cmpwi r3, 1
; CHECK-BE-NEXT:    ld r4, .LC1@toc@l(r4)
; CHECK-BE-NEXT:    setnbc r3, lt
; CHECK-BE-NEXT:    stw r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp slt i32 %a, 1
  %conv1 = sext i1 %cmp to i32
  store i32 %conv1, i32* @globalVal2, align 4
  ret void
}

define void @setnbc11(i64 %a) {
; CHECK-LE-LABEL: setnbc11:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    cmpdi r3, 1
; CHECK-LE-NEXT:    setnbc r3, lt
; CHECK-LE-NEXT:    pstd r3, globalVal3@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc11:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC2@toc@ha
; CHECK-BE-NEXT:    cmpdi r3, 1
; CHECK-BE-NEXT:    ld r4, .LC2@toc@l(r4)
; CHECK-BE-NEXT:    setnbc r3, lt
; CHECK-BE-NEXT:    std r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp slt i64 %a, 1
  %conv1 = sext i1 %cmp to i64
  store i64 %conv1, i64* @globalVal3, align 8
  ret void
}

define void @setnbc12(i16 %a) {
; CHECK-LE-LABEL: setnbc12:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    extsh r3, r3
; CHECK-LE-NEXT:    cmpwi r3, 1
; CHECK-LE-NEXT:    setnbc r3, lt
; CHECK-LE-NEXT:    psth r3, globalVal4@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc12:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC3@toc@ha
; CHECK-BE-NEXT:    extsh r3, r3
; CHECK-BE-NEXT:    ld r4, .LC3@toc@l(r4)
; CHECK-BE-NEXT:    cmpwi r3, 1
; CHECK-BE-NEXT:    setnbc r3, lt
; CHECK-BE-NEXT:    sth r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp slt i16 %a, 1
  %conv1 = sext i1 %cmp to i16
  store i16 %conv1, i16* @globalVal4, align 2
  ret void
}

define signext i32 @setnbc13(i8 %a) {
; CHECK-LABEL: setnbc13:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extsb r3, r3
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sgt i8 %a, 1
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @setnbc14(i32 %a) {
; CHECK-LABEL: setnbc14:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sgt i32 %a, 1
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @setnbc15(i64 %a) {
; CHECK-LABEL: setnbc15:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpdi r3, 1
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sgt i64 %a, 1
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @setnbc16(i16 %a) {
; CHECK-LABEL: setnbc16:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extsh r3, r3
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sgt i16 %a, 1
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i64 @setnbc17(i8 %a) {
; CHECK-LABEL: setnbc17:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extsb r3, r3
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sgt i8 %a, 1
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i64 @setnbc18(i32 %a) {
; CHECK-LABEL: setnbc18:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sgt i32 %a, 1
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i64 @setnbc19(i64 %a) {
; CHECK-LABEL: setnbc19:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpdi r3, 1
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sgt i64 %a, 1
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i64 @setnbc20(i16 %a) {
; CHECK-LABEL: setnbc20:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extsh r3, r3
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sgt i16 %a, 1
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define void @setnbc21(i8 %a) {
; CHECK-LE-LABEL: setnbc21:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    extsb r3, r3
; CHECK-LE-NEXT:    cmpwi r3, 1
; CHECK-LE-NEXT:    setnbc r3, gt
; CHECK-LE-NEXT:    pstb r3, globalVal@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc21:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC0@toc@ha
; CHECK-BE-NEXT:    extsb r3, r3
; CHECK-BE-NEXT:    ld r4, .LC0@toc@l(r4)
; CHECK-BE-NEXT:    cmpwi r3, 1
; CHECK-BE-NEXT:    setnbc r3, gt
; CHECK-BE-NEXT:    stb r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp sgt i8 %a, 1
  %conv1 = sext i1 %cmp to i8
  store i8 %conv1, i8* @globalVal, align 1
  ret void
}

define void @setnbc22(i32 %a) {
; CHECK-LE-LABEL: setnbc22:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    cmpwi r3, 1
; CHECK-LE-NEXT:    setnbc r3, gt
; CHECK-LE-NEXT:    pstw r3, globalVal2@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc22:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC1@toc@ha
; CHECK-BE-NEXT:    cmpwi r3, 1
; CHECK-BE-NEXT:    ld r4, .LC1@toc@l(r4)
; CHECK-BE-NEXT:    setnbc r3, gt
; CHECK-BE-NEXT:    stw r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp sgt i32 %a, 1
  %conv1 = sext i1 %cmp to i32
  store i32 %conv1, i32* @globalVal2, align 4
  ret void
}

define void @setnbc23(i64 %a) {
; CHECK-LE-LABEL: setnbc23:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    cmpdi r3, 1
; CHECK-LE-NEXT:    setnbc r3, gt
; CHECK-LE-NEXT:    pstd r3, globalVal3@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc23:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC2@toc@ha
; CHECK-BE-NEXT:    cmpdi r3, 1
; CHECK-BE-NEXT:    ld r4, .LC2@toc@l(r4)
; CHECK-BE-NEXT:    setnbc r3, gt
; CHECK-BE-NEXT:    std r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp sgt i64 %a, 1
  %conv1 = sext i1 %cmp to i64
  store i64 %conv1, i64* @globalVal3, align 8
  ret void
}

define void @setnbc24(i16 %a) {
; CHECK-LE-LABEL: setnbc24:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    extsh r3, r3
; CHECK-LE-NEXT:    cmpwi r3, 1
; CHECK-LE-NEXT:    setnbc r3, gt
; CHECK-LE-NEXT:    psth r3, globalVal4@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc24:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC3@toc@ha
; CHECK-BE-NEXT:    extsh r3, r3
; CHECK-BE-NEXT:    ld r4, .LC3@toc@l(r4)
; CHECK-BE-NEXT:    cmpwi r3, 1
; CHECK-BE-NEXT:    setnbc r3, gt
; CHECK-BE-NEXT:    sth r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp sgt i16 %a, 1
  %conv1 = sext i1 %cmp to i16
  store i16 %conv1, i16* @globalVal4, align 2
  ret void
}

define signext i32 @setnbc25(i8 %a) {
; CHECK-LABEL: setnbc25:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    clrlwi r3, r3, 24
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, eq
; CHECK-NEXT:    blr
entry:
  %cmp = icmp eq i8 %a, 1
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @setnbc26(i32 %a) {
; CHECK-LABEL: setnbc26:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, eq
; CHECK-NEXT:    blr
entry:
  %cmp = icmp eq i32 %a, 1
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @setnbc27(i64 %a) {
; CHECK-LABEL: setnbc27:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpdi r3, 1
; CHECK-NEXT:    setnbc r3, eq
; CHECK-NEXT:    blr
entry:
  %cmp = icmp eq i64 %a, 1
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @setnbc28(i16 %a) {
; CHECK-LABEL: setnbc28:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    clrlwi r3, r3, 16
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, eq
; CHECK-NEXT:    blr
entry:
  %cmp = icmp eq i16 %a, 1
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i64 @setnbc29(i8 %a) {
; CHECK-LABEL: setnbc29:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    clrlwi r3, r3, 24
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, eq
; CHECK-NEXT:    blr
entry:
  %cmp = icmp eq i8 %a, 1
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i64 @setnbc30(i32 %a) {
; CHECK-LABEL: setnbc30:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, eq
; CHECK-NEXT:    blr
entry:
  %cmp = icmp eq i32 %a, 1
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i64 @setnbc31(i64 %a) {
; CHECK-LABEL: setnbc31:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpdi r3, 1
; CHECK-NEXT:    setnbc r3, eq
; CHECK-NEXT:    blr
entry:
  %cmp = icmp eq i64 %a, 1
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i64 @setnbc32(i16 %a) {
; CHECK-LABEL: setnbc32:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    clrlwi r3, r3, 16
; CHECK-NEXT:    cmpwi r3, 1
; CHECK-NEXT:    setnbc r3, eq
; CHECK-NEXT:    blr
entry:
  %cmp = icmp eq i16 %a, 1
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define void @setnbc33(i8 %a) {
; CHECK-LE-LABEL: setnbc33:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    clrlwi r3, r3, 24
; CHECK-LE-NEXT:    cmpwi r3, 1
; CHECK-LE-NEXT:    setnbc r3, eq
; CHECK-LE-NEXT:    pstb r3, globalVal@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc33:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC0@toc@ha
; CHECK-BE-NEXT:    clrlwi r3, r3, 24
; CHECK-BE-NEXT:    ld r4, .LC0@toc@l(r4)
; CHECK-BE-NEXT:    cmpwi r3, 1
; CHECK-BE-NEXT:    setnbc r3, eq
; CHECK-BE-NEXT:    stb r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp eq i8 %a, 1
  %conv1 = sext i1 %cmp to i8
  store i8 %conv1, i8* @globalVal, align 1
  ret void
}

define void @setnbc34(i32 %a) {
; CHECK-LE-LABEL: setnbc34:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    cmpwi r3, 1
; CHECK-LE-NEXT:    setnbc r3, eq
; CHECK-LE-NEXT:    pstw r3, globalVal2@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc34:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC1@toc@ha
; CHECK-BE-NEXT:    cmpwi r3, 1
; CHECK-BE-NEXT:    ld r4, .LC1@toc@l(r4)
; CHECK-BE-NEXT:    setnbc r3, eq
; CHECK-BE-NEXT:    stw r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp eq i32 %a, 1
  %conv1 = sext i1 %cmp to i32
  store i32 %conv1, i32* @globalVal2, align 4
  ret void
}

define void @setnbc35(i64 %a) {
; CHECK-LE-LABEL: setnbc35:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    cmpdi r3, 1
; CHECK-LE-NEXT:    setnbc r3, eq
; CHECK-LE-NEXT:    pstd r3, globalVal3@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc35:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC2@toc@ha
; CHECK-BE-NEXT:    cmpdi r3, 1
; CHECK-BE-NEXT:    ld r4, .LC2@toc@l(r4)
; CHECK-BE-NEXT:    setnbc r3, eq
; CHECK-BE-NEXT:    std r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp eq i64 %a, 1
  %conv1 = sext i1 %cmp to i64
  store i64 %conv1, i64* @globalVal3, align 8
  ret void
}

define void @setnbc36(i16 %a) {
; CHECK-LE-LABEL: setnbc36:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    clrlwi r3, r3, 16
; CHECK-LE-NEXT:    cmpwi r3, 1
; CHECK-LE-NEXT:    setnbc r3, eq
; CHECK-LE-NEXT:    psth r3, globalVal4@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc36:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC3@toc@ha
; CHECK-BE-NEXT:    clrlwi r3, r3, 16
; CHECK-BE-NEXT:    ld r4, .LC3@toc@l(r4)
; CHECK-BE-NEXT:    cmpwi r3, 1
; CHECK-BE-NEXT:    setnbc r3, eq
; CHECK-BE-NEXT:    sth r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp eq i16 %a, 1
  %conv1 = sext i1 %cmp to i16
  store i16 %conv1, i16* @globalVal4, align 2
  ret void
}

define signext i32 @setnbc37(i64 %a) {
; CHECK-LABEL: setnbc37:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpldi r3, 1
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ugt i64 %a, 1
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i64 @setnbc38(i64 %a) {
; CHECK-LABEL: setnbc38:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpldi r3, 1
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ugt i64 %a, 1
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define void @setnbc39(i64 %a) {
; CHECK-LE-LABEL: setnbc39:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    cmpldi r3, 1
; CHECK-LE-NEXT:    setnbc r3, gt
; CHECK-LE-NEXT:    pstd r3, globalVal3@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc39:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC2@toc@ha
; CHECK-BE-NEXT:    cmpldi r3, 1
; CHECK-BE-NEXT:    ld r4, .LC2@toc@l(r4)
; CHECK-BE-NEXT:    setnbc r3, gt
; CHECK-BE-NEXT:    std r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp ugt i64 %a, 1
  %conv1 = sext i1 %cmp to i64
  store i64 %conv1, i64* @globalVal3, align 8
  ret void
}

define signext i32 @setnbc40(i8 %a) {
; CHECK-LABEL: setnbc40:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extsb. r3, r3
; CHECK-NEXT:    setnbc r3, lt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i8 %a, 0
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @setnbc41(i32 %a) {
; CHECK-LABEL: setnbc41:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpwi r3, 0
; CHECK-NEXT:    setnbc r3, lt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i32 %a, 0
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @setnbc42(i16 %a) {
; CHECK-LABEL: setnbc42:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extsh. r3, r3
; CHECK-NEXT:    setnbc r3, lt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i16 %a, 0
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i64 @setnbc43(i8 %a) {
; CHECK-LABEL: setnbc43:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extsb. r3, r3
; CHECK-NEXT:    setnbc r3, lt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i8 %a, 0
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i64 @setnbc44(i32 %a) {
; CHECK-LABEL: setnbc44:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpwi r3, 0
; CHECK-NEXT:    setnbc r3, lt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i32 %a, 0
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i64 @setnbc45(i16 %a) {
; CHECK-LABEL: setnbc45:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extsh. r3, r3
; CHECK-NEXT:    setnbc r3, lt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp slt i16 %a, 0
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i32 @setnbc46(i8 %a) {
; CHECK-LABEL: setnbc46:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extsb. r3, r3
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sgt i8 %a, 0
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @setnbc47(i32 %a) {
; CHECK-LABEL: setnbc47:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpwi r3, 0
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sgt i32 %a, 0
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @setnbc48(i64 %a) {
; CHECK-LABEL: setnbc48:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpdi r3, 0
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sgt i64 %a, 0
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @setnbc49(i16 %a) {
; CHECK-LABEL: setnbc49:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extsh. r3, r3
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sgt i16 %a, 0
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i64 @setnbc50(i8 %a) {
; CHECK-LABEL: setnbc50:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extsb. r3, r3
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sgt i8 %a, 0
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i64 @setnbc51(i32 %a) {
; CHECK-LABEL: setnbc51:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpwi r3, 0
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sgt i32 %a, 0
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i64 @setnbc52(i64 %a) {
; CHECK-LABEL: setnbc52:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpdi r3, 0
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sgt i64 %a, 0
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i64 @setnbc53(i16 %a) {
; CHECK-LABEL: setnbc53:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    extsh. r3, r3
; CHECK-NEXT:    setnbc r3, gt
; CHECK-NEXT:    blr
entry:
  %cmp = icmp sgt i16 %a, 0
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define void @setnbc54(i8 %a) {
; CHECK-LE-LABEL: setnbc54:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    extsb. r3, r3
; CHECK-LE-NEXT:    setnbc r3, gt
; CHECK-LE-NEXT:    pstb r3, globalVal@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc54:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC0@toc@ha
; CHECK-BE-NEXT:    extsb. r3, r3
; CHECK-BE-NEXT:    setnbc r3, gt
; CHECK-BE-NEXT:    ld r4, .LC0@toc@l(r4)
; CHECK-BE-NEXT:    stb r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp sgt i8 %a, 0
  %conv1 = sext i1 %cmp to i8
  store i8 %conv1, i8* @globalVal, align 1
  ret void
}

define void @setnbc55(i32 %a) {
; CHECK-LE-LABEL: setnbc55:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    cmpwi r3, 0
; CHECK-LE-NEXT:    setnbc r3, gt
; CHECK-LE-NEXT:    pstw r3, globalVal2@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc55:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC1@toc@ha
; CHECK-BE-NEXT:    cmpwi r3, 0
; CHECK-BE-NEXT:    ld r4, .LC1@toc@l(r4)
; CHECK-BE-NEXT:    setnbc r3, gt
; CHECK-BE-NEXT:    stw r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp sgt i32 %a, 0
  %conv1 = sext i1 %cmp to i32
  store i32 %conv1, i32* @globalVal2, align 4
  ret void
}

define void @setnbc56(i64 %a) {
; CHECK-LE-LABEL: setnbc56:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    cmpdi r3, 0
; CHECK-LE-NEXT:    setnbc r3, gt
; CHECK-LE-NEXT:    pstd r3, globalVal3@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc56:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC2@toc@ha
; CHECK-BE-NEXT:    cmpdi r3, 0
; CHECK-BE-NEXT:    ld r4, .LC2@toc@l(r4)
; CHECK-BE-NEXT:    setnbc r3, gt
; CHECK-BE-NEXT:    std r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp sgt i64 %a, 0
  %conv1 = sext i1 %cmp to i64
  store i64 %conv1, i64* @globalVal3, align 8
  ret void
}

define void @setnbc57(i16 %a) {
; CHECK-LE-LABEL: setnbc57:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    extsh. r3, r3
; CHECK-LE-NEXT:    setnbc r3, gt
; CHECK-LE-NEXT:    psth r3, globalVal4@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc57:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC3@toc@ha
; CHECK-BE-NEXT:    extsh. r3, r3
; CHECK-BE-NEXT:    setnbc r3, gt
; CHECK-BE-NEXT:    ld r4, .LC3@toc@l(r4)
; CHECK-BE-NEXT:    sth r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp sgt i16 %a, 0
  %conv1 = sext i1 %cmp to i16
  store i16 %conv1, i16* @globalVal4, align 2
  ret void
}

define signext i32 @setnbc58(i8 %a) {
; CHECK-LABEL: setnbc58:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    andi. r3, r3, 255
; CHECK-NEXT:    setnbc r3, eq
; CHECK-NEXT:    blr
entry:
  %cmp = icmp eq i8 %a, 0
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @setnbc59(i32 %a) {
; CHECK-LABEL: setnbc59:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpwi r3, 0
; CHECK-NEXT:    setnbc r3, eq
; CHECK-NEXT:    blr
entry:
  %cmp = icmp eq i32 %a, 0
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @setnbc60(i64 %a) {
; CHECK-LABEL: setnbc60:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpdi r3, 0
; CHECK-NEXT:    setnbc r3, eq
; CHECK-NEXT:    blr
entry:
  %cmp = icmp eq i64 %a, 0
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i32 @setnbc61(i16 %a) {
; CHECK-LABEL: setnbc61:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    andi. r3, r3, 65535
; CHECK-NEXT:    setnbc r3, eq
; CHECK-NEXT:    blr
entry:
  %cmp = icmp eq i16 %a, 0
  %conv = sext i1 %cmp to i32
  ret i32 %conv
}

define signext i64 @setnbc62(i8 %a) {
; CHECK-LABEL: setnbc62:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    andi. r3, r3, 255
; CHECK-NEXT:    setnbc r3, eq
; CHECK-NEXT:    blr
entry:
  %cmp = icmp eq i8 %a, 0
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i64 @setnbc63(i32 %a) {
; CHECK-LABEL: setnbc63:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpwi r3, 0
; CHECK-NEXT:    setnbc r3, eq
; CHECK-NEXT:    blr
entry:
  %cmp = icmp eq i32 %a, 0
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i64 @setnbc64(i64 %a) {
; CHECK-LABEL: setnbc64:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cmpdi r3, 0
; CHECK-NEXT:    setnbc r3, eq
; CHECK-NEXT:    blr
entry:
  %cmp = icmp eq i64 %a, 0
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define signext i64 @setnbc65(i16 %a) {
; CHECK-LABEL: setnbc65:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    andi. r3, r3, 65535
; CHECK-NEXT:    setnbc r3, eq
; CHECK-NEXT:    blr
entry:
  %cmp = icmp eq i16 %a, 0
  %conv = sext i1 %cmp to i64
  ret i64 %conv
}

define void @setnbc66(i8 %a) {
; CHECK-LE-LABEL: setnbc66:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    andi. r3, r3, 255
; CHECK-LE-NEXT:    setnbc r3, eq
; CHECK-LE-NEXT:    pstb r3, globalVal@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc66:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC0@toc@ha
; CHECK-BE-NEXT:    andi. r3, r3, 255
; CHECK-BE-NEXT:    setnbc r3, eq
; CHECK-BE-NEXT:    ld r4, .LC0@toc@l(r4)
; CHECK-BE-NEXT:    stb r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp eq i8 %a, 0
  %conv1 = sext i1 %cmp to i8
  store i8 %conv1, i8* @globalVal, align 1
  ret void
}

define void @setnbc67(i32 %a) {
; CHECK-LE-LABEL: setnbc67:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    cmpwi r3, 0
; CHECK-LE-NEXT:    setnbc r3, eq
; CHECK-LE-NEXT:    pstw r3, globalVal2@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc67:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC1@toc@ha
; CHECK-BE-NEXT:    cmpwi r3, 0
; CHECK-BE-NEXT:    ld r4, .LC1@toc@l(r4)
; CHECK-BE-NEXT:    setnbc r3, eq
; CHECK-BE-NEXT:    stw r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp eq i32 %a, 0
  %conv1 = sext i1 %cmp to i32
  store i32 %conv1, i32* @globalVal2, align 4
  ret void
}

define void @setnbc68(i64 %a) {
; CHECK-LE-LABEL: setnbc68:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    cmpdi r3, 0
; CHECK-LE-NEXT:    setnbc r3, eq
; CHECK-LE-NEXT:    pstd r3, globalVal3@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc68:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC2@toc@ha
; CHECK-BE-NEXT:    cmpdi r3, 0
; CHECK-BE-NEXT:    ld r4, .LC2@toc@l(r4)
; CHECK-BE-NEXT:    setnbc r3, eq
; CHECK-BE-NEXT:    std r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp eq i64 %a, 0
  %conv1 = sext i1 %cmp to i64
  store i64 %conv1, i64* @globalVal3, align 8
  ret void
}

define void @setnbc69(i16 %a) {
; CHECK-LE-LABEL: setnbc69:
; CHECK-LE:       # %bb.0: # %entry
; CHECK-LE-NEXT:    andi. r3, r3, 65535
; CHECK-LE-NEXT:    setnbc r3, eq
; CHECK-LE-NEXT:    psth r3, globalVal4@PCREL(0), 1
; CHECK-LE-NEXT:    blr
;
; CHECK-BE-LABEL: setnbc69:
; CHECK-BE:       # %bb.0: # %entry
; CHECK-BE-NEXT:    addis r4, r2, .LC3@toc@ha
; CHECK-BE-NEXT:    andi. r3, r3, 65535
; CHECK-BE-NEXT:    setnbc r3, eq
; CHECK-BE-NEXT:    ld r4, .LC3@toc@l(r4)
; CHECK-BE-NEXT:    sth r3, 0(r4)
; CHECK-BE-NEXT:    blr
entry:
  %cmp = icmp eq i16 %a, 0
  %conv1 = sext i1 %cmp to i16
  store i16 %conv1, i16* @globalVal4, align 2
  ret void
}

