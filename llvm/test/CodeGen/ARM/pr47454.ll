; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=armv8-unknown-linux-unknown -mattr=-fp16 -O0 < %s | FileCheck %s

declare fastcc half @getConstant()

declare fastcc i1 @isEqual(half %0, half %1)

define internal fastcc void @main() {
; CHECK-LABEL: main:
; CHECK:       @ %bb.0: @ %Entry
; CHECK-NEXT:    push {r11, lr}
; CHECK-NEXT:    mov r11, sp
; CHECK-NEXT:    sub sp, sp, #16
; CHECK-NEXT:    mov r0, #31744
; CHECK-NEXT:    strh r0, [r11, #-2]
; CHECK-NEXT:    ldrh r0, [r11, #-2]
; CHECK-NEXT:    bl __gnu_h2f_ieee
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vstr s0, [sp, #4] @ 4-byte Spill
; CHECK-NEXT:    bl getConstant
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl __gnu_h2f_ieee
; CHECK-NEXT:    vmov s0, r0
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl __gnu_f2h_ieee
; CHECK-NEXT:    vldr s0, [sp, #4] @ 4-byte Reload
; CHECK-NEXT:    str r0, [sp, #8] @ 4-byte Spill
; CHECK-NEXT:    vmov r0, s0
; CHECK-NEXT:    bl __gnu_f2h_ieee
; CHECK-NEXT:    mov r1, r0
; CHECK-NEXT:    ldr r0, [sp, #8] @ 4-byte Reload
; CHECK-NEXT:    uxth r1, r1
; CHECK-NEXT:    vmov s0, r1
; CHECK-NEXT:    uxth r0, r0
; CHECK-NEXT:    vmov s1, r0
; CHECK-NEXT:    bl isEqual
; CHECK-NEXT:    mov sp, r11
; CHECK-NEXT:    pop {r11, pc}
Entry:
    ; First arg directly from constant
    %const = alloca half, align 2
    store half 0xH7C00, half* %const, align 2
    %arg1 = load half, half* %const, align 2
    ; Second arg from fucntion return
    %arg2 = call fastcc half @getConstant()
    ; Arguments should have equivalent mangling
    %result = call fastcc i1 @isEqual(half %arg1, half %arg2)
    ret void
}
