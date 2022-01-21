
`timescale 1ns/1ns
`include "axi_bus_defines.svh"

module segment_slave(
            BUS_GRANTS,
            ADDR,
            CHIP_SELECTS,
            SELECT_ERROR
    );

    parameter masters = 2;
    parameter slaves  = 2;

    input  [masters-1:0] BUS_GRANTS;
    input  [`addr_bits-1:0]        ADDR[masters-1:0];
    output [slaves-1:0]  CHIP_SELECTS;
    output               SELECT_ERROR;

    wire   [`addr_bits-1:0]        address;
    wire   [31:0]        local_selects; 
    wire                 active;

    bmux #(masters, `addr_bits) mux00 (address, BUS_GRANTS, ADDR);

    assign local_selects[00] = (address[31:26] ==  6'b000000) ? 1 : 0;   // SRAM at 0
    assign local_selects[01] = (address[31:16] == 16'h8000)   ? 1 : 0;   // UART at 0x10000000
    assign local_selects[02] = (address[31:16] == 16'ha000)   ? 1 : 0;   // catapult accelerator
    assign local_selects[03] = (address[31:16] == 16'h9000)   ? 1 : 0;   // timer
    assign local_selects[04] = (address[31:26] ==  6'b001000) ? 1 : 0;   // high memory at 0x20000000 ;
    assign local_selects[05] = 0;
    assign local_selects[06] = 0;
    assign local_selects[07] = 0;
    assign local_selects[08] = 0;
    assign local_selects[09] = 0;
    assign local_selects[10] = 0;
    assign local_selects[11] = 0;
    assign local_selects[12] = 0;
    assign local_selects[13] = 0;
    assign local_selects[14] = 0;
    assign local_selects[15] = 0;
    assign local_selects[16] = 0;
    assign local_selects[17] = 0;
    assign local_selects[18] = 0;
    assign local_selects[19] = 0;
    assign local_selects[20] = 0;
    assign local_selects[21] = 0;
    assign local_selects[22] = 0;
    assign local_selects[23] = 0;
    assign local_selects[24] = 0;
    assign local_selects[25] = 0;
    assign local_selects[26] = 0;
    assign local_selects[27] = 0;
    assign local_selects[28] = 0;
    assign local_selects[29] = 0;
    assign local_selects[30] = 0;
    assign local_selects[31] = 0;
    
    assign CHIP_SELECTS = (active) ? local_selects[slaves-1:0] : {31 {1'b0}};
    assign SELECT_ERROR = ((!local_selects) && (active)) ? 1 : 0;
    assign active = (BUS_GRANTS) ? 1 : 0;
 
endmodule
