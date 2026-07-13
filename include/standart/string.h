#ifndef _STRING_H
#define _STRING_H

#include <stddef.h>

#ifndef NULL
#define NULL ((void *)0)
#endif

void *memset(void *s, int c, size_t n);               // DONE
void *memcpy(void *dest, const void *src, size_t n);  // DONE
void *memmove(void *dest, const void *src, size_t n); // DONE
int memcmp(const void *s1, const void *s2, size_t n); // DONE

size_t strlen(const char *s);
char *strcpy(char *dest, const char *src);              // DONE
char *strncpy(char *dest, const char *src, size_t n);   // DONE
char *strcat(char *dest, const char *src);              // DONE
int strcmp(const char *s1, const char *s2);             // DONE
int strncmp(const char *s1, const char *s2, size_t n);  // DONE
char *strchr(const char *s, int c);                     // DONE
char *strstr(const char *haystack, const char *needle); // TODO

#endif
