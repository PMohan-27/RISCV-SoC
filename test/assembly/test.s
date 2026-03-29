.global _start
_start:

li x2, 0x80000000
li x4, 0xDDCCFABC
li x1, 0x50
sw x1, 4(x2)
sh x4, 0(x2)
# li x4, 0xCAFEBEEF
# sh x4, 0(x2)


addi x1, x0, 1
sw x1, 4(x2)


li x5, 0x80000008
li x4, 0xFFFFFFFF
sw x4, 0(x5)

lw x5, 0(x2)
halt:
jal x0, halt
