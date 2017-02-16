// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (win64) Build 1733598 Wed Dec 14 22:35:39 MST 2016
// Date        : Tue Feb 07 14:35:51 2017
// Host        : W530_Dux running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/cygwin64/home/saute/yarr_sim/project_sim/project_sim.runs/dist_mem_gen_0_synth_1/dist_mem_gen_0_stub.v
// Design      : dist_mem_gen_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k160tfbg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0_11,Vivado 2016.4" *)
module dist_mem_gen_0(a, d, clk, we, spo)
/* synthesis syn_black_box black_box_pad_pin="a[15:0],d[63:0],clk,we,spo[63:0]" */;
  input [15:0]a;
  input [63:0]d;
  input clk;
  input we;
  output [63:0]spo;
endmodule
