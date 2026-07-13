.section .text

.align 2
.global memset
memset:
/*  Params:
 *  void *dest  r0
 *  int c       r1
 *  size_t n    r2
 */

  push {r0, lr} @ Return addr

// Protection (NULL)
  and r0, r0, r0  @ Check if dest == NULL
  beq .memset_end @ Return NULL then

// Do not do anything if n == 0
  and r2, r2, r2  @ Check if n == 0
  beq .memset_end @ Return dest then

// Create copy of char (000C => CCCC)
  uxtb r1, r1     @ Remove everything except byte
  lsl r3, r1, #8  @ Copy this byte to second byte of r3
  orr r1, r1, r3  @ Copy to second byte of r1
  lsl r3, r1, #16 @ Copy these 2 bytes to r3
  orr r1, r1, r3  @ Fill remaining bytes

// Calculate word count
  lsr r3, r2, #2    @ Divide by 4
  beq .memset_end_w @ If 0 jump to bytes

// Copy words
.memset_loop_w:
  str r1, [r0]        @ Copy word to dest
  add r0, r0, #4      @ Move dest
  sub r3, r3, #1      @ --n
  bne .memset_loop_w  @ If not 0, repeat
.memset_end_w:

// Calculate byte count
  mov r3, #3        @ And mask
  and r3, r2, r3    @ & mask
  beq .memset_end   @ If 0 jump to return

// Copy bytes
.memset_loop_b:
  strb r1, [r0]       @ Copy byte to dest
  add r0, r0, #1      @ Move dest
  sub r3, r3, #1      @ --n
  bne .memset_loop_b  @ If not 0, repeat

// Return dest
.memset_end:
  pop {r0, pc}

.align 2
.global memcpy
memcpy:
/*  Params:
 *  void *dest  r0
 *  void *src   r1 (const)
 *  size_t n    r2
 */

  push {r0, r4, lr} @ Return addr

// Protection (NULL)
  and r0, r0, r0  @ Check if dest == NULL
  beq .memcpy_end @ Return NULL then

// Protection (NULL 1)
  and r1, r1, r1  @ Check if src == NULL
  beq .memcpy_flt @ Return NULL then

// Do not do anything if n == 0
  and r2, r2, r2  @ Check if n == 0
  beq .memcpy_end @ Return dest then

.memcpy_start:
// Calculate word count
  lsr r3, r2, #2    @ Divide by 4
  beq .memcpy_end_w @ If 0 jump to bytes

// Copy words
.memcpy_loop_w:
  ldr r4, [r1]        @ Load word from src
  str r4, [r0]        @ Copy word to dest
  add r0, r0, #4      @ Move dest
  add r1, r1, #4      @ Move src
  sub r3, r3, #1      @ --n
  bne .memcpy_loop_w  @ If not 0, repeat
.memcpy_end_w:

// Calculate byte count
  mov r3, #3        @ And mask
  and r3, r3, r2    @ & mask
  beq .memcpy_end   @ If 0 jump to return

// Copy bytes
.memcpy_loop_b:
  ldrb r4, [r1]       @ Load byte from src
  strb r4, [r0]       @ Copy byte to dest
  add r0, r0, #1      @ Move dest
  add r1, r1, #1      @ Move src
  sub r3, r3, #1      @ --n
  bne .memcpy_loop_b  @ If not 0, repeat
.memcpy_flt:
  mov r0, #0    @ Set it to NULL
  pop {r1, r4, pc}  @ Return NULL
.memcpy_end:
  pop {r0, r4, pc}  @ Return

.align 2
.global memmove
memove:
/*  Params:
  *  void *dest  r0
  *  void *src   r1 (const)
  *  size_t n    r2
*/
  push {r0, lr} @ Return addr

// Protection (NULL)
  and r0, r0, r0  @ Check if NULL
  beq .memmove_flt
  and r1, r1, r1  @ Check if NULL
  beq .memmove_flt

// If n == 0, do nothing
  and r2, r2, r2    @ Check if n == 0
  beq .memmove_end  @ Then return dest

// Check if src > dest (dest < src)
  sub r3, r0, r1    @ r3 = dest - src
  bmi .memcpy_start @ Use memcpy

// Check if dest >= src + n (no overlap)
  mov r3, r1
  add r3, r2        @ r3 = src + n
  sub r3, r0, r3    @ r3 = dest - (src + n)
  bpl .memcpy_start @ Use memcpy

// Offset pointers by n - 1
  add r0, r0, r2    @ dest += n
  add r1, r1, r2    @ src  += n
  sub r0, r0, #1    @ --dest
  sub r1, r1, #1    @ --src

// Copy bytes
.memmove_loop_b:
  ldrb r3, [r1]   @ Load byte from src
  strb r3, [r0]   @ Copy byte to dest
  sub r0, r0, #1  @ Move dest
  sub r1, r1, #1  @ Move src
  sub r2, r2, #1  @ --n
  bne .memmove_loop_b

.memmove_end:
  pop {r0, pc}    @ Return dest
.memmove_flt:
  mov r0, #0      @ Return NULL
  pop {r1, pc}

.align 2
.global memcmp
memcmp:
/*  Params:
  *  void *s1    r0 (const)
  *  void *s2    r1 (const)
  *  size_t n    r2
*/

  push {r4, lr} @ Return addr

// Protection (NULL)
  and r0, r0, r0  @ Check if s1 == NULL
  beq .memcmp_flt @ Return NULL then

// Protection (NULL 1)
  and r1, r1, r1  @ Check if s2 == NULL
  beq .memcmp_flt @ Return NULL then

// Do not do anything if n == 0
  and r2, r2, r2  @ Check if n == 0
  beq .memcmp_zro @ Return 0 then

// R3 now s1, R0 - compare reg
  mov r3, r0

// Compare bytes
.memcmp_loop_b:
  ldrb r0, [r3]       @ Load byte from s1
  ldrb r4, [r1]       @ Copy byte to s2
  sub r0, r0, r4      @ Compare
  bne .memcmp_end     @ Not equal
  add r3, r3, #1      @ Move s1
  add r1, r1, #1      @ Move s2
  sub r2, r2, #1      @ --n
  bne .memcmp_loop_b  @ If not 0, repeat
.memcmp_end:
  pop {r4, pc}        @ Return
.memcmp_zro:
  mov r0, #0          @ Set it to 0
  pop {r4, pc}
.memcmp_flt:
  ldr r0, =NULLFAULT  @ Return NULLFAULT
  pop {r4, pc}

.align 2
.global strcmp
strcmp:
/*  Params:
 *  void *s1    r0 (const)
 *  void *s2    r1 (const)
*/

  push {r4, lr}
// Protection (NULL)
  and r0, r0, r0  @ Check if s1 == NULL
  beq .strcmp_flt
  and r1, r1, r1  @ Check if s2 == NULL
  beq .strcmp_flt

  mov r2, r1  @ r2 = s2
  mov r1, r0  @ r1 = s1

.strcmp_loop:
  ldrb r0, [r1]   @ Load s1
  ldrb r3, [r2]   @ Load s2
  add r1, r1, #1  @ ++s1
  add r2, r2, #1  @ ++s2

// Check if not same
  mov r4, r0      @ Copy to temporary
  sub r0, r0, r3  @ Compare
  bne .strcmp_end @ Different

// Check if 0
  and r4, r4, r4    @ Fully equal
  bne .strcmp_loop  @ Repeat
  mov r0, r4        @ Restore r0
.strcmp_end:
  pop {r4, pc}  @ Return r0

.strcmp_flt:
  ldr r0, =NULLFAULT  @ Return NULLFAULT
  pop {r4, pc}

.align 2
.global strncmp
strncmp:
/*  Params:
 *  void *s1    r0 (const)
 *  void *s2    r1 (const)
 *  size_t n    r2
*/

  push {r4, r5, lr}
// Protection (NULL)
  and r0, r0, r0  @ Check if s1 == NULL
  beq .strncmp_flt
  and r1, r1, r1  @ Check if s2 == NULL
  beq .strncmp_flt

// Check if n == 0
  and r2, r2, r2  @ Check if n == 0
  beq .strncmp_zro

  mov r4, r2  @ r4 = r3
  mov r2, r1  @ r2 = s2
  mov r1, r0  @ r1 = s1

.strncmp_loop:
  ldrb r0, [r1]   @ Load s1
  ldrb r3, [r2]   @ Load s2
  add r1, r1, #1  @ ++s1
  add r2, r2, #1  @ ++s2
// Check if not same
  mov r5, r0        @ Move to temporary
  sub r0, r0, r3    @ Compare
  bne .strncmp_end  @ Different

// Check if n == 0
  sub r4, r4, #1  @ --n
  beq .strncmp_end @ Fully equal first n char

// Check if 0
  and r5, r5, r5    @ Fully equal
  bne .strncmp_loop @ Repeat
  mov r0, r5        @ Restore r0
.strncmp_end:
  pop {r4, r5, pc}  @ Return r0

.strncmp_flt:
  ldr r0, =NULLFAULT  @ Return NULLFAULT
  pop {r4, r5, pc}

.strncmp_zro:
  mov r0, #0  @ Return 0
  pop {r4, r5, pc}

.align 2
.global strlen
strlen:
  /*  Params:
  *  void *s     r0 (const)
  */

  push {lr} @ Save return addr
// Protection (NULL)
  and r0, r0, r0  @ Check if s == NULL
  beq .strlen_flt

  and r0, r0, r0 @ Check if 0
  beq .strlen_flt

  mov r1, #0      @ Counter
.strlen_loop:
  ldrb r2, [r0]   @ Load char
  and r2, r2, r2  @ If 0, return count
  beq .strlen_end
  add r1, r1, #1  @ Next char
  b .strlen_loop  @ Repeat

.strlen_end:
  mov r0, r1  @ Counter
  pop {pc}    @ Return counter
.strlen_flt:
  ldr r0, =MINUS1 @ Return -1
  pop {pc}

.align 2
.global strchr
strchr:
  /*  Params:
  *  char *str  r0  (const)
  *  int c      r1
  */
  push {lr}

// Protection
  and r0, r0, r0  @ Check if NULL
  beq .strchr_flt

// (char)c
  uxtb r1, r1     @ Remove everything except char

.strchr_loop:
  ldrb r2, [r0]   @ Load char
  cmp r2, r1      @ If == c, return
  beq .strchr_end
  and r2, r2, r2  @ If 0, return NULL
  beq .strchr_flt
  add r0, r0, #1  @ ++str
  b .strchr_loop

.strchr_end:
  pop {pc}
.strchr_flt:
  mov r0, #0  @ Return NULL
  pop {pc}

.align 2
.global strcat
strcat:
  /*  Params:
  *  char *dest   r0
  *  char *src    r1 (const)
  */

  push {r0, lr}

// Protection (NULL)
  and r0, r0, r0  @ Check if NULL
  beq .strcat_flt
  and r1, r1, r1  @ Check if NULL
  beq .strcat_flt

.strcat_loop:
  ldrb r2, [r0]   @ Load char
  and r2, r2, r2  @ If 0, start copying
  beq .strcat_cpy_loop
  add r0, r0, #1  @ ++dest
  b .strcat_loop

.strcat_cpy_loop:
  ldrb r2, [r1]   @ Load char
  strb r2, [r0]   @ Copy char
  add r0, r0, #1  @ ++dest
  add r1, r1, #1  @ ++src
  and r2, r2, r2  @ If 0, break
  bne .strcat_cpy_loop

.strcat_end:
  pop {r0, pc}    @ Return dest
.strcat_flt:
  mov r0, #0      @ Return NULL
  pop {r1, pc}

.align 2
.global strcpy
strcpy:
  /*  Params:
  *  char *dest   r0
  *  char *src    r1 (const)
  */

  push {r0, lr}

// Protection (NULL)
  and r0, r0, r0  @ Check if NULL
  beq .strcpy_flt
  and r1, r1, r1  @ Check if NULL
  beq .strcpy_flt

.strcpy_loop:
  ldrb r2, [r1]   @ Load char
  strb r2, [r0]   @ Copy char
  add r0, r0, #1  @ ++dest
  add r1, r1, #1  @ ++src
  and r2, r2, r2  @ If 0, break
  bne .strcpy_loop

.strcpy_end:
  pop {r0, pc}    @ Return dest
.strcpy_flt:
  mov r0, #0      @ Return NULL
  pop {r1, pc}

.align 2
.global strncpy
strncpy:
  /*  Params:
  *  char *dest   r0
  *  char *src    r1 (const)
  *  size_t n     r2
  */

  push {r0, lr}

// Protection (NULL)
  and r0, r0, r0  @ Check if NULL
  beq .strncpy_flt
  and r1, r1, r1  @ Check if NULL
  beq .strncpy_flt

// Zero checking
  and r2, r2, r2  @ Check if n == 0
  beq .strncpy_end

// Copy everything before \0
.strncpy_loop:
  ldrb r3, [r1]   @ Load *src
  strb r3, [r0]   @ Copy to *dest
  add r0, r0, #1  @ ++dest
  add r1, r1, #1  @ ++src
  sub r2, r2, #1  @ --n
  and r2, r2, r2  @ n == 0 ? break
  beq .strncpy_end
  and r3, r3, r3  @ If == 0, copy 0s
  bne .strncpy_loop

// Fill with zeroes
  mov r3, #0      @ '\0'
.strncpy_zros:
  strb r3, [r0]   @ Copy to *dest
  add r0, r0, #1  @ ++dest
  sub r2, r2, #1  @ --n
  and r2, r2, r2  @ n == 0 ? break
  bne .strncpy_zros
.strncpy_end:
  pop {r0, pc}
.strncpy_flt:
  mov r0, #0  @ Return NULL
  pop {r1, pc}

/*
.align 2
.global strncpy
strncpy:
  *  char *dest   r0
  *  char *src    r1 (const)
  *  size_t n     r2

  push {r0, lr}

// Protection (NULL)
  and r0, r0, r0  @ Check if NULL
  beq .strncpy_flt
  and r1, r1, r1  @ Check if NULL
  beq .strncpy_flt

// If n == 0, do nothing
  and r2, r2, r2    @ Check if n == 0
  beq .strncpy_end  @ Then return dest

.strncpy_loop_nz:
  ldrb r3, [r1]   @ Load char
.strncpy_loop:
  strb r3, [r0]   @ Copy char
  add r0, r0, #1  @ ++dest
  add r1, r1, #1  @ ++src
  sub r2, r2, #1  @ If n == 0, break
  beq .strncpy_end
  and r3, r3, r3        @ If > 0, continue
  bne .strncpy_loop_nz
  mov r3, #0            @ Else, fill with 0
  b .strncpy_loop

.strncpy_end:
  pop {r0, pc}    @ Return dest
.strncpy_flt:
  mov r0, #0      @ Return NULL
  pop {r1, pc}
*/

.align 4
.equ NULLFAULT, 0x80000000
.equ MINUS1,    0xFFFFFFFF
