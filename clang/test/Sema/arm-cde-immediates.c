// RUN: %clang_cc1 -triple thumbv8.1m.main-arm-none-eabi -fallow-half-arguments-and-returns -target-feature +mve.fp -target-feature +cdecp0 -verify -fsyntax-only %s

#include <arm_cde.h>
#include <arm_acle.h>

void test_coproc_gcp_instr(int a) {
  __builtin_arm_cdp(0, 2, 3, 4, 5, 6);   // expected-error {{coprocessor 0 must be configured as GCP}}
  __builtin_arm_cdp2(0, 2, 3, 4, 5, 6);  // expected-error {{coprocessor 0 must be configured as GCP}}
  __builtin_arm_mcr(0, 0, a, 13, 0, 3);  // expected-error {{coprocessor 0 must be configured as GCP}}
  __builtin_arm_mcr2(0, 0, a, 13, 0, 3); // expected-error {{coprocessor 0 must be configured as GCP}}
  __builtin_arm_mrc(0, 0, 13, 0, 3);     // expected-error {{coprocessor 0 must be configured as GCP}}
  __builtin_arm_mrc2(0, 0, 13, 0, 3);    // expected-error {{coprocessor 0 must be configured as GCP}}
  __builtin_arm_mcrr(0, 0, a, 0);        // expected-error {{coprocessor 0 must be configured as GCP}}
  __builtin_arm_mcrr2(0, 0, a, 0);       // expected-error {{coprocessor 0 must be configured as GCP}}
  __builtin_arm_mrrc(0, 0, 0);           // expected-error {{coprocessor 0 must be configured as GCP}}
  __builtin_arm_mrrc2(0, 0, 0);          // expected-error {{coprocessor 0 must be configured as GCP}}
  __builtin_arm_ldc(0, 2, &a);           // expected-error {{coprocessor 0 must be configured as GCP}}
  __builtin_arm_ldcl(0, 2, &a);          // expected-error {{coprocessor 0 must be configured as GCP}}
  __builtin_arm_ldc2(0, 2, &a);          // expected-error {{coprocessor 0 must be configured as GCP}}
  __builtin_arm_ldc2l(0, 2, &a);         // expected-error {{coprocessor 0 must be configured as GCP}}
  __builtin_arm_stc(0, 2, &a);           // expected-error {{coprocessor 0 must be configured as GCP}}
  __builtin_arm_stcl(0, 2, &a);          // expected-error {{coprocessor 0 must be configured as GCP}}
  __builtin_arm_stc2(0, 2, &a);          // expected-error {{coprocessor 0 must be configured as GCP}}
  __builtin_arm_stc2l(0, 2, &a);         // expected-error {{coprocessor 0 must be configured as GCP}}
}

void test_coproc(uint32_t a) {
  (void)__arm_cx1(0, 0);
  __arm_cx1(a, 0);  // expected-error {{argument to '__arm_cx1' must be a constant integer}}
  __arm_cx1(-1, 0); // expected-error {{argument value -1 is outside the valid range [0, 7]}}
  __arm_cx1(8, 0);  // expected-error {{argument value 8 is outside the valid range [0, 7]}}
  __arm_cx1(1, 0);  // expected-error {{coprocessor 1 must be configured as CDE}}
}

void test_cx(uint32_t a, uint64_t da, uint32_t n, uint32_t m) {
  (void)__arm_cx1(0, 0);
  __arm_cx1(0, a);          // expected-error {{argument to '__arm_cx1' must be a constant integer}}
  __arm_cx1(0, 8192);       // expected-error {{argument value 8192 is outside the valid range [0, 8191]}}
  __arm_cx1a(0, a, a);      // expected-error {{argument to '__arm_cx1a' must be a constant integer}}
  __arm_cx1a(0, a, 8192);   // expected-error {{argument value 8192 is outside the valid range [0, 8191]}}
  __arm_cx1d(0, a);         // expected-error {{argument to '__arm_cx1d' must be a constant integer}}
  __arm_cx1d(0, 8192);      // expected-error {{argument value 8192 is outside the valid range [0, 8191]}}
  __arm_cx1da(0, da, a);    // expected-error {{argument to '__arm_cx1da' must be a constant integer}}
  __arm_cx1da(0, da, 8192); // expected-error {{argument value 8192 is outside the valid range [0, 8191]}}

  (void)__arm_cx2(0, n, 0);
  __arm_cx2(0, n, a);         // expected-error {{argument to '__arm_cx2' must be a constant integer}}
  __arm_cx2(0, n, 512);       // expected-error {{argument value 512 is outside the valid range [0, 511]}}
  __arm_cx2a(0, a, n, a);     // expected-error {{argument to '__arm_cx2a' must be a constant integer}}
  __arm_cx2a(0, a, n, 512);   // expected-error {{argument value 512 is outside the valid range [0, 511]}}
  __arm_cx2d(0, n, a);        // expected-error {{argument to '__arm_cx2d' must be a constant integer}}
  __arm_cx2d(0, n, 512);      // expected-error {{argument value 512 is outside the valid range [0, 511]}}
  __arm_cx2da(0, da, n, a);   // expected-error {{argument to '__arm_cx2da' must be a constant integer}}
  __arm_cx2da(0, da, n, 512); // expected-error {{argument value 512 is outside the valid range [0, 511]}}

  (void)__arm_cx3(0, n, m, 0);
  __arm_cx3(0, n, m, a);        // expected-error {{argument to '__arm_cx3' must be a constant integer}}
  __arm_cx3(0, n, m, 64);       // expected-error {{argument value 64 is outside the valid range [0, 63]}}
  __arm_cx3a(0, a, n, m, a);    // expected-error {{argument to '__arm_cx3a' must be a constant integer}}
  __arm_cx3a(0, a, n, m, 64);   // expected-error {{argument value 64 is outside the valid range [0, 63]}}
  __arm_cx3d(0, n, m, a);       // expected-error {{argument to '__arm_cx3d' must be a constant integer}}
  __arm_cx3d(0, n, m, 64);      // expected-error {{argument value 64 is outside the valid range [0, 63]}}
  __arm_cx3da(0, da, n, m, a);  // expected-error {{argument to '__arm_cx3da' must be a constant integer}}
  __arm_cx3da(0, da, n, m, 64); // expected-error {{argument value 64 is outside the valid range [0, 63]}}
}
