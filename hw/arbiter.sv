/****************************************************************************
 * arbiter.sv
 * 
 * Licensed under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of
 * the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in
 * writing, software distributed under the License is
 * distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied.  See
 * the License for the specific language governing
 * permissions and limitations under the License.
 ****************************************************************************/
/*
 * Module: arbiter.sv
 * 
 * TODO: Add module documentation
 */
	module arbiter #(
			parameter int			N_REQ=2
			) (
			input						clk,
			input						rstn,
			input[N_REQ-1:0]			req,
			output						gnt,
			output[$clog2(N_REQ)-1:0]	gnt_id
			);
	
		reg state;
	
		reg [N_REQ-1:0]	gnt_o;
		reg [N_REQ-1:0]	last_gnt;
		reg [$clog2(N_REQ)-1:0] gnt_id_o;
		assign gnt = |gnt_o;
		assign gnt_id = gnt_id_o;
	
		wire[N_REQ-1:0] gnt_ppc;
		wire[N_REQ-1:0]	gnt_ppc_next;

		generate
			if (N_REQ > 1) begin
				assign gnt_ppc_next = {gnt_ppc[N_REQ-2:0], 1'b0};
			end else begin
				assign gnt_ppc_next = gnt_ppc;
			end
		endgenerate

		generate
			genvar gnt_ppc_i;
		
			for (gnt_ppc_i=N_REQ-1; gnt_ppc_i>=0; gnt_ppc_i--) begin : gnt_ppc_genblk
				if (gnt_ppc_i == 0) begin
					assign gnt_ppc[gnt_ppc_i] = last_gnt[0];
				end else begin
					assign gnt_ppc[gnt_ppc_i] = |last_gnt[gnt_ppc_i-1:0];
				end
			end
		endgenerate
	
		wire[N_REQ-1:0]		unmasked_gnt;
		generate
			genvar unmasked_gnt_i;
		
			for (unmasked_gnt_i=0; unmasked_gnt_i<N_REQ; unmasked_gnt_i++) begin : unmasked_gnt_genblk
				// Prioritized unmasked grant vector. Grant to the lowest active grant
				if (unmasked_gnt_i == 0) begin
					assign unmasked_gnt[unmasked_gnt_i] = req[unmasked_gnt_i];
				end else begin
					assign unmasked_gnt[unmasked_gnt_i] = (req[unmasked_gnt_i] & ~(|req[unmasked_gnt_i-1:0]));
				end
			end
		endgenerate
	
		wire[N_REQ-1:0]		masked_gnt;
		generate
			genvar masked_gnt_i;
		
			for (masked_gnt_i=0; masked_gnt_i<N_REQ; masked_gnt_i++) begin : masked_gnt_genblk
				if (masked_gnt_i == 0) begin
					assign masked_gnt[masked_gnt_i] = (gnt_ppc_next[masked_gnt_i] & req[masked_gnt_i]);
				end else begin
					// Select first request above the last grant
					assign masked_gnt[masked_gnt_i] = (gnt_ppc_next[masked_gnt_i] & req[masked_gnt_i] & 
							~(|(gnt_ppc_next[masked_gnt_i-1:0] & req[masked_gnt_i-1:0])));
				end
			end
		endgenerate
	
		wire[N_REQ-1:0] prioritized_gnt;

		// Give priority to the 'next' request
		assign prioritized_gnt = (|masked_gnt)?masked_gnt:unmasked_gnt;
	
		always @(posedge clk) begin
			if (rstn == 0) begin
				state <= 0;
				last_gnt <= 0;
				gnt_o <= 0;
				gnt_id_o <= 0;
			end else begin
				case (state) 
					0: begin
						if (|prioritized_gnt) begin
							state <= 1;
							gnt_o <= prioritized_gnt;
							last_gnt <= prioritized_gnt;
							gnt_id_o <= gnt2id(prioritized_gnt);
						end
					end
				
					1: begin
						if ((gnt_o & req) == 0) begin
							state <= 0;
							gnt_o <= 0;
						end
					end
				endcase
			end
		end

		function reg[$clog2(N_REQ)-1:0] gnt2id(reg[N_REQ-1:0] gnt);
			// automatic int i;
			//		static reg[$clog2(N_REQ)-1:0] result;
			reg[$clog2(N_REQ)-1:0] result;
		
			result = 0;
		
			for (int i=0; i<N_REQ; i++) begin
				if (gnt[i]) begin
					result |= i;
				end
			end
	
			return result;
		endfunction
	endmodule	

