.cpu cortex-m0plus
.thumb

.section .text


.align 2
.thumb_func
_gpio_prepare:
  push {r4, r5, r6, lr}
  mov r4, r0                  @ Save gp
  mov r5, r1                  @ Save count
  mov r6, r2                  @ Save mask (in / out)

  ldr r0, =m_RESETS           @ Load mask
  bl _rst_unlock_peripherals  @ Unlock peripherals

.gpio_prepare_get_io_offset:
  ldr r0, =IO_BANK0_BASE      @ Load base
  add r0, r0, #4              @ CTRL offset
  mov r1, r4                  @ Offset multiplier
  lsl r1, r1, #3              @ Get offset
  add r0, r0, r1              @ base + offset

.gpio_prepare_get_pads_offset:
  ldr r2, =PADS_BANK0_BASE    @ Load base
  add r2, r2, #4              @ GPIO0 offset
  mov r1, r4                  @ Offset multiplier
  lsl r1, r1, #2              @ Get offset
  add r2, r2, r1              @ base + offset

// r0 -> IO_BANK0_offset
// r1 -> IO mask
// r2 -> PADS_BANK0_offset
// r3 -> unused

// r4 -> gp
// r5 -> count
// r6 -> PADS mask

  mov r1, #5                  @ IO   mask
.gpio_prepare_loop:
  str r1, [r0]                @ Store IO   mask
  str r6, [r2]                @ Store PADS mask
  add r0, r0, #8              @ Next CTRL
  add r2, r2, #4              @ Next GPIO
  sub r5, r5, #1              @ --count
  cmp r5, #0
  bne .gpio_prepare_loop  @ Repeat count times

.gpio_prepare_end:
  pop {r4, r5, r6, pc}


.align 2
.thumb_func
.global _gpio_prepare_out
_gpio_prepare_out:  // void ( uint32_t gp, uint32_t count )

.gpio_prepare_out_set_oe:
  mov r2, #1                  @ Load 1
  lsl r2, r2, r1              @ 1 << count
  sub r2, r2, #1              @ - 1
  lsl r2, r2, r0              @ ((1 << count) - 1) << gp
  ldr r3, =SIO_BASE           @ Load base
  add r3, r3, #o_SIO_GPIO_OE_SET
  str r2, [r3]                @ Set OE

  mov r2, #m_OUT
  b _gpio_prepare

.align 2
.thumb_func
.global _gpio_prepare_in
_gpio_prepare_in:  // void ( uint32_t gp, uint32_t count )
  mov r2, #m_IN
  b _gpio_prepare


.align 2
.thumb_func
.global _gpio_out_mask_to_reg
_gpio_out_mask_to_reg:
// r0 -> reg
// r1 -> mask
  ldr r2, =SIO_BASE @ Load base
  add r0, r0, r2    @ Base + offset
  str r1, [r0]      @ *reg = mask
  bx lr


.align 2
.thumb_func
.global _gpio_create_mask_to_reg
_gpio_create_mask_to_reg:
// r0 -> gp
// r1 -> count
// r2 -> reg

// Create mask from gp and count
  mov r3, #1      @ Load 1
  lsl r3, r3, r1  @ Shift by count
  sub r3, r3, #1  @ 0b1 copy count times
  lsl r3, r3, r0  @ Shift by gp

// Call func
  mov r0, r2
  mov r1, r3
  b _gpio_out_mask_to_reg

.align 2
.thumb_func
.global _gpio_set
_gpio_set:
// r0 -> gp
// r1 -> count
  ldr r2, =o_SIO_GPIO_OUT_SET
  b _gpio_create_mask_to_reg

.align 2
.thumb_func
.global _gpio_clr
_gpio_clr:
// r0 -> gp
// r1 -> count
  ldr r2, =o_SIO_GPIO_OUT_CLR
  b _gpio_create_mask_to_reg

.align 2
.thumb_func
.global _gpio_xor
_gpio_xor:
// r0 -> gp
// r1 -> count
  ldr r2, =o_SIO_GPIO_OUT_XOR
  b _gpio_create_mask_to_reg

.equ IO_BANK0_BASE,   0x40014000
.equ PADS_BANK0_BASE, 0x4001c000
.equ SIO_BASE,        0xD0000000
.equ o_SIO_GPIO_OE_SET,       0x24

.equ o_SIO_GPIO_OUT_SET,      0x14
.equ o_SIO_GPIO_OUT_CLR,      0x18
.equ o_SIO_GPIO_OUT_XOR,      0x1C

.equ m_RESETS,        0x00000120
.equ m_OUT,           0x12
.equ m_IN,            0x5A

