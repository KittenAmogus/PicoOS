.syntax unified
.cpu cortex-m0plus
.thumb

.section .text.resets, "ax", %progbits
.global _resets_unlock
.type _resets_unlock, %function
_resets_unlock:
// r0 mask
  ldr r1, =RESETS_CLR           // Atomic clear register
  str r0, [r1]                  // Stor unlock mask
  ldr r1, =RESETS_BASE          // Resets base addr
.rst_wait_unlock:               // Wait for reset
  ldr r2, [r1, #o_resets_done]  // Load ready mask
  ands r2, r2, r0               // Check if all mask is ready
  cmp r2, r0
  bne .rst_wait_unlock          // If not, repeat
  bx lr                         // Return

.global _resets_lock
.type _resets_lock, %function
_resets_lock:
// r0 mask
  ldr r1, =RESETS_SET // Atomic set register
  str r0, [r1]        // Stor lock mask
  bx lr               // Return

.struct 0
o_resets_reset: .space 4
o_resets_wdsel: .space 4
o_resets_done:  .space 4
.text

.equ RESETS_BASE, 0x4000c000
.equ RESETS_SET,  0x4000e000
.equ RESETS_CLR,  0x4000f000

