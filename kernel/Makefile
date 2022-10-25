# Kernel build system

COMP_FLAGS := -ffreestanding -mno-red-zone
LINK_FLAGS := -nostdlib -lgcc

BDIR := ../build
ODIR := $(BDIR)/obj
SDIR := src
IDIR := include

CC := i686-elf-gcc
SRCS := $(shell find $(SDIR)/ -type f -name '*.c')
OBJS := $(patsubst $(SDIR)/%.c,$(ODIR)/%.o,$(SRCS))
BUILD := $(BDIR)/kernel.bin
ENTRY := $(ODIR)/kernel_entry.o

# Pre-build
$(shell mkdir -p $(ODIR)/driver)

# Linking
$(BUILD): $(ENTRY) $(OBJS)
	$(CC) $(LINK_FLAGS) -T link.ld  $^ -o $@

-include $(shell find $(ODIR)/ -type f -name '*.d')

# Compiling
$(ODIR)/%.o: $(SDIR)/%.c
	$(CC) $(COMP_FLAGS) -c -I$(IDIR) -MMD -o $@ $<

$(ENTRY): $(SDIR)/kernel_entry.asm
	nasm $< -f elf -o $@

clean:
	rm -r $(ODIR)
	rm -f $(BUILD)
