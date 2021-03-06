/*
 * Memory Setup stuff - taken from blob memsetup.S
 *
 * Copyright (C) 2009 Samsung Electronics
 * Kyungmin Park <kyungmin.park@samsung.com>
 *
 * See file CREDITS for list of people who contributed to this
 * project.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#include <config.h>
#include <version.h>
#include <asm/arch/cpu.h>
#include <asm/arch/clock.h>
#include <asm/arch/power.h>

/*
 * Register usages:
 *
 * r5 has zero always
 * r7 has S5PC100 GPIO base, 0xE0300000
 * r8 has real GPIO base, 0xE0300000, 0xE0200000 at S5PC100, S5PC110 repectively
 * r9 has Mobile DDR size, 1 means 1GiB, 2 means 2GiB and so on
 */

_TEXT_BASE:
	.word	CONFIG_SYS_TEXT_BASE

	.globl lowlevel_init
lowlevel_init:
	mov	r11, lr

	/* r5 has always zero */
	mov	r5, #0

	ldr	r7, =S5PC100_GPIO_BASE
	ldr	r8, =S5PC100_GPIO_BASE
	/* Read CPU ID */
	ldr	r2, =S5PC110_PRO_ID
	ldr	r0, [r2]
	mov	r1, #0x00010000
	and	r0, r0, r1
	cmp	r0, r5
	beq	100f
	ldr	r8, =S5PC110_GPIO_BASE
100:
	/* Turn on KEY_LED_ON [GPJ4(1)] XMSMWEN */
	cmp	r7, r8
	beq	skip_check_didle			@ Support C110 only

	ldr	r0, =S5PC110_RST_STAT
	ldr	r1, [r0]
	and	r1, r1, #0x000D0000
	cmp	r1, #(0x1 << 19)			@ DEEPIDLE_WAKEUP
	beq	didle_wakeup
	cmp	r7, r8

skip_check_didle:
	addeq	r0, r8, #0x280				@ S5PC100_GPIO_J4
	addne	r0, r8, #0x2C0				@ S5PC110_GPIO_J4
	ldr	r1, [r0, #0x0]				@ GPIO_CON_OFFSET
	bic	r1, r1, #(0xf << 4)			@ 1 * 4-bit
	orr	r1, r1, #(0x1 << 4)
	str	r1, [r0, #0x0]				@ GPIO_CON_OFFSET

	ldr	r1, [r0, #0x4]				@ GPIO_DAT_OFFSET
	bic	r1, r1, #(1 << 1)
	str	r1, [r0, #0x4]				@ GPIO_DAT_OFFSET

	/* Don't setup at s5pc100 */
	beq	100f

	/*
	 * Initialize Async Register Setting for EVT1
	 * Because we are setting EVT1 as the default value of EVT0,
	 * setting EVT0 as well does not make things worse.
	 * Thus, for the simplicity, we set for EVT0, too
	 *
	 * The "Async Registers" are:
	 *	0xE0F0_0000
	 *	0xE1F0_0000
	 *	0xF180_0000
	 *	0xF190_0000
	 *	0xF1A0_0000
	 *	0xF1B0_0000
	 *	0xF1C0_0000
	 *	0xF1D0_0000
	 *	0xF1E0_0000
	 *	0xF1F0_0000
	 *	0xFAF0_0000
	 */
	ldr     r0, =0xe0f00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xe1f00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1800000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1900000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1a00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1b00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1c00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1d00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1e00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xf1f00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	ldr     r0, =0xfaf00000
	ldr     r1, [r0]
	bic     r1, r1, #0x1
	str     r1, [r0]

	/*
	 * Diable ABB block to reduce sleep current at low temperature
	 * Note that it's hidden register setup don't modify it
	 */
	ldr	r0, =0xE010C300
	ldr	r1, =0x00800000
	str	r1, [r0]

100:
	/* IO retension release */
	ldreq	r0, =S5PC100_OTHERS			@ 0xE0108200
	ldrne	r0, =S5PC110_OTHERS			@ 0xE010E000
	ldr	r1, [r0]
	ldreq	r2, =(1 << 31)				@ IO_RET_REL
	ldrne	r2, =((1 << 31) | (1 << 30) | (1 << 29) | (1 << 28))
	orr	r1, r1, r2
	/* Do not release retention here for S5PC110 */
	streq	r1, [r0]

	/* Disable Watchdog */
	ldreq	r0, =S5PC100_WATCHDOG_BASE		@ 0xEA200000
	ldrne	r0, =S5PC110_WATCHDOG_BASE		@ 0xE2700000
	str	r5, [r0]

	/* setting SRAM */
	ldreq	r0, =S5PC100_SROMC_BASE
	ldrne	r0, =S5PC110_SROMC_BASE
	ldr	r1, =0x9
	str	r1, [r0]

	/* S5PC100 has 3 groups of interrupt sources */
	ldreq	r0, =S5PC100_VIC0_BASE			@ 0xE4000000
	ldrne	r0, =S5PC110_VIC0_BASE			@ 0xF2000000
	add	r1, r0, #0x00100000
	add	r2, r0, #0x00200000
	add	r3, r0, #0x00300000
	/* Disable all interrupts (VIC0, VIC1 and VIC2) */
	mvn	r4, #0x0
	str	r4, [r0, #0x14]				@ INTENCLEAR
	str	r4, [r1, #0x14]				@ INTENCLEAR
	str	r4, [r2, #0x14]				@ INTENCLEAR
	str	r4, [r3, #0x14]				@ INTENCLEAR

	/* Set all interrupts as IRQ */
	str	r5, [r0, #0xc]				@ INTSELECT
	str	r5, [r1, #0xc]				@ INTSELECT
	str	r5, [r2, #0xc]				@ INTSELECT
	str	r5, [r3, #0xc]				@ INTSELECT

	/* Pending Interrupt Clear */
	str	r5, [r0, #0xf00]			@ INTADDRESS
	str	r5, [r1, #0xf00]			@ INTADDRESS
	str	r5, [r2, #0xf00]			@ INTADDRESS
	str	r5, [r3, #0xf00]			@ INTADDRESS


	/*led_init*/
	ldr r1, =0xE0200280 					
	ldr r0, =0x00001111
	str r0, [r1]
	/*led_on*/
	ldr r1, =0xE0200284 					
	mov r0, #0
	str r0, [r1]

	/* for UART */
	bl	uart_asm_init

	bl	internal_ram_init

	/*for SDRAM*/
	bl sdram_init

	/*for copy_sd_to_ddr*/

	bl copy_code_to_dram	
	
	/* init system clock */
	//bl system_clock_init


	cmp	r7, r8
	/* Clear wakeup status register */
	ldreq	r0, =S5PC100_WAKEUP_STAT	
	ldrne	r0, =S5PC110_WAKEUP_STAT
	ldr	r1, [r0]
	str	r1, [r0]

	/* IO retension release */
	ldreq	r0, =S5PC100_OTHERS			@ 0xE0108200
	ldrne	r0, =S5PC110_OTHERS			@ 0xE010E000
	ldr	r1, [r0]
	ldreq	r2, =(1 << 31)				@ IO_RET_REL
	ldrne	r2, =((1 << 31) | (1 << 30) | (1 << 29) | (1 << 28))
	orr	r1, r1, r2
	str	r1, [r0]

	b	1f

didle_wakeup:
	/* Wait when APLL is locked */
	ldr	r0, =0xE0100100			@ S5PC110_APLL_CON
lockloop:
	ldr	r1, [r0]
	and	r1, r1, #(1 << 29)
	cmp	r1, #(1 << 29)
	bne	lockloop

	ldr	r0, =S5PC110_INFORM0
	ldr	r1, [r0]
	mov	pc, r1
	nop
	nop
	nop
	nop
	nop

1:
	mov	lr, r11
	mov	pc, lr

/*
 * system_clock_init: Initialize core clock and bus clock.
 * void system_clock_init(void)
 */
system_clock_init:
	ldr	r0, =S5PC110_CLOCK_BASE		@ 0xE0100000

	/* Check S5PC100 */
	cmp	r7, r8
	bne	110f
100:
	/* Set Lock Time */
	ldr	r1, =0xe10			@ Locktime : 0xe10 = 3600
	str	r1, [r0, #0x000]		@ S5PC100_APLL_LOCK
	str	r1, [r0, #0x004]		@ S5PC100_MPLL_LOCK
	str	r1, [r0, #0x008]		@ S5PC100_EPLL_LOCK
	str	r1, [r0, #0x00C]		@ S5PC100_HPLL_LOCK

	/* S5P_APLL_CON */
	ldr	r1, =0x81bc0400		@ SDIV 0, PDIV 4, MDIV 444 (1333MHz)
	str	r1, [r0, #0x100]
	/* S5P_MPLL_CON */
	ldr	r1, =0x80590201		@ SDIV 1, PDIV 2, MDIV 89 (267MHz)
	str	r1, [r0, #0x104]
	/* S5P_EPLL_CON */
	ldr	r1, =0x80870303		@ SDIV 3, PDIV 3, MDIV 135 (67.5MHz)
	str	r1, [r0, #0x108]
	/* S5P_HPLL_CON */
	ldr	r1, =0x80600603		@ SDIV 3, PDIV 6, MDIV 96
	str	r1, [r0, #0x10C]

	ldr     r1, [r0, #0x300]
	ldr     r2, =0x00003fff
	bic     r1, r1, r2
	ldr     r2, =0x00011301

	orr	r1, r1, r2
	str	r1, [r0, #0x300]
	ldr     r1, [r0, #0x304]
	ldr     r2, =0x00011110
	orr     r1, r1, r2
	str     r1, [r0, #0x304]
	ldr     r1, =0x00000001
	str     r1, [r0, #0x308]

	/* Set Source Clock */
	ldr	r1, =0x00001111			@ A, M, E, HPLL Muxing
	str	r1, [r0, #0x200]		@ S5PC1XX_CLK_SRC0

	b	200f
110:
	ldr	r0, =0xE010C000			@ S5PC110_PWR_CFG

	/* Set OSC_FREQ value */
	ldr	r1, =0xf
	str	r1, [r0, #0x100]		@ S5PC110_OSC_FREQ

	/* Set MTC_STABLE value */
	ldr	r1, =0xffffffff
	str	r1, [r0, #0x110]		@ S5PC110_MTC_STABLE

	/* Set CLAMP_STABLE value */
	ldr	r1, =0x3ff03ff
	str	r1, [r0, #0x114]		@ S5PC110_CLAMP_STABLE

	ldr	r0, =S5PC110_CLOCK_BASE		@ 0xE0100000

	/* Set Clock divider */
	ldr	r1, =0x14131330			@ 1:1:4:4, 1:4:5
	str	r1, [r0, #0x300]
	ldr	r1, =0x11110111			@ UART[3210]: MMC[3210]
	str	r1, [r0, #0x310]

	/* Set Lock Time */
	ldr	r1, =0x2cf			@ Locktime : 30us
	str	r1, [r0, #0x000]		@ S5PC110_APLL_LOCK
	ldr	r1, =0xe10			@ Locktime : 0xe10 = 3600
	str	r1, [r0, #0x008]		@ S5PC110_MPLL_LOCK
	str	r1, [r0, #0x010]		@ S5PC110_EPLL_LOCK
	str	r1, [r0, #0x020]		@ S5PC110_VPLL_LOCK

	/* S5PC110_APLL_CON */
	ldr	r1, =0x80C80601			@ 800MHz
	str	r1, [r0, #0x100]
	/* S5PC110_MPLL_CON */
	ldr	r1, =0x829B0C01			@ 667MHz
	str	r1, [r0, #0x108]
	/* S5PC110_EPLL_CON */
	ldr	r1, =0x80600602			@  96MHz VSEL 0 P 6 M 96 S 2
	str	r1, [r0, #0x110]
	/* S5PC110_VPLL_CON */
	ldr	r1, =0x806C0603			@  54MHz
	str	r1, [r0, #0x120]

	/* Set Source Clock */
	ldr	r1, =0x10001111			@ A, M, E, VPLL Muxing
	str	r1, [r0, #0x200]		@ S5PC1XX_CLK_SRC0

	/* OneDRAM(DMC0) clock setting */
	ldr	r1, =0x01000000			@ ONEDRAM_SEL[25:24] 1 SCLKMPLL
	str	r1, [r0, #0x218]		@ S5PC110_CLK_SRC6
	ldr	r1, =0x30000000			@ ONEDRAM_RATIO[31:28] 3 + 1
	str	r1, [r0, #0x318]		@ S5PC110_CLK_DIV6

	/* XCLKOUT = XUSBXTI 24MHz */
	add	r2, r0, #0xE000			@ S5PC110_OTHERS
	ldr     r1, [r2]
	orr	r1, r1, #(0x3 << 8)		@ CLKOUT[9:8] 3 XUSBXTI
	str	r1, [r2]

	/* CLK_IP0 */
	ldr	r1, =0x8fefeeb			@ DMC[1:0] PDMA0[3] IMEM[5]
	str	r1, [r0, #0x460]		@ S5PC110_CLK_IP0

	/* CLK_IP1 */
	ldr	r1, =0xe9fdf0f9			@ FIMD[0] USBOTG[16]
						@ NANDXL[24]
	str	r1, [r0, #0x464]		@ S5PC110_CLK_IP1

	/* CLK_IP2 */
	ldr	r1, =0xf75f7fc			@ CORESIGHT[8] MODEM[9]
						@ HOSTIF[10] HSMMC0[16]
						@ HSMMC2[18] VIC[27:24]
	str	r1, [r0, #0x468]		@ S5PC110_CLK_IP2

	/* CLK_IP3 */
	ldr	r1, =0x8eff038c			@ I2C[8:6]
						@ SYSTIMER[16] UART0[17]
						@ UART1[18] UART2[19]
						@ UART3[20] WDT[22]
						@ PWM[23] GPIO[26] SYSCON[27]
	str	r1, [r0, #0x46c]		@ S5PC110_CLK_IP3

	/* CLK_IP4 */
	ldr	r1, =0xfffffff1			@ CHIP_ID[0] TZPC[8:5]
	str	r1, [r0, #0x470]		@ S5PC110_CLK_IP3

200:
	/* wait at least 200us to stablize all clock */
	mov	r2, #0x10000
1:	subs	r2, r2, #1
	bne	1b

	mov	pc, lr

internal_ram_init:
	ldreq	r0, =0xE3800000
	ldrne	r0, =0xF1500000
	ldr	r1, =0x0
	str	r1, [r0]

	mov	pc, lr

/*
 * uart_asm_init: Initialize UART's pins
 */
uart_asm_init:
	ldr r0, =S5PC110_GPIO_BASE
	ldr r1, =0x22222222
	str r1, [r0, #0x0]			@GPAO=0x2222

	ldr r0, =S5PC110_UART_BASE
	ldr	r1, =3
	str	r1, [r0, #0x0]			@ ULCON=3

	ldr	r1, =0x305
	str	r1, [r0, #0x4]			@ UCON=0x305

	ldr	r1, =1
	str	r1, [r0, #0x8]			@ UFCON=1
	ldr		r1, =0
	str	r1, [r0, #0xC]			@ UMCON=0

	ldr	r1, =34
	str	r1, [r0, #0x28]			@ UBRDIV0=34
	ldr	r1, =0xDFDD
	str	r1, [r0, #0x2C]			@ UDIVSLOT0=0XDFDD

	
	mov	pc, lr

.globl sdram_init
sdram_init:
//step 2: Set the PhyControl0.ctrl_start_point, .ctrl_inc, .ctrl_dll_on
	ldr	r0, =APB_DMC_0_BASE
	ldr	r1, =0x0010100A					
	str	r1, [r0, #DMC_PHYCONTROL0]
	//step 3: Set the PhyControl1.ctrl_shiftc, .ctrl_offsetc
	ldr	r1, =0x00000086					
	str	r1, [r0, #DMC_PHYCONTROL1]
	//step 4: PhyControl0 DLL start
	ldr	r1, =0x0010100B					
	str	r1, [r0, #DMC_PHYCONTROL0]

find_lock_val:
	//step 11:Loop until DLL is locked
	ldr	r1, [r0, #DMC_PHYSTATUS]			
	and	r2, r1, #0x7
	cmp	r2, #0x7					
	bne	find_lock_val
	
	//step 12: Force Value locking
	and	r1, #0x3fc0
	mov	r2, r1, LSL #18
	orr	r2, r2, #0x100000
	orr	r2 ,r2, #0x1000
	orr	r1, r2, #0xB					
	str	r1, [r0, #DMC_PHYCONTROL0]

	//step 5: ConControl auto refresh off
	ldr	r1, =0x0FFF1010					
	str	r1, [r0, #DMC_CONCONTROL]
	//step 6: MemControl BL=4, 1 chip, DDR2 type, dynamic power down off
	ldr	r1, =0x00202400				
	str	r1, [r0, #DMC_MEMCONTROL]
	//step 7: MemConfig0 512MB config, 8 banks,Mapping Method[12:15]0:linear 
	ldr	r1, =0x20E00323				
	str	r1, [r0, #DMC_MEMCONFIG0]
	//step 8:PrechConfig
	ldr	r1, =0xFF000000					
	str	r1, [r0, #DMC_PRECHCONFIG]
	ldr	r1, =0xFFFF00FF					
	str	r1, [r0, #DMC_PWRDNCONFIG]

	//step 9:TimingAref	7.8us//133MHz=1038(0x40E), 100MHz=780(0x30C), 20MHz=156(0x9C), 10MHz=78(0x4E)
	ldr	r1, =0x0000040E				
	str	r1, [r0, #DMC_TIMINGAREF]
	//TimingRow
	ldr	r1, =0x11122206				
	str	r1, [r0, #DMC_TIMINGROW]
	//TimingData
	ldr	r1, =0x12240000				
	str	r1, [r0, #DMC_TIMINGDATA]
	//TimingPower
	ldr	r1, =0x05DC0343				
	str	r1, [r0, #DMC_TIMINGPOWER]

	//step 14:DirectCmd	chip0 NOP
	ldr	r1, =0x07000000					
	str	r1, [r0, #DMC_DIRECTCMD]
	//step 16:DirectCmd	chip0 PALL
	ldr	r1, =0x01000000					
	str	r1, [r0, #DMC_DIRECTCMD]
	//step 17:DirectCmd	chip0 EMRS2
	ldr	r1, =0x00020000					
	str	r1, [r0, #DMC_DIRECTCMD]
	//step 18:DirectCmd	chip0 EMRS3
	ldr	r1, =0x00030000					
	str	r1, [r0, #DMC_DIRECTCMD]
	//step 19:DirectCmd	chip0 EMRS1 (MEM DLL on, DQS# disable)
	ldr	r1, =0x00010000					
	str	r1, [r0, #DMC_DIRECTCMD]
	//step 20:DirectCmd	chip0 MRS (MEM DLL reset) CL=4, BL=4
	ldr	r1, =0x00000542					
	str	r1, [r0, #DMC_DIRECTCMD]
	//step 21:DirectCmd	chip0 PALL
	ldr	r1, =0x01000000					
	str	r1, [r0, #DMC_DIRECTCMD]
	//step 22:DirectCmd	chip0 REFA
	ldr	r1, =0x05000000					
	str	r1, [r0, #DMC_DIRECTCMD]
	//DirectCmd	chip0 REFA
	ldr	r1, =0x05000000					
	str	r1, [r0, #DMC_DIRECTCMD]
	//step 23:DirectCmd	chip0 MRS (MEM DLL unreset)
	ldr	r1, =0x00000442					
	str	r1, [r0, #DMC_DIRECTCMD]
	//step 25(1):DirectCmd	chip0 EMRS1 (OCD default)
	ldr	r1, =0x00010380					
	str	r1, [r0, #DMC_DIRECTCMD]
	//step 25(2)DirectCmd	chip0 EMRS1 (OCD exit)
	ldr	r1, =0x00010000					
	str	r1, [r0, #DMC_DIRECTCMD]
	
	//step 27:ConControl	auto refresh on
	ldr	r1, =0x0FF01030					
	str	r1, [r0, #DMC_CONCONTROL]
	//step 28:MemControl	BL=4, 1 chip, DDR2 type, dynamic self refresh, force precharge, dynamic power down off
	ldr	r1, =0x00202400					
	str	r1, [r0, #DMC_MEMCONTROL]


	ldr	r0,=0xE2900020
	ldr	r1,=0x44			@UTH0='D'
	str	r1,[r0]

	ldr	r1,=0x44			
	str	r1,[r0]				@UTH0='D'

	ldr	r1,=0x52			
	str	r1,[r0]				@UTH0='R'

	ldr	r1,=0x5F
	str	r1,[r0]				@UTH0='-'

	ldr	r1,=0x4F			
	str	r1,[r0]				@UTH0='O'

	ldr	r1,=0x6B
	str	r1,[r0]				@UTH0='k'

	ldr	r1,=0x21
	str	r1,[r0]				@UTH0='!'

	ldr	r1,=0xA
	str	r1,[r0]				@UTH0='\r'

	ldr	r1,=0xD
	str	r1,[r0]				@UTH0='\n'

	mov	pc, lr


.globl display_addr_dat
display_addr_dat:
	ldr r0, [r0]

	ldr r1, =0xE2900020
	ldr r2, =0x30
	str r2, [r1]
	ldr r2, =0x78
	str r2, [r1]		@dispaly  0x

	ldr r3, =28
display_loop_cnt:
	lsr 	r2, r0, r3
	and 	r2, r2, #0xF
	cmp 	r2, #10			@xian shi ascii ma
	addmi	r2, r2, #0x30
	addpl	r2, r2, #0x37
	str 	r2, [r1]

	sub	r3, r3, #4
	cmp 	r3, #0
	bpl	display_loop_cnt

	ldr r2, =0xA
	str r2, [r1]
	ldr r2, =0xD
	str r2, [r1]

	mov pc, lr

.globl display_num_dat
display_num_dat:


	ldr r1, =0xE2900020
	ldr r2, =0x30
	str r2, [r1]
	ldr r2, =0x78
	str r2, [r1]		@dispaly  0x

	ldr r3, =28
display_loop_num:
	lsr 	r2, r0, r3
	and 	r2, r2, #0xF
	cmp 	r2, #10			@xian shi ascii ma
	addmi	r2, r2, #0x30
	addpl	r2, r2, #0x37
	str 	r2, [r1]

	sub	r3, r3, #4
	cmp 	r3, #0
	bpl	display_loop_num

	ldr r2, =0xA
	str r2, [r1]
	ldr r2, =0xD
	str r2, [r1]

	mov pc, lr


.globl display_put
display_put:
	bl display_num_dat
	mov pc, lr

.globl display_addr
display_addr:
	mov r0, lr
	//sub r0, #12
	bl display_num_dat
	bl display_addr_dat
	mov pc, lr
