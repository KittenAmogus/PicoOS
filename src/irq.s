.cpu cortex-m0plus
.thumb

.section .text

.align 2
.global _irq_handler
_irq_handler:
  bl powerdown

.align 2
.global _nmi_handler
_nmi_handler:
  bl powerdown

.align 2
.global _hardfault_handler
_hardfault_handler:
  bl powerdown

.align 2
.global _svcall_handler
_svcall_handler:
  bl powerdown

.align 2
.global _pendsv_handler
_pendsv_handler:
  bl powerdown

.align 2
.global _systick_handler
_systick_handler:
  bl powerdown
