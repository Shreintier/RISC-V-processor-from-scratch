# JAL/JALR link registers and wrong-path flush
# Expected x1=0x00000004, x10=0x00000014, x11=0x00000004, x12=0x00000018, x13=0x00000000, x14=0x0000002a
    .option norvc
    .text
    .globl _start
_start:
    jal x1, subroutine
    addi x10, x10, 7
    jal x0, after
subroutine:
    addi x11, x1, 0
    addi x10, x0, 13
    jalr x12, 0(x1)
    addi x13, x0, 99
after:
    addi x14, x0, 42
halt:
    jal x0, halt
