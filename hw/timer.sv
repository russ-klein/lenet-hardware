module timer (                                                     
  input          clock,                                                
  input          resetn,                                               
  input  [15:0]  read_addr,                                            
  output [31:0]  read_data,                                            
  input          oe,                                                   
  input  [15:0]  write_addr,                                           
  input  [31:0]  write_data,                                           
  input  [3:0]   be,                                                   
  input          we                                                   
);                                                                     
                                                                       
 reg     [31:0]  register_bank[15:0];                                  
 reg     [31:0]  rd_reg;                                               
                                                                       
 reg             ready_out = 1'b1;                                     
 reg             resp_out = 2'b00;                                     
                                                                       
 wire    [15:0]  read_address;                                         
 wire    [15:0]  write_address;                                        
 wire            read_enable = oe;                                     
 wire            write_enable = we;                                    
                                                                       
 assign read_data = rd_reg;                                            
                                                                       
 assign read_address = read_addr[15:0];                                
 assign write_address = write_addr[15:0];                              
                                                                       
 always @(posedge clock or negedge resetn) begin                       
   if (resetn == 1'b0) begin                                           
     rd_reg <= 32'h00000000;                                           
   end else begin                                                      
     if (read_enable) begin                                            
       rd_reg <= register_bank[read_address];                          
     end                                                               
   end                                                                 
 end                                                                   
                                                                       
 always @(posedge clock or negedge resetn) begin                       
   if (resetn == 1'b0) begin                                           
       register_bank[0] <= 32'h00000000; 
   end else begin                                                      
       register_bank[0] = register_bank[0] + 32'h00000001;
   end                                                                 
 end                                                                   
                                                                       
 endmodule 
