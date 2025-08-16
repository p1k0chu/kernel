#include "kernel.h"

#include "kernelkt_api.h"

#include <my_stdio.h>
#include <stdint.h>
#include <string.h>
#include <vga_color.h>

void kernel_main() {
    kernelkt_ExportedSymbols *kernelkt = kernelkt_symbols();

    uint16_t *vga = (void *)0xB8000;
    memset(vga, 0, 80 * 25);

    for (uint8_t attr = 0; attr <= 15; ++attr) {
        *(vga++) = attr << 12;
    }
    vga = (uint16_t *)0xB8000;
    printnum(vga, kernelkt->kotlin.root.helloFromKotlin(), 10, WHITE);
}

