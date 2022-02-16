
SCRIPTS_DIR ?= ../../../scripts
COMMON_DIR ?= ../common

LINKER_SCRIPT = $(COMMON_DIR)/linker.ld
CC = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy
CFLAGS += -march=rv32i -mabi=ilp32 -I$(COMMON_DIR)
LDFLAGS += -march=rv32i -mabi=ilp32

crt0.o: $(COMMON_DIR)/crt0.S
	$(CC) $(CFLAGS) -c $< -o $@

%.E: %.c
	$(CC) $(CFLAGS) -E $< -o $@

%.elf: %.o crt0.o
	$(CC) $(LDFLAGS) -Wl,-T,$(LINKER_SCRIPT),-Bstatic -nostartfiles -ffreestanding $^ -o $@
	$(SCRIPTS_DIR)/utils.py debug $@

%.hex: %.elf
	$(OBJCOPY) -O verilog $< $@

.PHONY: clean
clean:
	rm -fv *.o *.elf *.debug *.E
