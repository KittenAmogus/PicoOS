#include <drivers/kbd.h>
#include <stdio.h>

static FILE keyboard_stream = {0};
kbd_t kbd_matrix[4];

static int kbd_write(int fd, const char *buffer, size_t count) { return -1; }

static int kbd_read(int fd, char *buffer, size_t count) { return 0; }

void kbd_update(void);

void kbd_init(void) {
  keyboard_stream.read = kbd_read;
  keyboard_stream.write = kbd_write;
}

FILE *kbd_stream(void) { return &keyboard_stream; }
