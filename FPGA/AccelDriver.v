/// <summary>
/// This module continuously reads data from the accelerometer at the specified read frequency
/// and returns data from the specified channel.
/// Currently, reconfiguring the read frequency or the data channel on the fly is not supported.
/// </summary>
/// <returns>On every rising edge of o_sync, a new value from the accelerometer appears on data</returns>
module AccelDriver(	
							input		sys_clock,
							input		reset,
							input		driver_enable,
							
							output		MOSI,
							input		MISO,
							output		SCL,
							output		CS,
							
							output		o_sync,
							output	signed	[7:0]	data
							);
							
	//signals for SPIMaster
	reg				enable;
	wire				rw;
	reg	[5:0]		address, addressNext;
	reg	[7:0]		wData, wDataNext;
	wire	[55:0]	o_buffer;
	
							
	//output reassignment
	wire signed [7:0] STATUS_REG,
					OUT_X_L,
					OUT_X_H,
					OUT_Y_L,
					OUT_Y_H,
					OUT_Z_L,
					OUT_Z_H;
	
					
	assign STATUS_REG	= o_buffer[55:48];
	assign OUT_X_L 	= o_buffer[47:40];
	assign OUT_X_H		= o_buffer[39:32];
	assign OUT_Y_L		= o_buffer[31:24];
	assign OUT_Y_H		= o_buffer[23:16];
	assign OUT_Z_L		= o_buffer[15:8];
	assign OUT_Z_H		= o_buffer[7:0];
	
	
	//PARAMETERS
	//------------------------------------------------------------------------------------------------------------------
	assign data = OUT_Z_H;
	
	//If this is changed, it's a good idea to change the CTRL register values as well.
	localparam read_freq = 10;				// 12MHz/2*2^(10) = ~5,859 reads/sec
	
	//CTRL_REG1
	localparam	CTRL_REG1 = 6'h20;
	localparam	ODR = 4'b1001,				//HR/normal: 1.344KHz, LP: 5.376KHz
					LPen = 1'b1,				//LP Mode enable
					Zen = 1'b1,					//Z-axis enable (1 = enabled)
					Yen = 1'b1,					//Y-axis enable
					Xen = 1'b1;					//X-axis enable
	
	//CTRL_REG4
	localparam	CTRL_REG4 = 6'h23;
	localparam	FS			= 2'b00,			//Full-scale selection (+/- 2g)
					HR			= 1'b0;			//High-resolution mode (1 = enabled)
	
	//------------------------------------------------------------------------------------------------------------------
	
	
	//Modules
	SPIMaster SPIM(sys_clock, reset, driver_enable & enable, rw, address, wData, o_buffer, o_sync, MOSI, MISO, SCL, CS);
	
	
	// ---- heartbeat ----
	//general purpose large counter
	reg [24:0] counter, counternext;
	always @(posedge sys_clock) counter <= (reset) ? 25'h0 : counternext;
	always @(*) counternext = counter + 25'h1;
	
	
	//define communication stages
	localparam RESET = 3'd0, OFF = 3'd1, READACCEL = 3'd2, WRITEACCEL1 = 3'd3, WRITEACCEL2 = 3'd4;
	reg [2:0] state, stateNext;
	
	//logic
	always @(posedge sys_clock) begin
		address <= reset ? 6'h00 : addressNext;
		wData <= reset ? 8'd0 : wDataNext;
		state <= reset ? RESET : stateNext;
	end
	
	
	always @(*) begin
		addressNext = address;
		wDataNext = wData;
		enable = 1'b0;
		stateNext = state;
		case(state)
			RESET: begin
				//reset whatever values
				stateNext = WRITEACCEL1;
			end
			WRITEACCEL1: begin
				addressNext = CTRL_REG1;	//CTRL_REG1
				wDataNext = {ODR, LPen, Zen, Yen, Xen};
				enable = 1'b1;
				if(o_sync) begin
					enable = 1'b0;
					stateNext = WRITEACCEL2;
				end
			end
			WRITEACCEL2: begin
				addressNext = CTRL_REG4;	//CTRL_REG4
				wDataNext = {1'b0, 1'b0, FS, HR, 2'b00, 1'b0};
				enable = 1'b1;
				if(o_sync) begin
					enable = 1'b0;
					stateNext = READACCEL;
				end
			end
			READACCEL: begin
				addressNext = 6'h27;
				wDataNext = 8'h00;
				enable = counter[read_freq];
			end
			OFF: begin
			end
			default: begin
				stateNext = RESET;
			end
		endcase
	end
	
	assign rw = state == READACCEL;

endmodule 