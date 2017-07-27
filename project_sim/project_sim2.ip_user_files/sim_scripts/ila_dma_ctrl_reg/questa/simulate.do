onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ila_dma_ctrl_reg_opt

do {wave.do}

view wave
view structure
view signals

do {ila_dma_ctrl_reg.udo}

run -all

quit -force
