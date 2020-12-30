; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+amx-int8 -mattr=+avx512f -verify-machineinstrs | FileCheck %s

@buf = dso_local global [1024 x i8] zeroinitializer, align 16
@buf2 = dso_local global [1024 x i8] zeroinitializer, align 16

define dso_local void @test_api(i32 %0, i16 signext %1, i16 signext %2) local_unnamed_addr {
; CHECK-LABEL: test_api:
; CHECK:       # %bb.0:
; CHECK-NEXT:    subq $2936, %rsp # imm = 0xB78
; CHECK-NEXT:    .cfi_def_cfa_offset 2944
; CHECK-NEXT:    vpxord %zmm0, %zmm0, %zmm0
; CHECK-NEXT:    vmovdqu64 %zmm0, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movb $1, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movb %dl, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movw %dx, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movb %dl, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movw %dx, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movb %sil, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movw %dx, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movb %sil, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movw %dx, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movb %dl, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movw %dx, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movb %dl, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movw %dx, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movb %sil, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movw %si, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movb %sil, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movw %dx, {{[0-9]+}}(%rsp)
; CHECK-NEXT:    ldtilecfg {{[0-9]+}}(%rsp)
; CHECK-NEXT:    movl $buf, %r8d
; CHECK-NEXT:    movl $32, %eax
; CHECK-NEXT:    tileloadd (%r8,%rax), %tmm1
; CHECK-NEXT:    tileloadd (%r8,%rax), %tmm1
; CHECK-NEXT:    movabsq $64, %rcx
; CHECK-NEXT:    tilestored %tmm1, 896(%rsp,%rcx) # 1024-byte Folded Spill
; CHECK-NEXT:    tileloadd (%r8,%rax), %tmm3
; CHECK-NEXT:    tileloadd (%r8,%rax), %tmm4
; CHECK-NEXT:    tileloadd (%r8,%rax), %tmm2
; CHECK-NEXT:    tileloadd (%r8,%rax), %tmm5
; CHECK-NEXT:    tileloadd (%r8,%rax), %tmm0
; CHECK-NEXT:    testl %edi, %edi
; CHECK-NEXT:    je .LBB0_2
; CHECK-NEXT:  # %bb.1:
; CHECK-NEXT:    tileloadd (%r8,%rax), %tmm6
; CHECK-NEXT:    tileloadd (%r8,%rax), %tmm7
; CHECK-NEXT:    tileloadd (%r8,%rax), %tmm1
; CHECK-NEXT:    jmp .LBB0_3
; CHECK-NEXT:  .LBB0_2:
; CHECK-NEXT:    movl $buf2, %ecx
; CHECK-NEXT:    tileloadd (%rcx,%rax), %tmm6
; CHECK-NEXT:    tileloadd (%rcx,%rax), %tmm7
; CHECK-NEXT:    tileloadd (%rcx,%rax), %tmm1
; CHECK-NEXT:  .LBB0_3:
; CHECK-NEXT:    tdpbssd %tmm7, %tmm6, %tmm1
; CHECK-NEXT:    movabsq $64, %rax
; CHECK-NEXT:    tileloadd 896(%rsp,%rax), %tmm7 # 1024-byte Folded Reload
; CHECK-NEXT:    tdpbssd %tmm7, %tmm1, %tmm3
; CHECK-NEXT:    tdpbssd %tmm4, %tmm3, %tmm2
; CHECK-NEXT:    tdpbssd %tmm5, %tmm2, %tmm0
; CHECK-NEXT:    movl $buf, %eax
; CHECK-NEXT:    movl $32, %ecx
; CHECK-NEXT:    tilestored %tmm0, (%rax,%rcx)
; CHECK-NEXT:    addq $2936, %rsp # imm = 0xB78
; CHECK-NEXT:    .cfi_def_cfa_offset 8
; CHECK-NEXT:    tilerelease
; CHECK-NEXT:    vzeroupper
; CHECK-NEXT:    retq
  %4 = tail call x86_amx @llvm.x86.tileloadd64.internal(i16 %1, i16 %2, i8* getelementptr inbounds ([1024 x i8], [1024 x i8]* @buf, i64 0, i64 0), i64 32)
  %5 = tail call x86_amx @llvm.x86.tileloadd64.internal(i16 %1, i16 %2, i8* getelementptr inbounds ([1024 x i8], [1024 x i8]* @buf, i64 0, i64 0), i64 32)
  %6 = tail call x86_amx @llvm.x86.tileloadd64.internal(i16 %1, i16 %2, i8* getelementptr inbounds ([1024 x i8], [1024 x i8]* @buf, i64 0, i64 0), i64 32)
  %7 = tail call x86_amx @llvm.x86.tileloadd64.internal(i16 %2, i16 %2, i8* getelementptr inbounds ([1024 x i8], [1024 x i8]* @buf, i64 0, i64 0), i64 32)
  %8 = tail call x86_amx @llvm.x86.tileloadd64.internal(i16 %2, i16 %2, i8* getelementptr inbounds ([1024 x i8], [1024 x i8]* @buf, i64 0, i64 0), i64 32)
  %9 = tail call x86_amx @llvm.x86.tileloadd64.internal(i16 %2, i16 %2, i8* getelementptr inbounds ([1024 x i8], [1024 x i8]* @buf, i64 0, i64 0), i64 32)
  %10 = tail call x86_amx @llvm.x86.tileloadd64.internal(i16 %2, i16 %2, i8* getelementptr inbounds ([1024 x i8], [1024 x i8]* @buf, i64 0, i64 0), i64 32)
  %11 = icmp eq i32 %0, 0
  br i1 %11, label %16, label %12

12:                                               ; preds = %3
  %13 = tail call x86_amx @llvm.x86.tileloadd64.internal(i16 %1, i16 %1, i8* getelementptr inbounds ([1024 x i8], [1024 x i8]* @buf, i64 0, i64 0), i64 32)
  %14 = tail call x86_amx @llvm.x86.tileloadd64.internal(i16 %1, i16 %2, i8* getelementptr inbounds ([1024 x i8], [1024 x i8]* @buf, i64 0, i64 0), i64 32)
  %15 = tail call x86_amx @llvm.x86.tileloadd64.internal(i16 %1, i16 %2, i8* getelementptr inbounds ([1024 x i8], [1024 x i8]* @buf, i64 0, i64 0), i64 32)
  br label %20

16:                                               ; preds = %3
  %17 = tail call x86_amx @llvm.x86.tileloadd64.internal(i16 %1, i16 %1, i8* getelementptr inbounds ([1024 x i8], [1024 x i8]* @buf2, i64 0, i64 0), i64 32)
  %18 = tail call x86_amx @llvm.x86.tileloadd64.internal(i16 %1, i16 %2, i8* getelementptr inbounds ([1024 x i8], [1024 x i8]* @buf2, i64 0, i64 0), i64 32)
  %19 = tail call x86_amx @llvm.x86.tileloadd64.internal(i16 %1, i16 %2, i8* getelementptr inbounds ([1024 x i8], [1024 x i8]* @buf2, i64 0, i64 0), i64 32)
  br label %20

20:                                               ; preds = %16, %12
  %21 = phi x86_amx [ %17, %16 ], [ %13, %12 ]
  %22 = phi x86_amx [ %18, %16 ], [ %14, %12 ]
  %23 = phi x86_amx [ %19, %16 ], [ %15, %12 ]
  %24 = tail call x86_amx @llvm.x86.tdpbssd.internal(i16 %1, i16 %2, i16 %1, x86_amx %23, x86_amx %21, x86_amx %22)
  %25 = tail call x86_amx @llvm.x86.tdpbssd.internal(i16 %1, i16 %2, i16 %2, x86_amx %6, x86_amx %24, x86_amx %5)
  %26 = tail call x86_amx @llvm.x86.tdpbssd.internal(i16 %1, i16 %2, i16 %2, x86_amx %8, x86_amx %25, x86_amx %7)
  %27 = tail call x86_amx @llvm.x86.tdpbssd.internal(i16 %2, i16 %2, i16 %2, x86_amx %10, x86_amx %26, x86_amx %9)
  tail call void @llvm.x86.tilestored64.internal(i16 %2, i16 %2, i8* getelementptr inbounds ([1024 x i8], [1024 x i8]* @buf, i64 0, i64 0), i64 32, x86_amx %27)
  ret void
}

declare x86_amx @llvm.x86.tileloadd64.internal(i16, i16, i8*, i64)
declare x86_amx @llvm.x86.tdpbssd.internal(i16, i16, i16, x86_amx, x86_amx, x86_amx)
declare void @llvm.x86.tilestored64.internal(i16, i16, i8*, i64, x86_amx)
