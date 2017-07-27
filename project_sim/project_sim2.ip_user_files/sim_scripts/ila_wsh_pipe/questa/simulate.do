onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib ila_wsh_pipe_opt

do {wave.do}

view wave
view structure
view signals

do {ila_wsh_pipe.udo}

run -all

quit -force
