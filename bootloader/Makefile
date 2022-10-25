# Bootloader build system

SRC_DIR := .
B_DIR := ../build
BUILD := $(B_DIR)/boot_sector.bin

SRCS := $(shell find $(SRC_DIR)/ -type f -name '*.asm')

$(BUILD): $(SRCS)
	nasm -f bin -I $(SRC_DIR) $(SRC_DIR)/boot_sector.asm -o $@

clean:
	rm -f $(BUILD)
