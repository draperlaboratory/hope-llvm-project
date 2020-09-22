; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc  -O0 -mtriple=mipsel-linux-gnu -global-isel -verify-machineinstrs %s -o -| FileCheck %s -check-prefixes=MIPS32,FP32
; RUN: llc  -O0 -mtriple=mipsel-linux-gnu -mattr=+fp64,+mips32r2 -global-isel -verify-machineinstrs %s -o -| FileCheck %s -check-prefixes=MIPS32,FP64

define i1 @false_s(float %x, float %y) {
; MIPS32-LABEL: false_s:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    ori $2, $zero, 0
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp false float %x, %y
  ret i1 %cmp
}
define i1 @true_s(float %x, float %y) {
; MIPS32-LABEL: true_s:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    ori $2, $zero, 1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp true float %x, %y
  ret i1 %cmp
}


define i1 @uno_s(float %x, float %y) {
; MIPS32-LABEL: uno_s:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.un.s $f12, $f14
; MIPS32-NEXT:    movf $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp uno float %x, %y
  ret i1 %cmp
}
define i1 @ord_s(float %x, float %y) {
; MIPS32-LABEL: ord_s:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.un.s $f12, $f14
; MIPS32-NEXT:    movt $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp ord float %x, %y
  ret i1 %cmp
}


define i1 @oeq_s(float %x, float %y) {
; MIPS32-LABEL: oeq_s:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.eq.s $f12, $f14
; MIPS32-NEXT:    movf $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp oeq float %x, %y
  ret i1 %cmp
}
define i1 @une_s(float %x, float %y) {
; MIPS32-LABEL: une_s:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.eq.s $f12, $f14
; MIPS32-NEXT:    movt $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp une float %x, %y
  ret i1 %cmp
}


define i1 @ueq_s(float %x, float %y) {
; MIPS32-LABEL: ueq_s:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.ueq.s $f12, $f14
; MIPS32-NEXT:    movf $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp ueq float %x, %y
  ret i1 %cmp
}
define i1 @one_s(float %x, float %y) {
; MIPS32-LABEL: one_s:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.ueq.s $f12, $f14
; MIPS32-NEXT:    movt $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp one float %x, %y
  ret i1 %cmp
}


define i1 @olt_s(float %x, float %y) {
; MIPS32-LABEL: olt_s:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.olt.s $f12, $f14
; MIPS32-NEXT:    movf $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp olt float %x, %y
  ret i1 %cmp
}
define i1 @uge_s(float %x, float %y) {
; MIPS32-LABEL: uge_s:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.olt.s $f12, $f14
; MIPS32-NEXT:    movt $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp uge float %x, %y
  ret i1 %cmp
}


define i1 @ult_s(float %x, float %y) {
; MIPS32-LABEL: ult_s:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.ult.s $f12, $f14
; MIPS32-NEXT:    movf $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp ult float %x, %y
  ret i1 %cmp
}
define i1 @oge_s(float %x, float %y) {
; MIPS32-LABEL: oge_s:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.ult.s $f12, $f14
; MIPS32-NEXT:    movt $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp oge float %x, %y
  ret i1 %cmp
}


define i1 @ole_s(float %x, float %y) {
; MIPS32-LABEL: ole_s:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.ole.s $f12, $f14
; MIPS32-NEXT:    movf $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp ole float %x, %y
  ret i1 %cmp
}
define i1 @ugt_s(float %x, float %y) {
; MIPS32-LABEL: ugt_s:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.ole.s $f12, $f14
; MIPS32-NEXT:    movt $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp ugt float %x, %y
  ret i1 %cmp
}


define i1 @ule_s(float %x, float %y) {
; MIPS32-LABEL: ule_s:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.ule.s $f12, $f14
; MIPS32-NEXT:    movf $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp ule float %x, %y
  ret i1 %cmp
}
define i1 @ogt_s(float %x, float %y) {
; MIPS32-LABEL: ogt_s:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.ule.s $f12, $f14
; MIPS32-NEXT:    movt $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp ogt float %x, %y
  ret i1 %cmp
}


define i1 @false_d(double %x, double %y) {
; MIPS32-LABEL: false_d:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    ori $2, $zero, 0
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp false double %x, %y
  ret i1 %cmp
}
define i1 @true_d(double %x, double %y) {
; MIPS32-LABEL: true_d:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    ori $2, $zero, 1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp true double %x, %y
  ret i1 %cmp
}


define i1 @uno_d(double %x, double %y) {
; MIPS32-LABEL: uno_d:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.un.d $f12, $f14
; MIPS32-NEXT:    movf $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp uno double %x, %y
  ret i1 %cmp
}
define i1 @ord_d(double %x, double %y) {
; MIPS32-LABEL: ord_d:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.un.d $f12, $f14
; MIPS32-NEXT:    movt $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp ord double %x, %y
  ret i1 %cmp
}


define i1 @oeq_d(double %x, double %y) {
; MIPS32-LABEL: oeq_d:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.eq.d $f12, $f14
; MIPS32-NEXT:    movf $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp oeq double %x, %y
  ret i1 %cmp
}
define i1 @une_d(double %x, double %y) {
; MIPS32-LABEL: une_d:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.eq.d $f12, $f14
; MIPS32-NEXT:    movt $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp une double %x, %y
  ret i1 %cmp
}


define i1 @ueq_d(double %x, double %y) {
; MIPS32-LABEL: ueq_d:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.ueq.d $f12, $f14
; MIPS32-NEXT:    movf $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp ueq double %x, %y
  ret i1 %cmp
}
define i1 @one_d(double %x, double %y) {
; MIPS32-LABEL: one_d:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.ueq.d $f12, $f14
; MIPS32-NEXT:    movt $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp one double %x, %y
  ret i1 %cmp
}


define i1 @olt_d(double %x, double %y) {
; MIPS32-LABEL: olt_d:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.olt.d $f12, $f14
; MIPS32-NEXT:    movf $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp olt double %x, %y
  ret i1 %cmp
}
define i1 @uge_d(double %x, double %y) {
; MIPS32-LABEL: uge_d:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.olt.d $f12, $f14
; MIPS32-NEXT:    movt $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp uge double %x, %y
  ret i1 %cmp
}


define i1 @ult_d(double %x, double %y) {
; MIPS32-LABEL: ult_d:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.ult.d $f12, $f14
; MIPS32-NEXT:    movf $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp ult double %x, %y
  ret i1 %cmp
}
define i1 @oge_d(double %x, double %y) {
; MIPS32-LABEL: oge_d:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.ult.d $f12, $f14
; MIPS32-NEXT:    movt $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp oge double %x, %y
  ret i1 %cmp
}


define i1 @ole_d(double %x, double %y) {
; MIPS32-LABEL: ole_d:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.ole.d $f12, $f14
; MIPS32-NEXT:    movf $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp ole double %x, %y
  ret i1 %cmp
}
define i1 @ugt_d(double %x, double %y) {
; MIPS32-LABEL: ugt_d:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.ole.d $f12, $f14
; MIPS32-NEXT:    movt $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp ugt double %x, %y
  ret i1 %cmp
}


define i1 @ule_d(double %x, double %y) {
; MIPS32-LABEL: ule_d:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.ule.d $f12, $f14
; MIPS32-NEXT:    movf $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp ule double %x, %y
  ret i1 %cmp
}
define i1 @ogt_d(double %x, double %y) {
; MIPS32-LABEL: ogt_d:
; MIPS32:       # %bb.0: # %entry
; MIPS32-NEXT:    addiu $1, $zero, 1
; MIPS32-NEXT:    c.ule.d $f12, $f14
; MIPS32-NEXT:    movt $1, $zero, $fcc0
; MIPS32-NEXT:    move $2, $1
; MIPS32-NEXT:    jr $ra
; MIPS32-NEXT:    nop
entry:
  %cmp = fcmp ogt double %x, %y
  ret i1 %cmp
}
