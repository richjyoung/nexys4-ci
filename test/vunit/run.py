import os

from vunit import VUnit

vu = VUnit.from_argv()

# Add Unisim Components package so that primitives do not generate compile error
# GHDL/VUnit seems unable to simulate these at present
unisim_lib = vu.add_library('unisim')
unisim_lib.add_source_files('/opt/Xilinx/Vivado/2016.4/data/vhdl/src/unisims/unisim_VCOMP.vhd')
unisim_lib.add_compile_option("ghdl.flags", ["--ieee=synopsys", "-frelaxed-rules"])

# Add synthesisable libraries
for root, dirs, files in os.walk('../../fw/src'):
    for lib in dirs:
        vu_lib = vu.add_library(lib.lower())
        vu_lib.add_source_files('../../fw/src/%s/*.vhd' % lib)

# Add simulation only libraries
for root, dirs, files in os.walk('../../fw/tb'):
    for lib in dirs:
        vu_lib = vu.add_library(lib.lower())
        vu_lib.add_source_files('../../fw/tb/%s/*.vhd' % lib)

vu.main()