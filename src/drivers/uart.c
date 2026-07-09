#include <drivers/mmap.h>
#include <drivers/uart.h>

void UART_init(int rx, int tx) {
  uint32_t mask = (1 << BIT_RESET_UART0);
  *r_RESETS_RESET &= ~mask;

  /* Enable SIO on UART TX/RX */
  *r_GPIO_CTRL(0) = FUNC_UART;
  *r_GPIO_CTRL(1) = FUNC_UART;

  /* IO modes */
  *r_PAD_CTRL(1) = (1 << BIT_PAD_IN_ENABLE);

  /* Setup */
  *r_UART0_CR = 0;                              // Disable UART
  *r_UART0_IBRD = 6;                            // 115200 if 12MHz
  *r_UART0_FBRD = 33;                           // 115200 if 12MHz
  *r_UART0_LCR_H = (1 << 4) | (3 << 5);         // 8N1
  *r_UART0_CR = (1 << 0) | (1 << 8) | (1 << 9); // TX, RX, ENABLE
}

void UART_putchar(char ch) {
  while ((*r_UART0_FR & (1 << 5)) == (1 << 5))
    ;

  *r_UART0_DR = ch;
}

char UART_getchar(void);
