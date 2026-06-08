#include "handlers.c"    
#include <stdint.h>

int add(int a, int b){
    return a+b;
}

int main (void){
    // define a, b
    uint32_t a=10, b=20; 

    // define result, to_host
    volatile uint32_t *result = (volatile uint32_t *)0x0100;
    volatile uint32_t *to_host = (volatile uint32_t *)0x01FC;

    *result = add(a, b);

    // condition
    if (*result == (30)){
        // write cafecafe
        *to_host = 0xCAFECAFE;
    } else {
        // write deadbeef
        *to_host = 0xDEADBEEF;
    }
    
    while(1);
    return 0;
}