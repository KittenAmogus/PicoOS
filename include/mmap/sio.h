#ifndef _MMAP_SIO_H
#define _MMAP_SIO_H

#include <stdint.h>

/* ===========================================
 * SIO (0xD0000000)
 * =========================================== */

#define SIO_BASE 0xD0000000

#define r_SIO_SET ((volatile uint32_t *)((char *)SIO_BASE + 0x014))
#define r_SIO_CLR ((volatile uint32_t *)((char *)SIO_BASE + 0x018))
#define r_SIO_XOR ((volatile uint32_t *)((char *)SIO_BASE + 0x01C))
#define r_SIO_OE_SET ((volatile uint32_t *)((char *)SIO_BASE + 0x024))
#define r_SIO_OE_CLR ((volatile uint32_t *)((char *)SIO_BASE + 0x028))
#define r_SIO_OE_XOR ((volatile uint32_t *)((char *)SIO_BASE + 0x02C))

#define SIO_SET_GPIO(x) (*r_SIO_SET = (1 << x))
#define SIO_CLR_GPIO(x) (*r_SIO_CLR = (1 << x))
#define SIO_XOR_GPIO(x) (*r_SIO_XOR = (1 << x))
#define SIO_OE_SET_GPIO(x) (*r_SIO_OE_SET = (1 << x))
#define SIO_OE_CLR_GPIO(x) (*r_SIO_OE_CLR = (1 << x))
#define SIO_OE_XOR_GPIO(x) (*r_SIO_OE_XOR = (1 << x))

#endif // _MMAP_SIO_H
