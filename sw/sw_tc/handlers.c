#include <stdint.h>

/* 
 * Mark functions with special section attributes so the linker
 * places them at the exact addresses defined in link.ld
 */

__attribute__((section(".reset"), naked))
void _reset(void) {
    /* Set up stack pointer: top of data memory */
    __asm__ volatile (
        "li sp, 0x4000\n"   /* 16K = top of 4096-word data memory */
        "j  main\n"
    );
}

__attribute__((section(".trap"), interrupt))
void _trap_handler(void) {
    volatile uint32_t *tohost = (volatile uint32_t *)0x3FF8;
    *tohost = 0xDEADBEEF;   /* signal that a trap occurred */
    while (1);               /* halt — or use wfi */
}