# Memory Map

This document contains the memory map. Addresses are to be added to base address.
These addresses are byte addressed.

## SDRAM ADDRESS SPACE: 0x0000_0000 - 0x007F_FFFF

SDRAM TEXT SPACE: 0x0000_0000 - 0x003F_FFFF
SDRAM DATA SPACE: 0x0040_0000 - 0x007F_FFFF

## BOOT ROM ADDRESS SPACE: 0xFFFF_0000 - 0xFFFF_FFFF

## MMIO ADDRESS SPACE : 0x8000_0000 - 0xFFFEFFFF

### SPI | Base Addr: 0x00

0x00:

| Bits  | 31-0                    |
|-------|-------------------------|
| DATA  | DATA[31:0]   TX/RX word |

0x04:

| Bits  | 31-12     | 11-5         | 4-3        | 2    | 1    | 0        |
|-------|-----------|--------------|------------|------|------|----------|
| CTRL  | NO USE    | CLK_DIV[6:0] | RESP [1:0] | CPHA | CPOL | CS_N     |

Currently RESP, CPHA, CPOL ae not used in logic. TODO

### GPIO | Base Addr: 0x08

0x08:

| Bits       | 31-16                     | 15-0       |
|------------|---------------------------|------------|
| DIRECTION  | DIR[15:0] HIGH out LOW in | DATA[15:0] |

### CSR | Base Addr: 0x0C

0x0C:

| Bits       | 31-0                      |
|------------|---------------------------|
| REGISTER   | Clock Cycles [31:0]       |
