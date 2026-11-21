# Sign extension for byte, halfword, and word loads
# Expected x10=0xffffffffffffffff, x11=0xffffffffffffffff, x12=0xffffffffffffffff, x13=0x000000000000ffff, x14=0x00000000000000ff, x15=0x00000000000000fe
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, -1
    sw x1, 0(x0)
    lw x10, 0(x0)
    lh x11, 0(x0)
    lb x12, 0(x0)
    lhu x13, 0(x0)
    lbu x14, 0(x0)
    add x15, x10, x14
halt:
    jal x0, halt
