
ASMC := nasm
QEMUC := qemu-system-x86_64
QEMUFLAGS := -no-reboot

ARCH := i686-elf
CC := $(ARCH)-gcc
CFLAGS := -O2 -Wall -Wextra -Werror -ffreestanding -m32 -nostdlib -I.

LD := $(ARCH)-ld
LDFLAGS := -nostdlib

OBJCOPY := $(ARCH)-objcopy

BUILD_DIR := build

KERNEL_C_SOURCES := kernel.c print.c
KERNEL_C_OBJS := $(patsubst %.c,$(BUILD_DIR)/%.c.o,$(KERNEL_C_SOURCES))

KERNEL_ASM_SOURCES := kernel.asm print.asm
KERNEL_ASM_OBJS := $(patsubst %.asm,$(BUILD_DIR)/%.asm.o,$(KERNEL_ASM_SOURCES))

KERNEL_OBJS := $(KERNEL_C_OBJS) $(KERNEL_ASM_OBJS)

ELF_ASM_OBJS := $(KERNEL_ASM_OBJS)

BIN_ASM_SOURCES := first_boot.asm second_boot.asm
BIN_ASM_OBJS := $(patsubst %.asm,$(BUILD_DIR)/%.bin,$(BIN_ASM_SOURCES))

$(BUILD_DIR)/boot.bin: $(BUILD_DIR)/first_boot.bin $(BUILD_DIR)/second_boot.bin $(BUILD_DIR)/kernel.bin
	dd if=$(BUILD_DIR)/first_boot.bin of=$@  bs=512 conv=sync,notrunc 2> /dev/null
	dd if=$(BUILD_DIR)/second_boot.bin of=$@ bs=512 seek=1 conv=sync,notrunc 2> /dev/null
	dd if=$(BUILD_DIR)/kernel.bin of=$@ bs=512 seek=2 conv=sync,notrunc 2> /dev/null

	truncate -c -s 7680 $@

$(BUILD_DIR)/kernel.bin: $(BUILD_DIR)/kernel.elf
	$(OBJCOPY) -O binary $< $@

$(BUILD_DIR)/kernel.elf: $(KERNEL_OBJS)
	$(LD) $(LDFLAGS) -T kernel.ld -o $@ $^

$(BUILD_DIR)/%.c.o: %.c | $(BUILD_DIR)/
	$(CC) $(CFLAGS) -c -o $@ $<

$(ELF_ASM_OBJS): $(BUILD_DIR)/%.asm.o: %.asm | $(BUILD_DIR)/
	$(ASMC) -f elf32 $< -o $@

$(BIN_ASM_OBJS): $(BUILD_DIR)/%.bin: %.asm | $(BUILD_DIR)/
	$(ASMC) -f bin $< -o $@

run: $(BUILD_DIR)/boot.bin
	$(QEMUC) $(QEMUFLAGS) -drive format=raw,file=$<,if=ide

$(BUILD_DIR)/:
	@mkdir -p $(BUILD_DIR)

clean:
	@read -p "Run rm -vrf $(BUILD_DIR) ? [y/N] " ans; \
	if [ "$$ans" = "y" ]; then \
		rm -vrf $(BUILD_DIR); \
	fi

.PHONY: run clean

