`timescale 1us/1ns
module tb_FFT();
reg i_clk;
reg i_reset;
reg i_ce;
reg [15:0] i_sample;

wire [21:0] o_result;
wire o_sync;


fftmain DUT1(i_clk, i_reset, i_ce, i_sample, o_result, o_sync);


initial begin
i_reset = 1'b1;
#30;
i_reset = 1'b0;
end

always begin
i_clk = 1'b1;
#5;
i_clk = 1'b0;
#5;
end

always begin
	i_sample = 16'h7f00;
	#500;
	
	i_sample = 16'h8100;
	#500;
end

always begin
	i_ce = 1'b1;
	#5;
	i_ce = 1'b0;
	#245;
end

endmodule 