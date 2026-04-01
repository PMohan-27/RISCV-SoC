# RISCV-SoC

RV32I CPU-based SoC with MMIO peripherals and unified SDRAM memory.

![SoC Architecture](docs/SOC.png)

## Overview

RISC-V RV32I SoC for Gowin Tang Nano 20K. Boots programs from SD card into SDRAM.

## Architecture

- **CPU**: RV32I core with instruction cache
- **Memory**: Embedded SDRAM (Gowin IP)
- **Peripherals**: SPI (SD card), GPIO
- **Interconnect**: AXI4-Lite

### Hardware Modules

- [x] RV32I CPU core
- [ ] Instruction cache
- [x] CPU SDRAM arbiter
- [x] AXI4-Lite interconnect
- [x] AXI4-Lite to CPU bridge
- [x] SDRAM controller (Gowin IP integration)
- [x] SPI controller
- [x] GPIO controller

### Firmware

- [ ] SD card driver
- [ ] Bootloader (SD card to SDRAM)
- [ ] Binary/ELF loader
- [ ] Basic test programs

### Integration & Testing

- [ ] Module level testbenches
- [ ] System integration
- [ ] FPGA synthesis and timing
- [ ] Hardware bring-up and validation

## Documentation

[docs.md](docs/docs.md) - Detailed architecture and module specifications \
[map.md](rtl/map.md) - Memory map and address space layout\
[test.md](test/test.md) - Testing procedures and verification

## Hardware

**FPGA Board**: Gowin Tang Nano 20K

## Build & Run

TODO
