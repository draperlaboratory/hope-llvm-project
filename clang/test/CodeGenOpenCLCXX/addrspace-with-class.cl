// RUN: %clang_cc1 %s -triple spir-unknown-unknown -cl-std=clc++ -emit-llvm -O0 -o - | FileCheck %s
// RUN: %clang_cc1 %s -triple spir-unknown-unknown -cl-std=CLC++ -emit-llvm -O0 -o - | FileCheck %s --check-prefix=CHECK-DEFINITIONS

// This test ensures the proper address spaces and address space cast are used
// for constructors, member functions and destructors.
// See also atexit.cl and global_init.cl for other specific tests.

// CHECK: %struct.MyType = type { i32 }
struct MyType {
  MyType(int i) : i(i) {}
  MyType(int i) __constant : i(i) {}
  ~MyType() {}
  ~MyType() __constant {}
  int bar() { return i + 2; }
  int bar() __constant { return i + 1; }
  int i;
};

// CHECK: @const1 = addrspace(2) global %struct.MyType zeroinitializer
__constant MyType const1 = 1;
// CHECK: @const2 = addrspace(2) global %struct.MyType zeroinitializer
__constant MyType const2(2);
// CHECK: @glob = addrspace(1) global %struct.MyType zeroinitializer
MyType glob(1);

// CHECK: call spir_func void @_ZNU3AS26MyTypeC1Ei(%struct.MyType addrspace(2)* @const1, i32 1)
// CHECK: call spir_func void @_ZNU3AS26MyTypeC1Ei(%struct.MyType addrspace(2)* @const2, i32 2)
// CHECK: call spir_func void @_ZNU3AS46MyTypeC1Ei(%struct.MyType addrspace(4)* addrspacecast (%struct.MyType addrspace(1)* @glob to %struct.MyType addrspace(4)*), i32 1)

// CHECK-LABEL: define spir_kernel void @fooGlobal()
kernel void fooGlobal() {
  // CHECK: call spir_func i32 @_ZNU3AS46MyType3barEv(%struct.MyType addrspace(4)* addrspacecast (%struct.MyType addrspace(1)* @glob to %struct.MyType addrspace(4)*))
  glob.bar();
  // CHECK: call spir_func i32 @_ZNU3AS26MyType3barEv(%struct.MyType addrspace(2)* @const1)
  const1.bar();
  // CHECK: call spir_func void @_ZNU3AS26MyTypeD1Ev(%struct.MyType addrspace(2)* @const1)
  const1.~MyType();
}

// CHECK-LABEL: define spir_kernel void @fooLocal()
kernel void fooLocal() {
  // CHECK: [[VAR:%.*]] = alloca %struct.MyType
  // CHECK: [[REG:%.*]] = addrspacecast %struct.MyType* [[VAR]] to %struct.MyType addrspace(4)*
  // CHECK: call spir_func void @_ZNU3AS46MyTypeC1Ei(%struct.MyType addrspace(4)* [[REG]], i32 3)
  MyType myLocal(3);
  // CHECK: [[REG:%.*]] = addrspacecast %struct.MyType* [[VAR]] to %struct.MyType addrspace(4)*
  // CHECK: call spir_func i32 @_ZNU3AS46MyType3barEv(%struct.MyType addrspace(4)* [[REG]])
  myLocal.bar();
  // CHECK: [[REG:%.*]] = addrspacecast %struct.MyType* [[VAR]] to %struct.MyType addrspace(4)*
  // CHECK: call spir_func void @_ZNU3AS46MyTypeD1Ev(%struct.MyType addrspace(4)* [[REG]])
}

// Ensure all members are defined for all the required address spaces.
// CHECK-DEFINITIONS-DAG: define linkonce_odr spir_func void @_ZNU3AS26MyTypeC1Ei(%struct.MyType addrspace(2)* %this, i32 %i)
// CHECK-DEFINITIONS-DAG: define linkonce_odr spir_func void @_ZNU3AS46MyTypeC1Ei(%struct.MyType addrspace(4)* %this, i32 %i)
// CHECK-DEFINITIONS-DAG: define linkonce_odr spir_func void @_ZNU3AS26MyTypeD1Ev(%struct.MyType addrspace(2)* %this)
// CHECK-DEFINITIONS-DAG: define linkonce_odr spir_func void @_ZNU3AS46MyTypeD1Ev(%struct.MyType addrspace(4)* %this)
// CHECK-DEFINITIONS-DAG: define linkonce_odr spir_func i32 @_ZNU3AS26MyType3barEv(%struct.MyType addrspace(2)* %this)
// CHECK-DEFINITIONS-DAG: define linkonce_odr spir_func i32 @_ZNU3AS46MyType3barEv(%struct.MyType addrspace(4)* %this)
