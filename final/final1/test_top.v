`timescale 1ps / 1ps

module test_top();

   parameter CLK = 1000000/10; // 10MHz

   parameter DATA_NUM = 256;

   reg [7:0] imem [0:DATA_NUM-1];
   reg [7:0] omem [0:DATA_NUM-1];
   
   // sorter input
   reg [7:0] data_in;
   reg 	     valid_in;
   // sorter output
   wire [7:0] data_out;
   wire       valid_out;

   // clock, reset
   reg 	      clk;
   reg 	      xrst;

   integer start_time;
   integer i, j;

   // clock generation
   always begin
      clk = 1'b1;
      #(CLK/2);
      clk = 1'b0;
      #(CLK/2);
   end

   // test senario
   initial begin

      // reset
      valid_in = 1'b0;
      #(CLK/2);
      xrst = 1'b0;
      read_data;
      #(CLK);
      xrst = 1'b1;

      start_time = $time;

      // data input
      for (i = 0; i < DATA_NUM; i = i + 1) begin
	 valid_in = 1'b1;
	 data_in = imem[i];
	 #(CLK);
      end
      valid_in = 1'b0;
   end

   initial begin
      #(CLK/2);
      #(CLK);

      // data output
      for (j = 0; j < DATA_NUM; j = j + 1) begin
	 while (valid_out == 1'b0) #(CLK);
	 omem[j]   = data_out;
	 #(CLK);
      end

      $display("Simulation time: %d ns", ($time-start_time)/1000);
      $display("Clock cycles: %d", ($time-start_time)/CLK);

      #(CLK*10);
      
      save_data;
      $finish;
   end
   
   // module
   sorter soter0(// Outputs
		 .data_out	(data_out[7:0]),
		 .valid_out	(valid_out),
	    // Inputs
		 .data_in	(data_in[7:0]),
		 .valid_in	(valid_in),
		 .clk		(clk),
		 .xrst		(xrst));
   
   task read_data;
      reg [7:0] val;
      integer fd;
      integer i;
      integer c;
      begin
	 fd = $fopen("input.dat", "r");
	 // read data
	 for (i = 0; i < DATA_NUM; i = i + 1) begin
            c = $fscanf(fd, "%d", val);
	    imem[i] = val;
         end
	 $fclose(fd);
      end
   endtask

   task save_data;
      integer fd;
      integer i;
      begin
	 fd = $fopen("output.dat", "w");
	 // write data
	 for (i = 0; i < DATA_NUM; i = i + 1) begin
	    $fdisplay(fd, "%d", omem[i]);
         end
	 $fclose(fd);
      end
   endtask

endmodule