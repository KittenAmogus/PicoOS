.cpu cortex-m0plus
.thumb

.section .vectors, "ax"

.word __stack_top__       @ Stack pointer for PROC0
.word _reset_handler      @ Reset handler
.word _nmi_handler        @ NMI (Timeout)
.word _hardfault_handler  @ Hardfault

.word 0x00000000        @ Never firing
.word 0x00000000        @ Never firing
.word 0x00000000        @ Never firing
.word 0x00000000        @ Never firing
.word 0x00000000        @ Never firing
.word 0x00000000        @ Never firing
.word 0x00000000        @ Never firing

.word _svcall_handler   @ SVCall

.word 0x00000000        @ Never firing
.word 0x00000000        @ Never firing

.word _pendsv_handler   @ PendSV
.word _systick_handler  @ SysTick

.word _irq_handler      @ TIMER_IRQ_0
.word _irq_handler      @ TIMER_IRQ_1
.word _irq_handler      @ TIMER_IRQ_2
.word _irq_handler      @ TIMER_IRQ_3
.word _irq_handler      @ PWM_IRQ_WRAP
.word _irq_handler      @ USBCTRL_IRQ
.word _irq_handler      @ XIP_IRQ
.word _irq_handler      @ PIO0_IRQ_0
.word _irq_handler      @ PIO0_IRQ_1
.word _irq_handler      @ PIO1_IRQ_0
.word _irq_handler      @ PIO1_IRQ_1
.word _irq_handler      @ DMA_IRQ_0
.word _irq_handler      @ DMA_IRQ_1
.word _irq_handler      @ IO_IRQ_BANK0
.word _irq_handler      @ IO_IRQ_QSPI
.word _irq_handler      @ SIO_IRQ_PROC0
.word _irq_handler      @ SIO_IRQ_PROC1
.word _irq_handler      @ CLOCKS_IRQ
.word _irq_handler      @ SPI0_IRQ
.word _irq_handler      @ SPI1_IRQ
.word _irq_handler      @ UART0_IRQ
.word _irq_handler      @ UART1_IRQ
.word _irq_handler      @ ADC_IRQ_FIFO
.word _irq_handler      @ I2C0_IRQ
.word _irq_handler      @ I2C_IRQ
.word _irq_handler      @ RTC_IRQ

.word 0x00000000        @ Never firing
.word 0x00000000        @ Never firing
.word 0x00000000        @ Never firing
.word 0x00000000        @ Never firing
.word 0x00000000        @ Never firing
.word 0x00000000        @ Never firing
