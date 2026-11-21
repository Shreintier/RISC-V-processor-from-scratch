# Integer power, 3^13 by squaring
# Expected x2=0x00000000, x10=0x001853d3
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, 3
    addi x2, x0, 13
    addi x10, x0, 1
loop:
    andi x3, x2, 1
    beq x3, x0, skip
    mul x10, x10, x1
skip:
    srli x2, x2, 1
    beq x2, x0, done
    mul x1, x1, x1
    jal x0, loop
done:
halt:
    jal x0, halt
