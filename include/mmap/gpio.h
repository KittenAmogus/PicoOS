#ifndef _MMAP_GPIO_H
#define _MMAP_GPIO_H

#include <stdint.h>

/* ===========================================
 * GPIO (0x40014000, IO_BANK0_BASE)
 * =========================================== */

#define IO_BANK0_BASE 0x40014000

#define GPIO_STATUS(x) (IO_BANK0_BASE + 0x000 + (x << 3))
#define GPIO_CTRL(x) (IO_BANK0_BASE + 0x004 + (x << 3))

#define INTR(x) (IO_BANK0_BASE + 0x0F0 + (x << 2))

#define INTR_GPIO_LVL_LOW(x, gpid)                                             \
  (((*INTR(x)) & (1 << ((gpid << 2) + 0))) >> ((gpid >> 2) + 0))
#define INTR_GPIO_LVL_HIGH(x, gpid)                                            \
  (((*INTR(x)) & (1 << ((gpid << 2) + 1))) >> ((gpid >> 2) + 1))
#define INTR_GPIO_EDG_LOW(x, gpid)                                             \
  (((*INTR(x)) & (1 << ((gpid << 2) + 2))) >> ((gpid >> 2) + 2))
#define INTR_GPIO_EDG_HIGH(x, gpid)                                            \
  (((*INTR(x)) & (1 << ((gpid << 2) + 3))) >> ((gpid >> 2) + 3))

#define PROC_INTE(proc_id, int_id)                                             \
  (IO_BANK0_BASE + 0x100 + ((proc_id << 4) + (proc_id << 5)) + (int_id << 2))

#define PROC_INTF(proc_id, int_id)                                             \
  (IO_BANK0_BASE + 0x114 + ((proc_id << 4) + (proc_id << 5)) + (int_id << 2))

#define PROC_INTS(proc_id, int_id)                                             \
  (IO_BANK0_BASE + 0x120 + ((proc_id << 4) + (proc_id << 5)) + (int_id << 2))

#define DORMANT_WAKE_INTE(int_id) (IO_BANK0_BASE + 0x160 + (int_id << 2))
#define DORMANT_WAKE_INTF(int_id) (IO_BANK0_BASE + 0x174 + (int_id << 2))
#define DORMANT_WAKE_INTS(int_id) (IO_BANK0_BASE + 0x180 + (int_id << 2))

#ifndef __ASSEMBLER__

typedef union {
  struct {
    uint32_t rsvd_0 : 8;      // Reserved
    uint32_t outfromperi : 1; /* Output signal from selected peripheral before
                                 register override is applied */
    uint32_t outtopad
        : 1; /* Output signal to pad after register override is applied */
    uint32_t rsvd_1 : 2;       // Reserved
    uint32_t oefromperi : 1;   /* Output enable from peripheral before roia */
    uint32_t oetopad : 1;      /* Output enable to pad after roia */
    uint32_t rsvd_2 : 3;       // Reserved
    uint32_t infrompad : 1;    /* Input signal from pad before roia */
    uint32_t rsvd_3 : 1;       // Reserved
    uint32_t intoperi : 1;     /* Input signal to peripheral after roia */
    uint32_t rsvd_4 : 4;       // Reserved
    uint32_t irqfrompad : 1;   /* Interrupt from pad before roia */
    uint32_t rsvd_5 : 1;       // Reserved
    uint32_t irqtoproc : 1;    /* Interrupt to processors after roia */
    uint32_t rsvd_6 : 6;       // Reserved
  } __attribute__((packed)) b; // Access as bits

  uint32_t w; // Access as word (32-bit)
} gpio_status_t;

typedef union {
  struct {
    uint32_t funcsel : 5;      /* Function select. 31 == NULL, gpio_func_e */
    uint32_t rsvd_0 : 3;       // Reserved
    uint32_t outover : 2;      /* Output overrides, gpio_out_e */
    uint32_t rsvd_1 : 2;       // Reserved
    uint32_t oeover : 2;       /* Oe overrides, gpio_oe_e */
    uint32_t rsvd_2 : 2;       // Reserved
    uint32_t inover : 2;       /* Input overrides, gpio_in_e */
    uint32_t rsvd_3 : 10;      // Reserved
    uint32_t irqover : 2;      /* Irq overrides, gpio_irq_e */
    uint32_t rsvd_4 : 2;       // Reserved
  } __attribute__((packed)) b; // Access as bits
  uint32_t w;                  // Access as word (32-bit)
} gpio_ctrl_t;

typedef enum {
  GPIO_OUT_NORMAL = 0b00,
  GPIO_OUT_INVERT = 0b01,
  GPIO_OUT_LOW = 0b10,
  GPIO_OUT_HIGH = 0b11
} gpio_out_e;

typedef enum {
  GPIO_OE_NORMAL = 0b00,
  GPIO_OE_INVERT = 0b01,
  GPIO_OE_DISABLE = 0b10,
  GPIO_OE_ENABLE = 0b11,
} gpio_oe_e;

typedef enum {
  GPIO_IN_NORMAL = 0b00,
  GPIO_IN_INVERT = 0b01,
  GPIO_IN_LOW = 0b10,
  GPIO_IN_HIGH = 0b11,
} gpio_in_e;

typedef enum {
  GPIO_IRQ_NORMAL = 0b00,
  GPIO_IRQ_INVERT = 0b01,
  GPIO_IRQ_LOW = 0b10,
  GPIO_IRQ_HIGH = 0b11,
} gpio_irq_e;

typedef enum {
  FUNC_JTAG = 0x00,
  FUNC_SPI = 0x01,
  FUNC_UART = 0x02,
  FUNC_I2C = 0x03,
  FUNC_PWM = 0x04,
  FUNC_SIO = 0x05,
  FUNC_PIO0 = 0x06,
  FUNC_PIO1 = 0x07,
  FUNC_CLOCK = 0x08,
  // TODO: Other if exist
  FUNC_NULL = 0x1F, // Disabled pin
} gpio_func_e;

#endif // __ASSEMBLER__

#endif // _MMAP_GPIO_H
