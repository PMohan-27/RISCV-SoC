SIM ?= verilator
TOPLEVEL_LANG = verilog
SRC_DIR = $(PWD)/../../rtl
IP_DIR = $(PWD)/../../ip

PROJECT_SOURCES = $(shell find $(SRC_DIR)/ -type f -name '*.sv')
CPU_SOURCES =  $(shell find $(IP_DIR)/riscv_core/rtl -type f -name '*.sv' | grep -v '/top\.sv$$')
AXI_SOURCES = $(shell find $(IP_DIR)/axi4/axi4-lite/rtl -type f -name '*.sv' | grep -v '/top\.sv$$')
WAVES = 1
SIM_BUILD = sim_build

VERILOG_SOURCES += $(PROJECT_SOURCES) $(CPU_SOURCES) $(AXI_SOURCES)
COMPILE_ARGS	+= -I$(SRC_DIR)

TOPLEVEL=top
MODULE=top_test

EXTRA_ARGS += --trace --trace-fst --trace-structs --x-initial unique --x-assign unique  --structs-packed


include $(shell cocotb-config --makefiles)/Makefile.sim

