// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.3 (win64) Build 1682563 Mon Oct 10 19:07:27 MDT 2016
// Date        : Mon Dec 12 15:35:15 2016
// Host        : W530_Dux running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/cygwin64/home/saute/yarr_sim/project_sim/project_sim.srcs/sources_1/ip/fifo_generator_0/fifo_generator_0_stub.v
// Design      : fifo_generator_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k160tfbg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_1_2,Vivado 2016.3" *)
module fifo_generator_0(rst, wr_clk, rd_clk, din, wr_en, rd_en, 
  prog_full_thresh_assert, prog_full_thresh_negate, dout, full, empty, valid, prog_full)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[63:0],wr_en,rd_en,prog_full_thresh_assert[9:0],prog_full_thresh_negate[9:0],dout[63:0],full,empty,valid,prog_full" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [63:0]din;
  input wr_en;
  input rd_en;
  input [9:0]prog_full_thresh_assert;
  input [9:0]prog_full_thresh_negate;
  output [63:0]dout;
  output full;
  output empty;
  output valid;
  output prog_full;
endmodule
