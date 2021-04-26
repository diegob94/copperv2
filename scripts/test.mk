# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

WORK=..
VERILOG_SOURCES += $(WORK)/chisel/Copperv2.v

# TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
TOPLEVEL = Copperv2

# MODULE is the basename of the Python test file
MODULE = test_my_design

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

