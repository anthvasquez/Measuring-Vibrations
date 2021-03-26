module SPIRegWrite(	input clk,
							input reset,
							input enable,
							input [5:0] address,
							input [7:0] value,
							output writeComplete,
							
							output MOSI,
							input SCLK
							);
		
		localparam IDLE = 2'd0, TX = 2'd1, FINISHED = 2'd2;
		reg [1:0] state, stateNext;
		
		reg [15:0] data, dataNext;
		reg [4:0] tCount, tCountNext;	//count the number of bit transfers
		
		reg oldsclk;
		wire fallingEdge;
		assign fallingEdge = (SCLK ^ oldsclk) & !SCLK;
		
		always @(posedge clk) begin
			data <= reset ? 16'd0 : dataNext;
			state <= reset ? 2'd0 : stateNext;
			oldsclk <= reset ? 1'b0 : SCLK;
		end
		
		always @(*) begin
			stateNext = state;
			case(state)
				IDLE: begin
					if(enable) stateNext = TX;
				end
				TX: begin
					if(tCount[4] & tCount[0]) stateNext = FINISHED;
				end
				FINISHED: begin
					if(!enable) stateNext = IDLE;
				end
			endcase
		end
		
		always @(*) begin
			dataNext = tCount == 5'd0 ? {2'b00, address, value} : 
							fallingEdge ? data << 1 : 
												data;
		end
		
		assign MOSI = data[15];
		assign writeComplete = state == FINISHED;

endmodule 