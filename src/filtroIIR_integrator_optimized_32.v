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


module filtroIIR_integrator_optimized_32(
    input wire clk,
  	input wire reset,
  	input wire n_1_reset,
    input wire enable,
    input wire signed[15:0] x,
    output wire signed[15:0] y
    );

    reg signed [17:0] n1, n2, n3, d1, d2;
    reg signed [31:0] x_1, x_2, y_1, y_2;
  	reg signed[15:0] x_i, en_mux;

  	wire signed[31:0] w1, w4, w7, w12, w13, w15;
  	wire signed [17:0] w2, w20, w8, w14, w16;
  	wire signed[47:0] w3, w5, w9, w6, w10, w11, w17, w18, w19;

	always @(posedge clk) begin
		if(reset) begin
			n1 <= {3'b000,15'b111100000001001};
			n2 <= {3'b110,15'b001011101111000}; // n2
			n3 <= {3'b000,15'b111000001111100}; // n3
			d1 <= {3'b001,15'b111000110011100};
			d2 <= {3'b111,15'b000111001001100};
			x_i <= 16'b0;
      x_1 <= 32'b0;
      x_2 <= 32'b0;
			y_1 <= 32'b0;
			y_2 <= 32'b0;
		end else if (n_1_reset) begin
		  x_i <= 16'b0;
			x_1 <= 32'b0;
      x_2 <= 32'b0;
			y_1 <= 32'b0;
			y_2 <= 32'b0;
		end else if (enable) begin
		    x_i <= x;
			x_1 <= w1;
			x_2 <= w4;
			y_1 <= w12;
			y_2 <= w13;
		end
	end

    always @(posedge clk) begin
		if(enable) begin
			en_mux <= w11[46:31];
		end else begin
			en_mux <= x;
		end
	end

	assign w1 = {x_i,16'b0};
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
  assign w12 = w11[46:15];
  assign w13 = y_1;
  assign w14 = d1;
  assign w15 = y_2;
  assign w16 = d2;
  assign w17 = (w15*w16);
  assign w18 = (w13*w14);
  assign w19 = w18 + w17;
  assign y = en_mux;

endmodule
