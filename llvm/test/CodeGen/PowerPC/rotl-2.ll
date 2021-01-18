; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs < %s -mtriple=ppc32-- | FileCheck %s
; RUN: llc -verify-machineinstrs < %s -mtriple=powerpc-ibm-aix-xcoff | FileCheck %s

define i32 @rotl32(i32 %A, i8 %Amt) nounwind {
; CHECK-LABEL: rotl32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    rotlw 3, 3, 4
; CHECK-NEXT:    blr
	%shift.upgrd.1 = zext i8 %Amt to i32		; <i32> [#uses=1]
	%B = shl i32 %A, %shift.upgrd.1		; <i32> [#uses=1]
	%Amt2 = sub i8 32, %Amt		; <i8> [#uses=1]
	%shift.upgrd.2 = zext i8 %Amt2 to i32		; <i32> [#uses=1]
	%C = lshr i32 %A, %shift.upgrd.2		; <i32> [#uses=1]
	%D = or i32 %B, %C		; <i32> [#uses=1]
	ret i32 %D
}

define i32 @rotr32(i32 %A, i8 %Amt) nounwind {
; CHECK-LABEL: rotr32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    subfic 4, 4, 32
; CHECK-NEXT:    rotlw 3, 3, 4
; CHECK-NEXT:    blr
	%shift.upgrd.3 = zext i8 %Amt to i32		; <i32> [#uses=1]
	%B = lshr i32 %A, %shift.upgrd.3		; <i32> [#uses=1]
	%Amt2 = sub i8 32, %Amt		; <i8> [#uses=1]
	%shift.upgrd.4 = zext i8 %Amt2 to i32		; <i32> [#uses=1]
	%C = shl i32 %A, %shift.upgrd.4		; <i32> [#uses=1]
	%D = or i32 %B, %C		; <i32> [#uses=1]
	ret i32 %D
}

define i32 @rotli32(i32 %A) nounwind {
; CHECK-LABEL: rotli32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    rotlwi 3, 3, 5
; CHECK-NEXT:    blr
	%B = shl i32 %A, 5		; <i32> [#uses=1]
	%C = lshr i32 %A, 27		; <i32> [#uses=1]
	%D = or i32 %B, %C		; <i32> [#uses=1]
	ret i32 %D
}

define i32 @rotri32(i32 %A) nounwind {
; CHECK-LABEL: rotri32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    rotlwi 3, 3, 27
; CHECK-NEXT:    blr
	%B = lshr i32 %A, 5		; <i32> [#uses=1]
	%C = shl i32 %A, 27		; <i32> [#uses=1]
	%D = or i32 %B, %C		; <i32> [#uses=1]
	ret i32 %D
}

