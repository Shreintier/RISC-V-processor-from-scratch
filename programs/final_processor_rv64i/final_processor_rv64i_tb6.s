# 64-bit bitwise operations and sign extension from LUI
# Expected x10=0x7fffffff80000000, x11=0xffffffff80000000, x12=0x8000000000000000, x13=0x0000000000000000
    .option norvc
    .text
    .globl _start
_start:
    lui x1, 0x80000
    addi x2, x0, 1
    slli x3, x2, 63
    xor x10, x1, x3
    or x11, x1, x3
    and x12, x1, x3
    andi x13, x10, 255
halt:
    jal x0, halt
