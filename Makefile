export O := build

SUBDIRS := kernel second_boot
SUBDIRS_TARGETS := $(patsubst %,%-submake,$(SUBDIRS))

export ARCH := x86_64
export TARGET := $(ARCH)-none-elf

export ASMC := nasm
export CC := clang
export LD := ld.lld
export OBJCOPY := objcopy
export QEMUC := qemu-system-$(ARCH)
export RM := rm -vrf

export CFLAGS := -Wall -Wextra -Werror -ffreestanding -m32 \
	  -I. -target $(TARGET) -O2

export LDFLAGS := -nostdlib
QEMUFLAGS := -no-reboot

ifeq ($(SHOW_DD), 1)
SILENCE_DD :=
else
SILENCE_DD := 2> /dev/null
endif

$(O)/boot.bin: $(O)/first_boot.bin second_boot/$(O)/second_boot.bin kernel/$(O)/kernel.bin
	$(foreach file,$^, dd if=$(file) of=$@ bs=512 oflag=append conv=sync,notrunc $(SILENCE_DD);)

	truncate -c -s 7680 $@

kernel/$(O)/kernel.bin: kernel-submake
second_boot/$(O)/second_boot.bin: second_boot-submake

$(SUBDIRS_TARGETS): %-submake: %
	$(MAKE) -C $<

$(O)/first_boot.bin: first_boot.s | $(O)/
	$(ASMC) -f bin -o $@ $<

run: $(O)/boot.bin
	$(QEMUC) $(QEMUFLAGS) -drive format=raw,file=$<,if=ide

.PHONY: run $(SUBDIRS_TARGETS)

include scripts/implicit_rules.mk scripts/clean.mk

