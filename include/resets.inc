.macro rst_unlock mask
  ldr r0, =(\mask)
  bl _resets_unlock
.endm

.macro rst_lock mask
  ldr r0, =(\mask)
  bl _resets_lock
.endm

.equ b_rst_adc,       (1 << 0x00)
.equ b_rst_busctrl,   (1 << 0x01)
.equ b_rst_dma,       (1 << 0x02)
.equ b_rst_i2c0,      (1 << 0x03)
.equ b_rst_i2c1,      (1 << 0x04)
.equ b_rst_io_bank0,  (1 << 0x05)
.equ b_rst_io_qspi,   (1 << 0x06)
.equ b_rst_jtag,      (1 << 0x07)
.equ b_rst_pads_bank0,(1 << 0x08)
.equ b_rst_pads_qspi, (1 << 0x09)
.equ b_rst_pio0,      (1 << 0x0a)
.equ b_rst_pio1,      (1 << 0x0b)
.equ b_rst_pll_sys,   (1 << 0x0c)
.equ b_rst_pll_usb,   (1 << 0x0d)
.equ b_rst_pwm,       (1 << 0x0e)
.equ b_rst_rtc,       (1 << 0x0f)
.equ b_rst_spi0,      (1 << 0x10)
.equ b_rst_spi1,      (1 << 0x11)
.equ b_rst_syscfg,    (1 << 0x12)
.equ b_rst_sysinfo,   (1 << 0x13)
.equ b_rst_tbman,     (1 << 0x14)
.equ b_rst_timer,     (1 << 0x15)
.equ b_rst_uart0,     (1 << 0x16)
.equ b_rst_uart1,     (1 << 0x17)
.equ b_rst_usbctrl,   (1 << 0x18)

