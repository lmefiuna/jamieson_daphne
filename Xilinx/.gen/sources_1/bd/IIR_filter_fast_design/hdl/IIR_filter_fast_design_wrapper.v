//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
//Date        : Mon Jul 25 13:00:23 2022
//Host        : DESKTOP-LKH6SF3 running 64-bit major release  (build 9200)
//Command     : generate_target IIR_filter_fast_design_wrapper.bd
//Design      : IIR_filter_fast_design_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module IIR_filter_fast_design_wrapper
   (clk,
    enable,
    reset,
    x,
    y);
  input clk;
  input enable;
  input reset;
  input [15:0]x;
  output [15:0]y;

  wire clk;
  wire enable;
  wire reset;
  wire [15:0]x;
  wire [15:0]y;

  IIR_filter_fast_design IIR_filter_fast_design_i
       (.clk(clk),
        .enable(enable),
        .reset(reset),
        .x(x),
        .y(y));
endmodule
