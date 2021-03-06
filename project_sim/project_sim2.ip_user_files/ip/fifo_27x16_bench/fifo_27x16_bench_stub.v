// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.2 (lin64) Build 1577090 Thu Jun  2 16:32:35 MDT 2016
// Date        : Wed Aug 23 10:14:58 2017
// Host        : spikepig.dhcp.lbl.gov running 64-bit CentOS Linux release 7.2.1511 (Core)
// Command     : write_verilog -force -mode synth_stub
//               /home/asautaux/Yarr-fw/ip-cores/kintex7/fifo_27x16_bench/fifo_27x16_bench_stub.v
// Design      : fifo_27x16_bench
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k160tfbg676-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_1_1,Vivado 2016.2" *)
module fifo_27x16_bench(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, almost_full, empty)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[28:0],wr_en,rd_en,dout[28:0],full,almost_full,empty" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [28:0]din;
  input wr_en;
  input rd_en;
  output [28:0]dout;
  output full;
  output almost_full;
  output empty;
endmodule
