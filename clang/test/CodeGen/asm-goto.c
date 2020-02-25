// REQUIRES: x86-registered-target
// RUN: %clang_cc1 -triple x86_64-pc-linux-gnu -O0 -emit-llvm %s -o - | FileCheck %s
// RUN: %clang_cc1 -triple i386-pc-linux-gnu -O0 -emit-llvm %s -o - | FileCheck %s

int test1(int cond) {
  // CHECK-LABEL: define i32 @test1(
  // CHECK: callbr void asm sideeffect
  // CHECK: to label %asm.fallthrough [label %label_true, label %loop]
  // CHECK-LABEL: asm.fallthrough:
  asm volatile goto("testl %0, %0; jne %l1;" :: "r"(cond)::label_true, loop);
  asm volatile goto("testl %0, %0; jne %l2;" :: "r"(cond)::label_true, loop);
  // CHECK: callbr void asm sideeffect
  // CHECK: to label %asm.fallthrough1 [label %label_true, label %loop]
  // CHECK-LABEL: asm.fallthrough1:
  return 0;
loop:
  return 0;
label_true:
  return 1;
}

int test2(int cond) {
  // CHECK-LABEL: define i32 @test2(
  // CHECK: callbr i32 asm sideeffect
  // CHECK: to label %asm.fallthrough [label %label_true, label %loop]
  // CHECK-LABEL: asm.fallthrough:
  asm volatile goto("testl %0, %0; jne %l2;" : "=r"(cond) : "r"(cond) :: label_true, loop);
  asm volatile goto("testl %0, %0; jne %l3;" : "=r"(cond) : "r"(cond) :: label_true, loop);
  // CHECK: callbr i32 asm sideeffect
  // CHECK: to label %asm.fallthrough1 [label %label_true, label %loop]
  // CHECK-LABEL: asm.fallthrough1:
  return 0;
loop:
  return 0;
label_true:
  return 1;
}

int test3(int out1, int out2) {
  // CHECK-LABEL: define i32 @test3(
  // CHECK: callbr { i32, i32 } asm sideeffect
  // CHECK: to label %asm.fallthrough [label %label_true, label %loop]
  // CHECK-LABEL: asm.fallthrough:
  asm volatile goto("testl %0, %0; jne %l3;" : "=r"(out1), "=r"(out2) : "r"(out1) :: label_true, loop);
  asm volatile goto("testl %0, %0; jne %l4;" : "=r"(out1), "=r"(out2) : "r"(out1) :: label_true, loop);
  // CHECK: callbr { i32, i32 } asm sideeffect
  // CHECK: to label %asm.fallthrough2 [label %label_true, label %loop]
  // CHECK-LABEL: asm.fallthrough2:
  return 0;
loop:
  return 0;
label_true:
  return 1;
}

int test4(int out1, int out2) {
  // CHECK-LABEL: define i32 @test4(
  // CHECK: callbr { i32, i32 } asm sideeffect "jne ${3:l}", "={si},={di},r,X,X,0,1
  // CHECK: to label %asm.fallthrough [label %label_true, label %loop]
  // CHECK-LABEL: asm.fallthrough:
  if (out1 < out2)
    asm volatile goto("jne %l3" : "+S"(out1), "+D"(out2) : "r"(out1) :: label_true, loop);
  else
    asm volatile goto("jne %l5" : "+S"(out1), "+D"(out2) : "r"(out1), "r"(out2) :: label_true, loop);
  // CHECK: callbr { i32, i32 } asm sideeffect "jne ${5:l}", "={si},={di},r,r,X,X,0,1
  // CHECK: to label %asm.fallthrough2 [label %label_true, label %loop]
  // CHECK-LABEL: asm.fallthrough2:
  return out1 + out2;
loop:
  return -1;
label_true:
  return -2;
}

int test5(int addr, int size, int limit) {
  // CHECK-LABEL: define i32 @test5(
  // CHECK: callbr i32 asm "add $1,$0 ; jc ${3:l} ; cmp $2,$0 ; ja ${3:l} ; ", "=r,imr,imr,X,0
  // CHECK: to label %asm.fallthrough [label %t_err]
  // CHECK-LABEL: asm.fallthrough:
  asm goto(
      "add %1,%0 ; "
      "jc %l[t_err] ; "
      "cmp %2,%0 ; "
      "ja %l[t_err] ; "
      : "+r" (addr)
      : "g" (size), "g" (limit)
      : : t_err);
  return 0;
t_err:
  return 1;
}

int test6(int out1) {
  // CHECK-LABEL: define i32 @test6(
  // CHECK: callbr i32 asm sideeffect "testl $0, $0; testl $1, $1; jne ${2:l}", "={si},r,X,X,0,{{.*}} i8* blockaddress(@test6, %label_true), i8* blockaddress(@test6, %landing)
  // CHECK: to label %asm.fallthrough [label %label_true, label %landing]
  // CHECK-LABEL: asm.fallthrough:
  // CHECK-LABEL: landing:
  int out2 = 42;
  asm volatile goto("testl %0, %0; testl %1, %1; jne %l2" : "+S"(out2) : "r"(out1) :: label_true, landing);
landing:
  return out1 + out2;
label_true:
  return -2;
}
