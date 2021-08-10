`timescale 1us/1ns
//This testbench could have been written using an always block
//for the write, read, and data signals.
//A separate DUT could have been used for the second half of this test
//However I started writing it this way and I don't feel like rewriting it.
module tb_FIFO();

	reg reset;
	reg sys_clock;
	reg write_en;
	reg [7:0] data;
	reg read_en;
	wire isEmpty;
	wire isFull;
	wire [7:0] data_out;

	FIFO DUT1(	.sys_clock(sys_clock),
				.reset(reset),
				.write_en(write_en),
				.pulse_mode(1'b1),
				.di(data),
				.read_en(read_en),
				.isEmpty(isEmpty),
				.isFull(isFull),
				.d_out(data_out));

	initial begin
		reset = 1'b1;
		write_en = 1'b0;
		data = 8'd1;
		read_en = 1'b0;
		#30;
		reset = 1'b0;
		write_en = 1'b1;
		#30;
		write_en = 1'b0;
		data = 8'd2;
		#30;
		write_en = 1'b1;
		#30;
		write_en = 1'b0;
		data = 8'h00;
		#30;
		write_en = 1'b1;
		#30;
		write_en = 1'b0;
		data = 8'd3;
		#30;
		write_en = 1'b1;
		#30;
		write_en = 1'b0;
		#120
		
		
		read_en = 1'b1;
		#30;
		read_en = 1'b0;
		#30;
		
		read_en = 1'b1;
		#30;
		read_en = 1'b0;
		#30;
		
		read_en = 1'b1;
		#30;
		read_en = 1'b0;
		#30;
		
		read_en = 1'b1;
		#30;
		read_en = 1'b0;
		#30;
		
		#300;
		
		//Simultaneous read and write test
		write_en = 1'b0;
		data = 8'd1;
		#30;
		write_en = 1'b1;
		#30;
		
		write_en = 1'b0;
		read_en = 1'b1;
		data = 8'd2;
		#30;
		write_en = 1'b1;
		read_en = 1'b0;
		#30;
		
		write_en = 1'b0;
		read_en = 1'b1;
		data = 8'd2;
		if(data_out !== 8'd1) begin
			$display("Assertion failed");
		end
		#30;
		write_en = 1'b1;
	end
	
	always begin
		sys_clock = 1'b0;
		#5;
		sys_clock = 1'b1;
		#5;
	end

endmodule 