CC = arm-none-eabi-gcc
PICOTOOL = picotool
OBJCOPY = arm-none-eabi-objcopy

CFLAGS = -mcpu=cortex-m0plus \
         -mthumb \
         -ffreestanding \
         -nostartfiles \
         -O2 \
         -Wall \
         -fdata-sections \
         -ffunction-sections \
         -isystem ./include -isystem ./include/standart
AFLAGS = -mcpu=cortex-m0plus \
         -mthumb \
         -x assembler-with-cpp
LDFLAGS = -nostdlib \
          -Wl,--gc-sections

CSOURCES = $(shell find src -name '*.c')
ASOURCES = $(shell find src -name '*.S')
INNERDIRS = $(patsubst src/%,build/%,$(shell find src -mindepth 1 -type d))
SOURCES = $(CSOURCES) $(ASOURCES)
OBJECTS = $(patsubst src/%,build/%.o,$(SOURCES))

LINKFILE = ./link.ld
UF2FILE = ./os.uf2
ELFTARGET = build/os.elf
BINTARGET = build/os.bin

.PHONY: all clean $(ELFTARGET) $(BINTARGET) $(UF2FILE) flush

all: $(BINTARGET)

$(BINTARGET): $(ELFTARGET)
	@echo "-- Copying binary $@"
	$(OBJCOPY) -O binary $< $@

$(ELFTARGET): $(OBJECTS)
	@echo "-- Linking elf $@"
	$(CC) $(LDFLAGS) -T $(LINKFILE) -o $@ $(OBJECTS)

build/%.c.o: src/%.c | innerdirs
	@echo "-- Compiling $< => $@"
	$(CC) $(CFLAGS) -o $@ -c $<

build/%.S.o: src/%.S | innerdirs
	@echo "-- Assembling $< => $@"
	$(CC) $(AFLAGS) -o $@ -c $<

innerdirs:
	@echo "-- Creating directory structure"
	@mkdir -pv build $(INNERDIRS)

clean:
	@echo "-- Cleaning up"
	@rm -rf build $(INNERDIRS) $(ELFTARGET) $(BINTARGET) $(UF2FILE)

$(UF2FILE): $(BINTARGET)
	@echo "-- Creating $@"
	$(PICOTOOL) uf2 convert $< $@

flush: $(UF2FILE)
	@echo "-- Flushing $< to pico"
	$(PICOTOOL) load -x $<


