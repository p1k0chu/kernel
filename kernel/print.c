#include "print.h"

#include "kernel.h"
#include "vga_color.h"

#include <stdint.h>
#include <string.h>

volatile short *const vga_mem = (void *)0xB8000;
uint8_t               vga_width;

int cursor_x = 0;
int cursor_y = 0;

void print_init() {
    // read vga size
    outb(0x3D4, 0x1);
    vga_width = inb(0x3D5) + 1;
}

void putc(char c, char attr) {
    vga_mem[cursor_y * vga_width + cursor_x++] = c | (attr << 8);
    if (cursor_x >= vga_width) {
        cursor_y += cursor_x / vga_width;
        cursor_x = cursor_x % vga_width;
    }
}

void putc_white(char c) {
    putc(c, WHITE);
}

inline void println(const char *str, char attr) {
    print(str, attr);
    cursor_x = 0;
    ++cursor_y;
}

// prints the string with the attr applied to every char
void print(const char *str, char attr) {
    char c;
    while ((c = *(str++)) != 0) {
        if (c == '\n') {
            ++cursor_y;
            cursor_x = 0;
            continue;
        }
        putc(c, attr);
    }
}

void clear_vga() {
    memset((void *)vga_mem, 0, vga_width * 25 * 2);
    cursor_x = 0;
    cursor_y = 0;
}
