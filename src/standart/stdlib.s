.section .text

.align 2
.global abs
abs:
  asr r1, r0      @ Some CPU magic,
  eor r0, r1      @ I have no idea
  sub r0, r0, r1  @ how this works
  bx lr           @ and does it

@ No, im not doing strto*l in assembly, fck it
