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
	
	reg enable;
	wire rw;
	wire [55:0] buffer;
	reg [55:0] accelData;
	reg [5:0] address, addressNext;
	reg [7:0] wData, wDataNext;
	wire ready;
	
	wire signed [7:0] 	STATUS_REG,
					OUT_X_L,
					OUT_X_H,
					OUT_Y_L,
					OUT_Y_H,
					OUT_Z_L,
					OUT_Z_H;
					
	assign STATUS_REG	= accelData[55:48];
	assign OUT_X_L 	= accelData[47:40];
	assign OUT_X_H		= accelData[39:32];
	assign OUT_Y_L		= accelData[31:24];
	assign OUT_Y_H		= accelData[23:16];
	assign OUT_Z_L		= accelData[15:8];
	assign OUT_Z_H		= accelData[7:0];
	
	wire [7:0] u_accelOut;
	assign u_accelOut = OUT_X_H + 8'd128;	//axis being measured
	
	wire [2:0] lightShift;
	assign lightShift = u_accelOut[7:5];	//split every 32
	
	wire [7:0] lightEnable;
	assign lightEnable = ~(8'hfe << ~lightShift);
	
	assign LEDR = lightEnable;

	// ---- heartbeat ----
	reg [24:0] counter, counternext;
	always @(posedge sys_clock) counter <= (reset) ? 25'h0 : counternext;
	always @(*) counternext = counter + 24'h1;
	
	SPIMaster SPIM(sys_clock, reset, enable, rw, address, wData, buffer, ready,
							MOSI, MISO, SCL, CS);
	
	localparam RESET = 3'd0, OFF = 3'd1, READACCEL = 3'd2, WRITEACCEL1 = 3'd3, WRITEACCEL2 = 3'd4;
	reg [2:0] state, stateNext;
	
	always @(posedge sys_clock) begin
		address <= reset ? 6'h00 : addressNext;
		wData <= reset ? 8'd0 : wDataNext;
		state <= reset ? RESET : stateNext;
		
		//fix flashing LEDR problem caused by shifting in values to buffer
		if(reset) accelData <= 56'd0;
		else if(ready) accelData <= buffer;
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
				addressNext = 6'h20;	//CTRL_REG1
				wDataNext = 8'b0010_1111;
				enable = 1'b1;
				if(ready) begin
					enable = 1'b0;
					stateNext = WRITEACCEL2;
				end
			end
			WRITEACCEL2: begin
				addressNext = 6'h23;	//CTRL_REG4
				wDataNext = 8'h00;
				enable = 1'b1;
				if(ready) begin
					enable = 1'b0;
					stateNext = READACCEL;
				end
			end
			READACCEL: begin
				addressNext = 6'h27;
				wDataNext = 8'h00;
				enable = counter[19];
			end
			OFF: begin
			end
			default: begin
				stateNext = RESET;
			end
		endcase
	end
	
	//assign enable = state == WRITEACCEL1 || counter[24];	// || WRITEACCEL2 || ...
	assign rw = state == READACCEL;

endmodule

// quartus_sh --flow compile SPIAccel
// quartus_pgm -m jtag -o "p;SPIAccel.sof@2"
