// RUN: llvm-mc -triple=aarch64 -show-encoding -mattr=+sve < %s \
// RUN:        | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INST
// RUN: not llvm-mc -triple=aarch64 -show-encoding < %s 2>&1 \
// RUN:        | FileCheck %s --check-prefix=CHECK-ERROR
// RUN: llvm-mc -triple=aarch64 -filetype=obj -mattr=+sve < %s \
// RUN:        | llvm-objdump -d --mattr=+sve - | FileCheck %s --check-prefix=CHECK-INST
// RUN: llvm-mc -triple=aarch64 -filetype=obj -mattr=+sve < %s \
// RUN:        | llvm-objdump -d - | FileCheck %s --check-prefix=CHECK-UNKNOWN

cnt     z31.b, p7/m, z31.b
// CHECK-INST: cnt	z31.b, p7/m, z31.b
// CHECK-ENCODING: [0xff,0xbf,0x1a,0x04]
// CHECK-ERROR: instruction requires: sve
// CHECK-UNKNOWN: ff bf 1a 04 <unknown>

cnt     z31.h, p7/m, z31.h
// CHECK-INST: cnt	z31.h, p7/m, z31.h
// CHECK-ENCODING: [0xff,0xbf,0x5a,0x04]
// CHECK-ERROR: instruction requires: sve
// CHECK-UNKNOWN: ff bf 5a 04 <unknown>

cnt     z31.s, p7/m, z31.s
// CHECK-INST: cnt	z31.s, p7/m, z31.s
// CHECK-ENCODING: [0xff,0xbf,0x9a,0x04]
// CHECK-ERROR: instruction requires: sve
// CHECK-UNKNOWN: ff bf 9a 04 <unknown>

cnt     z31.d, p7/m, z31.d
// CHECK-INST: cnt	z31.d, p7/m, z31.d
// CHECK-ENCODING: [0xff,0xbf,0xda,0x04]
// CHECK-ERROR: instruction requires: sve
// CHECK-UNKNOWN: ff bf da 04 <unknown>


// --------------------------------------------------------------------------//
// Test compatibility with MOVPRFX instruction.

movprfx z4.d, p7/z, z6.d
// CHECK-INST: movprfx	z4.d, p7/z, z6.d
// CHECK-ENCODING: [0xc4,0x3c,0xd0,0x04]
// CHECK-ERROR: instruction requires: sve
// CHECK-UNKNOWN: c4 3c d0 04 <unknown>

cnt     z4.d, p7/m, z31.d
// CHECK-INST: cnt	z4.d, p7/m, z31.d
// CHECK-ENCODING: [0xe4,0xbf,0xda,0x04]
// CHECK-ERROR: instruction requires: sve
// CHECK-UNKNOWN: e4 bf da 04 <unknown>

movprfx z4, z6
// CHECK-INST: movprfx	z4, z6
// CHECK-ENCODING: [0xc4,0xbc,0x20,0x04]
// CHECK-ERROR: instruction requires: sve
// CHECK-UNKNOWN: c4 bc 20 04 <unknown>

cnt     z4.d, p7/m, z31.d
// CHECK-INST: cnt	z4.d, p7/m, z31.d
// CHECK-ENCODING: [0xe4,0xbf,0xda,0x04]
// CHECK-ERROR: instruction requires: sve
// CHECK-UNKNOWN: e4 bf da 04 <unknown>
