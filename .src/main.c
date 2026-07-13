#include <mmap/gpio.h>
#include <mmap/pad.h>
#include <mmap/ppb.h>
#include <mmap/rst.h>
#include <mmap/sio.h>
#include <mmap/uart.h>

#include <stdio.h>
#include <stdlib.h>

#include <drivers/uart.h>

extern void powerdown(void);

void kmain(void) {
  // powerdown();

  // Init LED
  resets_mask_t *rmask = (resets_mask_t *)RESETS_RESET;
  resets_mask_t *dmask = (resets_mask_t *)RESETS_DONE;
  rmask->b.IO_BANK0 = 0;
  rmask->b.PADS_BANK0 = 0;

  while (dmask->b.IO_BANK0 == 0 || dmask->b.PADS_BANK0 == 0) {
    asm volatile("nop");
  }

  gpio_ctrl_t *ctrl = (gpio_ctrl_t *)GPIO_CTRL(4);
  ctrl->w = 0;
  ctrl->b.funcsel = FUNC_SIO;

  ctrl = (gpio_ctrl_t *)GPIO_CTRL(5);
  ctrl->w = 0;
  ctrl->b.funcsel = FUNC_SIO;

  ctrl = (gpio_ctrl_t *)GPIO_CTRL(0);
  ctrl->w = 0;
  ctrl->b.funcsel = FUNC_UART;

  ctrl = (gpio_ctrl_t *)GPIO_CTRL(1);
  ctrl->w = 0;
  ctrl->b.funcsel = FUNC_UART;

  pad_t *pad = (pad_t *)PAD_GPIO(1);
  pad->b.ie = 1;
  pad->b.pue = 1;

  SIO_OE_SET_GPIO(4);
  SIO_OE_CLR_GPIO(5);

  pad = (pad_t *)PAD_GPIO(5);
  pad_t cpad;

  cpad.w = pad->w;
  cpad.b.pue = 1;
  cpad.b.pde = 0;
  cpad.b.ie = 1;
  pad->w = cpad.w;

  k_mem_init();
  k_stdio_init();

  uart_init(0);

  extern int uart_putchar(int uid, char c);

  uart_putchar(0, 'a');
  uart_putchar(0, '\n');
  uart_putchar(0, '\r');

  FILE *uart0 = uart_stream(0);
  uart0->fd = 1;
  if (k_register_stream(uart0) != 0) {
    uart_putchar(0, 'Z');
    uart_putchar(0, '\n');
    uart_putchar(0, '\r');
    for (;;)
      ;
  } else {
    uart_putchar(0, 'X');
    uart_putchar(0, '\n');
    uart_putchar(0, '\r');
  }

  printf("Hello, 0=%d, 10=%d, 20=%d, 11=%d, 21=%d\n\r", 0, 10, 20, 11, 21);
  int iter = 0;
  for (;;) {
    printf("Hello, World! (iter=%d)\n\r", iter++);
    for (int i = 0; i < 0xB7FFFF; ++i) {
      // asm volatile("nop");
    }
  }

  return;
}
