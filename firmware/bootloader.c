int x = 5;

int boot_main(){
    volatile int y = x + 3;
    while (1);
}