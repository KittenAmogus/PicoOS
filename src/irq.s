.cpu cortex-m0plus
.thumb

.section .text

.align 2
.global _irq_handler
_irq_handler:
  blx powerdown

.align 2
.global _nmi_handler
_nmi_handler:
  blx powerdown

.align 2
.global _hardfault_handler
_hardfault_handler:
  blx powerdown

.align 2
.global _svcall_handler
_svcall_handler:
  blx powerdown

.align 2
.global _pendsv_handler
_pendsv_handler:
  blx powerdown

.align 2
.global _systick_handler
_systick_handler:
  blx powerdown
