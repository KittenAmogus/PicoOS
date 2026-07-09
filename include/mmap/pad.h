#ifndef _MMAP_PAD_H
#define _MMAP_PAD_H

#include <stdint.h>

/* ===========================================
 * PAD (0x4001C000)
 * =========================================== */

#define PAD_BASE 0x4001C000

#define PAD_VOLTAGE_SELECT (PAD_BASE + 0x00)
#define PAD_SWCLC (PAD_BASE + 0x080)
#define PAD_SWD (PAD_BASE + 0x84)

#define PAD_GPIO(x) (PAD_BASE + (x << 2) + 0x04)

#ifndef __ASSEMBLER__

typedef union {
  struct {
    uint32_t voltage : 1;      /* pad_voltage_e */
    uint32_t rsvd_0 : 31;      // Reserved
  } __attribute__((packed)) b; // Access as bits
  uint32_t w;                  // Access as word (32-bit)
} pad_voltage_t;

typedef union {
  struct {
    uint32_t slewfast : 1; /* Slew rate ctrl (1 = FAST, 0 = SLOW) */
    uint32_t schmitt : 1;  /* Enable schmitt trigger */
    uint32_t pde : 1;      /* Pulldown enable */
    uint32_t pue : 1;      /* Pullup enable */
    uint32_t drive : 2;    /* pad_gpio_drive_e */
    uint32_t ie : 1;       /* Enable input */
    uint32_t od
        : 1; /* Disable output (Priority over enable from peripherals) */
    uint32_t rsvd_0 : 24;      // Reserved
  } __attribute__((packed)) b; // Access as bits
  uint32_t w;                  // Access as word (32-bit)
} pad_t;

typedef enum {
  PAD_VOLTAGE_3V3 = 0b0,
  PAD_VOLTAGE_1V8 = 0b1,
} pad_voltage_e;

typedef enum {
  PAD_DRIVE_2MA = 0b00,
  PAD_DRIVE_4MA = 0b01,
  PAD_DRIVE_8MA = 0b10,
  PAD_DRIVE_12MA = 0b11,
} pad_gpio_drive_e;

/*
typedef enum {
  GPIO_QSPI_VOLTAGE_SELECT = 0x00,
  GPIO_QSPI_SCLK = 0x04,
  GPIO_QSPI_SD0 = 0x08,
  GPIO_QSPI_SD1 = 0x0C,
  GPIO_QSPI_SD2 = 0x10,
  GPIO_QSPI_SD3 = 0x14,
  GPIO_QSPI_SS = 0x18,
} pad_qspi_bank;
* TODO: Move to qspi.h
*/

#endif // __ASSEMBLER__

#endif // _MMAP_PAD_H
