// full-duplex synchronous RAM
module RAM #(parameter DATA_WIDTH = 8, parameter ADDR_WIDTH = 4)
				(clk, en, we, w_addr, di, r_addr, dout);
    input	clk;
    input	we;
    input	en;
    input	[ADDR_WIDTH-1:0] w_addr;
    input	[DATA_WIDTH-1:0] di;
	input	[ADDR_WIDTH-1:0] r_addr;
    output [DATA_WIDTH-1:0] dout;
	 
    reg    [DATA_WIDTH-1:0] RAM [0:(1 << ADDR_WIDTH) - 1];  // 'DATA_WIDTH'-bit, 2^ADDR_WIDTH locations
    reg    [DATA_WIDTH-1:0] dout;

	 
    always @(posedge clk)
    begin
        if (en)
        begin
            if (we)
              RAM[w_addr] <= di;
            dout <= RAM[r_addr];
        end
    end

endmodule
