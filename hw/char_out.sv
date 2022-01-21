
`timescale 1ns/1ns

module char_out (
      input          clk,
      input          resetn,
      input [7:0]    char,
      input          strobe
    );

  reg init = 1'b0;
  reg char_sent = 1'b0;

  import "DPI-C" task start_external_terminal();
  import "DPI-C" task send_char_to_terminal(int outchar);

  always @(posedge clk) begin
     if (!init) begin
        start_external_terminal();
        init <= 1'b1;
     end
  end

  always @(posedge clk) begin
     if (!resetn) begin
         char_sent <= 1'b0;
     end
     if (strobe) begin
         if (!char_sent) begin
             send_char_to_terminal(char);
             // $display("Character: ", char);
             char_sent <= 1'b1;
         end
     end else begin
         char_sent <= 1'b0;
     end
  end

endmodule
