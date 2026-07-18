ENTRY(_reset_handler)

MEMORY
{
  /* FLASH memory */
  FLASH(rx)   : ORIGIN = 0x10000000, LENGTH = 2048K

  /* SRAM banks */
  BANK0(rwx)  : ORIGIN = 0x20000000, LENGTH = 64K
  BANK1(rwx)  : ORIGIN = 0x20010000, LENGTH = 64K
  BANK2(rwx)  : ORIGIN = 0x20020000, LENGTH = 64K
  BANK3(rwx)  : ORIGIN = 0x20030000, LENGTH = 64K

  /* Scratch SRAM banks */
  BANK4(rwx)  : ORIGIN = 0x20040000, LENGTH = 4K
  BANK5(rwx)  : ORIGIN = 0x20041000, LENGTH = 4K
}

SECTIONS
{
  /* === FLASH memory === */
  /* Read-only data */

  /* 2nd stage of boot */
  .boot2 : {
    __boot2_start__ = .;
    KEEP(*(.boot2))
    __boot2_end__   = .;
  } > FLASH
  ASSERT(SIZEOF(.boot2) == 256, "BOOT2 must be 256b")

  /* Vector table */
  .vectors : {
    . = ALIGN(4);
    __vector_table_start__ = .;
    KEEP(*(.vectors))
    . = ALIGN(4);
    __vector_table_end__   = .;
  } > FLASH

  /* Reset handler */
  .reset : {
    . = ALIGN(4);
    __reset_start__ = .;
    KEEP(*(.reset))
    __reset_end__   = .;
  } > FLASH

  /* === BANK 0 === */
  /* Code, variables */

  /* RAM vector table */
  /*
  .ram_vectors (NOLOAD) : {
    . = ALIGN(4);
    __vector_ram_table_start__ = .;
    . += SIZEOF(.vectors);
    . = ALIGN(4);
    __vector_ram_table_end__   = .;
  } > BANK0
  */

  /* PROC0 Code */
  .text : {
    . = ALIGN(4);
    __text_start__ = .;
    *(.text*)
    . = ALIGN(4);
    *(.rodata*)
    . = ALIGN(4);
    __text_end__   = .;
  } > FLASH
  /*} > BANK0 AT> FLASH*/
  __text_flash_load__ = LOADADDR(.text);

  /* PROC0 Data */
  .data : {
    . = ALIGN(4);
    __data_start__ = .;
    *(.data*)
    . = ALIGN(4);
    __data_end__   = .;
  } > BANK0 AT> FLASH
  __data_flash_load__ = LOADADDR(.data);

  /* PROC0 BSS */
  .bss : {
    . = ALIGN(4);
    __bss_start__ = .;
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    __bss_end__   = .;
  } > BANK0 AT> FLASH

  /* Copy data from flash to SRAM */
  /*__copy_ram_start__  = __text_start__;*/
  __copy_ram_start__  = __data_start__;
  __copy_ram_end__    = __data_end__;
  __copy_flash_load__ = __data_flash_load__;

  /* Reset data in SRAM */
  __rst_ram_start__   = __bss_start__;
  __rst_ram_end__     = __bss_end__;

  /* === BANK 1-2 === */
  /* Heap, buffers, stack */

  /* Heap */
  .heap_b1 (NOLOAD) : {
    __heap_b1_start__ = .;
    . += LENGTH(BANK1);
    __heap_b1_limit__ = .;
  } > BANK1

  .heap_b2 (NOLOAD) : {
    __heap_b2_start__ = .;
    . += 32K;
    __heap_b2_limit__ = .;
  } > BANK2

  /* Buffers */
  .buffers (NOLOAD) : {
    __buffers_start__ = .;
    . += 16K;
    __buffers_end__   = .;
  } > BANK2

  .stack (NOLOAD) : {
    __stack_bottom__ = .;
    . = ORIGIN(BANK2) + LENGTH(BANK2);
    __stack_top__    = .;
  } > BANK2

  /* === BANK 3 === */
  /* PROC1 Space (Code, data, buffers, stack) */

  /* === BANK 4 === */
  /* Display buffer, sound buffer */

  /* === BANK 5 === */
  /* TF Card buffer */
}

