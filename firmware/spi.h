#ifndef SPI_H
#define SPI_H

#define MMIO_BASE_ADDR 0x80000000

#define SPI_DATA_ADDR (0x00 + MMIO_BASE_ADDR)
#define SPI_CTRL_ADDR (0x04 + MMIO_BASE_ADDR)

void SPI_SEND_DATA(int data);

#endif