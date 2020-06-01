module SPIMaster(		input clk,
							input reset,
							input enable,
							input rw,
							input [5:0] address,
							input [7:0] value,
							output reg [55:0] buffer,
							output ready,
							
							output MOSI,
							input MISO,
							output SCLK,
							output CS
							);
		
		
						
		localparam IDLE = 3'd0, TX = 3'd1, READ = 3'd2, WRITE = 3'd3, FINISHED = 3'd4;
		reg [2:0] state, nextState;
		
		wire [1:0] rw_ms;
		wire spiclk;
		reg [5:0] count, countNext;
		reg [4:0] tCount, tCountNext;	//count the number of bit transfers
		assign spiclk = !count[1];	//3MHz!
		assign SCLK = spiclk;
		assign CS = state == IDLE || state == FINISHED;
		assign rw_ms = rw ? 2'b11 : 2'b00;
		
		//SPIRegWrite SPIW(clk, reset, we, address, value, tCount, negedgeSignal, writeComplete, MOSIW, SCLK);
		//SPIRegRead SPIR(clk, reset, re, address, buffer, tCount, negedgeSignal, dataReady, MOSIR, MISO, SCLK);
		
		reg [15:0] data, dataNext;
		reg [55:0] bufferNext;
		
		reg oldspiclk;
		wire posedgeSCLK;
		wire negedgeSCLK;
		assign negedgeSCLK = (spiclk ^ oldspiclk) & !spiclk;
		assign posedgeSCLK = (spiclk ^ oldspiclk) & spiclk;
		
		always @(posedge clk) begin
			count <= reset ? 6'd0 : countNext;
			tCount <= reset ? 5'd0 : tCountNext;
			oldspiclk <= reset ? 1'b0 : spiclk;
			data <= reset ? 16'd0 : dataNext;
			buffer <= reset ? 56'd0 : bufferNext;
			state <= reset ? IDLE : nextState;
		end
		
		always @(*) begin
			nextState = state;
			countNext = count + 6'd1;
			tCountNext = tCount;
			bufferNext = buffer;
			case(state)
				IDLE: begin
				countNext = 6'd0;
					if(enable) begin
						tCountNext = 5'd0;
						bufferNext = 56'd1;
						nextState = TX;
					end
				end
				TX: begin	//handle setting up rw, ms, and address
					//if(writeComplete | dataReady) stateNext = FINISHED;
					if(tCount[3] & tCount[0])
						nextState = rw ? READ : WRITE;
					if(negedgeSCLK) tCountNext = tCount + 5'd1;
				end
				READ: begin
					if(posedgeSCLK) begin
						if(buffer[55]) nextState = FINISHED;
						bufferNext = {buffer[54:0], MISO};
					end
				end
				WRITE: begin
					if(tCount[4] & tCount[0])
						nextState = FINISHED;
					if(negedgeSCLK) tCountNext = tCount + 5'd1;
				end
				FINISHED: begin
					if(!enable) nextState = IDLE;
				end
			endcase
		end
		
		always @(*) begin
			dataNext = tCount == 5'd0 ? {rw_ms, address, value} : 
							negedgeSCLK ? data << 1 : 
												data;
		end
		
		//assign ready = rw ? dataReady : writeComplete;
		assign ready = state == FINISHED;
		assign MOSI = data[15];

endmodule 