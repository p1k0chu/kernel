
boot.bin: boot.asm
	nasm -f bin boot.asm -o boot.bin

run: boot.bin
	qemu-system-x86_64 -drive format=raw,file=boot.bin


