set top "nexys4_rev_b"
set part "xc7a100tcsg324-1"
set commit [exec git rev-parse HEAD | head -c 8]

puts "===== Building $top for device $part (commit: $commit) ====="
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
puts "    \[-\] nexys4_rev_b"
read_xdc -ref nexys4_rev_b ../constraints/nexys4_rev_b.xdc

puts "\[+\] Setting top module to $top..."
set_property top $top [current_fileset]

puts "\[+\] Synthesizing design..."
synth_design -top $top -part $part -fsm_extraction auto -resource_sharing on
write_edif -force "$top.edn"
report_utilization -file "${top}_post_synth_util.txt"
report_utilization -hierarchical -file "${top}_post_synth_util_hier.txt"
report_timing -file "${top}_post_synth_timing.txt"
report_drc -file "${top}_post_synth_drc.txt"
write_checkpoint -force "${top}_post_synth"

puts "\[+\] Optimising design..."
opt_design
puts "\[+\] Placing design..."
place_design
write_checkpoint -force "${top}_post_place"
puts "\[+\] Routing design..."
route_design
report_timing_summary -file "${top}_post_route_timing.txt"
report_utilization -file "${top}_post_route_util.txt"
report_utilization -hierarchical -file "${top}_post_route_util_hier.txt"
report_drc -file "${top}_post_route_drc.txt"
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
puts "\[+\] Generating bitstream..."
set_property BITSTREAM.CONFIG.USR_ACCESS "0x$commit" [current_design]
write_bitstream -force -file "$top.bit"
write_checkpoint -force "${top}_post_route"
file copy -force "vivado.log" "$top.log"
exit