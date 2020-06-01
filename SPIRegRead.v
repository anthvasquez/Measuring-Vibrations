module SPIRegRead(	input clk,
							input reset,
							input enable,
							input [5:0] startAddress,
							output [55:0] buffer,
							input [4:0] tCount,
							input fallingEdge,
							output dataReady,
							
							output MOSI,
							input MISO,
							input SCLK
							);
							
	localparam IDLE = 2'd0, TX = 2'd1, READ = 2'd2, FINISHED = 2'd3;
	reg [1:0] state, stateNext;
	reg [7:0] data, dataNext;
	
	always @(posedge clk) begin
		data <= reset ? 6'd0 : dataNext;
		state <= reset ? 2'd0 : stateNext;
	end
	
	always @(*) begin
		stateNext = state;
		case(state)
			IDLE: begin
				if(enable) stateNext = TX;
			end
			TX: begin
				if(tCount[3] & tCount[0]) stateNext = FINISHED;
			end
			READ: begin
				
			end
			FINISHED: begin
			end
		endcase
	end
	
	always @(*) begin
			dataNext = tCount == 5'd0 ? {2'b11, startAddress} : 
							fallingEdge ? data << 1 : 
												data;
		end
	
	assign dataReady = state == FINISHED;

endmodule 