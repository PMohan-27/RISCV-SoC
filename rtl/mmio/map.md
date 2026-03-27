# MMIO Maps

This document contains the memory map for MMIO peripherals. Addresses are to be added to  MMIO base address. **MMIO BASE ADDRESS: 0x8000_0000**

## SPI | Base Addr: 0x00

0x00:

| Bits  | 31-0                    |
|-------|-------------------------|
| DATA  | DATA[31:0]   TX/RX word |

0x04:

| Bits  | 31-12     | 11-5         | 4-3        | 2    | 1    | 0        |
|-------|-----------|--------------|------------|------|------|----------|
| CTRL  | NO USE    | CLK_DIV[6:0] | RESP [1:0] | CPHA | CPOL | CS_N     |

Will eventually add CPOL, CPHA and a RESP field into CTRL reg.
