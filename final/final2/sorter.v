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
	reg [7:0]			data_out_reg;
   reg 		    	   valid_out_reg;
	
	//counter
	reg [7:0] j,k;



   always @(posedge clk or negedge xrst) begin
      if (xrst == 1'b0) begin
         valid_out_reg <= 1'd0;
      end else begin
			if(valid_in == 1'b1) begin
				if(data_in == k) begin
					valid_out_reg <= 1'b1;
					data_out_reg <= k;
				end else valid_out_reg <= 1'b0;
			end
      end
   end
	
	always @(posedge clk or negedge xrst) begin
      if (xrst == 1'b0) begin
         j <= 0;
			k <= 0;
      end else begin
         if(valid_in == 1'b1)begin
				j <= j + 8'd1;
				if(j == 8'd255) k <= k + 8'd1;
			end
      end
   end

   assign data_out = data_out_reg;
   assign valid_out = valid_out_reg;

endmodule