RISCV=riscv64-unknown-elf
BUILD=build

mkdir -p $BUILD

$RISCV-as crt0.s -o $BUILD/crt0.o -march=rv32i

$RISCV-gcc -c bootloader.c -o $BUILD/boot.o \
    -march=rv32i -mabi=ilp32 -ffreestanding -O0 -mcmodel=medany

$RISCV-gcc -c spi.c -o $BUILD/spi.o \
    -march=rv32i -mabi=ilp32 -ffreestanding -O0 -mcmodel=medany

$RISCV-gcc \
    -T link.ld \
    $BUILD/crt0.o $BUILD/boot.o $BUILD/spi.o\
    -o $BUILD/boot.elf \
    -march=rv32i -mabi=ilp32 -nostdlib -ffreestanding -mcmodel=medany

$RISCV-objcopy -O binary $BUILD/boot.elf $BUILD/boot.bin --only-section=.text --change-section-address .text-0xFFFF0000
$RISCV-objcopy -O verilog --only-section=.text \
    $BUILD/boot.elf $BUILD/boot.hex --change-section-address .text-0xFFFF0000
# $RISCV-objcopy -O verilog $BUILD/boot.elf $BUILD/boot.bin --only-section=.text
riscv64-unknown-elf-objdump -d build/boot.elf