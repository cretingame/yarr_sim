onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+cross_clock_fifo -L unisims_ver -L unimacro_ver -L secureip -L xil_defaultlib -L xpm -L fifo_generator_v13_1_1 -O5 xil_defaultlib.cross_clock_fifo xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {cross_clock_fifo.udo}

run -all

endsim

quit -force
