# copperv2
RISCV core
# Instructions:
## Debug cocotb test
```bash
# Add breakpoint() in python
source script/cocotb_debug.sh
pytest
# In separate terminal (rlwrap optional)
rlwrap netcat localhost 4440
```
