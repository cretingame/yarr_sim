// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (win64) Build 1733598 Wed Dec 14 22:35:39 MST 2016
// Date        : Wed Jan 11 15:40:11 2017
// Host        : W530_Dux running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/cygwin64/home/saute/yarr_sim/project_sim/project_sim.srcs/sources_1/ip/fifo_128x512/fifo_128x512_stub.v
// Design      : fifo_128x512
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k160tfbg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_1_3,Vivado 2016.4" *)
module fifo_128x512(rst, wr_clk, rd_clk, din, wr_en, rd_en, 
  prog_full_thresh_assert, prog_full_thresh_negate, dout, full, empty, valid, prog_full)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[127:0],wr_en,rd_en,prog_full_thresh_assert[8:0],prog_full_thresh_negate[8:0],dout[127:0],full,empty,valid,prog_full" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [127:0]din;
  input wr_en;
  input rd_en;
  input [8:0]prog_full_thresh_assert;
  input [8:0]prog_full_thresh_negate;
  output [127:0]dout;
  output full;
  output empty;
  output valid;
  output prog_full;
endmodule
