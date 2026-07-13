#include <stddef.h>
#include <stdlib.h>
#include <string.h>

char *strchr(const char *s, int c) {
  char ch = (char)c;
  while (*s != ch && *s != 0)
    ++s;
  if (ch == *s)
    return (char *)s;
  return NULL;
}

char *strstr(const char *haystack, const char *needle) {
  int needle_len = strlen(needle);
  if (needle_len < 1)
    return (char *)haystack;

  while (*haystack != 0) {
    if (strncmp(haystack, needle, needle_len) == 0) {
      return (char *)haystack;
    }
    ++haystack;
  }
  return NULL;
}

char *strdup(const char *src) {
  if (src == NULL)
    return NULL;

  int len = strlen(src);
  char *cpy = malloc(len + 1);
  if (cpy == NULL)
    return NULL;

  return strcpy(cpy, src);
}

int strsplit(char *string, char splitter, size_t n, char **split) {
  if (string == NULL || split == NULL)
    return -1;

  if (splitter == 0 || n == 0 || *string == 0) {
    split[0] = string;
    return 1;
  }

  size_t count = 0;
  do {
    split[count] = string;

    while (*string != 0 && *string != splitter)
      ++string;

    while (*string != 0 && *string == splitter) {
      *string = 0;
      ++string;
    }

    if (*string == 0)
      break;

    ++count;
  } while (count < n);

  if (n == count)
    split[count] = string;

  return count + 1;
}
