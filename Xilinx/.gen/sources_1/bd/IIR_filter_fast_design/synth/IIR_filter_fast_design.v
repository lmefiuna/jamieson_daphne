//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
//Date        : Mon Jul 25 13:00:23 2022
//Host        : DESKTOP-LKH6SF3 running 64-bit major release  (build 9200)
//Command     : generate_target IIR_filter_fast_design.bd
//Design      : IIR_filter_fast_design
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "IIR_filter_fast_design,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=IIR_filter_fast_design,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=13,numReposBlks=12,numNonXlnxBlks=0,numHierBlks=1,maxHierDepth=1,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=4,numPkgbdBlks=0,bdsource=USER,synth_mode=Global}" *) (* HW_HANDOFF = "IIR_filter_fast_design.hwdef" *) 
module IIR_filter_fast_design
   (clk,
    enable,
    reset,
    x,
    y);
  input clk;
  input enable;
  input reset;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.X DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.X, LAYERED_METADATA undef" *) input [15:0]x;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.Y DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.Y, LAYERED_METADATA undef" *) output [15:0]y;

  wire [0:0]acc_reset_1;
  wire clk_1;
  wire enable_1;
  wire filter_FSM_0_acc_enable;
  wire filter_FSM_0_acc_reset;
  wire filter_FSM_0_macc_enable;
  wire [2:0]filter_FSM_0_mem_dir;
  wire filter_FSM_0_mult_reset;
  wire filter_FSM_0_output_reg_enable;
  wire filter_FSM_0_x_mem_enable;
  wire filter_FSM_0_y_mem_enable;
  wire [31:0]filter_mem_block_0_out;
  wire [31:0]filter_rom_block_0_y;
  wire [47:0]macc_acc_output;
  wire [0:0]mult_reset_1;
  wire [31:0]reg_32_0_y;
  wire reset_1;
  wire [15:0]x_1;
  wire [31:0]xlconcat_0_dout;
  wire [15:0]xlconstant_0_dout;
  wire [31:0]xlslice_0_Dout;
  wire [15:0]xlslice_1_Dout;

  assign clk_1 = clk;
  assign enable_1 = enable;
  assign reset_1 = reset;
  assign x_1 = x[15:0];
  assign y[15:0] = xlslice_1_Dout;
  IIR_filter_fast_design_filter_FSM_0_0 filter_FSM_0
       (.acc_enable(filter_FSM_0_acc_enable),
        .acc_reset(filter_FSM_0_acc_reset),
        .clk(clk_1),
        .enable(enable_1),
        .mem_dir(filter_FSM_0_mem_dir),
        .mult_enable(filter_FSM_0_macc_enable),
        .mult_reset(filter_FSM_0_mult_reset),
        .output_reg_enable(filter_FSM_0_output_reg_enable),
        .reset(reset_1),
        .x_mem_enable(filter_FSM_0_x_mem_enable),
        .y_mem_enable(filter_FSM_0_y_mem_enable));
  IIR_filter_fast_design_filter_mem_block_0_0 filter_mem_block_0
       (.clk(clk_1),
        .dir(filter_FSM_0_mem_dir),
        .out_mem(filter_mem_block_0_out),
        .reset(reset_1),
        .x(xlconcat_0_dout),
        .x_enable(filter_FSM_0_x_mem_enable),
        .y(reg_32_0_y),
        .y_enable(filter_FSM_0_y_mem_enable));
  IIR_filter_fast_design_filter_rom_block_0_0 filter_rom_block_0
       (.clk(clk_1),
        .enable(filter_FSM_0_macc_enable),
        .reset(reset_1),
        .y(filter_rom_block_0_y));
  macc_imp_1AWI9W4 macc
       (.A(filter_mem_block_0_out),
        .B(filter_rom_block_0_y),
        .acc_enable(filter_FSM_0_acc_enable),
        .acc_output(macc_acc_output),
        .acc_reset(acc_reset_1),
        .clk({clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1,clk_1}),
        .mult_enable(filter_FSM_0_macc_enable),
        .mult_reset(mult_reset_1));
  IIR_filter_fast_design_reg_32_0_0 reg_32_0
       (.clk(clk_1),
        .enable(filter_FSM_0_output_reg_enable),
        .reset(reset_1),
        .x(xlslice_0_Dout),
        .y(reg_32_0_y));
  IIR_filter_fast_design_util_vector_logic_0_0 util_vector_logic_0
       (.Op1(filter_FSM_0_mult_reset),
        .Op2(reset_1),
        .Res(mult_reset_1));
  IIR_filter_fast_design_util_vector_logic_1_0 util_vector_logic_1
       (.Op1(reset_1),
        .Op2(filter_FSM_0_acc_reset),
        .Res(acc_reset_1));
  IIR_filter_fast_design_xlconcat_0_0 xlconcat_0
       (.In0(xlconstant_0_dout),
        .In1(x_1),
        .dout(xlconcat_0_dout));
  IIR_filter_fast_design_xlconstant_0_0 xlconstant_0
       (.dout(xlconstant_0_dout));
  IIR_filter_fast_design_xlslice_0_0 xlslice_0
       (.Din(macc_acc_output),
        .Dout(xlslice_0_Dout));
  IIR_filter_fast_design_xlslice_1_0 xlslice_1
       (.Din(reg_32_0_y),
        .Dout(xlslice_1_Dout));
endmodule

module macc_imp_1AWI9W4
   (A,
    B,
    acc_enable,
    acc_output,
    acc_reset,
    clk,
    mult_enable,
    mult_reset);
  input [31:0]A;
  input [31:0]B;
  input acc_enable;
  output [47:0]acc_output;
  input acc_reset;
  input [31:0]clk;
  input mult_enable;
  input mult_reset;

  wire [31:0]A_1;
  wire [31:0]B_1;
  wire acc_enable_1;
  wire acc_reset_1;
  wire [47:0]c_accum_0_Q;
  wire [31:0]clk_1;
  wire mult_enable_1;
  wire [47:0]mult_gen_0_P;
  wire mult_reset_1;

  assign A_1 = A[31:0];
  assign B_1 = B[31:0];
  assign acc_enable_1 = acc_enable;
  assign acc_output[47:0] = c_accum_0_Q;
  assign acc_reset_1 = acc_reset;
  assign clk_1 = clk[31:0];
  assign mult_enable_1 = mult_enable;
  assign mult_reset_1 = mult_reset;
  IIR_filter_fast_design_c_accum_0_0 c_accum_0
       (.B(mult_gen_0_P),
        .CE(acc_enable_1),
        .CLK(clk_1[0]),
        .Q(c_accum_0_Q),
        .SCLR(acc_reset_1));
  IIR_filter_fast_design_mult_gen_0_0 mult_gen_0
       (.A(A_1),
        .B(B_1),
        .CE(mult_enable_1),
        .CLK(clk_1[0]),
        .P(mult_gen_0_P),
        .SCLR(mult_reset_1));
endmodule
