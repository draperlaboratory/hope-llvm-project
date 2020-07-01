; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main -mattr=+mve -disable-mve-tail-predication=false %s -o - | FileCheck %s

define dso_local void @varying_outer_2d_reduction(i16* nocapture readonly %Input, i16* nocapture %Output, i16 signext %Size, i16 signext %N, i16 signext %Scale) local_unnamed_addr {
; CHECK-LABEL: varying_outer_2d_reduction:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    push.w {r4, r5, r6, r7, r8, r9, r10, r11, lr}
; CHECK-NEXT:    sub sp, #8
; CHECK-NEXT:    cmp r3, #1
; CHECK-NEXT:    str r0, [sp, #4] @ 4-byte Spill
; CHECK-NEXT:    blt .LBB0_8
; CHECK-NEXT:  @ %bb.1: @ %for.body.lr.ph
; CHECK-NEXT:    ldr r0, [sp, #44]
; CHECK-NEXT:    adr r7, .LCPI0_0
; CHECK-NEXT:    ldr.w r10, [sp, #4] @ 4-byte Reload
; CHECK-NEXT:    add.w r9, r2, #3
; CHECK-NEXT:    vldrw.u32 q0, [r7]
; CHECK-NEXT:    mov.w r11, #0
; CHECK-NEXT:    uxth r0, r0
; CHECK-NEXT:    rsbs r5, r0, #0
; CHECK-NEXT:    str.w r9, [sp] @ 4-byte Spill
; CHECK-NEXT:    b .LBB0_4
; CHECK-NEXT:  .LBB0_2: @ in Loop: Header=BB0_4 Depth=1
; CHECK-NEXT:    movs r0, #0
; CHECK-NEXT:  .LBB0_3: @ %for.end
; CHECK-NEXT:    @ in Loop: Header=BB0_4 Depth=1
; CHECK-NEXT:    lsrs r0, r0, #16
; CHECK-NEXT:    sub.w r9, r9, #1
; CHECK-NEXT:    strh.w r0, [r1, r11, lsl #1]
; CHECK-NEXT:    add.w r11, r11, #1
; CHECK-NEXT:    add.w r10, r10, #2
; CHECK-NEXT:    cmp r11, r3
; CHECK-NEXT:    beq .LBB0_8
; CHECK-NEXT:  .LBB0_4: @ %for.body
; CHECK-NEXT:    @ =>This Loop Header: Depth=1
; CHECK-NEXT:    @ Child Loop BB0_6 Depth 2
; CHECK-NEXT:    cmp r2, r11
; CHECK-NEXT:    ble .LBB0_2
; CHECK-NEXT:  @ %bb.5: @ %vector.ph
; CHECK-NEXT:    @ in Loop: Header=BB0_4 Depth=1
; CHECK-NEXT:    bic r7, r9, #3
; CHECK-NEXT:    movs r6, #1
; CHECK-NEXT:    subs r7, #4
; CHECK-NEXT:    sub.w r0, r2, r11
; CHECK-NEXT:    vmov.i32 q2, #0x0
; CHECK-NEXT:    add.w r8, r6, r7, lsr #2
; CHECK-NEXT:    ldr r7, [sp] @ 4-byte Reload
; CHECK-NEXT:    sub.w r4, r7, r11
; CHECK-NEXT:    movs r7, #0
; CHECK-NEXT:    bic r4, r4, #3
; CHECK-NEXT:    subs r4, #4
; CHECK-NEXT:    add.w r4, r6, r4, lsr #2
; CHECK-NEXT:    subs r6, r0, #1
; CHECK-NEXT:    dls lr, r4
; CHECK-NEXT:    mov r4, r10
; CHECK-NEXT:    ldr r0, [sp, #4] @ 4-byte Reload
; CHECK-NEXT:  .LBB0_6: @ %vector.body
; CHECK-NEXT:    @ Parent Loop BB0_4 Depth=1
; CHECK-NEXT:    @ => This Inner Loop Header: Depth=2
; CHECK-NEXT:    vmov q1, q2
; CHECK-NEXT:    vadd.i32 q2, q0, r7
; CHECK-NEXT:    vdup.32 q3, r7
; CHECK-NEXT:    mov lr, r8
; CHECK-NEXT:    vcmp.u32 hi, q3, q2
; CHECK-NEXT:    vdup.32 q3, r6
; CHECK-NEXT:    vpnot
; CHECK-NEXT:    sub.w r8, r8, #1
; CHECK-NEXT:    vpsttt
; CHECK-NEXT:    vcmpt.u32 cs, q3, q2
; CHECK-NEXT:    vldrht.s32 q2, [r0], #8
; CHECK-NEXT:    vldrht.s32 q3, [r4], #8
; CHECK-NEXT:    adds r7, #4
; CHECK-NEXT:    vmul.i32 q2, q3, q2
; CHECK-NEXT:    vshl.s32 q2, r5
; CHECK-NEXT:    vadd.i32 q2, q2, q1
; CHECK-NEXT:    le lr, .LBB0_6
; CHECK-NEXT:  @ %bb.7: @ %middle.block
; CHECK-NEXT:    @ in Loop: Header=BB0_4 Depth=1
; CHECK-NEXT:    vpsel q1, q2, q1
; CHECK-NEXT:    vaddv.u32 r0, q1
; CHECK-NEXT:    b .LBB0_3
; CHECK-NEXT:  .LBB0_8: @ %for.end17
; CHECK-NEXT:    add sp, #8
; CHECK-NEXT:    pop.w {r4, r5, r6, r7, r8, r9, r10, r11, pc}
; CHECK-NEXT:    .p2align 4
; CHECK-NEXT:  @ %bb.9:
; CHECK-NEXT:  .LCPI0_0:
; CHECK-NEXT:    .long 0 @ 0x0
; CHECK-NEXT:    .long 1 @ 0x1
; CHECK-NEXT:    .long 2 @ 0x2
; CHECK-NEXT:    .long 3 @ 0x3
entry:
  %conv = sext i16 %N to i32
  %cmp36 = icmp sgt i16 %N, 0
  br i1 %cmp36, label %for.body.lr.ph, label %for.end17

for.body.lr.ph:                                   ; preds = %entry
  %conv2 = sext i16 %Size to i32
  %conv1032 = zext i16 %Scale to i32
  %i = add i32 %conv2, 3
  br label %for.body

for.body:                                         ; preds = %for.end, %for.body.lr.ph
  %lsr.iv51 = phi i32 [ %lsr.iv.next, %for.end ], [ %i, %for.body.lr.ph ]
  %lsr.iv46 = phi i16* [ %scevgep47, %for.end ], [ %Input, %for.body.lr.ph ]
  %i.037 = phi i32 [ 0, %for.body.lr.ph ], [ %inc16, %for.end ]
  %i1 = mul nsw i32 %i.037, -1
  %i2 = add i32 %i, %i1
  %i3 = lshr i32 %i2, 2
  %i4 = shl nuw i32 %i3, 2
  %i5 = add i32 %i4, -4
  %i6 = lshr i32 %i5, 2
  %i7 = add nuw nsw i32 %i6, 1
  %i8 = sub i32 %conv2, %i.037
  %cmp433 = icmp slt i32 %i.037, %conv2
  br i1 %cmp433, label %vector.ph, label %for.end

vector.ph:                                        ; preds = %for.body
  %trip.count.minus.1 = add i32 %i8, -1
  call void @llvm.set.loop.iterations.i32(i32 %i7)
  br label %vector.body

vector.body:                                      ; preds = %vector.body, %vector.ph
  %lsr.iv48 = phi i16* [ %scevgep49, %vector.body ], [ %lsr.iv46, %vector.ph ]
  %lsr.iv = phi i16* [ %scevgep, %vector.body ], [ %Input, %vector.ph ]
  %index = phi i32 [ 0, %vector.ph ], [ %index.next, %vector.body ]
  %vec.phi = phi <4 x i32> [ zeroinitializer, %vector.ph ], [ %i16, %vector.body ]
  %i9 = phi i32 [ %i7, %vector.ph ], [ %i17, %vector.body ]
  %lsr.iv4850 = bitcast i16* %lsr.iv48 to <4 x i16>*
  %lsr.iv45 = bitcast i16* %lsr.iv to <4 x i16>*
  %active.lane.mask = call <4 x i1> @llvm.get.active.lane.mask.v4i1.i32(i32 %index, i32 %trip.count.minus.1)
  %wide.masked.load = call <4 x i16> @llvm.masked.load.v4i16.p0v4i16(<4 x i16>* %lsr.iv45, i32 2, <4 x i1> %active.lane.mask, <4 x i16> undef)
  %i10 = sext <4 x i16> %wide.masked.load to <4 x i32>
  %wide.masked.load42 = call <4 x i16> @llvm.masked.load.v4i16.p0v4i16(<4 x i16>* %lsr.iv4850, i32 2, <4 x i1> %active.lane.mask, <4 x i16> undef)
  %i11 = sext <4 x i16> %wide.masked.load42 to <4 x i32>
  %i12 = mul nsw <4 x i32> %i11, %i10
  %i13 = insertelement <4 x i32> undef, i32 %conv1032, i32 0
  %i14 = shufflevector <4 x i32> %i13, <4 x i32> undef, <4 x i32> zeroinitializer
  %i15 = ashr <4 x i32> %i12, %i14
  %i16 = add <4 x i32> %i15, %vec.phi
  %index.next = add i32 %index, 4
  %scevgep = getelementptr i16, i16* %lsr.iv, i32 4
  %scevgep49 = getelementptr i16, i16* %lsr.iv48, i32 4
  %i17 = call i32 @llvm.loop.decrement.reg.i32(i32 %i9, i32 1)
  %i18 = icmp ne i32 %i17, 0
  br i1 %i18, label %vector.body, label %middle.block

middle.block:                                     ; preds = %vector.body
  %i19 = select <4 x i1> %active.lane.mask, <4 x i32> %i16, <4 x i32> %vec.phi
  %i20 = call i32 @llvm.experimental.vector.reduce.add.v4i32(<4 x i32> %i19)
  br label %for.end

for.end:                                          ; preds = %middle.block, %for.body
  %Sum.0.lcssa = phi i32 [ 0, %for.body ], [ %i20, %middle.block ]
  %i21 = lshr i32 %Sum.0.lcssa, 16
  %conv13 = trunc i32 %i21 to i16
  %arrayidx14 = getelementptr inbounds i16, i16* %Output, i32 %i.037
  store i16 %conv13, i16* %arrayidx14, align 2
  %inc16 = add nuw nsw i32 %i.037, 1
  %scevgep47 = getelementptr i16, i16* %lsr.iv46, i32 1
  %lsr.iv.next = add i32 %lsr.iv51, -1
  %exitcond39 = icmp eq i32 %inc16, %conv
  br i1 %exitcond39, label %for.end17, label %for.body

for.end17:                                        ; preds = %for.end, %entry
  ret void
}

declare <4 x i1> @llvm.get.active.lane.mask.v4i1.i32(i32, i32)
declare <4 x i16> @llvm.masked.load.v4i16.p0v4i16(<4 x i16>*, i32 immarg, <4 x i1>, <4 x i16>)
declare i32 @llvm.experimental.vector.reduce.add.v4i32(<4 x i32>)
declare i32 @llvm.loop.decrement.reg.i32(i32, i32)
declare void @llvm.set.loop.iterations.i32(i32)
