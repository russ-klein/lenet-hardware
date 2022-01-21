
`timescale 1ns/1ns
`include "axi_bus_defines.svh"

module axi_matrix
   (
            ACLK,
            ARESETn,

            AWID,
            AWADDR,
            AWLEN,
            AWSIZE,
            AWBURST,
            AWLOCK,
            AWCACHE,
            AWPROT,
            AWVALID,
            AWREADY,

            WID,
            WDATA,
            WSTRB,
            WLAST,
            WVALID,
            WREADY,

            BID,
            BRESP,
            BVALID,
            BREADY,

            ARID,
            ARADDR,
            ARLEN,
            ARSIZE,
            ARBURST,
            ARLOCK,
            ARCACHE,
            ARPROT,
            ARVALID,
            ARREADY,

            RID,
            RDATA,
            RRESP,
            RLAST,
            RVALID,
            RREADY,

            S_AWMASTER,
            S_AWID,
            S_AWADDR,
            S_AWLEN,
            S_AWSIZE,
            S_AWBURST,
            S_AWLOCK,
            S_AWCACHE,
            S_AWPROT,
            S_AWVALID,
            S_AWREADY,

            S_WMASTER,
            S_WID,
            S_WDATA,
            S_WSTRB,
            S_WLAST,
            S_WVALID,
            S_WREADY,

            S_BMASTER,
            S_BID,
            S_BRESP,
            S_BVALID,
            S_BREADY,

            S_ARMASTER,
            S_ARID,
            S_ARADDR,
            S_ARLEN,
            S_ARSIZE,
            S_ARBURST,
            S_ARLOCK,
            S_ARCACHE,
            S_ARPROT,
            S_ARVALID,
            S_ARREADY,

            S_RMASTER,
            S_RID,
            S_RDATA,
            S_RRESP,
            S_RLAST,
            S_RVALID,
            S_RREADY,

            CSYSREQ,
            CSYSACK,
            CACTIVE
    );

    parameter masters  = 3;
    parameter slaves   = 2;
    parameter channels = 1;

    input                            ACLK;
    input                            ARESETn;

    input  [`id_bits-1:0]            AWID[masters-1:0];
    input  [`addr_bits-1:0]          AWADDR[masters-1:0];
    input  [`len_bits-1:0]           AWLEN[masters-1:0];
    input  [`size_bits-1:0]          AWSIZE[masters-1:0];
    input  [`burst_bits-1:0]         AWBURST[masters-1:0];
    input  [`lock_bits-1:0]          AWLOCK[masters-1:0];
    input  [`cache_bits-1:0]         AWCACHE[masters-1:0];
    input  [`prot_bits-1:0]          AWPROT[masters-1:0];
    input                            AWVALID[masters-1:0];
    output                           AWREADY[masters-1:0];

    input  [`id_bits-1:0]            WID[masters-1:0];
    input  [`data_bits-1:0]          WDATA[masters-1:0];
    input  [`strb_bits-1:0]          WSTRB[masters-1:0];
    input                            WLAST[masters-1:0];
    input                            WVALID[masters-1:0];
    output                           WREADY[masters-1:0];

    output [`id_bits-1:0]            BID[masters-1:0];
    output [`resp_bits-1:0]          BRESP[masters-1:0];
    output                           BVALID[masters-1:0];
    input                            BREADY[masters-1:0];

    input  [`id_bits-1:0]            ARID[masters-1:0];
    input  [`addr_bits-1:0]          ARADDR[masters-1:0];
    input  [`len_bits-1:0]           ARLEN[masters-1:0];
    input  [`size_bits-1:0]          ARSIZE[masters-1:0];
    input  [`burst_bits-1:0]         ARBURST[masters-1:0];
    input  [`lock_bits-1:0]          ARLOCK[masters-1:0];
    input  [`cache_bits-1:0]         ARCACHE[masters-1:0];
    input  [`prot_bits-1:0]          ARPROT[masters-1:0];
    input                            ARVALID[masters-1:0];
    output                           ARREADY[masters-1:0];

    output [`id_bits-1:0]            RID[masters-1:0];
    output [`data_bits-1:0]          RDATA[masters-1:0];
    output [`resp_bits-1:0]          RRESP[masters-1:0];
    output                           RLAST[masters-1:0];
    output                           RVALID[masters-1:0];
    input                            RREADY[masters-1:0];

    output [masters-1:0]             S_AWMASTER[slaves-1:0];
    output [`id_bits-1:0]            S_AWID[slaves-1:0];
    output [`addr_bits-1:0]          S_AWADDR[slaves-1:0];
    output [`len_bits-1:0]           S_AWLEN[slaves-1:0];
    output [`size_bits-1:0]          S_AWSIZE[slaves-1:0];
    output [`burst_bits-1:0]         S_AWBURST[slaves-1:0];
    output [`lock_bits-1:0]          S_AWLOCK[slaves-1:0];
    output [`cache_bits-1:0]         S_AWCACHE[slaves-1:0];
    output [`prot_bits-1:0]          S_AWPROT[slaves-1:0];
    output                           S_AWVALID[slaves-1:0];
    input                            S_AWREADY[slaves-1:0];

    output [masters-1:0]             S_WMASTER[slaves-1:0];
    output [`id_bits-1:0]            S_WID[slaves-1:0];
    output [`data_bits-1:0]          S_WDATA[slaves-1:0];
    output [`strb_bits-1:0]          S_WSTRB[slaves-1:0];
    output                           S_WLAST[slaves-1:0];
    output                           S_WVALID[slaves-1:0];
    input                            S_WREADY[slaves-1:0];

    input  [masters-1:0]             S_BMASTER[slaves-1:0];
    input  [`id_bits-1:0]            S_BID[slaves-1:0];
    input  [`resp_bits-1:0]          S_BRESP[slaves-1:0];
    input                            S_BVALID[slaves-1:0];
    output                           S_BREADY[slaves-1:0];

    output [masters-1:0]             S_ARMASTER[slaves-1:0];
    output [`id_bits-1:0]            S_ARID[slaves-1:0];
    output [`addr_bits-1:0]          S_ARADDR[slaves-1:0];
    output [`len_bits-1:0]           S_ARLEN[slaves-1:0];
    output [`size_bits-1:0]          S_ARSIZE[slaves-1:0];
    output [`burst_bits-1:0]         S_ARBURST[slaves-1:0];
    output [`lock_bits-1:0]          S_ARLOCK[slaves-1:0];
    output [`cache_bits-1:0]         S_ARCACHE[slaves-1:0];
    output [`prot_bits-1:0]          S_ARPROT[slaves-1:0];
    output                           S_ARVALID[slaves-1:0];
    input                            S_ARREADY[slaves-1:0];

    input  [masters-1:0]             S_RMASTER[slaves-1:0];
    input  [`id_bits-1:0]            S_RID[slaves-1:0];
    input  [`data_bits-1:0]          S_RDATA[slaves-1:0];
    input  [`resp_bits-1:0]          S_RRESP[slaves-1:0];
    input                            S_RLAST[slaves-1:0];
    input                            S_RVALID[slaves-1:0];
    output                           S_RREADY[slaves-1:0];

    input                            CSYSREQ;
    input                            CSYSACK;
    input                            CACTIVE;

    reg    [masters-1:0]             C_AWMASTER[channels-1:0];
    reg    [`id_bits-1:0]            C_AWID[channels-1:0];
    reg    [`addr_bits-1:0]          C_AWADDR[channels-1:0];
    reg    [`len_bits-1:0]           C_AWLEN[channels-1:0];
    reg    [`size_bits-1:0]          C_AWSIZE[channels-1:0];
    reg    [`burst_bits-1:0]         C_AWBURST[channels-1:0];
    reg    [`lock_bits-1:0]          C_AWLOCK[channels-1:0];
    reg    [`cache_bits-1:0]         C_AWCACHE[channels-1:0];
    reg    [`prot_bits-1:0]          C_AWPROT[channels-1:0];
    reg                              C_AWVALID[channels-1:0];
    reg                              C_AWREADY[channels-1:0];

    reg    [masters-1:0]             C_WMASTER[channels-1:0];
    reg    [`id_bits-1:0]            C_WID[channels-1:0];
    reg    [`data_bits-1:0]          C_WDATA[channels-1:0];
    reg    [`strb_bits-1:0]          C_WSTRB[channels-1:0];
    reg                              C_WLAST[channels-1:0];
    reg                              C_WVALID[channels-1:0];
    reg                              C_WREADY[channels-1:0];

    reg    [masters-1:0]             C_BMASTER[channels-1:0];
    reg    [`id_bits-1:0]            C_BID[channels-1:0];
    reg    [`resp_bits-1:0]          C_BRESP[channels-1:0];
    reg                              C_BVALID[channels-1:0];
    reg                              C_BREADY[channels-1:0];

    reg    [masters-1:0]             C_ARMASTER[channels-1:0];
    reg    [`id_bits-1:0]            C_ARID[channels-1:0];
    reg    [`addr_bits-1:0]          C_ARADDR[channels-1:0];
    reg    [`len_bits-1:0]           C_ARLEN[channels-1:0];
    reg    [`size_bits-1:0]          C_ARSIZE[channels-1:0];
    reg    [`burst_bits-1:0]         C_ARBURST[channels-1:0];
    reg    [`lock_bits-1:0]          C_ARLOCK[channels-1:0];
    reg    [`cache_bits-1:0]         C_ARCACHE[channels-1:0];
    reg    [`prot_bits-1:0]          C_ARPROT[channels-1:0];
    reg                              C_ARVALID[channels-1:0];
    reg                              C_ARREADY[channels-1:0];

    reg    [masters-1:0]             C_RMASTER[channels-1:0];
    reg    [`id_bits-1:0]            C_RID[channels-1:0];
    reg    [`data_bits-1:0]          C_RDATA[channels-1:0];
    reg    [`resp_bits-1:0]          C_RRESP[channels-1:0];
    reg                              C_RLAST[channels-1:0];
    reg                              C_RVALID[channels-1:0];
    reg                              C_RREADY[channels-1:0];

    reg    [slaves-1:0]              slave_table[(1<<(masters+`id_bits))-1:0];

    reg    [slaves-1:0]              AWSLAVE;
    reg    [slaves-1:0]              WSLAVE;
    reg    [masters-1:0]             BSLAVE;   // peripheral is the master
    reg    [slaves-1:0]              ARSLAVE;
    reg    [masters-1:0]             RSLAVE;   // peripheral is the master

    reg    [masters-1:0]             AWMASTER;
    reg    [masters-1:0]             WMASTER;
    reg    [slaves-1:0]              BMASTER;  // peripheral is the master
    reg    [masters-1:0]             ARMASTER;
    reg    [slaves-1:0]              RMASTER;  // peripheral is the master

    reg                              AR_BUSERR;
    reg                              AW_BUSERR;

    wire [(1<<(masters+1))-1:0]      slave_table_read_index;
    wire [(1<<(masters+1))-1:0]      resp_table_read_index;
    genvar m;
    genvar s;

    wire                             strobe_aw = C_AWVALID[0] && C_AWREADY[0];
    wire                             strobe_w  = C_WVALID[0]  && C_WREADY[0];
    wire                             strobe_b  = C_BVALID[0]  && C_BREADY[0];
    wire                             strobe_ar = C_ARVALID[0] && C_ARREADY[0];
    wire                             strobe_r  = C_RVALID[0]  && C_RREADY[0];

    wire [31:0]                      payload_aw = (strobe_aw) ? C_AWADDR[0] : 32'hzzzzzzzz;
    wire [63:0]                      payload_w  = (strobe_w)  ? C_WDATA[0]  : 64'hzzzzzzzzzzzzzzzz;
    wire [31:0]                      payload_ar = (strobe_ar) ? C_ARADDR[0] : 32'hzzzzzzzz;
    wire [63:0]                      payload_r  = (strobe_r)  ? C_RDATA[0]  : 64'hzzzzzzzzzzzzzzzz;

    generate
       for (m=0; m<(1<<(masters+`id_bits)); m++) begin
           initial slave_table[m] = 32'b00000000;
       end
    endgenerate

    //  Write address segment logic

    segment_arbiter #(masters) address_write_channel_arbiter(AWMASTER, AWVALID, ACLK, ARESETn);
    segment_slave   #(masters, slaves) address_write_channel_slave(AWMASTER, AWADDR, AWSLAVE, AW_BUSERR);

    assign C_AWMASTER[0] = AWMASTER;

    bmux #(masters, `id_bits)    mux00 (C_AWID[0],    AWMASTER, AWID);
    bmux #(masters, `addr_bits)  mux01 (C_AWADDR[0],  AWMASTER, AWADDR);
    bmux #(masters, `len_bits)   mux02 (C_AWLEN[0],   AWMASTER, AWLEN);
    bmux #(masters, `size_bits)  mux03 (C_AWSIZE[0],  AWMASTER, AWSIZE);
    bmux #(masters, `burst_bits) mux04 (C_AWBURST[0], AWMASTER, AWBURST);
    bmux #(masters, `lock_bits)  mux05 (C_AWLOCK[0],  AWMASTER, AWLOCK);
    bmux #(masters, `cache_bits) mux06 (C_AWCACHE[0], AWMASTER, AWCACHE);
    bmux #(masters, `prot_bits)  mux07 (C_AWPROT[0],  AWMASTER, AWPROT);
    bmux #(masters, 1)           mux08 (C_AWVALID[0], AWMASTER, AWVALID);

    bmux #(slaves,  1)           mux09 (C_AWREADY[0], AWSLAVE,  S_AWREADY);

    generate 
       for (m=0; m<masters; m++) begin
          assign AWREADY[m] = AWMASTER[m] ? C_AWREADY[0] : 1'b0;
       end
    endgenerate

    // output enables for slaves

    generate 
       for (s=0; s<slaves; s++) begin
          assign S_AWMASTER[s] = AWSLAVE[s] ? C_AWMASTER[0] : {masters {1'b0}};
          assign S_AWID[s] =     AWSLAVE[s] ? C_AWID[0]     : {`id_bits {1'b0}};
          assign S_AWADDR[s] =   AWSLAVE[s] ? C_AWADDR[0]   : {`addr_bits {1'b0}};
          assign S_AWLEN[s] =    AWSLAVE[s] ? C_AWLEN[0]    : {`len_bits {1'b0}};
          assign S_AWSIZE[s] =   AWSLAVE[s] ? C_AWSIZE[0]   : {`size_bits {1'b0}};
          assign S_AWBURST[s] =  AWSLAVE[s] ? C_AWBURST[0]  : {`burst_bits {1'b0}};
          assign S_AWLOCK[s] =   AWSLAVE[s] ? C_AWLOCK[0]   : {`lock_bits {1'b0}};
          assign S_AWCACHE[s] =  AWSLAVE[s] ? C_AWCACHE[0]  : {`cache_bits {1'b0}};
          assign S_AWPROT[s] =   AWSLAVE[s] ? C_AWPROT[0]   : {`prot_bits {1'b0}};
          assign S_AWVALID[s] =  AWSLAVE[s] ? C_AWVALID[0]  : 1'b0;
       end
    endgenerate

    // save master-id mapping in slave table
    generate
       for (m=0; m<masters; m++) begin
          always @(posedge ACLK) begin
             if (AWMASTER[m]) begin
                  // $display("Setting slave to ", AWSLAVE, " at ",{AWMASTER, AWID[m]});
                  // $display("master = ", AWMASTER, " transcation_id = ", AWID[m], " Slave = ", AWSLAVE);
                  slave_table[{AWMASTER, AWID[m]}] = AWSLAVE;  
             end
          end
       end
    endgenerate


    // Write data segment logic

    segment_arbiter #(masters) data_write_channel_arbiter(WMASTER, WVALID, ACLK, ARESETn);
    
    assign slave_table_read_index = {WMASTER, C_WID[0]};
    assign WSLAVE = slave_table[slave_table_read_index];

    assign C_WMASTER[0] = WMASTER;

    bmux #(masters, `id_bits)  mux10 (C_WID[0],    WMASTER, WID);
    bmux #(masters, `data_bits) mux11 (C_WDATA[0],  WMASTER, WDATA);
    bmux #(masters, `data_bits/8) mux12 (C_WSTRB[0],  WMASTER, WSTRB);
    bmux #(masters, 1)         mux13 (C_WLAST[0],  WMASTER, WLAST);
    bmux #(masters, 1)         mux14 (C_WVALID[0], WMASTER, WVALID);

    bmux #(slaves, 1)          mux15 (C_WREADY[0], WSLAVE,  S_WREADY);

    generate 
       for (m=0; m<masters; m++) begin
          assign WREADY[m] = WMASTER[m] ? C_WREADY[0] : 1'b0;
       end
    endgenerate

    generate 
       for (s=0; s<slaves; s++) begin
          assign S_WMASTER[s] = WSLAVE[s] ? C_WMASTER[0] : {masters {1'b0}};
          assign S_WID[s] =     WSLAVE[s] ? C_WID[0]     : {`id_bits {1'b0}};
          assign S_WDATA[s] =   WSLAVE[s] ? C_WDATA[0]   : {`data_bits {1'b0}};
          assign S_WSTRB[s] =   WSLAVE[s] ? C_WSTRB[0]   : {(`data_bits/8) {1'b0}};
          assign S_WLAST[s] =   WSLAVE[s] ? C_WLAST[0]   : 1'b0;
          assign S_WVALID[s] =  WSLAVE[s] ? C_WVALID[0]  : 1'b0;
       end
    endgenerate


    // Write response segment logic

    segment_arbiter #(slaves) write_response_channel_arbiter(BMASTER, S_BVALID, ACLK, ARESETn);

    bmux #(slaves, masters)  mux20 (C_BMASTER[0], BMASTER, S_BMASTER);
    bmux #(slaves, `id_bits) mux21 (C_BID[0],     BMASTER, S_BID);
    bmux #(slaves, `resp_bits) mux22 (C_BRESP[0],   BMASTER, S_BRESP);
    bmux #(slaves, 1)        mux23 (C_BVALID[0],  BMASTER, S_BVALID);

    bmux #(masters, 1)       mux24 (C_BREADY[0],  C_BMASTER[0],  BREADY);

    generate 
       for (s=0; s<slaves; s++) begin
          assign S_BREADY[s] = BMASTER[s] ? C_BREADY[0] : 1'b0;
       end
    endgenerate

    assign BSLAVE = C_BMASTER[0];

    generate 
       for (m=0; m<masters; m++) begin
          assign BID[m] =     BSLAVE[m] ? C_BID[0]     : {`id_bits{1'b0}};
          assign BRESP[m] =   BSLAVE[m] ? C_BRESP[0]   : {`resp_bits{1'b0}};
          assign BVALID[m] =  BSLAVE[m] ? C_BVALID[0]  : 1'b0;
       end
    endgenerate

    //  Read address segment logic

    segment_arbiter #(masters) address_read_channel_arbiter(ARMASTER, ARVALID, ACLK, ARESETn);
    segment_slave   #(masters, slaves) address_read_channel_slave(ARMASTER, ARADDR, ARSLAVE, AR_BUSERR);

    assign C_ARMASTER[0] = ARMASTER;

    bmux #(masters, `id_bits)    mux30 (C_ARID[0],    ARMASTER, ARID);
    bmux #(masters, `addr_bits)  mux31 (C_ARADDR[0],  ARMASTER, ARADDR);
    bmux #(masters, `len_bits)   mux32 (C_ARLEN[0],   ARMASTER, ARLEN);
    bmux #(masters, `size_bits)  mux33 (C_ARSIZE[0],  ARMASTER, ARSIZE);
    bmux #(masters, `burst_bits) mux34 (C_ARBURST[0], ARMASTER, ARBURST);
    bmux #(masters, `lock_bits)  mux35 (C_ARLOCK[0],  ARMASTER, ARLOCK);
    bmux #(masters, `cache_bits) mux36 (C_ARCACHE[0], ARMASTER, ARCACHE);
    bmux #(masters, `prot_bits)  mux37 (C_ARPROT[0],  ARMASTER, ARPROT);
    bmux #(masters, 1)           mux38 (C_ARVALID[0], ARMASTER, ARVALID);

    bmux #(slaves, 1)          mux39 (C_ARREADY[0], ARSLAVE,  S_ARREADY);

    generate 
       for (m=0; m<masters; m++) begin
          assign ARREADY[m] = ARMASTER[m] ? C_ARREADY[0] : 1'b0;
       end
    endgenerate

    // output enables for slaves

    generate 
       for (s=0; s<slaves; s++) begin
          assign S_ARMASTER[s] = ARSLAVE[s] ? C_ARMASTER[0] : {masters {1'b0}};
          assign S_ARID[s] =     ARSLAVE[s] ? C_ARID[0]     : {`id_bits {1'b0}};
          assign S_ARADDR[s] =   ARSLAVE[s] ? C_ARADDR[0]   : {`addr_bits {1'b0}};
          assign S_ARLEN[s] =    ARSLAVE[s] ? C_ARLEN[0]    : {`len_bits {1'b0}};
          assign S_ARSIZE[s] =   ARSLAVE[s] ? C_ARSIZE[0]   : {`size_bits {1'b0}};
          assign S_ARBURST[s] =  ARSLAVE[s] ? C_ARBURST[0]  : {`burst_bits {1'b0}};
          assign S_ARLOCK[s] =   ARSLAVE[s] ? C_ARLOCK[0]   : {`lock_bits {1'b0}};
          assign S_ARCACHE[s] =  ARSLAVE[s] ? C_ARCACHE[0]  : {`cache_bits {1'b0}};
          assign S_ARPROT[s] =   ARSLAVE[s] ? C_ARPROT[0]   : {`prot_bits {1'b0}};
          assign S_ARVALID[s] =  ARSLAVE[s] ? C_ARVALID[0]  : 1'b0;
       end
    endgenerate

    // Read data/response segment logic

    segment_arbiter #(slaves) read_response_channel_arbiter(RMASTER, S_RVALID, ACLK, ARESETn);

    // assign RMASTER = S_RMASTER[BSLAVE];

    bmux #(slaves, masters)  mux40 (C_RMASTER[0], RMASTER, S_RMASTER);
    bmux #(slaves, `id_bits) mux41 (C_RID[0],     RMASTER, S_RID);
    bmux #(slaves, `data_bits) mux42 (C_RDATA[0],   RMASTER, S_RDATA);
    bmux #(slaves, `resp_bits) mux43 (C_RRESP[0],   RMASTER, S_RRESP);
    bmux #(slaves, 1)        mux44 (C_RLAST[0],   RMASTER, S_RLAST);
    bmux #(slaves, 1)        mux45 (C_RVALID[0],  RMASTER, S_RVALID);

    bmux #(masters, 1)       mux46 (C_RREADY[0], C_RMASTER[0],  RREADY);

    generate 
       for (s=0; s<slaves; s++) begin
          assign S_RREADY[s] = RMASTER[s] ? C_RREADY[0] : 1'b0;
       end
    endgenerate

    assign RSLAVE = C_RMASTER[0];

    generate 
       for (m=0; m<masters; m++) begin
          assign RID[m] =     RSLAVE[m] ? C_RID[0]     : {`id_bits {1'b0}};
          assign RDATA[m] =   RSLAVE[m] ? C_RDATA[0]   : {`data_bits {1'b0}};
          assign RRESP[m] =   RSLAVE[m] ? C_RRESP[0]   : {`resp_bits {1'b0}};
          assign RLAST[m] =   RSLAVE[m] ? C_RLAST[0]   : 1'b0;
          assign RVALID[m] =  RSLAVE[m] ? C_RVALID[0]  : 1'b0;
       end
    endgenerate

endmodule
