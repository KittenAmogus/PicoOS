.syntax unified
.cpu cortex-m0plus
.thumb

.section .text
.align 2

.global memset
.global memcpy
.global strcpy
.global strcat

/* ========================================================================
 * void *memset(void *dest [r0], int value [r1], size_t count [r2])
 * Returns: dest [r0]
   ======================================================================== */
.thumb_func
memset:
    push {r0, r4, lr}        @ Save original dest (r0) for return and r4

    @ 1. Duplicate byte from r1 into all 4 bytes of r1 (similar to eax replication)
    uxtb r1, r1              @ Clear upper bytes of r1, keeping only the lowest byte
    lsls r4, r1, #8          @ r4 = r1 << 8
    orrs r1, r1, r4          @ r1 |= r4 (now 2 identical bytes)
    lsls r4, r1, #16         @ r4 = r1 << 16
    orrs r1, r1, r4          @ r1 |= r4 (now all 4 bytes are identical)

    @ r0 = dest, r1 = 32-bit value, r2 = count

    @ 2. Copy by 4 bytes (Dword count)
    lsrs r3, r2, #2          @ r3 = count / 4 (number of 32-bit words)
    beq .memset_bytes        @ If 0 words, skip directly to byte copying

.memset_word_loop:
    str r1, [r0]             @ Write 4 bytes at once
    adds r0, r0, #4          @ Advance dest pointer
    subs r3, r3, #1          @ Decrement word counter
    bne .memset_word_loop

.memset_bytes:
    @ 3. Copy remaining bytes (Byte count)
    push {r0}                @ Temporary hack to clear a register for the mask
    movs r0, #3
    mov r3, r0
    pop {r0}

    ands r2, r2, r3          @ r2 = count & 3 (remaining bytes: 0, 1, 2, or 3)
    beq .memset_done

.memset_byte_loop:
    strb r1, [r0]            @ Write 1 byte
    adds r0, r0, #1          @ Advance dest pointer
    subs r2, r2, #1          @ Decrement byte counter
    bne .memset_byte_loop

.memset_done:
    pop {r0, r4, pc}         @ Restore original dest into r0 and exit

/* ========================================================================
 * void *memcpy(void *dest [r0], const void *src [r1], size_t count [r2])
 * Returns: dest [r0]
   ======================================================================== */
.thumb_func
memcpy:
    push {r0, lr}            @ Save original dest (r0) for return

    @ r0 = dest, r1 = src, r2 = count

    @ 1. Copy by 4 bytes (Dword count)
    lsrs r3, r2, #2          @ r3 = count / 4
    beq .memcpy_bytes

.memcpy_word_loop:
    ldr r2, [r1]             @ Read 4 bytes from src into r2
    str r2, [r0]             @ Write 4 bytes into dest
    adds r1, r1, #4          @ Advance src pointer
    adds r0, r0, #4          @ Advance dest pointer
    subs r3, r3, #1          @ Decrement word counter
    bne .memcpy_word_loop

.memcpy_bytes:
    @ 2. Copy remaining bytes (Byte count)
    push {r0}                @ Temporary hack to clear a register for the mask
    movs r0, #3
    mov r3, r0
    pop {r0}

    ands r2, r2, r3          @ r2 = count & 3
    beq .memcpy_done

.memcpy_byte_loop:
    ldrb r3, [r1]            @ Read 1 byte
    strb r3, [r0]            @ Write 1 byte
    adds r1, r1, #1
    adds r0, r0, #1
    subs r2, r2, #1
    bne .memcpy_byte_loop

.memcpy_done:
    pop {r0, pc}             @ Restore original dest into r0 and exit

/* ========================================================================
 * char *strcpy(char *dest [r0], const char *src [r1])
 * Returns: dest [r0]
   ======================================================================== */
.thumb_func
strcpy:
    push {r0, lr}            @ Save original dest (r0) for return

    @ r0 = dest, r1 = src

.strcpy_loop:
    ldrb r2, [r1]            @ r2 = *src
    strb r2, [r0]            @ *dest = r2
    cmp r2, #0               @ Check for null-terminator (\0)
    beq .strcpy_done

    adds r0, r0, #1          @ dest++
    adds r1, r1, #1          @ src++
    b .strcpy_loop

.strcpy_done:
    pop {r0, pc}             @ Restore original dest into r0 and exit

/* ========================================================================
 * char *strcat(char *dest [r0], const char *src [r1])
 * Returns: dest [r0]
   ======================================================================== */
.thumb_func
strcat:
    push {r0, lr}            @ Save original dest (r0) for return

    @ r0 = dest, r1 = src

.strcat_find_loop:
    ldrb r2, [r0]            @ Read byte from dest
    cmp r2, #0               @ Look for null-terminator (\0)
    beq .strcat_copy_loop

    adds r0, r0, #1          @ dest++
    b .strcat_find_loop

.strcat_copy_loop:
    ldrb r2, [r1]            @ r2 = *src
    strb r2, [r0]            @ *dest = r2
    cmp r2, #0               @ Check if null-terminator was copied
    beq .strcat_done

    adds r0, r0, #1          @ dest++
    adds r1, r1, #1          @ src++
    b .strcat_copy_loop

.strcat_done:
    pop {r0, pc}             @ Restore original dest into r0 and exit
