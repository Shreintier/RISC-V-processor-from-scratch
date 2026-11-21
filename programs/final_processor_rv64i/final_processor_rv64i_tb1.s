# Fibonacci F(50), beyond 32 bits
# Expected x10=0x00000002ee333961, x11=0x00000004bdd96882
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, 50
    addi x11, x0, 1
loop:
    add x12, x10, x11
    addi x10, x11, 0
    addi x11, x12, 0
    addi x1, x1, -1
    bne x1, x0, loop
halt:
    jal x0, halt
