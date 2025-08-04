
ASMC := nasm
ASMFLAGS := -f bin
QEMUC := qemu-system-x86_64

build/%.bin: %.asm | build/
	$(ASMC) $(ASMFLAGS) $< -o $@

run: build/boot.bin
	$(QEMUC) -drive format=raw,file=$<

build/:
	mkdir -p build

clean:
	rm -vrf build

.PHONY: run clean

