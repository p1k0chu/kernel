#include "isr.h"

#include "vga_color.h"

#include <my_stdlib.h>
#include <stdint.h>

static void printstr(short **const vga, const char *str, uint32_t size) {
    for (uint8_t i = 0; i < size; ++i) {
        *((*vga)++) = str[i] | ((WHITE | BLUE_BG) << 8);
    }
}

static uint8_t itoc(uint8_t i, uint8_t base) {
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

static void printnum(short *vga, uint32_t number, uint8_t base) {
    uint16_t i = 0;
    for (uint32_t n = number; n >= base; n /= base) ++i;

    for (; number >= base; number /= base) {
        vga[i--] = itoc(number, base) | ((WHITE | BLUE_BG) << 8);
    }
    vga[i] = itoc(number, base) | ((WHITE | BLUE_BG) << 8);
}

void exc_handler(int                    vector,
                 struct interrupt_frame interrupts,
                 uint32_t               code,
                 struct pushad_frame    registers) {
    const char msg[]            = "Cpu fault: ";
    const char msg2[]           = "Code, if any: ";
    const char msg3[]           = "Instruction address: ";
    const char msg4[]           = "CS: ";
    const char msg5[]           = "EFLAGS: ";
    const char msg_stack_dump[] = "Stack hex dump:";

    short *vga = (void *)0xB8000;

    memsetw(vga, ' ' | (BLUE_BG << 8), 80 * 25);
    vga += 81;

    printstr(&vga, msg, sizeof(msg) - 1);
    printnum(vga, vector, 10);

    vga = (short *)0xB8002 + 80 * 2;
    printstr(&vga, msg2, sizeof(msg2) - 1);
    printnum(vga, code, 10);

    vga = (short *)0xB8002 + 80 * 3;
    printstr(&vga, msg3, sizeof(msg3) - 1);
    printnum(vga, interrupts.eip, 16);

    vga = (short *)0xB8002 + 80 * 4;
    printstr(&vga, msg4, sizeof(msg4) - 1);
    printnum(vga, interrupts.cs, 16);

    vga = (short *)0xB8002 + 80 * 5;
    printstr(&vga, msg5, sizeof(msg5) - 1);
    printnum(vga, interrupts.eflags, 16);

    vga = (short *)0xB8002 + 80 * 7;
    printstr(&vga, msg_stack_dump, sizeof(msg_stack_dump) - 1);

    vga           = (short *)0xB8000 + 80 * 8 + 3;
    uint32_t *esp = (void *)registers.esp;
    for (uint32_t i = 0; i < 40; ++i) {
        const uint8_t x = i / 10;
        const uint8_t y = i % 10;
        printnum(vga + y * 80 + x * 10, esp[i], 16);
    }

    asm volatile("cli");
    for (;;) {
        asm volatile("hlt");
    }
}

