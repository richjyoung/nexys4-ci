import os

from vunit import VUnit

vu = VUnit.from_argv()

for root, dirs, files in os.walk('../../fw/src'):
    for lib in dirs:
        vu_lib = vu.add_library(lib.lower())
        vu_lib.add_source_files('../../fw/src/%s/*.vhd' % lib)

for root, dirs, files in os.walk('../../fw/tb'):
    for lib in dirs:
        vu_lib = vu.add_library(lib.lower())
        vu_lib.add_source_files('../../fw/tb/%s/*.vhd' % lib)

vu.main()