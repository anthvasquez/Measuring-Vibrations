module UARTDriver(	input sys_clock,
					input reset,
					input UART_TX,
					input UART_send,
					input new_frame,
					input [21:0] i_data);
	
	reg fifo_write_en, fifo_write_en_next;
	reg [7:0] fifo_data, fifo_data_next;
	wire fifo_isFull;
					
	
//	State						new_frame	UART_send				next_state				output	
//	Idle						1				1							Queue frame_end		
//	Idle						0				1							Queue bin_start		
//	Queue frame_end		X				X							Queue frame_start		FIFO add frame_end	
//	Queue frame_start		X				X							Queue bin_start		FIFO add frame_start	
//	Queue bin_start		X				X							Queue data				FIFO add bin_start	
//	Queue data				X				X							Queue bin_end			FIFO add byte of data until data == 0
//	Queue bin_end			X				X							Idle						FIFO add bin_end	

//Send 7 bits of data each UART message, the MSB is reserved for determining if it's a control signal or a data signal
	
	reg old_UART_send;
	wire posedge_UART_send;
	always @(posedge sys_clock) old_UART_send <= reset ? 1'b0 : UART_send;
	assign posedge_UART_send = (UART_send ^ old_UART_send) & UART_send;
	
	//FIFO control signals (D for data)
	localparam D_FRAME_END = 8'h80, D_FRAME_START = 8'h81, D_BIN_START = 8'h82, D_BIN_END = 8'h83, D_FIFO_FULL = 8'h84;	//all control signals have the form 8'b1xxx_xxxx
	
	//states
	localparam IDLE = 3'd0, FRAME_END = 3'd1, FRAME_START = 3'd2, BIN_START = 3'd3, DATA = 3'd4, BIN_END = 3'd5, FIFO_FULL = 3'd6;
	reg [6:0] state, state_next;
	
	
	always @(posedge sys_clock) begin
		state <= reset ? IDLE : fifo_isFull ? FIFO_FULL : state_next;
		fifo_write_en <= reset ? 1'd0 : fifo_write_en_next;
		fifo_data <= reset ? 8'd0 : fifo_data_next;
	end
	
	
	//combinational logic - WRITING
	always @(*) begin
		state_next = state;
		fifo_write_en_next = 1'b1;			//default is to write something to the FIFO
		fifo_data_next = -state;		//default is to create a control signal based on the state of the moore machine (MSB must be 1)
		case(state)
			IDLE: begin
				fifo_write_en_next = 1'b0;
				if(posedge_UART_send) begin
					if(new_frame)	state_next = FRAME_END;
					else			state_next = BIN_START;
				end
			end
			FRAME_END:		state_next = FRAME_START;
			FRAME_START:	state_next = BIN_START;
			BIN_START:		state_next = BIN_END;//DATA;
			BIN_END:			state_next = IDLE;
			DATA: begin
			//TODO: send data to UART module when new fifo data is read and UART is not busy
			//Note: if(!o_busy) => raise txuart write, shift byte on posedge of o_busy;
				//TODO: implement what is described above
			end
			FIFO_FULL: begin
				fifo_write_en_next = 1'b0;
				if(~fifo_isFull) state_next = IDLE;
			end
			default: begin	//SOS
				fifo_write_en_next = 1'b0;
				state_next = IDLE;
			end
		endcase
	end
	
	////////////READING///////////
	
	wire [30:0] i_setup;
	assign i_setup = 31'h40_00_00_68;
	
	wire [7:0]	fifo_data_read;
	wire		fifo_read_en, fifo_isEmpty;
	reg		UART_wr, UART_wr_next;
	wire		UART_o_busy;
	
	txuart UART(.i_clk(sys_clock),
				.i_reset(reset),
				.i_setup(i_setup),
				.i_break(1'b0),
				.i_wr(UART_wr),
				.i_data(fifo_data_read),
				.i_cts_n(1'b0),
				.o_uart_tx(UART_TX),
				.o_busy(UART_o_busy));
					
	FIFO fifo(	.sys_clock(sys_clock),
				.reset(reset),
				.write_en(fifo_write_en),
				.pulse_mode(1'b0),
				.di(fifo_data),
				.read_en(fifo_read_en),
				.isEmpty(fifo_isEmpty),
				.isFull(fifo_isFull),
				.d_out(fifo_data_read));
	
	//add one clock cycle of delay to allow the newly written FIFO data to propogate.
	//Ackchyually, the FIFO should add this delay before driving isEmpty back to low or
	//add some pass through for same cycle read/writes, but
	//the code is much cleaner this way and you don't need that one clock cycle bro
	always @(posedge sys_clock) UART_wr <= reset ? 1'b0 : UART_wr_next;
	always @(*) UART_wr_next = ~fifo_isEmpty;
	assign fifo_read_en = UART_wr & ~UART_o_busy;

endmodule 