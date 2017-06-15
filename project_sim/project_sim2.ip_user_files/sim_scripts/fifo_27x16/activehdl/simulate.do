onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+fifo_27x16 -L unisims_ver -L unimacro_ver -L secureip -L xil_defaultlib -L xpm -O5 xil_defaultlib.fifo_27x16 xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {fifo_27x16.udo}

run -all

endsim

quit -force