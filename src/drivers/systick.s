.cpu cortex-m0plus
.thumb

.section .text

.align 2
.thumb_func
.global _systick_init_1ms
_systick_init_1ms:

// Disable SysTick
.systick_init_disable:
  ldr r0, =SYST_CSR @ Control register
  mov r1, #0        @ Zero = disable
  str r1, [r0]      @ Disable SysTick

// Setup timer
.systick_init_setup_timer:
  ldr r0, =SYST_RVR @ Reload value register
  ldr r1, =SYST_1MS_125MHZ
  str r1, [r0]      @ Store value

// Reset timer
.systick_init_reset_timer:
  ldr r0, =SYST_CVR @ Current value register
  mov r1, #0        @ Zero
  str r1, [r0]      @ Reset value

// Enable SysTick
.systick_init_enable:
  ldr r0, =SYST_CSR @ Control register
  mov r1, #0b111    @ Enable mask
  str r1, [r0]      @ Enable SysTick

.systick_init_end:
  bx lr


.align 2
.thumb_func
.global _millis
_millis:
  ldr r1, =_systick_millis  @ Load millis addr
  ldr r0, [r1]              @ Load millis
  bx lr                     @ Return millis
  nop                       @ Align to 4 bytes

.section .bss
.align 2
.global _systick_millis
_systick_millis:
  .skip 4

.equ SYST_CSR,    0xe000e010
.equ SYST_RVR,    0xe000e014
.equ SYST_CVR,    0xe000e018
.equ SYST_CALIB,  0xe000e01c

.equ SYST_1MS_125MHZ, 0x0001E847

