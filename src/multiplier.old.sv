module multiplier(
    input wire clk,
	input wire reset, 
    input wire enable,
	input wire signed [31:0] a,
    input wire signed [31:0] b,
	output wire signed [63:0] p
    );
    
    reg signed [63:0] value;
    
    always @(posedge clk) begin
    	if (reset) begin 
    		value <= 64'b0;
        end else if (enable) begin 
            value <= a*b;
        end
    end
    
    assign p = value;

endmodule