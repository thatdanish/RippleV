TC ?= undefined
FINAL ?= ../data/$(TC)

CROSS   := riscv32-unknown-elf
CC      := $(CROSS)-gcc
OBJCOPY := $(CROSS)-objcopy
OBJDUMP := $(CROSS)-objdump

CFLAGS  := -march=rv32im -mabi=ilp32 -nostdlib -nostartfiles \
           -ffreestanding -O0 -g

TARGET  := sw_tc/$(TC)

all: $(TARGET).hex $(TARGET).dump move

$(TARGET).elf: $(TARGET).c link.ld
	$(CC) $(CFLAGS) -T link.ld -o $@ $<

# Flat binary of the instruction memory image
$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary --only-section=.reset \
               --only-section=.trap --only-section=.text \
               --only-section=.rodata $< $@

# Hex file readable by $readmemh — 32-bit words, one per line
$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -O verilog --verilog-data-width=4 $< $@

# Human-readable disassembly for debugging
$(TARGET).dump: $(TARGET).elf
	$(OBJDUMP) -d -S $< > $@

move: 
	mkdir -p $(FINAL) && mv sw_tc/*.elf sw_tc/*.dump sw_tc/*.hex $(FINAL)
