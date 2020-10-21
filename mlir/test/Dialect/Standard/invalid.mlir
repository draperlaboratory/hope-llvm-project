// RUN: mlir-opt -split-input-file %s -verify-diagnostics

// CHECK-LABEL: test_index_cast_shape_error
func @test_index_cast_shape_error(%arg0 : tensor<index>) -> tensor<2xi64> {
  // expected-error @+1 {{requires the same shape for all operands and results}}
  %0 = index_cast %arg0 : tensor<index> to tensor<2xi64>
  return %0 : tensor<2xi64>
}

// -----

// CHECK-LABEL: test_index_cast_tensor_error
func @test_index_cast_tensor_error(%arg0 : tensor<index>) -> i64 {
  // expected-error @+1 {{requires the same shape for all operands and results}}
  %0 = index_cast %arg0 : tensor<index> to i64
  return %0 : i64
}

// -----

func @dynamic_tensor_from_elements(%m : index)
    -> tensor<?x3x?xf32> {
  // expected-error @+1 {{must have as many index operands as dynamic extents in the result type}}
  %tnsr = dynamic_tensor_from_elements %m {
    ^bb0(%i : index, %j : index, %k : index):
      %elem = constant 8.0 : f32
      yield %elem : f32
  } : tensor<?x3x?xf32>
  return %tnsr : tensor<?x3x?xf32>
}

// -----

func @dynamic_tensor_from_elements(%m : index, %n : index)
    -> tensor<?x3x?xf32> {
  // expected-error @+1 {{must have one body argument per input dimension}}
  %tnsr = dynamic_tensor_from_elements %m, %n {
    ^bb0(%i : index, %j : index):
      %elem = constant 8.0 : f32
      yield %elem : f32
  } : tensor<?x3x?xf32>
  return %tnsr : tensor<?x3x?xf32>
}

// -----

func @dynamic_tensor_from_elements(%m : index, %n : index)
    -> tensor<?x3x?xf32> {
  // expected-error @+1 {{all body arguments must be index}}
  %tnsr = dynamic_tensor_from_elements %m, %n {
    ^bb0(%i : index, %j : index, %k : i64):
      %elem = constant 8.0 : f32
      yield %elem : f32
  } : tensor<?x3x?xf32>
  return %tnsr : tensor<?x3x?xf32>
}

// -----

func @dynamic_tensor_from_elements(%m : index, %n : index)
    -> tensor<?x3x?xf32> {
  // expected-error @+2 {{op expects regions to end with 'std.yield', found 'std.return'}}
  // expected-note @+1 {{in custom textual format, the absence of terminator implies 'std.yield'}}
  %tnsr = dynamic_tensor_from_elements %m, %n {
    ^bb0(%i : index, %j : index, %k : index):
      %elem = constant 8.0 : f32
      return %elem : f32
  } : tensor<?x3x?xf32>
  return %tnsr : tensor<?x3x?xf32>
}

// -----

func @dynamic_tensor_from_elements(%m : index, %n : index)
    -> tensor<?x3x?xf32> {
  // expected-error @+1 {{body must be terminated with a `yield` operation of the tensor element type}}
  %tnsr = dynamic_tensor_from_elements %m, %n {
    ^bb0(%i : index, %j : index, %k : index):
      %elem = constant 8 : i32
      yield %elem : i32
  } : tensor<?x3x?xf32>
  return %tnsr : tensor<?x3x?xf32>
}

// -----

func @transpose_not_permutation(%v : memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>>) {
  // expected-error @+1 {{expected a permutation map}}
  transpose %v (i, j) -> (i, i) : memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>> to memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>>
}

// -----

func @transpose_bad_rank(%v : memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>>) {
  // expected-error @+1 {{expected a permutation map of same rank as the input}}
  transpose %v (i) -> (i) : memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>> to memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>>
}

// -----

func @transpose_wrong_type(%v : memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>>) {
  // expected-error @+1 {{output type 'memref<?x?xf32, affine_map<(d0, d1)[s0, s1] -> (d0 * s1 + s0 + d1)>>' does not match transposed input type 'memref<?x?xf32, affine_map<(d0, d1)[s0, s1] -> (d0 * s1 + s0 + d1)>>'}}
  transpose %v (i, j) -> (j, i) : memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>> to memref<?x?xf32, affine_map<(i, j)[off, M]->(off + M * i + j)>>
}

// -----

// CHECK-LABEL: memref_reshape_element_type_mismatch
func @memref_reshape_element_type_mismatch(
       %buf: memref<*xf32>, %shape: memref<1xi32>) {
  // expected-error @+1 {{element types of source and destination memref types should be the same}}
  memref_reshape %buf(%shape) : (memref<*xf32>, memref<1xi32>) -> memref<?xi32>
}

// -----

// CHECK-LABEL: memref_reshape_dst_ranked_shape_unranked
func @memref_reshape_dst_ranked_shape_unranked(
       %buf: memref<*xf32>, %shape: memref<?xi32>) {
  // expected-error @+1 {{cannot use shape operand with dynamic length to reshape to statically-ranked memref type}}
  memref_reshape %buf(%shape) : (memref<*xf32>, memref<?xi32>) -> memref<?xf32>
}

// -----

// CHECK-LABEL: memref_reshape_dst_shape_rank_mismatch
func @memref_reshape_dst_shape_rank_mismatch(
       %buf: memref<*xf32>, %shape: memref<1xi32>) {
  // expected-error @+1 {{length of shape operand differs from the result's memref rank}}
  memref_reshape %buf(%shape)
    : (memref<*xf32>, memref<1xi32>) -> memref<?x?xf32>
}

// -----

// CHECK-LABEL: memref_reshape_src_affine_map_is_not_identity
func @memref_reshape_src_affine_map_is_not_identity(
        %buf: memref<4x4xf32, offset: 0, strides: [3, 2]>,
        %shape: memref<1xi32>) {
  // expected-error @+1 {{source memref type should have identity affine map}}
  memref_reshape %buf(%shape)
    : (memref<4x4xf32, offset: 0, strides: [3, 2]>, memref<1xi32>)
    -> memref<8xf32>
}

// -----

// CHECK-LABEL: memref_reshape_result_affine_map_is_not_identity
func @memref_reshape_result_affine_map_is_not_identity(
        %buf: memref<4x4xf32>, %shape: memref<1xi32>) {
  // expected-error @+1 {{result memref type should have identity affine map}}
  memref_reshape %buf(%shape)
    : (memref<4x4xf32>, memref<1xi32>) -> memref<8xf32, offset: 0, strides: [2]>
}
