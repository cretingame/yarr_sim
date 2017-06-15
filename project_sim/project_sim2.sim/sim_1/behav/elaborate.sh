#!/bin/bash -f
xv_path="/opt/Xilinx/Vivado/2016.2"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto a6976a0e484940b39cee4d8d27e8478c -m64 --debug typical --relax --mt 8 -L xil_defaultlib -L xpm -L fifo_generator_v13_1_1 -L unisims_ver -L unimacro_ver -L secureip --snapshot ddr3_ctrl_wb_bench_behav xil_defaultlib.ddr3_ctrl_wb_bench xil_defaultlib.glbl -log elaborate.log