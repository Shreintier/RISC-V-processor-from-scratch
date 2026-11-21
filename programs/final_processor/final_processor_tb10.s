# Popcount and bit reversal of 0xB2
# Expected x10=0x00000004, x11=0x0000004d
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, 178
    addi x2, x0, 8
loop:
    andi x3, x1, 1
    add x10, x10, x3
    slli x11, x11, 1
    or x11, x11, x3
    srli x1, x1, 1
    addi x2, x2, -1
    bne x2, x0, loop
halt:
    jal x0, halt
