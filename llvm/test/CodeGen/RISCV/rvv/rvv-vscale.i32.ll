; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple riscv32 -mattr=+m,+experimental-v < %s \
; RUN:    | FileCheck %s

define i32 @vscale_zero() nounwind {
; CHECK-LABEL: vscale_zero:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    mv a0, zero
; CHECK-NEXT:    ret
entry:
  %0 = call i32 @llvm.vscale.i32()
  %1 = mul i32 %0, 0
  ret i32 %1
}

define i32 @vscale_one() nounwind {
; CHECK-LABEL: vscale_one:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csrr a0, vlenb
; CHECK-NEXT:    srli a0, a0, 3
; CHECK-NEXT:    ret
entry:
  %0 = call i32 @llvm.vscale.i32()
  %1 = mul i32 %0, 1
  ret i32 %1
}

define i32 @vscale_uimmpow2xlen() nounwind {
; CHECK-LABEL: vscale_uimmpow2xlen:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csrr a0, vlenb
; CHECK-NEXT:    slli a0, a0, 3
; CHECK-NEXT:    ret
entry:
  %0 = call i32 @llvm.vscale.i32()
  %1 = mul i32 %0, 64
  ret i32 %1
}

define i32 @vscale_non_pow2() nounwind {
; CHECK-LABEL: vscale_non_pow2:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    csrr a0, vlenb
; CHECK-NEXT:    srli a0, a0, 3
; CHECK-NEXT:    addi a1, zero, 24
; CHECK-NEXT:    mul a0, a0, a1
; CHECK-NEXT:    ret
entry:
  %0 = call i32 @llvm.vscale.i32()
  %1 = mul i32 %0, 24
  ret i32 %1
}

declare i32 @llvm.vscale.i32()
