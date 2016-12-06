vlib work
vlib msim

vlib msim/fifo_generator_v13_1_2
vlib msim/xil_defaultlib

vmap fifo_generator_v13_1_2 msim/fifo_generator_v13_1_2
vmap xil_defaultlib msim/xil_defaultlib

vlog -work fifo_generator_v13_1_2 -64 -incr \
"../../../ipstatic/simulation/fifo_generator_vlog_beh.v" \

vcom -work fifo_generator_v13_1_2 -64 -93 \
"../../../ipstatic/hdl/fifo_generator_v13_1_rfs.vhd" \

vlog -work fifo_generator_v13_1_2 -64 -incr \
"../../../ipstatic/hdl/fifo_generator_v13_1_rfs.v" \

vlog -work xil_defaultlib -64 -incr \
"../../../../project_sim.srcs/sources_1/ip/fifo_generator_0/sim/fifo_generator_0.v" \


vlog -work xil_defaultlib "glbl.v"

