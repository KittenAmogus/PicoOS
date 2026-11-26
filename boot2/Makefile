CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
PICOTOOL = picotool
PYTHON = python3

CFLAGS = -mcpu=cortex-m0plus -mthumb -O0
LDFLAGS = -mcpu=cortex-m0plus -mthumb -nostdlib -nostartfiles -Wl,-e,0 -Ttext=0x00000000

CRC32_SCRIPT = calculate-crc32.py

.PHONY: all build/boot2.uf2

BOOT2_S = boot2.S

all: build/boot2.uf2

build/boot2.uf2: build/boot2.bin
	@echo ">> Converting $< to $@"
	$(PICOTOOL) uf2 convert \
		$< -t bin \
		$@ -t uf2 \
		--offset 0x10000000 \
		--family rp2040

build/boot2.bin:
	@mkdir -p build
	@echo ">> Compiling $<"
	$(CC) $(CFLAGS) -o build/boot2.o -c $(BOOT2_S)
	@echo ">> Linking build/boot2.elf"
	$(CC) $(LDFLAGS) -o build/boot2.elf build/boot2.o
	@echo ">> Copying $@"
	$(OBJCOPY) -O binary build/boot2.elf build/boot2.raw.bin
	@echo ">> Calculating CRC32"
	$(PYTHON) $(CRC32_SCRIPT) build/boot2.raw.bin build/boot2.bin
