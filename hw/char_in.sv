
`timescale 1ns/1ns
`define period 12000

module char_in (
      input          clk,
      input          resetn,
      output [7:0]   char,
      output         strobe
    );

  reg char_recv;
  reg [7:0] key_pressed;
  reg local_strobe;
  reg [7:0] local_key;
  reg [31:0] count;

/*
// p.r.a.g.m.a tbx export_out_of_the_blue get_char_from_terminal 
  export "DPI-C" task get_char xxx _from_terminal;

  task get_char xxx _from_terminal(int kp);
     //$display("A key was pressed! \n");
     char_recv <= 1'b1;
     key_pressed <= kp;
  endtask
*/

  import "DPI-C" pure function byte key_ready();
  import "DPI-C" pure function byte get_key();

  assign strobe = local_strobe;
  assign char = local_key;

  always @(posedge clk) begin
     if (!resetn) begin
         char_recv <= 1'b0;
         count <= 32'h00000000;
     end else begin
         if (count < `period) begin
             count <= count + 32'h00000001;
             if (local_strobe) begin
                local_strobe <= 1'b0;
             end
         end else begin
             count <= 32'b00000000;
             if (key_ready()) begin
                 local_strobe <= 1'b1;
                 local_key <= get_key();
             end
         end
     end
  end

endmodule
