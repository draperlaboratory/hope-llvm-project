# RUN: llvm-mc -triple=ve --show-encoding < %s \
# RUN:     | FileCheck %s --check-prefixes=CHECK-ENCODING,CHECK-INST
# RUN: llvm-mc -triple=ve -filetype=obj < %s | llvm-objdump -d - \
# RUN:     | FileCheck %s --check-prefixes=CHECK-INST

# CHECK-INST: vst %v11, 23, %s12
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0b,0x8c,0x17,0x40,0x91]
vst %v11, 23, %s12

# CHECK-INST: vst.nc %vix, 63, %s22
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0xff,0x96,0x3f,0x00,0x91]
vst.nc %vix, 63, %s22

# CHECK-INST: vst.ot %v63, -64, %s63
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x3f,0xbf,0x40,0xc0,0x91]
vst.ot %v63, -64, %s63

# CHECK-INST: vst.nc.ot %v12, %s12, 0
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0c,0x00,0x8c,0x80,0x91]
vst.nc.ot %v12, %s12, 0

# CHECK-INST: vst %v11, 23, %s12
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0b,0x8c,0x17,0x40,0x91]
vst %v11, 23, %s12, %vm0

# CHECK-INST: vst.nc %vix, 63, %s22, %vm1
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0xff,0x96,0x3f,0x01,0x91]
vst.nc %vix, 63, %s22, %vm1

# CHECK-INST: vst.ot %v63, -64, %s63, %vm15
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x3f,0xbf,0x40,0xcf,0x91]
vst.ot %v63, -64, %s63, %vm15

# CHECK-INST: vst.nc.ot %v12, %s12, 0, %vm8
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0c,0x00,0x8c,0x88,0x91]
vst.nc.ot %v12, %s12, 0, %vm8

# CHECK-INST: vstu %v11, 23, %s12
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0b,0x8c,0x17,0x40,0x92]
vstu %v11, 23, %s12

# CHECK-INST: vstu.nc %vix, 63, %s22
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0xff,0x96,0x3f,0x00,0x92]
vstu.nc %vix, 63, %s22

# CHECK-INST: vstu.ot %v63, -64, %s63
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x3f,0xbf,0x40,0xc0,0x92]
vstu.ot %v63, -64, %s63

# CHECK-INST: vstu.nc.ot %v12, %s12, 0
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0c,0x00,0x8c,0x80,0x92]
vstu.nc.ot %v12, %s12, 0

# CHECK-INST: vstu %v11, 23, %s12
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0b,0x8c,0x17,0x40,0x92]
vstu %v11, 23, %s12, %vm0

# CHECK-INST: vstu.nc %vix, 63, %s22, %vm1
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0xff,0x96,0x3f,0x01,0x92]
vstu.nc %vix, 63, %s22, %vm1

# CHECK-INST: vstu.ot %v63, -64, %s63, %vm15
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x3f,0xbf,0x40,0xcf,0x92]
vstu.ot %v63, -64, %s63, %vm15

# CHECK-INST: vstu.nc.ot %v12, %s12, 0, %vm8
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0c,0x00,0x8c,0x88,0x92]
vstu.nc.ot %v12, %s12, 0, %vm8

# CHECK-INST: vstl %v11, 23, %s12
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0b,0x8c,0x17,0x40,0x93]
vstl %v11, 23, %s12

# CHECK-INST: vstl.nc %vix, 63, %s22
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0xff,0x96,0x3f,0x00,0x93]
vstl.nc %vix, 63, %s22

# CHECK-INST: vstl.ot %v63, -64, %s63
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x3f,0xbf,0x40,0xc0,0x93]
vstl.ot %v63, -64, %s63

# CHECK-INST: vstl.nc.ot %v12, %s12, 0
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0c,0x00,0x8c,0x80,0x93]
vstl.nc.ot %v12, %s12, 0

# CHECK-INST: vstl %v11, 23, %s12
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0b,0x8c,0x17,0x40,0x93]
vstl %v11, 23, %s12, %vm0

# CHECK-INST: vstl.nc %vix, 63, %s22, %vm1
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0xff,0x96,0x3f,0x01,0x93]
vstl.nc %vix, 63, %s22, %vm1

# CHECK-INST: vstl.ot %v63, -64, %s63, %vm15
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x3f,0xbf,0x40,0xcf,0x93]
vstl.ot %v63, -64, %s63, %vm15

# CHECK-INST: vstl.nc.ot %v12, %s12, 0, %vm8
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0c,0x00,0x8c,0x88,0x93]
vstl.nc.ot %v12, %s12, 0, %vm8

# CHECK-INST: vst2d %v11, 23, %s12
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0b,0x8c,0x17,0x40,0xd1]
vst2d %v11, 23, %s12

# CHECK-INST: vst2d.nc %vix, 63, %s22
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0xff,0x96,0x3f,0x00,0xd1]
vst2d.nc %vix, 63, %s22

# CHECK-INST: vst2d.ot %v63, -64, %s63
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x3f,0xbf,0x40,0xc0,0xd1]
vst2d.ot %v63, -64, %s63

# CHECK-INST: vst2d.nc.ot %v12, %s12, 0
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0c,0x00,0x8c,0x80,0xd1]
vst2d.nc.ot %v12, %s12, 0

# CHECK-INST: vst2d %v11, 23, %s12
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0b,0x8c,0x17,0x40,0xd1]
vst2d %v11, 23, %s12, %vm0

# CHECK-INST: vst2d.nc %vix, 63, %s22, %vm1
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0xff,0x96,0x3f,0x01,0xd1]
vst2d.nc %vix, 63, %s22, %vm1

# CHECK-INST: vst2d.ot %v63, -64, %s63, %vm15
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x3f,0xbf,0x40,0xcf,0xd1]
vst2d.ot %v63, -64, %s63, %vm15

# CHECK-INST: vst2d.nc.ot %v12, %s12, 0, %vm8
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0c,0x00,0x8c,0x88,0xd1]
vst2d.nc.ot %v12, %s12, 0, %vm8

# CHECK-INST: vstu2d %v11, 23, %s12
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0b,0x8c,0x17,0x40,0xd2]
vstu2d %v11, 23, %s12

# CHECK-INST: vstu2d.nc %vix, 63, %s22
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0xff,0x96,0x3f,0x00,0xd2]
vstu2d.nc %vix, 63, %s22

# CHECK-INST: vstu2d.ot %v63, -64, %s63
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x3f,0xbf,0x40,0xc0,0xd2]
vstu2d.ot %v63, -64, %s63

# CHECK-INST: vstu2d.nc.ot %v12, %s12, 0
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0c,0x00,0x8c,0x80,0xd2]
vstu2d.nc.ot %v12, %s12, 0

# CHECK-INST: vstu2d %v11, 23, %s12
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0b,0x8c,0x17,0x40,0xd2]
vstu2d %v11, 23, %s12, %vm0

# CHECK-INST: vstu2d.nc %vix, 63, %s22, %vm1
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0xff,0x96,0x3f,0x01,0xd2]
vstu2d.nc %vix, 63, %s22, %vm1

# CHECK-INST: vstu2d.ot %v63, -64, %s63, %vm15
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x3f,0xbf,0x40,0xcf,0xd2]
vstu2d.ot %v63, -64, %s63, %vm15

# CHECK-INST: vstu2d.nc.ot %v12, %s12, 0, %vm8
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0c,0x00,0x8c,0x88,0xd2]
vstu2d.nc.ot %v12, %s12, 0, %vm8

# CHECK-INST: vstl2d %v11, 23, %s12
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0b,0x8c,0x17,0x40,0xd3]
vstl2d %v11, 23, %s12

# CHECK-INST: vstl2d.nc %vix, 63, %s22
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0xff,0x96,0x3f,0x00,0xd3]
vstl2d.nc %vix, 63, %s22

# CHECK-INST: vstl2d.ot %v63, -64, %s63
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x3f,0xbf,0x40,0xc0,0xd3]
vstl2d.ot %v63, -64, %s63

# CHECK-INST: vstl2d.nc.ot %v12, %s12, 0
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0c,0x00,0x8c,0x80,0xd3]
vstl2d.nc.ot %v12, %s12, 0

# CHECK-INST: vstl2d %v11, 23, %s12
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0b,0x8c,0x17,0x40,0xd3]
vstl2d %v11, 23, %s12, %vm0

# CHECK-INST: vstl2d.nc %vix, 63, %s22, %vm1
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0xff,0x96,0x3f,0x01,0xd3]
vstl2d.nc %vix, 63, %s22, %vm1

# CHECK-INST: vstl2d.ot %v63, -64, %s63, %vm15
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x3f,0xbf,0x40,0xcf,0xd3]
vstl2d.ot %v63, -64, %s63, %vm15

# CHECK-INST: vstl2d.nc.ot %v12, %s12, 0, %vm8
# CHECK-ENCODING: encoding: [0x00,0x00,0x00,0x0c,0x00,0x8c,0x88,0xd3]
vstl2d.nc.ot %v12, %s12, 0, %vm8
