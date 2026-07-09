#ifndef _MMAP_H
#define _MMAP_H

#include <stdint.h>

#define ROM_BASE 0x00000000  /* Start of ROM */
#define XIP_BASE 0x10000000  /* Start of Flash */
#define SRAM_BASE 0x20000000 /* Start of RAM (SRAM) */
#define SRAM_END 0x20042000  /* End of RAM (SRAM) */

#define RESETS_BASE 0x4000C000
#define r_RESETS_RESET                                                         \
  ((volatile uint32_t *)(RESETS_BASE + 0x00)) /* 1 - Reset, 0 - Enable */
#define r_RESETS_XOR                                                           \
  ((volatile uint32_t *)(RESETS_BASE + 0x04)) /* Invert of resets */
#define r_RESETS_READY                                                         \
  ((volatile uint32_t *)(RESETS_BASE + 0x08)) /* Block is ready */

#define BIT_RESET_I2C1 23
#define BIT_RESET_I2C0 22
#define BIT_RESET_IO_BANK0 11   /* GPIO controller */
#define BIT_RESET_PADS_BANK0 10 /* PULL UP/DOWN */
#define BIT_RESET_SPI1 17
#define BIT_RESET_SPI0 16
#define BIT_RESET_UART1 27
#define BIT_RESET_UART0 26

#define SIO_BASE 0xD0000000

#define r_SIO_GPIO_IN                                                          \
  ((volatile uint32_t *)(SIO_BASE + 0x004)) /* All pins (in) */
#define r_SIO_GPIO_OUT                                                         \
  ((volatile uint32_t *)(SIO_BASE + 0x010)) /* All pins (out) */
#define r_SIO_GPIO_SET                                                         \
  ((volatile uint32_t *)(SIO_BASE + 0x014)) /* Enable pin */
#define r_SIO_GPIO_CLR                                                         \
  ((volatile uint32_t *)(SIO_BASE + 0x018)) /* Disable pin */
#define r_SIO_GPIO_XOR                                                         \
  ((volatile uint32_t *)(SIO_BASE + 0x01c)) /* Invert pin */
#define r_SIO_GPIO_OE                                                          \
  ((volatile uint32_t *)(SIO_BASE + 0x020)) /* 1-OUT, 0-IN */
#define r_SIO_GPIO_OE_SET                                                      \
  ((volatile uint32_t *)(SIO_BASE + 0x024)) /* Make pin OUT */
#define r_SIO_GPIO_OE_CLR                                                      \
  ((volatile uint32_t *)(SIO_BASE + 0x028)) /* Make pin IN */

#define r_SIO_FIFO_ST                                                          \
  ((volatile uint32_t *)(SIO_BASE + 0x050)) /* FIFO between Core0 and Core1 */
#define r_SIO_FIFO_WR                                                          \
  ((volatile uint32_t *)(SIO_BASE + 0x054)) /* Write FIFO                      \
                                             */
#define r_SIO_FIFO_RD                                                          \
  ((volatile uint32_t *)(SIO_BASE + 0x058)) /* Read FIFO                       \
                                             */

#define BIT_FIFO_ST_VLD 0 /* Can read */
#define BIT_FIFO_ST_RDY 1 /* Can write */

#define r_SIO_CPUID                                                            \
  ((volatile uint32_t *)(SIO_BASE + 0x000)) /* Get core id                     \
                                             */

#define IO_BANK0_BASE 0x40014000
#define r_GPIO_CTRL(pin)                                                       \
  ((volatile uint32_t *)(IO_BANK0_BASE + 0x04 +                                \
                         ((pin) * 8))) /* Pin functions */

#define FUNC_SPI 1
#define FUNC_UART 2
#define FUNC_I2C 3
#define FUNC_SIO 5 /* Digital */

#define PADS_BANK0_BASE 0x4001c000
#define r_PAD_CTRL(pin)                                                        \
  ((volatile uint32_t *)(PADS_BANK0_BASE + 0x04 + ((pin) * 4))) /* PULL */

#define BIT_PAD_PULLUP 3    /* 1 - Pull to 3.3V */
#define BIT_PAD_PULLDOWN 2  /* 1 - Pull to GND (0) */
#define BIT_PAD_IN_ENABLE 6 /* 1 - Input */

#define TIMER_BASE 0x40054000
#define r_TIMER_TIMEH ((volatile uint32_t *)(TIMER_BASE + 0x0c)) /* Millis */
#define r_TIMER_TIMEL ((volatile uint32_t *)(TIMER_BASE + 0x10)) /* Micros */

#define NVIC_BASE 0xe000e100
#define r_NVIC_ISER                                                            \
  ((volatile uint32_t *)(NVIC_BASE + 0x00)) /* Enable interrupt */
#define r_NVIC_ICER                                                            \
  ((volatile uint32_t *)(NVIC_BASE + 0x80)) /* Disasble interrupt */

#define IRQ_TIMER_0 0
#define IRQ_UART0 20
#define IRQ_UART1 21
#define IRQ_SPI0 22
#define IRQ_SPI1 23
#define IRQ_I2C0 24
#define IRQ_I2C1 25

#define UART0_BASE 0x40034000
#define UART1_BASE 0x40038000

#define I2C1_BASE 0x40048000 /* HW I2C */

#define SPI1_BASE 0x40040000 /* HW SPI (1) */

#endif // _MMAP_H
