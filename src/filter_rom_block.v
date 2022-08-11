module filter_rom_block(
    input wire clk,
	input wire reset, 
    input wire enable,
	output wire signed [31:0] y
    );
    
    reg signed [31:0] mem [4:0];
    
    always @(posedge clk) begin
    	if (reset) begin 
    		mem[0] <= {16'b0,16'b1111000000010011}; // n1
    		mem[1] <= {16'b1111111111111110,16'b0010111011110011 + 1'b1}; // n2
    		mem[2] <= {16'b0,16'b1110000011111001}; // n3
            mem[3] <= {16'b0000000000000001,16'b1110001100111001}; // d1
            mem[4] <= {16'b1111111111111111,16'b0001110010011000 + 1'b1}; // d2
        end else if (enable) begin
            mem[0] <= mem[1];
            mem[1] <= mem[2];
            mem[2] <= mem[3];
            mem[3] <= mem[4];
            mem[4] <= mem[0];
        end
    end
    
    assign y = mem[0];

endmodule