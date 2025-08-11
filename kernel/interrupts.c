#include "interrupts.h"

#include <my_stdio.h>
#include <my_stdlib.h>
#include <stdint.h>
#include <vga_color.h>

#define BSOD_COLOR (WHITE | BLUE_BG)

#define PRINT_PAIR(vga, msg, value, base, color)              \
    {                                                         \
        const uint32_t size = sizeof(msg) - 1;                \
        printstr((vga), (msg), size, (color));                \
        printnum((vga) + size + 1, (value), (base), (color)); \
    }

void setup_idt() {
    idtr.base  = (uint32_t)idt;
    idtr.limit = sizeof(idt_t) * 32 - 1;

    for (uint8_t i = 0; i < 32; ++i) {
        idt_set_descriptor(idt + i, isr_stub_table[i], 0x8E);
    }
    load_idtr(&idtr);
}

void exc_handler(int                    vector,
                 struct interrupt_frame interrupts,
                 uint32_t               code,
                 struct pushad_frame    registers) {
    const char msg[]            = "Cpu fault:";
    const char msg2[]           = "Code, if any:";
    const char msg3[]           = "Instruction address:";
    const char msg4[]           = "CS:";
    const char msg5[]           = "EFLAGS:";
    const char msg_stack_dump[] = "Stack hex dump:";

    uint16_t *vga = (void *)0xB8000;

    memsetw(vga, ' ' | (BLUE_BG << 8), 80 * 25);
    vga += 80 + 1;

    PRINT_PAIR(vga, msg, vector, 10, BSOD_COLOR);
    vga += 80;

    PRINT_PAIR(vga, msg2, code, 10, BSOD_COLOR);
    vga += 80;

    PRINT_PAIR(vga, msg3, interrupts.eip, 16, BSOD_COLOR);
    vga += 80;

    PRINT_PAIR(vga, msg4, interrupts.cs, 16, BSOD_COLOR);
    vga += 80;

    PRINT_PAIR(vga, msg5, interrupts.eflags, 16, BSOD_COLOR);
    vga += 80 * 2;

    printstr(vga + 3, msg_stack_dump, sizeof(msg_stack_dump) - 1, WHITE | BLUE_BG);
    vga += 80;

    uint32_t *esp = (void *)registers.esp;
    for (uint32_t i = 0; i < 40; ++i) {
        const uint8_t x = i / 10;
        const uint8_t y = i % 10;
        printnum(vga + y * 80 + x * 10, esp[i], 16, WHITE | BLUE_BG);
    }

    const char msg_registers[] = "Registers:";
    const char reg_names[][3]  = {"EDI", "ESI", "EBP", "ESP", "EBX", "EDX", "ECX", "EAX"};

    vga = (uint16_t *)0xB8000 + 44 + 80;
    printstr(vga, msg_registers, sizeof(msg_registers) - 1, WHITE | BLUE_BG);
    vga += 80 * 2 - 4;

    uint32_t      *reg_array = (uint32_t *)&registers;
    const uint32_t size      = sizeof(struct pushad_frame) / sizeof(uint32_t);

    for (uint32_t i = 0; i < size; ++i) {
        const uint32_t size = sizeof(reg_names[i]);

        printstr(vga, reg_names[i], size, BSOD_COLOR);
        printnum(vga + size + 1, reg_array[i], 16, BSOD_COLOR);

        vga += 80;
    }

    asm volatile("cli");
    for (;;) {
        asm volatile("hlt");
    }
}

