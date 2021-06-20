module UARTDriver(	input sys_clock,
							input reset,
							input UART_TX,
							input UART_send,
							input new_frame,
							input [21:0] i_data);
							
	wire [30:0] i_setup;
	assign i_setup = 31'h40_00_00_68;

	//txuart UART(sys_clock, reset, i_setup, 1'b1, i_wr, i_data, 1'b0, UART_TX, o_busy);
	//txuart(i_clk, i_reset, i_setup, i_break, i_wr, i_data,
	//	i_cts_n, o_uart_tx, o_busy);
	
//	State						new_frame	UART_send		next_state				output	
//	Idle						1				1					Queue frame_end		
//	Idle						0				1					Queue bin_start		
//	Queue frame_end		X				X					Queue frame_start		FIFO add frame_end	
//	Queue frame_start		X				X					Queue bin_start		FIFO add frame_start	
//	Queue bin_start		X				X					Queue data				FIFO add bin_start	
//	Queue data				X				X					Queue bin_end			FIFO add byte of data until data == 0		Note: if(!o_busy) => raise txuart write, shift byte on posedge of o_busy;
//	Queue bin_end			X				X					Idle						FIFO add bin_end	

//Send 7 bits of data each UART message, the MSB is reserved for determining if it's a control signal or not

endmodule 