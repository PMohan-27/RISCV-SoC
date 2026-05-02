#include "spi.h"

#define SDRAM_TEXT_BASE 0x00

void sd_init();
void sd_read(unsigned int sector, unsigned char *buf) ;

void boot_main(){
    unsigned char code_buffer[512];
    unsigned int sd_sector = 0;
    sd_init();
    sd_read(sd_sector,code_buffer);
    for(int i = 0; i < 512; i++) {
        *(volatile unsigned char *)(SDRAM_TEXT_BASE + i + sd_sector*512) = code_buffer[i];
    }
    ((void(*)())SDRAM_TEXT_BASE)();
    while (1);
}

void sd_init() {
    SPI_WRITE_CTRL(8, 1);
    for(int i = 0; i < 10; i++) {
        SPI_WRITE_BYTE(0xFF);
    }
    
    SPI_WRITE_CTRL(8, 0);
    SPI_WRITE_BYTE(0x40);
    SPI_WRITE_BYTE(0);
    SPI_WRITE_BYTE(0);
    SPI_WRITE_BYTE(0);
    SPI_WRITE_BYTE(0);
    SPI_WRITE_BYTE(0x95);
    while(SPI_READ_BYTE() == 0xFF);
    SPI_WRITE_CTRL(8, 1);
    
    SPI_WRITE_CTRL(8, 0);
    SPI_WRITE_BYTE(0x48);
    SPI_WRITE_BYTE(0);
    SPI_WRITE_BYTE(0);
    SPI_WRITE_BYTE(0x01);
    SPI_WRITE_BYTE(0xAA);
    SPI_WRITE_BYTE(0x87);
    while(SPI_READ_BYTE() == 0xFF);
    for(int i = 0; i < 4; i++) {
        SPI_READ_BYTE();
    }
    SPI_WRITE_CTRL(8, 1);
    
    for(int j = 0; j < 100; j++) {
        SPI_WRITE_CTRL(8, 0);
        SPI_WRITE_BYTE(0x77);
        SPI_WRITE_BYTE(0);
        SPI_WRITE_BYTE(0);
        SPI_WRITE_BYTE(0);
        SPI_WRITE_BYTE(0);
        SPI_WRITE_BYTE(0x01);
        while(SPI_READ_BYTE() == 0xFF);
        SPI_WRITE_CTRL(8, 1);
        
        SPI_WRITE_CTRL(8, 0);
        SPI_WRITE_BYTE(0x69);
        SPI_WRITE_BYTE(0x40);
        SPI_WRITE_BYTE(0);
        SPI_WRITE_BYTE(0);
        SPI_WRITE_BYTE(0);
        SPI_WRITE_BYTE(0x01);
        unsigned char r = 0xFF;
        while(r == 0xFF) {
            r = SPI_READ_BYTE();
        }
        SPI_WRITE_CTRL(8, 1);
        if(r == 0) {
            break;
        }
    }
    
    SPI_WRITE_CTRL(2, 1);
}

void sd_read(unsigned int sector, unsigned char *buf) {
    SPI_WRITE_CTRL(2, 0);
    SPI_WRITE_BYTE(0x51);
    SPI_WRITE_BYTE((sector >> 24) & 0xFF);
    SPI_WRITE_BYTE((sector >> 16) & 0xFF);
    SPI_WRITE_BYTE((sector >> 8) & 0xFF);
    SPI_WRITE_BYTE(sector & 0xFF);
    SPI_WRITE_BYTE(0x01);
    while(SPI_READ_BYTE() != 0x00);
    while(SPI_READ_BYTE() != 0xFE);
    for(int i = 0; i < 512; i++) {
        buf[i] = SPI_READ_BYTE();
    }
    SPI_READ_BYTE();
    SPI_READ_BYTE();
    SPI_WRITE_CTRL(2, 1);
}