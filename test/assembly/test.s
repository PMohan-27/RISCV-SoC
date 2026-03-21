.global _start
_start:

li x2, 0x04
li x1, 0x50
sw x1, 0(x2)

addi x4, x4, 1000
sw x4, 0(x0)

lw x5, 0(x0)
halt:
jal x0, halt
