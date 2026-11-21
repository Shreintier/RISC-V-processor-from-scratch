set source_dir [file normalize [file dirname [info script]]]
if {$argc != 1} {error "Pass the build output directory as a Tcl argument"}
set output_dir [file normalize [lindex $argv 0]]
file mkdir $output_dir
cd $output_dir
read_verilog [list [file join $source_dir led_blink.v]]
read_xdc [list [file join $source_dir led_blink.xdc]]
synth_design -top led_blink -part xc7s50csga324-1
opt_design
place_design
route_design
report_timing_summary -file timing_summary.rpt
write_bitstream -force led_blink.bit
