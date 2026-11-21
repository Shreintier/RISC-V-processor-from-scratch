# Signed array sum, min, and max for [8,-3,12,-9,5]
# Expected x10=0x0000000d, x11=0xfffffff7, x12=0x0000000c
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, 8
    sw x1, 0(x0)
    addi x1, x0, -3
    sw x1, 4(x0)
    addi x1, x0, 12
    sw x1, 8(x0)
    addi x1, x0, -9
    sw x1, 12(x0)
    addi x1, x0, 5
    sw x1, 16(x0)
    addi x2, x0, 0
    addi x3, x0, 20
    lw x11, 0(x0)
    addi x12, x11, 0
loop:
    lw x4, 0(x2)
    add x10, x10, x4
    bge x4, x11, skip_min
    addi x11, x4, 0
skip_min:
    bge x12, x4, skip_max
    addi x12, x4, 0
skip_max:
    addi x2, x2, 4
    blt x2, x3, loop
halt:
    jal x0, halt
