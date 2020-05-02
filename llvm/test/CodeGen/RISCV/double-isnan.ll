; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+d -target-abi ilp32d -verify-machineinstrs \
; RUN:   < %s | FileCheck -check-prefix=RV32IFD %s
; RUN: llc -mtriple=riscv64 -mattr=+d -target-abi lp64d -verify-machineinstrs \
; RUN:   < %s | FileCheck -check-prefix=RV64IFD %s

define zeroext i1 @double_is_nan(double %a) nounwind {
; RV32IFD-LABEL: double_is_nan:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    feq.d a0, fa0, fa0
; RV32IFD-NEXT:    and a0, a0, a0
; RV32IFD-NEXT:    seqz a0, a0
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: double_is_nan:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    feq.d a0, fa0, fa0
; RV64IFD-NEXT:    and a0, a0, a0
; RV64IFD-NEXT:    seqz a0, a0
; RV64IFD-NEXT:    ret
  %1 = fcmp uno double %a, 0.000000e+00
  ret i1 %1
}

define zeroext i1 @double_not_nan(double %a) nounwind {
; RV32IFD-LABEL: double_not_nan:
; RV32IFD:       # %bb.0:
; RV32IFD-NEXT:    feq.d a0, fa0, fa0
; RV32IFD-NEXT:    and a0, a0, a0
; RV32IFD-NEXT:    ret
;
; RV64IFD-LABEL: double_not_nan:
; RV64IFD:       # %bb.0:
; RV64IFD-NEXT:    feq.d a0, fa0, fa0
; RV64IFD-NEXT:    and a0, a0, a0
; RV64IFD-NEXT:    ret
  %1 = fcmp ord double %a, 0.000000e+00
  ret i1 %1
}
