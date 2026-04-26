#include "spi.h"

void SPI_SEND_DATA(int data){
    *(volatile int *)SPI_DATA_ADDR = data;
    return;
    // return *(volatile int *)SPI_CTRL_ADDR;
}
