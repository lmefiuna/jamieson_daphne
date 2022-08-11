module filtroIIR(
	input wire clk,
	input wire reset, 
	input wire n_1_reset, 
    input wire[1:0] reg_select,
	input wire enable_reg_select,
	input wire en,
    input wire signed[31:0] coefficient, 
	input wire signed[15:0] x,
    output wire signed[15:0] y
);

	reg signed[31:0] coefficient_1, coefficient_2, coefficient_3, x_1, y_1;
	reg signed[15:0] en_mux;	
	
	wire signed[31:0] w1, w3, w4, w9, w10, w11, w12;
	wire signed[63:0] w2, w5, w6, w7, w8;

	always @(posedge clk) begin 
		if(reset) begin 
			coefficient_1 <= 32'b0;
			coefficient_2 <= 32'b0;
			coefficient_3 <= 32'b0;
            x_1 <= 32'b0;
			y_1 <= 32'b0;
		end else if (n_1_reset) begin 
			x_1 <= 32'b0;
			y_1 <= 32'b0;
	    end else if(enable_reg_select) begin  
			case(reg_select)
				2'b00: begin 
					coefficient_1 <= coefficient;
				end
				2'b01: begin
					coefficient_2 <= coefficient;
				end
				2'b10: begin 
					coefficient_3 <= coefficient;
				end
				default: begin
					coefficient_1 <= 32'bx;
					coefficient_2 <= 32'bx;  
       			    coefficient_3 <= 32'bx;
				end
			endcase
		end else if (en) begin
			x_1 <= w1;
			y_1 <= w9;
		end
	end

	always @(*) begin
		if(en) begin 
			en_mux <= w8[47:32];
		end else begin 
			en_mux <= x;
		end
	end

	assign w1 = {x,16'b0};
    assign w12 = coefficient_1;
    assign w2 = (w12*w1);
	assign w3 = x_1;
    assign w4 = coefficient_2;
	assign w5 = (w3*w4);
	assign w6 = (w2 + w5);
	assign w7 = (w10*w11);
	assign w8 = (w6 + w7);
	assign w9 = w8[47:16];
	assign w10 = y_1;
	assign w11 = coefficient_3;
	assign y = en_mux;

endmodule
	

	  
