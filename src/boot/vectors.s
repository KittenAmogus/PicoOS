.cpu cortex-m0plus
.thumb

.section .vectors, "ax"
.word __stack_top__   //start of stack pointer
.word _reset_handler  //reset
.word nmi_handler     //isr_nmi
.word hf_handler      //isr_hardfault
.word 0x00000000  //isr_invalid; Reserved, should never fire
.word 0x00000000  //isr_invalid; Reserved, should never fire
.word 0x00000000  //isr_invalid; Reserved, should never fire
.word 0x00000000  //isr_invalid; Reserved, should never fire
.word 0x00000000  //isr_invalid; Reserved, should never fire
.word 0x00000000  //isr_invalid; Reserved, should never fire
.word 0x00000000  //isr_invalid; Reserved, should never fire
.word 0x100001c7  //isr_svcall
.word 0x00000000  //isr_invalid; Reserved, should never fire
.word 0x00000000  //isr_invalid; Reserved, should never fire
.word 0x100001c9  //isr_pendsv
.word 0x100001cb  //isr_systick

.word irq_handler  //interrupt_0
.word irq_handler  //interrupt_1
.word irq_handler  //interrupt_2
.word irq_handler  //interrupt_3
.word irq_handler  //interrupt_4
.word irq_handler  //interrupt_5
.word irq_handler  //interrupt_6
.word irq_handler  //interrupt_7
.word irq_handler  //interrupt_8
.word irq_handler  //interrupt_9
.word irq_handler  //interrupt_10
.word irq_handler  //interrupt_11
.word irq_handler  //interrupt_12
.word irq_handler  //interrupt_13
.word irq_handler  //interrupt_14
.word irq_handler  //interrupt_15
.word irq_handler  //interrupt_16
.word irq_handler  //interrupt_17
.word irq_handler  //interrupt_18
.word irq_handler  //interrupt_19
.word irq_handler  //interrupt_20
.word irq_handler  //interrupt_21
.word irq_handler  //interrupt_22
.word irq_handler  //interrupt_23
.word irq_handler  //interrupt_24
.word irq_handler  //interrupt_25
.word irq_handler  //interrupt_26
.word irq_handler  //interrupt_27
.word irq_handler  //interrupt_28
.word irq_handler  //interrupt_29
.word irq_handler  //interrupt_30
.word irq_handler  //interrupt_31
