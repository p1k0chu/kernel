# kernel

this is my kernel written from nothing for learning purposes.  
its x86 assembly.

it contains first and second stage bootloader and a kernel,  
second entering protected mode and loading the kernel at 1 MB in ram ("high memory")  
the kernel is a combination of NASM and C (both 32 bit)

# Build

Install `clang` compiler and `lld` (llvm linker)

and you can just run `make` to get a boot.bin raw binary!

if you have `qemu-system` installed, you can run it with `make run`

works on my machine btw.

## License

This project is licensed under MIT license  
Copyright (c) 2025 p1k0chu
