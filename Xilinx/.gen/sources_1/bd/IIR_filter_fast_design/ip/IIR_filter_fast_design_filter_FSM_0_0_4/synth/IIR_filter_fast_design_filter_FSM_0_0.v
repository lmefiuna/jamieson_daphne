// (c) Copyright 1995-2022 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:filter_FSM:1.0
// IP Revision: 1

(* X_CORE_INFO = "filter_FSM,Vivado 2022.1" *)
(* CHECK_LICENSE_TYPE = "IIR_filter_fast_design_filter_FSM_0_0,filter_FSM,{}" *)
(* CORE_GENERATION_INFO = "IIR_filter_fast_design_filter_FSM_0_0,filter_FSM,{x_ipProduct=Vivado 2022.1,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=filter_FSM,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,s0=000,s1=001,s2=010,s3=011,s4=100,s5=101,s6=110}" *)
(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module IIR_filter_fast_design_filter_FSM_0_0 (
  clk,
  reset,
  enable,
  mult_reset,
  mult_enable,
  acc_reset,
  acc_enable,
  output_reg_enable,
  x_mem_enable,
  y_mem_enable,
  mem_dir
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, ASSOCIATED_RESET reset, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
input wire clk;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset RST" *)
input wire reset;
input wire enable;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME mult_reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 mult_reset RST" *)
output wire mult_reset;
output wire mult_enable;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME acc_reset, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 acc_reset RST" *)
output wire acc_reset;
output wire acc_enable;
output wire output_reg_enable;
output wire x_mem_enable;
output wire y_mem_enable;
output wire [2 : 0] mem_dir;

  filter_FSM #(
    .s0(3'B000),
    .s1(3'B001),
    .s2(3'B010),
    .s3(3'B011),
    .s4(3'B100),
    .s5(3'B101),
    .s6(3'B110)
  ) inst (
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .mult_reset(mult_reset),
    .mult_enable(mult_enable),
    .acc_reset(acc_reset),
    .acc_enable(acc_enable),
    .output_reg_enable(output_reg_enable),
    .x_mem_enable(x_mem_enable),
    .y_mem_enable(y_mem_enable),
    .mem_dir(mem_dir)
  );
endmodule
