module adjust_v(
   // Outputs
   rcv_req, pixel_v_out, snd_ack,
   // Inputs
   clk, xrst, pixel_v_in, rcv_ack, snd_req, from_v, to_v
);

   // clock, reset
   input clk;
   input xrst;

   // receive port (MASTER)
   input [7:0]  pixel_v_in;
   output 	rcv_req;
   input 	rcv_ack;

   // send port (SLAVE)
   output [7:0] pixel_v_out;
   input 	snd_req;
   output 	snd_ack;
   
    // parameter values
   input [7:0] 	from_v;
   input [7:0] 	to_v;

   //////////////////////////////////////////////////////////
   // stage 0 (registered primary input)
   //////////////////////////////////////////////////////////
   reg [7:0] 	s0_v_reg;
   reg [7:0] 	s0_from_v_reg;
   reg [7:0] 	s0_to_v_reg;
   reg 		s0_ack_reg;

   always @(posedge clk or negedge xrst) begin
      if (xrst == 1'b0)
	s0_v_reg <= 8'd0;
      else
	s0_v_reg <= pixel_v_in;
   end

   always @(posedge clk or negedge xrst) begin
      if (xrst == 1'b0)
	s0_from_v_reg <= 8'd0;
      else
	s0_from_v_reg <= from_v;
   end

   always @(posedge clk or negedge xrst) begin
      if (xrst == 1'b0)
	s0_to_v_reg <= 8'd0;
      else
	s0_to_v_reg <= to_v;
   end

   always @(posedge clk or negedge xrst) begin
      if (xrst == 1'b0)
	s0_ack_reg <= 1'b0;
      else
	s0_ack_reg <= rcv_ack;
   end
   
   //////////////////////////////////////////////////////////
   // stage 1 (calculation)
   //////////////////////////////////////////////////////////
   reg [7:0] 	s1_v_reg;
   reg 		s1_ack_reg;

    wire [15:0]     s1_dividend_l;
    wire [15:0]     s1_dividend_s;
    wire [15:0]     s1_dividend;

    wire [7:0]      s1_divisor_l;
    wire [7:0]      s1_divisor_s;
    wire [7:0]      s1_divisor;

    wire [7:0]      s1_quotient_l;
    wire [7:0]      s1_quotient_s;
    wire [7:0]      s1_quotient_l_sel;
    wire [7:0]      s1_quotient_s_sel;
    wire [7:0]      s1_quotient_sel;

    wire [7:0]      s1_v;

   assign s1_dividend_l = (8'd255 - s0_to_v_reg) * s0_v_reg + (s0_to_v_reg - s0_from_v_reg) * 8'd255;
   assign s1_dividend_s = s0_v_reg * s0_to_v_reg;
   assign s1_divisor_l  = 8'd255 - s0_from_v_reg;
   assign s1_divisor_s  = s0_from_v_reg;

   div_u #(16,8,8) div0(.i1(s1_dividend_l), .i2(s1_divisor_l), .o1(s1_quotient_l));
   div_u #(16,8,8) div1(.i1(s1_dividend_s), .i2(s1_divisor_s), .o1(s1_quotient_s));

   assign s1_quotient_s_sel = (s0_from_v_reg != 8'd0) ? s1_quotient_s : 8'd0;
   assign s1_quotient_l_sel = (s0_from_v_reg != 8'd255) ? s1_quotient_l : 8'd0;
   assign s1_quotient_sel = (s0_v_reg > s0_from_v_reg) ? s1_quotient_l_sel : s1_quotient_s_sel;
   assign s1_v = (s1_quotient_sel > 8'd255) ? 8'd255 : s1_quotient_sel;

   always @(posedge clk or negedge xrst) begin
      if (xrst == 1'b0)
	s1_v_reg <= 8'd0;
      else
	s1_v_reg <= s1_v;
   end

   always @(posedge clk or negedge xrst) begin
      if (xrst == 1'b0)
	s1_ack_reg <= 1'b0;
      else
	s1_ack_reg <= s0_ack_reg;
   end

   //////////////////////////////////////////////////////////
   // output
   //////////////////////////////////////////////////////////
   assign pixel_v_out = s1_v_reg;
   assign snd_ack = s1_ack_reg;
   assign rcv_req = snd_req;

endmodule
