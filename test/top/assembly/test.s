.global _start
_start:
lui     sp,0x800
auipc   t0,0x0
addi    t0,t0,12
jr      t0

addi    sp,sp,-16
sw      ra,12(sp)
sw      s0,8(sp)
addi    s0,sp,16
li      a4,0
lui     a5,0xdeadc
addi    a5,a5,-273
sw      a5,0(a4)
# li x2, 0x0

# li x3, 0x00a00493 # addi x9, x0, 10
# li x4, 0x08902023 # sw x9, 128(x0)
# li x5, 0x01e00513 # addi x10, x0, 30
# li x6, 0x00a00093 # addi x1, x0, 10
# li x7, 0x0000006f # jal x0, 0


# sw x3, 0(x2)
# sw x4, 4(x2)
# sw x5, 8(x2)
# sw x6, 12(x2)
# sw x7, 16(x2)
# lw x19, 16(x2)

# li x10, 0x8000000C # csr for IPC calculation
# lw x15, 0(x10)

jalr x0, 0x0

# halt:
# jal x0, halt
