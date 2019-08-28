// RUN: not llvm-mc -arch=amdgcn -show-encoding %s 2>&1 | FileCheck %s --check-prefix=GFX67 --check-prefix=GCN
// RUN: not llvm-mc -arch=amdgcn -mcpu=tahiti -show-encoding %s 2>&1 | FileCheck %s --check-prefix=GFX67 --check-prefix=GCN
// RUN: not llvm-mc -arch=amdgcn -mcpu=fiji -show-encoding %s 2>&1 | FileCheck %s --check-prefix=GFX89 --check-prefix=GCN
// RUN: not llvm-mc -arch=amdgcn -mcpu=gfx900 -show-encoding %s 2>&1 | FileCheck %s --check-prefix=GFX89 --check-prefix=GCN

v_add_f32_e64 v0, v1
// GCN: error: too few operands for instruction

v_div_scale_f32  v24, vcc, v22, 1.1, v22
// GCN: error: invalid literal operand

v_mqsad_u32_u8 v[0:3], s[2:3], v4, v[0:3]
// GFX67: error: instruction not supported on this GPU
// GFX89: error: destination must be different than all sources

v_mqsad_pk_u16_u8 v[0:1], v[1:2], v9, v[4:5]
// GCN: error: destination must be different than all sources

v_mqsad_pk_u16_u8 v[1:2], v[1:2], v9, v[4:5]
// GCN: error: destination must be different than all sources

v_mqsad_pk_u16_u8 v[2:3], v[1:2], v9, v[4:5]
// GCN: error: destination must be different than all sources

v_mqsad_pk_u16_u8 v[3:4], v[0:1], v9, v[4:5]
// GCN: error: destination must be different than all sources

v_mqsad_pk_u16_u8 v[4:5], v[1:2], v9, v[4:5]
// GCN: error: destination must be different than all sources

v_mqsad_pk_u16_u8 v[5:6], v[1:2], v9, v[4:5]
// GCN: error: destination must be different than all sources

v_mqsad_pk_u16_u8 v[8:9], v[1:2], v9, v[4:5]
// GCN: error: destination must be different than all sources

v_mqsad_pk_u16_u8 v[9:10], v[1:2], v9, v[4:5]
// GCN: error: destination must be different than all sources

v_cmp_eq_f32_e64 vcc, v0, v1 mul:2
// GCN: error: invalid operand for instruction

v_cmp_le_f64_e64 vcc, v0, v1 mul:4
// GCN: error: invalid operand for instruction

v_cvt_u32_f32_e64 v0, v1 div:2
// GCN: error: invalid operand for instruction

//
// mul
//

v_cvt_f64_i32 v[5:6], s1 mul:3
// GCN: error: invalid mul value.

//
// v_interp*
//

v_interp_mov_f32_e64 v5, p10, attr0.x high
// GCN: error: invalid operand for instruction

v_interp_mov_f32_e64 v5, p10, attr0.x v0
// GCN: error: invalid operand for instruction

v_interp_p1_f32_e64 v5, v2, attr0.x high
// GCN: error: invalid operand for instruction

v_interp_p1_f32_e64 v5, v2, attr0.x v0
// GCN: error: invalid operand for instruction

v_interp_p2_f32_e64 v255, v2, attr0.x high
// GCN: error: invalid operand for instruction

v_interp_p2_f32_e64 v255, v2, attr0.x v0
// GCN: error: invalid operand for instruction

v_interp_p1ll_f16 v5, p0, attr31.x
// GCN: error: invalid operand for instruction

v_interp_p1ll_f16 v5, v2, attr31.x v0
// GCN: error: invalid operand for instruction

v_interp_p2_f16 v5, v2, attr1.x, v3 mul:2
// GFX67: error: not a valid operand
// GFX89: error: invalid operand for instruction
