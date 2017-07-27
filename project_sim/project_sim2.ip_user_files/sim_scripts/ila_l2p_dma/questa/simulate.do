onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ila_l2p_dma_opt

do {wave.do}

view wave
view structure
view signals

do {ila_l2p_dma.udo}

run -all

quit -force
