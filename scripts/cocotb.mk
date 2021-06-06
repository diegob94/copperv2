DUT_COPPERV1 ?= 0
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
WAVES ?= 1
MODULE = test_copperv2
export COCOTB_ANSI_OUTPUT = 1

RTL_V1_DIR = $(ROOT)/src/main/resources/rtl_v1
VERILOG_SOURCES += $(wildcard $(RTL_V1_DIR)/*.v)
COMPILE_ARGS += -I$(RTL_V1_DIR)/include

export PYTHONBREAKPOINT=remote_pdb.set_trace
export REMOTE_PDB_HOST=localhost
export REMOTE_PDB_PORT=4440

ROOT = $(abspath ../..)

ifneq ($(DUT_COPPERV1),1)
	TOPLEVEL = copperv2
	VERILOG_SOURCES += $(ROOT)/work/chisel/copperv2.v
else
	TOPLEVEL = copperv
	PLUSARGS += +dut_copperv1
endif

ifeq ($(WAVES), 1)
	VERILOG_SOURCES += iverilog_dump.v
	COMPILE_ARGS += -s iverilog_dump
endif

ifeq ($(DEBUG_TEST), 1)
	PLUSARGS += +debug_test
endif

include $(shell cocotb-config --makefiles)/Makefile.sim

iverilog_dump.v:
	echo "// generated by cocotb.mk - $(shell date)" > $@
	echo 'module iverilog_dump();' >> $@
	echo 'reg [1023:0] test_name;' >> $@
	echo 'initial begin' >> $@
	echo '    test_name = "unknown";' >> $@
	echo '    $$dumpfile ("$(TOPLEVEL).vcd");' >> $@
	echo '    $$dumpvars(0, $(TOPLEVEL), iverilog_dump);' >> $@
	echo 'end' >> $@
	echo 'endmodule' >> $@
