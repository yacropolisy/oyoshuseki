module counter(clk, xrst,count,state);

   input clk;
   input xrst;
   input count;

   output [6:0] state;

   reg [6:0] q;

   
   always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0)
		   q <= 7'd0;
		else if (count==1) begin
		   if (q == 7'd100)
			q <= 7'd0;
		   else
			q <= q + 7'd1;
		end			
   end

   assign state = q;

endmodule
