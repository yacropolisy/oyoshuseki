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
   // stage 1 (calculation1)
   //////////////////////////////////////////////////////////

    reg 				 s1_ack_reg;
	 reg [7:0] 		 s1_v_reg;
	 
	 reg [15:0]     s1_dividend_l_reg;
    reg [15:0]     s1_dividend_s_reg;

    reg [7:0]      s1_divisor_l_reg;
    reg [7:0]      s1_divisor_s_reg;

    wire [15:0]     s1_dividend_l;
    wire [15:0]     s1_dividend_s;
    wire [15:0]     s1_dividend;

    wire [7:0]      s1_divisor_l;
    wire [7:0]      s1_divisor_s;
    wire [7:0]      s1_divisor;

	assign s1_dividend_l = (8'd255 - s0_to_v_reg) * s0_v_reg + (s0_to_v_reg - s0_from_v_reg) * 8'd255;
   assign s1_dividend_s = s0_v_reg * s0_to_v_reg;
   assign s1_divisor_l  = 8'd255 - s0_from_v_reg;
   assign s1_divisor_s  = s0_from_v_reg;
    
   always @(posedge clk or negedge xrst) begin
      if (xrst == 1'b0)
	s1_v_reg <= 8'd0;
      else
	s1_v_reg <= s0_v_reg;
	
   end

   always @(posedge clk or negedge xrst) begin
      if (xrst == 1'b0)
	s1_ack_reg <= 1'b0;
      else
	s1_ack_reg <= s0_ack_reg;
   end
	
   always @(posedge clk or negedge xrst) begin
      if (xrst == 1'b0) begin
	s1_dividend_l_reg <= 8'd0;
	s1_dividend_s_reg <= 8'd0;

   s1_divisor_l_reg <= 8'd0;
   s1_divisor_s_reg <= 8'd0;
		end
      else begin
	s1_dividend_l_reg <= s1_dividend_l;
	s1_dividend_s_reg <= s1_dividend_s;

   s1_divisor_l_reg <= s1_divisor_l;
   s1_divisor_s_reg <= s1_divisor_s;
		end
   end

	//////////////////////////////////////////////////////////
   // stage 2 (calculation2)
   //////////////////////////////////////////////////////////
	 reg 				  s2_ack_reg;
	 reg [7:0] 		  s2_v_reg;
	 wire [7:0]      s2_quotient_l;
    wire [7:0]      s2_quotient_s;
    reg [7:0]      s2_quotient_l_reg;
    reg [7:0]      s2_quotient_s_reg;

   div_u #(16,8,8) div0(.i1(s1_dividend_l_reg), .i2(s1_divisor_l_reg), .o1(s2_quotient_l));
   div_u #(16,8,8) div1(.i1(s1_dividend_s_reg), .i2(s1_divisor_s_reg), .o1(s2_quotient_s));
	
	always @(posedge clk or negedge xrst) begin
      if (xrst == 1'b0)
	s2_v_reg <= 8'd0;
      else
	s2_v_reg <= s1_v_reg;
   end

   always @(posedge clk or negedge xrst) begin
      if (xrst == 1'b0)
	s2_ack_reg <= 1'b0;
      else
	s2_ack_reg <= s1_ack_reg;
   end
	
	always @(posedge clk or negedge xrst) begin
      if (xrst == 1'b0) begin
	s2_quotient_l_reg <= 8'd0;
	s2_quotient_s_reg <= 8'd0;
		end
      else begin
	s2_quotient_l_reg <= s2_quotient_l;
	s2_quotient_s_reg <= s2_quotient_s;
		end
   end
	//////////////////////////////////////////////////////////
   // stage 3 (calculation3)
   //////////////////////////////////////////////////////////
	 reg 				  s3_ack_reg;
	 reg [7:0] 		  s3_v_reg;
    wire [7:0]      s3_quotient_l_sel;
    wire [7:0]      s3_quotient_s_sel;
    wire [7:0]      s3_quotient_sel;

    wire [7:0]      s3_v;

   assign s3_quotient_s_sel = (s0_from_v_reg != 8'd0) ? s2_quotient_s_reg : 8'd0;
   assign s3_quotient_l_sel = (s0_from_v_reg != 8'd255) ? s2_quotient_l_reg : 8'd0;
   assign s3_quotient_sel = (s2_v_reg > s0_from_v_reg) ? s3_quotient_l_sel : s3_quotient_s_sel;
   assign s3_v = (s3_quotient_sel > 8'd255) ? 8'd255 : s3_quotient_sel;
	
	always @(posedge clk or negedge xrst) begin
      if (xrst == 1'b0)
	s3_v_reg <= 8'd0;
      else
	s3_v_reg <= s3_v;
   end

   always @(posedge clk or negedge xrst) begin
      if (xrst == 1'b0)
	s3_ack_reg <= 1'b0;
      else
	s3_ack_reg <= s2_ack_reg;
   end

   //////////////////////////////////////////////////////////
   // output
   //////////////////////////////////////////////////////////
   assign pixel_v_out = s3_v_reg;
   assign snd_ack = s3_ack_reg;
   assign rcv_req = snd_req;

endmodule
