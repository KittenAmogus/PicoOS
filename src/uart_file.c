#include <stdio.h>
#include <uart_file.h>

#include <drivers/mmap.h>
#include <drivers/uart.h>
#include <stddef.h>

FILE _uart_stream;

static int uart_read(int fd, char *buffer, size_t count) { return -1; }

static int uart_write(int fd, const char *buffer, size_t count) {
  if (buffer == NULL || fd != _uart_stream.fd)
    return -1;
  if (count == 0)
    return 0;

  size_t n = count;
  while (n > 0) {
    UART_putchar(*buffer);
    ++buffer;
    --n;
  }

  return count;
}

FILE *k_uart_create_stream(void) {
  UART_init(0, 1);
  _uart_stream.read = uart_read;
  _uart_stream.write = uart_write;
  return &_uart_stream;
}
