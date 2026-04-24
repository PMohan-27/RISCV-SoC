# Documentation

Detailed architecture and implementation specifications for RISCV-SoC.

## CPU Core

5 stage pipeline. Stalls on data load / store and instruction wait.

## Memory Architecture

**Boot ROM**: FPGA BRAM contains bootloader  
**SDRAM**: Gowin embedded IP connected via SDRAM Bridge  
**CPU SDRAM Arbiter**: Arbitrates instruction and data requests, prioritizes data  
**Data Interconnect**: Routes to SDRAM or MMIO by address  

## Interconnect

**CPU-SDRAM Bridge**: Converts CPU load/stores and instruction requests to SDRAM mem signals  
**AXI4-Lite Bridge**: Bridges CPU data to AXI4-Lite ctrl signals

## Peripherals

See [map.md](../rtl/map.md) for register maps.

**SPI**: SD card interface  
**GPIO**: FPGA pin control
**CSR**: Currently only used for IPC

## Boot Flow

1. Start at Boot ROM (BRAM bootloader)
2. Init SPI/SD card
3. Load program from SD → SDRAM
4. Jump to SDRAM and execute