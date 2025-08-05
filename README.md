# kernel

this is my kernel written from nothing for learning purposes.  
its x86 assembly.

it contains first and second stage bootloader,  
second entering protected mode and linking together with 32 bit C code

# Build

Requires you to compile GCC manually for `i686-elf` target  
you can find a guide for compilation [here](https://wiki.osdev.org/GCC_Cross-Compiler)

make sure the compiler is in your path.

and you can just run `make` to get a boot.bin raw binary!

if you have `qemu-system` installed, you can run it with `make run`

works on my machine btw.

## License

This project is licensed under MIT license  
Copyright (c) 2025 p1k0chu
