#ifndef _UNISTD_H
#define _UNISTD_H

#include <stdint.h>

#ifndef NULL
#define NULL ((void *)0)
#endif

#define STDIN_FILENO 0
#define STDOUT_FILENO 1
#define STDERR_FILENO 2

int open(const char *pathname, int flags);
int close(int fd);
ssize_t read(int fd, void *buf, size_t count);
ssize_t write(int fd, const void *buf, size_t count);
int lseek(int fd, int offset, int whence);

#endif
