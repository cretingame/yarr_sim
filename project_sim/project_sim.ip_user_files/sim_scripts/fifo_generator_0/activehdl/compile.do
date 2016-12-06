vlib work
vlib activehdl

vlib activehdl/fifo_generator_v13_1_2
vlib activehdl/xil_defaultlib

vmap fifo_generator_v13_1_2 activehdl/fifo_generator_v13_1_2
vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work fifo_generator_v13_1_2  -v2k5 \
"../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_1_2 -93 \
"../../../ipstatic/hdl/fifo_generator_v13_1_rfs.vhd" \

vlog -work fifo_generator_v13_1_2  -v2k5 \
"../../../ipstatic/hdl/fifo_generator_v13_1_rfs.v" \

vlog -work xil_defaultlib  -v2k5 \
"../../../../project_sim.srcs/sources_1/ip/fifo_generator_0/sim/fifo_generator_0.v" \


vlog -work xil_defaultlib "glbl.v"

