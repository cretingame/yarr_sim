@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.4\\bin
call %xv_path%/xsim top_bench_behav -key {Behavioral:sim_1:Functional:top_bench} -tclbatch top_bench.tcl -view C:/cygwin64/home/saute/yarr_sim/project_sim/l2p_dma_bench_behav.wcfg -view C:/cygwin64/home/saute/yarr_sim/project_sim/wb_master64_bench_behav.wcfg -view C:/cygwin64/home/saute/yarr_sim/project_sim/p2l_dma_bench_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
