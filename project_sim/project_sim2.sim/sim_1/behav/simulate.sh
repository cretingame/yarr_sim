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
ExecStep $xv_path/bin/xsim ddr3_ctrl_wb_bench_behav -key {Behavioral:sim_1:Functional:ddr3_ctrl_wb_bench} -tclbatch ddr3_ctrl_wb_bench.tcl -view /home/asautaux/yarr_sim/project_sim/l2p_dma_bench_behav.wcfg -view /home/asautaux/yarr_sim/project_sim/wb_master64_bench_behav.wcfg -view /home/asautaux/yarr_sim/project_sim/p2l_dma_bench_behav.wcfg -view /home/asautaux/yarr_sim/project_sim/top_bench_behav.wcfg -view /home/asautaux/yarr_sim/project_sim/p2l_decoder_bench_behav.wcfg -view /home/asautaux/yarr_sim/project_sim/ddr3_ctrl_wb_bench_behav.wcfg -log simulate.log
