#include "spi.h"

#define SDRAM_TEXT_BASE 0x00


int boot_main(){
    *(volatile int *)0x00 = 0xDEADBEEF;
    // *(volatile int *)SPI_DATA_ADDR = 10;
    SPI_SEND_DATA(10);
    // asm volatile ("jr %0" :: "r"(SDRAM_TEXT_BASE));
    while (1);
}