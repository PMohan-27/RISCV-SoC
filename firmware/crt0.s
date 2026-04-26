.section .text.boot
.global _start

_start:
    li sp, 0x00800000

    la t0, boot_main
    jr t0