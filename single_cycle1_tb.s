addi x1,x0,5
addi x2,x0,10
add x3,x1,x2
sub x4,x2,x1
and x5,x2,x1
or x6,x2,x1
xor x7,x2,x1
addi x8,x0,-1
slt x9,x8,x1
sltu x10,x8,x1
addi x11,x0,1
addi x12,x0,3
sll x13,x11,x12
lui x14,0x80000
addi x15,x0,4
srl x16,x14,x15
sra x17,x14,x15
addi x18,x1,-8
slti x19,x1,6
sltiu x20,x8,1
xori x21,x1,255
ori x22,x1,256
andi x23,x7,7
slli x24,x1,2
srli x25,x14,4
srai x26,x14,4
lui x27,0x12345
auipc x28,0x0

sw x3,0(x0)
lw x29,0(x0)
addi x30,x0,128
sb x30,4(x0)
lb x31,4(x0)
lbu x5,4(x0)
addi x6,x0,1
addi x7,x0,128
lui x7,0x8
addi x7,x7,1
sh x7,8(x0)
lh x8,8(x0)
lhu x9,8(x0)
addi x10,x0,85
sb x10,5(x0)
lbu x11,5(x0)
sb x10,6(x0)
lbu x12,6(x0)
sb x10,7(x0)
lbu x13,7(x0)
lui x10,0x1
addi x10,x10,564
sh x10,10(x0)
lh x11,10(x0)
lhu x12,10(x0)

addi x1,x0,7
addi x2,x0,7
beq x1,x2,L1

addi x3,x0,99
L1:
bne x1,x2,L2

addi x4,x0,11
L2:
addi x5,x0,-1
addi x6,x0,1
blt x5,x6,L3

addi x7,x0,99
L3:
bge x6,x5,L4

addi x8,x0,99
L4:
bltu x5,x6,L5

addi x9,x0,12
L5:
bgeu x5,x6,L6

addi x10,x0,99
L6:
jal x11,L7

addi x12,x0,99
L7:
addi x13,x0,13
addi x14,x0,300
jalr x15,0(x14)

addi x16,x0,99
L8:
addi x17,x0,17
addi x0,x0,123
addi x18,x0,1
L9:
jal x0,L9