.global _start
_start:

li x2, 0x0

# Data values
li x3, 0x00a00493
li x4, 0x08902023
li x5, 0x00000013
li x6, 0x00a00093
li x7, 0x0000006f


# Store words at 0, 4, 8, 12, 16
sw x3, 0(x2)
sw x4, 4(x2)
sw x5, 8(x2)
sw x6, 12(x2)
sw x7, 16(x2)

jalr x0, 0
halt:
jal x0, halt
