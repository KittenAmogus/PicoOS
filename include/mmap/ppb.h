#ifndef _MMAP_PPB_H
#define _MMAP_PPB_H

#include <stdint.h>

/* ===========================================
 * PPB (0xE0000000)
 * =========================================== */

#define PPB_BASE 0x00000000

/* === SYST === */
#define PPB_SYST_CSR                                                           \
  (PPB_BASE + 0xE010) /* SysTick control and status register */
#define PPB_SYST_RVR (PPB_BASE + 0xE014) /* SysTick reload value register */
#define PPB_SYST_CVR (PPB_BASE + 0xE018) /* SysTick current value register */
#define PPB_SYST_CALIB                                                         \
  (PPB_BASE + 0xE01C) /* SysTick calibration value register */

/* === NVIC === */
#define PPB_NVIC_ISER (PPB_BASE + 0xE100) /* Interrupt set-enable register */
#define PPB_NVIC_ICER                                                          \
  (PPB_BASE + 0xE180)                     /* Interrupt clear-enable register   \
                                           */
#define PPB_NVIC_ISPR (PPB_BASE + 0xE200) /* Interrupt set-pending register */
#define PPB_NVIC_ICPR                                                          \
  (PPB_BASE + 0xE280) /* Interrupt clear-pending register                      \
                       */

#define PPB_NVIC_IPR(x)                                                        \
  (PPB_BASE + (0xE400 + (x << 2)))        /* Interrupt priority register <x> */
#define PPB_NVIC_IPR0 (PPB_BASE + 0xE400) /* Interrupt priority register 0 */
#define PPB_NVIC_IPR1 (PPB_BASE + 0xE404) /* Interrupt priority register 1 */
#define PPB_NVIC_IPR2 (PPB_BASE + 0xE408) /* Interrupt priority register 2 */
#define PPB_NVIC_IPR3 (PPB_BASE + 0xE40C) /* Interrupt priority register 3 */
#define PPB_NVIC_IPR4 (PPB_BASE + 0xE410) /* Interrupt priority register 4 */
#define PPB_NVIC_IPR5 (PPB_BASE + 0xE414) /* Interrupt priority register 5 */
#define PPB_NVIC_IPR6 (PPB_BASE + 0xE418) /* Interrupt priority register 6 */
#define PPB_NVIC_IPR7 (PPB_BASE + 0xE41C) /* Interrupt priority register 7 */

/* === PBP System === */
#define PPB_CPUID (PPB_BASE + 0xED00) /* CPUID base register */
#define PPB_ICSR (PPB_BASE + 0xED04)  /* Interrupt ctrl and state register */
#define PPB_VTOR (PPB_BASE + 0xED08)  /* Vector table offset register */
#define PPB_AIRCR                                                              \
  (PPB_BASE + 0xED0C) /* Application interrupt and reset ctrl register */
#define PPB_SCR (PPB_BASE + 0xED10)   /* System ctrl register */
#define PPB_CCR (PPB_BASE + 0xED14)   /* Config and ctrl register */
#define PPB_SHPR2 (PPB_BASE + 0xED1C) /* System handler priority register 2 */
#define PPB_SHPR3 (PPB_BASE + 0xED20) /* System handler priority register 3 */
#define PPB_SHCSR                                                              \
  (PPB_BASE + 0xED24) /* System handler ctrl and state register */

/* === MPU === */
#define PPB_MPU_TYPE (PPB_BASE + 0xED90) /* MPU type register */
#define PPB_MPU_CTRL (PPB_BASE + 0xED94) /* MPU ctrl register */
#define PPB_MPU_RNR (PPB_BASE + 0xED98)  /* MPU region num register */
#define PPB_MPU_RBAR (PPB_BASE + 0xED9C) /* MPU region base register */
#define PPB_MPU_RASR                                                           \
  (PPB_BASE + 0xEDA0) /* MPU region attr and size register                     \
                       */

#ifndef __ASSEMBLER__

typedef union {
  struct {
    uint32_t enable : 1;    // Bit 0: 1 = Counter enabled, 0 = Disable
    uint32_t tickint : 1;   // Bit 1 : 1 = Enable SysTick interrupt, 0 = Disable
    uint32_t clksource : 1; // Bit 2 : 1 = processor clock, 0 = External clokc
    uint32_t rsvd_0 : 13;   // Bits 15:3: Reserved, unchangeable
    uint32_t countflag : 1; // Bit 16: 1 = Timer counted to 0 (Read-only)
    uint32_t rsvd_1 : 15;   // Bits 31:17: Reserved
  } __attribute__((packed)) b; // Access as bits

  uint32_t w; // Access as word (32-bit)
} syst_csr_t;

typedef union {
  struct {
    uint32_t reload : 24; // Bits 23:0: Value to load into Systick current value
                          // register when counter reaches 0
    uint32_t rsvd_0 : 8;  // Bits 31:24: Reserved
  } __attribute__((packed)) b; // Access as bits
  uint32_t w;                  // Access as word (32-bit)
} syst_rvr_t;

// TODO: Add all bitmask structures for PPB

#endif // __ASSEMBLER__

#endif // _MMAP_PPB_H
