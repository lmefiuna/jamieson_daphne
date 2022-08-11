`timescale 1ns / 10ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Esteban Cristaldo 
// 
// Create Date: 07/05/2022 02:54:52 PM
// Design Name: 
// Module Name: filtroIIR_integrator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module filtroIIR_integrator(
    input wire clk,
	input wire reset,
	input wire n_1_reset,
    input wire[2:0] reg_select,
    input wire enable_reg_select,
    input wire enable,
    input wire signed[31:0] coefficient,
    input wire signed[15:0] x,
    output wire signed[15:0] y
    );
    
    reg signed[31:0] n1, n2, n3, d1, d2, x_1, x_2, y_1, y_2;
	reg signed[15:0] en_mux;
	
	wire signed[31:0] w1, w2, w4, w20, w7, w8, w12, w13, w14, w15, w16;
	wire signed[63:0] w3, w5, w9, w6, w10, w11, w17, w18, w19;
	
	always @(posedge clk) begin
		if(reset) begin
			n1 <= 32'b0;
			n2 <= 32'b0;
			n3 <= 32'b0;
			d1 <= 32'b0;
			d2 <= 32'b0;
            x_1 <= 32'b0;
            x_2 <= 32'b0;
			y_1 <= 32'b0;
			y_2 <= 32'b0;
		end else if (n_1_reset) begin
			x_1 <= 32'b0;
            x_2 <= 32'b0;
			y_1 <= 32'b0;
			y_2 <= 32'b0;
	    end else if(enable_reg_select) begin
			case(reg_select)
				3'b000: begin
					n1 <= coefficient;
				end
				3'b001: begin
					n2 <= coefficient;
				end
				3'b010: begin
					n3 <= coefficient;
				end
				3'b011: begin
					d1 <= coefficient;
				end
				3'b100: begin
					d2 <= coefficient;
				end
				default: begin
					n1 <= 32'bx;
			        n2 <= 32'bx;
			        n3 <= 32'bx;
			        d1 <= 32'bx;
			        d2 <= 32'bx;
				end
			endcase
		end else if (enable) begin
			x_1 <= w1;
			x_2 <= w4;
			y_1 <= w12;
			y_2 <= w13;
		end
	end
		
    always @(*) begin
		if(enable) begin
			en_mux <= w11[47:32];
		end else begin
			en_mux <= x;
		end
	end
	
	assign w1 = {x,16'b0};
    assign w2 = n1;
    assign w3 = (w1*w2);
    assign w4 = x_1;
    assign w20 = n2;
    assign w5 = (w4*w20);
    assign w7 = x_2;
    assign w8 = n3;
    assign w9 = (w7*w8);
    assign w6 = w3 + w5;
    assign w10 = w6 + w9;
    assign w11 = w19 + w10;
    assign w12 = w11[47:16];
    assign w13 = y_1;
    assign w14 = d1;
    assign w15 = y_2;
    assign w16 = d2;
    assign w17 = (w15*w16);
    assign w18 = (w13*w14);
    assign w19 = w18 + w17;
    assign y = en_mux;
    
endmodule
