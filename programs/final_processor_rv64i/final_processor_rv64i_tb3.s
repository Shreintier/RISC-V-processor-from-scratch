# 64-bit immediate and register shift amounts
# Expected x10=0x8000000000000000, x11=0x0000000000000001, x12=0xffffffffffffffff, x13=0xffffffffffffffff, x14=0x0000000000000001
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, 1
    addi x2, x0, 127
    sll x10, x1, x2
    srli x11, x10, 63
    srai x12, x10, 63
    sra x13, x10, x2
    srl x14, x10, x2
halt:
    jal x0, halt
