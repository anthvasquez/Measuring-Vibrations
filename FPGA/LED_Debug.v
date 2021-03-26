module LED_Debug(
						input sys_clock,
						input reset,
						input o_sync,
						input signed [7:0] data,
						output [7:0] LEDR
						);
						
	reg [7:0] dataBuf;
	
	always @(posedge sys_clock) begin
		dataBuf <= reset ? 8'h80 : o_sync ? data : dataBuf;
	end
	
	wire [7:0] u_accelOut;
	assign u_accelOut = {!dataBuf[7], dataBuf[6:0]};	//flip MSB to convert +/- 128 to 0-255
	
	wire [2:0] lightShift;
	assign lightShift = u_accelOut[7:5];	//split every 32
	
	wire [7:0] lightEnable;
	assign lightEnable = lightShift == 3'd0 ? 8'd0 : (8'hff >> -lightShift);
	
	assign LEDR = reset ? 8'hff : lightEnable;

endmodule 