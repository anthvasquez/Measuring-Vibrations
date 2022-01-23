`timescale 1ns/1ns
module tb_MeasuringVibrations();
	
	reg 		          		sys_clock;
	wire							MOSI;
	wire							MISO;
	wire							SCL;
	wire							CS;
	reg							INT1;
	reg							INT2;
	reg							UART_RX;
	wire							UART_TX;
	reg 		     				KEY;
	wire		     [7:0]		LEDR;
	
	wire reset;
	assign reset = ~KEY;
	
	MeasuringVibrations DUT1(	sys_clock, KEY,
										MOSI, MISO, SCL, CS,
										INT1, INT2,
										UART_RX, UART_TX,
										LEDR);
	SimpleSPISlave Accel(SCL, MOSI, MISO, CS);
	
	initial begin
		KEY = 1'b0;	//high
		#300;
		KEY = 1'b1;
	end
	
	initial sys_clock = 1'b0;
	initial INT1 = 1'b0;
	initial INT2 = 1'b0;
	initial UART_RX = 1'b1;
	
	always begin
		#41 sys_clock = ~sys_clock;
	end
	
endmodule 