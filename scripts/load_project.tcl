set top "nexys_toplevel"
set part "xc7a100tcsg324-1"

puts "===== Building $top for device $part ====="
puts "\[+\] Loading source files..."

foreach {lib} [glob -tails -directory "../src" -type d *] {
	puts -nonewline "    \[-\] $lib: "
	puts [glob -tails -directory "../src/$lib" "*.vhd"]
	read_vhdl -vhdl2008 -library "$lib" [glob "../src/$lib/*.vhd"]
}

puts "\[+\] Loading IP..."
set_property part $part [current_project]
set_property target_language VHDL [current_project]
set_property simulator_language VHDL [current_project]
foreach {xci} [glob -nocomplain -tails -directory "../ip" "*.xci"] {
    set rootname [file rootname $xci]
	puts "    \[-\]$rootname"
	file mkdir ../ip/${rootname}_generated
	file copy -force ../ip/$rootname.xci ../ip/${rootname}_generated/$rootname.xci
	read_ip ../ip/${rootname}_generated/$rootname.xci
    set_property generate_synth_checkpoint false [get_files $rootname.xci]
	generate_target all [get_files $rootname.xci]
}

puts "\[+\] Loading constraints..."
puts "    \[-\] nexys_toplevel"
read_xdc -ref nexys_toplevel ../constraints/nexys_toplevel.xdc

puts "\[+\] Setting top module to $top..."
set_property top $top [current_fileset]

start_gui