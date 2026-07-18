.section .text

.align 2
.global kmain
.thumb_func
kmain:

// Enable IO_BANK0, PAD_BANK0 and UART0
  ldr r0, =RESETS_RESET_CLR @ Clr atom register
  ldr r1, =RESETS_MASK      @ Mask
  str r1, [r0]              @ Enable peripherals

// Wait for enabling
  ldr r0, =RESETS_DONE
  ldr r2, =RESETS_MASK
.reset_loop:
  ldr r1, [r0]    @ Load status
  and r1, r1, r2  @ status & mask
  cmp r1, r2      @ (status & mask) == mask
  bne .reset_loop @ Repeat until everything ready

// Function select
  ldr r0, =GPIO4_CTRL     @ CTRL register
  ldr r1, =GPIO_FUNC_SIO  @ SIO function
  str r1, [r0]            @ Set function

// Function select
  ldr r0, =GPIO0_CTRL       @ CTRL register
  ldr r1, =GPIO_FUNC_UART0  @ SIO function
  str r1, [r0]              @ Set function

// Function select
  ldr r0, =GPIO1_CTRL       @ CTRL register
  ldr r1, =GPIO_FUNC_UART0  @ SIO function
  str r1, [r0]              @ Set function

/*
// IE mode
  ldr r0, =PAD_GPIO1_SET
  ldr r1, =IE_BIT
  str r1, [r0]
*/
// OE mode
  ldr r0, =SIO_OE_SET     @ Set atom register
  ldr r1, =SIO_GPIO4_BIT  @ GPIO4 bit
  str r1, [r0]            @ Set OE

// Disable UART
  ldr r0, =UART0_CR
  mov r1, #0
  str r1, [r0]

// Set BAUDRATE
  ldr r0, =UART0_IBRD
  ldr r1, =BAUDRATE_I
  str r1, [r0]
  ldr r0, =UART0_FBRD
  ldr r1, =BAUDRATE_F
  str r1, [r0]

// Set 8N1 mode
  ldr r0, =UART0_LCR_H
  ldr r1, =MASK_UART0_LCR_H
  str r1, [r0]

// Enable UART
  ldr r0, =UART0_CR
  ldr r1, =0x301
  str r1, [r0]

  ldr r3, =SIO_OUT_XOR    @ Set atom register
.led_loop:
  ldr r0, =DL_1S_125MHZ   @ Wait ticks
  bl delay                @ delay()
  str r1, [r3]            @ Toggle LED

// Output 'A' in UART0
  ldr r0, =UART0_FR
  ldr r1, =UART0_DR
  mov r2, #1
.uart0_loop:
  /*ldr r1, [r0]
  and r1, r1, r2
  cmp r1, r2
  bne .uart0_loop*/
  mov r1, #'A'
  str r1, [r3]

  b .led_loop

.align 2
.thumb_func
delay:
  /* R0 = ticks to delay */
  sub r0, r0, #1  @ Substract 1
  bne delay       @ = 0
  bx lr           @ return

.equ RESETS_RESET,      0x4000c000
.equ RESETS_RESET_CLR,  0x4000c000
.equ RESETS_DONE,       0x4000c008

.equ IO_BANK0_BASE,   0x40014000

.equ GPIO0_CTRL,      0x40014004
.equ GPIO0_CTRL_SET,  0x40016004
.equ GPIO0_CTRL_CLR,  0x40017004

.equ GPIO1_CTRL,      0x40014008
.equ GPIO1_CTRL_SET,  0x40016008
.equ GPIO1_CTRL_CLR,  0x40017008

.equ GPIO4_CTRL,      0x40014024
.equ GPIO4_CTRL_SET,  0x40016024
.equ GPIO4_CTRL_CLR,  0x40017024

.equ PAD_GPIO0,       0x4001C004
.equ PAD_GPIO0_SET,   0x4001D004
.equ PAD_GPIO1,       0x4001C008
.equ PAD_GPIO1_SET,   0x4001D008
.equ IE_BIT,          0x00000040

.equ SIO_BASE,        0xD0000000
.equ SIO_OUT_SET,     0xD0000014
.equ SIO_OUT_CLR,     0xD0000018
.equ SIO_OUT_XOR,     0xD000001C
.equ SIO_OE_SET,      0xD0000024
.equ SIO_OE_CLR,      0xD0000028
.equ SIO_OE_XOR,      0xD000002C
.equ SIO_GPIO4_BIT,   0x00000010

// RESETS mask for IO_BANK0, PAD_BANK0, UART0
.equ RESETS_MASK,   0x00400120

.equ DL_1S_12MHZ,     0xB7FFFF      @ Wait ~1s in 12MHz mode
.equ DL_1S_125MHZ,    0x1DCD650     @ Wait ~1s in 125MHz mode
.equ GPIO_FUNC_SIO,   5
.equ GPIO_FUNC_UART0, 2

.equ UART0_DR,    0x40034000
.equ UART0_SR,    0x40034004
.equ UART0_FR,    0x40034018
.equ UART0_IBRD,  0x40034024
.equ UART0_FBRD,  0x40034028
.equ UART0_LCR_H, 0x4003402C
.equ UART0_CR,    0x40034030

.equ BAUDRATE_I,  67
.equ BAUDRATE_F,  52

.equ MASK_UART0_LCR_H, 0x70 // WLEN=8, FIFO=1 (8N1 Mode)
