.syntax unified
.cpu cortex-m0plus
.thumb

/* ========================================================================
 * BOOT 2
   ======================================================================== */
.section .boot2, "ax"
.incbin "boot2/boot2.bin"

/* ========================================================================
 * INTERRUPT VECTOR TABLE
   ======================================================================== */
.section .vectors, "ax"
.align 2

.global __vectors
__vectors:
  .word _estack            /* 0: Stack Pointer */
  .word Reset_Handler      /* 1: Reset handler */
  .word NMI_Handler        /* 2: Non-masked interrupt */
  .word HardFault_Handler  /* 3: Kernel panic */

/* ========================================================================
 * RESET HANDLER
   ======================================================================== */
.section .text
.global Reset_Handler
.thumb_func
Reset_Handler:
  /* Stack */
  ldr r0, =_estack
  mov sp, r0

  /* Copy .data */
  ldr r0, =_sidata
  ldr r1, =_sdata
  ldr r2, =_edata
  cmp r1, r2
  beq .copy_data_done

.copy_data_loop:
  ldmia r0!, {r3}
  stmia r1!, {r3}
  cmp r1, r2
  blo .copy_data_loop
.copy_data_done:

  /* Reset .bss */
  ldr r1, =_sbss
  ldr r2, =_ebss
  movs r3, #0
  cmp r1, r2
  beq .clear_bss_done

.clear_bss_loop:
  stmia r1!, {r3}
  cmp r1, r2
  blo .clear_bss_loop
.clear_bss_done:

  /* C-main */
  bl kmain

  /* Infinity loop after kmain */
.infinite_loop:
  b .infinite_loop

  /* Errors */
.thumb_func
NMI_Handler:
  b NMI_Handler

.thumb_func
HardFault_Handler:
  b HardFault_Handler

