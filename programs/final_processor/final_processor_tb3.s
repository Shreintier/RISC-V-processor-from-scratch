# Factorial, 10!
# Expected x1=0x00000000, x10=0x00375f00, x11=0x00375f00
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, 10
    addi x10, x0, 1
loop:
    mul x10, x10, x1
    addi x1, x1, -1
    bne x1, x0, loop
    sw x10, 0(x0)
    lw x11, 0(x0)
halt:
    jal x0, halt
