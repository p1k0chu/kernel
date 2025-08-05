#include "kernel_asm.h"

#define WHITE_FG 0b00001111

volatile short *const vga_mem = (void *)0xB8000;
char                  vga_width;

// prints str at position [x, y], with attribute attr for every char
void print(int x, int y, const char *str, char attr) {
    char c;
    while ((c = *(str++)) != 0) {
        if (c == '\n') {
            ++y;
            x = 0;
            continue;
        }
        int i      = y * vga_width + x;
        vga_mem[i] = c | (attr << 8);
        ++x;
    }
}

void clear() {
    for (int i = 0; i < vga_width * 25; ++i) {
        vga_mem[i] = 0;
    }
}

void kernel_main() {
    // read vga width
    outb(0x3D4, 0x1);
    vga_width = inb(0x3D5) + 1;

    clear();

    print(0, 0, "RAHHHHHH\n"
                "WHAT THE FUCK IS AN\n"
                "OS?????\n", WHITE_FG);
}

