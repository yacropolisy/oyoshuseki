`timescale 1ps / 1ps

module test_counter();

   parameter CLK = 1000000/10; // 10MHz

	// for input
	reg clk;
	reg xrst;
	reg count;

	// for output
	wire [6:0] state;
	
	// module
	counter counter0(	.clk (clk),
				.xrst (xrst),
				.count (count),
				.state (state));

	// clock generation
	always begin
		clk = 1'b1;
		#(CLK/2);
		clk = 1'b0;
		#(CLK/2);
	end

   // test senario
   initial begin
		count=1;
		xrst = 1;
		#(CLK/2);
		xrst = 0;
		#(CLK);
		xrst = 1;

		#(CLK*110);
		xrst = 0;
		#(CLK/2);
		xrst = 1;
		#(CLK/2);
		#(CLK*10);
		count=0;
		#(CLK*5)
		count=1;
		#(CLK*5)

      $finish;
   end

endmodule
