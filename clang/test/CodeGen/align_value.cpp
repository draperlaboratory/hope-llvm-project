// NOTE: Assertions have been autogenerated by utils/update_cc_test_checks.py
// RUN: %clang_cc1 -triple x86_64-unknown-unknown -emit-llvm -o - %s | FileCheck %s

typedef double * __attribute__((align_value(64))) aligned_double;

// CHECK-LABEL: define {{[^@]+}}@_Z3fooPdS_Rd
// CHECK-SAME: (double* align 64 [[X:%.*]], double* align 32 [[Y:%.*]], double* nonnull align 128 dereferenceable(8) [[Z:%.*]]) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[X_ADDR:%.*]] = alloca double*, align 8
// CHECK-NEXT:    [[Y_ADDR:%.*]] = alloca double*, align 8
// CHECK-NEXT:    [[Z_ADDR:%.*]] = alloca double*, align 8
// CHECK-NEXT:    store double* [[X]], double** [[X_ADDR]], align 8
// CHECK-NEXT:    store double* [[Y]], double** [[Y_ADDR]], align 8
// CHECK-NEXT:    store double* [[Z]], double** [[Z_ADDR]], align 8
// CHECK-NEXT:    ret void
//
void foo(aligned_double x, double * y __attribute__((align_value(32))),
         double & z __attribute__((align_value(128)))) { };

struct ad_struct {
  aligned_double a;
};

// CHECK-LABEL: define {{[^@]+}}@_Z3fooR9ad_struct
// CHECK-SAME: (%struct.ad_struct* nonnull align 8 dereferenceable(8) [[X:%.*]]) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[X_ADDR:%.*]] = alloca %struct.ad_struct*, align 8
// CHECK-NEXT:    store %struct.ad_struct* [[X]], %struct.ad_struct** [[X_ADDR]], align 8
// CHECK-NEXT:    [[TMP0:%.*]] = load %struct.ad_struct*, %struct.ad_struct** [[X_ADDR]], align 8
// CHECK-NEXT:    [[A:%.*]] = getelementptr inbounds [[STRUCT_AD_STRUCT:%.*]], %struct.ad_struct* [[TMP0]], i32 0, i32 0
// CHECK-NEXT:    [[TMP1:%.*]] = load double*, double** [[A]], align 8
// CHECK-NEXT:    [[PTRINT:%.*]] = ptrtoint double* [[TMP1]] to i64
// CHECK-NEXT:    [[MASKEDPTR:%.*]] = and i64 [[PTRINT]], 63
// CHECK-NEXT:    [[MASKCOND:%.*]] = icmp eq i64 [[MASKEDPTR]], 0
// CHECK-NEXT:    call void @llvm.assume(i1 [[MASKCOND]])
// CHECK-NEXT:    ret double* [[TMP1]]
//
double *foo(ad_struct& x) {

  return x.a;
}

// CHECK-LABEL: define {{[^@]+}}@_Z3gooP9ad_struct
// CHECK-SAME: (%struct.ad_struct* [[X:%.*]]) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[X_ADDR:%.*]] = alloca %struct.ad_struct*, align 8
// CHECK-NEXT:    store %struct.ad_struct* [[X]], %struct.ad_struct** [[X_ADDR]], align 8
// CHECK-NEXT:    [[TMP0:%.*]] = load %struct.ad_struct*, %struct.ad_struct** [[X_ADDR]], align 8
// CHECK-NEXT:    [[A:%.*]] = getelementptr inbounds [[STRUCT_AD_STRUCT:%.*]], %struct.ad_struct* [[TMP0]], i32 0, i32 0
// CHECK-NEXT:    [[TMP1:%.*]] = load double*, double** [[A]], align 8
// CHECK-NEXT:    [[PTRINT:%.*]] = ptrtoint double* [[TMP1]] to i64
// CHECK-NEXT:    [[MASKEDPTR:%.*]] = and i64 [[PTRINT]], 63
// CHECK-NEXT:    [[MASKCOND:%.*]] = icmp eq i64 [[MASKEDPTR]], 0
// CHECK-NEXT:    call void @llvm.assume(i1 [[MASKCOND]])
// CHECK-NEXT:    ret double* [[TMP1]]
//
double *goo(ad_struct *x) {

  return x->a;
}

// CHECK-LABEL: define {{[^@]+}}@_Z3barPPd
// CHECK-SAME: (double** [[X:%.*]]) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[X_ADDR:%.*]] = alloca double**, align 8
// CHECK-NEXT:    store double** [[X]], double*** [[X_ADDR]], align 8
// CHECK-NEXT:    [[TMP0:%.*]] = load double**, double*** [[X_ADDR]], align 8
// CHECK-NEXT:    [[TMP1:%.*]] = load double*, double** [[TMP0]], align 8
// CHECK-NEXT:    [[PTRINT:%.*]] = ptrtoint double* [[TMP1]] to i64
// CHECK-NEXT:    [[MASKEDPTR:%.*]] = and i64 [[PTRINT]], 63
// CHECK-NEXT:    [[MASKCOND:%.*]] = icmp eq i64 [[MASKEDPTR]], 0
// CHECK-NEXT:    call void @llvm.assume(i1 [[MASKCOND]])
// CHECK-NEXT:    ret double* [[TMP1]]
//
double *bar(aligned_double *x) {

  return *x;
}

// CHECK-LABEL: define {{[^@]+}}@_Z3carRPd
// CHECK-SAME: (double** nonnull align 8 dereferenceable(8) [[X:%.*]]) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[X_ADDR:%.*]] = alloca double**, align 8
// CHECK-NEXT:    store double** [[X]], double*** [[X_ADDR]], align 8
// CHECK-NEXT:    [[TMP0:%.*]] = load double**, double*** [[X_ADDR]], align 8
// CHECK-NEXT:    [[TMP1:%.*]] = load double*, double** [[TMP0]], align 8
// CHECK-NEXT:    [[PTRINT:%.*]] = ptrtoint double* [[TMP1]] to i64
// CHECK-NEXT:    [[MASKEDPTR:%.*]] = and i64 [[PTRINT]], 63
// CHECK-NEXT:    [[MASKCOND:%.*]] = icmp eq i64 [[MASKEDPTR]], 0
// CHECK-NEXT:    call void @llvm.assume(i1 [[MASKCOND]])
// CHECK-NEXT:    ret double* [[TMP1]]
//
double *car(aligned_double &x) {

  return x;
}

// CHECK-LABEL: define {{[^@]+}}@_Z3darPPd
// CHECK-SAME: (double** [[X:%.*]]) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[X_ADDR:%.*]] = alloca double**, align 8
// CHECK-NEXT:    store double** [[X]], double*** [[X_ADDR]], align 8
// CHECK-NEXT:    [[TMP0:%.*]] = load double**, double*** [[X_ADDR]], align 8
// CHECK-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds double*, double** [[TMP0]], i64 5
// CHECK-NEXT:    [[TMP1:%.*]] = load double*, double** [[ARRAYIDX]], align 8
// CHECK-NEXT:    [[PTRINT:%.*]] = ptrtoint double* [[TMP1]] to i64
// CHECK-NEXT:    [[MASKEDPTR:%.*]] = and i64 [[PTRINT]], 63
// CHECK-NEXT:    [[MASKCOND:%.*]] = icmp eq i64 [[MASKEDPTR]], 0
// CHECK-NEXT:    call void @llvm.assume(i1 [[MASKCOND]])
// CHECK-NEXT:    ret double* [[TMP1]]
//
double *dar(aligned_double *x) {

  return x[5];
}

aligned_double eep();
// CHECK-LABEL: define {{[^@]+}}@_Z3retv() #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[CALL:%.*]] = call double* @_Z3eepv()
// CHECK-NEXT:    [[PTRINT:%.*]] = ptrtoint double* [[CALL]] to i64
// CHECK-NEXT:    [[MASKEDPTR:%.*]] = and i64 [[PTRINT]], 63
// CHECK-NEXT:    [[MASKCOND:%.*]] = icmp eq i64 [[MASKEDPTR]], 0
// CHECK-NEXT:    call void @llvm.assume(i1 [[MASKCOND]])
// CHECK-NEXT:    ret double* [[CALL]]
//
double *ret() {

  return eep();
}

// CHECK-LABEL: define {{[^@]+}}@_Z3no1PPd
// CHECK-SAME: (double** [[X:%.*]]) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[X_ADDR:%.*]] = alloca double**, align 8
// CHECK-NEXT:    store double** [[X]], double*** [[X_ADDR]], align 8
// CHECK-NEXT:    [[TMP0:%.*]] = load double**, double*** [[X_ADDR]], align 8
// CHECK-NEXT:    ret double** [[TMP0]]
//
double **no1(aligned_double *x) {
  return x;
}

// CHECK-LABEL: define {{[^@]+}}@_Z3no2RPd
// CHECK-SAME: (double** nonnull align 8 dereferenceable(8) [[X:%.*]]) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[X_ADDR:%.*]] = alloca double**, align 8
// CHECK-NEXT:    store double** [[X]], double*** [[X_ADDR]], align 8
// CHECK-NEXT:    [[TMP0:%.*]] = load double**, double*** [[X_ADDR]], align 8
// CHECK-NEXT:    ret double** [[TMP0]]
//
double *&no2(aligned_double &x) {
  return x;
}

// CHECK-LABEL: define {{[^@]+}}@_Z3no3RPd
// CHECK-SAME: (double** nonnull align 8 dereferenceable(8) [[X:%.*]]) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[X_ADDR:%.*]] = alloca double**, align 8
// CHECK-NEXT:    store double** [[X]], double*** [[X_ADDR]], align 8
// CHECK-NEXT:    [[TMP0:%.*]] = load double**, double*** [[X_ADDR]], align 8
// CHECK-NEXT:    ret double** [[TMP0]]
//
double **no3(aligned_double &x) {
  return &x;
}

// CHECK-LABEL: define {{[^@]+}}@_Z3no3Pd
// CHECK-SAME: (double* align 64 [[X:%.*]]) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[X_ADDR:%.*]] = alloca double*, align 8
// CHECK-NEXT:    store double* [[X]], double** [[X_ADDR]], align 8
// CHECK-NEXT:    [[TMP0:%.*]] = load double*, double** [[X_ADDR]], align 8
// CHECK-NEXT:    [[TMP1:%.*]] = load double, double* [[TMP0]], align 8
// CHECK-NEXT:    ret double [[TMP1]]
//
double no3(aligned_double x) {
  return *x;
}

// CHECK-LABEL: define {{[^@]+}}@_Z3no4Pd
// CHECK-SAME: (double* align 64 [[X:%.*]]) #0
// CHECK-NEXT:  entry:
// CHECK-NEXT:    [[X_ADDR:%.*]] = alloca double*, align 8
// CHECK-NEXT:    store double* [[X]], double** [[X_ADDR]], align 8
// CHECK-NEXT:    [[TMP0:%.*]] = load double*, double** [[X_ADDR]], align 8
// CHECK-NEXT:    ret double* [[TMP0]]
//
double *no4(aligned_double x) {
  return x;
}

