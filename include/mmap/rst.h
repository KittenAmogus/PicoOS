#ifndef _MMAP_RST_H
#define _MMAP_RST_H

#include <stdint.h>

/* ===========================================
 * RESETS (0x4000C000)
 * =========================================== */

#define RESETS_BASE 0x4000C000

/* === RESETS === */
#define RESETS_RESET (RESETS_BASE + 0x0)
#define RESETS_WDSEL (RESETS_BASE + 0x4)
#define RESETS_DONE (RESETS_BASE + 0x8)

typedef union {
  struct {
    uint32_t ADC : 1;
    uint32_t BUSCTRL : 1;
    uint32_t DMA : 1;
    uint32_t I2C0 : 1;
    uint32_t I2C1 : 1;
    uint32_t IO_BANK0 : 1;
    uint32_t IO_QSPI : 1;
    uint32_t JTAG : 1;
    uint32_t PADS_BANK0 : 1;
    uint32_t PADS_QSPI : 1;
    uint32_t PIO0 : 1;
    uint32_t PIO1 : 1;
    uint32_t PLL_SYS : 1;
    uint32_t PLL_USB : 1;
    uint32_t PWM : 1;
    uint32_t RTC : 1;
    uint32_t SPI0 : 1;
    uint32_t SPI1 : 1;
    uint32_t SYSCFG : 1;
    uint32_t SYSINFO : 1;
    uint32_t TBMAN : 1;
    uint32_t TIMER : 1;
    uint32_t UART0 : 1;
    uint32_t UART1 : 1;
    uint32_t USBCTRL : 1;
    uint32_t rsvd : 8;         // Reserved
  } __attribute__((packed)) b; // Access as bits
  uint32_t w;                  // Access as word (32-bit)
} resets_mask_t;

#endif // _MMAP_RST_H
