MEMORY
{
    FLASH(rx) : ORIGIN = 0x10000000, LENGTH = 2048k
    RAM(rwx)  : ORIGIN = 0x20000000, LENGTH = 256k
}

ENTRY(Reset_Handler)

SECTIONS
{
    .boot2 : {
        KEEP(*(.boot2))
    } > FLASH

    .vectors : {
        . = ALIGN(256);
        KEEP(*(.vectors))
    } > FLASH

    .text : {
        . = ALIGN(4);
        *(.text*)
    } > FLASH

    .rodata : {
        . = ALIGN(4);
        *(.rodata*)
    } > FLASH

    _sidata = LOADADDR(.data);

    .data : {
        . = ALIGN(4);
        _sdata = .;
        *(.data*)
        . = ALIGN(4);
        _edata = .;
    } > RAM AT > FLASH

    .bss : {
        . = ALIGN(4);
        _sbss = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } > RAM

    /* Heap start */
    . = ALIGN(4);
    _heap_start = .;

    /* Stack bottom */
    _heap_end = 0x2003E000;

    /* Stack top */
    _estack = 0x20040000;
}


