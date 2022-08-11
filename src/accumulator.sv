module accumulator(
    input wire clk,
	input wire reset, 
    input wire enable,
	input wire signed [63:0] x,
	output wire signed [63:0] y
    );
    
    reg signed [63:0] acc;
    
    always @(posedge clk) begin
    	if (reset) begin 
    		acc <= 64'b0;
        end else if (enable) begin 
            acc <= acc + x;
        end
    end
    
    assign y = acc;

endmodule