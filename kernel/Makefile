O := build

include ../scripts/util.mk

KERNEL_C_SOURCES := $(wildcard *.c)
KERNEL_ASM_SOURCES := $(wildcard *.s)

KERNEL_C_OBJS := $(patsubst %,$(O)/%.o,$(KERNEL_C_SOURCES))
KERNEL_ASM_OBJS := $(patsubst %,$(O)/%.o,$(KERNEL_ASM_SOURCES))

$(O)/kernel.bin: $(O)/kernel.elf
	$(OBJCOPY) -O binary $< $@

$(O)/kernel.elf: kernel.ld $(KERNEL_C_OBJS) $(KERNEL_ASM_OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

$(KERNEL_ASM_OBJS): $(O)/%.s.o: %.s | $(O)/
	$(ASMC) -f elf32 -o $@ $<

include ../scripts/implicit_rules.mk ../scripts/clean.mk

