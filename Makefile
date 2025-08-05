
ASMC := nasm
ASMFLAGS := -f bin
QEMUC := qemu-system-x86_64

ARCH := i686-elf
CC := $(ARCH)-gcc
CFLAGS := -ffreestanding -m32 -nostdlib

LD := $(ARCH)-ld
LDFLAGS := -nostdlib

OBJCOPY := $(ARCH)-objcopy

build/boot.bin: build/first_boot.bin build/kernel.bin
	dd if=build/first_boot.bin of=$@  bs=512 conv=sync,notrunc
	dd if=build/kernel.bin of=$@ bs=512 seek=1 conv=sync,notrunc

build/kernel.bin: build/kernel.elf
	$(OBJCOPY) -O binary $< $@

build/kernel.elf: build/kernel.c.o build/kernel.asm.o
	$(LD) $(LDFLAGS) -T kernel.ld -o $@ $^

build/kernel.c.o: kernel.c | build/
	$(CC) $(CFLAGS) -c -o $@ $<

build/kernel.asm.o: kernel.asm | build/
	$(ASMC) -f elf32 $< -o $@

build/first_boot.bin: first_boot.asm | build/
	$(ASMC) $(ASMFLAGS) $< -o $@

run: build/boot.bin
	$(QEMUC) -drive format=raw,file=$<

build/:
	mkdir -p build

clean:
	rm -vrf build

.PHONY: run clean

