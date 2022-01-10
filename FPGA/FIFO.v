/*
USAGE:
To write, set di to the data you want to add and pulse write_en.
To read the next piece of data in the FIFO, pulse the read_en line.

** WARNING **
When reusing this FIFO,
be aware that isEmpty is driven low one clock cycle before d_out shows the correct data.
If you do something like connecting 'read_en' to '~isEmpty', you'll get the wrong output.
Maybe I'll fix this in the futre, maybe I won't.

*/
module FIFO(	input				sys_clock,
					input 				reset,
					input 				write_en,	//performs one r/w action per posedge when pulse_mode is high.
					input					pulse_mode,	//enable this to queue data at the same address until write_en is pulled low.
															//when this bit is low, the write address will change every clock cycle while write_en is high.
					input 		[7:0]	di,
					input 				read_en,	//data read is available on d_out once this goes high.
					output 				isEmpty,
					output 				isFull,
					output		[7:0]	d_out);

	reg [3:0] read_addr, read_addr_next;
	reg [3:0] write_addr, write_addr_next;
	
	RAM #(.DATA_WIDTH(8), .ADDR_WIDTH(4)) FullDuplexRAM(sys_clock, ~reset, write_en, write_addr, di, read_addr, d_out);
	
	localparam IDLE = 0;
	reg state, state_next;
	
	always @(posedge sys_clock) begin
		read_addr <= reset ? 4'd0 : read_addr_next;
		write_addr <= reset ? 4'd0 : write_addr_next;
	end
	
	//---------------------writing-------------------------------
	//track negedge of write_en to switch write_addr
	reg write_en_last;
	wire negedge_write_en;
	always @(posedge sys_clock) write_en_last <= reset ? 1'b0 : write_en;
	assign negedge_write_en = (write_en_last ^ write_en) & ~write_en;
	
	always @(*) begin
		write_addr_next = write_addr;
		
		if(~isFull) begin
			if(pulse_mode) begin
				write_addr_next = negedge_write_en ? write_addr + 4'd1 : write_addr;
			end
			else begin
				write_addr_next = write_en ? write_addr + 4'd1 : write_addr;
			end
		end
	end
	
	
	//---------------------reading--------------------------------
	//track negedge of read_en to switch read_addr
	reg read_en_last;
	wire negedge_read_en;
	always @(posedge sys_clock) read_en_last <= reset ? 1'b0 : read_en;
	assign negedge_read_en = (read_en_last ^ read_en) & ~read_en;
	
	always @(*) begin
		read_addr_next = read_addr;
		if(negedge_read_en & ~isEmpty) begin
			read_addr_next = read_addr + 4'd1;
		end
	end
	
	wire [3:0] write_addr_plusone;
	assign write_addr_plusone = write_addr + 4'd1;	//used for isFull comparison
	
	assign isEmpty	=	read_addr == write_addr;
	assign isFull	=	read_addr == write_addr_plusone;

endmodule 