// RUN: mlir-opt %s -convert-linalg-to-parallel-loops -split-input-file | FileCheck %s --dump-input-on-failure

#map0 = affine_map<(d0, d1) -> (d0, d1)>
func @linalg_generic_sum(%lhs: memref<2x2xf32>,
                         %rhs: memref<2x2xf32>,
                         %sum: memref<2x2xf32>) {
  linalg.generic {
    args_in = 2 : i64,
    args_out = 1 : i64,
    indexing_maps = [#map0, #map0, #map0],
    iterator_types = ["parallel", "parallel"]
  } %lhs, %rhs, %sum {
    ^bb0(%lhs_in: f32, %rhs_in: f32, %sum_out: f32):   // no predecessors
      %0 = addf %lhs_in, %rhs_in : f32
      linalg.yield %0 : f32
  }: memref<2x2xf32>, memref<2x2xf32>, memref<2x2xf32>
  return
}
// CHECK-LABEL: @linalg_generic_sum
// CHECK:   (%[[LHS:.*]]:{{.*}}, %[[RHS:.*]]:{{.*}}, %[[SUM:.*]]:{{.*}})
// CHECK-DAG: %[[C2:.*]] = constant 2
// CHECK-DAG: %[[C0:.*]] = constant 0
// CHECK-DAG: %[[C1:.*]] = constant 1
// CHECK: scf.parallel (%[[I:.*]], %[[J:.*]]) = {{.*}}
// CHECK:   %[[LHS_ELEM:.*]] = load %[[LHS]][%[[I]], %[[J]]]
// CHECK:   %[[RHS_ELEM:.*]] = load %[[RHS]][%[[I]], %[[J]]]
// CHECK:   %[[SUM:.*]] = addf %[[LHS_ELEM]], %[[RHS_ELEM]] : f32
// CHECK:   store %[[SUM]], %{{.*}}[%[[I]], %[[J]]]
// CHECK:   scf.yield

// -----

#accesses = [
  affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>,
  affine_map<(d0, d1, d2, d3) -> (d0, d1, d3)>
]
#trait = {
  args_in = 1,
  args_out = 1,
  iterator_types = ["parallel", "parallel", "reduction", "parallel"],
  indexing_maps = #accesses
}

func @lower_outer_parallel(%A: memref<?x?x?x?xf32>, %B: memref<?x?x?xf32>) {
  linalg.generic #trait %A, %B {
    ^bb0(%a: f32, %b: f32):
      linalg.yield %a: f32
  } : memref<?x?x?x?xf32>, memref<?x?x?xf32>
  return
}
// CHECK-LABEL: @lower_outer_parallel
//   CHECK-DAG: %[[C0:.*]] = constant 0
//   CHECK-DAG: %[[C1:.*]] = constant 1
//   CHECK-DAG: %[[D0:.*]] = dim %{{.*}}, 0
//   CHECK-DAG: %[[D1:.*]] = dim %{{.*}}, 1
//   CHECK-DAG: %[[D2:.*]] = dim %{{.*}}, 2
//   CHECK-DAG: %[[D3:.*]] = dim %{{.*}}, 3
//       CHECK: scf.parallel (%[[IV0:.*]], %[[IV1:.*]]) = (%[[C0]], %[[C0]]) to (%[[D0]], %[[D1]]) step (%[[C1]], %[[C1]])
//       CHECK:   scf.for %[[IV2:.*]] = %[[C0]] to %[[D2]] step %[[C1]]
//       CHECK:     scf.parallel (%[[IV3:.*]]) = (%[[C0]]) to (%[[D3]]) step (%[[C1]])
//       CHECK:       load %{{.*}}[%[[IV0]], %[[IV1]], %[[IV2]], %[[IV3]]]
//       CHECK:       store %{{.*}}, %{{.*}}[%[[IV0]], %[[IV1]], %[[IV3]]]

// -----

#accesses = [
  affine_map<(d0, d1, d2, d3, d4, d5) -> (d0, d1, d2, d3, d4, d5)>,
  affine_map<(d0, d1, d2, d3, d4, d5) -> (d0, d2, d4, d5)>
]
#trait = {
  args_in = 1,
  args_out = 1,
  iterator_types = ["parallel", "parallel", "reduction", "parallel", "parallel", "reduction"],
  indexing_maps = #accesses
}

func @lower_mixed_parallel(%A: memref<?x?x?x?x?x?xf32>, %B: memref<?x?x?x?xf32>) {
  linalg.generic #trait %A, %B {
    ^bb0(%a: f32, %b: f32):
      linalg.yield %a: f32
  } : memref<?x?x?x?x?x?xf32>, memref<?x?x?x?xf32>
  return
}
// CHECK-LABEL: @lower_mixed_parallel
//   CHECK-DAG: %[[C0:.*]] = constant 0
//   CHECK-DAG: %[[C1:.*]] = constant 1
//   CHECK-DAG: %[[D0:.*]] = dim %{{.*}}, 0
//   CHECK-DAG: %[[D1:.*]] = dim %{{.*}}, 1
//   CHECK-DAG: %[[D2:.*]] = dim %{{.*}}, 2
//   CHECK-DAG: %[[D3:.*]] = dim %{{.*}}, 3
//   CHECK-DAG: %[[D4:.*]] = dim %{{.*}}, 4
//   CHECK-DAG: %[[D5:.*]] = dim %{{.*}}, 5
//       CHECK: scf.parallel (%[[IV0:.*]], %[[IV1:.*]]) = (%[[C0]], %[[C0]]) to (%[[D0]], %[[D1]]) step (%[[C1]], %[[C1]])
//       CHECK:   scf.for %[[IV2:.*]] = %[[C0]] to %[[D2]] step %[[C1]]
//       CHECK:     scf.parallel (%[[IV3:.*]], %[[IV4:.*]]) = (%[[C0]], %[[C0]]) to (%[[D3]], %[[D4]]) step (%[[C1]], %[[C1]])
//       CHECK:       scf.for %[[IV5:.*]] = %[[C0]] to %[[D5]] step %[[C1]]
//       CHECK:       load %{{.*}}[%[[IV0]], %[[IV1]], %[[IV2]], %[[IV3]], %[[IV4]], %[[IV5]]]
//       CHECK:       store %{{.*}}, %{{.*}}[%[[IV0]], %[[IV2]], %[[IV4]], %[[IV5]]]
