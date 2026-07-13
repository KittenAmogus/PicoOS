.section .text
.align 4

.global memset
memset:
  push {r0, r4, lr} @ Save l4 and return addr

// Protection
  and r0, r0, r0  @ Check if NULL
  beq .end_memset        @ Then return NULL

// Create char copy
  uxtb r1, r1     // ...C
  lsl r4, r1, #8  // ..C.
  orr r1, r1, r4  // ..CC
  lsl r4, r1, #16 // CC..
  orr r1, r1, r4  // CCCC

.words_memset:
  lsr r3, r2, #2  @ Word count
  beq .bytes      @ If 0 copy bytes
.word_loop_memset:
  str r1, [r0]    @ Write word
  add r0, r0, #4  @ Move dest
  sub r3, r3, #1  @ Word count
  bne .word_loop_memset
.bytes:
  movs r3, #3
  and r2, r2, r3  @ Byte count
  beq .end_memset        @ If 0 return
.bytes_loop_memset:
  strb r1, [r0]   @ Write byte
  add r0, r0, #1  @ Move dest
  sub r2, r2, #1  @ Byte count
  bne .bytes_loop_memset
.end_memset:
  pop {r0, r4, pc}  @ Return dest

.global memcpy
memcpy:
  push {r0, r4, lr} @ Save l4 and return addr

// Protection
  and r0, r0, r0  @ Check if NULL
  beq .end_memcpy        @ Then return NULL

  and r1, r1, r1  @ Check if NULL
  beq .end_memcpy        @ Then return NULL

.words_memcpy:
  lsr r3, r2, #2  @ Word count
  beq .bytes      @ If 0 copy bytes
.word_loop_memcpy:
  ldr r4, [r1]    @ Read word
  str r4, [r0]    @ Write word
  add r0, r0, #4  @ Move dest
  add r1, r1, #4  @ Move dest
  sub r3, r3, #1  @ Word count
  bne .word_loop_memcpy
.bytes_memcpy:
  movs r3, #3
  and r2, r2, r3  @ Byte count
  beq .end_memcpy        @ If 0 return
.bytes_loop_memcpy:
  ldrb r4, [r1]   @ Read byte
  strb r4, [r0]   @ Write byte
  add r0, r0, #1  @ Move dest
  add r1, r1, #1  @ Move dest
  sub r2, r2, #1  @ Byte count
  bne .bytes_loop_memcpy
.end_memcpy:
  pop {r0, r4, pc}  @ Return dest

.global strcpy
strcpy:
  push {r0, lr} @ Save dest and return addr

  and r0, r0, r0  @ Check if NULL
  beq .end_strcpy        @ Then return NULL

  and r1, r1, r1  @ Check if NULL
  beq .end_strcpy        @ Then return NULL

.loop_strcpy:
  ldrb r2, [r1]   @ Load byte
  strb r2, [r0]   @ Store byte
  and r2, r2, r2  @ Check if 0
  beq .end_strcpy        @ Then exit
  add r1, r1, #1  @ Next byte src
  add r0, r0, #1  @ Next byte dest

.end_strcpy:
  pop {r0, pc}  @ Return dest

.global strcat
strcat:
  push {r0, lr} @ Save dest and return addr

  and r0, r0, r0  @ Check if NULL
  beq .end_strcat        @ Then return

  and r1, r1, r1  @ Check if NULL
  beq .end_strcat        @ Then return

.findend_loop:
  ldrb r2, [r0]   @ Load byte
  and r2, r2, r2  @ Check if 0
  beq .cpy_loop   @ Then copy
  add r0, r0, #1  @ Next byte dest
  b .findend_loop
.cpy_loop:
  ldrb r2, [r1]   @ Load byte
  strb r2, [r0]   @ Store byte
  and r2, r2, r2  @ Check if 0
  beq .end_strcat        @ Return
  add r0, r0, #1  @ Next byte dest
  add r1, r1, #1  @ Next byte src
  b .cpy_loop

.end_strcat:
  pop {r0, pc}  @ Return dest

.global memcmp
memcmp:
  push {r4, lr} @ Save dest and return addr

  and r0, r0, r0  @ Check if NULL
  beq .flt_memcmp        @ Then return -1

  mov r3, r0  @ move to r3

  mov r0, #0      @ Return 0 if n == 0
  and r2, r2, r2  @ Check if n == 0
  beq .end_memcmp        @ Return

.loop_memcmp:
  ldrb r0, [r3]   @ Load *s1
  ldrb r4, [r1]   @ Load *s2
  add r3, r3, #1 @ Next byte
  add r1, r1, #1 @ Next byte
  sub r2, r2, #1 @ --n
  beq .end_memcmp       @ N == 0
  sub r0, r0, r4 @ Compare
  beq .loop_memcmp
.end_memcmp:
  pop {r4, pc}  @ Return r0
.flt_memcmp:
  ldr r0, =0xFFFFFFFF @ -1
  b .end_memcmp

.global strcmp
strcmp:
  push {lr} @ Save dest and return addr

  and r0, r0, r0  @ Check if NULL
  beq .flt_strcmp        @ Then return -1

  and r1, r1, r1  @ Check if NULL
  beq .flt_strcmp        @ Then return -1

  mov r2, r0  @ Better compare with r0
.loop_strcmp:
  ldrb r0, [r2]   @ Load *s1
  and r0, r0, r0  @ Check if 0
  beq .end_strcmp        @ Return
  ldrb r3, [r1]   @ Load *s2
  add r2, r2, #1 @ Next byte
  add r1, r1, #1 @ Next byte
.eqcheck:
  sub r0, r0, r3 @ Compare
  bne .end_strcmp
.end_strcmp:
  pop {pc}  @ Return r0
.flt_strcmp:
  ldr r0, =0xFFFFFFFF @ -1
  b .end_strcmp

.global strncmp
strncmp:
  push {r4, lr}       @ Save return address

  and r0, r0, r0      @ Check if s1 is NULL
  beq .strncmp_flt    @ If NULL, return -1
  and r1, r1, r1      @ Check if s2 is NULL
  beq .strncmp_flt    @ If NULL, return -1

  and r2, r2, r2      @ Check if remaining bytes count is 0
  beq .strncmp_zro    @ If n == 0, return 0

  mov r3, r0          @ Move s1 pointer to r3 to preserve r0 for results

.strncmp_loop:
  ldrb r0, [r3]       @ Load current byte from s1 (*s1)
  and r0, r0, r0      @ Check if it is the end of s1 ('\0')
  beq .strncmp_end    @ If s1 ended, return 0 (r0 is already 0)

  ldrb r4, [r1]       @ Load current byte from s2 (*s2) into temporary lr register

  add r3, r3, #1      @ s1++
  add r1, r1, #1      @ s2++

  sub r0, r0, r4      @ Compare bytes (r0 = *s1 - *s2)
  bne .strncmp_end    @ If they are not equal, exit and return the difference

  sub r2, r2, #1      @ n-- (decrement remaining characters counter)
  bne .strncmp_loop   @ If n is not 0, continue checking next characters

.strncmp_end:
  pop {r4, pc}            @ Return the calculated value in r0 to C-code

.strncmp_zro:
  movs r0, #0         @ If n was initially 0, standard requires returning 0
  pop {r4, pc}

.strncmp_flt:
  ldr r0, =0xFFFFFFFF @ Return -1 on bad pointer error
  pop {r4, pc}

.global strlen
strlen:
  push {lr}

  ldr r2, =0xFFFFFFFF @ Exit code if fault
  and r0, r0, r0      @ Check if NULL
  beq .end_strlen            @ Return r2

  mov r2, #0
.loop_strlen:
  ldrb r1, [r0]   @ Check byte
  and r1, r1, r1  @ Check if 0
  beq .end_strlen        @ Then return 0
  add r2, r2, #1  @ ++len
  add r0, r0, #1  @ ++str
  b .loop_strlen

.end_strlen:
  mov r0, r2  @ Return r2
  pop {pc}    @ Return

