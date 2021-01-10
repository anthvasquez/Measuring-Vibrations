module MeasuringVibrations(
	input 		          		sys_clock,
	output							MOSI,
	input								MISO,
	output							SCL,
	output							CS,
	input								INT1,
	input								INT2,
	input 		     				KEY,
	output		     [7:0]		LEDR
);

	wire reset;
	assign reset = ~KEY;
	
	wire accel_osync;
	wire signed [7:0] accel_data;
	
	wire FFT_osync;
	wire [21:0] FFT_data;
	
	
	//track posedge of accelerometer data sync signal
	//used to send only one sample to FFT per data read
	reg old_accel_osync;
	wire posedge_accel_osync;
	always @(posedge sys_clock) old_accel_osync <= reset ? 1'b0 : accel_osync;
	assign posedge_accel_osync = (accel_osync ^ old_accel_osync) & accel_osync;
	
							
	AccelDriver Driver(sys_clock, reset, 1'b1, MOSI, MISO, SCL, CS, accel_osync, accel_data);
	LED_Debug	LED(sys_clock, reset, accel_osync, accel_data, LEDR);
	
	fftmain FFT(sys_clock, reset, posedge_accel_osync, {accel_data, 8'd0}, FFT_data, FFT_osync);
	
	txuart UART(sys_clock, reset,
	//txuart(i_clk, i_reset, i_setup, i_break, i_wr, i_data,
	//	i_cts_n, o_uart_tx, o_busy);

endmodule

// quartus_sh --flow compile MeasuringVibrations
// quartus_pgm -m jtag -o "p;MeasuringVibrations.sof@2"
