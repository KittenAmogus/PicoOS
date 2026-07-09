# =======================
# TOOLCHAIN
# =======================
CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy

# =======================
# FLAGS
# =======================
CFLAGS = -mcpu=cortex-m0plus -mthumb -O3 -nostdlib

# =======================
# RULES
# =======================
.PHONY: all clean
all: boot2.bin

boot2.elf: boot2.s
	$(CC) $(CFLAGS) $< -o $@

boot2_raw.bin: boot2.elf
	$(OBJCOPY) -O binary -j .text $< $@

boot2.bin: boot2_raw.bin
	python3 checksum.py $< $@

clean:
	@rm -f boot2.elf boot2_raw.bin boot2.bin

