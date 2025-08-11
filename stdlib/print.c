#include "my_stdio.h"

#include <stdint.h>
#include <vga_color.h>

void printstr(uint16_t *vga, const char *const str, const uint32_t size, const uint8_t color) {
    for (uint8_t i = 0; i < size; ++i) {
        *(vga++) = str[i] | (color << 8);
    }
}

uint8_t itoc(uint8_t i, uint8_t base) {
    char    c;
    uint8_t rem = i % base;
    if (rem >= 10) {
        c = 'A';
        rem -= 10;
    } else {
        c = '0';
    }
    return c + rem;
}

uint32_t printnum(uint16_t *vga, uint32_t number, uint32_t base, const uint8_t color) {
    uint16_t size = 0;
    for (uint32_t n = number; n >= base; n /= base) ++size;

    vga += size;
    for (; number >= base; number /= base) {
        *(vga--) = itoc(number, base) | (color << 8);
    }
    *vga = itoc(number, base) | (color << 8);

    return size;
}

