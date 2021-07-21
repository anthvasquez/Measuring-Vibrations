module MeasuringVibrations(
	input 		        sys_clock,
	input 		     	KEY,
	
	output				MOSI,
	input				MISO,
	output				SCL,
	output				CS,
	input				INT1,
	input				INT2,
	
	input				UART_RX,
	output				UART_TX,
	
	output	[7:0]		LEDR
);

	wire reset;
	assign reset = ~KEY;
	
	wire accel_osync;
	wire signed [7:0] accel_data;
	
	wire FFT_osync;
	wire [21:0] FFT_data;
	
	
	wire [21:0] UART_data;
	assign UART_data = FFT_data[21:11]*FFT_data[21:11] + FFT_data[10:0]*FFT_data[10:0];
	
	wire o_uart_tx;
	wire o_busy;	
	
	//track posedge of accelerometer data sync signal
	//used to send only one sample to FFT per data read
	reg old_accel_osync;
	wire posedge_accel_osync;
	always @(posedge sys_clock) old_accel_osync <= reset ? 1'b0 : accel_osync;
	assign posedge_accel_osync = (accel_osync ^ old_accel_osync) & accel_osync;
	
							
	AccelDriver ADriver(sys_clock, reset, 1'b1, MOSI, MISO, SCL, CS, accel_osync, accel_data);
	LED_Debug	LED(sys_clock, reset, accel_osync, accel_data, LEDR);
	
	fftmain FFT(sys_clock, reset, posedge_accel_osync, {accel_data, 8'd0}, FFT_data, FFT_osync);
	
	//Trigger write any time a new sample is given&taken from the FFT
	UARTDriver UDriver(	.sys_clock(sys_clock),
						.reset(reset),
						.UART_TX(UART_TX),
						.UART_send(posedge_accel_osync),
						.new_frame(FFT_osync),
						.i_data(UART_data));

endmodule

// quartus_sh --flow compile MeasuringVibrations
// quartus_pgm -m jtag -o "p;MeasuringVibrations.sof@2"
