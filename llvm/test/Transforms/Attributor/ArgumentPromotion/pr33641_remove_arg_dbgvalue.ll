; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt -attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=1 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_NPM,NOT_CGSCC_OPM,NOT_TUNIT_NPM,IS__TUNIT____,IS________OPM,IS__TUNIT_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor -attributor-manifest-internal  -attributor-max-iterations-verify -attributor-annotate-decl-cs -attributor-max-iterations=1 -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_CGSCC_OPM,NOT_CGSCC_NPM,NOT_TUNIT_OPM,IS__TUNIT____,IS________NPM,IS__TUNIT_NPM
; RUN: opt -attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_NPM,IS__CGSCC____,IS________OPM,IS__CGSCC_OPM
; RUN: opt -aa-pipeline=basic-aa -passes=attributor-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,NOT_TUNIT_NPM,NOT_TUNIT_OPM,NOT_CGSCC_OPM,IS__CGSCC____,IS________NPM,IS__CGSCC_NPM

; Fix for PR33641. ArgumentPromotion removed the argument to bar but left the call to
; dbg.value which still used the removed argument.

; The %p argument should be removed, and the use of it in dbg.value should be
; changed to undef.

%p_t = type i16*
%fun_t = type void (%p_t)*

define void @foo() {
; CHECK-LABEL: define {{[^@]+}}@foo()
; CHECK-NEXT:    [[TMP:%.*]] = alloca void (i16*)*
; CHECK-NEXT:    store void (i16*)* @bar, void (i16*)** [[TMP]], align 8
; CHECK-NEXT:    ret void
;
  %tmp = alloca %fun_t
  store %fun_t @bar, %fun_t* %tmp
  ret void
}

define internal void @bar(%p_t %p)  {
; CHECK-LABEL: define {{[^@]+}}@bar
; CHECK-SAME: (i16* nocapture nofree readnone [[P:%.*]])
; CHECK-NEXT:    call void @llvm.dbg.value(metadata i16* [[P]], metadata !3, metadata !DIExpression()) #3, !dbg !5
; CHECK-NEXT:    ret void
;
  call void @llvm.dbg.value(metadata %p_t %p, metadata !4, metadata !5), !dbg !6
  ret void
}

declare void @llvm.dbg.value(metadata, metadata, metadata)

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2}

!0 = distinct !DICompileUnit(language: DW_LANG_C, file: !1)
!1 = !DIFile(filename: "test.c", directory: "")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = distinct !DISubprogram(name: "bar", unit: !0)
!4 = !DILocalVariable(name: "p", scope: !3)
!5 = !DIExpression()
!6 = !DILocation(line: 1, column: 1, scope: !3)
