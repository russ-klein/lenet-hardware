
`timescale 1ns/1ns

module ahb_switch(

          HCLOCK, 
          HRESETn,

          // AHB master signals 

          HADDR,
          HTRANS,
          HBURST,
          HWRITE,
          HSIZE,
          HPROT,
          HREADY,
          HRESP,
          HWDATA,
          HRDATA,
          HLOCK,

          // AHB Slave signals 

          S_ADDRESS,
          S_CHIP_SELECT,
          S_BYTE_ENABLE,
          S_WRITE,
          S_WDATA,
          S_TRANS,
          S_RDATA,
          S_RESP,
          S_READY
   );

   parameter masters  = 3;
   parameter slaves   = 2;
   parameter channels = 1;

   input             HCLOCK; 
   input             HRESETn;

   // AHB master signals 

   input  [31:0]     HADDR[masters-1:0];
   input  [1:0]      HTRANS[masters-1:0];
   input  [2:0]      HBURST[masters-1:0];
   input             HWRITE[masters-1:0];
   input  [2:0]      HSIZE[masters-1:0];
   input  [3:0]      HPROT[masters-1:0];
   output            HREADY[masters-1:0];
   output [1:0]      HRESP[masters-1:0];
   input  [31:0]     HWDATA[masters-1:0];
   output [31:0]     HRDATA[masters-1:0];
   input             HLOCK[masters-1:0];

   // AHB Slave signals 
 
   output [31:0]     S_ADDRESS[slaves-1:0];
   output            S_CHIP_SELECT[slaves-1:0];
   output [3:0]      S_BYTE_ENABLE[slaves-1:0];
   output            S_WRITE[slaves-1:0];
   output [31:0]     S_WDATA[slaves-1:0];
   output [1:0]      S_TRANS[slaves-1:0];
   input  [31:0]     S_RDATA[slaves-1:0];
   input  [1:0]      S_RESP[slaves-1:0];
   input             S_READY[slaves-1:0];

   reg  [3:0]        hbl[masters-1:0];
   reg  [1:0]        htrans_delayed[masters-1:0];
   reg  [3:0]        slave_table [masters-1:0];
   reg  [0:masters-1]  slave_req;
   reg  [0:masters-1]  slave_valid;
   reg  [3:0]        slave_table_d [masters-1:0];
   reg  [0:masters-1]  slave_valid_d;
   reg  [3:0]        master_table [slaves-1:0];
   reg               master_valid [slaves-1:0];

   reg               grant_table[masters][slaves];
   reg  [3:0]        master_list_d[masters][slaves];
   reg               master_list_v[masters][slaves];

   reg               ready_from_active_slave[masters];
   reg               goose_idles[masters];


   // address mapping for peripherals

   function [3:0] slave_select;
     input [31:0] addr;

     begin
       if (addr[31:28] == 4'h0) return 0;
       if (addr[31:28] == 4'h4) return 1;
       if (addr[31:28] == 4'h8) return 2;
       if (addr[31:28] == 4'hA) return 3;
       if (addr[31:28] == 4'h9) return 4;
       return 15;
     end
   endfunction

   genvar m;
   genvar s;

   generate 
     for (m=0; m<masters; m++) begin
       blgen bg (hbl[m], HSIZE[m], HADDR[m]);
     end
   endgenerate

   always @(posedge HCLOCK) begin
     htrans_delayed <= HTRANS;
     slave_table_d  <= slave_table;
     slave_valid_d  <= slave_valid;
   end

   generate
     for (m=0; m<masters; m++) begin
       assign ready_from_active_slave[m] = slave_valid_d[m] ? S_READY[slave_table_d[m]] : 1'b0;
       assign goose_idles[m] = (HTRANS[m] == 2'b00) ? 1'b1 : 1'b0;
     end
   endgenerate

   generate 
     for (m=0; m<masters; m++) begin
       assign HREADY[m] = slave_valid[m] ? S_READY [slave_table[m]] : goose_idles[m];
       assign HRDATA[m] = slave_valid[m] ? S_RDATA [slave_table[m]] : 32'h00000000;
       assign HRESP[m]  = slave_valid[m] ? S_RESP  [slave_table[m]] : 2'b00;
     end
   endgenerate

   generate
     for (s=0; s<slaves; s++) begin
       assign S_ADDRESS[s]     = master_valid[s] ? HADDR [master_table[s]] : 32'h00000000;
       assign S_BYTE_ENABLE[s] = master_valid[s] ? hbl   [master_table[s]] : 4'b0000;
       assign S_WRITE[s]       = master_valid[s] ? HWRITE[master_table[s]] : 1'b0;
       assign S_WDATA[s]       = master_valid[s] ? HWDATA[master_table[s]] : 32'h00000000;
       assign S_TRANS[s]       = master_valid[s] ? HTRANS[master_table[s]] : 2'b00;
       assign S_CHIP_SELECT[s] = master_valid[s] ? 1'b1 : 1'b0;
     end
   endgenerate

   generate
     for (m=0; m<masters; m++) begin
       assign slave_req[m] = (HTRANS[m] != 2'b00) ? 1'b1 : 1'b0;
     end
   endgenerate

   generate 
     for (m=0; m<masters; m++) begin
       always @(posedge HCLOCK or HRESETn == 1'b0) begin
         if (HRESETn == 1'b0) begin
           slave_valid[m] <= 1'b0;
           slave_table[m] <= 4'b0000;
         end else begin
           if (!slave_req[m] && HREADY[m]) begin   // master is done with the slave, release it
              slave_valid[m] <= 1'b0;
           end else if (slave_valid[m] && (slave_table[m] != slave_select(HADDR[m]))) begin // handoff to new slave, release current slave
              slave_valid[m] <= 1'b0;
           end else begin
             if ((slave_valid[0:masters-1] & slave_req[0:masters-1]) == {masters {1'b0}}) begin // if the slave is not in use
               if (m == 0) begin
                 if (slave_req[m]) begin
                    slave_valid[m] <= 1'b1;
                    if (slave_req[m]) slave_table[m] <= slave_select(HADDR[m]);
                 end else begin
                    slave_valid[m] = 1'b0;
                 end
               end else begin
                 // old line: if (slave_req[m] && (slave_req[0:m-1] == {masters-m{1'b0}})) begin
                 if (m>0) begin
                    if (slave_req[m] && (slave_req[0:m-1] == { m {1'b0} })) begin
                       slave_valid[m] <= 1'b1;
                       slave_table[m] <= slave_select(HADDR[m]);
                    end else begin
                       slave_valid[m] <= 1'b0;
                    end
                 end else begin  // m==0
                    if (slave_req[m]) begin
                       slave_valid[m] <= 1'b1;
                       slave_table[m] <= slave_select(HADDR[m]);
                    end else begin
                       slave_valid[m] <= 1'b0;
                    end 
                 end
               end
             end 
           end
         end
       end
     end
   endgenerate

   generate
     for (s=0; s<slaves; s++) begin
       for (m=0; m<masters; m++) begin
         assign grant_table[m][s] = slave_valid[m] && (slave_table[m] == s);
       end
     end
   endgenerate

   generate
     for (s=0; s<slaves; s++) begin
       for (m=0; m<masters-1; m++) begin
         assign master_list_d[m][s] = master_list_d[m+1][s] | (grant_table[m][s] ? m : 0);
         assign master_list_v[m][s] = master_list_v[m+1][s] |  grant_table[m][s];
       end
       assign master_list_d[masters-1][s] = grant_table[masters-1][s] ? masters-1 : 0;
       assign master_list_v[masters-1][s] = grant_table[masters-1][s];
     end
   endgenerate

   generate
     for (s=0; s<slaves; s++) begin
       assign master_table[s] = master_list_d[0][s];
       assign master_valid[s] = master_list_v[0][s];
     end
   endgenerate

endmodule
