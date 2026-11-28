.syntax unified
.cpu cortex-m0plus
.thumb

.include "resets.inc"
#include "hw_regs.inc"

.equ pll_refdiv_125MHz, 1
.equ pll_fbdiv_125MHz, 125
.equ pll_pd1_125MHz, 6
.equ pll_pd2_125MHz, 2


.section .init.clock_init, "ax", %progbits
.global _clock_init

.type _clock_init, %function
_clock_init:
  push {lr}

  // Start XOSC
  ldr r0, =hw_rw(XOSC_BASE)
  movs r1, #47
  str r1, [r0, #o_xosc_startup]
  ldr r1, =m_xosc_ctrl
  str r1, [r0, #o_xosc_ctrl]

  // wait XOSC
.wait_xosc:
  ldr r1, [r0, #o_xosc_status]
  lsrs r1, r1, #31
  beq .wait_xosc  // Wait 1

  // Setup PLL_SYS
  rst_unlock b_rst_pll_sys

  // Lock PLL
  ldr r0, =hw_rw(PLL_SYS_BASE)
  ldr r1, =0xffffffff
  str r1, [r0, #o_pll_pwr]
  adds r1, r1, #1 // r1 = 0
  str r1, [r0, #o_pll_fbdiv_int]

  // Set refdiv and fbdiv
  ldr r0, =hw_rw(PLL_SYS_BASE)
  ldr r1, =pll_refdiv_125MHz
  str r1, [r0, #o_pll_cs]
  ldr r1, =pll_fbdiv_125MHz
  str r1, [r0, #o_pll_fbdiv_int]

  // Enable VCO abd PLL
  ldr r0, =hw_clr(PLL_SYS_BASE)
  ldr r1, =((1 << 0) | (1 << 5))  // PD VCOPD
  str r1, [r0, #o_pll_pwr]

  // Wait for VCO
  ldr r0, =hw_rw(PLL_SYS_BASE)
.wait_vco:
  ldr r1, [r0, #o_pll_cs]
  lsrs r1, r1, #31
  beq .wait_vco // if 0 repeat

  // Setup PRIM
  ldr r1, =((pll_pd2_125MHz << 16) | (pll_pd1_125MHz << 12))
  str r1, [r0, #o_pll_prim]

  // Reset POSTDIVPD
  ldr r0, =hw_clr(PLL_SYS_BASE)
  ldr r1, =(1 << 3)
  str r1, [r0, #o_pll_pwr]

  // Set clk to XOSC
  ldr r0, =hw_rw(CLOCKS_BASE)
  movs r1, #2 // XOSC
  str r1, [r0, #o_clk_ref_ctrl]

  ldr r2, =(1 << 2)
.wait_clk_ref:
  ldr r1, [r0, #o_clk_ref_selected]
  ands r1, r1, r2
  beq .wait_clk_ref

  // Set mux to PLL_SYS
  movs r1, #1 // PLL, MUX
  str r1, [r0, #o_clk_sys_ctrl]

  ldr r2, =(1 << 1)
.wait_clk_sys:
  ldr r1, [r0, #o_clk_sys_selected]
  ands r1, r1, r2
  beq .wait_clk_sys

  // Enable CLK_PERI
  movs r1, #1
  lsls r1, r1, #11
  str r1, [r0, #o_clk_peri_ctrl]

  // Now we have 125MHz
  pop {pc}


.struct 0
o_xosc_ctrl:    .skip 4
o_xosc_status:  .skip 4
o_xosc_dormant: .skip 4
o_xosc_startup: .skip 4
o_xosc_count:   .skip 4
.text

.struct 0
o_pll_cs:         .skip 4
o_pll_pwr:        .skip 4
o_pll_fbdiv_int:  .skip 4
o_pll_prim:       .skip 4
.text

.equ CLOCKS_BASE, 0x40008000
.equ o_clk_ref_ctrl, 0x30
.equ o_clk_sys_ctrl, 0x3c
.equ o_clk_ref_selected, 0x38
.equ o_clk_sys_selected, 0x44
.equ o_clk_peri_ctrl, 0x48

.equ XOSC_BASE, 0x40024000
.equ m_xosc_ctrl, ((0xaa0 << 0) | (0xfab << 12))  // Enable, 1-15MHz input
.equ b_xosc_status_stable, (1 << 31) // is stable

.equ PLL_SYS_BASE, 0x40028000

