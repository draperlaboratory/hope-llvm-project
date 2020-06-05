// RUN: mlir-opt %s -split-input-file -verify-diagnostics

// -----

func @broadcast_to_scalar(%arg0: f32) -> f32 {
  // expected-error@+1 {{'vector.broadcast' op result #0 must be vector of any type values, but got 'f32'}}
  %0 = vector.broadcast %arg0 : f32 to f32
}

// -----

func @broadcast_rank_too_high(%arg0: vector<4x4xf32>) {
  // expected-error@+1 {{'vector.broadcast' op source rank higher than destination rank}}
  %1 = vector.broadcast %arg0 : vector<4x4xf32> to vector<4xf32>
}

// -----

func @broadcast_dim1_mismatch(%arg0: vector<7xf32>) {
  // expected-error@+1 {{'vector.broadcast' op dimension mismatch (7 vs. 3)}}
  %1 = vector.broadcast %arg0 : vector<7xf32> to vector<3xf32>
}

// -----

func @broadcast_dim2_mismatch(%arg0: vector<4x8xf32>) {
  // expected-error@+1 {{'vector.broadcast' op dimension mismatch (4 vs. 1)}}
  %1 = vector.broadcast %arg0 : vector<4x8xf32> to vector<1x8xf32>
}

// -----

func @shuffle_elt_type_mismatch(%arg0: vector<2xf32>, %arg1: vector<2xi32>) {
  // expected-error@+1 {{'vector.shuffle' op failed to verify that second operand v2 and result have same element type}}
  %1 = vector.shuffle %arg0, %arg1 [0, 1] : vector<2xf32>, vector<2xi32>
}

// -----

func @shuffle_rank_mismatch(%arg0: vector<2xf32>, %arg1: vector<4x2xf32>) {
  // expected-error@+1 {{'vector.shuffle' op rank mismatch}}
  %1 = vector.shuffle %arg0, %arg1 [0, 1] : vector<2xf32>, vector<4x2xf32>
}

// -----

func @shuffle_trailing_dim_size_mismatch(%arg0: vector<2x2xf32>, %arg1: vector<2x4xf32>) {
  // expected-error@+1 {{'vector.shuffle' op dimension mismatch}}
  %1 = vector.shuffle %arg0, %arg1 [0, 1] : vector<2x2xf32>, vector<2x4xf32>
}

// -----

func @shuffle_index_out_of_range(%arg0: vector<2xf32>, %arg1: vector<2xf32>) {
  // expected-error@+1 {{'vector.shuffle' op mask index #2 out of range}}
  %1 = vector.shuffle %arg0, %arg1 [0, 4] : vector<2xf32>, vector<2xf32>
}

// -----

func @shuffle_empty_mask(%arg0: vector<2xf32>, %arg1: vector<2xf32>) {
  // expected-error@+1 {{'vector.shuffle' invalid mask length}}
  %1 = vector.shuffle %arg0, %arg1 [] : vector<2xf32>, vector<2xf32>
}

// -----

func @extract_element(%arg0: vector<4x4xf32>) {
  %c = constant 3 : i32
  // expected-error@+1 {{'vector.extractelement' op expected 1-D vector}}
  %1 = vector.extractelement %arg0[%c : i32] : vector<4x4xf32>
}

// -----

func @extract_vector_type(%arg0: index) {
  // expected-error@+1 {{expected vector type}}
  %1 = vector.extract %arg0[] : index
}

// -----

func @extract_position_empty(%arg0: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected non-empty position attribute}}
  %1 = vector.extract %arg0[] : vector<4x8x16xf32>
}

// -----

func @extract_position_rank_overflow(%arg0: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected position attribute of rank smaller than vector}}
  %1 = vector.extract %arg0[0, 0, 0, 0] : vector<4x8x16xf32>
}

// -----

func @extract_position_rank_overflow_generic(%arg0: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected position attribute of rank smaller than vector}}
  %1 = "vector.extract" (%arg0) { position = [0, 0, 0, 0] } : (vector<4x8x16xf32>) -> (vector<16xf32>)
}

// -----

func @extract_position_overflow(%arg0: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected position attribute #2 to be a non-negative integer smaller than the corresponding vector dimension}}
  %1 = vector.extract %arg0[0, 43, 0] : vector<4x8x16xf32>
}

// -----

func @extract_precise_position_overflow(%arg0: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected position attribute #3 to be a non-negative integer smaller than the corresponding vector dimension}}
  %1 = vector.extract %arg0[3, 7, 16] : vector<4x8x16xf32>
}

// -----

func @extract_position_overflow(%arg0: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected position attribute #3 to be a non-negative integer smaller than the corresponding vector dimension}}
  %1 = vector.extract %arg0[0, 0, -1] : vector<4x8x16xf32>
}

// -----

func @insert_element(%arg0: f32, %arg1: vector<4x4xf32>) {
  %c = constant 3 : i32
  // expected-error@+1 {{'vector.insertelement' op expected 1-D vector}}
  %0 = vector.insertelement %arg0, %arg1[%c : i32] : vector<4x4xf32>
}

// -----

func @insert_element_wrong_type(%arg0: i32, %arg1: vector<4xf32>) {
  %c = constant 3 : i32
  // expected-error@+1 {{'vector.insertelement' op failed to verify that source operand type matches element type of result}}
  %0 = "vector.insertelement" (%arg0, %arg1, %c) : (i32, vector<4xf32>, i32) -> (vector<4xf32>)
}

// -----

func @insert_vector_type(%a: f32, %b: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected non-empty position attribute}}
  %1 = vector.insert %a, %b[] : f32 into vector<4x8x16xf32>
}

// -----

func @insert_vector_type(%a: f32, %b: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected position attribute of rank smaller than dest vector rank}}
  %1 = vector.insert %a, %b[3, 3, 3, 3, 3, 3] : f32 into vector<4x8x16xf32>
}

// -----

func @insert_vector_type(%a: vector<4xf32>, %b: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected position attribute rank + source rank to match dest vector rank}}
  %1 = vector.insert %a, %b[3] : vector<4xf32> into vector<4x8x16xf32>
}

// -----

func @insert_vector_type(%a: f32, %b: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected position attribute rank to match the dest vector rank}}
  %1 = vector.insert %a, %b[3, 3] : f32 into vector<4x8x16xf32>
}

// -----

func @insert_position_overflow(%a: f32, %b: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected position attribute #3 to be a non-negative integer smaller than the corresponding dest vector dimension}}
  %1 = vector.insert %a, %b[0, 0, -1] : f32 into vector<4x8x16xf32>
}

// -----

func @insert_precise_position_overflow(%a: f32, %b: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected position attribute #1 to be a non-negative integer smaller than the corresponding dest vector dimension}}
  %1 = vector.insert %a, %b[4, 7, 15] : f32 into vector<4x8x16xf32>
}

// -----

func @outerproduct_num_operands(%arg0: f32) {
  // expected-error@+1 {{expected at least 2 operands}}
  %1 = vector.outerproduct %arg0 : f32, f32
}
// -----

func @outerproduct_non_vector_operand(%arg0: f32) {
  // expected-error@+1 {{expected 2 vector types}}
  %1 = vector.outerproduct %arg0, %arg0 : f32, f32
}

// -----

func @outerproduct_operand_1(%arg0: vector<4xf32>, %arg1: vector<4x8xf32>) {
  // expected-error@+1 {{expected 1-d vector for operand #1}}
  %1 = vector.outerproduct %arg1, %arg1 : vector<4x8xf32>, vector<4x8xf32>
}

// -----

func @outerproduct_operand_2(%arg0: vector<4xf32>, %arg1: vector<4x8xf32>) {
  // expected-error@+1 {{expected 1-d vector for operand #2}}
  %1 = vector.outerproduct %arg0, %arg1 : vector<4xf32>, vector<4x8xf32>
}

// -----

func @outerproduct_result_generic(%arg0: vector<4xf32>, %arg1: vector<8xf32>) {
  // expected-error@+1 {{expected 2-d vector result}}
  %1 = "vector.outerproduct" (%arg0, %arg1) : (vector<4xf32>, vector<8xf32>) -> (vector<8xf32>)
}

// -----

func @outerproduct_operand_1_dim_generic(%arg0: vector<4xf32>, %arg1: vector<8xf32>) {
  // expected-error@+1 {{expected #1 operand dim to match result dim #1}}
  %1 = "vector.outerproduct" (%arg0, %arg1) : (vector<4xf32>, vector<8xf32>) -> (vector<8x16xf32>)
}

// -----

func @outerproduct_operand_2_dim_generic(%arg0: vector<4xf32>, %arg1: vector<8xf32>) {
  // expected-error@+1 {{expected #2 operand dim to match result dim #2}}
  %1 = "vector.outerproduct" (%arg0, %arg1) : (vector<4xf32>, vector<8xf32>) -> (vector<4x16xf32>)
}

// -----

func @outerproduct_operand_3_result_type_generic(%arg0: vector<4xf32>, %arg1: vector<8xf32>, %arg2: vector<4x16xf32>) {
  // expected-error@+1 {{expected operand #3 of same type as result type}}
  %1 = "vector.outerproduct" (%arg0, %arg1, %arg2) : (vector<4xf32>, vector<8xf32>, vector<4x16xf32>) -> (vector<4x8xf32>)
}

// -----

func @test_vector.transfer_read(%arg0: memref<?x?xf32>) {
  %c3 = constant 3 : index
  %cst = constant 3.0 : f32
  // expected-error@+1 {{requires two types}}
  %0 = vector.transfer_read %arg0[%c3, %c3], %cst { permutation_map = affine_map<()->(0)> } : memref<?x?xf32>
}

// -----

func @test_vector.transfer_read(%arg0: vector<4x3xf32>) {
  %c3 = constant 3 : index
  %f0 = constant 0.0 : f32
  %vf0 = splat %f0 : vector<4x3xf32>
  // expected-error@+1 {{ requires memref type}}
  %0 = vector.transfer_read %arg0[%c3, %c3], %vf0 : vector<4x3xf32>, vector<1x1x2x3xf32>
}

// -----

func @test_vector.transfer_read(%arg0: memref<4x3xf32>) {
  %c3 = constant 3 : index
  %f0 = constant 0.0 : f32
  %vf0 = splat %f0 : vector<4x3xf32>
  // expected-error@+1 {{ requires vector type}}
  %0 = vector.transfer_read %arg0[%c3, %c3], %vf0 : memref<4x3xf32>, f32
}

// -----

func @test_vector.transfer_read(%arg0: memref<?x?xf32>) {
  %c3 = constant 3 : index
  %cst = constant 3.0 : f32
  // expected-error@+1 {{requires 2 indices}}
  %0 = vector.transfer_read %arg0[%c3, %c3, %c3], %cst { permutation_map = affine_map<()->(0)> } : memref<?x?xf32>, vector<128xf32>
}

// -----

func @test_vector.transfer_read(%arg0: memref<?x?xf32>) {
  %c3 = constant 3 : index
  %cst = constant 3.0 : f32
  // expected-error@+1 {{requires a permutation_map with input dims of the same rank as the memref type}}
  %0 = vector.transfer_read %arg0[%c3, %c3], %cst {permutation_map = affine_map<(d0)->(d0)>} : memref<?x?xf32>, vector<128xf32>
}

// -----

func @test_vector.transfer_read(%arg0: memref<?x?xf32>) {
  %c3 = constant 3 : index
  %cst = constant 3.0 : f32
  // expected-error@+1 {{requires a permutation_map with result dims of the same rank as the vector type}}
  %0 = vector.transfer_read %arg0[%c3, %c3], %cst {permutation_map = affine_map<(d0, d1)->(d0, d1)>} : memref<?x?xf32>, vector<128xf32>
}

// -----

func @test_vector.transfer_read(%arg0: memref<?x?xf32>) {
  %c3 = constant 3 : index
  %cst = constant 3.0 : f32
  // expected-error@+1 {{requires a projected permutation_map (at most one dim or the zero constant can appear in each result)}}
  %0 = vector.transfer_read %arg0[%c3, %c3], %cst {permutation_map = affine_map<(d0, d1)->(d0 + d1)>} : memref<?x?xf32>, vector<128xf32>
}

// -----

func @test_vector.transfer_read(%arg0: memref<?x?xf32>) {
  %c3 = constant 3 : index
  %cst = constant 3.0 : f32
  // expected-error@+1 {{requires a projected permutation_map (at most one dim or the zero constant can appear in each result)}}
  %0 = vector.transfer_read %arg0[%c3, %c3], %cst {permutation_map = affine_map<(d0, d1)->(d0 + 1)>} : memref<?x?xf32>, vector<128xf32>
}

// -----

func @test_vector.transfer_read(%arg0: memref<?x?x?xf32>) {
  %c3 = constant 3 : index
  %cst = constant 3.0 : f32
  // expected-error@+1 {{requires a permutation_map that is a permutation (found one dim used more than once)}}
  %0 = vector.transfer_read %arg0[%c3, %c3, %c3], %cst {permutation_map = affine_map<(d0, d1, d2)->(d0, d0)>} : memref<?x?x?xf32>, vector<3x7xf32>
}

// -----

func @test_vector.transfer_read(%arg0: memref<?x?xvector<4x3xf32>>) {
  %c3 = constant 3 : index
  %f0 = constant 0.0 : f32
  %vf0 = splat %f0 : vector<4x3xf32>
  // expected-error@+1 {{requires memref and vector types of the same elemental type}}
  %0 = vector.transfer_read %arg0[%c3, %c3], %vf0 {permutation_map = affine_map<(d0, d1)->(d0, d1)>} : memref<?x?xvector<4x3xf32>>, vector<1x1x4x3xi32>
}

// -----

func @test_vector.transfer_read(%arg0: memref<?x?xvector<4x3xf32>>) {
  %c3 = constant 3 : index
  %f0 = constant 0.0 : f32
  %vf0 = splat %f0 : vector<4x3xf32>
  // expected-error@+1 {{requires memref vector element and vector result ranks to match}}
  %0 = vector.transfer_read %arg0[%c3, %c3], %vf0 {permutation_map = affine_map<(d0, d1)->(d0, d1)>} : memref<?x?xvector<4x3xf32>>, vector<3xf32>
}

// -----

func @test_vector.transfer_read(%arg0: memref<?x?xvector<4x3xf32>>) {
  %c3 = constant 3 : index
  %f0 = constant 0.0 : f32
  %vf0 = splat %f0 : vector<4x3xf32>
  // expected-error@+1 {{ requires memref vector element shape to match suffix of vector result shape}}
  %0 = vector.transfer_read %arg0[%c3, %c3], %vf0 {permutation_map = affine_map<(d0, d1)->(d0, d1)>} : memref<?x?xvector<4x3xf32>>, vector<1x1x2x3xf32>
}

// -----

func @test_vector.transfer_read(%arg0: memref<?x?xvector<2x3xf32>>) {
  %c3 = constant 3 : index
  %f0 = constant 0.0 : f32
  %vf0 = splat %f0 : vector<2x3xf32>
  // expected-error@+1 {{ expects the optional masked attr of same rank as permutation_map results: affine_map<(d0, d1) -> (d0, d1)>}}
  %0 = vector.transfer_read %arg0[%c3, %c3], %vf0 {masked = [false], permutation_map = affine_map<(d0, d1)->(d0, d1)>} : memref<?x?xvector<2x3xf32>>, vector<1x1x2x3xf32>
}

// -----

func @test_vector.transfer_write(%arg0: memref<?x?xf32>) {
  %c3 = constant 3 : index
  %cst = constant 3.0 : f32
  // expected-error@+1 {{requires two types}}
  vector.transfer_write %arg0, %arg0[%c3, %c3] : memref<?x?xf32>
}

// -----

func @test_vector.transfer_write(%arg0: memref<vector<4x3xf32>>) {
  %c3 = constant 3 : index
  %f0 = constant 0.0 : f32
  %vf0 = splat %f0 : vector<4x3xf32>
  // expected-error@+1 {{ requires vector type}}
  vector.transfer_write %arg0, %arg0[%c3, %c3] : memref<vector<4x3xf32>>, vector<4x3xf32>
}

// -----

func @test_vector.transfer_write(%arg0: vector<4x3xf32>) {
  %c3 = constant 3 : index
  %f0 = constant 0.0 : f32
  %vf0 = splat %f0 : vector<4x3xf32>
  // expected-error@+1 {{ requires memref type}}
  vector.transfer_write %arg0, %arg0[%c3, %c3] : vector<4x3xf32>, f32
}

// -----

func @test_vector.transfer_write(%arg0: memref<?x?xf32>) {
  %c3 = constant 3 : index
  %cst = constant dense<3.0> : vector<128 x f32>
  // expected-error@+1 {{expected 5 operand types but had 4}}
  %0 = "vector.transfer_write"(%cst, %arg0, %c3, %c3, %c3) {permutation_map = affine_map<()->(0)>} : (vector<128xf32>, memref<?x?xf32>, index, index) -> ()
}

// -----

func @test_vector.transfer_write(%arg0: memref<?x?xf32>) {
  %c3 = constant 3 : index
  %cst = constant dense<3.0> : vector<128 x f32>
  // expected-error@+1 {{requires 2 indices}}
  vector.transfer_write %cst, %arg0[%c3, %c3, %c3] {permutation_map = affine_map<()->(0)>} : vector<128xf32>, memref<?x?xf32>
}

// -----

func @test_vector.transfer_write(%arg0: memref<?x?xf32>) {
  %c3 = constant 3 : index
  %cst = constant dense<3.0> : vector<128 x f32>
  // expected-error@+1 {{requires a permutation_map with input dims of the same rank as the memref type}}
  vector.transfer_write %cst, %arg0[%c3, %c3] {permutation_map = affine_map<(d0)->(d0)>} : vector<128xf32>, memref<?x?xf32>
}

// -----

func @test_vector.transfer_write(%arg0: memref<?x?xf32>) {
  %c3 = constant 3 : index
  %cst = constant dense<3.0> : vector<128 x f32>
  // expected-error@+1 {{requires a permutation_map with result dims of the same rank as the vector type}}
  vector.transfer_write %cst, %arg0[%c3, %c3] {permutation_map = affine_map<(d0, d1)->(d0, d1)>} : vector<128xf32>, memref<?x?xf32>
}

// -----

func @test_vector.transfer_write(%arg0: memref<?x?xf32>) {
  %c3 = constant 3 : index
  %cst = constant dense<3.0> : vector<128 x f32>
  // expected-error@+1 {{requires a projected permutation_map (at most one dim or the zero constant can appear in each result)}}
  vector.transfer_write %cst, %arg0[%c3, %c3] {permutation_map = affine_map<(d0, d1)->(d0 + d1)>} : vector<128xf32>, memref<?x?xf32>
}

// -----

func @test_vector.transfer_write(%arg0: memref<?x?xf32>) {
  %c3 = constant 3 : index
  %cst = constant dense<3.0> : vector<128 x f32>
  // expected-error@+1 {{requires a projected permutation_map (at most one dim or the zero constant can appear in each result)}}
  vector.transfer_write %cst, %arg0[%c3, %c3] {permutation_map = affine_map<(d0, d1)->(d0 + 1)>} : vector<128xf32>, memref<?x?xf32>
}

// -----

func @test_vector.transfer_write(%arg0: memref<?x?x?xf32>) {
  %c3 = constant 3 : index
  %cst = constant dense<3.0> : vector<3 x 7 x f32>
  // expected-error@+1 {{requires a permutation_map that is a permutation (found one dim used more than once)}}
  vector.transfer_write %cst, %arg0[%c3, %c3, %c3] {permutation_map = affine_map<(d0, d1, d2)->(d0, d0)>} : vector<3x7xf32>, memref<?x?x?xf32>
}

// -----

func @insert_strided_slice(%a: vector<4x4xf32>, %b: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected offsets of same size as destination vector rank}}
  %1 = vector.insert_strided_slice %a, %b {offsets = [100], strides = [1, 1]} : vector<4x4xf32> into vector<4x8x16xf32>
}

// -----

func @insert_strided_slice(%a: vector<4x4xf32>, %b: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected strides of same size as source vector rank}}
  %1 = vector.insert_strided_slice %a, %b {offsets = [2, 2, 2], strides = [1]} : vector<4x4xf32> into vector<4x8x16xf32>
}

// -----

func @insert_strided_slice(%a: vector<4x4xf32>, %b: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected source rank to be smaller than destination rank}}
  %1 = vector.insert_strided_slice %b, %a {offsets = [2, 2], strides = [1, 1, 1]} : vector<4x8x16xf32> into vector<4x4xf32>
}

// -----

func @insert_strided_slice(%a: vector<4x4xf32>, %b: vector<4x8x16xf32>) {
  // expected-error@+1 {{op expected offsets dimension 0 to be confined to [0, 4)}}
  %1 = vector.insert_strided_slice %a, %b {offsets = [100,100,100], strides = [1, 1]} : vector<4x4xf32> into vector<4x8x16xf32>
}

// -----

func @insert_strided_slice(%a: vector<4x4xf32>, %b: vector<4x8x16xf32>) {
  // expected-error@+1 {{op expected strides to be confined to [1, 2)}}
  %1 = vector.insert_strided_slice %a, %b {offsets = [2, 2, 2], strides = [100, 100]} : vector<4x4xf32> into vector<4x8x16xf32>
}

// -----

func @insert_strided_slice(%a: vector<4x4xf32>, %b: vector<4x8x16xf32>) {
  // expected-error@+1 {{op expected sum(offsets, source vector shape) dimension 1 to be confined to [1, 9)}}
  %1 = vector.insert_strided_slice %a, %b {offsets = [2, 7, 2], strides = [1, 1]} : vector<4x4xf32> into vector<4x8x16xf32>
}

// -----

func @extract_strided_slice(%arg0: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected offsets, sizes and strides attributes of same size}}
  %1 = vector.extract_strided_slice %arg0 {offsets = [100], sizes = [2, 2], strides = [1, 1]} : vector<4x8x16xf32> to vector<2x2x16xf32>
}

// -----

func @extract_strided_slice(%arg0: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected offsets attribute of rank smaller than vector rank}}
  %1 = vector.extract_strided_slice %arg0 {offsets = [2, 2, 2, 2], sizes = [2, 2, 2, 2], strides = [1, 1, 1, 1]} : vector<4x8x16xf32> to vector<2x2x16xf32>
}

// -----

func @extract_strided_slice(%arg0: vector<4x8x16xf32>) {
  // expected-error@+1 {{expected offsets attribute of rank smaller than vector rank}}
  %1 = vector.extract_strided_slice %arg0 {offsets = [2, 2, 2, 2], sizes = [2, 2, 2, 2], strides = [1, 1, 1, 1]} : vector<4x8x16xf32> to vector<2x2x16xf32>
}

// -----

func @extract_strided_slice(%arg0: vector<4x8x16xf32>) {
  // expected-error@+1 {{op expected offsets dimension 0 to be confined to [0, 4)}}
  %1 = vector.extract_strided_slice %arg0 {offsets = [100], sizes = [100], strides = [100]} : vector<4x8x16xf32> to vector<100x8x16xf32>
}

// -----

func @extract_strided_slice(%arg0: vector<4x8x16xf32>) {
  // expected-error@+1 {{op expected sizes dimension 0 to be confined to [1, 5)}}
  %1 = vector.extract_strided_slice %arg0 {offsets = [2], sizes = [100], strides = [100]} : vector<4x8x16xf32> to vector<100x8x16xf32>
}

// -----

func @extract_strided_slice(%arg0: vector<4x8x16xf32>) {
  // expected-error@+1 {{op expected strides to be confined to [1, 2)}}
  %1 = vector.extract_strided_slice %arg0 {offsets = [2], sizes = [1], strides = [100]} : vector<4x8x16xf32> to vector<1x8x16xf32>
}

// -----

func @extract_strided_slice(%arg0: vector<4x8x16xf32>) {
  // expected-error@+1 {{op expected strides to be confined to [1, 2)}}
  %1 = vector.extract_strided_slice %arg0 {offsets = [2], sizes = [1], strides = [100]} : vector<4x8x16xf32> to vector<1x8x16xf32>
}

// -----

func @extract_strided_slice(%arg0: vector<4x8x16xf32>) {
  // expected-error@+1 {{op expected sum(offsets, sizes) dimension 0 to be confined to [1, 5)}}
  %1 = vector.extract_strided_slice %arg0 {offsets = [2], sizes = [3], strides = [1]} : vector<4x8x16xf32> to vector<3x8x16xf32>
}

// -----

func @extract_strided_slice(%arg0: vector<4x8x16xf32>) {
  // expected-error@+1 {{op expected result type to be 'vector<2x8x16xf32>'}}
  %1 = vector.extract_strided_slice %arg0 {offsets = [2], sizes = [2], strides = [1]} : vector<4x8x16xf32> to vector<3x1xf32>
}

// -----

#contraction_accesses = [
  affine_map<(b0, f0, f1, c0, c1) -> (c0, b0, c1, f0)>,
  affine_map<(b0, f0, f1, c0, c1) -> (b0, c1, c0, f1)>,
  affine_map<(b0, f0, f1, c0, c1) -> (b0, f0, f1)>,
  affine_map<(b0, f0, f1, c0, c1) -> (b0, f0, f1)>
]
#contraction_trait = {
  indexing_maps = #contraction_accesses,
  iterator_types = ["parallel", "parallel", "parallel", "reduction", "reduction"]
}
func @contraction(%arg0: vector<7x8x16x15xf32>, %arg1: vector<8x16x7x5xf32>,
                  %arg2: vector<8x15x5xf32>, %arg3 :  vector<8x15x8x5xf32>,
                  %arg4 : index) {
  // expected-error@+1 {{expected an indexing map for each vector operand}}
  %0 = vector.contract #contraction_trait %arg0, %arg1, %arg2
      : vector<7x8x16x15xf32>, vector<8x16x7x5xf32> into vector<8x15x5xf32>
}

// -----

#contraction_accesses = [
  affine_map<(b0, f0, f1, c0, c1) -> (c0, c0, c1, f0)>,
  affine_map<(b0, f0, f1, c0, c1) -> (b0, c1, c0, f1)>,
  affine_map<(b0, f0, f1, c0, c1) -> (b0, f0, f1)>
]
#contraction_trait = {
  indexing_maps = #contraction_accesses,
  iterator_types = ["parallel", "parallel", "parallel", "reduction", "reduction"]
}
func @contraction(%arg0: vector<7x8x16x15xf32>, %arg1: vector<8x16x7x5xf32>,
                  %arg2: vector<8x15x5xf32>, %arg3 :  vector<8x15x8x5xf32>,
                  %arg4 : index) {
  // expected-error@+1 {{expected indexing map 0 to be a projected permutation of its inputs}}
  %0 = vector.contract #contraction_trait %arg0, %arg1, %arg2
      : vector<7x8x16x15xf32>, vector<8x16x7x5xf32> into vector<8x15x5xf32>
}

// -----

#contraction_accesses = [
  affine_map<(b0, f0, f1, c0, c1) -> (c0, b0, c1, f0)>,
  affine_map<(b0, f0, f1, c0, c1)[s0] -> (b0, s0, c0, f1)>,
  affine_map<(b0, f0, f1, c0, c1) -> (b0, f0, f1)>
]
#contraction_trait = {
  indexing_maps = #contraction_accesses,
  iterator_types = ["parallel", "parallel", "parallel", "reduction", "reduction"]
}
func @contraction(%arg0: vector<7x8x16x15xf32>, %arg1: vector<8x16x7x5xf32>,
                  %arg2: vector<8x15x5xf32>, %arg3 :  vector<8x15x8x5xf32>,
                  %arg4 : index) {
  // expected-error@+1 {{op expected indexing map 1 to have no symbols}}
  %0 = vector.contract #contraction_trait %arg0, %arg1, %arg2
      : vector<7x8x16x15xf32>, vector<8x16x7x5xf32> into vector<8x15x5xf32>
}

// -----

#contraction_accesses = [
  affine_map<(b0, f0, f1, c0, c1) -> (c0, b0, c1, f0)>,
  affine_map<(b0, f0, f1, c0, c1) -> (b0, c1, c0, f1)>,
  affine_map<(b0, f0, f1, c1) -> (b0, f0, f1)>
]
#contraction_trait = {
  indexing_maps = #contraction_accesses,
  iterator_types = ["parallel", "parallel", "parallel", "reduction", "reduction"]
}
func @contraction(%arg0: vector<7x8x16x15xf32>, %arg1: vector<8x16x7x5xf32>,
                  %arg2: vector<8x15x5xf32>, %arg3 :  vector<8x15x8x5xf32>,
                  %arg4 : index) {
  // expected-error@+1 {{expected indexing map 2 to have 5 number of inputs}}
  %0 = vector.contract #contraction_trait %arg0, %arg1, %arg2
      : vector<7x8x16x15xf32>, vector<8x16x7x5xf32> into vector<8x15x5xf32>
}

// -----

#contraction_accesses = [
  affine_map<(b0, f0, f1, c0, c1) -> (c0, b0, c1, f0)>,
  affine_map<(b0, f0, f1, c0, c1) -> (b0, c1, f1)>,
  affine_map<(b0, f0, f1, c0, c1) -> (b0, f0, f1)>
]
#contraction_trait = {
  indexing_maps = #contraction_accesses,
  iterator_types = ["parallel", "parallel", "parallel", "reduction", "reduction"]
}
func @contraction(%arg0: vector<7x8x16x15xf32>, %arg1: vector<8x16x7x5xf32>,
                  %arg2: vector<8x15x5xf32>, %arg3 :  vector<8x15x8x5xf32>,
                  %arg4 : index) {
  // expected-error@+1 {{expected indexing map 1 to have 4 number of outputs}}
  %0 = vector.contract #contraction_trait %arg0, %arg1, %arg2
      : vector<7x8x16x15xf32>, vector<8x16x7x5xf32> into vector<8x15x5xf32>
}

// -----

#contraction_accesses = [
  affine_map<(b0, f0, f1, b1, b2) -> (b1, b0, b2, f0)>,
  affine_map<(b0, f0, f1, b1, b2) -> (b0, b2, b1, f1)>,
  affine_map<(b0, f0, f1, b1, b2) -> (b0, f0, f1)>
]
#contraction_trait = {
  indexing_maps = #contraction_accesses,
  iterator_types = ["parallel", "parallel", "parallel", "parallel", "parallel"]
}
func @contraction(%arg0: vector<7x8x16x15xf32>, %arg1: vector<8x16x7x5xf32>,
                  %arg2: vector<8x15x5xf32>, %arg3 :  vector<8x15x8x5xf32>,
                  %arg4 : index) {
  // expected-error@+1 {{op expected at least one contracting dimension pair}}
  %0 = vector.contract #contraction_trait %arg0, %arg1, %arg2
      : vector<7x8x16x15xf32>, vector<8x16x7x5xf32> into vector<8x15x5xf32>
}

// -----

#contraction_accesses = [
  affine_map<(b0, f0, f1, c0, c1) -> (c1, b0, c0, f0)>,
  affine_map<(b0, f0, f1, c0, c1) -> (b0, c1, c0, f1)>,
  affine_map<(b0, f0, f1, c0, c1) -> (b0, f0, f1)>
]
#contraction_trait = {
  indexing_maps = #contraction_accesses,
  iterator_types = ["parallel", "parallel", "parallel", "reduction", "reduction"]
}
func @contraction(%arg0: vector<7x8x16x15xf32>, %arg1: vector<8x16x7x5xf32>,
                  %arg2: vector<8x15x5xf32>, %arg3 :  vector<8x15x8x5xf32>,
                  %arg4 : index) {
  // expected-error@+1 {{invalid contracting dimension map}}
  %0 = vector.contract #contraction_trait %arg0, %arg1, %arg2
      : vector<7x8x16x15xf32>, vector<8x16x7x5xf32> into vector<8x15x5xf32>
}

// -----

#contraction_accesses = [
  affine_map<(b0, f0, f1, c0, c1) -> (c0, b0, c1, f0)>,
  affine_map<(b0, f0, f1, c0, c1) -> (f1, c1, c0, b0)>,
  affine_map<(b0, f0, f1, c0, c1) -> (b0, f0, f1)>
]
#contraction_trait = {
  indexing_maps = #contraction_accesses,
  iterator_types = ["parallel", "parallel", "parallel", "reduction", "reduction"]
}
func @contraction(%arg0: vector<7x8x16x15xf32>, %arg1: vector<8x16x7x5xf32>,
                  %arg2: vector<8x15x5xf32>, %arg3 :  vector<8x15x8x5xf32>,
                  %arg4 : index) {
  // expected-error@+1 {{invalid batch dimension map}}
  %0 = vector.contract #contraction_trait %arg0, %arg1, %arg2
      : vector<7x8x16x15xf32>, vector<8x16x7x5xf32> into vector<8x15x5xf32>
}

// -----

#contraction_accesses = [
  affine_map<(b0, f0, f1, c0, c1) -> (c0, b0, c1, f0)>,
  affine_map<(b0, f0, f1, c0, c1) -> (b0, c1, c0, f1)>,
  affine_map<(b0, f0, f1, c0, c1) -> (b0, f0, f1)>
]
#contraction_trait = {
  indexing_maps = #contraction_accesses,
  iterator_types = ["parallel", "parallel", "parallel", "reduction", "reduction"]
}
func @contraction(%arg0: vector<7x8x16x15xf32>, %arg1: vector<8x16x7x5xf32>,
                  %arg2: vector<88x15x5xf32>, %arg3 :  vector<8x15x8x5xf32>,
                  %arg4 : index) {
  // expected-error@+1 {{invalid accumulator/result vector shape}}
  %0 = vector.contract #contraction_trait %arg0, %arg1, %arg2
      : vector<7x8x16x15xf32>, vector<8x16x7x5xf32> into vector<88x15x5xf32>
}

// -----

#contraction_accesses = [
  affine_map<(b0, f0, f1, c0, c1) -> (c0, b0, c1, f0)>,
  affine_map<(b0, f0, f1, c0, c1) -> (b0, c1, c0, f1)>,
  affine_map<(b0, f0, f1, c0, c1) -> (b0, f0, f1)>
]
#contraction_trait = {
  indexing_maps = #contraction_accesses,
  iterator_types = ["parallel", "parallel", "parallel", "reduction", "reduction"]
}
func @contraction(%arg0: vector<7x8x16x15xf32>, %arg1: vector<8x16x7x5xf32>,
                  %arg2: vector<8x15x5xf32>, %arg3 :  vector<8x15x8x5xf32>,
                  %arg4 : index) {
  %lhs_mask = vector.constant_mask [7, 8, 16, 15] : vector<7x8x16x15xi1>
  %rhs_mask = vector.constant_mask [8, 16, 7, 5] : vector<8x16x7x5xi1>
  // expected-error@+1 {{expected zero or exactly 2 vector mask operands}}
  %0 = vector.contract #contraction_trait %arg0, %arg1, %arg2, %lhs_mask
      : vector<7x8x16x15xf32>, vector<8x16x7x5xf32> into vector<8x15x5xf32>
}

// -----

#contraction_accesses = [
        affine_map<(i, j, k) -> (i, k)>,
        affine_map<(i, j, k) -> (k, j)>,
        affine_map<(i, j, k) -> (i, j)>
      ]
#contraction_trait = {
        indexing_maps = #contraction_accesses,
        iterator_types = ["parallel", "parallel", "reduction"]
      }
func @contraction(%arg0: vector<4x3xi32>,
                  %arg1: vector<3x7xf32>,
                  %arg2: vector<4x7xf32>) -> vector<4x7xf32> {
  // expected-error@+1 {{'vector.contract' op failed to verify that first operand lhs and result have same element type}}
  %0 = vector.contract #contraction_trait %arg0, %arg1, %arg2
    : vector<4x3xi32>, vector<3x7xf32> into vector<4x7xf32>
}

// -----

#contraction_accesses = [
  affine_map<(m, n, k) -> (m, k)>,
  affine_map<(m, n, k) -> (k, n)>,
  affine_map<(m, n, k) -> (n, m)>
]
#contraction_trait = {
  indexing_maps = #contraction_accesses,
  iterator_types = ["parallel", "parallel", "reduction"]
}
func @contraction(%arg0: vector<2x1xf32>, %arg1: vector<1x3xf32>, %arg2: vector<2x3xf32>)
-> vector<3x2xf32>
{
// expected-error@+1 {{invalid accumulator/result vector shape, expected: 'vector<3x2xf32>'}}
  %0 = vector.contract #contraction_trait %arg0, %arg1, %arg2
    : vector<2x1xf32>, vector<1x3xf32> into vector<2x3xf32>
  return %0 : vector<2x3xf32>
}

// -----

func @create_mask() {
  %c2 = constant 2 : index
  %c3 = constant 3 : index
  // expected-error@+1 {{must specify an operand for each result vector dimension}}
  %0 = vector.create_mask %c3, %c2 : vector<4x3x7xi1>
}


// -----

func @constant_mask() {
  // expected-error@+1 {{must specify array attr of size equal vector result rank}}
  %0 = vector.constant_mask [3, 2, 7] : vector<4x3xi1>
}

// -----

func @constant_mask_out_of_bounds() {
  // expected-error@+1 {{array attr of size out of bounds of vector result dimension size}}
  %0 = vector.constant_mask [-1, 2] : vector<4x3xi1>
}

// -----

func @constant_mask_out_of_bounds() {
  // expected-error@+1 {{array attr of size out of bounds of vector result dimension size}}
  %0 = vector.constant_mask [3, 4] : vector<4x3xi1>
}

// -----

func @constant_mask_with_zero_mask_dim_size() {
  // expected-error@+1 {{expected all mask dim sizes to be zeros, as a result of conjunction with zero mask dim}}
  %0 = vector.constant_mask [0, 2] : vector<4x3xi1>
}


// -----

func @extract_slices_non_unit_strides(%arg0 : vector<4x2xf32>) {
  // expected-error@+1 {{requires unit strides}}
  %0 = vector.extract_slices %arg0, [2, 2], [1, 3]
    : vector<4x2xf32> into tuple<vector<2x2xf32>, vector<2x2xf32>>
}

// -----

func @extract_slices_tuple_element_wrong_rank(%arg0 : vector<4x2xf32>) {
  // expected-error@+1 {{requires vector tuple elements of rank 2}}
  %0 = vector.extract_slices %arg0, [2, 2], [1, 1]
    : vector<4x2xf32> into tuple<vector<2x2xf32>, vector<2x2x3xf32>>
}

// -----

func @extract_slices_sizes_strides_wrong_rank(%arg0 : vector<4x2xf32>) {
  // expected-error@+1 {{requires sizes and strides of rank}}
  %0 = vector.extract_slices %arg0, [2, 2], [1, 1, 1]
    : vector<4x2xf32> into tuple<vector<2x2xf32>, vector<2x2xf32>>
}

// -----

func @extract_slices_invalid_tuple_element_type(%arg0 : vector<4x2xf32>) {
  // expected-error@+1 {{invalid tuple element type}}
  %0 = vector.extract_slices %arg0, [2, 2], [1, 1]
    : vector<4x2xf32> into tuple<vector<2x2xf32>, vector<4x2xf32>>
}

// -----

func @tuple_of_non_vectors(%arg0 : vector<4x2xf32>) {
  %c0 = constant 0 : index
  // expected-error@+1 {{must be vector of any type values}}
  %0 = vector.tuple %arg0, %c0 : vector<4x2xf32>, index
}

// -----

func @tuple_get_of_non_vectors(%arg0 : tuple<vector<4x2xf32>, index>) {
  // expected-error@+1 {{vector of any type values}}
  %0 = vector.tuple_get %arg0, 0 : tuple<vector<4x2xf32>, index>
}

// -----

func @insert_slices_non_unit_strides(%arg0 : tuple<vector<2x2xf32>, vector<2x2xf32>>) {
  // expected-error@+1 {{requires unit strides}}
  %0 = vector.insert_slices %arg0, [2, 2], [1, 3]
    : tuple<vector<2x2xf32>, vector<2x2xf32>> into vector<4x2xf32>
}

// -----

func @insert_slices_tuple_element_wrong_rank(%arg0 : tuple<vector<2x2xf32>, vector<2x2x3xf32>>) {
  // expected-error@+1 {{requires vector tuple elements of rank 2}}
  %0 = vector.insert_slices %arg0, [2, 2], [1, 1]
    : tuple<vector<2x2xf32>, vector<2x2x3xf32>> into vector<4x2xf32>
}

// -----

func @insert_slices_sizes_strides_wrong_rank(%arg0 : tuple<vector<2x2xf32>, vector<2x2xf32>>) {
  // expected-error@+1 {{requires sizes and strides of rank}}
  %0 = vector.insert_slices %arg0, [2, 2], [1, 1, 1]
    : tuple<vector<2x2xf32>, vector<2x2xf32>> into vector<4x2xf32>
}

// -----

func @insert_slices_invalid_tuple_element_type(%arg0 : tuple<vector<2x2xf32>, vector<4x2xf32>>) {
  // expected-error@+1 {{invalid tuple element type}}
  %0 = vector.insert_slices %arg0, [2, 2], [1, 1]
    : tuple<vector<2x2xf32>, vector<4x2xf32>> into vector<4x2xf32>
}

// -----

func @print_no_result(%arg0 : f32) -> i32 {
  // expected-error@+1 {{cannot name an operation with no results}}
  %0 = vector.print %arg0 : f32
}

// -----

func @reshape_bad_input_shape(%arg0 : vector<3x2x4xf32>) {
  %c2 = constant 2 : index
  %c3 = constant 3 : index
  %c6 = constant 6 : index
  %c9 = constant 9 : index
  // expected-error@+1 {{invalid input shape for vector type}}
  %1 = vector.reshape %arg0, [%c3, %c6, %c3], [%c2, %c9], [4]
    : vector<3x2x4xf32> to vector<2x3x4xf32>
}

// -----

func @reshape_bad_output_shape(%arg0 : vector<3x2x4xf32>) {
  %c2 = constant 2 : index
  %c3 = constant 3 : index
  %c6 = constant 6 : index
  %c9 = constant 9 : index
  // expected-error@+1 {{invalid output shape for vector type}}
  %1 = vector.reshape %arg0, [%c3, %c6], [%c2, %c9, %c3], [4]
    : vector<3x2x4xf32> to vector<2x3x4xf32>
}

// -----

func @reshape_bad_input_output_shape_product(%arg0 : vector<3x2x4xf32>) {
  %c2 = constant 2 : index
  %c3 = constant 3 : index
  %c6 = constant 6 : index
  %c9 = constant 9 : index
  // expected-error@+1 {{product of input and output shape sizes must match}}
  %1 = vector.reshape %arg0, [%c3, %c6], [%c2, %c6], [4]
    : vector<3x2x4xf32> to vector<2x3x4xf32>
}

// -----

func @reshape_bad_input_fixed_size(%arg0 : vector<3x2x5xf32>) {
  %c2 = constant 2 : index
  %c3 = constant 3 : index
  %c6 = constant 6 : index
  %c9 = constant 9 : index
  // expected-error@+1 {{fixed vector size must match input vector for dim 0}}
  %1 = vector.reshape %arg0, [%c3, %c6], [%c2, %c9], [4]
    : vector<3x2x5xf32> to vector<2x3x4xf32>
}

// -----

func @reshape_bad_output_fixed_size(%arg0 : vector<3x2x4xf32>) {
  %c2 = constant 2 : index
  %c3 = constant 3 : index
  %c6 = constant 6 : index
  %c9 = constant 9 : index
  // expected-error@+1 {{fixed vector size must match output vector for dim 0}}
  %1 = vector.reshape %arg0, [%c3, %c6], [%c2, %c9], [4]
    : vector<3x2x4xf32> to vector<2x3x5xf32>
}

// -----

func @shape_cast_wrong_element_type(%arg0 : vector<5x1x3x2xf32>) {
  // expected-error@+1 {{op source/result vectors must have same element type}}
  %0 = vector.shape_cast %arg0 : vector<5x1x3x2xf32> to vector<15x2xi32>
}

// -----

func @shape_cast_wrong_element_type_tuple(%arg0 : tuple<vector<5x4x2xf32>,
                                                        vector<3x4x2xf32>>) {
  // expected-error@+1 {{op source/result vectors must have same element type}}
  %0 = vector.shape_cast %arg0 : tuple<vector<5x4x2xf32>, vector<3x4x2xf32>> to
                                 tuple<vector<20x2xi32>, vector<12x2xi32>>
}

// -----

func @shape_cast_wrong_num_elements(%arg0 : vector<5x1x3x2xf32>) {
  // expected-error@+1 {{op source/result number of elements must match}}
  %0 = vector.shape_cast %arg0 : vector<5x1x3x2xf32> to vector<10x2xf32>
}

// -----

func @shape_cast_wrong_num_elements_tuple(%arg0 : tuple<vector<5x4x2xf32>,
                                                        vector<3x4x2xf32>>) {
  // expected-error@+1 {{op source/result number of elements must match}}
  %0 = vector.shape_cast %arg0 : tuple<vector<5x4x2xf32>, vector<3x4x2xf32>> to
                                 tuple<vector<21x2xf32>, vector<13x2xf32>>
}

// -----

func @shape_cast_invalid_rank_reduction(%arg0 : vector<5x1x3x2xf32>) {
  // expected-error@+1 {{invalid shape cast}}
  %0 = vector.shape_cast %arg0 : vector<5x1x3x2xf32> to vector<2x15xf32>
}

// -----

func @shape_cast_invalid_rank_reduction_tuple(%arg0
  : tuple<vector<5x4x2xf32>, vector<3x4x2xf32>>) {
  // expected-error@+1 {{invalid shape cast}}
  %0 = vector.shape_cast %arg0: tuple<vector<5x4x2xf32>, vector<3x4x2xf32>> to
                                tuple<vector<10x4xf32>, vector<6x4xf32>>
}

// -----

func @shape_cast_invalid_rank_expansion(%arg0 : vector<15x2xf32>) {
  // expected-error@+1 {{invalid shape cast}}
  %0 = vector.shape_cast %arg0 : vector<15x2xf32> to vector<5x2x3x1xf32>
}

// -----

func @shape_cast_invalid_rank_expansion_tuple(%arg0 : tuple<vector<20x2xf32>,
                                                            vector<12x2xf32>>) {
  // expected-error@+1 {{invalid shape cast}}
  %0 = vector.shape_cast %arg0 : tuple<vector<20x2xf32>, vector<12x2xf32>> to
                                 tuple<vector<5x2x4xf32>, vector<4x3x2xf32>>
}

// -----

func @shape_cast_source_result_different_types(
  %arg1 : tuple<vector<20x2xf32>, vector<12x2xf32>>) {
  // expected-error@+1 {{source/result must be of same type}}
  %1 = vector.shape_cast %arg1 : tuple<vector<20x2xf32>, vector<12x2xf32>> to
                                 vector<5x2x4xf32>
}

// -----

func @shape_cast_different_tuple_sizes(
  %arg1 : tuple<vector<5x4x2xf32>, vector<3x4x2xf32>>) {
  // expected-error@+1 {{op source/result tuples must be the same size}}
  %1 = vector.shape_cast %arg1 : tuple<vector<5x4x2xf32>, vector<3x4x2xf32>> to
                                 tuple<vector<20x2xf32>>
}

// -----

func @reduce_unknown_kind(%arg0: vector<16xf32>) -> f32 {
  // expected-error@+1 {{'vector.reduction' op unknown reduction kind: joho}}
  %0 = vector.reduction "joho", %arg0 : vector<16xf32> into f32
}

// -----

func @reduce_elt_type_mismatch(%arg0: vector<16xf32>) -> i32 {
  // expected-error@+1 {{'vector.reduction' op failed to verify that source operand and result have same element type}}
  %0 = vector.reduction "add", %arg0 : vector<16xf32> into i32
}

// -----

func @reduce_unsupported_attr(%arg0: vector<16xf32>) -> i32 {
  // expected-error@+1 {{attribute 'kind' failed to satisfy constraint: string attribute}}
  %0 = vector.reduction 1234, %arg0 : vector<16xf32> into i32
}

// -----

func @reduce_unsupported_third_argument(%arg0: vector<16xf32>, %arg1: f32) -> f32 {
  // expected-error@+1 {{'vector.reduction' unsupported number of operands}}
  %0 = vector.reduction "add", %arg0, %arg1, %arg1 : vector<16xf32> into f32
}

// -----

func @reduce_unsupported_accumulator_kind(%arg0: vector<16xf32>, %arg1: f32) -> f32 {
  // expected-error@+1 {{'vector.reduction' op no accumulator for reduction kind: min}}
  %0 = vector.reduction "min", %arg0, %arg1 : vector<16xf32> into f32
}

// -----

func @reduce_unsupported_accumulator_type(%arg0: vector<16xi32>, %arg1: i32) -> i32 {
  // expected-error@+1 {{'vector.reduction' op no accumulator for type: 'i32'}}
  %0 = vector.reduction "add", %arg0, %arg1 : vector<16xi32> into i32
}

// -----

func @reduce_unsupported_type(%arg0: vector<16xf32>) -> f32 {
  // expected-error@+1 {{'vector.reduction' op unsupported reduction type}}
  %0 = vector.reduction "xor", %arg0 : vector<16xf32> into f32
}

// -----

func @reduce_unsupported_rank(%arg0: vector<4x16xf32>) -> f32 {
  // expected-error@+1 {{'vector.reduction' op unsupported reduction rank: 2}}
  %0 = vector.reduction "add", %arg0 : vector<4x16xf32> into f32
}

// -----

func @transpose_rank_mismatch(%arg0: vector<4x16x11xf32>) {
  // expected-error@+1 {{'vector.transpose' op vector result rank mismatch: 1}}
  %0 = vector.transpose %arg0, [2, 1, 0] : vector<4x16x11xf32> to vector<100xf32>
}

// -----

func @transpose_length_mismatch(%arg0: vector<4x4xf32>) {
  // expected-error@+1 {{'vector.transpose' op transposition length mismatch: 3}}
  %0 = vector.transpose %arg0, [2, 0, 1] : vector<4x4xf32> to vector<4x4xf32>
}

// -----

func @transpose_index_oob(%arg0: vector<4x4xf32>) {
  // expected-error@+1 {{'vector.transpose' op transposition index out of range: 2}}
  %0 = vector.transpose %arg0, [2, 0] : vector<4x4xf32> to vector<4x4xf32>
}

// -----

func @transpose_index_dup(%arg0: vector<4x4xf32>) {
  // expected-error@+1 {{'vector.transpose' op duplicate position index: 0}}
  %0 = vector.transpose %arg0, [0, 0] : vector<4x4xf32> to vector<4x4xf32>
}

// -----

func @transpose_dim_size_mismatch(%arg0: vector<11x7x3x2xi32>) {
  // expected-error@+1 {{'vector.transpose' op dimension size mismatch at: 0}}
  %0 = vector.transpose %arg0, [3, 0, 1, 2] : vector<11x7x3x2xi32> to vector<2x3x7x11xi32>
}

// -----

func @flat_transpose_type_mismatch(%arg0: vector<16xf32>) {
  // expected-error@+1 {{'vector.flat_transpose' op failed to verify that source operand and result have same element type}}
  %0 = vector.flat_transpose %arg0 { rows = 4: i32, columns = 4: i32 } : vector<16xf32> -> vector<16xf64>
}

// -----

func @type_cast_layout(%arg0: memref<4x3xf32, affine_map<(d0, d1)[s0, s1, s2] -> (d0 * s0 + d1 * s1 + s2)>>) {
  // expected-error@+1 {{expects operand to be a memref with no layout}}
  %0 = vector.type_cast %arg0: memref<4x3xf32, affine_map<(d0, d1)[s0, s1, s2] -> (d0 * s0 + d1 * s1 + s2)>> to memref<vector<4x3xf32>>
}
