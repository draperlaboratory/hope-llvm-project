; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs -mtriple=powerpc64-unknown-linux-gnu -O2 \
; RUN:   -ppc-gpr-icmps=all -ppc-asm-full-reg-names -mcpu=pwr8 < %s | FileCheck %s \
; RUN:  --implicit-check-not cmpw --implicit-check-not cmpd --implicit-check-not cmpl
; RUN: llc -verify-machineinstrs -mtriple=powerpc64le-unknown-linux-gnu -O2 \
; RUN:   -ppc-gpr-icmps=all -ppc-asm-full-reg-names -mcpu=pwr8 < %s | FileCheck %s \
; RUN:  --implicit-check-not cmpw --implicit-check-not cmpd --implicit-check-not cmpl

@glob = dso_local local_unnamed_addr global i8 0, align 1

; Function Attrs: norecurse nounwind readnone
define i64 @test_llleuc(i8 zeroext %a, i8 zeroext %b) {
; CHECK-LABEL: test_llleuc:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sub r3, r4, r3
; CHECK-NEXT:    not r3, r3
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ule i8 %a, %b
  %conv3 = zext i1 %cmp to i64
  ret i64 %conv3
}

; Function Attrs: norecurse nounwind readnone
define i64 @test_llleuc_sext(i8 zeroext %a, i8 zeroext %b) {
; CHECK-LABEL: test_llleuc_sext:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sub r3, r4, r3
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    addi r3, r3, -1
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ule i8 %a, %b
  %conv3 = sext i1 %cmp to i64
  ret i64 %conv3
}

; Function Attrs: norecurse nounwind readnone
define i64 @test_llleuc_z(i8 zeroext %a) {
; CHECK-LABEL: test_llleuc_z:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cntlzw r3, r3
; CHECK-NEXT:    srwi r3, r3, 5
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ule i8 %a, 0
  %conv2 = zext i1 %cmp to i64
  ret i64 %conv2
}

; Function Attrs: norecurse nounwind readnone
define i64 @test_llleuc_sext_z(i8 zeroext %a) {
; CHECK-LABEL: test_llleuc_sext_z:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cntlzw r3, r3
; CHECK-NEXT:    srwi r3, r3, 5
; CHECK-NEXT:    neg r3, r3
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ule i8 %a, 0
  %conv2 = sext i1 %cmp to i64
  ret i64 %conv2
}

; Function Attrs: norecurse nounwind
define dso_local void @test_llleuc_store(i8 zeroext %a, i8 zeroext %b) {
; CHECK-LABEL: test_llleuc_store:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sub r3, r4, r3
; CHECK-NEXT:    addis r5, r2, glob@toc@ha
; CHECK-NEXT:    not r3, r3
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    stb r3, glob@toc@l(r5)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ule i8 %a, %b
  %conv3 = zext i1 %cmp to i8
  store i8 %conv3, i8* @glob
  ret void
}

; Function Attrs: norecurse nounwind
define dso_local void @test_llleuc_sext_store(i8 zeroext %a, i8 zeroext %b) {
; CHECK-LABEL: test_llleuc_sext_store:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    sub r3, r4, r3
; CHECK-NEXT:    addis r5, r2, glob@toc@ha
; CHECK-NEXT:    rldicl r3, r3, 1, 63
; CHECK-NEXT:    addi r3, r3, -1
; CHECK-NEXT:    stb r3, glob@toc@l(r5)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ule i8 %a, %b
  %conv3 = sext i1 %cmp to i8
  store i8 %conv3, i8* @glob
  ret void
}

; Function Attrs: norecurse nounwind
define dso_local void @test_llleuc_z_store(i8 zeroext %a) {
; CHECK-LABEL: test_llleuc_z_store:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cntlzw r3, r3
; CHECK-NEXT:    addis r4, r2, glob@toc@ha
; CHECK-NEXT:    srwi r3, r3, 5
; CHECK-NEXT:    stb r3, glob@toc@l(r4)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ule i8 %a, 0
  %conv2 = zext i1 %cmp to i8
  store i8 %conv2, i8* @glob
  ret void
}

; Function Attrs: norecurse nounwind
define dso_local void @test_llleuc_sext_z_store(i8 zeroext %a) {
; CHECK-LABEL: test_llleuc_sext_z_store:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cntlzw r3, r3
; CHECK-NEXT:    addis r4, r2, glob@toc@ha
; CHECK-NEXT:    srwi r3, r3, 5
; CHECK-NEXT:    neg r3, r3
; CHECK-NEXT:    stb r3, glob@toc@l(r4)
; CHECK-NEXT:    blr
entry:
  %cmp = icmp ule i8 %a, 0
  %conv2 = sext i1 %cmp to i8
  store i8 %conv2, i8* @glob
  ret void
}
