; RUN: opt -analyze -enable-new-pm=0 -scalar-evolution < %s | FileCheck %s
; RUN: opt -disable-output "-passes=print<scalar-evolution>" < %s 2>&1 | FileCheck %s

target triple = "x86_64-unknown-linux-gnu"

; CHECK-LABEL: Printing analysis 'Scalar Evolution Analysis' for function 'f0':
; CHECK-NEXT: Classifying expressions for: @f0
; CHECK-NEXT:   %v0 = phi i16 [ 2, %b0 ], [ %v2, %b1 ]
; CHECK-NEXT:   -->  {2,+,1}<nuw><nsw><%b1> U: [2,4) S: [2,4)         Exits: 3                LoopDispositions: { %b1: Computable }
; CHECK-NEXT:   %v1 = phi i16 [ 1, %b0 ], [ %v3, %b1 ]
; CHECK-NEXT:   -->  {1,+,2,+,1}<%b1> U: full-set S: full-set         Exits: 3                LoopDispositions: { %b1: Computable }
; CHECK-NEXT:   %v2 = add nsw i16 %v0, 1
; CHECK-NEXT:   -->  {3,+,1}<nuw><nsw><%b1> U: [3,5) S: [3,5)         Exits: 4                LoopDispositions: { %b1: Computable }
; CHECK-NEXT:   %v3 = add nsw i16 %v1, %v0
; CHECK-NEXT:   -->  {3,+,3,+,1}<%b1> U: full-set S: full-set         Exits: 6                LoopDispositions: { %b1: Computable }
; CHECK-NEXT:   %v4 = and i16 %v3, 1
; CHECK-NEXT:   -->  (zext i1 {true,+,true,+,true}<%b1> to i16) U: [0,2) S: [0,2)             Exits: 0                LoopDispositions: { %b1: Computable }
; CHECK-NEXT: Determining loop execution counts for: @f0
; CHECK-NEXT: Loop %b1: backedge-taken count is 1
; CHECK-NEXT: Loop %b1: max backedge-taken count is 1
; CHECK-NEXT: Loop %b1: Predicated backedge-taken count is 1
; CHECK-NEXT:  Predicates:
; CHECK-EMPTY:
; CHECK-NEXT: Loop %b1: Trip multiple is 2
define void @f0() {
b0:
  br label %b1

b1:                                               ; preds = %b1, %b0
  %v0 = phi i16 [ 2, %b0 ], [ %v2, %b1 ]
  %v1 = phi i16 [ 1, %b0 ], [ %v3, %b1 ]
  %v2 = add nsw i16 %v0, 1
  %v3 = add nsw i16 %v1, %v0
  %v4 = and i16 %v3, 1
  %v5 = icmp ne i16 %v4, 0
  br i1 %v5, label %b1, label %b2

b2:                                               ; preds = %b1
  ret void
}

@g0 = common dso_local global i16 0, align 2
@g1 = common dso_local global i32 0, align 4
@g2 = common dso_local global i32* null, align 8

; CHECK-LABEL: Printing analysis 'Scalar Evolution Analysis' for function 'f1':
; CHECK-NEXT: Classifying expressions for: @f1
; CHECK-NEXT:   %v0 = phi i16 [ 0, %b0 ], [ %v3, %b1 ]
; CHECK-NEXT:   -->  {0,+,3,+,1}<%b1> U: full-set S: full-set         Exits: 7                LoopDispositions: { %b1: Computable }
; CHECK-NEXT:   %v1 = phi i32 [ 3, %b0 ], [ %v6, %b1 ]
; CHECK-NEXT:   -->  {3,+,1}<nuw><nsw><%b1> U: [3,6) S: [3,6)         Exits: 5                LoopDispositions: { %b1: Computable }
; CHECK-NEXT:   %v2 = trunc i32 %v1 to i16
; CHECK-NEXT:   -->  {3,+,1}<%b1> U: [3,6) S: [3,6)           Exits: 5                LoopDispositions: { %b1: Computable }
; CHECK-NEXT:   %v3 = add i16 %v0, %v2
; CHECK-NEXT:   -->  {3,+,4,+,1}<%b1> U: full-set S: full-set         Exits: 12               LoopDispositions: { %b1: Computable }
; CHECK-NEXT:   %v4 = and i16 %v3, 1
; CHECK-NEXT:   -->  (zext i1 {true,+,false,+,true}<%b1> to i16) U: [0,2) S: [0,2)            Exits: 0                LoopDispositions: { %b1: Computable }
; CHECK-NEXT:   %v6 = add nuw nsw i32 %v1, 1
; CHECK-NEXT:   -->  {4,+,1}<nuw><nsw><%b1> U: [4,7) S: [4,7)         Exits: 6                LoopDispositions: { %b1: Computable }
; CHECK-NEXT:   %v7 = phi i32 [ %v1, %b1 ]
; CHECK-NEXT:   -->  {3,+,1}<nuw><nsw><%b1> U: [3,6) S: [3,6)  -->  5 U: [5,6) S: [5,6)
; CHECK-NEXT:   %v8 = phi i16 [ %v3, %b1 ]
; CHECK-NEXT:   -->  {3,+,4,+,1}<%b1> U: full-set S: full-set  -->  12 U: [12,13) S: [12,13)
; CHECK-NEXT: Determining loop execution counts for: @f1
; CHECK-NEXT: Loop %b3: <multiple exits> Unpredictable backedge-taken count.
; CHECK-NEXT: Loop %b3: Unpredictable max backedge-taken count.
; CHECK-NEXT: Loop %b3: Unpredictable predicated backedge-taken count.
; CHECK-NEXT: Loop %b1: backedge-taken count is 2
; CHECK-NEXT: Loop %b1: max backedge-taken count is 2
; CHECK-NEXT: Loop %b1: Predicated backedge-taken count is 2
; CHECK-NEXT:  Predicates:
; CHECK-EMPTY:
; CHECK-NEXT: Loop %b1: Trip multiple is 3
define void @f1() #0 {
b0:
  store i16 0, i16* @g0, align 2
  store i32* @g1, i32** @g2, align 8
  br label %b1

b1:                                               ; preds = %b1, %b0
  %v0 = phi i16 [ 0, %b0 ], [ %v3, %b1 ]
  %v1 = phi i32 [ 3, %b0 ], [ %v6, %b1 ]
  %v2 = trunc i32 %v1 to i16
  %v3 = add i16 %v0, %v2
  %v4 = and i16 %v3, 1
  %v5 = icmp eq i16 %v4, 0
  %v6 = add nuw nsw i32 %v1, 1
  br i1 %v5, label %b2, label %b1

b2:                                               ; preds = %b1
  %v7 = phi i32 [ %v1, %b1 ]
  %v8 = phi i16 [ %v3, %b1 ]
  store i32 %v7, i32* @g1, align 4
  store i16 %v8, i16* @g0, align 2
  br label %b3

b3:                                               ; preds = %b3, %b2
  br label %b3
}

attributes #0 = { nounwind uwtable "target-cpu"="x86-64" }
