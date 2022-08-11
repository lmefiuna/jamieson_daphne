module reg_32(
    input wire clk,
	input wire reset, 
    input wire enable,
	input wire signed [31:0] x,
	output wire signed [31:0] y
    );
    
    reg signed [31:0] value;
    
    always @(posedge clk) begin
    	if (reset) begin 
    		value <= 32'b0;
        end else if (enable) begin 
            value <= x;
        end
    end
    
    assign y = value;

endmodule