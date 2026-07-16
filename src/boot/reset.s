.section .reset, "ax"
.global _reset_handler

_reset_handler:
// Setup stack
  ldr r0, =__stack_top__  @ Stack pointer for PROC0
  mov sp, r0

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
  bl kmain  @ Load C function
  bl powerdown

.align 2
.global irq_handler
irq_handler:
  b irq_handler

.align 2
.global nmi_handler
nmi_handler:
  b nmi_handler

.align 2
.global hf_handler
hf_handler:
  b hf_handler

.align 2
.global svcall_handler
svcall_handler:
  b svcall_handler

.align 2
.global pendsv_handler
pendsv_handler:
  b pendsv_handler

.align 2
.global systick_handler
systick_handler:
  b systick_handler

.align 2
.global powerdown
.type powerdown, %function
powerdown:
// Wait for FIFO to be empty
.waitcore1_loop:
  ldr r0, =SIO_FIFO_ST  @ Load FIFO addr
  ldr r2, [r0]          @ Load status
  movs r3, #2           @ Bit 1 (READY)
  and r2, r2, r3        @ Isolate bit
  beq .waitcore1_loop   @ If 0, FIFO is not ready

// Powerdown core 1
.waitcore1_done:
  ldr r0, =SIO_FIFO_WR      @ Load FIFO addr
  ldr r1, =CORE1_POWER_CMD  @ Load powerdown cmd
  str r1, [r0]              @ Send cmd

// Powerdown peripherals
  ldr r0, =RESETS_RESET @ Load RESET addr
  ldr r1, =0xFFFFFFFF   @ Disable everything mask
  str r1, [r0]          @ Disable peripherals

// Powerdown core 0
endloop:
  cpsid i   @ Disable interrupts
  wfi       @ Wait for interrupt
  b endloop @ If wfi wakes, repeat

.data
.equ RESETS_RESET, 0x4000C000
.equ SIO_FIFO_WR,  0xD0000054
.equ SIO_FIFO_ST,  0xD0000050
.equ CORE1_POWER_CMD, 0xDEADC0DE
