@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.3\\bin
call %xv_path%/xelab  -wto 065b24f1651e4cfdbcb9bd0f289efcec -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L fifo_generator_v13_1_2 -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot l2p_dma_bench_behav xil_defaultlib.l2p_dma_bench xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
