# 2x2 matrix multiplication: [[1,2],[3,4]] times [[5,6],[7,8]]
# Expected x24=0x00000013, x25=0x00000016, x26=0x0000002b, x27=0x00000032
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, 1
    addi x2, x0, 2
    addi x3, x0, 3
    addi x4, x0, 4
    addi x5, x0, 5
    addi x6, x0, 6
    addi x7, x0, 7
    addi x8, x0, 8
    sw x1, 0(x0)
    sw x2, 4(x0)
    sw x3, 8(x0)
    sw x4, 12(x0)
    sw x5, 16(x0)
    sw x6, 20(x0)
    sw x7, 24(x0)
    sw x8, 28(x0)
    addi x9, x0, 0
    addi x10, x0, 8
    addi x11, x0, 32
row:
    addi x12, x0, 16
    addi x13, x0, 24
col:
    add x14, x9, x0
    add x15, x12, x0
    addi x16, x0, 2
    addi x17, x0, 0
dot:
    lw x18, 0(x14)
    lw x19, 0(x15)
    mul x20, x18, x19
    add x17, x17, x20
    addi x14, x14, 4
    addi x15, x15, 8
    addi x16, x16, -1
    bne x16, x0, dot
    sw x17, 0(x11)
    addi x11, x11, 4
    addi x12, x12, 4
    blt x12, x13, col
    addi x9, x9, 8
    addi x23, x0, 16
    blt x9, x23, row
    lw x24, 32(x0)
    lw x25, 36(x0)
    lw x26, 40(x0)
    lw x27, 44(x0)
halt:
    jal x0, halt
