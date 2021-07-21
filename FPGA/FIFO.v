/*
USAGE:
To write, set di to the data you want to add and pulse write_en.
To read the next piece of data in the FIFO, pulse the read_en line.
*/
module FIFO(		input				sys_clock,
					input 				reset,
					input 				write_en,	//performs one r/w action per posedge when pulse_mode is high.
					input				pulse_mode,	//enable this to queue data at the same address until write_en is pulled low.
													//when this bit is low, the write address will change every clock cycle.
					input 		[7:0]	di,
					input 				read_en,	//data read is available on d_out once this goes high.
					output 				isEmpty,
					output 				isFull,
					output reg	[7:0]	d_out);

	reg [3:0] read_addr, read_addr_next;
	reg [3:0] write_addr, write_addr_next;
	
	wire [7:0] d_out_next;
	
	RAM #(.DATA_WIDTH(8), .ADDR_WIDTH(4)) FullDuplexRAM(sys_clock, ~reset, write_en, write_addr, di, read_addr, d_out_next);
	
	localparam IDLE = 0;
	reg state, state_next;
	
	always @(posedge sys_clock) begin
		read_addr <= reset ? 4'd0 : read_addr_next;
		write_addr <= reset ? 4'd0 : write_addr_next;
		d_out <= read_en ? d_out_next : d_out;	//d_out line holds last read value until next read request
	end
	
	//---------------------writing-------------------------------
	//track negedge of write_en to switch write_addr
	reg write_en_last;
	wire negedge_write_en;
	always @(posedge sys_clock) write_en_last <= reset ? 1'b0 : write_en;
	assign negedge_write_en = (write_en_last ^ write_en) & ~write_en;
	
	always @(*) begin
		write_addr_next = write_addr;
		if((~pulse_mode & write_en) | (negedge_write_en & ~isFull)) begin
			write_addr_next = write_addr + 4'd1;
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
					
	assign isEmpty	=	read_addr == write_addr;
	assign isFull	=	read_addr == (write_addr + 1);

endmodule 