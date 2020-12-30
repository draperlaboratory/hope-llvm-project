; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -lower-amx-type %s -S | FileCheck %s

%struct.__tile_str = type { i16, i16, <256 x i32> }

@buf = dso_local global [1024 x i8] zeroinitializer, align 16
@buf2 = dso_local global [1024 x i8] zeroinitializer, align 16

; test bitcast x86_amx to <256 x i32>
define dso_local void @test_user_empty(i16 %m, i16 %n, i8 *%buf, i64 %s) {
; CHECK-LABEL: @test_user_empty(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[T1:%.*]] = call x86_amx @llvm.x86.tileloadd64.internal(i16 [[M:%.*]], i16 [[N:%.*]], i8* [[BUF:%.*]], i64 [[S:%.*]])
; CHECK-NEXT:    ret void
;
entry:
  %t1 = call x86_amx @llvm.x86.tileloadd64.internal(i16 %m, i16 %n, i8* %buf, i64 %s)
  %t2 = bitcast x86_amx %t1 to <256 x i32>
  ret void
}

; test bitcast <256 x i32> to x86_amx
define dso_local void @test_user_empty2(<256 x i32> %in) {
; CHECK-LABEL: @test_user_empty2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    ret void
;
entry:
  %t = bitcast <256 x i32> %in to x86_amx
  ret void
}

define dso_local <256 x i32> @test_amx_load_bitcast(<256 x i32>* %in, i16 %m, i16 %n, i8 *%buf, i64 %s) {
; CHECK-LABEL: @test_amx_load_bitcast(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[T1:%.*]] = load <256 x i32>, <256 x i32>* [[IN:%.*]], align 64
; CHECK-NEXT:    [[TMP0:%.*]] = bitcast <256 x i32>* [[IN]] to i8*
; CHECK-NEXT:    [[TMP1:%.*]] = call x86_amx @llvm.x86.tileloadd64.internal(i16 [[M:%.*]], i16 [[N:%.*]], i8* [[TMP0]], i64 64)
; CHECK-NEXT:    call void @llvm.x86.tilestored64.internal(i16 [[M]], i16 [[N]], i8* [[BUF:%.*]], i64 [[S:%.*]], x86_amx [[TMP1]])
; CHECK-NEXT:    ret <256 x i32> [[T1]]
;
entry:
  %t1 = load <256 x i32>, <256 x i32>* %in, align 64
  %t2 = bitcast <256 x i32> %t1 to x86_amx
  call void @llvm.x86.tilestored64.internal(i16 %m, i16 %n, i8* %buf, i64 %s, x86_amx %t2)
  ret <256 x i32> %t1
}

define dso_local <256 x i32> @test_amx_bitcast_store(<256 x i32>* %out, i16 %m, i16 %n, i8 *%buf, i64 %s) {
; CHECK-LABEL: @test_amx_bitcast_store(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[T1:%.*]] = call x86_amx @llvm.x86.tileloadd64.internal(i16 [[M:%.*]], i16 [[M]], i8* [[BUF:%.*]], i64 [[S:%.*]])
; CHECK-NEXT:    [[TMP0:%.*]] = bitcast <256 x i32>* [[OUT:%.*]] to i8*
; CHECK-NEXT:    call void @llvm.x86.tilestored64.internal(i16 [[M]], i16 [[M]], i8* [[TMP0]], i64 64, x86_amx [[T1]])
; CHECK-NEXT:    [[TMP1:%.*]] = load <256 x i32>, <256 x i32>* [[OUT]], align 1024
; CHECK-NEXT:    ret <256 x i32> [[TMP1]]
;
entry:
  %t1 = call x86_amx @llvm.x86.tileloadd64.internal(i16 %m, i16 %m, i8* %buf, i64 %s)
  %t2 = bitcast x86_amx %t1 to <256 x i32>
  store <256 x i32> %t2, <256 x i32>* %out
  ret <256 x i32> %t2
}

define dso_local void @test_src_add(<256 x i32> %x, <256 x i32> %y, i16 %r, i16 %c, i8* %buf, i64 %s) {
; CHECK-LABEL: @test_src_add(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = alloca <256 x i32>, align 64
; CHECK-NEXT:    [[ADD:%.*]] = add <256 x i32> [[Y:%.*]], [[X:%.*]]
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast <256 x i32>* [[TMP0]] to i8*
; CHECK-NEXT:    store <256 x i32> [[ADD]], <256 x i32>* [[TMP0]], align 1024
; CHECK-NEXT:    [[TMP2:%.*]] = call x86_amx @llvm.x86.tileloadd64.internal(i16 [[R:%.*]], i16 [[C:%.*]], i8* [[TMP1]], i64 64)
; CHECK-NEXT:    call void @llvm.x86.tilestored64.internal(i16 [[R]], i16 [[C]], i8* [[BUF:%.*]], i64 [[S:%.*]], x86_amx [[TMP2]])
; CHECK-NEXT:    ret void
;
entry:
  %add = add <256 x i32> %y, %x
  %t = bitcast <256 x i32> %add to x86_amx
  call void @llvm.x86.tilestored64.internal(i16 %r, i16 %c, i8* %buf, i64 %s, x86_amx %t)
  ret void
}

define dso_local void @test_src_add2(<256 x i32> %x, i16 %r, i16 %c, i8* %buf, i64 %s) {
; CHECK-LABEL: @test_src_add2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = alloca <256 x i32>, align 64
; CHECK-NEXT:    [[T1:%.*]] = call x86_amx @llvm.x86.tileloadd64.internal(i16 [[R:%.*]], i16 [[C:%.*]], i8* [[BUF:%.*]], i64 [[S:%.*]])
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast <256 x i32>* [[TMP0]] to i8*
; CHECK-NEXT:    call void @llvm.x86.tilestored64.internal(i16 [[R]], i16 [[C]], i8* [[TMP1]], i64 64, x86_amx [[T1]])
; CHECK-NEXT:    [[TMP2:%.*]] = load <256 x i32>, <256 x i32>* [[TMP0]], align 1024
; CHECK-NEXT:    [[ADD:%.*]] = add <256 x i32> [[TMP2]], [[X:%.*]]
; CHECK-NEXT:    ret void
;
entry:
  %t1 = call x86_amx @llvm.x86.tileloadd64.internal(i16 %r, i16 %c, i8* %buf, i64 %s)
  %t2 = bitcast x86_amx %t1 to <256 x i32>
  %add = add <256 x i32> %t2, %x
  ret void
}

define dso_local void @test_load(i8* %in, i8* %out) local_unnamed_addr {
; CHECK-LABEL: @test_load(
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast i8* [[IN:%.*]] to <256 x i32>*
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8* [[OUT:%.*]] to <256 x i32>*
; CHECK-NEXT:    [[TMP3:%.*]] = load <256 x i32>, <256 x i32>* [[TMP1]], align 64
; CHECK-NEXT:    store <256 x i32> [[TMP3]], <256 x i32>* [[TMP2]], align 64
; CHECK-NEXT:    ret void
;
  %1 = bitcast i8* %in to <256 x i32>*
  %2 = bitcast i8* %out to <256 x i32>*
  %3 = load <256 x i32>, <256 x i32>* %1, align 64
  store <256 x i32> %3, <256 x i32>* %2, align 64
  ret void
}

define dso_local <256 x i32> @foo(<256 x i32>* nocapture readonly byval(<256 x i32>) align 1024 %0, <256 x i32>* nocapture readonly byval(<256 x i32>) align 1024 %1) local_unnamed_addr {
; CHECK-LABEL: @foo(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[X:%.*]] = load <256 x i32>, <256 x i32>* [[TMP0:%.*]], align 1024
; CHECK-NEXT:    [[Y:%.*]] = load <256 x i32>, <256 x i32>* [[TMP1:%.*]], align 1024
; CHECK-NEXT:    [[ADD:%.*]] = add <256 x i32> [[Y]], [[X]]
; CHECK-NEXT:    ret <256 x i32> [[ADD]]
;
entry:
  %x = load <256 x i32>, <256 x i32>* %0, align 1024
  %y = load <256 x i32>, <256 x i32>* %1, align 1024
  %add = add <256 x i32> %y, %x
  ret <256 x i32> %add
}

define dso_local void @__tile_loadd(%struct.__tile_str* nocapture %0, i8* %1, i64 %2) local_unnamed_addr {
; CHECK-LABEL: @__tile_loadd(
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[STRUCT___TILE_STR:%.*]], %struct.__tile_str* [[TMP0:%.*]], i64 0, i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = load i16, i16* [[TMP4]], align 64
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr inbounds [[STRUCT___TILE_STR]], %struct.__tile_str* [[TMP0]], i64 0, i32 1
; CHECK-NEXT:    [[TMP7:%.*]] = load i16, i16* [[TMP6]], align 2
; CHECK-NEXT:    [[TMP8:%.*]] = shl i64 [[TMP2:%.*]], 32
; CHECK-NEXT:    [[TMP9:%.*]] = ashr exact i64 [[TMP8]], 32
; CHECK-NEXT:    [[TMP10:%.*]] = tail call x86_amx @llvm.x86.tileloadd64.internal(i16 [[TMP5]], i16 [[TMP7]], i8* [[TMP1:%.*]], i64 [[TMP9]])
; CHECK-NEXT:    [[TMP11:%.*]] = getelementptr inbounds [[STRUCT___TILE_STR]], %struct.__tile_str* [[TMP0]], i64 0, i32 2
; CHECK-NEXT:    [[TMP12:%.*]] = bitcast <256 x i32>* [[TMP11]] to i8*
; CHECK-NEXT:    call void @llvm.x86.tilestored64.internal(i16 [[TMP5]], i16 [[TMP7]], i8* [[TMP12]], i64 64, x86_amx [[TMP10]])
; CHECK-NEXT:    ret void
;
  %4 = getelementptr inbounds %struct.__tile_str, %struct.__tile_str* %0, i64 0, i32 0
  %5 = load i16, i16* %4, align 64
  %6 = getelementptr inbounds %struct.__tile_str, %struct.__tile_str* %0, i64 0, i32 1
  %7 = load i16, i16* %6, align 2
  %8 = shl i64 %2, 32
  %9 = ashr exact i64 %8, 32
  %10 = tail call x86_amx @llvm.x86.tileloadd64.internal(i16 %5, i16 %7, i8* %1, i64 %9)
  %11 = bitcast x86_amx %10 to <256 x i32>
  %12 = getelementptr inbounds %struct.__tile_str, %struct.__tile_str* %0, i64 0, i32 2
  store <256 x i32> %11, <256 x i32>* %12, align 64
  ret void
}

define dso_local void @__tile_dpbsud(%struct.__tile_str* nocapture %0, %struct.__tile_str* nocapture readonly byval(%struct.__tile_str) align 64 %1, %struct.__tile_str* nocapture readonly byval(%struct.__tile_str) align 64 %2) local_unnamed_addr {
; CHECK-LABEL: @__tile_dpbsud(
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[STRUCT___TILE_STR:%.*]], %struct.__tile_str* [[TMP1:%.*]], i64 0, i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = load i16, i16* [[TMP4]], align 64
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr inbounds [[STRUCT___TILE_STR]], %struct.__tile_str* [[TMP2:%.*]], i64 0, i32 1
; CHECK-NEXT:    [[TMP7:%.*]] = load i16, i16* [[TMP6]], align 2
; CHECK-NEXT:    [[TMP8:%.*]] = getelementptr inbounds [[STRUCT___TILE_STR]], %struct.__tile_str* [[TMP1]], i64 0, i32 1
; CHECK-NEXT:    [[TMP9:%.*]] = load i16, i16* [[TMP8]], align 2
; CHECK-NEXT:    [[TMP10:%.*]] = getelementptr inbounds [[STRUCT___TILE_STR]], %struct.__tile_str* [[TMP0:%.*]], i64 0, i32 2
; CHECK-NEXT:    [[TMP11:%.*]] = bitcast <256 x i32>* [[TMP10]] to i8*
; CHECK-NEXT:    [[TMP12:%.*]] = call x86_amx @llvm.x86.tileloadd64.internal(i16 [[TMP5]], i16 [[TMP7]], i8* [[TMP11]], i64 64)
; CHECK-NEXT:    [[TMP13:%.*]] = getelementptr inbounds [[STRUCT___TILE_STR]], %struct.__tile_str* [[TMP1]], i64 0, i32 2
; CHECK-NEXT:    [[TMP14:%.*]] = bitcast <256 x i32>* [[TMP13]] to i8*
; CHECK-NEXT:    [[TMP15:%.*]] = call x86_amx @llvm.x86.tileloadd64.internal(i16 [[TMP5]], i16 [[TMP9]], i8* [[TMP14]], i64 64)
; CHECK-NEXT:    [[TMP16:%.*]] = getelementptr inbounds [[STRUCT___TILE_STR]], %struct.__tile_str* [[TMP2]], i64 0, i32 2
; CHECK-NEXT:    [[TMP17:%.*]] = bitcast <256 x i32>* [[TMP16]] to i8*
; CHECK-NEXT:    [[TMP18:%.*]] = call x86_amx @llvm.x86.tileloadd64.internal(i16 [[TMP9]], i16 [[TMP7]], i8* [[TMP17]], i64 64)
; CHECK-NEXT:    [[TMP19:%.*]] = tail call x86_amx @llvm.x86.tdpbssd.internal(i16 [[TMP5]], i16 [[TMP7]], i16 [[TMP9]], x86_amx [[TMP12]], x86_amx [[TMP15]], x86_amx [[TMP18]])
; CHECK-NEXT:    [[TMP20:%.*]] = bitcast <256 x i32>* [[TMP10]] to i8*
; CHECK-NEXT:    call void @llvm.x86.tilestored64.internal(i16 [[TMP5]], i16 [[TMP7]], i8* [[TMP20]], i64 64, x86_amx [[TMP19]])
; CHECK-NEXT:    ret void
;
  %4 = getelementptr inbounds %struct.__tile_str, %struct.__tile_str* %1, i64 0, i32 0
  %5 = load i16, i16* %4, align 64
  %6 = getelementptr inbounds %struct.__tile_str, %struct.__tile_str* %2, i64 0, i32 1
  %7 = load i16, i16* %6, align 2
  %8 = getelementptr inbounds %struct.__tile_str, %struct.__tile_str* %1, i64 0, i32 1
  %9 = load i16, i16* %8, align 2
  %10 = getelementptr inbounds %struct.__tile_str, %struct.__tile_str* %0, i64 0, i32 2
  %11 = load <256 x i32>, <256 x i32>* %10, align 64
  %12 = bitcast <256 x i32> %11 to x86_amx
  %13 = getelementptr inbounds %struct.__tile_str, %struct.__tile_str* %1, i64 0, i32 2
  %14 = load <256 x i32>, <256 x i32>* %13, align 64
  %15 = bitcast <256 x i32> %14 to x86_amx
  %16 = getelementptr inbounds %struct.__tile_str, %struct.__tile_str* %2, i64 0, i32 2
  %17 = load <256 x i32>, <256 x i32>* %16, align 64
  %18 = bitcast <256 x i32> %17 to x86_amx
  %19 = tail call x86_amx @llvm.x86.tdpbssd.internal(i16 %5, i16 %7, i16 %9, x86_amx %12, x86_amx %15, x86_amx %18)
  %20 = bitcast x86_amx %19 to <256 x i32>
  store <256 x i32> %20, <256 x i32>* %10, align 64
  ret void
}

define dso_local void @__tile_stored(i8* %0, i64 %1, %struct.__tile_str* nocapture readonly byval(%struct.__tile_str) align 64 %2) local_unnamed_addr {
; CHECK-LABEL: @__tile_stored(
; CHECK-NEXT:    [[TMP4:%.*]] = getelementptr inbounds [[STRUCT___TILE_STR:%.*]], %struct.__tile_str* [[TMP2:%.*]], i64 0, i32 0
; CHECK-NEXT:    [[TMP5:%.*]] = load i16, i16* [[TMP4]], align 64
; CHECK-NEXT:    [[TMP6:%.*]] = getelementptr inbounds [[STRUCT___TILE_STR]], %struct.__tile_str* [[TMP2]], i64 0, i32 1
; CHECK-NEXT:    [[TMP7:%.*]] = load i16, i16* [[TMP6]], align 2
; CHECK-NEXT:    [[TMP8:%.*]] = getelementptr inbounds [[STRUCT___TILE_STR]], %struct.__tile_str* [[TMP2]], i64 0, i32 2
; CHECK-NEXT:    [[TMP9:%.*]] = bitcast <256 x i32>* [[TMP8]] to i8*
; CHECK-NEXT:    [[TMP10:%.*]] = call x86_amx @llvm.x86.tileloadd64.internal(i16 [[TMP5]], i16 [[TMP7]], i8* [[TMP9]], i64 64)
; CHECK-NEXT:    [[TMP11:%.*]] = shl i64 [[TMP1:%.*]], 32
; CHECK-NEXT:    [[TMP12:%.*]] = ashr exact i64 [[TMP11]], 32
; CHECK-NEXT:    tail call void @llvm.x86.tilestored64.internal(i16 [[TMP5]], i16 [[TMP7]], i8* [[TMP0:%.*]], i64 [[TMP12]], x86_amx [[TMP10]])
; CHECK-NEXT:    ret void
;
  %4 = getelementptr inbounds %struct.__tile_str, %struct.__tile_str* %2, i64 0, i32 0
  %5 = load i16, i16* %4, align 64
  %6 = getelementptr inbounds %struct.__tile_str, %struct.__tile_str* %2, i64 0, i32 1
  %7 = load i16, i16* %6, align 2
  %8 = getelementptr inbounds %struct.__tile_str, %struct.__tile_str* %2, i64 0, i32 2
  %9 = load <256 x i32>, <256 x i32>* %8, align 64
  %10 = bitcast <256 x i32> %9 to x86_amx
  %11 = shl i64 %1, 32
  %12 = ashr exact i64 %11, 32
  tail call void @llvm.x86.tilestored64.internal(i16 %5, i16 %7, i8* %0, i64 %12, x86_amx %10)
  ret void
}

declare x86_amx @llvm.x86.tileloadd64.internal(i16, i16, i8*, i64)
declare x86_amx @llvm.x86.tdpbssd.internal(i16, i16, i16, x86_amx, x86_amx, x86_amx)
declare void @llvm.x86.tilestored64.internal(i16, i16, i8*, i64, x86_amx)
