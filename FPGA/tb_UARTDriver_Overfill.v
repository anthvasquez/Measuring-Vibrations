/*
Test what happens when the FIFO is fully filled and then fully emptied.
*/
`timescale 1us/1ns
module tb_UARTDriver_Overfill();
	
	reg reset;
	reg sys_clock;
	wire UART_TX;
	wire UART_send;
	reg [21:0] i_data;
	
	reg [14:0] counter;
	
	/*module UARTDriver(	input sys_clock,
							input reset,
							input UART_TX,
							input UART_send,
							input new_frame,
							input [21:0] i_data);*/
	UARTDriver OverfillTest(sys_clock, reset, UART_TX, UART_send, new_frame, i_data);
	
	
	initial begin
		reset = 1'b1;
		i_data = 22'h0f0f0f;
		#30;
		reset = 1'b0;
	end
	
	initial counter = 15'd0;
	always @(posedge sys_clock) counter <= reset ? 15'd0 : counter + 15'd1;
	assign UART_send = counter[6];
							
	always begin
		sys_clock = 1'b0;
		#5;
		sys_clock = 1'b1;
		#5;
	end
	
endmodule 