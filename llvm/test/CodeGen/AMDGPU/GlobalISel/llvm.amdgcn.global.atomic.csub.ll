; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -global-isel -mtriple=amdgcn-amd-amdhsa -mcpu=gfx1030 -verify-machineinstrs < %s | FileCheck %s -check-prefix=GCN

define i32 @global_atomic_csub(i32 addrspace(1)* %ptr, i32 %data) {
; GCN-LABEL: global_atomic_csub:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GCN-NEXT:    s_waitcnt_vscnt null, 0x0
; GCN-NEXT:    global_atomic_csub v0, v[0:1], v2, off glc
; GCN-NEXT:    ; implicit-def: $vcc_hi
; GCN-NEXT:    s_waitcnt vmcnt(0)
; GCN-NEXT:    s_setpc_b64 s[30:31]
  %ret = call i32 @llvm.amdgcn.global.atomic.csub.p1i32(i32 addrspace(1)* %ptr, i32 %data)
  ret i32 %ret
}

define i32 @global_atomic_csub_offset(i32 addrspace(1)* %ptr, i32 %data) {
; GCN-LABEL: global_atomic_csub_offset:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GCN-NEXT:    s_waitcnt_vscnt null, 0x0
; GCN-NEXT:    s_movk_i32 s4, 0x1000
; GCN-NEXT:    s_mov_b32 s5, 0
; GCN-NEXT:    v_mov_b32_e32 v3, s4
; GCN-NEXT:    v_mov_b32_e32 v4, s5
; GCN-NEXT:    ; implicit-def: $vcc_hi
; GCN-NEXT:    v_add_co_u32_e64 v0, vcc_lo, v0, v3
; GCN-NEXT:    v_add_co_ci_u32_e32 v1, vcc_lo, v1, v4, vcc_lo
; GCN-NEXT:    global_atomic_csub v0, v[0:1], v2, off glc
; GCN-NEXT:    s_waitcnt vmcnt(0)
; GCN-NEXT:    s_setpc_b64 s[30:31]
  %gep = getelementptr i32, i32 addrspace(1)* %ptr, i64 1024
  %ret = call i32 @llvm.amdgcn.global.atomic.csub.p1i32(i32 addrspace(1)* %gep, i32 %data)
  ret i32 %ret
}

define void @global_atomic_csub_nortn(i32 addrspace(1)* %ptr, i32 %data) {
; GCN-LABEL: global_atomic_csub_nortn:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GCN-NEXT:    s_waitcnt_vscnt null, 0x0
; GCN-NEXT:    global_atomic_csub v0, v[0:1], v2, off glc
; GCN-NEXT:    ; implicit-def: $vcc_hi
; GCN-NEXT:    s_waitcnt vmcnt(0)
; GCN-NEXT:    s_setpc_b64 s[30:31]
  %ret = call i32 @llvm.amdgcn.global.atomic.csub.p1i32(i32 addrspace(1)* %ptr, i32 %data)
  ret void
}

define void @global_atomic_csub_offset_nortn(i32 addrspace(1)* %ptr, i32 %data) {
; GCN-LABEL: global_atomic_csub_offset_nortn:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GCN-NEXT:    s_waitcnt_vscnt null, 0x0
; GCN-NEXT:    s_movk_i32 s4, 0x1000
; GCN-NEXT:    s_mov_b32 s5, 0
; GCN-NEXT:    v_mov_b32_e32 v3, s4
; GCN-NEXT:    v_mov_b32_e32 v4, s5
; GCN-NEXT:    ; implicit-def: $vcc_hi
; GCN-NEXT:    v_add_co_u32_e64 v0, vcc_lo, v0, v3
; GCN-NEXT:    v_add_co_ci_u32_e32 v1, vcc_lo, v1, v4, vcc_lo
; GCN-NEXT:    global_atomic_csub v0, v[0:1], v2, off glc
; GCN-NEXT:    s_waitcnt vmcnt(0)
; GCN-NEXT:    s_setpc_b64 s[30:31]
  %gep = getelementptr i32, i32 addrspace(1)* %ptr, i64 1024
  %ret = call i32 @llvm.amdgcn.global.atomic.csub.p1i32(i32 addrspace(1)* %gep, i32 %data)
  ret void
}

define amdgpu_kernel void @global_atomic_csub_sgpr_base_offset(i32 addrspace(1)* %ptr, i32 %data) {
; GCN-LABEL: global_atomic_csub_sgpr_base_offset:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_clause 0x1
; GCN-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x0
; GCN-NEXT:    s_load_dword s2, s[4:5], 0x8
; GCN-NEXT:    ; implicit-def: $vcc_hi
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_add_u32 s0, s0, 0x1000
; GCN-NEXT:    s_addc_u32 s1, s1, 0
; GCN-NEXT:    v_mov_b32_e32 v0, s0
; GCN-NEXT:    v_mov_b32_e32 v1, s1
; GCN-NEXT:    v_mov_b32_e32 v2, s2
; GCN-NEXT:    global_atomic_csub v0, v[0:1], v2, off glc
; GCN-NEXT:    s_waitcnt vmcnt(0)
; GCN-NEXT:    global_store_dword v[0:1], v0, off
; GCN-NEXT:    s_endpgm
  %gep = getelementptr i32, i32 addrspace(1)* %ptr, i64 1024
  %ret = call i32 @llvm.amdgcn.global.atomic.csub.p1i32(i32 addrspace(1)* %gep, i32 %data)
  store i32 %ret, i32 addrspace(1)* undef
  ret void
}

define amdgpu_kernel void @global_atomic_csub_sgpr_base_offset_nortn(i32 addrspace(1)* %ptr, i32 %data) {
; GCN-LABEL: global_atomic_csub_sgpr_base_offset_nortn:
; GCN:       ; %bb.0:
; GCN-NEXT:    s_clause 0x1
; GCN-NEXT:    s_load_dwordx2 s[0:1], s[4:5], 0x0
; GCN-NEXT:    s_load_dword s2, s[4:5], 0x8
; GCN-NEXT:    s_waitcnt lgkmcnt(0)
; GCN-NEXT:    s_add_u32 s0, s0, 0x1000
; GCN-NEXT:    s_addc_u32 s1, s1, 0
; GCN-NEXT:    v_mov_b32_e32 v0, s0
; GCN-NEXT:    v_mov_b32_e32 v1, s1
; GCN-NEXT:    v_mov_b32_e32 v2, s2
; GCN-NEXT:    global_atomic_csub v0, v[0:1], v2, off glc
; GCN-NEXT:    s_endpgm
  %gep = getelementptr i32, i32 addrspace(1)* %ptr, i64 1024
  %ret = call i32 @llvm.amdgcn.global.atomic.csub.p1i32(i32 addrspace(1)* %gep, i32 %data)
  ret void
}

declare i32 @llvm.amdgcn.global.atomic.csub.p1i32(i32 addrspace(1)* nocapture, i32) #1

attributes #0 = { nounwind willreturn }
attributes #1 = { argmemonly nounwind }
