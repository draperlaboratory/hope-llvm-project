; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
;
; PR30298: Check if the target doesn't have SSE2, compiler will not crash
; or generate incorrect code because of vector mul width shrinking optimization.
;
; RUN: llc -mtriple=i386-pc-linux-gnu -mattr=+sse < %s | FileCheck %s

@c = external dso_local global i32*, align 8

define void @mul_2xi8(i8* nocapture readonly %a, i8* nocapture readonly %b, i64 %index) nounwind {
; CHECK-LABEL: mul_2xi8:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    pushl %ebx
; CHECK-NEXT:    pushl %edi
; CHECK-NEXT:    pushl %esi
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %eax
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %ecx
; CHECK-NEXT:    movl {{[0-9]+}}(%esp), %edx
; CHECK-NEXT:    movl c, %esi
; CHECK-NEXT:    movzbl 1(%edx,%ecx), %edi
; CHECK-NEXT:    movzbl (%edx,%ecx), %edx
; CHECK-NEXT:    movzbl 1(%eax,%ecx), %ebx
; CHECK-NEXT:    imull %edi, %ebx
; CHECK-NEXT:    movzbl (%eax,%ecx), %eax
; CHECK-NEXT:    imull %edx, %eax
; CHECK-NEXT:    movl %ebx, 4(%esi,%ecx,4)
; CHECK-NEXT:    movl %eax, (%esi,%ecx,4)
; CHECK-NEXT:    popl %esi
; CHECK-NEXT:    popl %edi
; CHECK-NEXT:    popl %ebx
; CHECK-NEXT:    retl
entry:
  %pre = load i32*, i32** @c
  %tmp6 = getelementptr inbounds i8, i8* %a, i64 %index
  %tmp7 = bitcast i8* %tmp6 to <2 x i8>*
  %wide.load = load <2 x i8>, <2 x i8>* %tmp7, align 1
  %tmp8 = zext <2 x i8> %wide.load to <2 x i32>
  %tmp10 = getelementptr inbounds i8, i8* %b, i64 %index
  %tmp11 = bitcast i8* %tmp10 to <2 x i8>*
  %wide.load17 = load <2 x i8>, <2 x i8>* %tmp11, align 1
  %tmp12 = zext <2 x i8> %wide.load17 to <2 x i32>
  %tmp13 = mul nuw nsw <2 x i32> %tmp12, %tmp8
  %tmp14 = getelementptr inbounds i32, i32* %pre, i64 %index
  %tmp15 = bitcast i32* %tmp14 to <2 x i32>*
  store <2 x i32> %tmp13, <2 x i32>* %tmp15, align 4
  ret void
}
