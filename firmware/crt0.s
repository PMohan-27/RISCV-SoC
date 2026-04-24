.section .text.boot
.global _start

_start:
    la sp, _stack_top

    la t0, boot_main
    jr t0