#ifndef _STDLIB_H
#define _STDLIB_H

#include <stddef.h>

#ifndef NULL
#define NULL ((void *)0)
#endif

void *malloc(size_t size);                                        // DONE
void free(void *ptr);                                             // DONE
void *calloc(size_t nmemb, size_t size);                          // DONE
void *realloc(void *ptr, size_t size);                            // DONE
void *reallocarray(void *ptr, size_t n, size_t size);             // DONE
                                                                  //
int atoi(const char *nptr);                                       // DONE
long strtol(const char *nptr, char **endptr, int base);           // DONE
unsigned long strtoul(const char *nptr, char **endptr, int base); // DONE
                                                                  //
int rand(void);                                                   // TODO
void srand(unsigned int seed);                                    // TODO
                                                                  //
void exit(int status);                                            // TODO
int abs(int j);                                                   // DONE

#endif
