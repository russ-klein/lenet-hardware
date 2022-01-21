
// Null peripheral, used as a placeholder when no accelerator is in the design
// should not be accessed, but will not cause issues if it is

module cat_accel
    (
        CLK,
        RSTn,
        READ_ADDR,
        DATA_OUT,
        DATA_VALID,
        OE,
        WRITE_ADDR,
        DATA_IN,
        BE,
        WE,
        WACK
    );

    parameter address_width     = 22;
    parameter data_width        = 2; //   in 2^data_width bytes
                                     //   0 = 8 bits  1 = 16 bits  2 = 32 bits  3 = 64 bits
                                     //   memory is always byte addressible

    input                                CLK;
    input                                RSTn;
    input [address_width-1:0]            READ_ADDR;
    output [((1<<data_width)*8)-1:0]     DATA_OUT;
    output                               DATA_VALID;
    input                                OE;
    input [address_width-1:0]            WRITE_ADDR;
    input [((1<<data_width)*8)-1:0]      DATA_IN;
    input [(1<<data_width)-1:0]          BE;
    input                                WE;
    output                               WACK;
    
    reg local_data_valid;
    reg local_wack;

    genvar w;

    assign DATA_OUT = 32'h0000DEAD;
    assign DATA_VALID = local_data_valid;
    always @(posedge CLK) begin
       local_wack <= (WE && BE) ? 1'b1 : 1'b0;
    end

    assign WACK = local_wack;

    always @(posedge CLK) begin
        local_data_valid <= OE;
    end 

    always @(posedge CLK) begin
        if (OE || (WE && BE)) begin
           $display("Null peripheral accessed, did you mean to do that? ");
        end
    end

endmodule
