#include "isr.h"

#include "vga_color.h"

#include <my_stdlib.h>
#include <stdint.h>

void exc_handler(int code) {
    const char msg[] = "Cpu fault: ";
    short     *vga   = (void *)0xB8000;

    memsetw(vga, ' ' | (BLUE_BG << 8), 80 * 25);

    for (uint8_t i = 0; i < sizeof(msg) - 1; ++i) {
        *(vga++) = msg[i] | ((WHITE | BLUE_BG) << 8);
    }

    memsetw(vga, ' ' | (BLUE_BG << 8), 2);
    vga += 2;
    while (code >= 10) {
        *(vga--) = ('0' + code % 10) | ((WHITE | BLUE_BG) << 8);
        code /= 10;
    }
    *vga = ('0' + code) | ((WHITE | BLUE_BG) << 8);

    asm volatile("cli");
    for (;;) {
        asm volatile("hlt");
    }
}

