open_hw
connect_hw_server
open_hw_target
set device [lindex [get_hw_devices xc7a100t_0] 0]
current_hw_device $device
refresh_hw_device -update_hw_probes false $device
set_property PROBES.FILE {} $device
set_property PROGRAM.FILE {nexys_toplevel.bit} $device
puts "\[+\] Programming device..."
set done [get_property REGISTER.CONFIG_STATUS.BIT14_DONE_PIN [lindex [get_hw_devices xc7a100t_0] 0]]
puts "    \[-\] DONE: $done"
program_hw_devices $device
set done [get_property REGISTER.CONFIG_STATUS.BIT14_DONE_PIN [lindex [get_hw_devices xc7a100t_0] 0]]
puts "    \[-\] DONE: $done"
if {$done == 1} {
    puts "    \[-\] Device programmed successfully"
    exit 0
} else {
    puts "    \[-\] Device programming failed"
    exit 1
}