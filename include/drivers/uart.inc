.macro _init_uart uid
  mov r0, #\uid
  bl _uart_init
.endm

.macro _putchar_uart_imm uid, ch
  mov r0, #\uid
  mov r1, #\ch
  bl _uart_putchar
.endm

.macro _putchar_uart_reg uid, reg
  mov r0, #\uid
  mov r1, \reg
  bl _uart_putchar
.endm

.macro _getchar_uart, uid
  mov r0, #\uid
  bl _uart_getchar
.endm

