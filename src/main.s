.include "util/gpio.inc"
.include "drivers/uart.inc"

.cpu cortex-m0plus
.thumb
.section .text

.align 2
.global kmain
.thumb_func
kmain:
  push {r4, lr}

// Init GPIO14 to OUT
  gpio_pinmode_out  14, 1
  gpio_set          14, 1

// Init peripherals
.kmain_init_peripherals:
  _init_uart 0              @ Init UART0
  bl _systick_init_1ms      @ Init SysTick

.kmain_loop:
// Input
  _getchar_uart 0           @ Get char
  mov r1, r0                @ Copy char
  cmp r1, #'\r'             @ Check if ENTER
  beq .kmain_end            @ Shutdown then

// Output
  _putchar_uart_reg 0, r1   @ Put char
  gpio_xor 14, 1            @ Toggle LED
  b .kmain_loop             @ Repeat

.kmain_end:
  pop {r4, pc}


.align 2
.thumb_func
_delay:
  sub r0, r0, #1
  bne _delay
.delay_done:
  bx lr


.equ DELAY_1S_133MHZ, 0x2C55555
.equ DELAY_1S_125MHZ, 0x29AAAAA
