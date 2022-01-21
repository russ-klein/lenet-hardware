
`timescale 1ns/1ns

`include "axi_bus_defines.svh"
`include "falcon_config.v"

module falcon_clk_gate (
       clk,
       clk_enable_i,
       se_i,
       clk_o
    );

    input clk;
    input clk_enable_i;
    input se_i;
    output clk_o;

    reg clk_enable_lat;

    always @ (clk or clk_enable_i or se_i) begin
        if (~clk) begin
            clk_enable_lat <= clk_enable_i | se_i;
        end
    end

    assign clk_o = clk & clk_enable_lat;
    
endmodule

module top (
    CLK, 
    RESETn, 

    TB_MEM_READ_ADDR,
    TB_MEM_READ_DATA,
    TB_MEM_OE,
    TB_MEM_WRITE_ADDR,
    TB_MEM_WRITE_DATA,
    TB_MEM_WRITE_BE,
    TB_MEM_WRITE_STROBE 

  );

`define masters 2
`define slaves 6
`define waits 0

    input                         CLK;
    input                         RESETn;

    output [`addr_bits-1:0]       TB_MEM_READ_ADDR;
    input  [`data_bits-1:0]       TB_MEM_READ_DATA;
    output                        TB_MEM_OE;
    output [`addr_bits-1:0]       TB_MEM_WRITE_ADDR;
    output [`data_bits-1:0]       TB_MEM_WRITE_DATA;
    output [`strb_bits-1:0]       TB_MEM_WRITE_BE;
    output                        TB_MEM_WRITE_STROBE;

    wire                          CLK_32_kHz;

    wire [3:0]                    nCPURESET;
    wire [3:0]                    nDBGRESET;
    wire [3:0]                    nNEONRESET;
    wire                          nPERIPHRESET;

    // there has got to be some way to embed this in a struct or interface

    wire [`id_bits-1:0]           AWID[`masters-1:0];
    wire [`addr_bits-1:0]         AWADDR[`masters-1:0];
    wire [`len_bits-1:0]          AWLEN[`masters-1:0];
    wire [`size_bits-1:0]         AWSIZE[`masters-1:0];
    wire [`burst_bits-1:0]        AWBURST[`masters-1:0];
    wire [`lock_bits-1:0]         AWLOCK[`masters-1:0];
    wire [`cache_bits-1:0]        AWCACHE[`masters-1:0];
    wire [`prot_bits-1:0]         AWPROT[`masters-1:0];
    wire                          AWVALID[`masters-1:0];
    wire                          AWREADY[`masters-1:0];
    wire [`wuser_bits-1:0]        AWUSER[`masters-1:0];
    wire [1:0]                    AWBAR[`masters-1:0];
    wire [1:0]                    AWDOMAIN[`masters-1:0];
    wire [2:0]                    AWSNOOP[`masters-1:0];
    wire [3:0]                    AWQOS[`masters-1:0];
    wire [3:0]                    AWREGION[`masters-1:0];
    wire                          AWUNIQUE[`masters-1:0];

    wire [`id_bits-1:0]           WID[`masters-1:0];
    wire [`data_bits-1:0]         WDATA[`masters-1:0];
    wire [`strb_bits-1:0]         WSTRB[`masters-1:0];
    wire                          WLAST[`masters-1:0];
    wire                          WVALID[`masters-1:0];
    wire                          WREADY[`masters-1:0];
    wire                          WUSER[`masters-1:0];

    wire [`id_bits-1:0]           BID[`masters-1:0];
    wire [`resp_bits-1:0]         BRESP[`masters-1:0];
    wire                          BVALID[`masters-1:0];
    wire                          BREADY[`masters-1:0];
    wire                          BUSER[`masters-1:0];

    wire [`id_bits-1:0]           ARID[`masters-1:0];
    wire [`addr_bits-1:0]         ARADDR[`masters-1:0];
    wire [`len_bits-1:0]          ARLEN[`masters-1:0];
    wire [`size_bits-1:0]         ARSIZE[`masters-1:0];
    wire [`burst_bits-1:0]        ARBURST[`masters-1:0];
    wire [`lock_bits-1:0]         ARLOCK[`masters-1:0];
    wire [`cache_bits-1:0]        ARCACHE[`masters-1:0];
    wire [`prot_bits-1:0]         ARPROT[`masters-1:0];
    wire                          ARVALID[`masters-1:0]; 
    wire                          ARREADY[`masters-1:0];
    wire [`ruser_bits-1:0]        ARUSER[`masters-1:0];
    wire [1:0]                    ARBAR[`masters-1:0];
    wire [1:0]                    ARDOMAIN[`masters-1:0];
    wire [3:0]                    ARQOS[`masters-1:0];
    wire [3:0]                    ARREGION[`masters-1:0];
    wire [3:0]                    ARSNOOP[`masters-1:0];
/*
    wire                          ACREADY[`masters-1:0];
    wire                          ACVALID[`masters-1:0];
    wire                          ACADDR[`masters-1:0];
    wire                          ACPROT[`masters-1:0];
    wire                          ACSNOOP[`masters-1:0];
    
    wire                          CRREADY[`masters-1:0];
    wire                          CRVALID[`masters-1:0];
    wire                          CRRESP[`masters-1:0];
    wire                          CDREADY[`masters-1:0];
    wire                          CDVALID[`masters-1:0];
    wire                          CDDATA[`masters-1:0];
    wire                          CDLAST[`masters-1:0];

    wire                          RACK[`masters-1:0];
    wire                          WACK[`masters-1:0];
*/

    wire [`id_bits-1:0]           RID[`masters-1:0];
    wire [`data_bits-1:0]         RDATA[`masters-1:0];
    wire [`resp_bits-1:0]         RRESP[`masters-1:0];
    wire                          RLAST[`masters-1:0];
    wire                          RVALID[`masters-1:0];
    wire                          RREADY[`masters-1:0];
    wire                          RUSER[`masters-1:0];

    wire [`masters-1:0]           S_AWMASTER[`slaves-1:0];
    wire [`slave_id_bits-1:0]     S_AWID[`slaves-1:0];
    wire [`addr_bits-1:0]         S_AWADDR[`slaves-1:0];
    wire [`len_bits-1:0]          S_AWLEN[`slaves-1:0];
    wire [`size_bits-1:0]         S_AWSIZE[`slaves-1:0];
    wire [`burst_bits-1:0]        S_AWBURST[`slaves-1:0];
    wire [`lock_bits-1:0]         S_AWLOCK[`slaves-1:0];
    wire [`cache_bits-1:0]        S_AWCACHE[`slaves-1:0];
    wire [`prot_bits-1:0]         S_AWPROT[`slaves-1:0];
    wire [3:0]                    S_AWQOS[`slaves-1:0];
    wire [3:0]                    S_AWREGION[`slaves-1:0];
    wire                          S_AWVALID[`slaves-1:0];
    wire                          S_AWREADY[`slaves-1:0];
    wire [`wuser_bits-1:0]        S_AWUSER[`slaves-1:0];

    wire [`masters-1:0]           S_WMASTER[`slaves-1:0];
    wire [`slave_id_bits-1:0]     S_WID[`slaves-1:0];
    wire [`data_bits-1:0]         S_WDATA[`slaves-1:0];
    wire [`strb_bits-1:0]         S_WSTRB[`slaves-1:0];
    wire                          S_WLAST[`slaves-1:0];
    wire                          S_WVALID[`slaves-1:0];
    wire                          S_WREADY[`slaves-1:0];

    wire [`masters-1:0]           S_BMASTER[`slaves-1:0];
    wire [`slave_id_bits-1:0]     S_BID[`slaves-1:0];
    wire [`resp_bits-1:0]         S_BRESP[`slaves-1:0];
    wire                          S_BVALID[`slaves-1:0];
    wire                          S_BREADY[`slaves-1:0];

    wire [`masters-1:0]           S_ARMASTER[`slaves-1:0];
    wire [`slave_id_bits-1:0]     S_ARID[`slaves-1:0];
    wire [`addr_bits-1:0]         S_ARADDR[`slaves-1:0];
    wire [`len_bits-1:0]          S_ARLEN[`slaves-1:0];
    wire [`size_bits-1:0]         S_ARSIZE[`slaves-1:0];
    wire [`burst_bits-1:0]        S_ARBURST[`slaves-1:0];
    wire [`lock_bits-1:0]         S_ARLOCK[`slaves-1:0];
    wire [`cache_bits-1:0]        S_ARCACHE[`slaves-1:0];
    wire [`prot_bits-1:0]         S_ARPROT[`slaves-1:0];
    wire [3:0]                    S_ARQOS[`slaves-1:0];
    wire [3:0]                    S_ARREGION[`slaves-1:0];
    wire                          S_ARVALID[`slaves-1:0]; 
    wire                          S_ARREADY[`slaves-1:0];
    wire [`ruser_bits-1:0]        S_ARUSER[`slaves-1:0];

    wire [`masters-1:0]           S_RMASTER[`slaves-1:0];
    wire [`slave_id_bits-1:0]     S_RID[`slaves-1:0];
    wire [`data_bits-1:0]         S_RDATA[`slaves-1:0];
    wire [`resp_bits-1:0]         S_RRESP[`slaves-1:0];
    wire                          S_RLAST[`slaves-1:0];
    wire                          S_RVALID[`slaves-1:0];
    wire                          S_RREADY[`slaves-1:0];

    wire                          ACLKEN[`masters-1:0];
    wire [1:0]                    INCLKEN = 2'b11;
    wire [1:0]                    OUTCLKEN = 2'b11;
    wire [23:0]                   SRID = 24'h000000;
    wire [3:0]                    SREND = 4'h0;


    wire [`addr_bits-1:0]         SSRAM_LOW_READ_ADDR;
    wire [`data_bits-1:0]         SSRAM_LOW_READ_DATA;
    wire                          SSRAM_LOW_OE;
    wire [`addr_bits-1:0]         SSRAM_LOW_WRITE_ADDR;
    wire [`data_bits-1:0]         SSRAM_LOW_WRITE_DATA;
    wire [`strb_bits-1:0]         SSRAM_LOW_WRITE_BE;
    wire                          SSRAM_LOW_WRITE_STROBE;

    wire [`addr_bits-1:0]         UART_READ_ADDR;
    wire [`data_bits-1:0]         UART_READ_DATA;
    wire                          UART_OE;
    wire [`addr_bits-1:0]         UART_WRITE_ADDR;
    wire [`data_bits-1:0]         UART_WRITE_DATA;
    wire [`strb_bits-1:0]         UART_WRITE_BE;
    wire                          UART_WRITE_STROBE;

    wire [15:0]                   CAT_READ_ADDR;
    wire [`data_bits-1:0]         CAT_READ_DATA;
    wire                          CAT_OE;
    wire [15:0]                   CAT_WRITE_ADDR;
    wire [`data_bits-1:0]         CAT_WRITE_DATA;
    wire [`strb_bits-1:0]         CAT_WRITE_BE;
    wire                          CAT_WRITE_STROBE;

    wire [15:0]                   TIMER_READ_ADDR;
    wire [`data_bits-1:0]         TIMER_READ_DATA;
    wire                          TIMER_OE;
    wire [15:0]                   TIMER_WRITE_ADDR;
    wire [`data_bits-1:0]         TIMER_WRITE_DATA;
    wire [`strb_bits-1:0]         TIMER_WRITE_BE;
    wire                          TIMER_WRITE_STROBE;

    wire [`addr_bits-1:0]         SSRAM_HIGH_READ_ADDR;
    wire [`data_bits-1:0]         SSRAM_HIGH_READ_DATA;
    wire                          SSRAM_HIGH_OE;
    wire [`addr_bits-1:0]         SSRAM_HIGH_WRITE_ADDR;
    wire [`data_bits-1:0]         SSRAM_HIGH_WRITE_DATA;
    wire [`strb_bits-1:0]         SSRAM_HIGH_WRITE_BE;
    wire                          SSRAM_HIGH_WRITE_STROBE;

    // Clock Signals
    wire                          CLKIN;
    // Reset Signals
    wire  [  0: 0]                nCPUPORESET;
    wire  [  0: 0]                nCORERESET;
    wire  [  0: 0]                WARMRSTREQ;
    reg                           nL2RESET; //         = 1'b0;
    reg                           L2RSTDISABLE     = 1'b0;
    // Configuration Signals
    reg   [  0: 0]                CFGEND           = 1'b0;
    reg   [  0: 0]                VINITHI          = 1'b0;
    reg   [  0: 0]                CFGTE            = 1'b0;
    reg   [  0: 0]                CP15SDISABLE     = 1'b0;
    reg   [  7: 0]                CLUSTERIDAFF1    = 8'h00;
    reg   [  7: 0]                CLUSTERIDAFF2    = 8'h00;
    reg   [  0: 0]                AA64nAA32        = 1'b1;
    reg   [ 39: 2]                RVBARADDR0       = 1'b0;
    // Interrupt Signals
    reg   [  0: 0]                nFIQ             = 1'b1;
    reg   [  0: 0]                nIRQ;
    reg   [  0: 0]                nSEI             = 1'b1;
    reg   [  0: 0]                nVFIQ            = 1'b1;
    reg   [  0: 0]                nVIRQ            = 1'b1;
    reg   [  0: 0]                nVSEI            = 1'b1;
    reg   [  0: 0]                nREI             = 1'b1;
    wire  [  0: 0]                nVCPUMNTIRQ      = 1'b1;
    reg   [ 39:18]                PERIPHBASE       = 22'h3C0000;
    reg                           GICCDISABLE      = 1'b1;
    reg                           ICDTVALID        = 1'b0;
    wire                          ICDTREADY;
    reg   [ 15: 0]                ICDTDATA         = 16'h0000;
    reg                           ICDTLAST         = 1'b0;
    reg   [  1: 0]                ICDTDEST         = 2'b00;
    wire                          ICCTVALID;
    reg                           ICCTREADY        = 1'b0;
    wire  [ 15: 0]                ICCTDATA         = 16'h0000;
    wire                          ICCTLAST         = 1'b0;
    wire  [  1: 0]                ICCTID;
    // Generic Timer Signals
    reg   [ 63: 0]                CNTVALUEB        = 64'h0000000000000000;
    reg                           CNTCLKEN         = 1'b0;
    wire  [  0: 0]                nCNTPNSIRQ;
    wire  [  0: 0]                nCNTPSIRQ;
    wire  [  0: 0]                nCNTVIRQ;
    wire  [  0: 0]                nCNTHPIRQ;
    // Power Management S  ignals (Non-Retention)
    reg                           CLREXMONREQ      = 1'b0;
    wire                          CLREXMONACK;
    reg                           EVENTI           = 1'b0;
    wire                          EVENTO;
    wire  [  0: 0]                STANDBYWFI;
    wire  [  0: 0]                STANDBYWFE;
    wire                          STANDBYWFIL2;
    reg                           L2FLUSHREQ       = 1'b0;
    wire                          L2FLUSHDONE;
    wire  [  0: 0]                SMPEN;
    // Power Management Signals (Retention)
    wire  [  0: 0]                CPUQACTIVE;
    reg   [  0: 0]                CPUQREQn         = 1'b1;
    wire  [  0: 0]                CPUQDENY;
    wire  [  0: 0]                CPUQACCEPTn;
    wire  [  0: 0]                NEONQACTIVE;
    reg   [  0: 0]                NEONQREQn        = 1'b1;
    wire  [  0: 0]                NEONQDENY;
    wire  [  0: 0]                NEONQACCEPTn;

    wire                          L2QACTIVE;
    reg                           L2QREQn          = 1'b1;
    wire                          L2QDENY;
    wire                          L2QACCEPTn;
    // L2 Error Signals
    wire                          nINTERRIRQ;
    // ACE and Skyros Interface Signals
    wire                          nEXTERRIRQ;
    reg                           BROADCASTCACHEMAINT = 1'b0;
    reg                           BROADCASTINNER   = 1'b0;
    reg                           BROADCASTOUTER   = 1'b0;
    reg                           SYSBARDISABLE    = 1'b1;
    // ACE Interface; Clock and Configuration Signals
    reg                           ACLKENM          = 1'b1;
    reg                           ACINACTM         = 1'b1;
    wire [  7: 0]                 RDMEMATTR;
    wire [  7: 0]                 WRMEMATTR;
    // ACE Interface; Coherency Address Channel Signals
    wire                          ACREADYM;
    reg                           ACVALIDM         = 1'b0;
    reg   [ 43: 0]                ACADDRM          = { 44 { 1'b0 } };
    reg   [  2: 0]                ACPROTM          = {  3 { 1'b0 } };
    reg   [  3: 0]                ACSNOOPM         = {  4 { 1'b0 } };
    // ACE Interface; Coherency Response Channel Signals
    reg                           CRREADYM         = 1'b0;
    wire                          CRVALIDM;
    wire  [  4: 0]                CRRESPM;
    // ACE Interface; Coherency Data Channel Signals
    reg                           CDREADYM         = 1'b0;
    wire                          CDVALIDM;
    wire  [127: 0]                CDDATAM          = { 128 { 1'b0 } };
    wire                          CDLASTM          = 1'b0;
    // ACE Interface; Read/Write Acknowledge Signals
    wire                          RACKM;
    wire                          WACKM;
    // ACP Interface; Clock and Configuration Signals
    reg                           ACLKENS          = 1'b0;
    reg                           AINACTS          = 1'b0;
    // ACP Interface; Write Address Channel Signals
    wire                          AWREADYS;
    reg                           AWVALIDS         = 1'b0;
    reg   [  4: 0]                AWIDS            = {  5 { 1'b0 }};
    reg   [ 39: 0]                AWADDRS          = { 40 { 1'b0 }};
    reg   [  7: 0]                AWLENS           = {  8 { 1'b0 }};
    reg   [  3: 0]                AWCACHES         = {  4 { 1'b0 }};
    reg   [  1: 0]                AWUSERS          = {  2 { 1'b0 }};
    reg   [  2: 0]                AWPROTS          = {  3 { 1'b0 }};
    // ACP Interface; Write Data Channel Signals
    wire                          WREADYS;
    reg                           WVALIDS          = 1'b0;
    reg   [127: 0]                WDATAS           = { 128 { 1'b0 }};
    reg   [ 15: 0]                WSTRBS           = {  16 { 1'b0 }};
    reg                           WLASTS           = 1'b0;
    // ACP Interface; Write Response Channel Signals
    reg                           BREADYS          = 1'b0;
    wire                          BVALIDS;
    wire  [  4: 0]                BIDS;
    wire  [  1: 0]                BRESPS;
    // ACP Interface; Read Address Channel Signals
    wire                          ARREADYS;
    reg                           ARVALIDS         = 1'b0;
    reg   [  4: 0]                ARIDS            = {  5 { 1'b0 }};
    reg   [ 39: 0]                ARADDRS          = { 40 { 1'b0 }};
    reg   [  7: 0]                ARLENS           = {  8 { 1'b0 }};
    reg   [  3: 0]                ARCACHES         = {  4 { 1'b0 }};
    reg   [  1: 0]                ARUSERS          = {  2 { 1'b0 }};
    reg   [  2: 0]                ARPROTS          = {  3 { 1'b0 }};
    // ACP Interface; Read Data Channel Signals
    reg                           RREADYS          = 1'b0;
    wire                          RVALIDS;
    wire  [  4: 0]                RIDS;
    wire  [127: 0]                RDATAS;
    wire  [  1: 0]                RRESPS;
    wire                          RLASTS;
    // APB Interface Signals
    reg                           nPRESETDBG;
    reg                           PCLKENDBG;
    reg                           PSELDBG          = 1'b0;
    reg   [ 21: 2]                PADDRDBG         = 19'h0;
    reg                           PADDRDBG31       = 1'b0;
    reg                           PENABLEDBG       = 1'b0;
    reg                           PWRITEDBG        = 1'b0;
    reg   [ 31: 0]                PWDATADBG        = 32'h00000000;
    wire  [ 31: 0]                PRDATADBG;
    wire                          PREADYDBG;
    wire                          PSLVERRDBG;
    // Miscellaneous Debug Signals
    reg   [ 39:12]                DBGROMADDR       = 28'h0000000;
    reg                           DBGROMADDRV      = 1'b0;
    wire  [  0: 0]                DBGACK;
    wire  [  0: 0]                nCOMMIRQ;
    wire  [  0: 0]                COMMRX;
    wire  [  0: 0]                COMMTX;
    reg   [  0: 0]                EDBGRQ           = 1'b0;
    reg   [  0: 0]                DBGEN            = 1'b0;
    reg   [  0: 0]                NIDEN            = 1'b0;
    reg   [  0: 0]                SPIDEN           = 1'b0;
    reg   [  0: 0]                SPNIDEN          = 1'b0;
    wire  [  0: 0]                DBGRSTREQ;
    wire  [  0: 0]                DBGNOPWRDWN;
    reg   [  0: 0]                DBGPWRDUP        = 1'b0;
    wire  [  0: 0]                DBGPWRUPREQ;
    reg                           DBGL1RSTDISABLE  = 1'b0;
    // ATB Interface Signals
    reg                           ATCLKEN          = 1'b0;
    reg                           ATREADYM0        = 1'b0;
    reg                           AFVALIDM0        = 1'b0;
    wire  [ 31: 0]                ATDATAM0;
    wire                          ATVALIDM0;
    wire  [  1: 0]                ATBYTESM0;
    wire                          AFREADYM0;
    wire  [  6: 0]                ATIDM0;
    // Miscellaneous ETM Signals
    reg                           SYNCREQM0        = 1'b0;
    reg   [ 63: 0]                TSVALUEB         = 1'b0;
    // CTI Interface Signals
    reg   [  3: 0]                CTICHIN          = 1'b0;
    reg   [  3: 0]                CTICHOUTACK      = 1'b0;
    wire  [  3: 0]                CTICHOUT;
    wire  [  3: 0]                CTICHINACK;
    reg                           CISBYPASS        = 1'b0;
    reg   [  3: 0]                CIHSBYPASS       = 1'b0;
    wire  [  0: 0]                CTIIRQ;
    reg   [  0: 0]                CTIIRQACK        = 1'b0;
    // PMU Signals
    wire  [  0: 0]                nPMUIRQ;
    wire  [ 29: 0]                PMUEVENT0;
    // DFT Signals
    reg                           DFTSE            = 1'b0;
    reg                           DFTRSTDISABLE    = 1'b0;
    reg                           DFTRAMHOLD       = 1'b0;
    reg                           DFTMCPHOLD       = 1'b0;
    // MBIST Interface Signals
    reg                           MBISTREQ         = 1'b0;
    reg                           nMBISTRESET      = 1'b1;
  
//  reg                           ic_clken_reg;
//  wire                          nSCURESET;

    wire                          CTS;
    wire                          DSR;
    wire                          DCD;
    wire                          RI;
    wire                          RTS;
    wire                          DTR;
    wire                          OUT;
    wire                          RXD;
    wire                          TXD;

    wire [7:0]                    data_in;
    wire                          dis;
    wire [7:0]                    data_out;
    wire                          dos;

    genvar m;

    generate 
       for (m=0; m<`masters; m++) begin
          assign ACLKEN[m]           =  1'b1;
       end
    endgenerate

    //-----------------------------------------------------------------------------
    // CPU Reset Control
    //-----------------------------------------------------------------------------
    
    assign  CLKIN          = CLK;
    assign  nCPUPORESET    = RESETn;
    assign  nCORERESET     = RESETn;
    assign  nSCURESET      = RESETn;
    assign  nPERIPHRESET   = RESETn;
    assign  nIRQ           = 1'b1;
    assign  nPRESETDBG     = RESETn;
    assign  PCLKENDBG      = 1'b0;
    assign  nL2RESET       = RESETn;
    
`ifdef VERBOSE
    always @(posedge CLK) begin
        if (AWREADY[0] && AWVALID[0])            $display ("Start write cycle on 0 %2x %8x ", AWID[0], AWADDR[0]);
        if (AWREADY[1] && AWVALID[1])            $display ("Start write cycle on 1 %2x %8x ", AWID[1], AWADDR[1]);
        if (BREADY[0]  && BVALID[0])             $display ("End write cycle on   0 %2x ", BID[0]);
        if (BREADY[1]  && BVALID[1])             $display ("End write cycle on   1 %2x ", BID[1]);
        if (ARREADY[0] && ARVALID[0])            $display ("Start read cycle on  0 %2x %8x ", ARID[0], ARADDR[0]);
        if (ARREADY[1] && ARVALID[1])            $display ("Start read cycle on  1 %2x %8x ", ARID[1], ARADDR[1]);
        if (RREADY[0]  && RREADY[0] && RLAST[0]) $display ("End read cycle on    0 %2x ", RID[0]);
        if (RREADY[1]  && RREADY[1] && RLAST[1]) $display ("End read cycle on    1 %2x ", RID[1]);
    end

/*
    always @(posedge CLK) begin
        if (AWREADY[0] && AWVALID[0]) $display("Write on 0: ADDR: ", AWADDR[0] & 32'hfffffff8);
        if (AWREADY[1] && AWVALID[1]) $display("Write on 1: ADDR: ", AWADDR[1] & 32'hfffffff8);
        if (WREADY[0]  && WVALID[0])  $display("Write on 0: DATA:        ", WDATA[0]);
        if (WREADY[1]  && WVALID[1])  $display("Write on 1: DATA:        ", WDATA[1]);
    end
*/
`endif
/*
    always @ (posedge CLK or negedge nSCURESET) 
    begin
        if (~nSCURESET) begin
            ic_clken_reg <= 1'b0;
        end else begin
            ic_clken_reg <= ~ic_clken_reg;
        end
    end

    assign PERIPHCLKEN = ic_clken_reg;

    falcon_clk_gate u_clk_gate (
        .clk          (CLK),
        .clk_enable_i (ic_clken_reg),
        .se_i         (1'b0),
        .clk_o        (PERIPHCLK)
    );
*/

    axi4_interconnect_NxN #( 
        .AXI4_ADDRESS_WIDTH (44),
        .AXI4_DATA_WIDTH (128),
        .AXI4_ID_WIDTH (`id_bits),
        .N_MASTERS (`masters),
        .N_SLAVES (`slaves-1),
        .ADDR_RANGES  ( {44'h000_0000_0000, 44'h000_00ff_ffff,
                         44'h000_8000_0000, 44'h000_8000_ffff,
                         44'h000_A000_0000, 44'h000_A000_ffff,
                         44'h000_9000_0000, 44'h000_9000_ffff,
                         44'h000_4000_0000, 44'h000_40ff_ffff })
    )
    bus_matrix (
        .clk         (CLK),
        .rstn        (RESETn),

        .AWID        (AWID),
        .AWADDR      (AWADDR),
        .AWLEN       (AWLEN),
        .AWSIZE      (AWSIZE),
        .AWBURST     (AWBURST),
        .AWLOCK      (AWLOCK),
        .AWCACHE     (AWCACHE),
        .AWPROT      (AWPROT),
        .AWQOS       (AWQOS),
        .AWREGION    (AWREGION),
        .AWVALID     (AWVALID),
        .AWREADY     (AWREADY),

        .ARID        (ARID),
        .ARADDR      (ARADDR),
        .ARLEN       (ARLEN),
        .ARSIZE      (ARSIZE),
        .ARBURST     (ARBURST),
        .ARLOCK      (ARLOCK),
        .ARCACHE     (ARCACHE),
        .ARPROT      (ARPROT),
        .ARQOS       (ARQOS),
        .ARREGION    (ARREGION),
        .ARVALID     (ARVALID),
        .ARREADY     (ARREADY),

        .BID         (BID),
        .BRESP       (BRESP),
        .BVALID      (BVALID),
        .BREADY      (BREADY),

        .RID         (RID),
        .RDATA       (RDATA),
        .RRESP       (RRESP),
        .RLAST       (RLAST),
        .RVALID      (RVALID),
        .RREADY      (RREADY),

        // .WID         (WID),
        .WDATA       (WDATA),
        .WSTRB       (WSTRB),
        .WLAST       (WLAST),
        .WVALID      (WVALID),
        .WREADY      (WREADY),

        .SAWID        (S_AWID),
        .SAWADDR      (S_AWADDR),
        .SAWLEN       (S_AWLEN),
        .SAWSIZE      (S_AWSIZE),
        .SAWBURST     (S_AWBURST),
        .SAWLOCK      (S_AWLOCK),
        .SAWCACHE     (S_AWCACHE),
        .SAWPROT      (S_AWPROT),
        .SAWQOS       (S_AWQOS),
        .SAWREGION    (S_AWREGION),
        .SAWVALID     (S_AWVALID),
        .SAWREADY     (S_AWREADY),

        .SARID        (S_ARID),
        .SARADDR      (S_ARADDR),
        .SARLEN       (S_ARLEN),
        .SARSIZE      (S_ARSIZE),
        .SARBURST     (S_ARBURST),
        .SARLOCK      (S_ARLOCK),
        .SARCACHE     (S_ARCACHE),
        .SARPROT      (S_ARPROT),
        .SARQOS       (S_ARQOS),
        .SARREGION    (S_ARREGION),
        .SARVALID     (S_ARVALID),
        .SARREADY     (S_ARREADY),

        .SBID         (S_BID),
        .SBRESP       (S_BRESP),
        .SBVALID      (S_BVALID),
        .SBREADY      (S_BREADY),

        .SRID         (S_RID),
        .SRDATA       (S_RDATA),
        .SRRESP       (S_RRESP),
        .SRLAST       (S_RLAST),
        .SRVALID      (S_RVALID),
        .SRREADY      (S_RREADY),

        // .SWID         (S_WID),
        .SWDATA       (S_WDATA),
        .SWSTRB       (S_WSTRB),
        .SWLAST       (S_WLAST),
        .SWVALID      (S_WVALID),
        .SWREADY      (S_WREADY)
    );

/*
    //AXI switch fabric

    axi_matrix #(`masters, `slaves, 1) bus_matrix (

        .ACLK        (CLK),
        .ARESETn     (RESETn),

        .AWID        (AWID),
        .AWADDR      (AWADDR),
        .AWLEN       (AWLEN),
        .AWSIZE      (AWSIZE),
        .AWBURST     (AWBURST),
        .AWLOCK      (AWLOCK),
        .AWCACHE     (AWCACHE),
        .AWPROT      (AWPROT),
        .AWVALID     (AWVALID),
        .AWREADY     (AWREADY),

        .WID         (WID),
        .WDATA       (WDATA),
        .WSTRB       (WSTRB),
        .WLAST       (WLAST),
        .WVALID      (WVALID),
        .WREADY      (WREADY),

        .BID         (BID),
        .BRESP       (BRESP),
        .BVALID      (BVALID),
        .BREADY      (BREADY),

        .ARID        (ARID),
        .ARADDR      (ARADDR),
        .ARLEN       (ARLEN),
        .ARSIZE      (ARSIZE),
        .ARBURST     (ARBURST),
        .ARLOCK      (ARLOCK),
        .ARCACHE     (ARCACHE),
        .ARPROT      (ARPROT),
        .ARVALID     (ARVALID),
        .ARREADY     (ARREADY),

        .RID         (RID),
        .RDATA       (RDATA),
        .RRESP       (RRESP),
        .RLAST       (RLAST),
        .RVALID      (RVALID),
        .RREADY      (RREADY),

        .S_AWMASTER  (S_AWMASTER),
        .S_AWID      (S_AWID),
        .S_AWADDR    (S_AWADDR),
        .S_AWLEN     (S_AWLEN),
        .S_AWSIZE    (S_AWSIZE),
        .S_AWBURST   (S_AWBURST),
        .S_AWLOCK    (S_AWLOCK),
        .S_AWCACHE   (S_AWCACHE),
        .S_AWPROT    (S_AWPROT),
        .S_AWVALID   (S_AWVALID),
        .S_AWREADY   (S_AWREADY),

        .S_WMASTER   (S_WMASTER),
        .S_WID       (S_WID),
        .S_WDATA     (S_WDATA),
        .S_WSTRB     (S_WSTRB),
        .S_WLAST     (S_WLAST),
        .S_WVALID    (S_WVALID),
        .S_WREADY    (S_WREADY),

        .S_BMASTER   (S_BMASTER),
        .S_BID       (S_BID),
        .S_BRESP     (S_BRESP),
        .S_BVALID    (S_BVALID),
        .S_BREADY    (S_BREADY),

        .S_ARMASTER  (S_ARMASTER),
        .S_ARID      (S_ARID),
        .S_ARADDR    (S_ARADDR),
        .S_ARLEN     (S_ARLEN),
        .S_ARSIZE    (S_ARSIZE),
        .S_ARBURST   (S_ARBURST),
        .S_ARLOCK    (S_ARLOCK),
        .S_ARCACHE   (S_ARCACHE),
        .S_ARPROT    (S_ARPROT),
        .S_ARVALID   (S_ARVALID),
        .S_ARREADY   (S_ARREADY),

        .S_RMASTER   (S_RMASTER),
        .S_RID       (S_RID),
        .S_RDATA     (S_RDATA),
        .S_RRESP     (S_RRESP),
        .S_RLAST     (S_RLAST),
        .S_RVALID    (S_RVALID),
        .S_RREADY    (S_RREADY),

        .CSYSREQ     (CSYSREQ),
        .CSYSACK     (CSYSACK),
        .CACTIVE     (CACTIVE)
    );

*/

`define sram_low_addr_bits 18

    axi_slave_interface 
        #(
        .masters    (`masters), 
        .width      (`sram_low_addr_bits),
        .id_bits    (`slave_id_bits),
        .p_size     (4),
        .b_size     (4))
       
        ssram_low_if (

        .ACLK      (CLK),
        .ARESETn   (RESETn),
 
        .AWMASTER  (S_AWMASTER[0]),
        .AWID      (S_AWID[0]),
        .AWADDR    (S_AWADDR[0][`sram_low_addr_bits-1:0]),
        .AWLEN     (S_AWLEN[0]),
        .AWSIZE    (S_AWSIZE[0]),
        .AWBURST   (S_AWBURST[0]),
        .AWLOCK    (S_AWLOCK[0]),
        .AWCACHE   (S_AWCACHE[0]),
        .AWPROT    (S_AWPROT[0]),
        .AWVALID   (S_AWVALID[0]),
        .AWREADY   (S_AWREADY[0]),

        .WMASTER   (S_WMASTER[0]),
        .WID       (S_WID[0]),
        .WDATA     (S_WDATA[0]),
        .WSTRB     (S_WSTRB[0]),
        .WLAST     (S_WLAST[0]),
        .WVALID    (S_WVALID[0]),
        .WREADY    (S_WREADY[0]),

        .BMASTER   (S_BMASTER[0]),
        .BID       (S_BID[0]),
        .BRESP     (S_BRESP[0]),
        .BVALID    (S_BVALID[0]),
        .BREADY    (S_BREADY[0]),

        .ARMASTER  (S_ARMASTER[0]),
        .ARID      (S_ARID[0]),
        .ARADDR    (S_ARADDR[0][`sram_low_addr_bits-1:0]),
        .ARLEN     (S_ARLEN[0]),
        .ARSIZE    (S_ARSIZE[0]),
        .ARBURST   (S_ARBURST[0]),
        .ARLOCK    (S_ARLOCK[0]),
        .ARCACHE   (S_ARCACHE[0]),
        .ARPROT    (S_ARPROT[0]),
        .ARVALID   (S_ARVALID[0]),
        .ARREADY   (S_ARREADY[0]),

        .RMASTER   (S_RMASTER[0]),
        .RID       (S_RID[0]),
        .RDATA     (S_RDATA[0]),
        .RRESP     (S_RRESP[0]),
        .RLAST     (S_RLAST[0]),
        .RVALID    (S_RVALID[0]),
        .RREADY    (S_RREADY[0]),

        .SRAM_READ_ADDRESS       (SSRAM_LOW_READ_ADDR[`sram_low_addr_bits-1:0]),
        .SRAM_READ_DATA          (SSRAM_LOW_READ_DATA),
        .SRAM_OUTPUT_ENABLE      (SSRAM_LOW_OE),
 
        .SRAM_WRITE_ADDRESS      (SSRAM_LOW_WRITE_ADDR[`sram_low_addr_bits-1:0]),
        .SRAM_WRITE_DATA         (SSRAM_LOW_WRITE_DATA),
        .SRAM_WRITE_BYTE_ENABLE  (SSRAM_LOW_WRITE_BE),
        .SRAM_WRITE_STROBE       (SSRAM_LOW_WRITE_STROBE) 
    );

`ifdef BYTE_MEMORY
    sram_byte_corex #(`sram_low_addr_bits, 4) ssram_low (
         .CLK          (CLK),
         .READ_ADDR    (SSRAM_LOW_READ_ADDR[`sram_low_addr_bits-1:0]),
         .DATA_OUT     (SSRAM_LOW_READ_DATA),
         .OE           (SSRAM_LOW_OE),
         .WRITE_ADDR   (SSRAM_LOW_WRITE_ADDR[`sram_low_addr_bits-1:0]),
         .DATA_IN      (SSRAM_LOW_WRITE_DATA),
         .BE           (SSRAM_LOW_WRITE_BE),
         .WE           (SSRAM_LOW_WRITE_STROBE)
    ); 
`else
    sram_corex #(`sram_low_addr_bits, 4) ssram_low (
         .CLK          (CLK),
         .READ_ADDR    (SSRAM_LOW_READ_ADDR[`sram_low_addr_bits-1:0]),
         .DATA_OUT     (SSRAM_LOW_READ_DATA),
         .OE           (SSRAM_LOW_OE),
         .WRITE_ADDR   (SSRAM_LOW_WRITE_ADDR[`sram_low_addr_bits-1:0]),
         .DATA_IN      (SSRAM_LOW_WRITE_DATA),
         .BE           (SSRAM_LOW_WRITE_BE),
         .WE           (SSRAM_LOW_WRITE_STROBE)
    ); 
`endif

`define sram_high_addr_bits 26 

    axi_slave_interface 
        #(
        .masters    (`masters), 
        .width      (`sram_high_addr_bits),
        .id_bits    (`slave_id_bits),
        .p_size     (4),
        .b_size     (4))
       
        ssram_high_if (

        .ACLK      (CLK),
        .ARESETn   (RESETn),
 
        .AWMASTER  (S_AWMASTER[4]),
        .AWID      (S_AWID[4]),
        .AWADDR    (S_AWADDR[4][`sram_high_addr_bits-1:0]),
        .AWLEN     (S_AWLEN[4]),
        .AWSIZE    (S_AWSIZE[4]),
        .AWBURST   (S_AWBURST[4]),
        .AWLOCK    (S_AWLOCK[4]),
        .AWCACHE   (S_AWCACHE[4]),
        .AWPROT    (S_AWPROT[4]),
        .AWVALID   (S_AWVALID[4]),
        .AWREADY   (S_AWREADY[4]),

        .WMASTER   (S_WMASTER[4]),
        .WID       (S_WID[4]),
        .WDATA     (S_WDATA[4]),
        .WSTRB     (S_WSTRB[4]),
        .WLAST     (S_WLAST[4]),
        .WVALID    (S_WVALID[4]),
        .WREADY    (S_WREADY[4]),

        .BMASTER   (S_BMASTER[4]),
        .BID       (S_BID[4]),
        .BRESP     (S_BRESP[4]),
        .BVALID    (S_BVALID[4]),
        .BREADY    (S_BREADY[4]),

        .ARMASTER  (S_ARMASTER[4]),
        .ARID      (S_ARID[4]),
        .ARADDR    (S_ARADDR[4][`sram_high_addr_bits-1:0]),
        .ARLEN     (S_ARLEN[4]),
        .ARSIZE    (S_ARSIZE[4]),
        .ARBURST   (S_ARBURST[4]),
        .ARLOCK    (S_ARLOCK[4]),
        .ARCACHE   (S_ARCACHE[4]),
        .ARPROT    (S_ARPROT[4]),
        .ARVALID   (S_ARVALID[4]),
        .ARREADY   (S_ARREADY[4]),

        .RMASTER   (S_RMASTER[4]),
        .RID       (S_RID[4]),
        .RDATA     (S_RDATA[4]),
        .RRESP     (S_RRESP[4]),
        .RLAST     (S_RLAST[4]),
        .RVALID    (S_RVALID[4]),
        .RREADY    (S_RREADY[4]),

        .SRAM_READ_ADDRESS       (SSRAM_HIGH_READ_ADDR[`sram_high_addr_bits-1:0]),
        .SRAM_READ_DATA          (SSRAM_HIGH_READ_DATA),
        .SRAM_OUTPUT_ENABLE      (SSRAM_HIGH_OE),
 
        .SRAM_WRITE_ADDRESS      (SSRAM_HIGH_WRITE_ADDR[`sram_high_addr_bits-1:0]),
        .SRAM_WRITE_DATA         (SSRAM_HIGH_WRITE_DATA),
        .SRAM_WRITE_BYTE_ENABLE  (SSRAM_HIGH_WRITE_BE),
        .SRAM_WRITE_STROBE       (SSRAM_HIGH_WRITE_STROBE) 
    );

`ifdef TB_MEM
    assign TB_MEM_READ_ADDR     = SSRAM_HIGH_READ_ADDR;
    assign SSRAM_HIGH_READ_DATA  = TB_MEM_READ_DATA;
    assign TB_MEM_OE            = SSRAM_HIGH_OE;
    assign TB_MEM_WRITE_ADDR    = SSRAM_HIGH_WRITE_ADDR;
    assign TB_MEM_WRITE_DATA    = SSRAM_HIGH_WRITE_DATA;
    assign TB_MEM_WRITE_BE      = SSRAM_HIGH_WRITE_BE;
    assign TB_MEM_WRITE_STROBE  = SSRAM_HIGH_WRITE_STROBE;
`else
`ifdef BYTE_MEMORY
    sram_byte_corex #(`ssram_high_addr_bits, 4) ssram_high (
`else
    sram_corex #(`sram_high_addr_bits, 4) ssram_high (
`endif
         .CLK          (CLK),
         .READ_ADDR    (SSRAM_HIGH_READ_ADDR[`sram_high_addr_bits-1:0]),
         .DATA_OUT     (SSRAM_HIGH_READ_DATA),
         .OE           (SSRAM_HIGH_OE),
         .WRITE_ADDR   (SSRAM_HIGH_WRITE_ADDR[`sram_high_addr_bits-1:0]),
         .DATA_IN      (SSRAM_HIGH_WRITE_DATA),
         .BE           (SSRAM_HIGH_WRITE_BE),
         .WE           (SSRAM_HIGH_WRITE_STROBE)
    ); 
`endif

    axi_slave_interface 
        #(
        .masters   (`masters),
        .width     (16),
        .id_bits   (`slave_id_bits),
        .p_size    (2),
        .b_size    (4))

        uart_if (

        .ACLK      (CLK),
        .ARESETn   (RESETn),
 
        .AWMASTER  (S_AWMASTER[1]),
        .AWID      (S_AWID[1]),
        .AWADDR    (S_AWADDR[1][15:0]),
        .AWLEN     (S_AWLEN[1]),
        .AWSIZE    (S_AWSIZE[1]),
        .AWBURST   (S_AWBURST[1]),
        .AWLOCK    (S_AWLOCK[1]),
        .AWCACHE   (S_AWCACHE[1]),
        .AWPROT    (S_AWPROT[1]),
        .AWVALID   (S_AWVALID[1]),
        .AWREADY   (S_AWREADY[1]),

        .WMASTER   (S_WMASTER[1]),
        .WID       (S_WID[1]),
        .WDATA     (S_WDATA[1]),
        .WSTRB     (S_WSTRB[1]),
        .WLAST     (S_WLAST[1]),
        .WVALID    (S_WVALID[1]),
        .WREADY    (S_WREADY[1]),

        .BMASTER   (S_BMASTER[1]),
        .BID       (S_BID[1]),
        .BRESP     (S_BRESP[1]),
        .BVALID    (S_BVALID[1]),
        .BREADY    (S_BREADY[1]),

        .ARMASTER  (S_ARMASTER[1]),
        .ARID      (S_ARID[1]),
        .ARADDR    (S_ARADDR[1][15:0]),
        .ARLEN     (S_ARLEN[1]),
        .ARSIZE    (S_ARSIZE[1]),
        .ARBURST   (S_ARBURST[1]),
        .ARLOCK    (S_ARLOCK[1]),
        .ARCACHE   (S_ARCACHE[1]),
        .ARPROT    (S_ARPROT[1]),
        .ARVALID   (S_ARVALID[1]),
        .ARREADY   (S_ARREADY[1]),

        .RMASTER   (S_RMASTER[1]),
        .RID       (S_RID[1]),
        .RDATA     (S_RDATA[1]),
        .RRESP     (S_RRESP[1]),
        .RLAST     (S_RLAST[1]),
        .RVALID    (S_RVALID[1]),
        .RREADY    (S_RREADY[1]),

        .SRAM_READ_ADDRESS       (UART_READ_ADDR[15:0]),
        .SRAM_READ_DATA          (UART_READ_DATA[31:0]),
        .SRAM_OUTPUT_ENABLE      (UART_OE),
 
        .SRAM_WRITE_ADDRESS      (UART_WRITE_ADDR[15:0]),
        .SRAM_WRITE_DATA         (UART_WRITE_DATA[31:0]),
        .SRAM_WRITE_BYTE_ENABLE  (UART_WRITE_BE[3:0]),
        .SRAM_WRITE_STROBE       (UART_WRITE_STROBE)
    );
    
    uart_pl01x tty0 (
        .CLOCK                   (CLK),
        .RESETn                  (RESETn),
   
        .READ_ADDRESS            (UART_READ_ADDR[9:0]),
        .READ_DATA               (UART_READ_DATA[31:0]),
        .OE                      (UART_OE),
   
        .WRITE_ADDRESS           (UART_WRITE_ADDR[9:0]),
        .WRITE_DATA              (UART_WRITE_DATA[31:0]),
        .WE                      (UART_WRITE_STROBE),
        .BE                      (UART_WRITE_BE[3:0]),
   
        .CTS                     (CTS),
        .DSR                     (DSR),
        .DCD                     (DCD),
        .RI                      (RI),
        .RTS                     (RTS),
        .DTR                     (DTR),
        .OUT                     (OUT),
        .RXD                     (RXD),
        .TXD                     (TXD),
   
        .char_in_from_tbx        (data_in),
        .input_strobe            (dis),
        .char_out_to_tbx         (data_out),
        .output_strobe           (dos)
    );

    char_out o0 (
        .clk                     (CLK),
        .resetn                  (RESETn),
        .char                    (data_out),
        .strobe                  (dos)
    );

    char_in i0 (
        .clk                     (CLK),
        .resetn                  (RESETn),
        .char                    (data_in),
        .strobe                  (dis)
    );


    axi_slave_interface 
        #(
        .masters    (`masters), 
        .width      (16),
        .id_bits    (`slave_id_bits),
        .p_size     (2),
        .b_size     (4))
       
        cat_accel_if (

        .ACLK      (CLK),
        .ARESETn   (RESETn),
 
        .AWMASTER  (S_AWMASTER[2]),
        .AWID      (S_AWID[2]),
        .AWADDR    (S_AWADDR[2][15:0]),
        .AWLEN     (S_AWLEN[2]),
        .AWSIZE    (S_AWSIZE[2]),
        .AWBURST   (S_AWBURST[2]),
        .AWLOCK    (S_AWLOCK[2]),
        .AWCACHE   (S_AWCACHE[2]),
        .AWPROT    (S_AWPROT[2]),
        .AWVALID   (S_AWVALID[2]),
        .AWREADY   (S_AWREADY[2]),

        .WMASTER   (S_WMASTER[2]),
        .WID       (S_WID[2]),
        .WDATA     (S_WDATA[2]),
        .WSTRB     (S_WSTRB[2]),
        .WLAST     (S_WLAST[2]),
        .WVALID    (S_WVALID[2]),
        .WREADY    (S_WREADY[2]),

        .BMASTER   (S_BMASTER[2]),
        .BID       (S_BID[2]),
        .BRESP     (S_BRESP[2]),
        .BVALID    (S_BVALID[2]),
        .BREADY    (S_BREADY[2]),

        .ARMASTER  (S_ARMASTER[2]),
        .ARID      (S_ARID[2]),
        .ARADDR    (S_ARADDR[2][15:0]),
        .ARLEN     (S_ARLEN[2]),
        .ARSIZE    (S_ARSIZE[2]),
        .ARBURST   (S_ARBURST[2]),
        .ARLOCK    (S_ARLOCK[2]),
        .ARCACHE   (S_ARCACHE[2]),
        .ARPROT    (S_ARPROT[2]),
        .ARVALID   (S_ARVALID[2]),
        .ARREADY   (S_ARREADY[2]),

        .RMASTER   (S_RMASTER[2]),
        .RID       (S_RID[2]),
        .RDATA     (S_RDATA[2]),
        .RRESP     (S_RRESP[2]),
        .RLAST     (S_RLAST[2]),
        .RVALID    (S_RVALID[2]),
        .RREADY    (S_RREADY[2]),

        .SRAM_READ_ADDRESS       (CAT_READ_ADDR[15:0]),
        .SRAM_READ_DATA          (CAT_READ_DATA[63:0]),
        .SRAM_OUTPUT_ENABLE      (CAT_OE),
 
        .SRAM_WRITE_ADDRESS      (CAT_WRITE_ADDR[15:0]),
        .SRAM_WRITE_DATA         (CAT_WRITE_DATA[63:0]),
        .SRAM_WRITE_BYTE_ENABLE  (CAT_WRITE_BE[7:0]),
        .SRAM_WRITE_STROBE       (CAT_WRITE_STROBE) 
    );

    cat_accel go_fast (
         .clock        (CLK),
         .resetn       (RESETn),
         .read_addr    (CAT_READ_ADDR[15:0]),
         .read_data    (CAT_READ_DATA[63:0]),
         .oe           (CAT_OE),
         .write_addr   (CAT_WRITE_ADDR[15:0]),
         .write_data   (CAT_WRITE_DATA[63:0]),
         .be           (CAT_WRITE_BE[7:0]),
         .we           (CAT_WRITE_STROBE)
`ifdef MASTER
         ,
         .AWID         (AWID[1]),
         .AWADDR       (AWADDR[1]),
         .AWLEN        (AWLEN[1]),
         .AWSIZE       (AWSIZE[1]),
         .AWBURST      (AWBURST[1]),
         .AWLOCK       (AWLOCK[1]),
         .AWCACHE      (AWCACHE[1]),
         .AWPROT       (AWPROT[1]),
         .AWREGION     (AWREGION[1]),
         .AWQOS        (AWQOS[1]),
         .AWVALID      (AWVALID[1]),
         .AWREADY      (AWREADY[1]),

         .WID          (WID[1]),
         .WDATA        (WDATA[1]),
         .WSTRB        (WSTRB[1]),
         .WLAST        (WLAST[1]),
         .WVALID       (WVALID[1]),
         .WREADY       (WREADY[1]),

         .BID          (BID[1]),
         .BRESP        (BRESP[1]),
         .BVALID       (BVALID[1]),
         .BREADY       (BREADY[1]),

         .ARID         (ARID[1]),
         .ARADDR       (ARADDR[1]),
         .ARLEN        (ARLEN[1]),
         .ARSIZE       (ARSIZE[1]),
         .ARBURST      (ARBURST[1]),
         .ARLOCK       (ARLOCK[1]),
         .ARCACHE      (ARCACHE[1]),
         .ARPROT       (ARPROT[1]),
         .ARREGION     (ARREGION[1]),
         .ARQOS        (ARQOS[1]),
         .ARVALID      (ARVALID[1]),
         .ARREADY      (ARREADY[1]),

         .RID          (RID[1]),
         .RDATA        (RDATA[1]),
         .RRESP        (RRESP[1]), 
         .RLAST        (RLAST[1]),
         .RVALID       (RVALID[1]),
         .RREADY       (RREADY[1])
`endif
    ); 

    axi_slave_interface 
        #(
        .masters    (`masters), 
        .width      (16),
        .id_bits    (`slave_id_bits),
        .p_size     (2),
        .b_size     (4))
       
        timer_accel_if (

        .ACLK      (CLK),
        .ARESETn   (RESETn),
 
        .AWMASTER  (S_AWMASTER[3]),
        .AWID      (S_AWID[3]),
        .AWADDR    (S_AWADDR[3][15:0]),
        .AWLEN     (S_AWLEN[3]),
        .AWSIZE    (S_AWSIZE[3]),
        .AWBURST   (S_AWBURST[3]),
        .AWLOCK    (S_AWLOCK[3]),
        .AWCACHE   (S_AWCACHE[3]),
        .AWPROT    (S_AWPROT[3]),
        .AWVALID   (S_AWVALID[3]),
        .AWREADY   (S_AWREADY[3]),

        .WMASTER   (S_WMASTER[3]),
        .WID       (S_WID[3]),
        .WDATA     (S_WDATA[3]),
        .WSTRB     (S_WSTRB[3]),
        .WLAST     (S_WLAST[3]),
        .WVALID    (S_WVALID[3]),
        .WREADY    (S_WREADY[3]),

        .BMASTER   (S_BMASTER[3]),
        .BID       (S_BID[3]),
        .BRESP     (S_BRESP[3]),
        .BVALID    (S_BVALID[3]),
        .BREADY    (S_BREADY[3]),

        .ARMASTER  (S_ARMASTER[3]),
        .ARID      (S_ARID[3]),
        .ARADDR    (S_ARADDR[3][15:0]),
        .ARLEN     (S_ARLEN[3]),
        .ARSIZE    (S_ARSIZE[3]),
        .ARBURST   (S_ARBURST[3]),
        .ARLOCK    (S_ARLOCK[3]),
        .ARCACHE   (S_ARCACHE[3]),
        .ARPROT    (S_ARPROT[3]),
        .ARVALID   (S_ARVALID[3]),
        .ARREADY   (S_ARREADY[3]),

        .RMASTER   (S_RMASTER[3]),
        .RID       (S_RID[3]),
        .RDATA     (S_RDATA[3]),
        .RRESP     (S_RRESP[3]),
        .RLAST     (S_RLAST[3]),
        .RVALID    (S_RVALID[3]),
        .RREADY    (S_RREADY[3]),

        .SRAM_READ_ADDRESS       (TIMER_READ_ADDR[15:0]),
        .SRAM_READ_DATA          (TIMER_READ_DATA[31:0]),
        .SRAM_OUTPUT_ENABLE      (TIMER_OE),
 
        .SRAM_WRITE_ADDRESS      (TIMER_WRITE_ADDR[15:0]),
        .SRAM_WRITE_DATA         (TIMER_WRITE_DATA[31:0]),
        .SRAM_WRITE_BYTE_ENABLE  (TIMER_WRITE_BE[3:0]),
        .SRAM_WRITE_STROBE       (TIMER_WRITE_STROBE) 
    );

    timer timer_1 (
         .clock        (CLK),
         .resetn       (RESETn),
         .read_addr    (TIMER_READ_ADDR[15:0]),
         .read_data    (TIMER_READ_DATA[31:0]),
         .oe           (TIMER_OE),
         .write_addr   (TIMER_WRITE_ADDR[15:0]),
         .write_data   (TIMER_WRITE_DATA[31:0]),
         .be           (TIMER_WRITE_BE[3:0]),
         .we           (TIMER_WRITE_STROBE)
    ); 
/*
    cat_accel #(
         .masters    (`masters),
         .width      (16),
         .id_bits    (`id_bits),
         .p_size     (2),   // peripheral data width in 2^p_size bytes
         .b_size     (3)    // bus width in 2^b_size bytes

    )  catapult_accelerator (

        .CLOCK     (CLK),
        .RESETn    (RESETn),

        .AWMASTER  (S_AWMASTER[2]),
        .AWID      (S_AWID[2]),
        .AWADDR    (S_AWADDR[2][14:0]),
        .AWLEN     (S_AWLEN[2]),
        .AWSIZE    (S_AWSIZE[2]),
        .AWBURST   (S_AWBURST[2]),
        .AWLOCK    (S_AWLOCK[2]),
        .AWCACHE   (S_AWCACHE[2]),
        .AWPROT    (S_AWPROT[2]),
        .AWVALID   (S_AWVALID[2]),
        .AWREADY   (S_AWREADY[2]),

        .WMASTER   (S_WMASTER[2]),
        .WID       (S_WID[2]),
        .WDATA     (S_WDATA[2]),
        .WSTRB     (S_WSTRB[2]),
        .WLAST     (S_WLAST[2]),
        .WVALID    (S_WVALID[2]),
        .WREADY    (S_WREADY[2]),

        .BMASTER   (S_BMASTER[2]),
        .BID       (S_BID[2]),
        .BRESP     (S_BRESP[2]),
        .BVALID    (S_BVALID[2]),
        .BREADY    (S_BREADY[2]),

        .ARMASTER  (S_ARMASTER[2]),
        .ARID      (S_ARID[[2),
        .ARADDR    (S_ARADDR[2][14:0]),
        .ARLEN     (S_ARLEN[2]),
        .ARSIZE    (S_ARSIZE[2]),
        .ARBURST   (S_ARBURST[2]),
        .ARLOCK    (S_ARLOCK[2]),
        .ARCACHE   (S_ARCACHE[2]),
        .ARPROT    (S_ARPROT[2]),
        .ARVALID   (S_ARVALID[2]),
        .ARREADY   (S_ARREADY[2]),

        .RMASTER   (S_RMASTER[2]),
        .RID       (S_RID[2]),
        .RDATA     (S_RDATA[2]),
        .RRESP     (S_RRESP[2]),
        .RLAST     (S_RLAST[2]),
        .RVALID    (S_RVALID[2]),
        .RREADY    (S_RREADY[2]),
     );
*/
     
//-------------------------------------------------------------------------------
// CPU Core
//-------------------------------------------------------------------------------

   //-------------------------------
   // CORTEXA53 single core variant
   //-------------------------------

assign AWID[0][5] = 1'b0;
assign WID[0][5]  = 1'b0; // someone had brain damage

CORTEXA53 cpu (
      // Clock Signals
        .CLKIN                      (CLKIN),
      // Reset Signals
        .nCPUPORESET                (nCPUPORESET),
        .nCORERESET                 (nCORERESET),
        .WARMRSTREQ                 (WARMRSTREQ),
        .nL2RESET                   (nL2RESET),
        .L2RSTDISABLE               (L2RSTDISABLE),
      // Configuration Signals
        .CFGEND                     (CFGEND),
        .VINITHI                    (VINITHI),
        .CFGTE                      (CFGTE),
        .CP15SDISABLE               (CP15SDISABLE),
        .CLUSTERIDAFF1              (CLUSTERIDAFF1),
        .CLUSTERIDAFF2              (CLUSTERIDAFF2),
        .AA64nAA32                  (AA64nAA32),
        .RVBARADDR0                 (RVBARADDR0),
      // Interrupt Signals
        .nFIQ                       (nFIQ),
        .nIRQ                       (nIRQ),
        .nSEI                       (nSEI),
        .nVFIQ                      (nVFIQ),
        .nVIRQ                      (nVIRQ),
        .nVSEI                      (nVSEI),
        .nREI                       (nREI),
        .nVCPUMNTIRQ                (nVCPUMNTIRQ),
        .PERIPHBASE                 (PERIPHBASE),
        .GICCDISABLE                (GICCDISABLE),
        .ICDTVALID                  (ICDTVALID),
        .ICDTREADY                  (ICDTREADY),
        .ICDTDATA                   (ICDTDATA),
        .ICDTLAST                   (ICDTLAST),
        .ICDTDEST                   (ICDTDEST),
        .ICCTVALID                  (ICCTVALID),
        .ICCTREADY                  (ICCTREADY),
        .ICCTDATA                   (ICCTDATA),
        .ICCTLAST                   (ICCTLAST),
        .ICCTID                     (ICCTID),
      // Generic Timer Signals
        .CNTVALUEB                  (CNTVALUEB),
        .CNTCLKEN                   (CNTCLKEN),
        .nCNTPNSIRQ                 (nCNTPNSIRQ),
        .nCNTPSIRQ                  (nCNTPSIRQ),
        .nCNTVIRQ                   (nCNTVIRQ),
        .nCNTHPIRQ                  (nCNTHPIRQ),
      // Power Management Signals (Non-Retention)
        .CLREXMONREQ                (CLREXMONREQ),
        .CLREXMONACK                (CLREXMONACK),
        .EVENTI                     (EVENTI),
        .EVENTO                     (EVENTO),
        .STANDBYWFI                 (STANDBYWFI),
        .STANDBYWFE                 (STANDBYWFE),
        .STANDBYWFIL2               (STANDBYWFIL2),
        .L2FLUSHREQ                 (L2FLUSHREQ),
        .L2FLUSHDONE                (L2FLUSHDONE),
        .SMPEN                      (SMPEN),
      // Power Management Signals (Retention)
        .CPUQACTIVE                 (CPUQACTIVE),
        .CPUQREQn                   (CPUQREQn),
        .CPUQDENY                   (CPUQDENY),
        .CPUQACCEPTn                (CPUQACCEPTn),
	.NEONQACTIVE                (NEONQACTIVE),
	.NEONQREQn                  (NEONQREQn),
	.NEONQDENY                  (NEONQDENY),
	.NEONQACCEPTn               (NEONQACCEPTn),
        .L2QACTIVE                  (L2QACTIVE),
        .L2QREQn                    (L2QREQn),
        .L2QDENY                    (L2QDENY),
        .L2QACCEPTn                 (L2QACCEPTn),
      // L2 Error Signals
        .nINTERRIRQ                 (nINTERRIRQ),
      // ACE and Skyros Interface Signals
        .nEXTERRIRQ                 (nEXTERRIRQ),
        .BROADCASTCACHEMAINT        (BROADCASTCACHEMAINT),
        .BROADCASTINNER             (BROADCASTINNER),
        .BROADCASTOUTER             (BROADCASTOUTER),
        .SYSBARDISABLE              (SYSBARDISABLE),
      // ACE Interface; Clock and Configuration Signals
        .ACLKENM                    (ACLKENM),
        .ACINACTM                   (ACINACTM),
        .RDMEMATTR                  (RDMEMATTR),
        .WRMEMATTR                  (WRMEMATTR),
      // ACE Interface; Write Address Channel Signals
        .AWREADYM                   (AWREADY[0]),
        .AWVALIDM                   (AWVALID[0]),
        .AWIDM                      (AWID[0][4:0]),
        .AWADDRM                    (AWADDR[0]),
        .AWLENM                     (AWLEN[0]),
        .AWSIZEM                    (AWSIZE[0]),
        .AWBURSTM                   (AWBURST[0]),
        .AWBARM                     (AWBAR[0]),
        .AWDOMAINM                  (AWDOMAIN[0]),
        .AWLOCKM                    (AWLOCK[0]),
        .AWCACHEM                   (AWCACHE[0]),
        .AWPROTM                    (AWPROT[0]),
        .AWSNOOPM                   (AWSNOOP[0]),
        .AWUNIQUEM                  (AWUNIQUE[0]),
      // ACE Interface; Write Data Channel Signals
        .WREADYM                    (WREADY[0]),
        .WVALIDM                    (WVALID[0]),
        .WIDM                       (WID[0][4:0]),
        .WDATAM                     (WDATA[0]),
        .WSTRBM                     (WSTRB[0]),
        .WLASTM                     (WLAST[0]),
      // ACE Interface; Write Response Channel Signals
        .BREADYM                    (BREADY[0]),
        .BVALIDM                    (BVALID[0]),
        .BIDM                       (BID[0][4:0]),
        .BRESPM                     (BRESP[0][1:0]),
      // ACE Interface; Read Address Channel Signals
        .ARREADYM                   (ARREADY[0]),
        .ARVALIDM                   (ARVALID[0]),
        .ARIDM                      (ARID[0]),
        .ARADDRM                    (ARADDR[0]),
        .ARLENM                     (ARLEN[0]),
        .ARSIZEM                    (ARSIZE[0]),
        .ARBURSTM                   (ARBURST[0]),
        .ARBARM                     (ARBAR[0]),
        .ARDOMAINM                  (ARDOMAIN[0]),
        .ARLOCKM                    (ARLOCK[0]),
        .ARCACHEM                   (ARCACHE[0]),
        .ARPROTM                    (ARPROT[0]),
        .ARSNOOPM                   (ARSNOOP[0]),
      // ACE Interface; Read Data Channel Signals
        .RREADYM                    (RREADY[0]),
        .RVALIDM                    (RVALID[0]),
        .RIDM                       (RID[0]),
        .RDATAM                     (RDATA[0]),
        .RRESPM                     (RRESP[0]),
        .RLASTM                     (RLAST[0]),
      // ACE Interface; Coherency Address Channel Signals
        .ACREADYM                   (ACREADYM),
        .ACVALIDM                   (ACVALIDM),
        .ACADDRM                    (ACADDRM),
        .ACPROTM                    (ACPROTM),
        .ACSNOOPM                   (ACSNOOPM),
      // ACE Interface; Coherency Response Channel Signals
        .CRREADYM                   (CRREADYM),
        .CRVALIDM                   (CRVALIDM),
        .CRRESPM                    (CRRESPM),
      // ACE Interface; Coherency Data Channel Signals
        .CDREADYM                   (CDREADYM),
        .CDVALIDM                   (CDVALIDM),
        .CDDATAM                    (CDDATAM),
        .CDLASTM                    (CDLASTM),
      // ACE Interface; Read/Write Acknowledge Signals
        .RACKM                      (RACKM),
        .WACKM                      (WACKM),
      // ACP Interface; Clock and Configuration Signals
        .ACLKENS                    (ACLKENS),
        .AINACTS                    (AINACTS),
      // ACP Interface; Write Address Channel Signals
        .AWREADYS                   (AWREADYS),
        .AWVALIDS                   (AWVALIDS),
        .AWIDS                      (AWIDS),
        .AWADDRS                    (AWADDRS),
        .AWLENS                     (AWLENS),
        .AWCACHES                   (AWCACHES),
        .AWUSERS                    (AWUSERS),
        .AWPROTS                    (AWPROTS),
      // ACP Interface; Write Data Channel Signals
        .WREADYS                    (WREADYS),
        .WVALIDS                    (WVALIDS),
        .WDATAS                     (WDATAS),
        .WSTRBS                     (WSTRBS),
        .WLASTS                     (WLASTS),
      // ACP Interface; Write Response Channel Signals
        .BREADYS                    (BREADYS),
        .BVALIDS                    (BVALIDS),
        .BIDS                       (BIDS),
        .BRESPS                     (BRESPS),
      // ACP Interface; Read Address Channel Signals
        .ARREADYS                   (ARREADYS),
        .ARVALIDS                   (ARVALIDS),
        .ARIDS                      (ARIDS),
        .ARADDRS                    (ARADDRS),
        .ARLENS                     (ARLENS),
        .ARCACHES                   (ARCACHES),
        .ARUSERS                    (ARUSERS),
        .ARPROTS                    (ARPROTS),
      // ACP Interface; Read Data Channel Signals
        .RREADYS                    (RREADYS),
        .RVALIDS                    (RVALIDS),
        .RIDS                       (RIDS),
        .RDATAS                     (RDATAS),
        .RRESPS                     (RRESPS),
        .RLASTS                     (RLASTS),
      // APB Interface Signals
        .nPRESETDBG                 (nPRESETDBG),
        .PCLKENDBG                  (PCLKENDBG),
        .PSELDBG                    (PSELDBG),
        .PADDRDBG                   (PADDRDBG),
        .PADDRDBG31                 (PADDRDBG31),
        .PENABLEDBG                 (PENABLEDBG),
        .PWRITEDBG                  (PWRITEDBG),
        .PWDATADBG                  (PWDATADBG),
        .PRDATADBG                  (PRDATADBG),
        .PREADYDBG                  (PREADYDBG),
        .PSLVERRDBG                 (PSLVERRDBG),
      // Miscellaneous Debug Signals
        .DBGROMADDR                 (DBGROMADDR),
        .DBGROMADDRV                (DBGROMADDRV),
        .DBGACK                     (DBGACK),
        .nCOMMIRQ                   (nCOMMIRQ),
        .COMMRX                     (COMMRX),
        .COMMTX                     (COMMTX),
        .EDBGRQ                     (EDBGRQ),
        .DBGEN                      (DBGEN),
        .NIDEN                      (NIDEN),
        .SPIDEN                     (SPIDEN),
        .SPNIDEN                    (SPNIDEN),
        .DBGRSTREQ                  (DBGRSTREQ),
        .DBGNOPWRDWN                (DBGNOPWRDWN),
        .DBGPWRDUP                  (DBGPWRDUP),
        .DBGPWRUPREQ                (DBGPWRUPREQ),
        .DBGL1RSTDISABLE            (DBGL1RSTDISABLE),
      // ATB Interface Signals
        .ATCLKEN                    (ATCLKEN),
        .ATREADYM0                  (ATREADYM0),
        .AFVALIDM0                  (AFVALIDM0),
        .ATDATAM0                   (ATDATAM0),
        .ATVALIDM0                  (ATVALIDM0),
        .ATBYTESM0                  (ATBYTESM0),
        .AFREADYM0                  (AFREADYM0),
        .ATIDM0                     (ATIDM0),
      // Miscellaneous ETM Signals
        .SYNCREQM0                  (SYNCREQM0),
        .TSVALUEB                   (TSVALUEB),
      // CTI Interface Signals
        .CTICHIN                    (CTICHIN),
        .CTICHOUTACK                (CTICHOUTACK),
        .CTICHOUT                   (CTICHOUT),
        .CTICHINACK                 (CTICHINACK),
        .CISBYPASS                  (CISBYPASS),
        .CIHSBYPASS                 (CIHSBYPASS),
        .CTIIRQ                     (CTIIRQ),
        .CTIIRQACK                  (CTIIRQACK),
      // PMU Signals
        .nPMUIRQ                    (nPMUIRQ),
        .PMUEVENT0                  (PMUEVENT0),
      // DFT Signals
        .DFTSE                      (DFTSE),
        .DFTRSTDISABLE              (DFTRSTDISABLE),
        .DFTRAMHOLD                 (DFTRAMHOLD),
        .DFTMCPHOLD                 (DFTMCPHOLD),
      // MBIST Interface Signals
        .MBISTREQ                   (MBISTREQ),
        .nMBISTRESET	            (nMBISTRESET)
    );

endmodule
