/////////////////////////////////////////////////////////////////////
//                                                                 //
//             READ ONLY FILE. PLEASE DO NOT EDIT!                 //
//                                                                 //
//      (use ./configure_rtl.pl script to create it instead)       //
//                                                                 //
/////////////////////////////////////////////////////////////////////

`ifdef _CORTEXA9_CONFIG_V_
`else
`define _CORTEXA9_CONFIG_V_

`define CORTEXA9_NUM_CPUS 4
`define CORTEXA9_DE_PRESENT
`define CORTEXA9_NEON_PRESENT
`define CORTEXA9_POWER_DOMAIN_WRAPPER
//`define CORTEXA9_PTM_IF
`define CORTEXA9_PARITY
`define CORTEXA9_NOARMBIST
`define CORTEXA9_DONT_USE_DW

//------------------------- SCU section
`define CORTEXA9_SCU_PRESENT
`define CORTEXA9_CCB_PRESENT
`define CORTEXA9_ACP_PRESENT
`define CORTEXA9_TWO_AXI_MASTERS

//------------------------- GIC section
`define CORTEXA9_INT_NUM 224
`define CORTEXA9_IRQ0
`define CORTEXA9_IRQ1
`define CORTEXA9_IRQ2
`define CORTEXA9_IRQ3
`define CORTEXA9_IRQ4
`define CORTEXA9_IRQ5
`define CORTEXA9_IRQ6

//------------------------- Uniform options
`define CORTEXA9_JAZELLE_PRESENT
//`define CORTEXA9_FPU
`define CORTEXA9_NEON
`define CORTEXA9_TLB_128
//`define CORTEXA9_PRELOAD_ENGINE_PRESENT
//`define CORTEXA9_PRELOAD_ENGINE_FIFO_SIZE_4
//`define CORTEXA9_PRELOAD_ENGINE_FIFO_SIZE_8

//------------------------- CPU0 section
`define CORTEXA9_CPU0_PRESENT
`define CORTEXA9_D_CACHESIZE0 2'b11
`define CORTEXA9_I_CACHESIZE0 2'b11
`define CORTEXA9_TLB0_128

//------------------------- CPU1 section
`define CORTEXA9_CPU1_PRESENT
`define CORTEXA9_D_CACHESIZE1 2'b11
`define CORTEXA9_I_CACHESIZE1 2'b11
`define CORTEXA9_TLB1_128

//------------------------- CPU2 section
`define CORTEXA9_CPU2_PRESENT
`define CORTEXA9_D_CACHESIZE2 2'b11
`define CORTEXA9_I_CACHESIZE2 2'b11
`define CORTEXA9_TLB2_128

//------------------------- CPU3 section
`define CORTEXA9_CPU3_PRESENT
`define CORTEXA9_D_CACHESIZE3 2'b11
`define CORTEXA9_I_CACHESIZE3 2'b11
`define CORTEXA9_TLB3_128

`endif
