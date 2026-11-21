# Dot product of [2,-3,4] with [5,6,-7]
# Expected x10=0xffffffdc
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, 2
    sw x1, 0(x0)
    addi x1, x0, -3
    sw x1, 4(x0)
    addi x1, x0, 4
    sw x1, 8(x0)
    addi x1, x0, 5
    sw x1, 12(x0)
    addi x1, x0, 6
    sw x1, 16(x0)
    addi x1, x0, -7
    sw x1, 20(x0)
    addi x2, x0, 0
    addi x3, x0, 12
loop:
    lw x4, 0(x2)
    lw x5, 12(x2)
    mul x6, x4, x5
    add x10, x10, x6
    addi x2, x2, 4
    blt x2, x3, loop
halt:
    jal x0, halt
