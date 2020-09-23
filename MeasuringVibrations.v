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
							
	AccelDriver Driver(sys_clock, reset, 1'b1, MOSI, MISO, SCL, CS, accel_osync, accel_data);
	LED_Debug	LED(sys_clock, reset, accel_osync, accel_data, LEDR);
	
	fftmain FFT(sys_clock, reset, accel_osync, {accel_data, 8'd0}, FFT_data, FFT_osync);

endmodule

// quartus_sh --flow compile SPIAccel
// quartus_pgm -m jtag -o "p;SPIAccel.sof@2"
