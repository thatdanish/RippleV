#include "handlers.c"
#include <stdint.h>

int factorial(int val) {
    if (val <= 1) {
        return 1;
    } else {
        return val * factorial(val-1);
    }
}

int main(void) {
    volatile uint32_t *result = (volatile uint32_t*)0x0100; // RESULT

    uint32_t val = 4; // val = 4

    *result = factorial(val); // call sub-function
    
    volatile uint32_t *done = (volatile uint32_t*)0x01FC; // TO_HOST
    *done = 0xCAFECAFE; // SUCCESS
      

    while (1); // halt
    return 0;
}

