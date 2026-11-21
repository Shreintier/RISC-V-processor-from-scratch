open_hw_manager
connect_hw_server -url localhost:3121
set targets [get_hw_targets]
puts "BOARD_TARGETS=$targets"
if {[llength $targets] != 1} {error "Expected one connected JTAG target"}
open_hw_target [lindex $targets 0]
puts "BOARD_DEVICES=[get_hw_devices]"
close_hw_manager
