# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=sandybridge -iterations=1 -resource-pressure=false -instruction-info=false -timeline < %s | FileCheck %s -check-prefixes=ALL,SANDY
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=haswell -iterations=1 -resource-pressure=false -instruction-info=false -timeline < %s | FileCheck %s -check-prefixes=ALL,HASWELL
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=broadwell -iterations=1 -resource-pressure=false -instruction-info=false -timeline < %s | FileCheck %s -check-prefixes=ALL,BDWELL
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=skylake -iterations=1 -resource-pressure=false -instruction-info=false -timeline < %s | FileCheck %s -check-prefixes=ALL,SKYLAKE

# PR36951
addl    %edi, %esi
addl    (%rdi), %esi

# ALL:          Iterations:        1
# ALL-NEXT:     Instructions:      2
# ALL-NEXT:     Total Cycles:      9
# ALL-NEXT:     Total uOps:        3

# BDWELL:       Dispatch Width:    4
# BDWELL-NEXT:  uOps Per Cycle:    0.33
# BDWELL-NEXT:  IPC:               0.22
# BDWELL-NEXT:  Block RThroughput: 0.8

# HASWELL:      Dispatch Width:    4
# HASWELL-NEXT: uOps Per Cycle:    0.33
# HASWELL-NEXT: IPC:               0.22
# HASWELL-NEXT: Block RThroughput: 0.8

# SANDY:        Dispatch Width:    4
# SANDY-NEXT:   uOps Per Cycle:    0.33
# SANDY-NEXT:   IPC:               0.22
# SANDY-NEXT:   Block RThroughput: 0.8

# SKYLAKE:      Dispatch Width:    6
# SKYLAKE-NEXT: uOps Per Cycle:    0.33
# SKYLAKE-NEXT: IPC:               0.22
# SKYLAKE-NEXT: Block RThroughput: 0.5

# ALL:          Timeline view:
# ALL-NEXT:     Index     012345678

# ALL:          [0,0]     DeER .  .   addl	%edi, %esi
# ALL-NEXT:     [0,1]     DeeeeeeER   addl	(%rdi), %esi

# ALL:          Average Wait times (based on the timeline view):
# ALL-NEXT:     [0]: Executions
# ALL-NEXT:     [1]: Average time spent waiting in a scheduler's queue
# ALL-NEXT:     [2]: Average time spent waiting in a scheduler's queue while ready
# ALL-NEXT:     [3]: Average time elapsed from WB until retire stage

# ALL:                [0]    [1]    [2]    [3]
# ALL-NEXT:     0.     1     1.0    1.0    0.0       addl	%edi, %esi
# ALL-NEXT:     1.     1     1.0    0.0    0.0       addl	(%rdi), %esi
# ALL-NEXT:            1     1.0    0.5    0.0       <total>
