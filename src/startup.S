.syntax unified
.cpu cortex-m0plus
.thumb

.include "clocks.inc"
.include "gpio.inc"

.equ VTOR_ADDR, 0xe000ed08

.section .init.Reset_Handler, "ax", %progbits
.global Reset_Handler
.type Reset_Handler, %function
Reset_Handler:
// Copy vectors to ram
  ldr r0, =_siramvec  // Flash addr
  ldr r1, =_sramvec   // Start
  ldr r2, =_eramvec   // End
  bl .memcpy4

// Load ram vectors
  ldr r0, =VTOR_ADDR
  ldr r1, =_sramvec
  str r1, [r0]

// Copy data to ram
  ldr r0, =_sicore0 // Flash addr
  ldr r1, =_score0  // Start
  ldr r2, =_ecore0  // End
  bl .memcpy4

// Reset bss
  movs r0, #0           // Value
  ldr r1, =_score0_bss  // Start
  ldr r2, =_ecore0_bss  // End
  bl .memset4

  clock_init  // Clock to 125MHz

  gpio_init
  gpio_prep out, 25

.ledloop:
  gpio xor, (1 << 25)

  ldr r0, =20833333
  bl .delay
  b .ledloop

// Endloop
  cpsid i
.endloop:
  wfi
  b .endloop

.delay:
  subs r0, #1
  bne .delay
  bx lr

.memset4:
// r0 value
// r1 dest start addr
// r2 dest limit addr
  cmp r1, r2        // Compare pos to end
  bhs .memset4_end  // Exit
  str r0, [r1]      // Stor word
  adds r1, r1, #4   // Increment pointer
  b .memset4
.memset4_end:
  bx lr

.memcpy4:
// r0 src addr
// r1 dest start addr
// r2 dest limit addr
  cmp r1, r2        // Compare pos to end
  bhs .memcpy4_end  // Exit
  ldr r3, [r0]      // Load word
  str r3, [r1]      // Stor word
  adds r0, r0, #4   // Increment pointer
  adds r1, r1, #4   // Increment pointer
  b .memcpy4
.memcpy4_end:
  bx lr

.section .text.weak_handlers, "ax", %progbits
.global default_handler
.type default_handler, %function
default_handler:
  wfi
  b default_handler

// Weak handler macro
.macro def_irq handler
  .weak \handler
  .thumb_set \handler, default_handler
.endm

// def_irq Reset_Handler
def_irq NMI_Handler
def_irq HardFault_Handler
def_irq SVC_Handler
def_irq PendSV_Handler
def_irq SysTick_Handler
def_irq TIMER_IRQ_0_Handler
def_irq TIMER_IRQ_1_Handler
def_irq TIMER_IRQ_2_Handler
def_irq TIMER_IRQ_3_Handler
def_irq PWM_IRQ_WRAP_Handler
def_irq USBCTRL_IRQ_Handler
def_irq XIP_IRQ_Handler
def_irq PIO0_IRQ_0_Handler
def_irq PIO0_IRQ_1_Handler
def_irq PIO1_IRQ_0_Handler
def_irq PIO1_IRQ_1_Handler
def_irq DMA_IRQ_0_Handler
def_irq DMA_IRQ_1_Handler
def_irq IO_IRQ_BANK0_Handler
def_irq IO_IRQ_QSPI_Handler
def_irq SIO_IRQ_PROC0_Handler
def_irq SIO_IRQ_PROC1_Handler
def_irq CLOCKS_IRQ_Handler
def_irq SPI0_IRQ_Handler
def_irq SPI1_IRQ_Handler
def_irq UART0_IRQ_Handler
def_irq UART1_IRQ_Handler
def_irq ADC_IRQ_FIFO_Handler
def_irq I2C0_IRQ_Handler
def_irq I2C1_IRQ_Handler
def_irq RTC_IRQ_Handler

