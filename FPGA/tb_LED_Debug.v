`timescale 1us/1ns
module tb_LED_Debug();

	reg sys_clock;
	reg reset;
	reg o_sync;
	reg signed [7:0] data;
	wire [7:0] LEDR;
						
	LED_Debug DUT1(sys_clock, reset, o_sync, data, LEDR);
	
	initial begin
		reset = 1'b1;
		o_sync = 1'b0;
		data = 8'hc0;
		#30;
		reset = 1'b0;
		#40;
		o_sync = 1'b1;
		#40
		o_sync = 0;
		#10;
		data = 8'ha0;
		#30;
		o_sync = 1'b1;
	end
	
	always begin
		sys_clock = 1'b0;
		#5;
		sys_clock = 1'b1;
		#5;
	end

endmodule 