# 64-bit carry, borrow, and wraparound
# Expected x10=0x0000000100000000, x11=0x00000000ffffffff, x12=0x0000000000000000, x13=0xffffffffffffffff, x14=0x8000000000000000
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, 1
    slli x2, x1, 32
    addi x3, x2, -1
    add x10, x3, x1
    sub x11, x10, x1
    addi x4, x0, -1
    add x12, x4, x1
    sub x13, x0, x1
    slli x14, x1, 63
halt:
    jal x0, halt
