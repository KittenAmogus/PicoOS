.syntax unified
.cpu cortex-m0plus
.thumb

.section .vectors, "a", %progbits
.align 2
.global _vectors
_vectors:
  .word __stack_core0_top
  .word Reset_Handler
  .word NMI_Handler
  .word HardFault_Handler
  .word 0, 0, 0, 0, 0, 0, 0
  .word SVC_Handler
  .word 0, 0
  .word PendSV_Handler
  .word SysTick_Handler

// IRQ 0..31
  .word TIMER_IRQ_0_Handler
  .word TIMER_IRQ_1_Handler
  .word TIMER_IRQ_2_Handler
  .word TIMER_IRQ_3_Handler
  .word PWM_IRQ_WRAP_Handler
  .word USBCTRL_IRQ_Handler
  .word XIP_IRQ_Handler
  .word PIO0_IRQ_0_Handler
  .word PIO0_IRQ_1_Handler
  .word PIO1_IRQ_0_Handler
  .word PIO1_IRQ_1_Handler
  .word DMA_IRQ_0_Handler
  .word DMA_IRQ_1_Handler
  .word IO_IRQ_BANK0_Handler
  .word IO_IRQ_QSPI_Handler
  .word SIO_IRQ_PROC0_Handler
  .word SIO_IRQ_PROC1_Handler
  .word CLOCKS_IRQ_Handler
  .word SPI0_IRQ_Handler
  .word SPI1_IRQ_Handler
  .word UART0_IRQ_Handler
  .word UART1_IRQ_Handler
  .word ADC_IRQ_FIFO_Handler
  .word I2C0_IRQ_Handler
  .word I2C1_IRQ_Handler
  .word RTC_IRQ_Handler
  .word 0, 0, 0, 0, 0, 0  @ Software IRQs
