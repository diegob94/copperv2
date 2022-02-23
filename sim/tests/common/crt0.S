#include "riscv_test.h"

.section .init, "ax"
.global _start
_start:
    la t0, __BSS_START__
    la t1, __BSS_END__
loop:
    sw zero, 0(t0)
    addi t0, t0, 4
    bgtu t1, t0, loop
    .cfi_startproc
    .cfi_undefined ra
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop
    la sp, __stack_top
    add s0, sp, zero
    .global main
    jal zero, main
    .cfi_endproc
    .end
