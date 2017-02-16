@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.4\\bin
call %xv_path%/xelab  -wto 065b24f1651e4cfdbcb9bd0f289efcec -m64 --debug typical --relax --mt 2 -L fifo_generator_v13_1_3 -L xil_defaultlib -L blk_mem_gen_v8_3_5 -L dist_mem_gen_v8_0_11 -L unisims_ver -L unimacro_ver -L secureip -L xpm --snapshot p2l_decoder_bench_behav xil_defaultlib.p2l_decoder_bench xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
