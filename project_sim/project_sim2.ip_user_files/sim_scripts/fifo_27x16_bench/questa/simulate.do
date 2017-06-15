onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fifo_27x16_bench_opt

do {wave.do}

view wave
view structure
view signals

do {fifo_27x16_bench.udo}

run -all

quit -force
