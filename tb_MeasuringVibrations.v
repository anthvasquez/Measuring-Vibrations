`timescale 1ns/1ns
module tb_MeasuringVibrations();
	
	reg 		          		sys_clock;
	wire							MOSI;
	reg							MISO;
	wire							SCL;
	wire							CS;
	wire							INT1;
	wire							INT2;
	reg 		     				KEY;
	wire		     [7:0]		LEDR;
	
	wire reset;
	assign reset = ~KEY;
	
	wire accel_osync;
	wire signed [7:0] accel_data;
	
	AccelDriver Driver(sys_clock, reset, 1'b1, MOSI, MISO, SCL, CS, accel_osync, accel_data);
	LED_Debug	LED(sys_clock, reset, accel_osync, accel_data, LEDR);
	
	
	initial begin
		KEY = 1'b0;	//high
		#30;
		KEY = 1'b1;
	end
	
	initial MISO = 1'b0;
	
	always begin
		sys_clock = 1'b0;
		#5;
		sys_clock = 1'b1;
		#5;
	end
	
endmodule 