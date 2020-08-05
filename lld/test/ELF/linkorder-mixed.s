# REQUIRES: x86
## Test that we allow SHF_LINK_ORDER sections with sh_link=0.
## SHF_LINK_ORDER sections with sh_link!=0 are ordered before others.
# RUN: llvm-mc -filetype=obj -triple=x86_64 %s -o %t.o
# RUN: ld.lld %t.o -o %t
# RUN: llvm-readelf -S -x .linkorder %t | FileCheck %s

# CHECK:      [Nr] Name       {{.*}} Size   ES Flg Lk Inf
# CHECK-NEXT: [ 0]            {{.*}}
# CHECK-NEXT: [ 1] .linkorder {{.*}} 000004 00  AL  3   0
# CHECK-NEXT: [ 2] .ignore    {{.*}}
# CHECK-NEXT: [ 3] .text      {{.*}}

# CHECK:      Hex dump of section '.linkorder':
# CHECK-NEXT:   [[#%x,ADDR:]] 01020003

## TODO Allow non-contiguous SHF_LINK_ORDER sections in an output section.
# RUN: llvm-mc --filetype=obj --defsym EXTRA=1 %s -o %t.o
# RUN: not ld.lld %t.o -o /dev/null

.section .text,"ax",@progbits,unique,0
.Ltext0:
.section .text,"ax",@progbits,unique,1
.Ltext1:
.section .linkorder,"ao",@progbits,0,unique,0
  .byte 0
.section .linkorder,"ao",@progbits,.Ltext0
  .byte 1
.section .linkorder,"ao",@progbits,.Ltext1
  .byte 2

.ifdef EXTRA
.section .linkorder,"a",@progbits
  .byte 4
.else
.section .ignore,"ao",@progbits,.Ltext1
.endif

.section .linkorder,"ao",@progbits,0,unique,3
  .byte 3
