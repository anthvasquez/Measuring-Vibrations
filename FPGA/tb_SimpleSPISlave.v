`timescale 1ns/1ns
module tb_SimpleSPISlave();
	reg 	sys_clock;
	reg	reset;
	
	wire MOSI, MISO, SCL, CS;
	wire accel_osync;
	wire signed [7:0] accel_value;
	
	AccelDriver ADriver(sys_clock, reset, 1'b1, MOSI, MISO, SCL, CS, accel_osync, accel_value);
	SimpleSPISlave Slave(SCL, MOSI, MISO, CS);
	
	initial begin
		reset = 1'b1;
		#300;
		reset = 1'b0;
	end
	
	always begin
		sys_clock = 1'b0;
		#41;
		sys_clock = 1'b1;
		#41;
	end
	
endmodule 