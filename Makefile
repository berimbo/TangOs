# Global build system

B_DIR := ./build
U_DIR := ./utils
IMG := tangos.img
OF := /dev/sda
SEC_COUNT := 55 # 55 sectors seems to be the limit

# Pre-build
$(shell mkdir -p $(B_DIR))

build: compile
	$(U_DIR)/create_img $(IMG) $(B_DIR)/boot_sector.bin $(B_DIR)/kernel.bin $(SEC_COUNT)

compile:
	make -C bootloader
	@printf "\n"
	make -C kernel
	@printf "\n"

run: build
	qemu-system-x86_64 -drive file=$(IMG),format=raw,index=0,media=disk

install: build
	@printf "\n===========================\n"
	sudo $(U_DIR)/installer $(IMG) $(OF)

clean:
	make -C bootloader clean
	make -C kernel clean
	rm -f $(IMG)
