# Forwarding tests
0x00: addi x1, x0, 5
0x04: addi x2, x1, 3
0x08: add  x3, x2, x1
0x0C: addi x4, x0, 0

# Store and load
0x10: sw   x3, 0(x4)
0x14: lw   x5, 0(x4)

# Load-use hazard
0x18: add  x6, x5, x3
0x1C: addi x7, x6, 1

# Branch and flush
0x20: addi x8, x0, 99
0x24: bne  x7, x0, 8
0x28: addi x8, x0, 11       # Should be flushed
0x2C: addi x8, x0, 22       # Branch target

# Forwarding after branch target
0x30: addi x9, x8, 1

# Signed comparison
0x34: addi x10, x0, -1
0x38: slt  x11, x10, x1

# Not-taken branch
0x3C: bge  x10, x1, 8
0x40: addi x12, x0, 12

# Not-taken branch
0x44: beq  x11, x0, 8
0x48: addi x13, x0, 13

# JAL and flush
0x4C: jal  x14, 8
0x50: addi x15, x0, 99       # Should be flushed
0x54: addi x15, x0, 15       # JAL target

# Link value dependency
0x58: addi x16, x14, 1

# Store/load forwarding
0x5C: addi x17, x0, 64
0x60: sw   x7, 4(x17)
0x64: lw   x18, 4(x17)
0x68: addi x19, x18, 2

# Branch flush
0x6C: addi x20, x0, 0
0x70: beq  x20, x0, 8
0x74: addi x21, x0, 99       # Should be flushed
0x78: addi x21, x0, 21       # Branch target

# JALR and flush
0x7C: addi x23, x0, 136
0x80: jalr x22, 0(x23)
0x84: addi x24, x0, 99       # Should be flushed
0x88: addi x24, x0, 24       # JALR target

# Stop
0x8C: jal  x0, 0