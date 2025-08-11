#include "kernel.h"

#include "kernel_idt.h"

#include <stdint.h>
#include <string.h>

void kernel_main() {
    setup_idt();

    uint16_t *vga = (void*)0xB8000;
    memset(vga, 0, 80 * 25);

    for (uint8_t attr = 0; attr <= 15; ++attr) {
        *(vga++) = attr << 8;
    }
}

