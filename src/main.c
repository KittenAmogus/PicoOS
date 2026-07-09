#include <mmap/gpio.h>
#include <mmap/pad.h>
#include <mmap/ppb.h>
#include <mmap/rst.h>
#include <mmap/sio.h>
#include <mmap/uart.h>

void kmain(void) {
  // Init LED
  resets_mask_t *rmask = (resets_mask_t *)RESETS_RESET;
  resets_mask_t *dmask = (resets_mask_t *)RESETS_DONE;
  rmask->b.IO_BANK0 = 0;
  rmask->b.PADS_BANK0 = 0;

  while (dmask->b.IO_BANK0 == 0 || dmask->b.PADS_BANK0 == 0) {
    asm volatile("nop");
  }

  gpio_ctrl_t *ctrl_4 = (gpio_ctrl_t *)GPIO_CTRL(4);
  ctrl_4->w = 0;
  ctrl_4->b.funcsel = FUNC_SIO;

  SIO_OE_SET_GPIO(4);
  for (;;) {
    for (int i = 0; i < 0xB7FFFF; ++i) {
      asm volatile("nop");
    }
    SIO_XOR_GPIO(4);
  }

  return;
}
