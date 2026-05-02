#include "spi.h"

void SPI_WRITE_BYTE(unsigned char data){
    *(volatile unsigned char *)SPI_DATA_ADDR = data;
    return;
}

void SPI_WRITE_HW(unsigned short data){
    *(volatile unsigned short *)SPI_DATA_ADDR = data;
    return;
}

void SPI_WRITE_WORD(unsigned int data){
    *(volatile unsigned int *)SPI_DATA_ADDR = data;
    return;
}

int SPI_READ_BYTE(){
    return *(volatile unsigned char *)SPI_DATA_ADDR;
}

int SPI_READ_HW(){
    return *(volatile unsigned short *)SPI_DATA_ADDR;
}

int SPI_READ_WORD(){
    return *(volatile unsigned int *)SPI_DATA_ADDR;
}

void SPI_WRITE_CTRL( unsigned int clk_div, unsigned int cs_n){
    unsigned int reg = ((clk_div & 0x7F) << 5) | ((cs_n & 0x01) << 0);

    *(volatile unsigned int *)SPI_CTRL_ADDR = reg;
}