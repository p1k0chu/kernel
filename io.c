#include "io.h"

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

void clear_vga() {
    for (int i = 0; i < vga_width * 25; ++i) {
        vga_mem[i] = 0;
    }
}

