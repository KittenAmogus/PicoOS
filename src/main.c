#include <stdio.h>

#include <stdlib.h>
#include <uart_file.h>

void kmain(void) {
  k_mem_init();
  k_stdio_init();

  puts("Hello, World!\r");
  puts("> MV FILE0 /MNT/SD/FILE0\r");

  for (;;) {
    /* Loop */
  }
}
