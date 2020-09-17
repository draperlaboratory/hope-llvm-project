; RUN: opt -disable-output -S -passes=print-ir-similarity < %s 2>&1 | FileCheck --allow-empty %s

; This is a simple test to make sure the IRSimilarityPrinterPass returns
; nothing when there is nothing to analyze.

; CHECK-NOT: Found in

define linkonce_odr void @fish() {
entry:
  ret void
}
