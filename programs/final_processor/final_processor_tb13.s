# RV32M high products and signed, unsigned, zero and overflow division
# Expected x10=0xffffffe2, x11=0xffffffff, x12=0xffffffff, x13=0x00000002, x14=0xfffffffd, x15=0x55555552, x16=0xffffffff, x17=0x00000000, x18=0xffffffff, x19=0xfffffff6, x20=0xffffffff, x21=0xfffffff6, x22=0x80000000, x23=0x00000000
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, -10
    addi x2, x0, 3
    mul x10, x1, x2
    mulh x11, x1, x2
    mulhsu x12, x1, x2
    mulhu x13, x1, x2
    div x14, x1, x2
    divu x15, x1, x2
    rem x16, x1, x2
    remu x17, x1, x2
    div x18, x1, x0
    rem x19, x1, x0
    divu x20, x1, x0
    remu x21, x1, x0
    lui x3, 0x80000
    addi x4, x0, -1
    div x22, x3, x4
    rem x23, x3, x4
halt:
    jal x0, halt
