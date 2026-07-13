#include <stddef.h>
#include <stdlib.h>

long strtol(const char *nptr, char **endptr, int base) {
  if (nptr == NULL)
    return 0;

  const char *s = nptr;
  long acc = 0;
  int c;
  int neg = 1; // Default multiplier for positive numbers

  // 1. Skip whitespace
  while (*s == ' ') {
    s++;
  }

  // 2. Handle sign
  if (*s == '-') {
    neg = -1;
    s++;
  } else if (*s == '+') {
    s++;
  }

  // 3. Auto-detect or validate base prefix
  if (base == 0) {
    if (*s == '0') {
      s++;
      c = *s;
      if (c == 'x' || c == 'X') {
        base = 16;
        s++;
      } else if (c == 'b' || c == 'B') {
        base = 2;
        s++;
      } else if (c == 'o' || c == 'O') {
        base = 8;
        s++;
      } else {
        base = 8; // Standard octal (just leading '0')
      }
    } else {
      base = 10;
    }
  } else if (base == 16) {
    // Skip optional 0x prefix if base 16 is explicitly set
    if (*s == '0' && (s[1] == 'x' || s[1] == 'X')) {
      s += 2;
    }
  } else if (base == 2) {
    // Skip optional 0b prefix if base 2 is explicitly set
    if (*s == '0' && (s[1] == 'b' || s[1] == 'B')) {
      s += 2;
    }
  }

  // 4. Core parsing loop
  while ((c = *s) != '\0') {
    int digit;

    // Convert ASCII char to raw value
    if (c >= '0' && c <= '9') {
      digit = c - '0';
    } else if (c >= 'A' && c <= 'Z') {
      digit = c - 'A' + 10;
    } else if (c >= 'a' && c <= 'z') {
      digit = c - 'a' + 10;
    } else {
      break; // Invalid character found
    }

    // Validate digit against base range
    if (digit >= base) {
      break;
    }

    // Calculate result: multiply accumulated value first, then add digit
    acc = (acc * base) + digit;
    s++;
  }

  // 5. Update end pointer for Shell/Vim compatibility
  if (endptr != NULL) {
    // If no digits were parsed at all, return original nptr
    *endptr = (char *)(s == nptr ? nptr : s);
  }

  // 6. Return final signed value
  return acc * neg;
}

/* Unsigned version for memory addresses and masks */
unsigned long strtoul(const char *nptr, char **endptr, int base) {
  // Reuses strtol logic but casts directly to unsigned long
  return (unsigned long)strtol(nptr, endptr, base);
}

/* Simplified wrapper for standard integer parsing */
int atoi(const char *nptr) {
  // Always uses base 10 and ignores end pointer
  return (int)strtol(nptr, NULL, 10);
}
