#include "kernel.h"

#include "print.h"
#include "vga_color.h"

#include <stdint.h>

void kernel_main() {
    print_init();

    clear_vga();

    for (uint8_t attr = 0; attr <= 15; ++attr) {
        putc(' ', attr << 4);
    }
    cursor_x = 0;
    ++cursor_y;
}

