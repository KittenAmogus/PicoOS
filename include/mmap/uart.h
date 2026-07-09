#ifndef _MMAP_UART_H
#define _MMAP_UART_H

#include <stdint.h>

/* ===========================================
 * UART (0x40034000, 0x40038000)
 * =========================================== */

#define UART_BASE(uid) (0x40034000 + (uid << 14))

#define UARTDR(uid) (UART_BASE(uid) + 0x000) /* Data Register, UARTDR */
#define UARTRSR(uid)                                                           \
  (UART_BASE(uid) +                                                            \
   0x004) /* Receive Status Register/Error Clear Register, UARTRSR/UARTECR */
#define UARTFR(uid) (UART_BASE(uid) + 0x018) /* Flag Register, UARTFR */
#define UARTILPR(uid)                                                          \
  (UART_BASE(uid) + 0x020) /* IrDA Low-Power Counter Register, UARTILPR */
#define UARTIBRD(uid)                                                          \
  (UART_BASE(uid) + 0x024) /* Integer Baud Rate Register, UARTIBRD */
#define UARTFBRD(uid)                                                          \
  (UART_BASE(uid) + 0x028) /* Fractional Baud Rate Register, UARTFBRD */
#define UARTLCR_H(uid)                                                         \
  (UART_BASE(uid) + 0x02c) /* Line Control Register, UARTLCR_H */
#define UARTCR(uid) (UART_BASE(uid) + 0x030) /* Control Register, UARTCR */
#define UARTIFLS(uid)                                                          \
  (UART_BASE(uid) + 0x034) /* Interrupt FIFO Level Select Register, UARTIFLS   \
                            */
#define UARTIMSC(uid)                                                          \
  (UART_BASE(uid) + 0x038) /* Interrupt Mask Set/Clear Register, UARTIMSC */
#define UARTRIS(uid)                                                           \
  (UART_BASE(uid) + 0x03c) /* Raw Interrupt Status Register, UARTRIS */
#define UARTMIS(uid)                                                           \
  (UART_BASE(uid) + 0x040) /* Masked Interrupt Status Register, UARTMIS */
#define UARTICR(uid)                                                           \
  (UART_BASE(uid) + 0x044) /* Interrupt Clear Register, UARTICR */
#define UARTDMACR(uid)                                                         \
  (UART_BASE(uid) + 0x048) /* DMA Control Register, UARTDMACR */
#define UARTPERIPHID0(uid) (UART_BASE(uid) + 0xfe0) /* UARTPeriphID0 Register  \
                                                     */
#define UARTPERIPHID1(uid) (UART_BASE(uid) + 0xfe4) /* UARTPeriphID1 Register  \
                                                     */
#define UARTPERIPHID2(uid) (UART_BASE(uid) + 0xfe8) /* UARTPeriphID2 Register  \
                                                     */
#define UARTPERIPHID3(uid) (UART_BASE(uid) + 0xfec) /* UARTPeriphID3 Register  \
                                                     */
#define UARTPCELLID0(uid) (UART_BASE(uid) + 0xff0)  /* UARTCellID0 Register */
#define UARTPCELLID1(uid) (UART_BASE(uid) + 0xff4)  /* UARTCellID1 Register */
#define UARTPCELLID2(uid) (UART_BASE(uid) + 0xff8)  /* UARTCellID2 Register */
#define UARTPCELLID3(uid) (UART_BASE(uid) + 0xffc)  /* UARTCellID3 Register */

#endif // _MMAP_UART_H
