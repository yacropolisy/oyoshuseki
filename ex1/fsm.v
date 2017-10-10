module fsm(clk,xrst,start,stop,mode,state);

	input clk;
	input xrst;
	input start;
	input stop;
	input mode;
	output [1:0] state;

	reg  [1:0] st_reg;

	//state name
	parameter INIT = 2'd0;
	parameter RUN  = 2'd1;
	parameter WAIT = 2'd2;

	always @(posedge clk or negedge xrst) begin
		if (xrst == 1'b0)
			st_reg <= INIT;
		else begin
			case(st_reg)
				INIT:
					if(start == 1'b1)
						st_reg <= RUN;
				RUN:
					if(mode == 1'b1)
						st_reg <= INIT;
					else
						st_reg <= WAIT;
				WAIT:
					if(stop == 1'b1)
						st_reg <= INIT;
			endcase
		end
	end
	
	assign state = st_reg;
endmodule
