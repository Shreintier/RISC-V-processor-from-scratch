# Forwarding priority, load-use, store-data forwarding and x0
# Expected x0=0x00000000, x1=0x0000000c, x10=0x00000018, x11=0x00000030, x12=0x00000030, x13=0x00000030, x14=0x00000030
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, 3
    addi x1, x1, 4
    addi x1, x1, 5
    add x10, x1, x1
    sw x10, 0(x0)
    lw x2, 0(x0)
    add x11, x2, x10
    sw x11, 4(x0)
    lw x12, 4(x0)
    sw x12, 8(x0)
    lw x13, 8(x0)
    addi x0, x13, 1
    add x14, x0, x13
halt:
    jal x0, halt
