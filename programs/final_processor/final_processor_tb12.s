# Byte and halfword stores, signed and unsigned loads
# Expected x10=0xfffe8078, x11=0xffffff80, x12=0x00000080, x13=0xfffffffe, x14=0x0000fffe, x15=0x00000078
    .option norvc
    .text
    .globl _start
_start:
    lui x1, 0x12345
    addi x1, x1, 0x678
    sw x1, 0(x0)
    addi x2, x0, -128
    sb x2, 1(x0)
    addi x3, x0, -2
    sh x3, 2(x0)
    lw x10, 0(x0)
    lb x11, 1(x0)
    lbu x12, 1(x0)
    lh x13, 2(x0)
    lhu x14, 2(x0)
    lbu x15, 0(x0)
halt:
    jal x0, halt
