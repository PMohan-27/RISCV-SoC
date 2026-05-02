#ifndef SPI_H
#define SPI_H

#define MMIO_BASE_ADDR 0x80000000

#define SPI_DATA_ADDR (0x00 + MMIO_BASE_ADDR)
#define SPI_CTRL_ADDR (0x04 + MMIO_BASE_ADDR)

void SPI_WRITE_BYTE(unsigned char data);
void SPI_WRITE_HW(unsigned short data);
void SPI_WRITE_WORD(unsigned int data);

int SPI_READ_BYTE();
int SPI_READ_HW();
int SPI_READ_WORD();

void SPI_WRITE_CTRL( unsigned int clk_div, unsigned int cs_n);


#endif