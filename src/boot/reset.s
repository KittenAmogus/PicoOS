.cpu cortex-m0plus
.thumb

.section .reset, "ax"
.global _reset_handler

_reset_handler:

// Copy .text and .data from flash
  ldr r0, =__copy_ram_start__   @ Dest start
  ldr r1, =__copy_ram_end__     @ Dest end
  ldr r2, =__copy_flash_load__  @ Src start

.copy_data_loop:
  cmp r0, r1          @ Check if reached end of dest
  beq .copy_data_done @ End of loop
  ldr r3, [r2]        @ Read 4 bytes
  str r3, [r0]        @ Write 4 bytes
  add r0, r0, #4      @ Next
  add r2, r2, #4      @ Next
  b .copy_data_loop

.copy_data_done:
  ldr r1, =__rst_ram_start__  @ Dest start
  ldr r2, =__rst_ram_end__    @ Dest end
  movs r3, #0                 @ Value to write

.clear_bss_loop:
  cmp r1, r2          @ Check if reached end
  beq .clear_bss_done @ End of loop
  str r3, [r1]        @ Write 4 bytes
  add r1, r1, #4      @ Next
  b .clear_bss_loop

.clear_bss_done:
  bl kmain      @ Load main function
  bl powerdown  @ And powerdown after

.align 2
.global powerdown
.thumb_func
powerdown:

// Powerdown peripherals
  ldr r0, =RESETS_RESET @ Load RESET addr
  ldr r1, =0xFFFFFFFF   @ Disable everything mask
  str r1, [r0]          @ Disable peripherals

// Powerdown PROC0
  cpsid i               @ Disable interrupts
endloop:
  wfi                   @ Wait for interrupt
  b endloop             @ Repeat

.equ RESETS_RESET, 0x4000C000
