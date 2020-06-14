// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %clang_cc1 -emit-llvm %s -std=c++2a -triple x86_64-unknown-linux-gnu -o %t.ll
// RUN: FileCheck -check-prefix=EVAL -input-file=%t.ll %s
// RUN: FileCheck -check-prefix=EVAL-STATIC -input-file=%t.ll %s
// RUN: %clang_cc1 -emit-llvm %s -std=c++2a -triple x86_64-unknown-linux-gnu -o - | FileCheck -check-prefix=EVAL-FN %s
// RUN: %clang_cc1 -emit-llvm %s -Dconsteval="" -std=c++2a -triple x86_64-unknown-linux-gnu -o %t.ll
// RUN: FileCheck -check-prefix=EXPR -input-file=%t.ll %s

// there is two version of symbol checks to ensure
// that the symbol we are looking for are correct
// EVAL-NOT: @__cxx_global_var_init()
// EXPR: @__cxx_global_var_init()

// EVAL-NOT: @_Z4ret7v()
// EXPR: @_Z4ret7v()
consteval int ret7() {
  return 7;
}

// EVAL-FN-LABEL: @_Z9test_ret7v(
// EVAL-FN-NEXT:  entry:
// EVAL-FN-NEXT:    [[I:%.*]] = alloca i32, align 4
// EVAL-FN-NEXT:    store i32 7, i32* [[I]], align 4
// EVAL-FN-NEXT:    [[TMP0:%.*]] = load i32, i32* [[I]], align 4
// EVAL-FN-NEXT:    ret i32 [[TMP0]]
//
int test_ret7() {
  int i = ret7();
  return i;
}

int global_i = ret7();

constexpr int i_const = 5;

// EVAL-NOT: @_Z4retIv()
// EXPR: @_Z4retIv()
consteval const int &retI() {
  return i_const;
}

// EVAL-FN-LABEL: @_Z12test_retRefIv(
// EVAL-FN-NEXT:  entry:
// EVAL-FN-NEXT:    ret i32* @_ZL7i_const
//
const int &test_retRefI() {
  return retI();
}

// EVAL-FN-LABEL: @_Z9test_retIv(
// EVAL-FN-NEXT:  entry:
// EVAL-FN-NEXT:    [[TMP0:%.*]] = load i32, i32* @_ZL7i_const, align 4
// EVAL-FN-NEXT:    ret i32 [[TMP0]]
//
int test_retI() {
  return retI();
}

// EVAL-NOT: @_Z4retIv()
// EXPR: @_Z4retIv()
consteval const int *retIPtr() {
  return &i_const;
}

// EVAL-FN-LABEL: @_Z12test_retIPtrv(
// EVAL-FN-NEXT:  entry:
// EVAL-FN-NEXT:    [[TMP0:%.*]] = load i32, i32* @_ZL7i_const, align 4
// EVAL-FN-NEXT:    ret i32 [[TMP0]]
//
int test_retIPtr() {
  return *retIPtr();
}

// EVAL-FN-LABEL: @_Z13test_retPIPtrv(
// EVAL-FN-NEXT:  entry:
// EVAL-FN-NEXT:    ret i32* @_ZL7i_const
//
const int *test_retPIPtr() {
  return retIPtr();
}

// EVAL-NOT: @_Z4retIv()
// EXPR: @_Z4retIv()
consteval const int &&retIRRef() {
  return static_cast<const int &&>(i_const);
}

// EVAL-FN-LABEL: @_Z13test_retIRRefv(
// EVAL-FN-NEXT:  entry:
// EVAL-FN-NEXT:    ret i32* @_ZL7i_const
//
const int &&test_retIRRef() {
  return static_cast<const int &&>(retIRRef());
}

// EVAL-FN-LABEL: @_Z14test_retIRRefIv(
// EVAL-FN-NEXT:  entry:
// EVAL-FN-NEXT:    [[TMP0:%.*]] = load i32, i32* @_ZL7i_const, align 4
// EVAL-FN-NEXT:    ret i32 [[TMP0]]
//
int test_retIRRefI() {
  return retIRRef();
}

struct Agg {
  int a;
  long b;
};

// EVAL-NOT: @_Z6retAggv()
// EXPR: @_Z6retAggv()
consteval Agg retAgg() {
  return {13, 17};
}

// EVAL-FN-LABEL: @_Z11test_retAggv(
// EVAL-FN-NEXT:  entry:
// EVAL-FN-NEXT:    [[B:%.*]] = alloca i64, align 8
// EVAL-FN-NEXT:    [[REF_TMP:%.*]] = alloca [[STRUCT_AGG:%.*]], align 8
// EVAL-FN-NEXT:    [[TMP0:%.*]] = getelementptr inbounds [[STRUCT_AGG]], %struct.Agg* [[REF_TMP]], i32 0, i32 0
// EVAL-FN-NEXT:    store i32 13, i32* [[TMP0]], align 8
// EVAL-FN-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [[STRUCT_AGG]], %struct.Agg* [[REF_TMP]], i32 0, i32 1
// EVAL-FN-NEXT:    store i64 17, i64* [[TMP1]], align 8
// EVAL-FN-NEXT:    store i64 17, i64* [[B]], align 8
// EVAL-FN-NEXT:    [[TMP2:%.*]] = load i64, i64* [[B]], align 8
// EVAL-FN-NEXT:    ret i64 [[TMP2]]
//
long test_retAgg() {
  long b = retAgg().b;
  return b;
}

// EVAL-STATIC: @A = global %struct.Agg { i32 13, i64 17 }, align 8
Agg A = retAgg();

// EVAL-NOT: @_Z9retRefAggv()
// EXPR: @_Z9retRefAggv()
consteval const Agg &retRefAgg() {
  const Agg &tmp = A;
  return A;
}

// EVAL-FN-LABEL: @_Z14test_retRefAggv(
// EVAL-FN-NEXT:  entry:
// EVAL-FN-NEXT:    [[B:%.*]] = alloca i64, align 8
// EVAL-FN-NEXT:    [[REF_TMP:%.*]] = alloca [[STRUCT_AGG:%.*]], align 8
// EVAL-FN-NEXT:    [[TMP0:%.*]] = getelementptr inbounds [[STRUCT_AGG]], %struct.Agg* [[REF_TMP]], i32 0, i32 0
// EVAL-FN-NEXT:    store i32 13, i32* [[TMP0]], align 8
// EVAL-FN-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [[STRUCT_AGG]], %struct.Agg* [[REF_TMP]], i32 0, i32 1
// EVAL-FN-NEXT:    store i64 17, i64* [[TMP1]], align 8
// EVAL-FN-NEXT:    store i64 17, i64* [[B]], align 8
// EVAL-FN-NEXT:    [[TMP2:%.*]] = load i64, i64* [[B]], align 8
// EVAL-FN-NEXT:    ret i64 [[TMP2]]
//
long test_retRefAgg() {
  long b = retAgg().b;
  return b;
}

// EVAL-NOT: @_Z8is_constv()
// EXPR: @_Z8is_constv()
consteval Agg is_const() {
  return {5, 19 * __builtin_is_constant_evaluated()};
}

// EVAL-FN-LABEL: @_Z13test_is_constv(
// EVAL-FN-NEXT:  entry:
// EVAL-FN-NEXT:    [[B:%.*]] = alloca i64, align 8
// EVAL-FN-NEXT:    [[REF_TMP:%.*]] = alloca [[STRUCT_AGG:%.*]], align 8
// EVAL-FN-NEXT:    [[TMP0:%.*]] = getelementptr inbounds [[STRUCT_AGG]], %struct.Agg* [[REF_TMP]], i32 0, i32 0
// EVAL-FN-NEXT:    store i32 5, i32* [[TMP0]], align 8
// EVAL-FN-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [[STRUCT_AGG]], %struct.Agg* [[REF_TMP]], i32 0, i32 1
// EVAL-FN-NEXT:    store i64 19, i64* [[TMP1]], align 8
// EVAL-FN-NEXT:    store i64 19, i64* [[B]], align 8
// EVAL-FN-NEXT:    [[TMP2:%.*]] = load i64, i64* [[B]], align 8
// EVAL-FN-NEXT:    ret i64 [[TMP2]]
//
long test_is_const() {
  long b = is_const().b;
  return b;
}

// EVAL-NOT: @_ZN7AggCtorC
// EXPR: @_ZN7AggCtorC
struct AggCtor {
  consteval AggCtor(int a = 3, long b = 5) : a(a * a), b(a * b) {}
  int a;
  long b;
};

// EVAL-FN-LABEL: @_Z12test_AggCtorv(
// EVAL-FN-NEXT:  entry:
// EVAL-FN-NEXT:    [[I:%.*]] = alloca i32, align 4
// EVAL-FN-NEXT:    [[C:%.*]] = alloca [[STRUCT_AGGCTOR:%.*]], align 8
// EVAL-FN-NEXT:    store i32 2, i32* [[I]], align 4
// EVAL-FN-NEXT:    [[TMP0:%.*]] = getelementptr inbounds [[STRUCT_AGGCTOR]], %struct.AggCtor* [[C]], i32 0, i32 0
// EVAL-FN-NEXT:    store i32 4, i32* [[TMP0]], align 8
// EVAL-FN-NEXT:    [[TMP1:%.*]] = getelementptr inbounds [[STRUCT_AGGCTOR]], %struct.AggCtor* [[C]], i32 0, i32 1
// EVAL-FN-NEXT:    store i64 10, i64* [[TMP1]], align 8
// EVAL-FN-NEXT:    [[A:%.*]] = getelementptr inbounds [[STRUCT_AGGCTOR]], %struct.AggCtor* [[C]], i32 0, i32 0
// EVAL-FN-NEXT:    [[TMP2:%.*]] = load i32, i32* [[A]], align 8
// EVAL-FN-NEXT:    [[CONV:%.*]] = sext i32 [[TMP2]] to i64
// EVAL-FN-NEXT:    [[B:%.*]] = getelementptr inbounds [[STRUCT_AGGCTOR]], %struct.AggCtor* [[C]], i32 0, i32 1
// EVAL-FN-NEXT:    [[TMP3:%.*]] = load i64, i64* [[B]], align 8
// EVAL-FN-NEXT:    [[ADD:%.*]] = add nsw i64 [[CONV]], [[TMP3]]
// EVAL-FN-NEXT:    ret i64 [[ADD]]
//
long test_AggCtor() {
  const int i = 2;
  AggCtor C(i);
  return C.a + C.b;
}
