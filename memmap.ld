ENTRY(Reset_Handler)

MEMORY
{
  FLASH (rx)  : ORIGIN = 0x10000100, LENGTH = 2048K - 256
  BANK0 (rwx) : ORIGIN = 0x21000000, LENGTH = 64K
  BANK1 (rwx) : ORIGIN = 0x21010000, LENGTH = 64K
  BANK2 (rwx) : ORIGIN = 0x21020000, LENGTH = 64K
  BANK3 (rwx) : ORIGIN = 0x21030000, LENGTH = 64K
  SCRATCH_X (rwx) : ORIGIN = 0x20040000, LENGTH = 4K
  SCRATCH_Y (rwx) : ORIGIN = 0x20041000, LENGTH = 4K
}

SECTIONS
{
  /* === Vector table === */

  /* (Core0) Flash vectors */
  .vectors : ALIGN(4)
  {
    KEEP(*(.vectors))
  } > FLASH

  /* (Core1) Flash vectors */
  .c1_vectors : ALIGN(4)
  {
    KEEP(*(.c1_vectors))
  } > FLASH

  /* Code that runs only once after reboot */
  .init : ALIGN(4)
  {
    *(.init*)
    *(.c0_init*)
    *(.c1_init*)
  }

  /* === Core1 - peripheral control - BANK2 === */

  /* (Core1) SRAM Vectors copy */
  .c1_vectors_ram (NOLOAD) : ALIGN(256)
  {
    _c1_sramvec = .;
    . = . + (48 * 4);
    _c1_eramvec = .;
  } > BANK2
  _c1_siramvec = LOADADDR(.c1_vectors);

  .core1 : ALIGN(4)
  {
    _score1 = .;
    *(.c1_text*)    /* Code */
    . = ALIGN(4);
    *(.c1_rodata*)  /* Constants */
    . = ALIGN(4);
    *(.c1_data*)    /* Initialized data */
    . = ALIGN(4);
    _ecore1 = .;
  } > BANK2 AT> FLASH
  _sicore1 = LOADADDR(.core1);

  .core1_bss (NOLOAD) : ALIGN(4)
  {
    _score1_bss = .;
    *(.c1_bss*)
    . = ALIGN(4);
    _ecore1_bss = .;
  } > BANK2

  /* === Core0 - system control - BANK3 === */

  /* (Core0) SRAM Vectors copy */
  .vectors_ram (NOLOAD) : ALIGN(256)
  {
    _sramvec = .;
    . = . + (48 * 4);
    _eramvec = .;
  } > BANK3
  _siramvec = LOADADDR(.vectors);

  .core0 : ALIGN(4)
  {
    _score0 = .;
    *(.text*)     /* Code */
    . = ALIGN(4);
    *(.rodata*)   /* Constants */
    . = ALIGN(4);
    *(.data*)     /* Initialized data */
    . = ALIGN(4);
    _ecore0 = .;
  } > BANK3 AT> FLASH
  _sicore0 = LOADADDR(.core0);

  .core0_bss (NOLOAD) : ALIGN(4)
  {
    _score0_bss = .;
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    _ecore0_bss = .;
  } > BANK3

  /* Stack to scratch bank */
  __stack_core0_top = ORIGIN(SCRATCH_Y) + LENGTH(SCRATCH_Y);
  __stack_core1_top = ORIGIN(SCRATCH_X) + LENGTH(SCRATCH_X);

  /* 128K of user-space ram */
  __user_ram_start = ORIGIN(BANK0);
  __user_ram_end   = ORIGIN(BANK1) + LENGTH(BANK1);
}
