.global _start
_start:

li x2, 0x0

li x3, 0x00a00493 # addi x9, x0, 10
li x4, 0x00a00093 # sw x9, 128(x0)
li x5, 0x01e00513 # addi x10, x0, 30
li x6, 0x00a00093 # addi x1, x0, 10
li x7, 0x0000006f # jal x0, 0


sw x3, 0(x2)
sw x4, 4(x2)
sw x5, 8(x2)
sw x6, 12(x2)
sw x7, 16(x2)

jalr x0, 0

# halt:
# jal x0, halt
