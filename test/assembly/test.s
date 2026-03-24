.global _start
_start:

li x2, 0x80000000
li x1, 0x50
sw x1, 4(x2)

addi x4, x4, 1000
sw x4, 0(x2)

# lw x5, 0(x2)
halt:
jal x0, halt
