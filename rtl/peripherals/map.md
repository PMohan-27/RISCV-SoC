# MMIO Maps

This document contains the memory map for MMIO peripherals. Addresses are assumed to be added to base.

## SPI | Base Addr: 0x00

0x00:

| Bits  | 31-0                    |
|-------|-------------------------|
| DATA  | DATA[31:0]   TX/RX word |

0x04:

| Bits  | 31-9      | 8-5          | 4-3        | 2    | 1    | 0        |
|-------|-----------|--------------|------------|------|------|----------|
| CTRL  | NO USE    | CLK_DIV[3:0] | NO USE     | N/A  | N/A  | N/A      |

Will eventually add CPOL, CPHA and a RESP field into CTRL reg.