# Run with Vivado in batch mode. Pass an output directory as the first Tcl argument.
set source_dir [file normalize [file dirname [info script]]]
set repo_dir [file dirname $source_dir]
if {$argc != 1} {
    error "Usage: vivado -mode batch -source fpga/build.tcl -tclargs <output-directory>"
}
set output_dir [file normalize [lindex $argv 0]]

file mkdir $output_dir
file copy -force [file join $repo_dir program.mem] [file join $output_dir program.mem]
cd $output_dir

read_verilog [lsort [glob [file join $repo_dir rtl *.v]]]
read_verilog [list [file join $source_dir fpga.v]]
read_xdc [list [file join $source_dir boolean.xdc]]
synth_design -top fpga_top -part xc7s50csga324-1
opt_design
place_design
route_design
report_timing_summary -file timing_summary.rpt
write_bitstream -force fpga_top.bit
