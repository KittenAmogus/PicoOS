.section .text

.struct 0
uart_dr:    .skip 4   @ Data register
            .skip 20  @ Unused
uart_fr:    .skip 4   @ Flag register
            .skip 8   @ Unused
uart_ibrd:  .skip 4   @ Integer     baud divisor
uart_fbrd:  .skip 4   @ Fractional  baud divisor
uart_lcr_h: .skip 4   @ Line control register
uart_cr:    .skip 4   @ Control register
.text

.align 2
.global _uart_init
.type _uart_init, %function
_uart_init:

// Max/min UID protection
  cmp r0, #0
  bmi .uart_init_flt
  ldr r2, =UART_MAX_UID
  cmp r2, r0
  bmi .uart_init_flt
  mov r3, r1          @ Save baudrate

// Load uart base
  lsl r0, #14         @ 0x4000 offset for each UID
  ldr r2, =UART_BASE  @ UART0_BASE
  add r2, r2, r0      @ + offset

// Disable uart
  mov r1, #0                @ Zero (disable)
  str r1, [r2, #uart_cr]    @ Store to CR

// Set baudrate
  mov r1, #67               @ TODO Remove hardcode
  str r1, [r2, #uart_ibrd]  @ Integer divisor
  mov r1, #52               @ TODO Remove hardcode
  str r1, [r2, #uart_fbrd]  @ Fractional divisor

// Set mode (8N1)
  mov r1, #UART_8N1_MASK    @ 8N1 mask
  str r1, [r2, #uart_lcr_h] @ Store to LCR

// Enable uart
  ldr r1, =UART_CR_ENABLE_ALL
  str r1, [r2, #uart_cr]

// Enable GPIO (TODO Remove hardcode)
  ldr r2, =IO_BANK0_BASE
  mov r1, #2                @ SIO_FUNC_UART
  str r1, [r2, #0x04]       @ GPIO 0 (TX)
  str r1, [r2, #0x0C]       @ GPIO 1 (RX)

.uart_init_end:
  mov r0, #0
  bx lr
.uart_init_flt:
  ldr r0, =MINUS1
  bx lr

.align 2
.global _uart_putbyte
.type _uart_putbyte, %function
_uart_putbyte:
  push {r4, r5, lr}
// Max/min UID protection
  cmp r0, #0
  bmi .uart_put_end
  ldr r2, =UART_MAX_UID
  cmp r2, r0
  bmi .uart_put_end

  mov r4, r1  @ Byte
  mov r5, r2  @ Block

// Load uart base
  lsl r0, #14         @ 0x4000 offset for each UID
  ldr r3, =UART_BASE  @ UART0_BASE
  add r0, r0, r3      @ + offset

// Check FIFO
  ldr r1, [r0, #uart_fr]  @ Flags
  mov r2, #32             @ 1 << 5 mask, TXFF
  tst r1, r2              @ Check if TX full
  beq .uart_put_wait      @ Not full
  mov r2, #1              @ & 1
  tst r5, r2              @ If block
  bne .uart_put_end       @ Can't write (non-blocking)

  mov r2, #32
.uart_put_wait:
  ldr r1, [r0, #uart_fr]  @ Load flags
  tst r1, r2              @ Check if full
  bne .uart_put_wait      @ repeat until free space

.uart_put_write:
  strb r4, [r0, #uart_dr] @ Write byte

.uart_put_end:
  mov r0, r4              @ Return byte
  pop {r4, r5, pc}
.uart_put_flt:
  ldr r0, =MINUS1
  pop {r4, r5, pc}


.equ MINUS1, 0xFFFFFFFF @ -1
.equ UART_MAX_UID, 1
.equ UART_BASE, 0x40034000
.equ UART_8N1_MASK, 0x70
.equ UART_CR_ENABLE_ALL, 0x301
.equ IO_BANK0_BASE, 0x40014000

