.syntax unified
.cpu cortex-m0plus
.thumb

.section .text
.global _stage2_boot
.type _stage2_boot, %function
.thumb_func
_stage2_boot:
    push {lr}
    ldr r3, =0x40020000
    movs r0, #(2 << 4 | 0x00000001)
    str r0, [r3, #0x00000004]
    ldr r0, [r3, #0x00000008]
    movs r1, #0x00000002
    bics r0, r1
    str r0, [r3, #0x00000008]
    str r0, [r3, #0x0000000c]
    str r0, [r3, #0x00000010]
    str r0, [r3, #0x00000014]
    ldr r3, =0x18000000
    movs r1, #0
    str r1, [r3, #0x00000008]
    movs r1, #2
    str r1, [r3, #0x00000014]
    movs r1, #1
    movs r2, #0x000000f0
    str r1, [r3, r2]
program_sregs:
    ldr r1, =((7 << 16) | (0x0 << 8))
    str r1, [r3, #0x00000000]
    movs r1, #1
    str r1, [r3, #0x00000008]
    movs r0, #0x35
    bl read_flash_sreg
    movs r2, #0x02
    cmp r0, r2
    beq skip_sreg_programming
    movs r1, #0x06
    str r1, [r3, #0x00000060]
    bl wait_ssi_ready
    ldr r1, [r3, #0x00000060]
    movs r1, #0x01
    str r1, [r3, #0x00000060]
    movs r0, #0
    str r0, [r3, #0x00000060]
    str r2, [r3, #0x00000060]
    bl wait_ssi_ready
    ldr r1, [r3, #0x00000060]
    ldr r1, [r3, #0x00000060]
    ldr r1, [r3, #0x00000060]
1:
    movs r0, #0x05
    bl read_flash_sreg
    movs r1, #1
    tst r0, r1
    bne 1b
skip_sreg_programming:
    movs r1, #0
    str r1, [r3, #0x00000008]
dummy_read:
    ldr r1, =((0x2 << 21) | (31 << 16) | (0x3 << 8))
    str r1, [r3, #0x00000000]
    movs r1, #0x0
    str r1, [r3, #0x00000004]
    ldr r1, =((8 << 2) | (4 << 11) | (0x2 << 8) | (0x1 << 0))
    ldr r0, =(0x18000000 + 0x000000f4)
    str r1, [r0]
    movs r1, #1
    str r1, [r3, #0x00000008]
    movs r1, #0xeb
    str r1, [r3, #0x00000060]
    movs r1, #0xa0
    str r1, [r3, #0x00000060]
    bl wait_ssi_ready
    movs r1, #0
    str r1, [r3, #0x00000008]
configure_ssi:
    ldr r1, =((0xa0 << 24) | (8 << 2) | (4 << 11) | (0x0 << 8) | (0x2 << 0))
    ldr r0, =(0x18000000 + 0x000000f4)
    str r1, [r0]
    movs r1, #1
    str r1, [r3, #0x00000008]
check_return:
    pop {r0}
    cmp r0, #0
    beq vector_into_flash
    bx r0
vector_into_flash:
    ldr r0, =(0x10000000 + 0x100)
    ldr r1, =(0xe0000000 + 0x0000ed08)
    str r0, [r1]
    ldmia r0, {r0, r1}
    msr msp, r0
    bx r1
wait_ssi_ready:
    push {r0, r1, lr}
1:
    ldr r1, [r3, #0x00000028]
    movs r0, #0x00000004
    tst r1, r0
    beq 1b
    movs r0, #0x00000001
    tst r1, r0
    bne 1b
    pop {r0, r1, pc}
.global read_flash_sreg
.type read_flash_sreg, %function
.thumb_func
read_flash_sreg:
    push {r1, lr}
    str r0, [r3, #0x00000060]
    str r0, [r3, #0x00000060]
    bl wait_ssi_ready
    ldr r0, [r3, #0x00000060]
    ldr r0, [r3, #0x00000060]
    pop {r1, pc}
.global literals
literals:
.ltorg
.end
