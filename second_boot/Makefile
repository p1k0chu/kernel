SOURCES := $(wildcard *.c) $(wildcard *.s)
OBJS := $(patsubst %,$(O)/%.o,$(SOURCES))

$(O)/second_boot.bin: $(O)/second_boot.elf
	$(OBJCOPY) -O binary $< $@

$(O)/second_boot.elf: $(OBJS) second_boot.ld
	$(LD) $(LDFLAGS) -o $@ $^

$(O)/%.s.o: %.s | $(O)/
	$(ASMC) -f elf32 -o $@ $<

include ../scripts/implicit_rules.mk ../scripts/clean.mk
