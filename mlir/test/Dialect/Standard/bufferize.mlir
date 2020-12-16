// RUN: mlir-opt %s -std-bufferize | FileCheck %s

// CHECK-LABEL:   func @dim(
// CHECK-SAME:              %[[TENSOR:.*]]: tensor<f32>,
// CHECK-SAME:              %[[INDEX:.*]]: index) -> index {
// CHECK:           %[[MEMREF:.*]] = tensor_to_memref %[[TENSOR]] : memref<f32>
// CHECK:           %[[EXTENT:.*]] = dim %[[MEMREF]], %[[INDEX]] : memref<f32>
// CHECK:           return %[[EXTENT]] : index
func @dim(%arg0: tensor<f32>, %arg1: index) -> index {
  %0 = dim %arg0, %arg1 : tensor<f32>
  return %0 : index
}

// CHECK-LABEL:   func @dynamic_tensor_from_elements(
// CHECK-SAME:                                       %[[ARG:.*]]: tensor<*xf32>,
// CHECK-SAME:                                       %[[DYNAMIC_EXTENT:.*]]: index) -> tensor<?xindex> {
// CHECK:           %[[MEMREF:.*]] = alloc(%[[DYNAMIC_EXTENT]]) : memref<?xindex>
// CHECK:           %[[C0:.*]] = constant 0 : index
// CHECK:           %[[C1:.*]] = constant 1 : index
// CHECK:           scf.parallel (%[[I:.*]]) = (%[[C0]]) to (%[[DYNAMIC_EXTENT]]) step (%[[C1]]) {
// CHECK:             %[[ARG_MEMREF:.*]] = tensor_to_memref %[[ARG]] : memref<*xf32>
// CHECK:             %[[ELEM:.*]] = dim %[[ARG_MEMREF]], %[[I]] : memref<*xf32>
// CHECK:             store %[[ELEM]], %[[MEMREF]][%[[I]]] : memref<?xindex>
// CHECK:             scf.yield
// CHECK:           }
// CHECK:           %[[RET:.*]] = tensor_load %[[MEMREF]] : memref<?xindex>
// CHECK:           return %[[RET]] : tensor<?xindex>
// CHECK:         }
func @dynamic_tensor_from_elements(%arg: tensor<*xf32>, %rank: index) -> tensor<?xindex> {
  %result = dynamic_tensor_from_elements %rank {
  ^bb0(%i : index):
    %elem = dim %arg, %i : tensor<*xf32>
    yield %elem : index
  } : tensor<?xindex>
  return %result : tensor<?xindex>
}

// Additional test that checks the logic for intermixed static and dynamic
// extents.
//
// CHECK-LABEL:   func @dynamic_tensor_from_elements_static_and_dynamic(
// CHECK-SAME:                                                          %[[DYNAMIC_EXTENT:.*]]: index) -> tensor<16x?xindex> {
// CHECK:           %[[MEMREF:.*]] = alloc(%[[DYNAMIC_EXTENT]]) : memref<16x?xindex>
// CHECK:           %[[C0:.*]] = constant 0 : index
// CHECK:           %[[C1:.*]] = constant 1 : index
// CHECK:           %[[C16:.*]] = constant 16 : index
// CHECK:           scf.parallel (%[[I:.*]], %[[J:.*]]) = (%[[C0]], %[[C0]]) to (%[[C16]], %[[DYNAMIC_EXTENT]]) step (%[[C1]], %[[C1]]) {
// CHECK:             %[[VAL_7:.*]] = addi %[[I]], %[[J]] : index
// CHECK:             store %[[VAL_7]], %[[MEMREF]][%[[I]], %[[J]]] : memref<16x?xindex>
// CHECK:             scf.yield
// CHECK:           }
// CHECK:           %[[RET:.*]] = tensor_load %[[MEMREF]] : memref<16x?xindex>
// CHECK:           return %[[RET]] : tensor<16x?xindex>
// CHECK:         }
func @dynamic_tensor_from_elements_static_and_dynamic(%arg0: index) -> tensor<16x?xindex> {
  %result = dynamic_tensor_from_elements %arg0 {
  ^bb0(%i: index, %j: index):
    %sum = addi %i, %j : index
    yield %sum : index
  } : tensor<16x?xindex>
  return %result : tensor<16x?xindex>
}

// CHECK-LABEL:   func @select(
// CHECK-SAME:                 %[[PRED:.*]]: i1,
// CHECK-SAME:                 %[[TRUE_VAL:.*]]: tensor<f32>,
// CHECK-SAME:                 %[[FALSE_VAL:.*]]: tensor<f32>) -> tensor<f32> {
// CHECK:           %[[TRUE_VAL_MEMREF:.*]] = tensor_to_memref %[[TRUE_VAL]] : memref<f32>
// CHECK:           %[[FALSE_VAL_MEMREF:.*]] = tensor_to_memref %[[FALSE_VAL]] : memref<f32>
// CHECK:           %[[RET_MEMREF:.*]] = select %[[PRED]], %[[TRUE_VAL_MEMREF]], %[[FALSE_VAL_MEMREF]] : memref<f32>
// CHECK:           %[[RET:.*]] = tensor_load %[[RET_MEMREF]] : memref<f32>
// CHECK:           return %[[RET]] : tensor<f32>
func @select(%arg0: i1, %arg1: tensor<f32>, %arg2: tensor<f32>) -> tensor<f32> {
  %0 = select %arg0, %arg1, %arg2 : tensor<f32>
  return %0 : tensor<f32>
}

// CHECK-LABEL:   func @tensor_from_elements(
// CHECK-SAME:                               %[[ELEM0:.*]]: index,
// CHECK-SAME:                               %[[ELEM1:.*]]: index) -> tensor<2xindex> {
// CHECK:           %[[MEMREF:.*]] = alloc()
// CHECK:           %[[C0:.*]] = constant 0 : index
// CHECK:           store %[[ELEM0]], %[[MEMREF]][%[[C0]]]
// CHECK:           %[[C1:.*]] = constant 1 : index
// CHECK:           store %[[ELEM1]], %[[MEMREF]][%[[C1]]]
// CHECK:           %[[RET:.*]] = tensor_load %[[MEMREF]]
// CHECK:           return %[[RET]] : tensor<2xindex>
func @tensor_from_elements(%arg0: index, %arg1: index) -> tensor<2xindex> {
  %0 = tensor_from_elements %arg0, %arg1 : tensor<2xindex>
  return %0 : tensor<2xindex>
}

// The dynamic_tensor_from_elements op needs to put its body into the
// resulting scf.parallel. To handle unknown ops in the body, it cannot clone
// the body because that would require the cloned ops to be legalized
// immediately, which is usually not possible since they might be from various
// other dialects.
//
// CHECK-LABEL: func @unknown_ops_in_body
func @unknown_ops_in_body(%arg0: index) -> tensor<?xindex> {
  // CHECK-NOT: dynamic_tensor_from_elements
  %tensor = dynamic_tensor_from_elements %arg0 {
  ^bb0(%iv: index):
    // CHECK: test.source
    %0 = "test.source"() : () -> index
    yield %0 : index
  } : tensor<?xindex>
  return %tensor : tensor<?xindex>
}
