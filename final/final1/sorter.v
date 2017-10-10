module sorter(
   // Outputs
   data_out, valid_out,
   // Inputs
   clk, xrst, data_in, valid_in
   );

   parameter DATA_NUM = 256;

   // clock, reset
   input clk;
   input xrst;

   // input
   input [7:0] data_in;
   input       valid_in;

   // output
   output signed [7:0] data_out;
   output 	       valid_out;

   // pipeline register
   reg [7:0] 	       s0_data_reg[0:DATA_NUM-1];
   reg 		       s0_valid_reg;
	
	//outoput reg
	reg [7:0] data_out_reg;
	
	//counter reg
	reg [7:0]	j, k;
	
	//calc j + 1
	wire [7:0]	jplus;
	assign jplus = j + 8'd1;

	
   always @(posedge clk or negedge xrst) begin
      if (xrst == 1'b0) begin
			j <= 8'd0;	
			s0_valid_reg <=1'b0;
			k <= 8'd0;
      end else begin
			j <= jplus;
			if(valid_in == 1'b1) 
				s0_data_reg[j] <= data_in;
			else begin
				if(k == s0_data_reg[j]) begin
					data_out_reg <= k;
					s0_valid_reg <= 1'b1;
				end else begin
					s0_valid_reg <= 1'b0;
				end
				if(j == 8'd255) begin
					k <= k + 8'd1;
				end
			end
      end
   end
   
   assign data_out = data_out_reg;
   assign valid_out = s0_valid_reg;

endmodule