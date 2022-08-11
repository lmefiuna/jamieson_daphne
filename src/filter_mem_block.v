module filter_mem_block(
    input wire clk,
	input wire reset,
    input wire x_enable,
    input wire y_enable,
	input wire [2:0] dir,
	input wire signed [31:0] x,
	input wire signed [31:0] y,
	output wire signed [31:0] out_mem
    );

    reg signed [31:0] mem [4:0];
    
    reg signed [31:0] output_reg; 
    
    always @(posedge clk) begin
    	if (reset) begin
    		mem[0] <= 32'b0;
    		mem[1] <= 32'b0;
    		mem[2] <= 32'b0;
    		mem[3] <= 32'b0;
    		mem[4] <= 32'b0;
        end else begin
            if (x_enable) begin
                mem[0] <= x;
                mem[1] <= mem[0];
                mem[2] <= mem[1];
            end
            if (y_enable) begin
                mem[3] <= y;
                mem[4] <= mem[3];
            end 
    	end
        output_reg <= mem[dir];
    end

    assign out_mem = (dir == 3'b000) ? x :
                     (dir == 3'b011) ? y :
                     output_reg;

endmodule