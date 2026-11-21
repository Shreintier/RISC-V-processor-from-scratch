# Check the M extension with x1 = -2^40 - 1 and x2 = 3.
# Signed and unsigned operations use the same input bits.
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, -1
    slli x1, x1, 40
    addi x1, x1, -1
    addi x2, x0, 3
    mul x10, x1, x2
    mulh x11, x1, x2
    mulhsu x12, x1, x2
    mulhu x13, x1, x2
    div x14, x1, x2
    divu x15, x1, x2
    rem x16, x1, x2
    remu x17, x1, x2
halt:
    jal x0, halt
