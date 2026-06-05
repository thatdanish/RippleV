#include "handlers.c"
#include <stdint.h>


int main(void) {
    volatile uint32_t *result = (volatile uint32_t *)0x0100; /* DMEM address */
    
    uint32_t a = 10, b = 20;
    *result = a + b;   /* should be 30 = 0x1E */

    /* Signal success by writing a known value to a sentinel address */
    volatile uint32_t *done = (volatile uint32_t *)0x01FC;
    *done = 0xCAFECAFE;

    while (1);  /* halt */
    return 0;
}