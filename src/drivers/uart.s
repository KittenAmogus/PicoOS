.cpu cortex-m0plus
.thumb
.section .text

.global _uart_init    /* uid    -> void */
.global _uart_putchar /* uid, c -> int  */
.global _uart_getchar /* uid    -> int  */

.align 2
.thumb_func
_uart_base_from_uid:
  push {r1}                 @ Save register
  ldr r1, =ls_UART_BASE_U1  @ uartX_offset
  lsl r0, r0, r1            @ uartX_offset * X
  ldr r1, =UART0_BASE       @ Base
  add r0, r0, r1            @ Base + offset
  pop {r1}                  @ Load register
  bx lr                     @ Return

.align 2
.thumb_func
_uart_init:
  push {r0, r4, lr}
  bl _uart_base_from_uid        @ Load base
  mov r4, r0                    @ Save base into r4

// Enable UART peripherals
.uart_init_enable_pers:         @ Enable UART
  ldr r0, =RESETS_BASE          @ Load base
  ldr r2, =m_RESETS_UALL        @ Unlock all UARTs mask
  mvn r2, r2                    @ ~disable_mask -> enable_mask
  ldr r1, [r0, #o_RESETS_RESET] @ Load current mask
  and r1, r1, r2                @ current & (~mask)
  str r1, [r0, #o_RESETS_RESET] @ Store new mask

// Wait for UART peripherals
  mvn r2, r2                    @ ~(~mask) -> mask
.uart_init_loop:                @ Wait for enabling
  ldr r1, [r0, #o_RESETS_DONE]  @ Load status
  and r1, r1, r2                @ status & mask
  cmp r1, r2                    @ (status & mask) == mask
  bne .uart_init_loop           @ Repeat until ready

// Set IO_FUNCSEL on pins
.uart_init_pins_io:
  ldr r0, =IO_BANK0_BASE        @ Load base
  ldr r1, =ls_IO_X0_X1          @ Load power
  pop {r2}                      @ Load uid
  push {r2}                     @ Save again
  lsl r2, r2, r1                @ Get offset
  add r0, r0, r2                @ base += offset

  ldr r1, =m_IO_UART0           @ Load func
  str r1, [r0, #0x4]            @ TX ctrl
  str r1, [r0, #0xC]            @ RX ctrl

// Set IE to RX
.uart_init_pins_pads:
  ldr r0, =PADS_BANK0_BASE      @ Load base
  ldr r1, =ls_PADS_X0_X1        @ Load power
  pop {r2}                      @ Load uid
  lsl r2, r2, r1                @ Get offset
  add r0, r0, r2                @ base += offset

  ldr r1, =m_PADS_RX            @ Load IE mask
  str r1, [r0, #0x08]           @ RX offset (1 + gpio + offset)

// Disable UART
.uart_init_disable:
  mov r1, #0                    @ Zero = disable UART
  str r1, [r4, #o_UARTCR]       @ Disable UART<uid>

// Set BAUDRATE
.uart_init_setbaud:
  ldr r1, =BAUDRATE_I_115200_125MHZ @ Baudrate I
  str r1, [r4, #o_UARTIBRD]         @ Store I
  ldr r1, =BAUDRATE_F_115200_125MHZ @ Baudrate F
  str r1, [r4, #o_UARTFBRD]         @ Store F

// Set LCR
.uart_init_lcr:
  ldr r1, =m_UARTLCR_8N1            @ Load LCR mask
  str r1, [r4, #o_UARTLCR_H]        @ Store LCR mask

// Enable UART
.uart_init_enable:
  ldr r1, =m_UARTCR                 @ Load CR mask (Enable)
  str r1, [r4, #o_UARTCR]           @ Enable UART<uid>

// Return
.uart_init_end:
  pop {r4, pc}                      @ Return

.align 2
.thumb_func
_uart_putchar:
  push {lr}
  bl _uart_base_from_uid      @ Load base

// Wait for unlock
  ldr r2, =m_UARTFR_WR_INVAL  @ Invalid mask
.uart_putchar_loop:
  ldr r3, [r0, #o_UARTFR]     @ Load status
  and r3, r2                  @ (status & mask)
  cmp r3, #0                  @ (status & mask) == 0
  bne .uart_putchar_loop      @ Wait until zero

  str r1, [r0, #o_UARTRSR]    @ Reset errors (Any value - same result)

// Putchar
.uart_putchar_putchar:
  uxtb r1, r1                 @ (char)c
  str r1, [r0, #o_UARTDR]     @ Store char

.uart_putchar_end:
  mov r0, r1                  @ Return char
  pop {pc}

.align 2
.thumb_func
_uart_getchar:
  push {lr}
  bl _uart_base_from_uid      @ Load base

// Wait for unlock
  ldr r2, =m_UARTFR_RD_INVAL  @ Invalid mask
.uart_getchar_loop:
  ldr r3, [r0, #o_UARTFR]     @ Load status
  and r3, r2                  @ (status & mask)
  cmp r3, #0                  @ (status & mask) == 0
  bne .uart_getchar_loop      @ Wait until zero

  str r1, [r0, #o_UARTRSR]    @ Reset errors (Any value - same result)

// Read char
  ldr r0, [r0, #o_UARTDR]     @ Load char from DR
  uxtb r0, r0                 @ (char)c
  pop {pc}

.equ IO_BANK0_BASE,   0x40014000
.equ o_IO_TX0_CTRL,   0x04  @ TX for UART0
.equ o_IO_RX0_CTRL,   0x0C  @ RX for UART0
.equ o_IO_X0_X1,      0x20  @ TX/RX offset from UART0 to UART1 (IO)
.equ ls_IO_X0_X1,     5     @ power of 2 of TX/RX offset from UART0 to UART1 (IO)

.equ m_IO_UART0,      0x02  @ FUNCSEL UART0
.equ m_PADS_RX,       0x40  @ PADS Input enable bit

.equ PADS_BANK0_BASE, 0x4001c000
.equ o_PADS_TX0,      0x08  @ TX for UART0
.equ o_PADS_X0_X1,    0x20  @ TX offset from UART0 to UART1 (PADS)
.equ ls_PADS_X0_X1,   5     @ power of 2 of TX offset from UART0 to UART1 (PADS)

.equ RESETS_BASE,     0x4000c000
.equ o_RESETS_RESET,  0x0   @ RESETS
.equ o_RESETS_DONE,   0x8   @ READY/DONE

.equ UART0_BASE,      0x40034000
.equ o_UART_BASE_U1,  0x00004000
.equ ls_UART_BASE_U1, 14    @ Power of 2 (1 << s_ABC) = ABC
.equ o_UARTDR,        0x000 @ Data register
.equ o_UARTRSR,       0x004 @ ECR/RSR register
.equ o_UARTFR,        0x018 @ Flag register
.equ o_UARTIBRD,      0x024 @ Integer BAUD divisor register
.equ o_UARTFBRD,      0x028 @ Fractional BAUD divisor register
.equ o_UARTLCR_H,     0x02c @ Line control register
.equ o_UARTCR,        0x030 @ Control register

.equ b_RESETS_IO_BANK0,   5
.equ b_RESETS_PADS_BANK0, 8
.equ b_RESETS_UART0,      22
.equ o_RESETS_UART1,      1 @ Offset from RESETS_UART0
.equ m_RESETS_U0,         0x400120
.equ m_RESETS_U1,         0x800120
.equ m_RESETS_UALL,       0xC00120

.equ b_UARTFR_BUSY,       3
.equ b_UARTFR_RXFE,       4
.equ b_UARTFR_TXFF,       5
.equ m_UARTFR_RD_INVAL,   0x18
.equ m_UARTFR_WR_INVAL,   0x28
.equ m_UARTFR_ALL_INVAL,  0x38

.equ b_UARTLCR_WLENH,     6
.equ b_UARTLCR_WLENL,     5
.equ b_UARTLCR_FEN,       4
.equ m_UARTLCR_8N1,       0x70

.equ b_UARTCR_RXE,        9
.equ b_UARTCR_TXE,        8
.equ b_UARTCR_UARTEN,     0
.equ m_UARTCR,            0x301

.equ BAUDRATE_I_115200_125MHZ,  67
.equ BAUDRATE_F_115200_125MHZ,  52
