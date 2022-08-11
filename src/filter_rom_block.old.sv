module filter_rom_block(
    input wire clk,
	input wire reset, 
	input wire [2:0] dir,
	output wire signed [31:0] y
    );
    
    reg signed [31:0] mem [4:0];
    reg signed [31:0] output_reg;
    
    always @(posedge clk) begin
    	if (reset) begin 
    		mem[0] <= {16'b0,16'b1111000000010011}; // n1
    		mem[1] <= {16'b1111111111111110,16'b0010111011110011 + 1'b1}; // n2
    		mem[2] <= {16'b0,16'b1110000011111001}; // n3
            mem[3] <= {16'b0000000000000001,16'b1110001100111001}; // d1
            mem[4] <= {16'b1111111111111111,16'b0001110010011000 + 1'b1}; // d2
        end
        output_reg <= mem[dir];
    end
    
    assign y = output_reg;

endmodule