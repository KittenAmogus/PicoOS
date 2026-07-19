.include "util/gpio.inc"

.cpu cortex-m0plus
.thumb

.section .text

.align 2
.thumb_func
.global _kbd_init
_kbd_init:
  push {lr}

.kbd_init_peripherals:
  ldr r0, =m_RESETS
  bl _rst_unlock_peripherals

.kbd_init_prepare_pins:
  gpio_pinmode_in   _KBD_GPIO_C0, 4 @ Prepare COLs
  gpio_pinmode_out  _KBD_GPIO_R0, 4 @ Prepare ROWs
  gpio_set          _KBD_GPIO_R0, 4 @ Disable ROWs

.kbd_init_end:
  pop {pc}

.align 2
.thumb_func
.global _kbd_update
_kbd_update:
  bx lr

.align 2
.thumb_func
.global _kbd_getchar
_kbd_getchar:
  ldr r2, =_kbd_buffer_tail_pos
  ldr r3, =_kbd_buffer_head_pos
  cmp r2, r3            @ Check if tail != head
  beq .kbd_getchar_flt  @ Return -1 if equal

.kbd_getchar_getchar:
  ldr r0, =_kbd_buffer  @ Load buffer pos
  add r0, r0, r2        @ Load char addr (buffer[tail])
  ldrb r0, [r0]         @ Load char
  uxtb r0, r0           @ (char)c

.kbd_getchar_update_tail:
  ldr r3, =_KBD_BUFFER_ANDM
  add r2, r2, #1        @ tail + 1
  and r2, r2, r3        @ (tail + 1) % size
  ldr r3, =_kbd_buffer_tail_pos
  str r2, [r3]          @ tail = (tail + 1) % size

.kbd_getchar_end:
  bx lr                 @ Return char

.kbd_getchar_flt:
  mov r1, #0            @ Zero
  str r1, [r2]          @ Reset head
  str r1, [r3]          @ Reset tail
  ldr r0, =MINUS1       @ Load -1
  bx lr                 @ Return -1

.struct 0                       @ typedef struct kbd_state_t
kbd_state_last_update:  .skip 4 @ Last update time in ms
kbd_state_mask_press:   .skip 4 @ Pressed mask
kbd_state_mask_event:   .skip 4 @ Event mask (!pressed -> pressed)
KBD_STATE_T_SIZE:               @ sizeof(kbd_state_t)
.text

.section .bss

.align 2
_kbd_buffer:          .skip _KBD_BUFFER_SIZE  @ Ring buffer
_kbd_buffer_head_pos: .skip 4 @ Write pos
_kbd_buffer_tail_pos: .skip 4 @ Read pos

_kbd_state:           .skip KBD_STATE_T_SIZE  @ KBD State
_kbd_press_count:     .skip 4 @ Count of press repeats
_kbd_press_button:    .skip 4 @ Last pressed button
_kbd_press_time:      .skip 4 @ Last press time in ms

.section .data
.align 2

/* === Keyboard ASCII buffer === */
/* ROW 0 */
_kbd_ascii_r0:
  .ascii  "1!?;:~"        @ Button 0
  .ascii  "ABC2@<"        @ Button 1
  .ascii  "DEF3#>"        @ Button 2
  .ascii  "\b\b\b\b\b\b"  @ Button 3 (Backspace / Cancel)

/* ROW 1 */
_kbd_ascii_r1:
  .ascii  "GHI4$\""       @ Button 4
  .ascii  "JKL5%\\"       @ Button 5
  .ascii  "MNO6^`"        @ Button 6
  .ascii  "\t\t\t\t\t\t"  @ Button 7 (Tab / Autocomplete)

/* ROW 2 */
_kbd_ascii_r2:
  .ascii  "PQRS7&"        @ Button 8
  .ascii  "TUV8*["        @ Button 9
  .ascii  "WXYZ9]"        @ Button A
  .ascii  "\n\n\n\n\n\n"  @ Button B (Enter / Confirm)

/* ROW 3 */
_kbd_ascii_r3:
  .ascii  "*+-=.,"        @ Button C
  .ascii  " 0(){}"        @ Button D
  .ascii  "/_\\|?$"       @ Button E
  .ascii  "\x15\x15\x15\x15"  @ Button F (Flush / System)
.align 2

.equ IO_BANK0_BASE,       0x40014000
.equ PADS_BANK0_GPIO0,    0x4001c000
.equ SIO_BASE,            0xd0000000
.equ o_SIO_GPIO_IN,       0x004 @ For COL
.equ o_SIO_GPIO_OUT_SET,  0x014 @ For ROW
.equ o_SIO_GPIO_OUT_CLR,  0x018 @ For ROW
.equ o_SIO_GPIO_OE_SET,   0x024 @ For ROW
.equ o_SIO_GPIO_OE_CLR,   0x028 @ For COL

.equ RESETS_BASE,         0x4000c000
.equ o_RESETS_RESET,      0x0
.equ o_RESETS_DONE,       0x8
.equ m_RESETS,            0x120

.equ _KBD_GPIO_R0,        6   @ Row start
.equ _KBD_GPIO_C0,        10  @ Col start

.equ _KBD_BUFFER_SIZE,    256 @ Ring buffer size in bytes
.equ _KBD_BUFFER_ANDM,    255 @ (pos & ANDM) = pos % SIZE
.equ _KBD_UPDATE_DELAY,   700 @ Reset press_count after X ms
.equ _KBD_DEBOUNCE_DELAY, 20  @ Ignore all updates until X ms from last update
.equ MINUS1,            0xFFFFFFFF

