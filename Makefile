CC = arm-none-eabi-gcc
SIZE = arm-none-eabi-size
OBJCOPY = arm-none-eabi-objcopy
PICOTOOL = picotool

CFLAGS = -mcpu=cortex-m0plus -mthumb -Os \
				 -ffreestanding -fno-builtin -fno-common \
				 -ffunction-sections -fdata-sections \
				 -fno-tree-loop-distribute-patterns \
				 -Wall -Wextra -Iinclude

LDFLAGS = -mcpu=cortex-m0plus -mthumb \
					-nostdlib -nostartfiles \
					-Wl,--gc-sections \
					-T memmap.ld \
					-Wl,-Map=build/app.map

CSOURCES = $(shell find src -name '*.c')
SSOURCES = $(shell find src -name '*.S')
SOURCES = $(CSOURCES) $(SSOURCES)
OBJECTS = $(patsubst src/%,build/%.o,$(SOURCES))

BOOT2_DIR = boot2
TARGET = pico-os

.PHONY: all clean $(TARGET).uf2 flash

all: $(TARGET).uf2

# Flash target
flash: $(TARGET).uf2
	@echo ">> Flashing $<"
	$(PICOTOOL) load --update --verify --execute \
		$< -t uf2 \
		--family rp2040

# Combine app and boot2
$(TARGET).uf2: $(BOOT2_DIR)/build/boot2.uf2 build/app.uf2
	@echo ">> Combining to $@"
	$(PICOTOOL) uf2 combine $^ $@ \
		--family rp2040

# Build boot2
$(BOOT2_DIR)/build/boot2.uf2:
	@echo ">> Running $(BOOT2_DIR)/Makefile"
	$(MAKE) -C $(BOOT2_DIR)

# Convert app
build/app.uf2: build/app.bin
	@echo ">> Converting $< to $@"
	$(PICOTOOL) uf2 convert \
		$< -t bin \
		$@ -t uf2 \
		--offset 0x10000100 \
		--family rp2040

# Build app
build/app.bin: $(OBJECTS)
	@mkdir -p $(dir $@)
	@echo ">> Linking $@"
	$(CC) $(LDFLAGS) -o build/app.elf $(OBJECTS)
	$(OBJCOPY) -O binary build/app.elf $@
	@echo ">> Calculating size"
	$(SIZE) build/app.elf

# Build obj
build/%.o: src/%
	@mkdir -p $(dir $@)
	@echo ">> Compiling $<"
	$(CC) $(CFLAGS) -o $@ -c $<

# Clean up
clean:
	@echo ">> Cleaning up"
	@rm -rf build $(BOOT2_DIR)/build $(TARGET).uf2

