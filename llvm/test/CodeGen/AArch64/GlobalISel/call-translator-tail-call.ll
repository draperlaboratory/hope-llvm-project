; NOTE: Assertions have been autogenerated by utils/update_mir_test_checks.py
; RUN: llc %s -stop-after=irtranslator -verify-machineinstrs -mtriple aarch64-apple-darwin -global-isel -o - 2>&1 | FileCheck %s --check-prefixes=DARWIN,COMMON
; RUN: llc %s -stop-after=irtranslator -verify-machineinstrs -mtriple aarch64-windows -global-isel -o - 2>&1 | FileCheck %s --check-prefixes=WINDOWS,COMMON

declare void @simple_fn()
define void @tail_call() {
  ; COMMON-LABEL: name: tail_call
  ; COMMON: bb.1 (%ir-block.0):
  ; COMMON:   TCRETURNdi @simple_fn, 0, csr_aarch64_aapcs, implicit $sp
  tail call void @simple_fn()
  ret void
}

; We should get a TCRETURNri here.
; FIXME: We don't need the COPY.
define void @indirect_tail_call(void()* %func) {
  ; COMMON-LABEL: name: indirect_tail_call
  ; COMMON: bb.1 (%ir-block.0):
  ; COMMON:   liveins: $x0
  ; COMMON:   [[COPY:%[0-9]+]]:tcgpr64(p0) = COPY $x0
  ; COMMON:   TCRETURNri [[COPY]](p0), 0, csr_aarch64_aapcs, implicit $sp
  tail call void %func()
  ret void
}

declare void @outgoing_args_fn(i32)
define void @test_outgoing_args(i32 %a) {
  ; COMMON-LABEL: name: test_outgoing_args
  ; COMMON: bb.1 (%ir-block.0):
  ; COMMON:   liveins: $w0
  ; COMMON:   [[COPY:%[0-9]+]]:_(s32) = COPY $w0
  ; COMMON:   $w0 = COPY [[COPY]](s32)
  ; COMMON:   TCRETURNdi @outgoing_args_fn, 0, csr_aarch64_aapcs, implicit $sp, implicit $w0
  tail call void @outgoing_args_fn(i32 %a)
  ret void
}

; Verify that we create frame indices for memory arguments in tail calls.
; We get a bunch of copies here which are unused and thus eliminated. So, let's
; just focus on what matters, which is that we get a G_FRAME_INDEX.
declare void @outgoing_stack_args_fn(<4 x half>)
define void @test_outgoing_stack_args([8 x <2 x double>], <4 x half> %arg) {
  ; COMMON-LABEL: name: test_outgoing_stack_args
  ; COMMON:   [[FRAME_INDEX:%[0-9]+]]:_(p0) = G_FRAME_INDEX %fixed-stack.0
  ; COMMON:   [[LOAD:%[0-9]+]]:_(<4 x s16>) = G_LOAD [[FRAME_INDEX]](p0) :: (invariant load 8 from %fixed-stack.0, align 16)
  ; COMMON:   $d0 = COPY [[LOAD]](<4 x s16>)
  ; COMMON:   TCRETURNdi @outgoing_stack_args_fn, 0, csr_aarch64_aapcs, implicit $sp, implicit $d0
  tail call void @outgoing_stack_args_fn(<4 x half> %arg)
  ret void
}

; Verify that we don't tail call when we cannot fit arguments on the caller's
; stack.
declare i32 @too_big_stack(i64 %x0, i64 %x1, i64 %x2, i64 %x3, i64 %x4, i64 %x5, i64 %x6, i64 %x7, i8 %c, i16 %s)
define i32 @test_too_big_stack() {
  ; COMMON-LABEL: name: test_too_big_stack
  ; COMMON-NOT: TCRETURNdi
  ; COMMON-NOT: TCRETURNri
  ; COMMON: BL @too_big_stack
  ; COMMON-DAG: RET_ReallyLR
entry:
  %call = tail call i32 @too_big_stack(i64 undef, i64 undef, i64 undef, i64 undef, i64 undef, i64 undef, i64 undef, i64 undef, i8 8, i16 9)
  ret i32 %call
}

; Right now, we don't want to tail call callees with nonvoid return types, since
; call lowering will insert COPYs after the call.
; TODO: Support this.
declare i32 @nonvoid_ret()
define i32 @test_nonvoid_ret() {
  ; COMMON-LABEL: name: test_nonvoid_ret
  ; COMMON: bb.1 (%ir-block.0):
  ; COMMON:   TCRETURNdi @nonvoid_ret, 0, csr_aarch64_aapcs, implicit $sp
  %call = tail call i32 @nonvoid_ret()
  ret i32 %call
}

declare void @varargs(i32, double, i64, ...)
define void @test_varargs() {
  ; COMMON-LABEL: name: test_varargs
  ; COMMON: bb.1 (%ir-block.0):
  ; COMMON:   [[C:%[0-9]+]]:_(s32) = G_CONSTANT i32 42
  ; COMMON:   [[C1:%[0-9]+]]:_(s64) = G_FCONSTANT double 1.000000e+00
  ; COMMON:   [[C2:%[0-9]+]]:_(s64) = G_CONSTANT i64 12
  ; COMMON:   $w0 = COPY [[C]](s32)
  ; COMMON:   $d0 = COPY [[C1]](s64)
  ; COMMON:   $x1 = COPY [[C2]](s64)
  ; COMMON:   TCRETURNdi @varargs, 0, csr_aarch64_aapcs, implicit $sp, implicit $w0, implicit $d0, implicit $x1
  tail call void(i32, double, i64, ...) @varargs(i32 42, double 1.0, i64 12)
  ret void
}

; Darwin should not tail call here, because the last parameter to @varargs is
; not fixed. So, it's passed on the stack, which will make us not fit. On
; Windows, it's passed in a register, so it's safe to tail call.
define void @test_varargs_2() {
  ; DARWIN-LABEL: name: test_varargs_2
  ; DARWIN-NOT: TCRETURNdi @varargs
  ; DARWIN:   BL @varargs, csr_aarch64_aapcs, implicit-def $lr, implicit $sp, implicit $w0, implicit $d0, implicit $x1
  ; DARWIN:   ADJCALLSTACKUP 8, 0, implicit-def $sp, implicit $sp
  ; DARWIN:   RET_ReallyLR

  ; WINDOWS-LABEL: name: test_varargs_2
  ; WINDOWS: bb.1 (%ir-block.0):
  ; WINDOWS:   [[C:%[0-9]+]]:_(s32) = G_CONSTANT i32 42
  ; WINDOWS:   [[C1:%[0-9]+]]:_(s64) = G_FCONSTANT double 1.000000e+00
  ; WINDOWS:   [[C2:%[0-9]+]]:_(s64) = G_CONSTANT i64 12
  ; WINDOWS:   [[C3:%[0-9]+]]:_(s64) = G_CONSTANT i64 314
  ; WINDOWS:   $w0 = COPY [[C]](s32)
  ; WINDOWS:   $d0 = COPY [[C1]](s64)
  ; WINDOWS:   $x1 = COPY [[C2]](s64)
  ; WINDOWS:   $x2 = COPY [[C3]](s64)
  ; WINDOWS:   TCRETURNdi @varargs, 0, csr_aarch64_aapcs, implicit $sp, implicit $w0, implicit $d0, implicit $x1, implicit $x2
  tail call void(i32, double, i64, ...) @varargs(i32 42, double 1.0, i64 12, i64 314)
  ret void
}

; Same deal here, even though we have enough room to fit. On Darwin, we'll pass
; the last argument to @varargs on the stack. We don't allow tail calling
; varargs arguments that are on the stack.
define void @test_varargs_3([8 x <2 x double>], <4 x half> %arg) {
  ; DARWIN-LABEL: name: test_varargs_3
  ; DARWIN-NOT: TCRETURNdi @varargs
  ; DARWIN:   BL @varargs, csr_aarch64_aapcs, implicit-def $lr, implicit $sp, implicit $w0, implicit $d0, implicit $x1
  ; DARWIN:   ADJCALLSTACKUP 8, 0, implicit-def $sp, implicit $sp
  ; DARWIN:   RET_ReallyLR

  ; WINDOWS-LABEL: name: test_varargs_3
  ; WINDOWS: bb.1 (%ir-block.1):
  ; WINDOWS:   liveins: $q0, $q1, $q2, $q3, $q4, $q5, $q6, $q7
  ; WINDOWS:   [[COPY:%[0-9]+]]:_(<2 x s64>) = COPY $q0
  ; WINDOWS:   [[COPY1:%[0-9]+]]:_(<2 x s64>) = COPY $q1
  ; WINDOWS:   [[COPY2:%[0-9]+]]:_(<2 x s64>) = COPY $q2
  ; WINDOWS:   [[COPY3:%[0-9]+]]:_(<2 x s64>) = COPY $q3
  ; WINDOWS:   [[COPY4:%[0-9]+]]:_(<2 x s64>) = COPY $q4
  ; WINDOWS:   [[COPY5:%[0-9]+]]:_(<2 x s64>) = COPY $q5
  ; WINDOWS:   [[COPY6:%[0-9]+]]:_(<2 x s64>) = COPY $q6
  ; WINDOWS:   [[COPY7:%[0-9]+]]:_(<2 x s64>) = COPY $q7
  ; WINDOWS:   [[FRAME_INDEX:%[0-9]+]]:_(p0) = G_FRAME_INDEX %fixed-stack.0
  ; WINDOWS:   [[LOAD:%[0-9]+]]:_(<4 x s16>) = G_LOAD [[FRAME_INDEX]](p0) :: (invariant load 8 from %fixed-stack.0, align 16)
  ; WINDOWS:   [[C:%[0-9]+]]:_(s32) = G_CONSTANT i32 42
  ; WINDOWS:   [[C1:%[0-9]+]]:_(s64) = G_FCONSTANT double 1.000000e+00
  ; WINDOWS:   [[C2:%[0-9]+]]:_(s64) = G_CONSTANT i64 12
  ; WINDOWS:   [[C3:%[0-9]+]]:_(s64) = G_CONSTANT i64 314
  ; WINDOWS:   $w0 = COPY [[C]](s32)
  ; WINDOWS:   $d0 = COPY [[C1]](s64)
  ; WINDOWS:   $x1 = COPY [[C2]](s64)
  ; WINDOWS:   $x2 = COPY [[C3]](s64)
  ; WINDOWS:   TCRETURNdi @varargs, 0, csr_aarch64_aapcs, implicit $sp, implicit $w0, implicit $d0, implicit $x1, implicit $x2
  tail call void(i32, double, i64, ...) @varargs(i32 42, double 1.0, i64 12, i64 314)
  ret void
}

; Unsupported calling convention for tail calls. Make sure we never tail call
; it.
declare ghccc void @bad_call_conv_fn()
define void @test_bad_call_conv() {
  ; COMMON-LABEL: name: test_bad_call_conv
  ; COMMON: bb.1 (%ir-block.0):
  ; COMMON:   ADJCALLSTACKDOWN 0, 0, implicit-def $sp, implicit $sp
  ; COMMON:   BL @bad_call_conv_fn, csr_aarch64_noregs, implicit-def $lr, implicit $sp
  ; COMMON:   ADJCALLSTACKUP 0, 0, implicit-def $sp, implicit $sp
  ; COMMON:   RET_ReallyLR
  tail call ghccc void @bad_call_conv_fn()
  ret void
}

; Shouldn't tail call when the caller has byval arguments.
define void @test_byval(i8* byval %ptr) {
  ; COMMON-LABEL: name: test_byval
  ; COMMON: bb.1 (%ir-block.0):
  ; COMMON:   [[FRAME_INDEX:%[0-9]+]]:_(p0) = G_FRAME_INDEX %fixed-stack.0
  ; COMMON:   [[LOAD:%[0-9]+]]:_(p0) = G_LOAD [[FRAME_INDEX]](p0) :: (invariant load 8 from %fixed-stack.0, align 16)
  ; COMMON:   ADJCALLSTACKDOWN 0, 0, implicit-def $sp, implicit $sp
  ; COMMON:   BL @simple_fn, csr_aarch64_aapcs, implicit-def $lr, implicit $sp
  ; COMMON:   ADJCALLSTACKUP 0, 0, implicit-def $sp, implicit $sp
  ; COMMON:   RET_ReallyLR
  tail call void @simple_fn()
  ret void
}

; Shouldn't tail call when the caller has inreg arguments.
define void @test_inreg(i8* inreg %ptr) {
  ; COMMON-LABEL: name: test_inreg
  ; COMMON: bb.1 (%ir-block.0):
  ; COMMON:   liveins: $x0
  ; COMMON:   [[COPY:%[0-9]+]]:_(p0) = COPY $x0
  ; COMMON:   ADJCALLSTACKDOWN 0, 0, implicit-def $sp, implicit $sp
  ; COMMON:   BL @simple_fn, csr_aarch64_aapcs, implicit-def $lr, implicit $sp
  ; COMMON:   ADJCALLSTACKUP 0, 0, implicit-def $sp, implicit $sp
  ; COMMON:   RET_ReallyLR
  tail call void @simple_fn()
  ret void
}

declare fastcc void @fast_fn()
define void @test_mismatched_caller() {
  ; COMMON-LABEL: name: test_mismatched_caller
  ; COMMON: bb.1 (%ir-block.0):
  ; COMMON:   TCRETURNdi @fast_fn, 0, csr_aarch64_aapcs, implicit $sp
  tail call fastcc void @fast_fn()
  ret void
}

; Verify that lifetime markers and llvm.assume don't impact tail calling.
declare void @llvm.assume(i1)
define void @test_assume() local_unnamed_addr {
  ; COMMON-LABEL: name: test_assume
  ; COMMON: bb.1.entry:
  ; COMMON:   TCRETURNdi @nonvoid_ret, 0, csr_aarch64_aapcs, implicit $sp
entry:
  %x = tail call i32 @nonvoid_ret()
  %y = icmp ne i32 %x, 0
  tail call void @llvm.assume(i1 %y)
  ret void
}

declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture)
declare void @llvm.lifetime.end.p0i8(i64, i8* nocapture)
define void @test_lifetime() local_unnamed_addr {
  ; COMMON-LABEL: name: test_lifetime
  ; COMMON: bb.1.entry:
  ; COMMON:   [[FRAME_INDEX:%[0-9]+]]:_(p0) = G_FRAME_INDEX %stack.0.t
  ; COMMON:   LIFETIME_START %stack.0.t
  ; COMMON:   TCRETURNdi @nonvoid_ret, 0, csr_aarch64_aapcs, implicit $sp
entry:
  %t = alloca i8, align 1
  call void @llvm.lifetime.start.p0i8(i64 1, i8* %t)
  %x = tail call i32 @nonvoid_ret()
  %y = icmp ne i32 %x, 0
  tail call void @llvm.lifetime.end.p0i8(i64 1, i8* %t)
  ret void
}

; We can tail call when the callee swiftself is the same as the caller one.
; It would be nice to move this to swiftself.ll, but it's important to verify
; that we get the COPY that makes this safe in the first place.
declare i8* @pluto()
define hidden swiftcc i64 @swiftself_indirect_tail(i64* swiftself %arg) {
  ; COMMON-LABEL: name: swiftself_indirect_tail
  ; COMMON: bb.1 (%ir-block.0):
  ; COMMON:   liveins: $x20
  ; COMMON:   [[COPY:%[0-9]+]]:_(p0) = COPY $x20
  ; COMMON:   ADJCALLSTACKDOWN 0, 0, implicit-def $sp, implicit $sp
  ; COMMON:   BL @pluto, csr_aarch64_aapcs, implicit-def $lr, implicit $sp, implicit-def $x0
  ; COMMON:   [[COPY1:%[0-9]+]]:tcgpr64(p0) = COPY $x0
  ; COMMON:   ADJCALLSTACKUP 0, 0, implicit-def $sp, implicit $sp
  ; COMMON:   $x20 = COPY [[COPY]](p0)
  ; COMMON:   TCRETURNri [[COPY1]](p0), 0, csr_aarch64_aapcs, implicit $sp, implicit $x20
  %tmp = call i8* @pluto()
  %tmp1 = bitcast i8* %tmp to i64 (i64*)*
  %tmp2 = tail call swiftcc i64 %tmp1(i64* swiftself %arg)
  ret i64 %tmp2
}

; Verify that we can tail call musttail callees.
declare void @must_callee(i8*)
define void @foo(i32*) {
  ; COMMON-LABEL: name: foo
  ; COMMON: bb.1 (%ir-block.1):
  ; COMMON:   liveins: $x0
  ; COMMON:   [[COPY:%[0-9]+]]:_(p0) = COPY $x0
  ; COMMON:   [[C:%[0-9]+]]:_(p0) = G_CONSTANT i64 0
  ; COMMON:   $x0 = COPY [[C]](p0)
  ; COMMON:   TCRETURNdi @must_callee, 0, csr_aarch64_aapcs, implicit $sp, implicit $x0
  musttail call void @must_callee(i8* null)
  ret void
}
