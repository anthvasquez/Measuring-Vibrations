/**
* This module is meant to emulate the most simple operation of the on-board accelerometer.
* It literally just reads 1 byte and then sends the same 8 bits back.
* MISO changes on posedge SCK instead of negedge
*/
module SimpleSPISlave(	input SCK,
								input MOSI,
								output MISO,
								input CS
								);
	reg [56:0]	shift_reg;	//extra big reg so the interesting part lines up with the read data from AccelDriver :)
	
	always @(posedge SCK) begin
		shift_reg <= CS ? 57'd0 : {shift_reg[55:0], MOSI};
	end
	
	assign MISO = shift_reg[56];
	
endmodule 