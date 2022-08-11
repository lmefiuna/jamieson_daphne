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


module mult_and_acc(
  input wire clk,
  input wire reset,
  input wire enable,
  input wire signed [31:0] a,
  input wire signed [31:0] b,
  input wire signed [63:0] c,
  output wire signed [63:0] p
  );

  reg signed [31:0] a_reg, b_reg;
  reg signed [63:0] c_reg, p_reg;

  wire signed [63:0] p_w;

  always @(posedge clk) begin
      if (reset) begin
        a_reg <= 32'b0;
        b_reg <= 32'b0;
        c_reg <= 64'b0;
        p_reg <= 64'b0;
      end else if (enable) begin
        a_reg <= a;
        b_reg <= b;
        c_reg <= c;
        p_reg <= p_w;
      end
  end
  
  assign p_w = a_reg*b_reg + c_reg;
  assign p = p_reg;

endmodule
