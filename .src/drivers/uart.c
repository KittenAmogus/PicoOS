#include <drivers/uart.h>
#include <errno.h>
#include <mmap/uart.h>
#include <stddef.h>
#include <stdio.h>

static FILE uart_streams[2] = {{0}, {0}};

static int uart_setbaud(int uid, int baudrate) {
  if (baudrate < 0 || uid < 0 || uid > 1)
    return EINVAL;

  int idivisor = 67; // TODO: Remove hardcode
  int fdivisor = 44; // TODO: Remove hardcode

  *((volatile uint32_t *)UARTIBRD(uid)) = idivisor;
  *((volatile uint32_t *)UARTFBRD(uid)) = fdivisor;
  return SUCCESS;
}

static int get_uid_by_fd(int fd) {
  for (int i = 0; i < 2; ++i) {
    if (uart_streams[i].read == NULL || uart_streams[i].write == NULL)
      continue;
    if (uart_streams[i].fd == fd)
      return i;
  }
  return -1;
}

static int uart_getchar(int uid) {
  uart_rsr_t *rsr = (uart_rsr_t *)UARTRSR(uid);
  uart_fr_t *fr = (uart_fr_t *)UARTFR(uid);

  if (rsr->w > 0)
    return -1;

  while ((fr->b.busy | fr->b.rxfe) == 1)
    asm volatile("nop");

  return (int)(*(volatile uint32_t *)UARTDR(uid));
}

int uart_putchar(int uid, char c) {
  uart_rsr_t *rsr = (uart_rsr_t *)UARTRSR(uid);
  uart_fr_t *fr = (uart_fr_t *)UARTFR(uid);

  rsr->w = 0;
  while ((fr->b.busy | fr->b.txff) == 1)
    asm volatile("nop");

  *((volatile uint32_t *)UARTDR(uid)) = c;
  return (int)c;
}

static int uart_read(int fd, char *buffer, size_t count) {
  int uid = get_uid_by_fd(fd);
  if (uid < 0 || uid > 1)
    return ENODEV;

  int ch;
  while (count > 0) {
    ch = uart_getchar(uid);
    if (ch < 1)
      return EINVAL;
    *buffer = (char)ch;
    ++buffer;
    --count;
  }
  return SUCCESS;
}

static int uart_write(int fd, const char *buffer, size_t count) {
  int uid = get_uid_by_fd(fd);
  if (uid < 0 || uid > 1)
    return ENODEV;

  char ch;
  while (count > 0) {
    ch = *buffer;
    if (uart_putchar(uid, ch) < 0)
      return EINVAL;
    ++buffer;
    --count;
  }
  return SUCCESS;
}

int uart_init(int uid) {
  if (uid < 0 || uid > 1)
    return EINVAL;

  /* Already created UART */
  FILE *uart_stream = &uart_streams[uid];
  if (uart_stream->read != NULL || uart_stream->write != NULL)
    return EEXIST;

  /* Init hardware UART */
  uart_setbaud(uid, 115200); // TODO: Remove hardcode

  uart_lcrh_t *lcrh = (uart_lcrh_t *)UARTLCR_H(uid);
  uart_lcrh_t lcrh_c = *lcrh;
  lcrh_c.w = 0;
  lcrh_c.b.fen = 1;
  lcrh_c.b.wlen = 3; // 8N1
  lcrh->w = lcrh_c.w;

  /* Init software */
  uart_stream->read = uart_read;
  uart_stream->write = uart_write;
  return SUCCESS;
}

FILE *uart_stream(int uid) {
  if (uid < 0 || uid > 1)
    return NULL;
  return &(uart_streams[uid]);
}
