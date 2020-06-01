`timescale 1ns/1ns

module SPIRegWritetb();

	reg clk;
	reg reset;
	reg start;
	reg [7:0] value;
	reg [5:0] setup;
	wire [55:0] buffer;
	reg rw;
	wire dataReady;
	reg [55:0] valueRecorded;
	wire MOSI, SCLK, CS;
	reg MISO;

	SPIMaster DUT1(clk, reset, start, rw, setup, value, buffer, dataReady,
							MOSI, MISO, SCLK, CS);
						
	initial begin
		reset = 1'b1;
		start = 1'b0;
		#60;
		reset = 1'b0;
		start = 1'b1;
	end
	
	initial setup = 6'h20;
	initial value = 8'b00100111;
	initial rw = 1'b0;
	initial MISO = 1'b0;
	
	always begin
		clk = 1'b0;
		#20;
		clk = 1'b1;
		#20;
	end
	
	always @(*) begin
		if(dataReady) begin
			start = 1'b0;
			setup = 6'h24;
			value = 8'b10100101;
			rw = 1'b1;
			valueRecorded = buffer;
			#1000;
			start = 1'b1;
		end
	end

endmodule 