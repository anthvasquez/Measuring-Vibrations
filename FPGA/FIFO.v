module FIFO(	input sys_clock,
					input reset,
					input write_en,	//performs one r/w action per posedge
					input di,
					input read_en,
					output isEmpty,
					output isFull,
					output o_ready,
					output reg d_out);

	reg read_addr;
	reg read_addr_next;
	
	reg write_addr;
	reg write_addr_next;
	
	wire d_out_next;
	
	RAM #(.BYTE_WIDTH(8), .ADDR_WIDTH(4)) FullDuplexRAM(sys_clock, ~reset, write_en, write_addr, di, read_addr, d_out_next);
	
	localparam IDLE = 0;
	reg state, state_next;
	
	always @(posedge sys_clock) begin
		read_addr <= reset ? 0 : read_addr_next;
		write_addr <= reset ? 0 : write_addr_next;
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
		if(negedge_write_en & ~isFull) begin
			write_addr_next = write_addr + 1;
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
			read_addr_next = read_addr + 1;
		end
	end
					
	assign isEmpty	=	read_addr == write_addr;
	assign isFull	=	read_addr == (write_addr + 1);

endmodule 