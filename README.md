# copperv2
RISCV core
# Instructions:
## Run dhrystone benchmark
```bash
cd sim/verilog_testbench
make -f Makefile.verilator
```
## Debug cocotb test
```bash
# Add breakpoint() in python
source script/cocotb_debug.sh
pytest
# In separate terminal (rlwrap optional)
rlwrap netcat localhost 4440
```
