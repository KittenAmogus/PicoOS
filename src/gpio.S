.syntax unified
.cpu cortex-m0plus
.thumb

.include "resets.inc"
#include "hw_regs.inc"

.macro gpio_prepare_func fnc
.global _gpio_prepare_\fnc
.type _gpio_prepare_\fnc, %function
_gpio_prepare_\fnc:

  // GPIO register
  ldr r3, =PADS_BANK0_BASE
  lsls r2, r0, #2 // pin * 4
  adds r2, r2, r3 // gpio_offset + addr

  ldr r3, =IO_BANK0_BASE
  ldr r1, =m_gpio_pad_\fnc
  str r1, [r2, #4]  // CTRL

  lsls r2, r0, #3 // pin * 8
  adds r2, r2, r3 // gpio_offset + addr
  ldr r1, =m_gpio_funcsel_SIO
  str r1, [r2, #4]  // CTRL

  ldr r3, =SIO_BASE
  movs r1, #1
  lsls r1, r1, r0 // (1 << pin)

.ifc \fnc, out  // output
  str r1, [r3, #0x18] // clear out
  str r1, [r3, #0x24] // set out enable
.else           // input
  str r1, [r3, #0x28] // set out enable
.endif

  bx lr
.endm

.macro gpio_func fnc
.global _gpio_\fnc
.type _gpio_\fnc, %function
_gpio_\fnc:
  ldr r3, =SIO_BASE
  movs r2, #o_gpio_out_\fnc
  str r0, [r3, r2]
  bx lr
.endm

.section .text.gpio, "ax", %progbits

gpio_prepare_func in
gpio_prepare_func out

gpio_func xor
gpio_func set
gpio_func clr

.equ m_gpio_pad_in, 0xda
.equ m_gpio_pad_out, 0x52

.equ o_gpio_in, 0x04
.equ o_gpio_out_set, 0x14
.equ o_gpio_out_clr, 0x18
.equ o_gpio_out_xor, 0x1c

.global _gpio_in
.type _gpio_in, %function
_gpio_in:
  ldr r3, =SIO_BASE
  ldr r2, [r3, #o_gpio_in]
  ands r0, r0, r2 // all_pins & mask
  bx lr

.section .init.gpio_init, "ax", %progbits
.global _gpio_init

.type _gpio_init, %function
_gpio_init:
  push {lr}

  // Unlock IO_BANK0 and PADS_BANK0
  rst_unlock (b_rst_io_bank0 | b_rst_pads_bank0)

  pop {pc}

.equ IO_BANK0_BASE, 0x40014000
.equ PADS_BANK0_BASE, 0x4001c000
.equ SIO_BASE, 0xd0000000
.equ m_gpio_funcsel_SIO, 5

