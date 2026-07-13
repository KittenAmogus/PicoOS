.section .text

.struct 0
mem_block_prev:    .skip 4    @ Prevous mem block ptr block*
mem_block_next:    .skip 4    @ Next mem block ptr    block*
mem_block_magic:   .skip 4    @ Magic number          uint32_t
mem_block_size:    .skip 4    @ Allocated RAM size    size_t (uint32_t)
mem_block_is_free: .skip 4    @ &1 = Is block free    uint32_t
MEM_BLOCK_T_SIZE:             @ sizeof(struct _mem_block)
.text

// __end__     -> allocable SRAM (heap) start
// __HeapLimit -> allocable SRAM (heap) end

.align 2
.global k_mem_init
k_mem_init: @ Init heap for OS
  bx lr

.align 2
.global malloc
malloc:
// size_t size = r0

  push {r4, r5, lr}

  cmp r0, #0      @ Compare to 0
  beq .malloc_flt @ Can't allocate = 0
  bmi .malloc_flt @ Can't allocate < 0

// Check first block magic
  ldr r1, =_first_block
  ldr r1, [r1]
  ldr r1, [r1, #mem_block_magic]
  ldr r2, =BLOCK_MAGIC
  cmp r1, r2      @ Check if mem initialized
  bne .malloc_flt @ Return NULL if not

// Align size to 4 bytes
  add r0, r0, #3      @ +  3
  ldr r1, =0xFFFFFFFC @   ~3
  and r0, r0, r1      @ & ~3

// Find free block
  ldr r1, =_first_block @ Load first block addr
  ldr r1, [r1]          @ Load first block struct
.malloc_loop:
  ldr r2, [r1, #mem_block_is_free]
  mov r3, #1
  tst r2, r3  @ Check if free
  bne .malloc_found_free

// Not free or big enough
.malloc_next:

// Check magic
  ldr r2, [r1, #mem_block_magic]
  ldr r3, =BLOCK_MAGIC
  cmp r2, r3      @ block->magic == BLOCK_MAGIC
  bne .malloc_flt @ Return NULL

// Check size
  ldr r2, [r1, #mem_block_next]
  cmp r2, #0      @ Check if NULL
  beq .malloc_flt @ Then return NULL

// Load next block
  mov r1, r2      @ Load block
  b .malloc_loop  @ Repeat

// Found free block
.malloc_found_free:
  ldr r2, [r1, #mem_block_size] @ Load size
  cmp r2, r0                    @ Check size
  bmi .malloc_next              @ Too small

// Found big enough block
.malloc_found_size:
  mov r2, #0  @ Block is not free now
  str r2, [r1, #mem_block_is_free]

// Check if big enough
// for new block
  ldr r2, =MEM_BLOCK_T_SIZE
  ldr r4, =MIN_ALLOC_SIZE
  ldr r3, [r1, #mem_block_size]
  add r4, r4, r2        @ needisze = META_SIZE + MIN_ALLOC_SIZE
  sub r3, r3, r4        @ remsize  = block->size - newsize
  cmp r3, r0
  bmi .malloc_split_end @ remsize < size

// Split too big block (r3 - size of new block + meta)
.malloc_split_block:

// Create new
  mov r4, r1            @ Block ptr
  ldr r5, =MEM_BLOCK_T_SIZE
  add r4, r4, r5
  add r4, r4, r0        @ New block ptr
  ldr r2, =BLOCK_MAGIC  @ Create magic
  str r2, [r4, #mem_block_magic]

// New size
  ldr r2, [r1, #mem_block_size] @ r2 = block->size
  ldr r5, =MEM_BLOCK_T_SIZE     @ r5 = META_SIZE
  sub r2, r2, r0                @ r2 = r2 - size
  sub r2, r2, r5                @ r2 = r2 - r5
  str r2, [r4, #mem_block_size]
  str r0, [r1, #mem_block_size] @ Resize block

// New free
  mov r2, #1            @ is_free = 1
  str r2, [r4, #mem_block_is_free]

// Next block pointers
  ldr r2, [r1, #mem_block_next]
  str r2, [r4, #mem_block_next] @ new->next = block->next
  str r1, [r4, #mem_block_prev] @ new->prev = block
  str r4, [r1, #mem_block_next] @ block->next = new

  cmp r2, #0    @ Check if new->next != NULL
  beq .malloc_split_end

  ldr r5, [r4, #mem_block_next] @ new->next
  str r4, [r5, #mem_block_prev] @ new->next->prev = new

.malloc_split_end:
  ldr r0, =MEM_BLOCK_T_SIZE
  add r0, r0, r1    @ Data of allocated block

.malloc_end:
  pop {r4, r5, pc}  @ Return data ptr
.malloc_flt:
  mov r0, #0    @ Return NULL
  pop {r4, r5, pc}

.align 2
.global free
free:
// Protection (NULL)
  ldr r1, =MEM_BLOCK_T_SIZE @ Load META_SIZE
  sub r0, r0, r1            @ ptr - META_SIZE
  bmi .free_end             @ return

// Validate block
  ldr r3, =BLOCK_MAGIC      @ Load magic
  ldr r1, [r0, #mem_block_magic]
  cmp r1, r3                @ Check if block->magic the same
  bne .free_end             @ return

// Free block
  mov r1, #1                @ block->is_free = 1
  str r1, [r0, #mem_block_is_free]

/* === Merge prev block === */

// Check if previous block exists
  ldr r2, [r0, #mem_block_prev]
  cmp r2, #0                @ Compare to NULL
  beq .merge_next           @ Merge next
  ldr r1, [r2, #mem_block_magic]
  cmp r1, r3                @ Check magic
  bne .merge_next           @ Merge next
  ldr r1, [r2, #mem_block_is_free]
  mov r3, #1
  tst r1, r3                @ is_free
  beq .merge_next

// Merge
  ldr r1, [r0, #mem_block_size]
  ldr r3, =MEM_BLOCK_T_SIZE
  add r1, r1, r3            @ block->size + META_SIZE
  ldr r3, [r2, #mem_block_size]
  add r1, r1, r3            @ + prev->size
  str r1, [r2, #mem_block_size]
  ldr r3, =BLOCK_MAGIC
  mvn r1, r3                @ block->magic = ~BLOCK_MAGIC
  str r1, [r0, #mem_block_magic]
  ldr r1, [r0, #mem_block_next]
  str r1, [r2, #mem_block_next] @ Relink
  mov r0, r2                @ block = prev
  ldr r3, =BLOCK_MAGIC      @ Load block magic again

// Relink block->next
  cmp r1, #0                @ Do not write if NULL
  beq .merge_next
  str r0, [r1, #mem_block_prev]

/* === Merge next block === */
.merge_next:

// Check if next block exists
  ldr r2, [r0, #mem_block_next]
  cmp r2, #0                @ Compare to NULL
  beq .free_end             @ return
  ldr r1, [r2, #mem_block_magic]
  cmp r1, r3                @ Check magic
  bne .free_end             @ return
  ldr r1, [r2, #mem_block_is_free]
  mov r3, #1
  tst r1, r3                @ is_free
  beq .free_end             @ return

// Merge
  ldr r1, [r0, #mem_block_size]
  ldr r3, =MEM_BLOCK_T_SIZE
  add r1, r1, r3            @ next->size + META_SIZE
  ldr r3, [r2, #mem_block_size]
  add r1, r1, r3            @ + block->size
  str r1, [r0, #mem_block_size]
  ldr r3, =BLOCK_MAGIC
  mvn r1, r3                @ next->magic = ~BLOCK_MAGIC
  str r1, [r2, #mem_block_magic]
  ldr r1, [r2, #mem_block_next]
  str r1, [r0, #mem_block_next] @ Relink

// Relink next->next
  cmp r1, #0
  beq .free_ret
  str r0, [r1, #mem_block_prev]

.free_ret:
// Return data ptr
  ldr r3, =MEM_BLOCK_T_SIZE
  add r0, r0, r3            @ block + META_SIZE = data
.free_end:
  bx lr

.section .bss
.align 2
_first_block: .skip 4         @ First mem block ptr

.equ BLOCK_MAGIC, 0xDEC0ADDE  @ DEADCODE (Little-Endian)
.equ MIN_ALLOC_SIZE, 0x10     @ Do not split if block - META_SIZE < MIN_ALLOC_SIZE

