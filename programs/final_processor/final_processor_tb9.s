# Count primes up to 30 and sum them
# Expected x10=0x0000000a, x11=0x00000081
    .option norvc
    .text
    .globl _start
_start:
    addi x1, x0, 2
    addi x2, x0, 31
candidate:
    addi x3, x0, 2
divisor:
    mul x4, x3, x3
    blt x1, x4, prime
    remu x5, x1, x3
    beq x5, x0, next
    addi x3, x3, 1
    jal x0, divisor
prime:
    addi x10, x10, 1
    add x11, x11, x1
next:
    addi x1, x1, 1
    blt x1, x2, candidate
halt:
    jal x0, halt
