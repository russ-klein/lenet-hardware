
`timescale 1ns/1ns

module uart_pl01x (
      input          CLOCK,
      input          RESETn,

      input  [11:2]  READ_ADDRESS,
      output [31:0]  READ_DATA,
      input          OE,

      input  [11:2]  WRITE_ADDRESS,
      input  [31:0]  WRITE_DATA,
      input          WE,
      input  [3:0]   BE,

      input          CTS,
      input          DSR,
      input          DCD,
      input          RI,
      output         RTS,
      output         DTR,
      output         OUT,
      input          RXD,
      output         TXD,

      input[7:0]     char_in_from_tbx,
      input          input_strobe,
      output[7:0]    char_out_to_tbx,
      output         output_strobe
    );

    parameter        wait_states = 3; 

    reg [7:0]        outgoing_byte;
    reg              out_strobe;

    wire [11:0]      addr;
// Register Map as defined by ARM

`define uartDRout       10'h000
`define uartDRin        10'h000
`define uartRSR         10'h001
`define uartRSR         10'h001
`define uartFR          10'h006
`define uartILPR        10'h008
`define uartIBRD        10'h009
`define uartFBRD        10'h00A
`define uartLCR_H       10'h00B
`define uartCR          10'h00C
`define uartIFLS        10'h00D
`define uartIMSC        10'h00E
`define uartRIS         10'h00F

`define uartMIS         10'h010
`define uartICR         10'h011
`define uartDMACR       10'h012

`define uartPeriphID0   10'h3F8
`define uartPeriphID1   10'h3F9
`define uartPeriphID2   10'h3FA
`define uartPeriphID3   10'h3FB

`define uartPCallID0    10'h3FC
`define uartPCallID1    10'h3FD
`define uartPCallID2    10'h3FE
`define uartPCallID3    10'h3FF

    reg  [15:0]      reg_bank [1023:0];
/*
// registers as defined by ARM 
    reg  [7:0]       uartDRout;               // 0 offset, write
    reg  [11:0]      uartDRin;                // 0 offset, read
    reg  [3:0]       uartRSR;                 // 4 offset, write
    reg              uartECR;                 // 4 offset, read
    reg  [8:0]       uartFR = 9'b010010000;
    reg  [7:0]       uartILPR = 8'h00;
    reg  [15:0]      uartIBRD = 16'h0000;
    reg  [5:0]       uartFBRD = 6'b000000;
    reg  [7:0]       uartLCR_H = 8'h00;
    reg  [15:0]      uartCR = 16'h0300;
    reg  [5:0]       uartIFLS = 6'b010010;
    reg  [10:0]      uartIMSC = 11'h000;
    reg  [10:0]      uartRIS = 11'h000;
    reg  [10:0]      uartMIS;
    reg  [10:0]      uartCI;
    reg  [2:0]       uartDMACR = 3'b000;

    reg  [7:0]       uartPeriphID0 = 8'h11;
    reg  [7:0]       uartPeriphID1 = 8'h10;
    reg  [7:0]       uartPeriphID2 = 8'h14;
    reg  [7:0]       uartPeriphID3 = 8'h00;
 
    reg  [7:0]       uartPCallID0 = 8'h0D;
    reg  [7:0]       uartPCallID1 = 8'hF0;
    reg  [7:0]       uartPCallID2 = 8'h05;
    reg  [7:0]       uartPCallID3 = 8'hB1;
*/
// fields of control registers

    wire [7:0]       uartDIN;
    wire             uartOE;
    wire             uartBE;
    wire             uartPE;
    wire             uartFE;
 
    wire             uartRI;
    wire             uartTXFE;
    wire             uartRXFF;
    wire             uartTXFF;
    wire             uartRXFE;
    wire             uartBUSY;
    wire             uartDCD;
    wire             uartDSR;
    wire             uartCTS;

    wire             uartSPS;
    wire [1:0]       uartWLEN;
    wire             uartFEN;
    wire             uartSTP2;
    wire             uartEPS;
    wire             uartPEN;
    wire             uartBRK;

    wire             uartCTSEn;
    wire             uartRTSEn;
    wire             uartOut2;
    wire             uartOut1;
    wire             uartRTS;
    wire             uartDTR;
    wire             uartRXE;
    wire             uartTXE;
    wire             uartLBE;
    wire             uartSIRLP;
    wire             uartSIREN;
    wire             uartUARTEN;

    wire [2:0]       uartRXIFLSEL;
    wire [2:0]       uartTXIFLSEL;

    wire             uartOEIM;
    wire             uartBEIM;
    wire             uartPEIM;
    wire             uartFEIM;
    wire             uartRTIM;
    wire             uartTXIM;
    wire             uartRXIM;
    wire             uartDSRMIM;
    wire             uartDCDMIM;
    wire             uartCTSMEM;
    wire             uartRIMIM;

    wire             uartOERIS;
    wire             uartBERIS;
    wire             uartPERIS;
    wire             uartFERIS;
    wire             uartRTRIS;
    wire             uartTXRIS;
    wire             uartRXRIS;
    wire             uartDSRRMIS;
    wire             uartDCDRMIS;
    wire             uartCTSRMIS;
    wire             uartRIRMIS;

    wire             uartOEMIS;
    wire             uartBEMIS;
    wire             uartPEMIS;
    wire             uartFEMIS;
    wire             uartRTMIS;
    wire             uartTXMIS;
    wire             uartRXMIS;
    wire             uartDSRMMIS;
    wire             uartDCDMMIS;
    wire             uartCTSMMIS;
    wire             uartRIMMIS;

    wire             uartDMAONERR;
    wire             uartTXDMAE;
    wire             uartRXDMAE;

    reg [31:0]       data_out;
    reg              write_data = 1'b0;
    reg              write_ctrl = 1'b0;
    reg              sel_en = 1'b0;

    reg              pending_write = 1'b0;
    reg [9:0]        waddr;

    wire [7:0]       fifo_output;
    wire [7:0]       buffered_keyboard_input;
    wire             keyboard_data_ready;
    reg              keyclick_ack;
    reg              key_read;

    bus_fifo char_in_buffer (
        .CLK          (CLOCK),
        .RESET_N      (RESETn),

        .DATA_STROBE  (input_strobe),
        .DATA_IN      (char_in_from_tbx),
        .FULL         (open),

        .DATA_READY   (keyboard_data_ready),
        .DATA_OUT     (fifo_output),
        .DATA_ACK     (keyclick_ack)
    );
        
    assign buffered_keyboard_input = (keyboard_data_ready) ? fifo_output : 8'h00;

    // do assignments here

    assign char_out_to_tbx = outgoing_byte;
    assign output_strobe   = out_strobe;

    assign   uartDIN       = reg_bank[`uartDRin][7:0];
    assign   uartOE        = reg_bank[`uartDRin][11];
    assign   uartBE        = reg_bank[`uartDRin][10];
    assign   uartPE        = reg_bank[`uartDRin][9];
    assign   uartFE        = reg_bank[`uartDRin][8];
  
    assign   uartRI        = reg_bank[`uartFR][8];
    assign   uartTXFE      = reg_bank[`uartFR][7];
    assign   uartRXFF      = reg_bank[`uartFR][6];
    assign   uartTXFF      = reg_bank[`uartFR][5];
    assign   uartRXFE      = reg_bank[`uartFR][4];
    assign   uartBUSY      = reg_bank[`uartFR][3];
    assign   uartDCD       = reg_bank[`uartFR][2];
    assign   uartDSR       = reg_bank[`uartFR][1];
    assign   uartCTS       = reg_bank[`uartFR][0];

    assign   uartSPS       = reg_bank[`uartLCR_H][7];
    assign   uartWLEN      = reg_bank[`uartLCR_H][6:5];
    assign   uartFEN       = reg_bank[`uartLCR_H][4];
    assign   uartSTP2      = reg_bank[`uartLCR_H][3];
    assign   uartEPS       = reg_bank[`uartLCR_H][2];
    assign   uartPEN       = reg_bank[`uartLCR_H][1];
    assign   uartBRK       = reg_bank[`uartLCR_H][0];

    assign   uartCTSEn     = reg_bank[`uartCR][15];
    assign   uartRTSEn     = reg_bank[`uartCR][14];
    assign   uartOut2      = reg_bank[`uartCR][13];
    assign   uartOut1      = reg_bank[`uartCR][12];
    assign   uartRTS       = reg_bank[`uartCR][11];
    assign   uartDTR       = reg_bank[`uartCR][10];
    assign   uartRXE       = reg_bank[`uartCR][9];
    assign   uartTXE       = reg_bank[`uartCR][8];
    assign   uartLBE       = reg_bank[`uartCR][7];
    assign   uartSIRLP     = reg_bank[`uartCR][2];
    assign   uartSIREN     = reg_bank[`uartCR][1];
    assign   uartUARTEN    = reg_bank[`uartCR][0];

    assign   uartRXIFLSEL  = reg_bank[`uartIFLS][5:3];
    assign   uartTXIFLSEL  = reg_bank[`uartIFLS][2:0];

    assign   uartOEIM      = reg_bank[`uartIMSC][10];
    assign   uartBEIM      = reg_bank[`uartIMSC][9];
    assign   uartPEIM      = reg_bank[`uartIMSC][8];
    assign   uartFEIM      = reg_bank[`uartIMSC][7];
    assign   uartRTIM      = reg_bank[`uartIMSC][6];
    assign   uartTXIM      = reg_bank[`uartIMSC][5];
    assign   uartRXIM      = reg_bank[`uartIMSC][4];
    assign   uartDSRMIM    = reg_bank[`uartIMSC][3];
    assign   uartDCDMIM    = reg_bank[`uartIMSC][2];
    assign   uartCTSMEM    = reg_bank[`uartIMSC][1];
    assign   uartRIMIM     = reg_bank[`uartIMSC][0];
 
    assign   uartOERIS     = reg_bank[`uartRIS][10];
    assign   uartBERIS     = reg_bank[`uartRIS][9];
    assign   uartPERIS     = reg_bank[`uartRIS][8];
    assign   uartFERIS     = reg_bank[`uartRIS][7];
    assign   uartRTRIS     = reg_bank[`uartRIS][6];
    assign   uartTXRIS     = reg_bank[`uartRIS][5];
    assign   uartRXRIS     = reg_bank[`uartRIS][4];
    assign   uartDSRRMIS   = reg_bank[`uartRIS][3];
    assign   uartDCRDMIS   = reg_bank[`uartRIS][2];
    assign   uartCTSRMIS   = reg_bank[`uartRIS][1];
    assign   uartRIRMIS    = reg_bank[`uartRIS][0];
 
    assign   uartOEMIS     = reg_bank[`uartMIS][10];
    assign   uartBEMIS     = reg_bank[`uartMIS][9];
    assign   uartPEMIS     = reg_bank[`uartMIS][8];
    assign   uartFEMIS     = reg_bank[`uartMIS][7];
    assign   uartRTMIS     = reg_bank[`uartMIS][6];
    assign   uartTXMIS     = reg_bank[`uartMIS][5];
    assign   uartRXMIS     = reg_bank[`uartMIS][4];
    assign   uartDSMRMIS   = reg_bank[`uartMIS][3];
    assign   uartDCMDMIS   = reg_bank[`uartMIS][2];
    assign   uartCTSMMIS   = reg_bank[`uartMIS][1];
    assign   uartRIMMIS    = reg_bank[`uartMIS][0];

    assign   uartDMAONERR  = reg_bank[`uartDMACR][2];
    assign   uartTXDMAE    = reg_bank[`uartDMACR][1];
    assign   uartRXDMAE    = reg_bank[`uartDMACR][0];

    assign   uartMIS       = reg_bank[`uartRIS] & reg_bank[`uartIMSC];

    assign   addr          = READ_ADDRESS;
    assign   waddr         = WRITE_ADDRESS;

    assign READ_DATA = data_out;

    assign data_out = (addr == 10'h000) ? buffered_keyboard_input : reg_bank[addr];

    always @(posedge CLOCK) begin

        if (!RESETn) begin // reset 

            reg_bank[`uartDRin]    <= 8'h00; 
            reg_bank[`uartRSR]     <= 4'h0; 
            reg_bank[`uartFR]      <= 9'b010010000;
            reg_bank[`uartILPR]    <= 8'h00;
            reg_bank[`uartIBRD]    <= 16'h0000;
            reg_bank[`uartFBRD]    <= 6'b000000;
            reg_bank[`uartLCR_H]   <= 8'h00;
            reg_bank[`uartCR]      <= 16'h0300;
            reg_bank[`uartIFLS]    <= 6'b010010;
            reg_bank[`uartIMSC]    <= 11'h000;
            reg_bank[`uartRIS]     <= 11'h000;
            reg_bank[`uartDMACR]   <= 3'b000;

            keyclick_ack  <= 1'b0;
            key_read      <= 1'b0;

        end else begin
           reg_bank[`uartFR][4] <= !keyboard_data_ready;
/*
           if (keyboard_data_ready) begin
               reg_bank[`uartFR][4] <= 1'b0;  // char ready (empty is false)
           end 
*/  
/*  -- made combinatorial

           if (OE) begin 
               case (addr) 

                  10'h000 : begin 
                               data_out    <= buffered_keyboard_input;
//                             reg_bank[`uartFR][4]   <= 1'b1;    // todo: add the output fifo
                               key_read    <= 1'b1;
                            end
                  10'h001 : data_out <= uartRSR;
                  10'h006 : data_out <= uartFR;
                  10'h008 : data_out <= uartILPR;
                  10'h009 : data_out <= uartIBRD;
                  10'h00A : data_out <= uartFBRD;
                  10'h00B : data_out <= uartLCR_H;
                  10'h00C : data_out <= uartCR;
                  10'h00D : data_out <= uartIFLS;
                  10'h00E : data_out <= uartIMSC;
                  10'h00F : data_out <= uartRIS;

                  10'h010 : data_out <= uartMIS;
                  10'h012 : data_out <= uartDMACR;

                  10'h3F8 : data_out <= uartPeriphID0;
                  10'h3F9 : data_out <= uartPeriphID1;
                  10'h3FA : data_out <= uartPeriphID2;
                  10'h3FB : data_out <= uartPeriphID3;
             
                  10'h3FC : data_out <= uartPCallID0;
                  10'h3FD : data_out <= uartPCallID1;
                  10'h3FE : data_out <= uartPCallID2;
                  10'h3FF : data_out <= uartPCallID3;
               endcase
           end else begin
*/
           if (OE && addr == 10'h000) begin
               key_read <= 1'b1;
           end

           if (!OE) begin
               if (key_read == 1'b1) begin
                   keyclick_ack <= 1'b1;
                   key_read <= 1'b0;
               end

               if (keyclick_ack == 1'b1) begin
                   keyclick_ack <= 1'b0;
               end

           end


           if (out_strobe) out_strobe <= 1'b0;

           if (WE) begin
              case (waddr) 

                  10'h000 : begin 
                              outgoing_byte  <= WRITE_DATA;
                              out_strobe     <= 1'b1;
                            end
                  10'h001 : reg_bank[`uartRSR]    <= 4'h0;
                  10'h008 : reg_bank[`uartILPR]   <= WRITE_DATA;
                  10'h009 : reg_bank[`uartIBRD]   <= WRITE_DATA;
                  10'h00A : reg_bank[`uartFBRD]   <= WRITE_DATA;
                  10'h00B : reg_bank[`uartLCR_H]  <= WRITE_DATA;
                  10'h00C : reg_bank[`uartCR]     <= WRITE_DATA;
                  10'h00D : reg_bank[`uartIFLS]   <= WRITE_DATA;
                  10'h00E : reg_bank[`uartIMSC]   <= WRITE_DATA;
     
                  10'h011 : reg_bank[`uartRIS]    <= reg_bank[`uartRIS] & (~WRITE_DATA);
                  10'h012 : reg_bank[`uartDMACR]  <= WRITE_DATA;

              endcase
           end 
        end
    end

endmodule
