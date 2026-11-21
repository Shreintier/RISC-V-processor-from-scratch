# Signed and unsigned branches and bitwise shifts
# Expected x10=0x00000007, x11=0xffffffff, x12=0x00000001, x13=0x7fffffff, x14=0x00000001, x15=0x00000001, x16=0x00000000
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, -1
    addi x2, x0, 1
    blt x1, x2, signed_ok
    addi x10, x10, 32
signed_ok:
    bltu x2, x1, unsigned_ok
    addi x10, x10, 32
unsigned_ok:
    bgeu x1, x2, ge_ok
    addi x10, x10, 32
ge_ok:
    addi x10, x10, 7
    slli x3, x2, 31
    srai x11, x3, 31
    srli x12, x3, 31
    xor x13, x3, x1
    and x14, x13, x2
    slt x15, x1, x2
    sltu x16, x1, x2
halt:
    jal x0, halt
