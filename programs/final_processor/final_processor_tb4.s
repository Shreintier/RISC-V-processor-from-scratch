# Euclid GCD of 1071 and 462
# Expected x2=0x00000000, x10=0x00000015
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, 1071
    addi x2, x0, 462
loop:
    remu x3, x1, x2
    addi x1, x2, 0
    addi x2, x3, 0
    bne x2, x0, loop
    addi x10, x1, 0
halt:
    jal x0, halt
