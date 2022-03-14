#include "riscv_test.h"

.section .init, "ax"
.global _start
_start:
    .cfi_startproc
    .cfi_undefined ra
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop
    la sp, __stack_top
    add s0, sp, zero
// initialize BSS section to zero
    .global __BSS_START__
    .global __BSS_END__
    la t0, __BSS_START__
    la t1, __BSS_END__
loop:
    sw zero, 0(t0)
    addi t0, t0, 4
    bgtu t1, t0, loop
// go to _init
    .global _init
    jal ra, _init
    .cfi_endproc
    .end
