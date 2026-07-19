.cpu cortex-m0plus
.thumb

.section .text

.align 2
.thumb_func
.global _rst_unlock_peripherals
_rst_unlock_peripherals:  // void ( uint32_t mask )
  mvn r0, r0                    @ Invert mask
  ldr r2, =RESETS_BASE          @ Load base
  ldr r1, [r2, #o_RESETS_RESET] @ Load mask
  and r1, r1, r0                @ & ~mask
  str r1, [r2, #o_RESETS_RESET] @ Store new mask

  mvn r0, r0                    @ ~~mask = mask
.rup_loop:
  ldr r1, [r2, #o_RESETS_DONE]  @ Load status
  and r1, r1, r0                @ status & mask
  cmp r1, r0                    @ == mask
  bne .rup_loop                 @ Wait until done
  bx lr                         @ Return mask (or void)

.align 2
.thumb_func
.global _rst_lock_peripherals
_rst_lock_peripherals:    // void ( uint32_t mask )
  ldr r2, =RESETS_BASE          @ Load base
  ldr r1, [r2, #o_RESETS_RESET] @ Load mask
  orr r1, r1, r0                @ | mask
  str r1, [r2, #o_RESETS_RESET] @ Store new mask
  bx lr                         @ Return mask (or void)

.equ RESETS_BASE,     0x4000c000
.equ o_RESETS_RESET,  0x0   @ RESETS
.equ o_RESETS_DONE,   0x8   @ READY/DONE

