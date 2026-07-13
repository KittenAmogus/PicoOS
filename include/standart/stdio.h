#ifndef _STDIO_H
#define _STDIO_H

#include <stdarg.h>
#include <stdint.h>

#ifndef NULL
#define NULL ((void *)0)
#endif

#define EOF (-1)

typedef uint32_t fpos_t;

typedef struct _FILE FILE;

extern FILE *stdin;
extern FILE *stdout;
extern FILE *stderr;

FILE *fopen(const char *pathname, const char *mode); // TODO
int fclose(FILE *stream);                            // TODO

int fputc(int c, FILE *stream); // DONE
int fgetc(FILE *stream);        // DONE
int fflush(FILE *stream);       // DONE

int fputs(char *s, FILE *stream);             // DONE
char *fgets(char *s, int size, FILE *stream); // TODO

size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream); // TODO
size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream);        // TODO

int fseek(FILE *stream, long offset, int whence); // TODO
long ftell(FILE *stream);                         // TODO
void rewind(FILE *stream);                        // TODO

int putchar(int c);      // DONE
int getchar(void);       // DONE
int puts(const char *s); // DONE

int putc(int c, FILE *stream); // DONE
int getc(FILE *stream);        // DONE

/* TODO IN C */
int printf(const char *format, ...);
int sprintf(char *str, const char *format, ...);
int snprintf(char *str, size_t size, const char *format, ...);
int vprintf(const char *format, va_list ap);
int vsnprintf(char *str, size_t size, const char *format, va_list ap);

#endif
