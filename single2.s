addi x1, x0, 15
addi x2, x0, 7
add  x3, x1, x2
sub  x4, x3, x2
and  x5, x4, x1
or   x6, x4, x2
xor  x7, x4, x2
slli x8, x2, 3
srli x9, x9, 2
addi x10, x0, -16
srai x11, x10, 2
slt  x12, x10, x1
sltu x13, x10, x1
addi x14, x0, 99
sw   x14, 0(x0)
lw   x15, 0(x0)
addi x16, x1, 15
add  x17, x15, x1
lw   x18, 0(x0)
add  x19, x18, x2
addi x20, x0, -5
sb   x20, 36(x0)
lb   x21, 4(x0)
lbu  x22, 4(x0)
beq  x1, x2, +12
bne  x1, x2, +12
addi x23, x0, 111
addi x24, x0, 222
addi x25, x0, 42
lui  x26, 2
auipc x27, 1
jal  x28, +12
addi x23, x0, 333
addi x24, x0, 444
addi x29, x0, 152
jalr x30, 0(x29)
addi x23, x0, 555
addi x24, x0, 666
addi x31, x0, 77
addi x0, x0, 99
nop
nop
nop
nop
nop