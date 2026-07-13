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
#define UARTPERIPHID0(uid)                                                     \
  (UART_BASE(uid) + 0xfe0) /* UARTPeriphID0 Register                           \
                            */
#define UARTPERIPHID1(uid)                                                     \
  (UART_BASE(uid) + 0xfe4) /* UARTPeriphID1 Register                           \
                            */
#define UARTPERIPHID2(uid)                                                     \
  (UART_BASE(uid) + 0xfe8) /* UARTPeriphID2 Register                           \
                            */
#define UARTPERIPHID3(uid)                                                     \
  (UART_BASE(uid) + 0xfec)                         /* UARTPeriphID3 Register   \
                                                    */
#define UARTPCELLID0(uid) (UART_BASE(uid) + 0xff0) /* UARTCellID0 Register */
#define UARTPCELLID1(uid) (UART_BASE(uid) + 0xff4) /* UARTCellID1 Register */
#define UARTPCELLID2(uid) (UART_BASE(uid) + 0xff8) /* UARTCellID2 Register */
#define UARTPCELLID3(uid) (UART_BASE(uid) + 0xffc) /* UARTCellID3 Register */

#ifndef __ASSEMBLER__

typedef union {
  struct {
    uint32_t fe : 1; /* Framing err (1 = Char had not valid stop bit (1),
                        cleared by UARTECR) */
    uint32_t pe
        : 1; /* Parity err (1 = Char parity did not match parity of CR) */
    uint32_t be : 1; /* Break err (1 = Break condition detected, rcvd data was
                        held LOW for longer than word length) */
    uint32_t oe : 1; /* Overrun err (1 = FIFO is full but data recvd) */
    uint32_t rsvd_0 : 28;      // Reserved
  } __attribute__((packed)) b; // Access as bits
  uint32_t w;                  // Access as word (32-bit)
} uart_rsr_t;

typedef union {
  struct {
    uint32_t cts : 1;          // Clear to send
    uint32_t dsr : 1;          // Data set ready
    uint32_t dcd : 1;          // Data carrier detect
    uint32_t busy : 1;         // Uart is busy
    uint32_t rxfe : 1;         // Receive FIFO is empty
    uint32_t txff : 1;         // Transmit FIFO is full
    uint32_t rxff : 1;         // Receive FIFO is full
    uint32_t txfe : 1;         // Transmit FIFO is empty
    uint32_t ri : 1;           // Ring indicator
    uint32_t rsvd_0 : 23;      // Reserved
  } __attribute__((packed)) b; // Access as bits
  uint32_t w;                  // Access as word (32-bit)
} uart_fr_t;

typedef union {
  struct {
    uint32_t brk : 1;  // Send break
    uint32_t pen : 1;  // Parity enable (1 = Enabled and generated)
    uint32_t eps : 1;  // Even parity select (0 = odd parity, 1 = even parity)
    uint32_t stp2 : 1; // 2 stop bits select (1 = Send 2 stop bits)
    uint32_t fen : 1;  // Enable FIFOs (0 = 1 byte FIFO, 1 = full FIFO)
    uint32_t wlen : 2; // Word len
    uint32_t sps : 1;  // Stick parity select (0 = Disabled)
    uint32_t rsvd_0 : 24;      // Reserved
  } __attribute__((packed)) b; // Access as bits
  uint32_t w;                  // Access as word (32-bit)
} uart_lcrh_t;

#endif // __ASSEMBLER__

#endif // _MMAP_UART_H
