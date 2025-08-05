#include "io.h"
#include "kernel_asm.h"

void kernel_main() {
    // read vga width
    outb(0x3D4, 0x1);
    vga_width = inb(0x3D5) + 1;

    clear_vga();

    print(0,
          0,
          "RAHHHHHH\n"
          "WHAT THE FUCK IS AN\n"
          "OS?????\n",
          WHITE_FG);
}

