    .section    .reset_vectors

    .extern  main
        
        b Reset_Handler
        b Undefined_Handler
        b SWI_Handler
        b Prefetch_Handler
        b Abort_Handler
        NOP                            
        b IRQ_Handler
        b FIQ_Handler
        
        
Reset_Handler :
    mov x0,#0x0
    mov x1,#0x0
    mov x2,#0x0
    mov x3,#0x0
    mov x4,#0x0
    mov x5,#0x0
    mov x6,#0x0
    mov x7,#0x0
    mov x8,#0x0
    mov x9,#0x0
    mov x10,#0x0
    mov x11,#0x0
    mov x12,#0x0
    mov x13,#0x0
    mov x14,#0x0
    mov x15,#0x0
    mov x16,#0x0
    mov x17,#0x0
    mov x18,#0x0
    mov x19,#0x0
    mov x20,#0x0
    mov x21,#0x0
    mov x22,#0x0
    mov x23,#0x0
    mov x24,#0x0
    mov x25,#0x0
    mov x26,#0x0
    mov x27,#0x0
    mov x28,#0x0
    mov x29,#0x0
    mov x30,#0x0

    MSR     SP_EL0,x0
    MSR     SP_EL1,x0
    MSR     SP_EL2,x0
    MOV     sp,x0
    MSR     ELR_EL1,x0
    MSR     ELR_EL2,x0
    MSR     ELR_EL3,x0
    MSR     SPSR_EL1,x0
    MSR     SPSR_EL2,x0
    MSR     SPSR_EL3,x0


    LDR     x1, =vectors_loc
    MSR     VBAR_EL3, x1


    bl flush_cache_all
    #tlbi    alle1
    #tlbi    alle1is

    bl get_cpuid
    mov x11,x0

    ldr x0,=0x2FF000
    mov x1,#0x8000
    mul x2,x1,x11
    sub x0,x0,x2

    mov sp, x0
    
    mrs     x0, MPIDR_EL1
    and x1, x0, #0xf
    cbnz  x1, slave_boot
        
    //LDR     x0, =page_table_base
    LDR     x0, =0x100000
    LDR     x1, =0x0000000000000605   //cached memory 0x00000000-0x3fffffff
    STR     x1, [x0, #0x00]
    LDR     x1, =0x0060000040000601   //device memory 0x40000000-0x7fffffff
    STR     x1, [x0, #0x08]
    LDR     x1, =0x0000000080000601   //device memory 0x80000000-0xbfffffff
    STR     x1, [x0, #0x10]
    LDR     x1, =0x00600000c0000601   //device memory 0xc0000000-0xffffffff
    STR     x1, [x0, #0x18]
    MSR     TTBR0_EL3, x0

    MOV     x1, #0xff04               // magic.  Not magic, temporal hints for caching, does not work, leave it off.
    MSR     MAIR_EL3, x1

    LDR     x1, =0x80842520           // more magic.  Umm, no, sets reserved bits. this is bullshit. Do to load this register.
    MSR     TCR_EL3, x1

    IC      IALLU
    TLBI    ALLE3

    ISB

    MRS     x1, SCTLR_EL3       // bit 11 is reserved, do not try to set it.  
    MOV     x2, #0x0800               
    ORR     x1, x1, x2
    MSR     SCTLR_EL3, x1

    NOP
    ISB

    MRS     x1, SCTLR_EL3       // enables MMU
    MOV     x2, #0x0801              
    ORR     x1, x1, x2
    MSR     SCTLR_EL3, x1

    NOP
    ISB

    MRS     x1, ACTLR_EL3
    MOV     x2, #0x42
    //MOV     x2, #0x73           // enable writes to auxiliary control register
    ORR     x1,x1,x2
    MSR     ACTLR_EL3, x1

    NOP
    ISB

    MRS     x1, SCTLR_EL3
    MOV     x2, #0x1004               // Turn on data and instruction caches
    MOV     x2, #0x1000               // Turn on instruction cache only (data cache seems to wedge)
    ORR     x1, x1, x2
    MSR     SCTLR_EL3, x1

    NOP
    ISB

    ldr     x13, =done
    bl      main

done:
    mov     x0, #0
    mov     x1, #0xFF000000

    str     x0, [x1]

        

slave_boot :
    WFE
    NOP

    LDR     x0, =0x100000
    MSR     TTBR0_EL3, x0

    MOV     x1, #0xff04               // magic
    MSR     MAIR_EL3, x1

    LDR     x1, =0x80842520           // more magic
    MSR     TCR_EL3, x1

    IC      IALLU
    TLBI    ALLE3

    ISB

  
    MRS     x1, SCTLR_EL3
    MOV     x2, #0x0800               // Turn on caches et al
    ORR     x1, x1, x2
    MSR     SCTLR_EL3, x1
    ISB
    MRS     x1, SCTLR_EL3
    MOV     x2, #0x0801               // Turn on caches et al
    ORR     x1, x1, x2
    MSR     SCTLR_EL3, x1
    NOP
    ISB

    MRS x1, ACTLR_EL3
    MOV    x2, #0x42
    ORR  x1,x1,x2
    MSR ACTLR_EL3, x1
    NOP
    ISB

    ldr x0,=main
    br x0

      .align 8
zeroes:
            .space 512

Undefined_Handler :
    eret

SWI_Handler :
    eret
    
NOTEXITSWI :
    eret

Prefetch_Handler :
    eret

Abort_Handler :
    eret
    NOP

IRQ_Handler :
    eret
    NOP

FIQ_Handler :
    eret
    NOP


__flush_dcache_all:
    dsb    sy                
    mrs    x0, clidr_el1
    and    x3, x0, #0x7000000
    lsr    x3, x3, #23    
    cbz    x3, finished        
    mov    x10, #0        
loop1:
    add    x2, x10, x10, lsr #1        
    lsr    x1, x0, x2    
    and    x1, x1, #7
    cmp    x1, #2            
    b.lt    skip                
    msr    csselr_el1, x10
    isb    
    mrs    x1, ccsidr_el1
    and    x2, x1, #7            
    add    x2, x2, #4            
    mov    x4, #0x3ff
    and    x4, x4, x1, lsr #3    
    clz    x5, x4                
    mov    x7, #0x7fff
    and    x7, x7, x1, lsr #13    
loop2:
    mov    x9, x4                
loop3:
    lsl    x6, x9, x5
    orr    x11, x10, x6        
    lsl    x6, x7, x2
    orr    x11, x11, x6        
    dc    cisw, x11            
    subs    x9, x9, #1        
    b.ge    loop3
    subs    x7, x7, #1        
    b.ge    loop2
skip:
    add    x10, x10, #2        
    cmp    x3, x10
    b.gt    loop1
finished:
    mov    x10, #0                
    msr    csselr_el1, x10        
    dsb    sy
    isb
    ret

flush_cache_all :
    mov    x12, x30
    #bl    __flush_dcache_all
    mov    x0, #0
    ic    ialluis        
    dsb sy
    isb
    ret    x12
    
get_cpuid:
   mrs     x0, MPIDR_EL1
   and x0, x0, #0xf
   ret

    
.end    
