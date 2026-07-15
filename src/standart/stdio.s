.section .text

.type fputc, %function
.type fgetc, %function
.type fflush, %function
.type putc, %function
.type putchar, %function
.type fputs, %function
.type puts, %function

.struct 0
file_fd:          .skip 4 @ int         @ FILE descriptor id
file_flags:       .skip 4 @ uint32_t    @ FILE flag mask
file_buffer:      .skip 4 @ char *      @ char buffer pointer
file_read_pos:    .skip 4 @ size_t      @ Read char count
file_buffer_pos:  .skip 4 @ size_t      @ Writed char count
file_buffer_size: .skip 4 @ size_t      @ Allocated buffer size
file_func_read:   .skip 4 @ <fucntion>  @ Function to read
file_func_write:  .skip 4 @ <function>  @ Function to write
file_func_flush:  .skip 4 @ <function>  @ Function to flush
FILE_T_SIZE:              @ sizeof(FILE)
.text

.align 2
.global fputc
fputc:
// int c        r0
// FILE *stream r1

// Check c
  cmp r0, #0      @ Check if c > 0
  bmi .fputc_end  @ return

// Check stream
  cmp r1, #0      @ Check if stream != NULL
  beq .fputc_end  @ return

// Load write func
  ldr r3, [r1, #file_func_write]
  cmp r3, #0      @ Check if write != NULL
  beq .fputc_end  @ return

// Create args
  push {r0}
  ldr r0, [r1, #file_fd]  @ fd
  mov r1, sp              @ &c
  mov r2, #1              @ count = 1

// Write
  blx r3          @ Call func
  cmp r0, #1      @ Check if writed
  bne .fputc_flt

  pop {r0}        @ Load char
  bx lr           @ return (int)c
.fputc_flt:
  pop {r1}        @ Remove from stack
.fputc_end:
  ldr r0, =MINUS1 @ EOF
  bx lr

.align 2
.global fgetc
fgetc:
// FILE *stream r0

// Check stream
  cmp r0, #0      @ Check if stream != NULL
  beq .fgetc_end  @ return

// Load read func
  ldr r3, [r0, #file_func_read]
  cmp r3, #0      @ Check if read != NULL
  beq .fgetc_end  @ return

// Create args
  push {r0}
  ldr r0, [r0, #file_fd]  @ fd
  mov r1, sp              @ &c
  mov r2, #1              @ count = 1

// Write
  blx r3          @ Call func
  cmp r0, #0      @ Check if writed
  bmi .fgetc_flt

  pop {r0}        @ Load char
  uxtb r0, r0     @ (char)c
  bx lr           @ return (int)c

.fgetc_flt:
  pop {r1}        @ Remove from stack
.fgetc_end:
  ldr r0, =MINUS1 @ EOF
  bx lr

.align 2
.global fflush
fflush:
// FILE *stream r0
  push {r4}

// Check stream
  cmp r0, #0      @ Check if stream != NULL
  beq .fflush_end  @ return

// Load flush func
  ldr r3, [r0, #file_func_flush]
  cmp r3, #0      @ Check if flush != NULL
  beq .fflush_end  @ return

// Create args
  mov r4, r0              @ Save stream
  ldr r0, [r0, #file_fd]  @ fd

// Write
  blx r3          @ Call func
  cmp r0, #0      @ Check if writed
  bmi .fflush_end @ return EOF

// Reset positions
  mov r0, #0
  str r0, [r4, #file_buffer_pos]  @ Reset write pos
  str r0, [r4, #file_read_pos]    @ Reset read pos
  pop {r4}
  bx lr           @ return flush code

.fflush_end:
  pop {r4}
  ldr r0, =MINUS1 @ EOF
  bx lr

.align 2
.global fputs
fputs:
  push {r4, r5, lr}

// Protection
  cmp r0, #0  @ Check if s == NULL
  beq .fputs_flt
  cmp r1, #0  @ Check if stream == NULL
  beq .fputs_flt

  mov r4, r0
  mov r5, r1
.fputs_loop:
  ldrb r0, [r4]   @ Load *s
  cmp r0, #0      @ Check if 0
  beq .fputs_end  @ return then
  mov r1, r5      @ Load stream
  bl fputc        @ Write char
  add r4, r4, #1  @ ++s
  cmp r0, #0      @ Check if 0
  bmi .fputs_flt  @ Failed to write
  b .fputs_loop

.fputs_end:
  pop {r4, r5, pc}

.fputs_flt:
  ldr r0, =MINUS1
  pop {r4, r5, pc}

.align 2
.global putchar
putchar:
  ldr r1, =stdout @ Load stdout ptr
  ldr r1, [r1]    @ Load stdout
  b fputc

.align 2
.global getchar
getchar:
  ldr r1, =stdin  @ Load stdin ptr
  ldr r1, [r1]    @ Load stdin
  b fgetc

.align 2
.global puts
puts:
  push {r4, lr}   @ Save lr
  mov r4, r0      @ Save string

// Protection
  cmp r4, #0      @ Check NULL
  beq .puts_flt

  ldr r1, =stdout @ Load stdout ptr
  ldr r1, [r1]    @ Load stdout
  bl fputs        @ Print string

  cmp r0, #0      @ Check exit code
  bmi .puts_flt

  mov r0, #10     @ '\n'
  ldr r1, =stdout @ Load stdout ptr
  ldr r1, [r1]    @ Load stdout
  bl fputc        @ Newline

  cmp r0, #0      @ Check exit code
  bmi .puts_flt

  mov r0, #1
  pop {r4, pc}    @ Return 1

.puts_flt:
  ldr r0, =MINUS1 @ Return -1
  pop {r4, pc}

.align 2
.global putc
putc:
  b fputc

.align 2
.global getc
getc:
  b fgetc

.section .data
.align 2
.global stdin
.global stdout
.global stderr

stdin:  .skip 4 @ FILE *
stdout: .skip 4 @ FILE *
stderr: .skip 4 @ FILE *

.equ MINUS1, 0xFFFFFFFF @ -1
// .equ MINUS1, 0x30 @ -1

