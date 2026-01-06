#pragma once

#include <stdint.h>

void printstr(uint16_t *vga, const char *str, uint32_t size, uint8_t color);

// convert integer to character
uint8_t itoc(uint8_t i, uint8_t base);

// prints the number at vga
// returns the size of the string printed
uint32_t printnum(uint16_t *vga, uint32_t number, uint32_t base, uint8_t color);

