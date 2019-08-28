// RUN: llvm-mc -triple=aarch64 -show-encoding -mattr=+sve2 < %s \
// RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INST
// RUN: not llvm-mc -triple=aarch64 -show-encoding < %s 2>&1 \
// RUN:        | FileCheck %s --check-prefix=CHECK-ERROR
// RUN: llvm-mc -triple=aarch64 -filetype=obj -mattr=+sve2 < %s \
// RUN:        | llvm-objdump -d -mattr=+sve2 - | FileCheck %s --check-prefix=CHECK-INST
// RUN: llvm-mc -triple=aarch64 -filetype=obj -mattr=+sve2 < %s \
// RUN:        | llvm-objdump -d - | FileCheck %s --check-prefix=CHECK-UNKNOWN

rshrnt     z0.b, z0.h, #1
// CHECK-INST: rshrnt	z0.b, z0.h, #1
// CHECK-ENCODING: [0x00,0x1c,0x2f,0x45]
// CHECK-ERROR: instruction requires: sve2
// CHECK-UNKNOWN: 00 1c 2f 45 <unknown>

rshrnt     z31.b, z31.h, #8
// CHECK-INST: rshrnt	z31.b, z31.h, #8
// CHECK-ENCODING: [0xff,0x1f,0x28,0x45]
// CHECK-ERROR: instruction requires: sve2
// CHECK-UNKNOWN: ff 1f 28 45 <unknown>

rshrnt     z0.h, z0.s, #1
// CHECK-INST: rshrnt	z0.h, z0.s, #1
// CHECK-ENCODING: [0x00,0x1c,0x3f,0x45]
// CHECK-ERROR: instruction requires: sve2
// CHECK-UNKNOWN: 00 1c 3f 45 <unknown>

rshrnt     z31.h, z31.s, #16
// CHECK-INST: rshrnt	z31.h, z31.s, #16
// CHECK-ENCODING: [0xff,0x1f,0x30,0x45]
// CHECK-ERROR: instruction requires: sve2
// CHECK-UNKNOWN: ff 1f 30 45 <unknown>

rshrnt     z0.s, z0.d, #1
// CHECK-INST: rshrnt	z0.s, z0.d, #1
// CHECK-ENCODING: [0x00,0x1c,0x7f,0x45]
// CHECK-ERROR: instruction requires: sve2
// CHECK-UNKNOWN: 00 1c 7f 45 <unknown>

rshrnt     z31.s, z31.d, #32
// CHECK-INST: rshrnt	z31.s, z31.d, #32
// CHECK-ENCODING: [0xff,0x1f,0x60,0x45]
// CHECK-ERROR: instruction requires: sve2
// CHECK-UNKNOWN: ff 1f 60 45 <unknown>
