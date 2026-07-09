PREFIX = arm-none-eabi-
CC = $(PREFIX)gcc
OBJCOPY = $(PREFIX)objcopy

# Никаких сторонних папок, только чистый Cortex-M0+ ассемблер
CFLAGS = -mcpu=cortex-m0plus -mthumb -O3 -nostdlib

all: boot2.bin

boot2.elf: boot2.S
	$(CC) $(CFLAGS) boot2.S -o boot2.elf

boot2_raw.bin: boot2.elf
	$(OBJCOPY) -O binary -j .text boot2.elf boot2_raw.bin

boot2.bin: boot2_raw.bin
	python3 pad_checksum.py boot2_raw.bin boot2.bin

clean:
	rm -f boot2.elf boot2_raw.bin boot2.bin

.PHONY: all clean
