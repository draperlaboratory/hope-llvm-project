// RUN: %clang_cc1 -fenable-matrix -triple x86_64-apple-darwin %s -emit-llvm -disable-llvm-passes -o - | FileCheck %s

typedef double dx5x5_t __attribute__((matrix_type(5, 5)));
typedef float fx2x3_t __attribute__((matrix_type(2, 3)));
typedef int ix9x3_t __attribute__((matrix_type(9, 3)));
typedef unsigned long long ullx4x2_t __attribute__((matrix_type(4, 2)));

// Floating point matrix/scalar additions.

void add_matrix_matrix_double(dx5x5_t a, dx5x5_t b, dx5x5_t c) {
  // CHECK-LABEL: define void @add_matrix_matrix_double(<25 x double> %a, <25 x double> %b, <25 x double> %c)
  // CHECK:       [[B:%.*]] = load <25 x double>, <25 x double>* {{.*}}, align 8
  // CHECK-NEXT:  [[C:%.*]] = load <25 x double>, <25 x double>* {{.*}}, align 8
  // CHECK-NEXT:  [[RES:%.*]] = fadd <25 x double> [[B]], [[C]]
  // CHECK-NEXT:  store <25 x double> [[RES]], <25 x double>* {{.*}}, align 8

  a = b + c;
}

void add_matrix_matrix_float(fx2x3_t a, fx2x3_t b, fx2x3_t c) {
  // CHECK-LABEL: define void @add_matrix_matrix_float(<6 x float> %a, <6 x float> %b, <6 x float> %c)
  // CHECK:       [[B:%.*]] = load <6 x float>, <6 x float>* {{.*}}, align 4
  // CHECK-NEXT:  [[C:%.*]] = load <6 x float>, <6 x float>* {{.*}}, align 4
  // CHECK-NEXT:  [[RES:%.*]] = fadd <6 x float> [[B]], [[C]]
  // CHECK-NEXT:  store <6 x float> [[RES]], <6 x float>* {{.*}}, align 4

  a = b + c;
}

void add_matrix_scalar_double_float(dx5x5_t a, float vf) {
  // CHECK-LABEL: define void @add_matrix_scalar_double_float(<25 x double> %a, float %vf)
  // CHECK:       [[MATRIX:%.*]] = load <25 x double>, <25 x double>* {{.*}}, align 8
  // CHECK-NEXT:  [[SCALAR:%.*]] = load float, float* %vf.addr, align 4
  // CHECK-NEXT:  [[SCALAR_EXT:%.*]] = fpext float [[SCALAR]] to double
  // CHECK-NEXT:  [[SCALAR_EMBED:%.*]] = insertelement <25 x double> undef, double [[SCALAR_EXT]], i32 0
  // CHECK-NEXT:  [[SCALAR_EMBED1:%.*]] = shufflevector <25 x double> [[SCALAR_EMBED]], <25 x double> undef, <25 x i32> zeroinitializer
  // CHECK-NEXT:  [[RES:%.*]] = fadd <25 x double> [[MATRIX]], [[SCALAR_EMBED1]]
  // CHECK-NEXT:  store <25 x double> [[RES]], <25 x double>* {{.*}}, align 8

  a = a + vf;
}

void add_matrix_scalar_double_double(dx5x5_t a, double vd) {
  // CHECK-LABEL: define void @add_matrix_scalar_double_double(<25 x double> %a, double %vd)
  // CHECK:       [[MATRIX:%.*]] = load <25 x double>, <25 x double>* {{.*}}, align 8
  // CHECK-NEXT:  [[SCALAR:%.*]] = load double, double* %vd.addr, align 8
  // CHECK-NEXT:  [[SCALAR_EMBED:%.*]] = insertelement <25 x double> undef, double [[SCALAR]], i32 0
  // CHECK-NEXT:  [[SCALAR_EMBED1:%.*]] = shufflevector <25 x double> [[SCALAR_EMBED]], <25 x double> undef, <25 x i32> zeroinitializer
  // CHECK-NEXT:  [[RES:%.*]] = fadd <25 x double> [[MATRIX]], [[SCALAR_EMBED1]]
  // CHECK-NEXT:  store <25 x double> [[RES]], <25 x double>* {{.*}}, align 8

  a = a + vd;
}

void add_matrix_scalar_float_float(fx2x3_t b, float vf) {
  // CHECK-LABEL: define void @add_matrix_scalar_float_float(<6 x float> %b, float %vf)
  // CHECK:       [[MATRIX:%.*]] = load <6 x float>, <6 x float>* {{.*}}, align 4
  // CHECK-NEXT:  [[SCALAR:%.*]] = load float, float* %vf.addr, align 4
  // CHECK-NEXT:  [[SCALAR_EMBED:%.*]] = insertelement <6 x float> undef, float [[SCALAR]], i32 0
  // CHECK-NEXT:  [[SCALAR_EMBED1:%.*]] = shufflevector <6 x float> [[SCALAR_EMBED]], <6 x float> undef, <6 x i32> zeroinitializer
  // CHECK-NEXT:  [[RES:%.*]] = fadd <6 x float> [[MATRIX]], [[SCALAR_EMBED1]]
  // CHECK-NEXT:  store <6 x float> [[RES]], <6 x float>* {{.*}}, align 4

  b = b + vf;
}

void add_matrix_scalar_float_double(fx2x3_t b, double vd) {
  // CHECK-LABEL: define void @add_matrix_scalar_float_double(<6 x float> %b, double %vd)
  // CHECK:       [[MATRIX:%.*]] = load <6 x float>, <6 x float>* {{.*}}, align 4
  // CHECK-NEXT:  [[SCALAR:%.*]] = load double, double* %vd.addr, align 8
  // CHECK-NEXT:  [[SCALAR_TRUNC:%.*]] = fptrunc double [[SCALAR]] to float
  // CHECK-NEXT:  [[SCALAR_EMBED:%.*]] = insertelement <6 x float> undef, float [[SCALAR_TRUNC]], i32 0
  // CHECK-NEXT:  [[SCALAR_EMBED1:%.*]] = shufflevector <6 x float> [[SCALAR_EMBED]], <6 x float> undef, <6 x i32> zeroinitializer
  // CHECK-NEXT:  [[RES:%.*]] = fadd <6 x float> [[MATRIX]], [[SCALAR_EMBED1]]
  // CHECK-NEXT:  store <6 x float> [[RES]], <6 x float>* {{.*}}, align 4

  b = b + vd;
}

// Integer matrix/scalar additions

void add_matrix_matrix_int(ix9x3_t a, ix9x3_t b, ix9x3_t c) {
  // CHECK-LABEL: define void @add_matrix_matrix_int(<27 x i32> %a, <27 x i32> %b, <27 x i32> %c)
  // CHECK:       [[B:%.*]] = load <27 x i32>, <27 x i32>* {{.*}}, align 4
  // CHECK-NEXT:  [[C:%.*]] = load <27 x i32>, <27 x i32>* {{.*}}, align 4
  // CHECK-NEXT:  [[RES:%.*]] = add <27 x i32> [[B]], [[C]]
  // CHECK-NEXT:  store <27 x i32> [[RES]], <27 x i32>* {{.*}}, align 4
  a = b + c;
}

void add_matrix_matrix_unsigned_long_long(ullx4x2_t a, ullx4x2_t b, ullx4x2_t c) {
  // CHECK-LABEL: define void @add_matrix_matrix_unsigned_long_long(<8 x i64> %a, <8 x i64> %b, <8 x i64> %c)
  // CHECK:       [[B:%.*]] = load <8 x i64>, <8 x i64>* {{.*}}, align 8
  // CHECK-NEXT:  [[C:%.*]] = load <8 x i64>, <8 x i64>* {{.*}}, align 8
  // CHECK-NEXT:  [[RES:%.*]] = add <8 x i64> [[B]], [[C]]
  // CHECK-NEXT:  store <8 x i64> [[RES]], <8 x i64>* {{.*}}, align 8

  a = b + c;
}

void add_matrix_scalar_int_short(ix9x3_t a, short vs) {
  // CHECK-LABEL: define void @add_matrix_scalar_int_short(<27 x i32> %a, i16 signext %vs)
  // CHECK:        [[MATRIX:%.*]] = load <27 x i32>, <27 x i32>* [[MAT_ADDR:%.*]], align 4
  // CHECK-NEXT:   [[SCALAR:%.*]] = load i16, i16* %vs.addr, align 2
  // CHECK-NEXT:   [[SCALAR_EXT:%.*]] = sext i16 [[SCALAR]] to i32
  // CHECK-NEXT:   [[SCALAR_EMBED:%.*]] = insertelement <27 x i32> undef, i32 [[SCALAR_EXT]], i32 0
  // CHECK-NEXT:   [[SCALAR_EMBED1:%.*]] = shufflevector <27 x i32> [[SCALAR_EMBED]], <27 x i32> undef, <27 x i32> zeroinitializer
  // CHECK-NEXT:   [[RES:%.*]] = add <27 x i32> [[MATRIX]], [[SCALAR_EMBED1]]
  // CHECK-NEXT:   store <27 x i32> [[RES]], <27 x i32>* [[MAT_ADDR]], align 4

  a = a + vs;
}

void add_matrix_scalar_int_long_int(ix9x3_t a, long int vli) {
  // CHECK-LABEL: define void @add_matrix_scalar_int_long_int(<27 x i32> %a, i64 %vli)
  // CHECK:        [[MATRIX:%.*]] = load <27 x i32>, <27 x i32>* [[MAT_ADDR:%.*]], align 4
  // CHECK-NEXT:   [[SCALAR:%.*]] = load i64, i64* %vli.addr, align 8
  // CHECK-NEXT:   [[SCALAR_TRUNC:%.*]] = trunc i64 [[SCALAR]] to i32
  // CHECK-NEXT:   [[SCALAR_EMBED:%.*]] = insertelement <27 x i32> undef, i32 [[SCALAR_TRUNC]], i32 0
  // CHECK-NEXT:   [[SCALAR_EMBED1:%.*]] = shufflevector <27 x i32> [[SCALAR_EMBED]], <27 x i32> undef, <27 x i32> zeroinitializer
  // CHECK-NEXT:   [[RES:%.*]] = add <27 x i32> [[MATRIX]], [[SCALAR_EMBED1]]
  // CHECK-NEXT:   store <27 x i32> [[RES]], <27 x i32>* [[MAT_ADDR]], align 4

  a = a + vli;
}

void add_matrix_scalar_int_unsigned_long_long(ix9x3_t a, unsigned long long int vulli) {
  // CHECK-LABEL: define void @add_matrix_scalar_int_unsigned_long_long(<27 x i32> %a, i64 %vulli)
  // CHECK:        [[MATRIX:%.*]] = load <27 x i32>, <27 x i32>* [[MAT_ADDR:%.*]], align 4
  // CHECK-NEXT:   [[SCALAR:%.*]] = load i64, i64* %vulli.addr, align 8
  // CHECK-NEXT:   [[SCALAR_TRUNC:%.*]] = trunc i64 [[SCALAR]] to i32
  // CHECK-NEXT:   [[SCALAR_EMBED:%.*]] = insertelement <27 x i32> undef, i32 [[SCALAR_TRUNC]], i32 0
  // CHECK-NEXT:   [[SCALAR_EMBED1:%.*]] = shufflevector <27 x i32> [[SCALAR_EMBED]], <27 x i32> undef, <27 x i32> zeroinitializer
  // CHECK-NEXT:   [[RES:%.*]] = add <27 x i32> [[MATRIX]], [[SCALAR_EMBED1]]
  // CHECK-NEXT:   store <27 x i32> [[RES]], <27 x i32>* [[MAT_ADDR]], align 4

  a = a + vulli;
}

void add_matrix_scalar_long_long_int_short(ullx4x2_t b, short vs) {
  // CHECK-LABEL: define void @add_matrix_scalar_long_long_int_short(<8 x i64> %b, i16 signext %vs)
  // CHECK:         [[SCALAR:%.*]] = load i16, i16* %vs.addr, align 2
  // CHECK-NEXT:    [[SCALAR_EXT:%.*]] = sext i16 [[SCALAR]] to i64
  // CHECK-NEXT:    [[MATRIX:%.*]] = load <8 x i64>, <8 x i64>* {{.*}}, align 8
  // CHECK-NEXT:    [[SCALAR_EMBED:%.*]] = insertelement <8 x i64> undef, i64 [[SCALAR_EXT]], i32 0
  // CHECK-NEXT:    [[SCALAR_EMBED1:%.*]] = shufflevector <8 x i64> [[SCALAR_EMBED]], <8 x i64> undef, <8 x i32> zeroinitializer
  // CHECK-NEXT:    [[RES:%.*]] = add <8 x i64> [[SCALAR_EMBED1]], [[MATRIX]]
  // CHECK-NEXT:    store <8 x i64> [[RES]], <8 x i64>* {{.*}}, align 8

  b = vs + b;
}

void add_matrix_scalar_long_long_int_int(ullx4x2_t b, long int vli) {
  // CHECK-LABEL: define void @add_matrix_scalar_long_long_int_int(<8 x i64> %b, i64 %vli)
  // CHECK:         [[SCALAR:%.*]] = load i64, i64* %vli.addr, align 8
  // CHECK-NEXT:    [[MATRIX:%.*]] = load <8 x i64>, <8 x i64>* {{.*}}, align 8
  // CHECK-NEXT:    [[SCALAR_EMBED:%.*]] = insertelement <8 x i64> undef, i64 [[SCALAR]], i32 0
  // CHECK-NEXT:    [[SCALAR_EMBED1:%.*]] = shufflevector <8 x i64> [[SCALAR_EMBED]], <8 x i64> undef, <8 x i32> zeroinitializer
  // CHECK-NEXT:    [[RES:%.*]] = add <8 x i64> [[SCALAR_EMBED1]], [[MATRIX]]
  // CHECK-NEXT:    store <8 x i64> [[RES]], <8 x i64>* {{.*}}, align 8

  b = vli + b;
}

void add_matrix_scalar_long_long_int_unsigned_long_long(ullx4x2_t b, unsigned long long int vulli) {
  // CHECK-LABEL: define void @add_matrix_scalar_long_long_int_unsigned_long_long
  // CHECK:        [[SCALAR:%.*]] = load i64, i64* %vulli.addr, align 8
  // CHECK-NEXT:   [[MATRIX:%.*]] = load <8 x i64>, <8 x i64>* %0, align 8
  // CHECK-NEXT:   [[SCALAR_EMBED:%.*]] = insertelement <8 x i64> undef, i64 [[SCALAR]], i32 0
  // CHECK-NEXT:   [[SCALAR_EMBED1:%.*]] = shufflevector <8 x i64> [[SCALAR_EMBED]], <8 x i64> undef, <8 x i32> zeroinitializer
  // CHECK-NEXT:   [[RES:%.*]] = add <8 x i64> [[SCALAR_EMBED1]], [[MATRIX]]
  // CHECK-NEXT:   store <8 x i64> [[RES]], <8 x i64>* {{.*}}, align 8
  b = vulli + b;
}

// Tests for the matrix type operators.

typedef double dx5x5_t __attribute__((matrix_type(5, 5)));
typedef float fx2x3_t __attribute__((matrix_type(2, 3)));

// Check that we can use matrix index expression on different floating point
// matrixes and indices.
void insert_double_matrix_const_idx_ll_u_double(dx5x5_t a, double d, fx2x3_t b, float e, int j, unsigned k) {
  // CHECK-LABEL: @insert_double_matrix_const_idx_ll_u_double(
  // CHECK:         [[D:%.*]] = load double, double* %d.addr, align 8
  // CHECK-NEXT:    [[MAT:%.*]] = load <25 x double>, <25 x double>* {{.*}}, align 8
  // CHECK-NEXT:    [[MATINS:%.*]] = insertelement <25 x double> [[MAT]], double [[D]], i64 5
  // CHECK-NEXT:    store <25 x double> [[MATINS]], <25 x double>* {{.*}}, align 8
  // CHECK-NEXT:    ret void

  a[0ll][1u] = d;
}

void insert_double_matrix_const_idx_i_u_double(dx5x5_t a, double d) {
  // CHECK-LABEL: @insert_double_matrix_const_idx_i_u_double(
  // CHECK:         [[D:%.*]] = load double, double* %d.addr, align 8
  // CHECK-NEXT:    [[MAT:%.*]] = load <25 x double>, <25 x double>* [[MAT_ADDR:%.*]], align 8
  // CHECK-NEXT:    [[MATINS:%.*]] = insertelement <25 x double> [[MAT]], double [[D]], i64 21
  // CHECK-NEXT:    store <25 x double> [[MATINS]], <25 x double>* [[MAT_ADDR]], align 8
  // CHECK-NEXT:    ret void

  a[1][4u] = d;
}

void insert_float_matrix_const_idx_ull_i_float(fx2x3_t b, float e) {
  // CHECK-LABEL: @insert_float_matrix_const_idx_ull_i_float(
  // CHECK:         [[E:%.*]] = load float, float* %e.addr, align 4
  // CHECK-NEXT:    [[MAT:%.*]] = load <6 x float>, <6 x float>* [[MAT_ADDR:%.*]], align 4
  // CHECK-NEXT:    [[MATINS:%.*]] = insertelement <6 x float> [[MAT]], float [[E]], i64 3
  // CHECK-NEXT:    store <6 x float> [[MATINS]], <6 x float>* [[MAT_ADDR]], align 4
  // CHECK-NEXT:    ret void

  b[1ull][1] = e;
}

void insert_float_matrix_idx_i_u_float(fx2x3_t b, float e, int j, unsigned k) {
  // CHECK-LABEL: @insert_float_matrix_idx_i_u_float(
  // CHECK:         [[E:%.*]] = load float, float* %e.addr, align 4
  // CHECK-NEXT:    [[J:%.*]] = load i32, i32* %j.addr, align 4
  // CHECK-NEXT:    [[J_EXT:%.*]] = sext i32 [[J]] to i64
  // CHECK-NEXT:    [[K:%.*]] = load i32, i32* %k.addr, align 4
  // CHECK-NEXT:    [[K_EXT:%.*]] = zext i32 [[K]] to i64
  // CHECK-NEXT:    [[IDX1:%.*]] = mul i64 [[K_EXT]], 2
  // CHECK-NEXT:    [[IDX2:%.*]] = add i64 [[IDX1]], [[J_EXT]]
  // CHECK-NEXT:    [[MAT:%.*]] = load <6 x float>, <6 x float>* [[MAT_ADDR:%.*]], align 4
  // CHECK-NEXT:    [[MATINS:%.*]] = insertelement <6 x float> [[MAT]], float [[E]], i64 [[IDX2]]
  // CHECK-NEXT:    store <6 x float> [[MATINS]], <6 x float>* [[MAT_ADDR]], align 4
  // CHECK-NEXT:    ret void

  b[j][k] = e;
}

void insert_float_matrix_idx_s_ull_float(fx2x3_t b, float e, short j, unsigned long long k) {
  // CHECK-LABEL: @insert_float_matrix_idx_s_ull_float(
  // CHECK:         [[E:%.*]] = load float, float* %e.addr, align 4
  // CHECK-NEXT:    [[J:%.*]] = load i16, i16* %j.addr, align 2
  // CHECK-NEXT:    [[J_EXT:%.*]] = sext i16 [[J]] to i64
  // CHECK-NEXT:    [[K:%.*]] = load i64, i64* %k.addr, align 8
  // CHECK-NEXT:    [[IDX1:%.*]] = mul i64 [[K]], 2
  // CHECK-NEXT:    [[IDX2:%.*]] = add i64 [[IDX1]], [[J_EXT]]
  // CHECK-NEXT:    [[MAT:%.*]] = load <6 x float>, <6 x float>* [[MAT_ADDR:%.*]], align 4
  // CHECK-NEXT:    [[MATINS:%.*]] = insertelement <6 x float> [[MAT]], float [[E]], i64 [[IDX2]]
  // CHECK-NEXT:    store <6 x float> [[MATINS]], <6 x float>* [[MAT_ADDR]], align 4
  // CHECK-NEXT:    ret void

  (b)[j][k] = e;
}

// Check that we can can use matrix index expressions on integer matrixes.
typedef int ix9x3_t __attribute__((matrix_type(9, 3)));
void insert_int_idx_expr(ix9x3_t a, int i) {
  // CHECK-LABEL: @insert_int_idx_expr(
  // CHECK:         [[I1:%.*]] = load i32, i32* %i.addr, align 4
  // CHECK-NEXT:    [[I2:%.*]] = load i32, i32* %i.addr, align 4
  // CHECK-NEXT:    [[I2_ADD:%.*]] = add nsw i32 4, [[I2]]
  // CHECK-NEXT:    [[ADD_EXT:%.*]] = sext i32 [[I2_ADD]] to i64
  // CHECK-NEXT:    [[IDX2:%.*]] = add i64 18, [[ADD_EXT]]
  // CHECK-NEXT:    [[MAT:%.*]] = load <27 x i32>, <27 x i32>* [[MAT_ADDR:%.*]], align 4
  // CHECK-NEXT:    [[MATINS:%.*]] = insertelement <27 x i32> [[MAT]], i32 [[I1]], i64 [[IDX2]]
  // CHECK-NEXT:    store <27 x i32> [[MATINS]], <27 x i32>* [[MAT_ADDR]], align 4
  // CHECK-NEXT:    ret void

  a[4 + i][1 + 1u] = i;
}

// Check that we can can use matrix index expressions on FP and integer
// matrixes.
typedef int ix9x3_t __attribute__((matrix_type(9, 3)));
void insert_float_into_int_matrix(ix9x3_t *a, int i) {
  // CHECK-LABEL: @insert_float_into_int_matrix(
  // CHECK:         [[I:%.*]] = load i32, i32* %i.addr, align 4
  // CHECK-NEXT:    [[MAT_ADDR1:%.*]] = load [27 x i32]*, [27 x i32]** %a.addr, align 8
  // CHECK-NEXT:    [[MAT_ADDR2:%.*]] = bitcast [27 x i32]* [[MAT_ADDR1]] to <27 x i32>*
  // CHECK-NEXT:    [[MAT:%.*]] = load <27 x i32>, <27 x i32>* [[MAT_ADDR2]], align 4
  // CHECK-NEXT:    [[MATINS:%.*]] = insertelement <27 x i32> [[MAT]], i32 [[I]], i64 13
  // CHECK-NEXT:    store <27 x i32> [[MATINS]], <27 x i32>* [[MAT_ADDR2]], align 4
  // CHECK-NEXT:    ret void

  (*a)[4][1] = i;
}

// Check that we can use overloaded matrix index expressions on matrixes with
// matching dimensions, but different element types.
typedef double dx3x3_t __attribute__((matrix_type(3, 3)));
typedef float fx3x3_t __attribute__((matrix_type(3, 3)));
void insert_matching_dimensions1(dx3x3_t a, double i) {
  // CHECK-LABEL: @insert_matching_dimensions1(
  // CHECK:         [[I:%.*]] = load double, double* %i.addr, align 8
  // CHECK-NEXT:    [[MAT:%.*]] = load <9 x double>, <9 x double>* [[MAT_ADDR:%.*]], align 8
  // CHECK-NEXT:    [[MATINS:%.*]] = insertelement <9 x double> [[MAT]], double [[I]], i64 5
  // CHECK-NEXT:    store <9 x double> [[MATINS]], <9 x double>* [[MAT_ADDR]], align 8
  // CHECK-NEXT:    ret void

  a[2u][1u] = i;
}

void insert_matching_dimensions(fx3x3_t b, float e) {
  // CHECK-LABEL: @insert_matching_dimensions(
  // CHECK:         [[E:%.*]] = load float, float* %e.addr, align 4
  // CHECK-NEXT:    [[MAT:%.*]] = load <9 x float>, <9 x float>* [[MAT_ADDR:%.*]], align 4
  // CHECK-NEXT:    [[MATINS:%.*]] = insertelement <9 x float> [[MAT]], float [[E]], i64 7
  // CHECK-NEXT:    store <9 x float> [[MATINS]], <9 x float>* [[MAT_ADDR]], align 4
  // CHECK-NEXT:    ret void

  b[1u][2u] = e;
}

double extract_double(dx5x5_t a) {
  // CHECK-LABEL: @extract_double(
  // CHECK:         [[MAT:%.*]] = load <25 x double>, <25 x double>* {{.*}}, align 8
  // CHECK-NEXT:    [[MATEXT:%.*]] = extractelement <25 x double> [[MAT]], i64 12
  // CHECK-NEXT:    ret double [[MATEXT]]

  return a[2][3 - 1u];
}

double extract_float(fx3x3_t b) {
  // CHECK-LABEL: @extract_float(
  // CHECK:         [[MAT:%.*]] = load <9 x float>, <9 x float>* {{.*}}, align 4
  // CHECK-NEXT:    [[MATEXT:%.*]] = extractelement <9 x float> [[MAT]], i64 5
  // CHECK-NEXT:    [[TO_DOUBLE:%.*]] = fpext float [[MATEXT]] to double
  // CHECK-NEXT:    ret double [[TO_DOUBLE]]

  return b[2][1];
}

int extract_int(ix9x3_t c, unsigned long j) {
  // CHECK-LABEL: @extract_int(
  // CHECK:         [[J1:%.*]] = load i64, i64* %j.addr, align 8
  // CHECK-NEXT:    [[J2:%.*]] = load i64, i64* %j.addr, align 8
  // CHECK-NEXT:    [[MAT:%.*]] = load <27 x i32>, <27 x i32>* {{.*}}, align 4
  // CHECK-NEXT:    [[IDX1:%.*]] = mul i64 [[J2]], 9
  // CHECK-NEXT:    [[IDX2:%.*]] = add i64 [[IDX1]], [[J1]]
  // CHECK-NEXT:    [[MATEXT:%.*]] = extractelement <27 x i32> [[MAT]], i64 [[IDX2]]
  // CHECK-NEXT:    ret i32 [[MATEXT]]

  return c[j][j];
}

typedef double dx3x2_t __attribute__((matrix_type(3, 2)));

double test_extract_matrix_pointer1(dx3x2_t **ptr, unsigned j) {
  // CHECK-LABEL: @test_extract_matrix_pointer1(
  // CHECK:         [[J:%.*]] = load i32, i32* %j.addr, align 4
  // CHECK-NEXT:    [[J_EXT:%.*]] = zext i32 [[J]] to i64
  // CHECK-NEXT:    [[PTR:%.*]] = load [6 x double]**, [6 x double]*** %ptr.addr, align 8
  // CHECK-NEXT:    [[PTR_IDX:%.*]] = getelementptr inbounds [6 x double]*, [6 x double]** [[PTR]], i64 1
  // CHECK-NEXT:    [[PTR2:%.*]] = load [6 x double]*, [6 x double]** [[PTR_IDX]], align 8
  // CHECK-NEXT:    [[PTR2_IDX:%.*]] = getelementptr inbounds [6 x double], [6 x double]* [[PTR2]], i64 2
  // CHECK-NEXT:    [[MAT_ADDR:%.*]] = bitcast [6 x double]* [[PTR2_IDX]] to <6 x double>*
  // CHECK-NEXT:    [[MAT:%.*]] = load <6 x double>, <6 x double>* [[MAT_ADDR]], align 8
  // CHECK-NEXT:    [[IDX:%.*]] = add i64 3, [[J_EXT]]
  // CHECK-NEXT:    [[MATEXT:%.*]] = extractelement <6 x double> [[MAT]], i64 [[IDX]]
  // CHECK-NEXT:    ret double [[MATEXT]]

  return ptr[1][2][j][1];
}

double test_extract_matrix_pointer2(dx3x2_t **ptr) {
  // CHECK-LABEL: @test_extract_matrix_pointer2(
  // CHECK-NEXT:  entry:
  // CHECK:         [[PTR:%.*]] = load [6 x double]**, [6 x double]*** %ptr.addr, align 8
  // CHECK-NEXT:    [[PTR_IDX:%.*]] = getelementptr inbounds [6 x double]*, [6 x double]** [[PTR]], i64 4
  // CHECK-NEXT:    [[PTR2:%.*]] = load [6 x double]*, [6 x double]** [[PTR_IDX]], align 8
  // CHECK-NEXT:    [[PTR2_IDX:%.*]] = getelementptr inbounds [6 x double], [6 x double]* [[PTR2]], i64 6
  // CHECK-NEXT:    [[MAT_ADDR:%.*]] = bitcast [6 x double]* [[PTR2_IDX]] to <6 x double>*
  // CHECK-NEXT:    [[MAT:%.*]] = load <6 x double>, <6 x double>* [[MAT_ADDR]], align 8
  // CHECK-NEXT:    [[MATEXT:%.*]] = extractelement <6 x double> [[MAT]], i64 5
  // CHECK-NEXT:    ret double [[MATEXT]]

  return (*(*(ptr + 4) + 6))[2][1 * 3 - 2];
}

void insert_extract(dx5x5_t a, fx3x3_t b, unsigned long j, short k) {
  // CHECK-LABEL: @insert_extract(
  // CHECK:         [[K:%.*]] = load i16, i16* %k.addr, align 2
  // CHECK-NEXT:    [[K_EXT:%.*]] = sext i16 [[K]] to i64
  // CHECK-NEXT:    [[MAT:%.*]] = load <9 x float>, <9 x float>* [[MAT_ADDR:%.*]], align 4
  // CHECK-NEXT:    [[IDX1:%.*]] = mul i64 [[K_EXT]], 3
  // CHECK-NEXT:    [[IDX2:%.*]] = add i64 [[IDX1]], 0
  // CHECK-NEXT:    [[MATEXT:%.*]] = extractelement <9 x float> [[MAT]], i64 [[IDX]]
  // CHECK-NEXT:    [[J:%.*]] = load i64, i64* %j.addr, align 8
  // CHECK-NEXT:    [[IDX3:%.*]] = mul i64 [[J]], 3
  // CHECK-NEXT:    [[IDX4:%.*]] = add i64 [[IDX3]], 2
  // CHECK-NEXT:    [[MAT2:%.*]] = load <9 x float>, <9 x float>* [[MAT_ADDR]], align 4
  // CHECK-NEXT:    [[MATINS:%.*]] = insertelement <9 x float> [[MAT2]], float [[MATEXT]], i64 [[IDX4]]
  // CHECK-NEXT:    store <9 x float> [[MATINS]], <9 x float>* [[MAT_ADDR]], align 4
  // CHECK-NEXT:    ret void

  b[2][j] = b[0][k];
}

void insert_compound_stmt(dx5x5_t a) {
  // CHECK-LABEL: define void @insert_compound_stmt(<25 x double> %a)
  // CHECK:        [[A:%.*]] = load <25 x double>, <25 x double>* [[A_PTR:%.*]], align 8
  // CHECK-NEXT:   [[EXT:%.*]] = extractelement <25 x double> [[A]], i64 17
  // CHECK-NEXT:   [[SUB:%.*]] = fsub double [[EXT]], 1.000000e+00
  // CHECK-NEXT:   [[A2:%.*]] = load <25 x double>, <25 x double>* [[A_PTR]], align 8
  // CHECK-NEXT:   [[INS:%.*]] = insertelement <25 x double> [[A2]], double [[SUB]], i64 17
  // CHECK-NEXT:   store <25 x double> [[INS]], <25 x double>* [[A_PTR]], align 8
  // CHECK-NEXT:   ret void

  a[2][3] -= 1.0;
}

struct Foo {
  fx2x3_t mat;
};

void insert_compound_stmt_field(struct Foo *a, float f, unsigned i, unsigned j) {
  // CHECK-LABEL: define void @insert_compound_stmt_field(%struct.Foo* %a, float %f, i32 %i, i32 %j)
  // CHECK:         [[I:%.*]] = load i32, i32* %i.addr, align 4
  // CHECK-NEXT:    [[I_EXT:%.*]] = zext i32 [[I]] to i64
  // CHECK-NEXT:    [[J:%.*]] = load i32, i32* %j.addr, align 4
  // CHECK-NEXT:    [[J_EXT:%.*]] = zext i32 [[J]] to i64
  // CHECK-NEXT:    [[IDX1:%.*]] = mul i64 [[J_EXT]], 2
  // CHECK-NEXT:    [[IDX2:%.*]] = add i64 [[IDX1]], [[I_EXT]]
  // CHECK-NEXT:    [[MAT_PTR:%.*]] = bitcast [6 x float]* %mat to <6 x float>*
  // CHECK-NEXT:    [[MAT:%.*]] = load <6 x float>, <6 x float>* [[MAT_PTR]], align 4
  // CHECK-NEXT:    [[EXT:%.*]] = extractelement <6 x float> [[MAT]], i64 [[IDX2]]
  // CHECK-NEXT:    [[SUM:%.*]] = fadd float [[EXT]], {{.*}}
  // CHECK-NEXT:    [[MAT2:%.*]] = load <6 x float>, <6 x float>* [[MAT_PTR]], align 4
  // CHECK-NEXT:    [[INS:%.*]] = insertelement <6 x float> [[MAT2]], float [[SUM]], i64 [[IDX2]]
  // CHECK-NEXT:    store <6 x float> [[INS]], <6 x float>* [[MAT_PTR]], align 4
  // CHECK-NEXT:    ret void

  a->mat[i][j] += f;
}

void matrix_as_idx(ix9x3_t a, int i, int j, dx5x5_t b) {
  // CHECK-LABEL: define void @matrix_as_idx(<27 x i32> %a, i32 %i, i32 %j, <25 x double> %b)
  // CHECK:       [[I1:%.*]] = load i32, i32* %i.addr, align 4
  // CHECK-NEXT:  [[I1_EXT:%.*]] = sext i32 [[I1]] to i64
  // CHECK-NEXT:  [[J1:%.*]] = load i32, i32* %j.addr, align 4
  // CHECK-NEXT:  [[J1_EXT:%.*]] = sext i32 [[J1]] to i64
  // CHECK-NEXT:  [[A:%.*]] = load <27 x i32>, <27 x i32>* %0, align 4
  // CHECK-NEXT:  [[IDX1_1:%.*]] = mul i64 [[J1_EXT]], 9
  // CHECK-NEXT:  [[IDX1_2:%.*]] = add i64 [[IDX1_1]], [[I1_EXT]]
  // CHECK-NEXT:  [[MI1:%.*]] = extractelement <27 x i32> [[A]], i64 [[IDX1_2]]
  // CHECK-NEXT:  [[MI1_EXT:%.*]] = sext i32 [[MI1]] to i64
  // CHECK-NEXT:  [[J2:%.*]] = load i32, i32* %j.addr, align 4
  // CHECK-NEXT:  [[J2_EXT:%.*]] = sext i32 [[J2]] to i64
  // CHECK-NEXT:  [[I2:%.*]] = load i32, i32* %i.addr, align 4
  // CHECK-NEXT:  [[I2_EXT:%.*]] = sext i32 [[I2]] to i64
  // CHECK-NEXT:  [[A2:%.*]] = load <27 x i32>, <27 x i32>* {{.*}}, align 4
  // CHECK-NEXT:  [[IDX2_1:%.*]] = mul i64 [[I2_EXT]], 9
  // CHECK-NEXT:  [[IDX2_2:%.*]] = add i64 [[IDX2_1]], [[J2_EXT]]
  // CHECK-NEXT:  [[MI2:%.*]] = extractelement <27 x i32> [[A2]], i64 [[IDX2_2]]
  // CHECK-NEXT:  [[MI3:%.*]] = add nsw i32 [[MI2]], 2
  // CHECK-NEXT:  [[MI3_EXT:%.*]] = sext i32 [[MI3]] to i64
  // CHECK-NEXT:  [[IDX3_1:%.*]] = mul i64 [[MI3_EXT]], 5
  // CHECK-NEXT:  [[IDX3_2:%.*]] = add i64 [[IDX3_1]], [[MI1_EXT]]
  // CHECK-NEXT:  [[B:%.*]] = load <25 x double>, <25 x double>* [[B_PTR:%.*]], align 8
  // CHECK-NEXT:  [[INS:%.*]] = insertelement <25 x double> [[B]], double 1.500000e+00, i64 [[IDX3_2]]
  // CHECK-NEXT:  store <25 x double> [[INS]], <25 x double>* [[B_PTR]], align 8
  b[a[i][j]][a[j][i] + 2] = 1.5;
}
