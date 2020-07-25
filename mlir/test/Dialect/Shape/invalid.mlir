// RUN: mlir-opt %s -split-input-file -verify-diagnostics

func @reduce_op_args_num_mismatch(%shape : !shape.shape, %init : !shape.size) {
  // expected-error@+1 {{ReduceOp body is expected to have 3 arguments}}
  %num_elements = shape.reduce(%shape, %init) : !shape.shape -> !shape.size {
    ^bb0(%index: index, %dim: !shape.size):
      shape.yield %dim : !shape.size
  }
  return
}

// -----

func @reduce_op_arg0_wrong_type(%shape : !shape.shape, %init : !shape.size) {
  // expected-error@+1 {{argument 0 of ReduceOp body is expected to be of IndexType}}
  %num_elements = shape.reduce(%shape, %init) : !shape.shape -> !shape.size {
    ^bb0(%index: f32, %dim: !shape.size, %acc: !shape.size):
      %new_acc = "shape.add"(%acc, %dim)
          : (!shape.size, !shape.size) -> !shape.size
      shape.yield %new_acc : !shape.size
  }
  return
}

// -----

func @reduce_op_arg1_wrong_type(%shape : !shape.shape, %init : !shape.size) {
  // expected-error@+1 {{argument 1 of ReduceOp body is expected to be of SizeType if the ReduceOp operates on a ShapeType}}
  %num_elements = shape.reduce(%shape, %init) : !shape.shape -> !shape.size {
    ^bb0(%index: index, %dim: f32, %lci: !shape.size):
      shape.yield
  }
  return
}

// -----

func @reduce_op_arg1_wrong_type(%shape : tensor<?xindex>, %init : index) {
  // expected-error@+1 {{argument 1 of ReduceOp body is expected to be of IndexType if the ReduceOp operates on an extent tensor}}
  %num_elements = shape.reduce(%shape, %init) : tensor<?xindex> -> index {
    ^bb0(%index: index, %dim: f32, %lci: index):
      shape.yield
  }
  return
}

// -----

func @reduce_op_init_type_mismatch(%shape : !shape.shape, %init : f32) {
  // expected-error@+1 {{type mismatch between argument 2 of ReduceOp body and initial value 0}}
  %num_elements = shape.reduce(%shape, %init) : !shape.shape -> f32 {
    ^bb0(%index: index, %dim: !shape.size, %lci: !shape.size):
      shape.yield
  }
  return
}

// -----

func @yield_op_args_num_mismatch(%shape : !shape.shape, %init : !shape.size) {
  // expected-error@+3 {{number of operands does not match number of results of its parent}}
  %num_elements = shape.reduce(%shape, %init) : !shape.shape -> !shape.size {
    ^bb0(%index: index, %dim: !shape.size, %lci: !shape.size):
      shape.yield %dim, %dim : !shape.size, !shape.size
  }
  return
}

// -----

func @yield_op_type_mismatch(%shape : !shape.shape, %init : !shape.size) {
  // expected-error@+4 {{types mismatch between yield op and its parent}}
  %num_elements = shape.reduce(%shape, %init) : !shape.shape -> !shape.size {
    ^bb0(%index: index, %dim: !shape.size, %lci: !shape.size):
      %c0 = constant 1 : index
      shape.yield %c0 : index
  }
  return
}

// -----

func @assuming_all_op_too_few_operands() {
  // expected-error@+1 {{no operands specified}}
  %w0 = shape.assuming_all
  return
}

// -----

func @shape_of(%value_arg : !shape.value_shape,
               %shaped_arg : tensor<?x3x4xf32>) {
  // expected-error@+1 {{if operand is of type `value_shape` then the result must be of type `shape` to propagate potential error shapes}}
  %0 = shape.shape_of %value_arg : !shape.value_shape -> tensor<?xindex>
  return
}

// -----

func @shape_of(%value_arg : !shape.value_shape,
               %shaped_arg : tensor<?x3x4xf32>) {
  // expected-error@+1 {{if operand is a shaped type then the result must be an extent tensor}}
  %1 = shape.shape_of %shaped_arg : tensor<?x3x4xf32> -> !shape.shape
  return
}

// -----

func @rank(%arg : !shape.shape) {
  // expected-error@+1 {{if operand is of type `shape` then the result must be of type `size` to propagate potential errors}}
  %0 = shape.rank %arg : !shape.shape -> index
  return
}

// -----

func @get_extent_error_free(%arg : tensor<?xindex>) -> !shape.size {
  %c0 = constant 0 : index
  // expected-error@+1 {{if none of the operands can hold error values then the result must be of type `index`}}
  %result = shape.get_extent %arg, %c0 : tensor<?xindex>, index -> !shape.size
  return %result : !shape.size
}

// -----

func @get_extent_error_possible(%arg : tensor<?xindex>) -> index {
  %c0 = shape.const_size 0
  // expected-error@+1 {{if at least one of the operands can hold error values then the result must be of type `size` to propagate them}}
  %result = shape.get_extent %arg, %c0 : tensor<?xindex>, !shape.size -> index
  return %result : index
}

// -----

func @mul_error_free(%arg : index) -> !shape.size {
  // expected-error@+1 {{if none of the operands can hold error values then the result must be of type `index`}}
  %result = shape.mul %arg, %arg : index, index -> !shape.size
  return %result : !shape.size
}

// -----

func @mul_error_possible(%lhs : !shape.size, %rhs : index) -> index {
  // expected-error@+1 {{if at least one of the operands can hold error values then the result must be of type `size` to propagate them}}
  %result = shape.mul %lhs, %rhs : !shape.size, index -> index
  return %result : index
}

// -----

func @num_elements_error_free(%arg : tensor<?xindex>) -> !shape.size {
  // expected-error@+1 {{if none of the operands can hold error values then the result must be of type `index`}}
  %result = shape.num_elements %arg : tensor<?xindex> -> !shape.size
  return %result : !shape.size
}

// -----

func @num_elements_error_possible(%arg : !shape.shape) -> index {
  // expected-error@+1 {{if at least one of the operands can hold error values then the result must be of type `size` to propagate them}}
  %result = shape.num_elements %arg : !shape.shape -> index
  return %result : index
}

