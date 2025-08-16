.SECONDEXPANSION:

#################
### VARIABLES ###
#################

ARCH := x86_64
TARGET := $(ARCH)-none-elf

O := build

ASMC := nasm
CC := clang
LD := ld.lld
OBJCOPY := objcopy
AR := llvm-ar

QEMUC := qemu-system-$(ARCH)
RM := rm -vrf

CFLAGS := -Wall -Wextra -Werror -ffreestanding \
   -Iinclude -target $(TARGET) -std=gnu23

LDFLAGS := -nostdlib
QEMUFLAGS := -no-reboot

ifeq ($(SHOW_DD), 1)
SILENCE_DD :=
else
SILENCE_DD := 2> /dev/null
endif


###################
### COMPILATION ###
###################

$(O)/boot.bin: $(O)/first_boot.bin $(O)/second_boot.bin $(O)/kernel.bin
	@$(RM) $@
	$(foreach file,$^, dd if=$(file) of=$@ bs=512 oflag=append conv=sync,notrunc $(SILENCE_DD);)

	truncate -c -s 11776 $@

$(O)/first_boot.bin: first_boot.s | $(O)/
	$(ASMC) -f bin -o $@ $<


##############
### STDLIB ###
##############

STDLIB_SRC := stdlib/print.c stdlib/memory.s
STDLIB_OBJS := $(patsubst %,$(O)/%.o,$(STDLIB_SRC))

$(O)/libstdlib.a: $(STDLIB_OBJS)
	$(AR) rcs $@ $^

##############
### KERNEL ###
##############

KERNEL_SRC := kernel/interrupts.c kernel/interrupts.s kernel/kernel.c kernel/kernel.s
KERNEL_OBJS := $(patsubst %,$(O)/%.o,$(KERNEL_SRC))

$(O)/kernel.bin: $(O)/kernel.elf
	$(OBJCOPY) -O binary $< $@

$(O)/kernel.elf: kernel/kernel.ld $(KERNEL_OBJS) $(O)/libstdlib.a
	$(LD) $(LDFLAGS) -o $@ $^


###############################
### SECOND STAGE BOOTLOADER ###
###############################

SECOND_BOOT_SRC := $(wildcard second_boot/*.c) $(wildcard second_boot/*.s)
SECOND_BOOT_OBJS := $(patsubst %,$(O)/%.o32,$(SECOND_BOOT_SRC))

$(O)/second_boot.bin: $(O)/second_boot.elf
	$(OBJCOPY) -O binary $< $@

$(O)/second_boot.elf: second_boot/second_boot.ld $(SECOND_BOOT_OBJS)
	$(LD) $(LDFLAGS) -o $@ $^


#############
### PHONY ###
#############

run: $(O)/boot.bin
	$(QEMUC) $(QEMUFLAGS) -drive format=raw,file=$<,if=ide

clean:
	$(RM) $(O)

.PHONY: clean run


######################
### IMPLICIT RULES ###
######################

# rule for making a directory
%/:
	mkdir -p $@

# default way to build a c file
$(O)/%.c.o: %.c | $$(dir $$@)
	$(CC) $(CFLAGS) -c -o $@ $<

$(O)/%.s.o: %.s | $$(dir $$@)
	$(ASMC) -f elf64 -o $@ $<

# 32 bit version for c and asm files
$(O)/%.c.o32: %.c | $$(dir $$@)
	$(CC) $(CFLAGS) -m32 -c -o $@ $<

$(O)/%.s.o32: %.s | $$(dir $$@)
	$(ASMC) -f elf32 -o $@ $<


