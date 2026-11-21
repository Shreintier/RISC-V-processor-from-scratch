# LCM of 84 and 30 via Euclid
# Expected x3=0x00000006, x10=0x000001a4
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, 84
    addi x2, x0, 30
    addi x3, x1, 0
    addi x4, x2, 0
loop:
    remu x5, x3, x4
    addi x3, x4, 0
    addi x4, x5, 0
    bne x4, x0, loop
    divu x6, x1, x3
    mul x10, x6, x2
halt:
    jal x0, halt
