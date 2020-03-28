/*===---- openmp_wrapper/math.h -------- OpenMP math.h intercept ------ c++ -===
 *
 * Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
 * See https://llvm.org/LICENSE.txt for license information.
 * SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
 *
 *===-----------------------------------------------------------------------===
 */

#ifndef __CLANG_OPENMP_MATH_H__
#define __CLANG_OPENMP_MATH_H__

#ifndef _OPENMP
#error "This file is for OpenMP compilation only."
#endif

#include_next <math.h>

// We need limits.h for __clang_cuda_math.h below and because it should not hurt
// we include it eagerly here.
#include <limits.h>

// We need stdlib.h because (for now) __clang_cuda_math.h below declares `abs`
// which should live in stdlib.h.
#include <stdlib.h>

#pragma omp begin declare variant match(                                       \
    device = {arch(nvptx, nvptx64)}, implementation = {extension(match_any)})

#define __CUDA__
#include <__clang_cuda_math.h>
#undef __CUDA__

#pragma omp end declare variant

#endif
