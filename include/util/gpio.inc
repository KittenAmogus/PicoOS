.macro gpio_set gp, count
  mov r0, #\gp
  mov r1, #\count
  bl _gpio_set
.endm

.macro gpio_clr gp, count
  mov r0, #\gp
  mov r1, #\count
  bl _gpio_clr
.endm

.macro gpio_xor gp, count
  mov r0, #\gp
  mov r1, #\count
  bl _gpio_xor
.endm

.macro gpio_get gp, count
  mov r0, #\gp
  mov r1, #\count
  bl _gpio_get
.endm

.macro gpio_pinmode_in gp, count
  mov r0, #\gp
  mov r1, #\count
  bl _gpio_prepare_in
.endm

.macro gpio_pinmode_out gp, count
  mov r0, #\gp
  mov r1, #\count
  bl _gpio_prepare_out
.endm

