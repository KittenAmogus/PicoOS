.cpu cortex-m0plus
.thumb
.section .text

.align 2
.global kmain
.thumb_func
kmain:
  push {r4}

  mov r0, #0        @ UART0 uid
  bl _uart_init     @ Init UART0

  ldr r4, =PROMPT           @ Load prompt
.puts_loop:
  ldr r1, [r4]              @ Load *str
  cmp r1, #0                @ Check if 0
  beq .loop                 @ Then break
  add r4, r4, #1            @ ++str
  mov r0, #0                @ UART uid
  bl _uart_putchar          @ putchar
  b .puts_loop              @ Repeat

.loop:
  mov r0, #0                @ UART uid
  bl _uart_getchar          @ getchar
  mov r1, r0                @ Copy char
  mov r0, #0                @ UART uid
  bl _uart_putchar          @ putchar
  b .loop                   @ Repeat

  ldr r0, =DELAY_1S_125MHZ  @ Delay ticks
  bl delay                  @ delay(ticks)

  pop {r4}
  bx lr

.align 2
.thumb_func
delay:
// uint32_t ticks r0
  sub r0, r0, #1
  bne delay
.delay_done:
  bx lr


.equ DELAY_1S_133MHZ, 0x2C55555
.equ DELAY_1S_125MHZ, 0x29AAAAA

.section .data

.align 2
PROMPT:
  .asciz "UART > "

