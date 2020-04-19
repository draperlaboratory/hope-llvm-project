; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: opt -instcombine -S %s | FileCheck --check-prefix=IR %s
; RUN: opt -instcombine    %s | llc -mtriple=thumbv8.1m.main -mattr=+mve.fp -verify-machineinstrs -O3 -o - | FileCheck --check-prefix=ASM %s

%struct.foo = type { [2 x <4 x i32>] }

define arm_aapcs_vfpcc i32 @test_vadciq_multiple(%struct.foo %a, %struct.foo %b, i32 %carry) {
entry:
  %a.0 = extractvalue %struct.foo %a, 0, 0
  %a.1 = extractvalue %struct.foo %a, 0, 1
  %b.0 = extractvalue %struct.foo %b, 0, 0
  %b.1 = extractvalue %struct.foo %b, 0, 1

  %fpscr.in.0 = shl i32 %carry, 29
  %outpair.0 = call { <4 x i32>, i32 } @llvm.arm.mve.vadc.v4i32(<4 x i32> %a.0, <4 x i32> %b.0, i32 %fpscr.in.0)
  %fpscr.out.0 = extractvalue { <4 x i32>, i32 } %outpair.0, 1
  %shifted.out.0 = lshr i32 %fpscr.out.0, 29
  %carry.out.0 = and i32 1, %shifted.out.0
  %fpscr.in.1 = shl i32 %carry.out.0, 29
  %outpair.1 = call { <4 x i32>, i32 } @llvm.arm.mve.vadc.v4i32(<4 x i32> %a.1, <4 x i32> %b.1, i32 %fpscr.in.1)
  %fpscr.out.1 = extractvalue { <4 x i32>, i32 } %outpair.1, 1
  %shifted.out.1 = lshr i32 %fpscr.out.1, 29
  %carry.out.1 = and i32 1, %shifted.out.1
  ret i32 %carry.out.1
}

define arm_aapcs_vfpcc i32 @test_vadciq_pred_multiple(%struct.foo %a, %struct.foo %b, i32 %ipred, i32 %carry) {
entry:
  %a.0 = extractvalue %struct.foo %a, 0, 0
  %a.1 = extractvalue %struct.foo %a, 0, 1
  %b.0 = extractvalue %struct.foo %b, 0, 0
  %b.1 = extractvalue %struct.foo %b, 0, 1

  %vpred = tail call <4 x i1> @llvm.arm.mve.pred.i2v.v4i1(i32 %ipred)
  %fpscr.in.0 = shl i32 %carry, 29
  %outpair.0 = call { <4 x i32>, i32 } @llvm.arm.mve.vadc.predicated.v4i32.v4i1(<4 x i32> undef, <4 x i32> %a.0, <4 x i32> %b.0, i32 %fpscr.in.0, <4 x i1> %vpred)
  %fpscr.out.0 = extractvalue { <4 x i32>, i32 } %outpair.0, 1
  %shifted.out.0 = lshr i32 %fpscr.out.0, 29
  %carry.out.0 = and i32 1, %shifted.out.0
  %fpscr.in.1 = shl i32 %carry.out.0, 29
  %outpair.1 = call { <4 x i32>, i32 } @llvm.arm.mve.vadc.predicated.v4i32.v4i1(<4 x i32> undef, <4 x i32> %a.1, <4 x i32> %b.1, i32 %fpscr.in.1, <4 x i1> %vpred)
  %fpscr.out.1 = extractvalue { <4 x i32>, i32 } %outpair.1, 1
  %shifted.out.1 = lshr i32 %fpscr.out.1, 29
  %carry.out.1 = and i32 1, %shifted.out.1
  ret i32 %carry.out.1
}

declare { <4 x i32>, i32 } @llvm.arm.mve.vadc.v4i32(<4 x i32>, <4 x i32>, i32)
declare { <4 x i32>, i32 } @llvm.arm.mve.vadc.predicated.v4i32.v4i1(<4 x i32>, <4 x i32>, <4 x i32>, i32, <4 x i1>)
declare <4 x i1> @llvm.arm.mve.pred.i2v.v4i1(i32)

; Expect the transformation in between the two intrinsics, where the
; fpscr-formatted output value is turned back into just the carry bit
; at bit 0 and then back again for the next call, to be optimized away
; completely in InstCombine, so that the FPSCR output from one
; intrinsic is passed straight on to the next:

; IR: %outpair.0 = call { <4 x i32>, i32 } @llvm.arm.mve.vadc.v4i32(<4 x i32> %a.0, <4 x i32> %b.0, i32 %fpscr.in.0)
; IR: %fpscr.out.0 = extractvalue { <4 x i32>, i32 } %outpair.0, 1
; IR: %outpair.1 = call { <4 x i32>, i32 } @llvm.arm.mve.vadc.v4i32(<4 x i32> %a.1, <4 x i32> %b.1, i32 %fpscr.out.0)

; IR: %outpair.0 = call { <4 x i32>, i32 } @llvm.arm.mve.vadc.predicated.v4i32.v4i1(<4 x i32> undef, <4 x i32> %a.0, <4 x i32> %b.0, i32 %fpscr.in.0, <4 x i1> %vpred)
; IR: %fpscr.out.0 = extractvalue { <4 x i32>, i32 } %outpair.0, 1
; IR: %outpair.1 = call { <4 x i32>, i32 } @llvm.arm.mve.vadc.predicated.v4i32.v4i1(<4 x i32> undef, <4 x i32> %a.1, <4 x i32> %b.1, i32 %fpscr.out.0, <4 x i1> %vpred)

; And this is the assembly language we expect at the end of it, with
; the two vadc.i32 instructions right next to each other, and the
; second one implicitly reusing the FPSCR written by the first.

; ASM: test_vadciq_multiple:
; ASM:      lsls r0, r0, #29
; ASM-NEXT: vmsr fpscr_nzcvqc, r0
; ASM-NEXT: vadc.i32 q0, q0, q2
; ASM-NEXT: vadc.i32 q0, q1, q3
; ASM-NEXT: vmrs r0, fpscr_nzcvqc
; ASM-NEXT: ubfx r0, r0, #29, #1
; ASM-NEXT: bx lr

; ASM: test_vadciq_pred_multiple:
; ASM: lsls r1, r1, #29
; ASM-NEXT: vmsr p0, r0
; ASM-NEXT: vmsr fpscr_nzcvqc, r1
; ASM-NEXT: vpstt
; ASM-NEXT: vadct.i32 q0, q0, q2
; ASM-NEXT: vadct.i32 q0, q1, q3
; ASM-NEXT: vmrs r0, fpscr_nzcvqc
; ASM-NEXT: ubfx r0, r0, #29, #1
; ASM-NEXT: bx lr
