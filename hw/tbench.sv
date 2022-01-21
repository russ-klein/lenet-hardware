
`timescale 1ns/1ns

`include "axi_bus_defines.svh"

module tbench;

  reg CLK;
  reg nCPURESET;

  wire [`addr_bits-1:0]       TB_MEM_READ_ADDR;
  wire [`data_bits-1:0]       TB_MEM_READ_DATA;
  wire                        TB_MEM_OE;
  wire [`addr_bits-1:0]       TB_MEM_WRITE_ADDR;
  wire [`data_bits-1:0]       TB_MEM_WRITE_DATA;
  wire [`strb_bits-1:0]       TB_MEM_WRITE_BE;
  wire                        TB_MEM_WRITE_STROBE;

  // tbx clkgen inactive_negedge
  initial begin
    CLK = 0;
    forever #50 CLK = ~CLK;
  end

  // tbx clkgen
  initial begin
    nCPURESET = 1;
    #1000 nCPURESET = 0;
    #10000 nCPURESET = 1;
  end

  // DUT
  top top(
    .CLK(CLK), 
    .RESETn(nCPURESET),

    .TB_MEM_READ_ADDR(TB_MEM_READ_ADDR),
    .TB_MEM_READ_DATA(TB_MEM_READ_DATA),
    .TB_MEM_OE(TB_MEM_OE),
    .TB_MEM_WRITE_ADDR(TB_MEM_WRITE_ADDR),
    .TB_MEM_WRITE_DATA(TB_MEM_WRITE_DATA),
    .TB_MEM_WRITE_BE(TB_MEM_WRITE_BE),
    .TB_MEM_WRITE_STROBE(TB_MEM_WRITE_STROBE)
  );

`ifdef CODELINK
   codelink_cpu_CORTEXA53_0 codelink_monitor();
`endif

`ifdef WARPCORE
  // Warpcore Sync
  warpcore_synchronizer ctrl(.CLK(CLK));
`endif

  // test finish

  wire AWVALID0 = tbench.top.AWVALID[0];
  wire [31:0] AWADDR0 = tbench.top.AWADDR[0];
  wire AWVALID1 = tbench.top.AWVALID[1];
  wire [31:0] AWADDR1 = tbench.top.AWADDR[1];
  
  always @(posedge CLK) begin
    if (AWVALID0 == 1 && AWADDR0 == 32'hFF000000) begin
      $display("TEST : PASS");
      $finish;
    end
    else if (AWVALID0 == 1 && AWADDR0 == 32'hFF001000) begin
      $display("TEST : FAIL");
      $finish;
    end
    if (AWVALID1 == 1 && AWADDR1 == 32'hFF000000) begin
      $display("TEST : PASS");
      $finish;
    end
    else if (AWVALID1 == 1 && AWADDR1 == 32'hFF001000) begin
      $display("TEST : FAIL");
      $finish;
    end
  end

  // testbench memory 

`define sram_addr_bits 26
`ifdef BYTE_MEMORY
  sram_byte_corex #(`sram_addr_bits, 4) ssram_high (
`else
  sram_corex #(`sram_addr_bits, 4) ssram_high (
`endif
       .CLK          (CLK),
       .READ_ADDR    (TB_MEM_READ_ADDR[`sram_addr_bits-1:0]),
       .DATA_OUT     (TB_MEM_READ_DATA),
       .OE           (TB_MEM_OE),
       .WRITE_ADDR   (TB_MEM_WRITE_ADDR[`sram_addr_bits-1:0]),
       .DATA_IN      (TB_MEM_WRITE_DATA),
       .BE           (TB_MEM_WRITE_BE),
       .WE           (TB_MEM_WRITE_STROBE)
  );

endmodule
