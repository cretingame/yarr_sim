vlib work
vlib activehdl

vlib activehdl/xil_defaultlib
vlib activehdl/xpm

vmap xil_defaultlib activehdl/xil_defaultlib
vmap xpm activehdl/xpm

vlog -work xil_defaultlib -v2k5 -sv "+incdir+../../../../../../Yarr-fw/ip-cores/kintex7/ila_axis/ila_v6_1_1/hdl/verilog" "+incdir+../../../../../../Yarr-fw/ip-cores/kintex7/ila_axis/ltlib_v1_0_0/hdl/verilog" "+incdir+../../../../../../Yarr-fw/ip-cores/kintex7/ila_axis/xsdbm_v1_1_3/hdl/verilog" "+incdir+../../../../../../Yarr-fw/ip-cores/kintex7/ila_axis/xsdbs_v1_0_2/hdl/verilog" "+incdir+../../../../../../Yarr-fw/ip-cores/kintex7/ila_axis/ila_v6_1_1/hdl/verilog" "+incdir+../../../../../../Yarr-fw/ip-cores/kintex7/ila_axis/ltlib_v1_0_0/hdl/verilog" "+incdir+../../../../../../Yarr-fw/ip-cores/kintex7/ila_axis/xsdbm_v1_1_3/hdl/verilog" "+incdir+../../../../../../Yarr-fw/ip-cores/kintex7/ila_axis/xsdbs_v1_0_2/hdl/verilog" \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_base.sv" \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_dpdistram.sv" \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_dprom.sv" \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_sdpram.sv" \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_spram.sv" \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_sprom.sv" \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_tdpram.sv" \

vcom -work xpm -93 \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xil_defaultlib -93 \
"../../../../../../Yarr-fw/ip-cores/kintex7/ila_axis/sim/ila_axis.vhd" \

vlog -work xil_defaultlib "glbl.v"

