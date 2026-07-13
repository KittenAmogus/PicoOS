MEMORY
{
    FLASH(rx) : ORIGIN = 0x10000000, LENGTH = 2048k
    RAM(rwx)  : ORIGIN = 0x20000000, LENGTH = 256k
    SCRATCH_Y : ORIGIN = 0x20040000, LENGTH = 4k
    SCRATCH_X : ORIGIN = 0x20041000, LENGTH = 4k
}

ENTRY(_start)

SECTIONS
{
  .flash_begin : {
    __flash_binary_start = .;
  } > FLASH

  .boot2 : {
    __boot2_start__ = .;
    KEEP(*(.boot2))
    __boot2_end__ = .;
  } > FLASH

  ASSERT(__boot2_end__ - __boot2_start__ != 0,
          "Error: boot2 size must be !0 bytes")

  ASSERT(__boot2_end__ - __boot2_start__ == 256,
          "Error: boot2 size must be 256 bytes")

  .text : {
    __logical_binary_start = .;
    KEEP(*(.vectors))
    KEEP(*(.binary_info_headers))
    __binary_info_header_end = .;
    . = __logical_binary_start + 0x100;
    KEEP(*(.reset))
  } > FLASH

  .rodata : {
    . = ALIGN(4);
    *(.rodata*)
    . = ALIGN(4);
    *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.flashdata*)))
    . = ALIGN(4);
  } > FLASH

  .ram_vector_table (COPY) : {
    *(.ram_vector_table)
  } > RAM

  __data_load_start__ = LOADADDR(.data);
  .data : {
    __data_start__ = .;
    *(.data*)
    . = ALIGN(4);
    __data_end__ = .;
  } > RAM AT> FLASH

  .bss : {
    . = ALIGN(4);
    __bss_start__ = .;
    *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.bss*)))
    *(COMMON)
    . = ALIGN(4);
    __bss_end__ = .;
  } > RAM

  .heap (NOLOAD) : {
    __end__ = .;
    end = __end__;
    . = ORIGIN(RAM) + LENGTH(RAM);
    __HeapLimit = .;
  } > RAM

  _estack = 0x20042000;
}

