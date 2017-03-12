open_hw
connect_hw_server
open_hw_target
set device [lindex [get_hw_devices xc7a100t_0] 0]
current_hw_device $device
refresh_hw_device -update_hw_probes false $device
set_property PROBES.FILE {} $device
set_property PROGRAM.FILE {nexys_toplevel.bit} $device
puts "\[+\] Programming device..."
program_hw_devices $device
exit