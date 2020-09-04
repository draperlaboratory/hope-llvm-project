; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=amdgcn-amd-amdhsa -mcpu=gfx900 -denormal-fp-math-f32=preserve-sign -verify-machineinstrs < %s | FileCheck -check-prefix=GFX9 %s

; Make sure that AMDGPUCodeGenPrepare introduces mul24 intrinsics
; after SLSR, as the intrinsics would interfere. It's unclear if these
; should be introduced before LSR or not. It seems to help in some
; cases, and hurt others.

define void @lsr_order_mul24_0(i32 %arg, i32 %arg2, i32 %arg6, i32 %arg13, i32 %arg16) #0 {
; GFX9-LABEL: lsr_order_mul24_0:
; GFX9:       ; %bb.0: ; %bb
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    global_load_dword v5, v[0:1], off
; GFX9-NEXT:    v_and_b32_e32 v2, 0xffffff, v2
; GFX9-NEXT:    v_sub_u32_e32 v4, v4, v1
; GFX9-NEXT:    s_mov_b64 s[4:5], 0
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    ds_write_b32 v0, v5
; GFX9-NEXT:  BB0_1: ; %bb23
; GFX9-NEXT:    ; =>This Inner Loop Header: Depth=1
; GFX9-NEXT:    v_mul_u32_u24_e32 v5, v0, v2
; GFX9-NEXT:    v_add_u32_e32 v0, v0, v1
; GFX9-NEXT:    v_sub_u32_e32 v5, v4, v5
; GFX9-NEXT:    v_add_u32_e32 v5, v5, v0
; GFX9-NEXT:    v_cmp_ge_u32_e32 vcc, v5, v3
; GFX9-NEXT:    s_or_b64 s[4:5], vcc, s[4:5]
; GFX9-NEXT:    s_andn2_b64 exec, exec, s[4:5]
; GFX9-NEXT:    s_cbranch_execnz BB0_1
; GFX9-NEXT:  ; %bb.2: ; %.loopexit
; GFX9-NEXT:    s_or_b64 exec, exec, s[4:5]
; GFX9-NEXT:    s_setpc_b64 s[30:31]
bb:
  %tmp22 = and i32 %arg6, 16777215
  br label %bb23

.loopexit:                                        ; preds = %bb23
  ret void

bb23:                                             ; preds = %bb23, %bb
  %tmp24 = phi i32 [ %arg, %bb ], [ %tmp47, %bb23 ]
  %tmp28 = and i32 %tmp24, 16777215
  %tmp29 = mul i32 %tmp28, %tmp22
  %tmp30 = sub i32 %tmp24, %tmp29
  %tmp31 = add i32 %tmp30, %arg16
  %tmp37 = icmp ult i32 %tmp31, %arg13
  %tmp44 = load float, float addrspace(1)* undef, align 4
  store float %tmp44, float addrspace(3)* undef, align 4
  %tmp47 = add i32 %tmp24, %arg2
  br i1 %tmp37, label %bb23, label %.loopexit
}

define void @lsr_order_mul24_1(i32 %arg, i32 %arg1, i32 %arg2, float addrspace(3)* nocapture %arg3, i32 %arg4, i32 %arg5, i32 %arg6, i32 %arg7, i32 %arg8, i32 %arg9, float addrspace(1)* nocapture readonly %arg10, i32 %arg11, i32 %arg12, i32 %arg13, i32 %arg14, i32 %arg15, i32 %arg16, i1 zeroext %arg17, i1 zeroext %arg18) #0 {
; GFX9-LABEL: lsr_order_mul24_1:
; GFX9:       ; %bb.0: ; %bb
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_and_b32_e32 v5, 1, v18
; GFX9-NEXT:    v_cmp_eq_u32_e32 vcc, 1, v5
; GFX9-NEXT:    v_cmp_lt_u32_e64 s[4:5], v0, v1
; GFX9-NEXT:    s_and_saveexec_b64 s[8:9], s[4:5]
; GFX9-NEXT:    s_cbranch_execz BB1_3
; GFX9-NEXT:  ; %bb.1: ; %bb19
; GFX9-NEXT:    v_cvt_f32_u32_e32 v7, v6
; GFX9-NEXT:    v_and_b32_e32 v5, 0xffffff, v6
; GFX9-NEXT:    v_add_u32_e32 v6, v4, v0
; GFX9-NEXT:    v_lshl_add_u32 v3, v6, 2, v3
; GFX9-NEXT:    v_rcp_iflag_f32_e32 v4, v7
; GFX9-NEXT:    v_lshlrev_b32_e32 v6, 2, v2
; GFX9-NEXT:    v_add_u32_e32 v7, v17, v12
; GFX9-NEXT:    s_mov_b64 s[10:11], 0
; GFX9-NEXT:  BB1_2: ; %bb23
; GFX9-NEXT:    ; =>This Inner Loop Header: Depth=1
; GFX9-NEXT:    v_cvt_f32_u32_e32 v8, v0
; GFX9-NEXT:    v_add_u32_e32 v9, v17, v0
; GFX9-NEXT:    v_add_u32_e32 v12, v7, v0
; GFX9-NEXT:    v_add_u32_e32 v0, v0, v2
; GFX9-NEXT:    v_madak_f32 v8, v8, v4, 0x3727c5ac
; GFX9-NEXT:    v_cvt_u32_f32_e32 v8, v8
; GFX9-NEXT:    v_mul_u32_u24_e32 v18, v8, v5
; GFX9-NEXT:    v_add_u32_e32 v8, v8, v16
; GFX9-NEXT:    v_cmp_lt_u32_e64 s[4:5], v8, v13
; GFX9-NEXT:    v_mul_lo_u32 v8, v8, v15
; GFX9-NEXT:    v_sub_u32_e32 v19, v9, v18
; GFX9-NEXT:    v_cmp_lt_u32_e64 s[6:7], v19, v14
; GFX9-NEXT:    s_and_b64 s[4:5], s[4:5], s[6:7]
; GFX9-NEXT:    v_sub_u32_e32 v12, v12, v18
; GFX9-NEXT:    v_add_u32_e32 v8, v12, v8
; GFX9-NEXT:    s_and_b64 s[4:5], s[4:5], vcc
; GFX9-NEXT:    v_mov_b32_e32 v9, 0
; GFX9-NEXT:    v_cndmask_b32_e64 v8, 0, v8, s[4:5]
; GFX9-NEXT:    v_lshlrev_b64 v[8:9], 2, v[8:9]
; GFX9-NEXT:    v_add_co_u32_e64 v8, s[6:7], v10, v8
; GFX9-NEXT:    v_addc_co_u32_e64 v9, s[6:7], v11, v9, s[6:7]
; GFX9-NEXT:    global_load_dword v8, v[8:9], off
; GFX9-NEXT:    v_cmp_ge_u32_e64 s[6:7], v0, v1
; GFX9-NEXT:    s_or_b64 s[10:11], s[6:7], s[10:11]
; GFX9-NEXT:    s_waitcnt vmcnt(0)
; GFX9-NEXT:    v_cndmask_b32_e64 v8, 0, v8, s[4:5]
; GFX9-NEXT:    ds_write_b32 v3, v8
; GFX9-NEXT:    v_add_u32_e32 v3, v3, v6
; GFX9-NEXT:    s_andn2_b64 exec, exec, s[10:11]
; GFX9-NEXT:    s_cbranch_execnz BB1_2
; GFX9-NEXT:  BB1_3: ; %Flow3
; GFX9-NEXT:    s_or_b64 exec, exec, s[8:9]
; GFX9-NEXT:    s_setpc_b64 s[30:31]
bb:
  %tmp = icmp ult i32 %arg, %arg1
  br i1 %tmp, label %bb19, label %.loopexit

bb19:                                             ; preds = %bb
  %tmp20 = uitofp i32 %arg6 to float
  %tmp21 = fdiv float 1.000000e+00, %tmp20, !fpmath !0
  %tmp22 = and i32 %arg6, 16777215
  br label %bb23

.loopexit:                                        ; preds = %bb23, %bb
  ret void

bb23:                                             ; preds = %bb19, %bb23
  %tmp24 = phi i32 [ %arg, %bb19 ], [ %tmp47, %bb23 ]
  %tmp25 = uitofp i32 %tmp24 to float
  %tmp26 = tail call float @llvm.fmuladd.f32(float %tmp25, float %tmp21, float 0x3EE4F8B580000000) #2
  %tmp27 = fptoui float %tmp26 to i32
  %tmp28 = and i32 %tmp27, 16777215
  %tmp29 = mul i32 %tmp28, %tmp22
  %tmp30 = sub i32 %tmp24, %tmp29
  %tmp31 = add i32 %tmp30, %arg16
  %tmp32 = add i32 %tmp27, %arg15
  %tmp33 = mul i32 %tmp32, %arg14
  %tmp34 = add i32 %tmp33, %arg11
  %tmp35 = add i32 %tmp34, %tmp31
  %tmp36 = add i32 %tmp24, %arg4
  %tmp37 = icmp ult i32 %tmp31, %arg13
  %tmp38 = icmp ult i32 %tmp32, %arg12
  %tmp39 = and i1 %tmp38, %tmp37
  %tmp40 = and i1 %tmp39, %arg17
  %tmp41 = zext i32 %tmp35 to i64
  %tmp42 = select i1 %tmp40, i64 %tmp41, i64 0
  %tmp43 = getelementptr inbounds float, float addrspace(1)* %arg10, i64 %tmp42
  %tmp44 = load float, float addrspace(1)* %tmp43, align 4
  %tmp45 = select i1 %tmp40, float %tmp44, float 0.000000e+00
  %tmp46 = getelementptr inbounds float, float addrspace(3)* %arg3, i32 %tmp36
  store float %tmp45, float addrspace(3)* %tmp46, align 4
  %tmp47 = add i32 %tmp24, %arg2
  %tmp48 = icmp ult i32 %tmp47, %arg1
  br i1 %tmp48, label %bb23, label %.loopexit
}

define void @slsr1_0(i32 %b.arg, i32 %s.arg) #0 {
; GFX9-LABEL: slsr1_0:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_mul_u32_u24_e32 v3, v0, v1
; GFX9-NEXT:    v_and_b32_e32 v2, 0xffffff, v1
; GFX9-NEXT:    global_store_dword v[0:1], v3, off
; GFX9-NEXT:    v_mad_u32_u24 v0, v0, v1, v2
; GFX9-NEXT:    global_store_dword v[0:1], v0, off
; GFX9-NEXT:    v_add_u32_e32 v0, v0, v2
; GFX9-NEXT:    global_store_dword v[0:1], v0, off
; GFX9-NEXT:    s_setpc_b64 s[30:31]
  %b = and i32 %b.arg, 16777215
  %s = and i32 %s.arg, 16777215

; CHECK-LABEL: @slsr1(
  ; foo(b * s);
  %mul0 = mul i32 %b, %s
; CHECK: mul i32
; CHECK-NOT: mul i32
  store volatile i32 %mul0, i32 addrspace(1)* undef

  ; foo((b + 1) * s);
  %b1 = add i32 %b, 1
  %mul1 = mul i32 %b1, %s
  store volatile i32 %mul1, i32 addrspace(1)* undef

  ; foo((b + 2) * s);
  %b2 = add i32 %b, 2
  %mul2 = mul i32 %b2, %s
  store volatile i32 %mul2, i32 addrspace(1)* undef
  ret void
}

define void @slsr1_1(i32 %b.arg, i32 %s.arg) #0 {
; GFX9-LABEL: slsr1_1:
; GFX9:       ; %bb.0:
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    s_or_saveexec_b64 s[4:5], -1
; GFX9-NEXT:    buffer_store_dword v43, off, s[0:3], s32 offset:12 ; 4-byte Folded Spill
; GFX9-NEXT:    s_mov_b64 exec, s[4:5]
; GFX9-NEXT:    v_writelane_b32 v43, s33, 4
; GFX9-NEXT:    s_mov_b32 s33, s32
; GFX9-NEXT:    s_add_u32 s32, s32, 0x800
; GFX9-NEXT:    buffer_store_dword v40, off, s[0:3], s33 offset:8 ; 4-byte Folded Spill
; GFX9-NEXT:    buffer_store_dword v41, off, s[0:3], s33 offset:4 ; 4-byte Folded Spill
; GFX9-NEXT:    buffer_store_dword v42, off, s[0:3], s33 ; 4-byte Folded Spill
; GFX9-NEXT:    v_writelane_b32 v43, s34, 0
; GFX9-NEXT:    s_getpc_b64 s[4:5]
; GFX9-NEXT:    s_add_u32 s4, s4, foo@gotpcrel32@lo+4
; GFX9-NEXT:    s_addc_u32 s5, s5, foo@gotpcrel32@hi+12
; GFX9-NEXT:    v_writelane_b32 v43, s35, 1
; GFX9-NEXT:    s_load_dwordx2 s[34:35], s[4:5], 0x0
; GFX9-NEXT:    v_mov_b32_e32 v40, v1
; GFX9-NEXT:    v_mov_b32_e32 v41, v0
; GFX9-NEXT:    v_writelane_b32 v43, s30, 2
; GFX9-NEXT:    v_mul_u32_u24_e32 v0, v41, v40
; GFX9-NEXT:    v_writelane_b32 v43, s31, 3
; GFX9-NEXT:    v_and_b32_e32 v42, 0xffffff, v40
; GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; GFX9-NEXT:    s_swappc_b64 s[30:31], s[34:35]
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_mad_u32_u24 v40, v41, v40, v42
; GFX9-NEXT:    v_mov_b32_e32 v0, v40
; GFX9-NEXT:    s_swappc_b64 s[30:31], s[34:35]
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_add_u32_e32 v0, v40, v42
; GFX9-NEXT:    s_swappc_b64 s[30:31], s[34:35]
; GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX9-NEXT:    v_readlane_b32 s4, v43, 2
; GFX9-NEXT:    v_readlane_b32 s5, v43, 3
; GFX9-NEXT:    v_readlane_b32 s35, v43, 1
; GFX9-NEXT:    v_readlane_b32 s34, v43, 0
; GFX9-NEXT:    buffer_load_dword v42, off, s[0:3], s33 ; 4-byte Folded Reload
; GFX9-NEXT:    buffer_load_dword v41, off, s[0:3], s33 offset:4 ; 4-byte Folded Reload
; GFX9-NEXT:    buffer_load_dword v40, off, s[0:3], s33 offset:8 ; 4-byte Folded Reload
; GFX9-NEXT:    s_sub_u32 s32, s32, 0x800
; GFX9-NEXT:    v_readlane_b32 s33, v43, 4
; GFX9-NEXT:    s_or_saveexec_b64 s[6:7], -1
; GFX9-NEXT:    buffer_load_dword v43, off, s[0:3], s32 offset:12 ; 4-byte Folded Reload
; GFX9-NEXT:    s_mov_b64 exec, s[6:7]
; GFX9-NEXT:    s_setpc_b64 s[4:5]
  %b = and i32 %b.arg, 16777215
  %s = and i32 %s.arg, 16777215

; CHECK-LABEL: @slsr1(
  ; foo(b * s);
  %mul0 = mul i32 %b, %s
; CHECK: mul i32
; CHECK-NOT: mul i32
  call void @foo(i32 %mul0)

  ; foo((b + 1) * s);
  %b1 = add i32 %b, 1
  %mul1 = mul i32 %b1, %s
  call void @foo(i32 %mul1)

  ; foo((b + 2) * s);
  %b2 = add i32 %b, 2
  %mul2 = mul i32 %b2, %s
  call void @foo(i32 %mul2)

  ret void
}

declare void @foo(i32) #0
declare float @llvm.fmuladd.f32(float, float, float) #1

attributes #0 = { nounwind willreturn "denormal-fp-math-f32"="preserve-sign,preserve-sign" }
attributes #1 = { nounwind readnone speculatable }

!0 = !{float 2.500000e+00}
