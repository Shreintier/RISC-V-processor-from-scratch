# Bubble sort of [7,-2,5,0,3]
# Expected x10=0xfffffffe, x11=0x00000000, x12=0x00000003, x13=0x00000005, x14=0x00000007
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, 7
    sw x1, 0(x0)
    addi x1, x0, -2
    sw x1, 4(x0)
    addi x1, x0, 5
    sw x1, 8(x0)
    sw x0, 12(x0)
    addi x1, x0, 3
    sw x1, 16(x0)
    addi x2, x0, 16
outer:
    addi x3, x0, 0
inner:
    lw x4, 0(x3)
    lw x5, 4(x3)
    bge x5, x4, ordered
    sw x5, 0(x3)
    sw x4, 4(x3)
ordered:
    addi x3, x3, 4
    blt x3, x2, inner
    addi x2, x2, -4
    bne x2, x0, outer
    lw x10, 0(x0)
    lw x11, 4(x0)
    lw x12, 8(x0)
    lw x13, 12(x0)
    lw x14, 16(x0)
halt:
    jal x0, halt
