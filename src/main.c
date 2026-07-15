#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <drivers/uart.h>

extern void powerdown(void);

const char GLOBAL[] = "[TEST]";
#define GLOBALS 6

static int uart_write(int fd, const char *buffer, size_t count) {
  if (fd != 1 || buffer == NULL) {
    _uart_putbyte(0, '{', 1);
    _uart_putbyte(0, '}', 1);
    _uart_putbyte(0, '\n', 1);
    _uart_putbyte(0, '\r', 1);
    return -1;
  }

  /*
  if (buffer != GLOBAL && count > 1) {
    _uart_putbyte(0, '<', 1);
    _uart_putbyte(0, '<', 1);
    _uart_putbyte(0, '\n', 1);
    _uart_putbyte(0, '\r', 1);
    return -2;
  } else {
    _uart_putbyte(0, '>', 1);
    _uart_putbyte(0, '>', 1);
    _uart_putbyte(0, '\n', 1);
    _uart_putbyte(0, '\r', 1);
  }
  */

  while (count > 0) {
    _uart_putbyte(0, *buffer, 1);
    ++buffer;
    --count;
  }
  return count;
}

FILE _tempuart;
FILE *uart_fd(void) {
  // FILE *uart = malloc(sizeof(FILE));
  FILE *uart = &_tempuart;
  if (uart == NULL)
    return NULL;

  memset(uart, 0, sizeof(FILE));
  uart->fd = 1;
  uart->func_write = uart_write;
  return uart;
}

void kmain(void) {

  _uart_init(0, 0);

  FILE *uartio = uart_fd();

  const char *string = "Hello, World!\n\r";
  size_t len = 15; // strlen(string);
  uartio->func_write(1, string, len);
  uartio->func_write(1, GLOBAL, GLOBALS);

  fputs(GLOBAL, uartio);
  /*while (*string != 0) {
    if (fputc(*string, uartio) < 0) {
      uartio->func_write(1, "ERR, SHUTTING DOWN\n\r", 20);
      powerdown();
    }
    ++string;
  }*/
  fputs(GLOBAL, uartio);

  for (int i = 0; i < 0x16FFFFE; ++i) {
    asm volatile("nop");
  }

  powerdown();
}
