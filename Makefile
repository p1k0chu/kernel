ARCH := x86_64
TARGET := $(ARCH)-none-elf

ASMC := nasm
CC := clang
LD := ld.lld
OBJCOPY := objcopy
QEMUC := qemu-system-$(ARCH)

CFLAGS := -Wall -Wextra -Werror -ffreestanding -m32 \
	  -I. -target $(TARGET) -O2

LDFLAGS := -nostdlib
QEMUFLAGS := -no-reboot

BUILD_DIR := build

KERNEL_C_SOURCES := kernel.c print.c
KERNEL_ASM_SOURCES := kernel.asm print.asm
BIN_ASM_SOURCES := first_boot.asm second_boot.asm

KERNEL_C_OBJS := $(patsubst %,$(BUILD_DIR)/%.o,$(KERNEL_C_SOURCES))
KERNEL_ASM_OBJS := $(patsubst %,$(BUILD_DIR)/%.o,$(KERNEL_ASM_SOURCES))
KERNEL_OBJS := $(KERNEL_C_OBJS) $(KERNEL_ASM_OBJS)
ELF_ASM_OBJS := $(KERNEL_ASM_OBJS)
BIN_ASM_OBJS := $(patsubst %.asm,$(BUILD_DIR)/%.bin,$(BIN_ASM_SOURCES))

$(BUILD_DIR)/boot.bin: $(BUILD_DIR)/first_boot.bin $(BUILD_DIR)/second_boot.bin $(BUILD_DIR)/kernel.bin
	$(foreach file,$^, dd if=$(file) of=$@ bs=512 oflag=append conv=sync,notrunc 2> /dev/null;)

	truncate -c -s 7680 $@

$(BUILD_DIR)/kernel.bin: $(BUILD_DIR)/kernel.elf
	$(OBJCOPY) -O binary $< $@

$(BUILD_DIR)/kernel.elf: kernel.ld $(KERNEL_OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

$(BUILD_DIR)/%.c.o: %.c | $(BUILD_DIR)/
	$(CC) $(CFLAGS) -c -o $@ $<

$(ELF_ASM_OBJS): $(BUILD_DIR)/%.asm.o: %.asm | $(BUILD_DIR)/
	$(ASMC) -f elf32 -o $@ $<

$(BIN_ASM_OBJS): $(BUILD_DIR)/%.bin: %.asm | $(BUILD_DIR)/
	$(ASMC) -f bin -o $@ $<

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

