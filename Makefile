# ===============================================
# TOOLCHAIN
# ===============================================
CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
PICOTOOL = picotool

# ===============================================
# FLAGS
# ===============================================
CFLAGS = \
	-mcpu=cortex-m0plus \
	-mthumb \
	-ffreestanding \
	-nostartfiles \
	-O0 \
	-Wall \
	-fdata-sections \
	-ffunction-sections \
	-isystem ./include -isystem ./include/standart
AFLAGS = \
	-mcpu=cortex-m0plus \
	-mthumb \
	-O0 \
	-x assembler-with-cpp
LDFLAGS = \
	-nostdlib \
	-Wl,--gc-sections \
  -Wl,-Map=build/firmware.map

# ===============================================
# SOURCES
# ===============================================
CSRCS = $(shell find src -name '*.c')
ASRCS = $(shell find src -name '*.s')
SRCS = $(CSRCS) $(ASRCS)

# ===============================================
# OBJECTS
# ===============================================
OBJECTS = $(patsubst src/%,build/%.o,$(SRCS))

# ===============================================
# FILES
# ===============================================
LINKER_FILE = ./link.ld
TARGET      = firmware

# ===============================================
# RULES
# ===============================================

.PHONY: all clean build/$(TARGET).elf build/$(TARGET).bin ./$(TARGET).uf2 flush

all: build/$(TARGET).bin

build/$(TARGET).bin: build/$(TARGET).elf
	@mkdir -p $(dir $@)
	@echo "-- Copying $< => $@"
	$(OBJCOPY) -O binary $< $@

build/$(TARGET).elf: $(OBJECTS)
	@mkdir -p $(dir $@)
	@echo "-- Linking $@"
	$(CC) $(LDFLAGS) -T $(LINKER_FILE) -o $@ $^

build/%.c.o: src/%.c
	@mkdir -p $(dir $@)
	@echo " - (GCC) $(notdir $<) => $(notdir $@)"
	$(CC) $(CFLAGS) -c $< -o $@

build/%.s.o: src/%.s
	@mkdir -p $(dir $@)
	@echo " - (ASM) $(notdir $<) => $(notdir $@)"
	$(CC) $(AFLAGS) -c $< -o $@

clean:
	@echo "-- Cleaning up"
	@rm -rf build ./$(TARGET).uf2

flush: ./$(TARGET).uf2
	@echo "-- Flushing $(notdir $<)"
	$(PICOTOOL) load -x $<

