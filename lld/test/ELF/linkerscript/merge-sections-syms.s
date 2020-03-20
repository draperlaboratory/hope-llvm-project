# REQUIRES: x86
# RUN: llvm-mc -filetype=obj -triple=x86_64-pc-linux %s -o %t.o

# RUN: echo "SECTIONS { \
# RUN:   . = SIZEOF_HEADERS; \
# RUN:   .rodata : { *(.aaa) *(.bbb) A = .; *(.ccc) B = .; } \
# RUN: }" > %t.script
# RUN: ld.lld -o %t.so --script %t.script %t.o -shared
# RUN: llvm-nm -D %t.so | FileCheck %s

# CHECK: 0000000000000226 R A
# CHECK: 0000000000000227 R B

.section .aaa,"a"
.byte 11

.section .bbb,"aMS",@progbits,1
.asciz "foo"

.section .ccc,"a"
.byte 33
