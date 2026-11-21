# Signed and unsigned comparisons across bit 63
# Expected x10=0x0000000000000001, x11=0x0000000000000000, x12=0x0000000000000007
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, 1
    slli x2, x1, 63
    slt x10, x2, x1
    sltu x11, x2, x1
    blt x2, x1, signed_ok
    addi x12, x12, 1
signed_ok:
    bltu x1, x2, unsigned_ok
    addi x12, x12, 2
unsigned_ok:
    addi x12, x12, 7
halt:
    jal x0, halt
