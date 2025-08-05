
ASMC := nasm
ASMFLAGS := -f bin
QEMUC := qemu-system-x86_64

build/boot.bin: build/first_boot.bin build/second_boot.bin
	dd if=build/first_boot.bin of=$@  bs=512 conv=sync,notrunc
	dd if=build/second_boot.bin of=$@ bs=512 seek=1 conv=sync,notrunc

build/%.bin: %.asm | build/
	$(ASMC) $(ASMFLAGS) $< -o $@

run: build/boot.bin
	$(QEMUC) -drive format=raw,file=$<

build/:
	mkdir -p build

clean:
	rm -vrf build

.PHONY: run clean

