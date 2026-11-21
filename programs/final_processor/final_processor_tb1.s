# Fibonacci sequence, F(0) through F(11)
# Expected x10=0x00000000, x11=0x00000001, x12=0x00000005, x13=0x00000037, x14=0x00000059, x15=0x00000090
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, 0
    addi x2, x0, 1
    addi x3, x0, 12
    addi x4, x0, 0
loop:
    sw x1, 0(x4)
    add x5, x1, x2
    addi x1, x2, 0
    addi x2, x5, 0
    addi x4, x4, 4
    addi x3, x3, -1
    bne x3, x0, loop
    lw x10, 0(x0)
    lw x11, 4(x0)
    lw x12, 20(x0)
    lw x13, 40(x0)
    lw x14, 44(x0)
    add x15, x13, x14
halt:
    jal x0, halt
