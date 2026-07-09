#ifndef _UART_H
#define _UART_H

#define r_UART0_DR ((volatile uint32_t *)(UART0_BASE + 0x00))
#define r_UART0_FR ((volatile uint32_t *)(UART0_BASE + 0x18))
#define r_UART0_IBRD ((volatile uint32_t *)(UART0_BASE + 0x24))
#define r_UART0_FBRD ((volatile uint32_t *)(UART0_BASE + 0x28))
#define r_UART0_LCR_H ((volatile uint32_t *)(UART0_BASE + 0x2c))
#define r_UART0_CR ((volatile uint32_t *)(UART0_BASE + 0x30))

void UART_init(int rx, int tx);
void UART_putchar(char ch);
char UART_getchar(void);

#endif // _UART_H
