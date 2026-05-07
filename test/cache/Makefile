SIM ?= verilator
TOPLEVEL_LANG = verilog
SRC_DIR = $(PWD)/../../rtl/

PROJECT_SOURCES = $(shell find $(SRC_DIR)/ -type f -name '*.sv')
WAVES = 1
SIM_BUILD = sim_build

VERILOG_SOURCES += $(PROJECT_SOURCES)
COMPILE_ARGS	+= -I$(SRC_DIR)

TOPLEVEL=instruction_cache
MODULE=cache_test

EXTRA_ARGS += --trace --trace-fst --trace-structs --x-initial unique --x-assign unique  --structs-packed


include $(shell cocotb-config --makefiles)/Makefile.sim

