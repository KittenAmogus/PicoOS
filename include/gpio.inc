.macro gpio_init
  bl _gpio_init
.endm

.macro gpio_in mask
  ldr r0, =(\mask)
  bl _gpio_in
.endm

.macro gpio func, mask
  ldr r0, =(\mask)
  bl _gpio_\func
.endm

.macro gpio_prep mode, pin
  movs r0, \pin
  bl _gpio_prepare_\mode
.endm

