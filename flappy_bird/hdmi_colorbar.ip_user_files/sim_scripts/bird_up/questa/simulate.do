onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib bird_up_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {bird_up.udo}

run -all

quit -force
