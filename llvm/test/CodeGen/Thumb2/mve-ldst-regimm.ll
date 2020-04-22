; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=thumbv8.1m.main-none-none-eabi -mattr=+mve -verify-machineinstrs %s -o - | FileCheck %s

%struct.s_int8_t = type { [16 x i8], [16 x i8] }
%struct.s_int16_t = type { [8 x i16], [8 x i16] }
%struct.s_int32_t = type { [4 x i32], [4 x i32] }
%struct.s_float16_t = type { [8 x half], [8 x half] }
%struct.s_float32_t = type { [4 x float], [4 x float] }

define hidden void @fwd_int8_t(%struct.s_int8_t* noalias %v) local_unnamed_addr #0 {
; CHECK-LABEL: fwd_int8_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldrb.u8 q0, [r0]
; CHECK-NEXT:    vstrb.8 q0, [r0, #16]
; CHECK-NEXT:    bx lr
entry:
  %arrayidx3 = getelementptr inbounds %struct.s_int8_t, %struct.s_int8_t* %v, i32 0, i32 1, i32 0
  %0 = bitcast %struct.s_int8_t* %v to <16 x i8>*
  %1 = load <16 x i8>, <16 x i8>* %0, align 1
  %2 = bitcast i8* %arrayidx3 to <16 x i8>*
  store <16 x i8> %1, <16 x i8>* %2, align 1
  ret void
}

define hidden void @fwd_int16_t(%struct.s_int16_t* noalias nocapture %v) local_unnamed_addr #0 {
; CHECK-LABEL: fwd_int16_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldrh.u16 q0, [r0]
; CHECK-NEXT:    vstrh.16 q0, [r0, #16]
; CHECK-NEXT:    bx lr
entry:
  %arrayidx3 = getelementptr inbounds %struct.s_int16_t, %struct.s_int16_t* %v, i32 0, i32 1, i32 0
  %0 = bitcast %struct.s_int16_t* %v to <8 x i16>*
  %1 = load <8 x i16>, <8 x i16>* %0, align 2
  %2 = bitcast i16* %arrayidx3 to <8 x i16>*
  store <8 x i16> %1, <8 x i16>* %2, align 2
  ret void
}

define hidden void @fwd_int32_t(%struct.s_int32_t* noalias nocapture %v) local_unnamed_addr #0 {
; CHECK-LABEL: fwd_int32_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldrw.u32 q0, [r0]
; CHECK-NEXT:    vstrw.32 q0, [r0, #16]
; CHECK-NEXT:    bx lr
entry:
  %arrayidx3 = getelementptr inbounds %struct.s_int32_t, %struct.s_int32_t* %v, i32 0, i32 1, i32 0
  %0 = bitcast %struct.s_int32_t* %v to <4 x i32>*
  %1 = load <4 x i32>, <4 x i32>* %0, align 4
  %2 = bitcast i32* %arrayidx3 to <4 x i32>*
  store <4 x i32> %1, <4 x i32>* %2, align 4
  ret void
}

define hidden void @fwd_float16_t(%struct.s_float16_t* noalias nocapture %v) local_unnamed_addr #0 {
; CHECK-LABEL: fwd_float16_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldrh.u16 q0, [r0], #16
; CHECK-NEXT:    vstrh.16 q0, [r0]
; CHECK-NEXT:    bx lr
entry:
  %arrayidx3 = getelementptr inbounds %struct.s_float16_t, %struct.s_float16_t* %v, i32 0, i32 1, i32 0
  %0 = bitcast %struct.s_float16_t* %v to <8 x half>*
  %1 = load <8 x half>, <8 x half>* %0, align 2
  %2 = bitcast half* %arrayidx3 to <8 x half>*
  store <8 x half> %1, <8 x half>* %2, align 2
  ret void
}

define hidden void @fwd_float32_t(%struct.s_float32_t* noalias nocapture %v) local_unnamed_addr #0 {
; CHECK-LABEL: fwd_float32_t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    vldrw.u32 q0, [r0]
; CHECK-NEXT:    vstrw.32 q0, [r0, #16]
; CHECK-NEXT:    bx lr
entry:
  %d = getelementptr inbounds %struct.s_float32_t, %struct.s_float32_t* %v, i32 0, i32 1
  %0 = bitcast %struct.s_float32_t* %v to <4 x i32>*
  %1 = load <4 x i32>, <4 x i32>* %0, align 4
  %2 = bitcast [4 x float]* %d to <4 x i32>*
  store <4 x i32> %1, <4 x i32>* %2, align 4
  ret void
}

define hidden void @bwd_int8_t(%struct.s_int8_t* noalias %v) local_unnamed_addr #0 {
; CHECK-LABEL: bwd_int8_t:
; CHECK:       @ %bb.0: @ %for.end
; CHECK-NEXT:    vldrb.u8 q0, [r0]
; CHECK-NEXT:    vstrb.8 q0, [r0, #-16]
; CHECK-NEXT:    bx lr
for.end:
  %0 = bitcast %struct.s_int8_t* %v to <16 x i8>*
  %1 = load <16 x i8>, <16 x i8>* %0, align 1
  %arrayidx3 = getelementptr inbounds %struct.s_int8_t, %struct.s_int8_t* %v, i32 -1, i32 1, i32 0
  %2 = bitcast i8* %arrayidx3 to <16 x i8>*
  store <16 x i8> %1, <16 x i8>* %2, align 1
  ret void
}

define hidden void @bwd_int16_t(%struct.s_int16_t* noalias nocapture %v) local_unnamed_addr #0 {
; CHECK-LABEL: bwd_int16_t:
; CHECK:       @ %bb.0: @ %for.end
; CHECK-NEXT:    vldrh.u16 q0, [r0]
; CHECK-NEXT:    vstrh.16 q0, [r0, #-16]
; CHECK-NEXT:    bx lr
for.end:
  %0 = bitcast %struct.s_int16_t* %v to <8 x i16>*
  %1 = load <8 x i16>, <8 x i16>* %0, align 2
  %arrayidx3 = getelementptr inbounds %struct.s_int16_t, %struct.s_int16_t* %v, i32 -1, i32 1, i32 0
  %2 = bitcast i16* %arrayidx3 to <8 x i16>*
  store <8 x i16> %1, <8 x i16>* %2, align 2
  ret void
}

define hidden void @bwd_int32_t(%struct.s_int32_t* noalias nocapture %v) local_unnamed_addr #0 {
; CHECK-LABEL: bwd_int32_t:
; CHECK:       @ %bb.0: @ %for.end
; CHECK-NEXT:    vldrw.u32 q0, [r0]
; CHECK-NEXT:    vstrw.32 q0, [r0, #-16]
; CHECK-NEXT:    bx lr
for.end:
  %0 = bitcast %struct.s_int32_t* %v to <4 x i32>*
  %1 = load <4 x i32>, <4 x i32>* %0, align 4
  %arrayidx3 = getelementptr inbounds %struct.s_int32_t, %struct.s_int32_t* %v, i32 -1, i32 1, i32 0
  %2 = bitcast i32* %arrayidx3 to <4 x i32>*
  store <4 x i32> %1, <4 x i32>* %2, align 4
  ret void
}

define hidden void @bwd_float16_t(%struct.s_float16_t* noalias nocapture %v) local_unnamed_addr #0 {
; CHECK-LABEL: bwd_float16_t:
; CHECK:       @ %bb.0: @ %for.end
; CHECK-NEXT:    vldrh.u16 q0, [r0], #-16
; CHECK-NEXT:    vstrh.16 q0, [r0]
; CHECK-NEXT:    bx lr
for.end:
  %0 = bitcast %struct.s_float16_t* %v to <8 x half>*
  %1 = load <8 x half>, <8 x half>* %0, align 2
  %arrayidx3 = getelementptr inbounds %struct.s_float16_t, %struct.s_float16_t* %v, i32 -1, i32 1, i32 0
  %2 = bitcast half* %arrayidx3 to <8 x half>*
  store <8 x half> %1, <8 x half>* %2, align 2
  ret void
}

define hidden void @bwd_float32_t(%struct.s_float32_t* noalias nocapture %v) local_unnamed_addr #0 {
; CHECK-LABEL: bwd_float32_t:
; CHECK:       @ %bb.0: @ %for.end
; CHECK-NEXT:    vldrw.u32 q0, [r0]
; CHECK-NEXT:    vstrw.32 q0, [r0, #-16]
; CHECK-NEXT:    bx lr
for.end:
  %0 = bitcast %struct.s_float32_t* %v to <4 x i32>*
  %1 = load <4 x i32>, <4 x i32>* %0, align 4
  %d = getelementptr inbounds %struct.s_float32_t, %struct.s_float32_t* %v, i32 -1, i32 1
  %2 = bitcast [4 x float]* %d to <4 x i32>*
  store <4 x i32> %1, <4 x i32>* %2, align 4
  ret void
}
