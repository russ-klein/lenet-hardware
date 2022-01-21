	.section "vectors"

        .section .reset_vector
        .align  2
        .globl  __reset_vector
	.globl  _exit
__isr_vector:

#.global reset
reset:	b	reset_handler
undef:	b	undefined_handler
swi:	b	swi_handler
pabt:	b	prefetch_handler
dabp:	b	abort_handler
nope:	nop
irq:	b	irq_handler
fiq_handler:

	mov	sp, #0x08000000
	add	sp, sp, #0x8000
	mov	x1, #1
	b	_fast_interrupt_handler
	ret

irq_handler:
	mov	sp, #0x08000000
	add	sp, sp, #0xC000
	mov	x1, #2
	b	_interrupt_handler
	ret

do_nothing:
	ret

#finish_up:
#	b	_exit

reset_handler:
	mov	x0, #0
	mov	x4, #0x20000
	str	x0, [x4, #0x208]
	str	x0, [x4, #0x218]
	str	x0, [x4, #0x760]
	str	x0, [x4, #0x768]
	mov	x0, do_nothing
	str	x0, [x4, #0x760]
#	mov 	x0, finish_up
#	str	x0, [x4, #0x770]
	mov     x0,#0x0
	mov     x1,x0
	mov     x2,x0
	mov     x3,x0
	mov     x4,x0
	mov     x5,x0
	mov     x6,x0
	mov     x7,x0
	mov     x8,x0
	mov     x9,x0
	mov     x10,x0
	mov     x11,x0
	mov     x12,x0
	mov     x13,x0
	mov     x14,x0
	mov     x15,x0
	mov     x16,x0
	mov     x17,x0
	mov     x18,x0
	mov     x19,x0
	mov     x20,x0
	mov     x21,x0
	mov     x22,x0
	mov     x23,x0
	mov     x24,x0
	mov     x25,x0
	mov     x26,x0
	mov     x27,x0
	mov     x28,x0
	mov     x29,x0
	mov     x30,x0
	msr     SP_EL0,x0
	msr     SP_EL1,x0
	msr     SP_EL2,x0
	mov     sp,x0
	msr     ELR_EL1,x0
	msr     ELR_EL2,x0
	msr     ELR_EL3,x0
	msr     SPSR_EL1,x0
	msr     SPSR_EL2,x0
	msr     SPSR_EL3,x0

	b	_start

undefined_handler:
	mov	x1, #0xdead
	add	x1, x1, #0x10000
	b	undefined_handler

swi_handler:
	mov	x1, #0xdead
	add	x1, x1, #0x20000;
	b	swi_handler


prefetch_handler:
	mov	x1, #0xdead
	add	x1, x1, #0x30000;
	b	prefetch_handler

abort_handler:
	mov	x1, #0xdead
	add	x1, x1, #0x40000;
	b	abort_handler

