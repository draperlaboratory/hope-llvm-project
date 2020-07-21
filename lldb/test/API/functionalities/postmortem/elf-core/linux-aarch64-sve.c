// compile with -march=armv8-a+sve on compatible aarch64 compiler
// linux-aarch64-sve.core was generated by: aarch64-linux-gnu-gcc-8
// commandline: -march=armv8-a+sve -nostdlib -static -g linux-aarch64-sve.c
static void bar(char *boom) {
  char F = 'b';
  asm volatile("ptrue p0.s\n\t");
  asm volatile("fcpy  z0.s, p0/m, #7.5\n\t");
  asm volatile("ptrue p1.s\n\t");
  asm volatile("fcpy  z1.s, p1/m, #11.5\n\t");
  asm volatile("ptrue p3.s\n\t");
  asm volatile("fcpy  z3.s, p3/m, #15.5\n\t");

  *boom = 47; // Frame bar
}

static void foo(char *boom, void (*boomer)(char *)) {
  char F = 'f';
  boomer(boom); // Frame foo
}

void _start(void) {
  char F = '_';
  foo(0, bar); // Frame _start
}
