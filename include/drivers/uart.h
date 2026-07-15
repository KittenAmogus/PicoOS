#ifndef _DRIVERS_UART_H
#define _DRIVERS_UART_H

#include <stddef.h>

#define _UART_UID_COUNT 2

int _uart_init(int uid, int baudrate);

void _uart_putbyte(int uid, char byte, int block);
int _uart_getbyte(int uid, int block);

#endif // _DRIVERS_UART_H
