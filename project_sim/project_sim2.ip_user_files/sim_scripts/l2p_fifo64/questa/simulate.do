onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib l2p_fifo64_opt

do {wave.do}

view wave
view structure
view signals

do {l2p_fifo64.udo}

run -all

quit -force
