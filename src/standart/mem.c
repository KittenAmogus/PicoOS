#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#warning "src/standart/mem.c -- hardcoded mem_block_t"
#define META_SIZE 20
#define OFF_SIZE 12
#define OFF_IS_FREE 16

void *calloc(size_t nmemb, size_t size) {
  size_t total;
  if (__builtin_mul_overflow(nmemb, size, &total))
    return NULL;

  void *ptr = malloc(total);

  if (ptr != NULL)
    memset(ptr, 0, total);

  return ptr;
}

void *realloc(void *ptr, size_t size) {
  if (ptr == NULL) {
    return malloc(size);
  }
  if (size == 0) {
    free(ptr);
    return NULL;
  }

  size = (size + 3) & 0xFFFFFFFC;

  uint8_t *block = (uint8_t *)ptr - META_SIZE;
  size_t current_size = *(size_t *)(block + OFF_SIZE);

  if (current_size >= size) {
    return ptr;
  }

  void *new_ptr = malloc(size);
  if (new_ptr == NULL) {
    return NULL;
  }

  memcpy(new_ptr, ptr, current_size);
  free(ptr);
  return new_ptr;
}

void *reallocarray(void *ptr, size_t n, size_t size) {
  size_t total_size;

  if (__builtin_mul_overflow(n, size, &total_size)) {
    return NULL;
  }

  return realloc(ptr, total_size);
}
