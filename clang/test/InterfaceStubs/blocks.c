// RUN: %clang_cc1 -emit-interface-stubs -fblocks -o - %s | FileCheck %s

// CHECK: --- !experimental-ifs-v2
// CHECK-NEXT: IfsVersion: 2.0
// CHECK-NEXT: Triple:
// CHECK-NEXT: ObjectFileFormat: ELF
// CHECK-NEXT: Symbols:
// CHECK-NEXT: ...
static void (^f)(void*) = ^(void* data) { int i; };
