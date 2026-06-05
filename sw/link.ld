/* Configurable reset and trap handler addresses */
RESET_ADDR  = 0x00000000;   /* change this to match your core's reset_vector param */
TRAP_ADDR   = 0x00000010;   /* change this to match your core's trap_vector param  */

MEMORY {
    /* Instruction memory: 4096 words = 16384 bytes */
    IMEM (rx) : ORIGIN = 0x00000000, LENGTH = 16K
    /* Data memory: 4096 words = 16384 bytes */
    DMEM (rw) : ORIGIN = 0x00000000, LENGTH = 16K
}

ENTRY(_reset)

SECTIONS {
    /* Reset handler goes at RESET_ADDR */
    .reset RESET_ADDR : {
        KEEP(*(.reset))
    } > IMEM

    /* Trap handler goes at TRAP_ADDR */
    .trap TRAP_ADDR : {
        KEEP(*(.trap))
    } > IMEM

    /* Normal code after trap handler */
    .text : {
        *(.text*)
    } > IMEM

    /* Read-only data */
    .rodata : {
        *(.rodata*)
    } > IMEM

    /* Data section — loaded from IMEM, runs from DMEM */
    .data : {
        *(.data*)
    } > DMEM AT > IMEM

    /* BSS (zero-initialized) */
    .bss : {
        *(.bss*)
        *(COMMON)
    } > DMEM
}