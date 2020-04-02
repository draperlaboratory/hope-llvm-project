; RUN: lli -jit-kind=orc-lazy -orc-lazy-debug=funcs-to-stdout %s | FileCheck %s
;
; Test that global constructors and destructors are run.
;
; CHECK: Hello
; CHECK: [ {{.*}}main{{.*}} ]
; CHECK: Goodbye

%class.Foo = type { i8 }

@f = global %class.Foo zeroinitializer, align 1
@__dso_handle = external global i8
@llvm.global_ctors = appending global [1 x { i32, void ()*, i8* }] [{ i32, void ()*, i8* } { i32 65535, void ()* @_GLOBAL__sub_I_hello.cpp, i8* null }]
@str = private unnamed_addr constant [6 x i8] c"Hello\00"
@str2 = private unnamed_addr constant [8 x i8] c"Goodbye\00"

define linkonce_odr void @_ZN3FooD1Ev(%class.Foo* nocapture readnone %this) unnamed_addr align 2 {
entry:
  %puts.i = tail call i32 @puts(i8* getelementptr inbounds ([8 x i8], [8 x i8]* @str2, i64 0, i64 0))
  ret void
}

declare i32 @__cxa_atexit(void (i8*)*, i8*, i8*)

define i32 @main(i32 %argc, i8** nocapture readnone %argv) {
entry:
  ret i32 0
}

define internal void @_GLOBAL__sub_I_hello.cpp() {
entry:
  %puts.i.i.i = tail call i32 @puts(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @str, i64 0, i64 0))
  %0 = tail call i32 @__cxa_atexit(void (i8*)* bitcast (void (%class.Foo*)* @_ZN3FooD1Ev to void (i8*)*), i8* getelementptr inbounds (%class.Foo, %class.Foo* @f, i64 0, i32 0), i8* @__dso_handle)
  ret void
}

declare i32 @puts(i8* nocapture readonly)
