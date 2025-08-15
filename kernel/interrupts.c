#include "interrupts.h"

#include "kernel.h"

#include <my_stdio.h>
#include <my_stdlib.h>
#include <stddef.h>
#include <stdint.h>
#include <vga_color.h>

#define BSOD_COLOR         (WHITE | BLUE_BG)
#define STACK_DUMP_ROWS    16
#define STACK_DUMP_COLUMNS 4

#define PRINT_PAIR(vga, msg, value, base, color)              \
    {                                                         \
        const uint32_t size = sizeof(msg) - 1;                \
        printstr((vga), (msg), size, (color));                \
        printnum((vga) + size + 1, (value), (base), (color)); \
    }

void setup_idt() {
    idtr.base  = (uint64_t)idt;
    idtr.limit = sizeof(idt_t) * 32 - 1;

    for (uint8_t i = 0; i < 32; ++i) {
        idt_set_descriptor(idt + i, isr_stub_table[i], 0x8E);
    }
    load_idtr(&idtr);
}

void idt_set_descriptor(idt_t *dst, void *isr, uint8_t flags) {
    dst->isr_low         = (uint64_t)isr & 0xFFFF;
    dst->selector        = 0x08;
    dst->ist             = 0;
    dst->type_attributes = flags;
    dst->isr_mid         = ((uint64_t)isr >> 16) & 0xFFFF;
    dst->isr_high        = ((uint64_t)isr >> 32) & 0xFFFFFFFF;
    dst->reserved        = 0;
}

void exc_handler(int vector, struct pushad_frame *registers, struct interrupt_frame *interrupts) {
    const char msg[]            = "Cpu fault:";
    const char msg3[]           = "Instruction address:";
    const char msg4[]           = "CS:";
    const char msg5[]           = "EFLAGS:";
    const char msg_stack_dump[] = "Stack hex dump:";

    uint16_t *vga = (void *)0xB8000;

    memsetw(vga, ' ' | (BLUE_BG << 8), 80 * 25);
    vga += 80 + 1;

    PRINT_PAIR(vga, msg, vector, 10, BSOD_COLOR);
    vga += 80;

    PRINT_PAIR(vga, msg3, interrupts->rip, 16, BSOD_COLOR);
    vga += 80;

    PRINT_PAIR(vga, msg4, interrupts->cs, 16, BSOD_COLOR);
    vga += 80;

    PRINT_PAIR(vga, msg5, interrupts->eflags, 16, BSOD_COLOR);
    vga += 80 * 2;

    printstr(vga + 3, msg_stack_dump, sizeof(msg_stack_dump) - 1, WHITE | BLUE_BG);
    vga += 80;

    uint64_t *rsp        = (void *)interrupts->rsp;
    uint64_t  stack_top  = (uint64_t)get_stack_top();
    uint32_t  stack_size = (stack_top - (uint64_t)rsp) / sizeof(size_t);

    if (stack_size > STACK_DUMP_ROWS * STACK_DUMP_COLUMNS) {
        stack_size = STACK_DUMP_ROWS * STACK_DUMP_COLUMNS;
    }

    for (uint32_t i = 0; i < stack_size; ++i) {
        const uint8_t x      = i / STACK_DUMP_ROWS;
        const uint8_t y      = i % STACK_DUMP_ROWS;
        uint16_t     *my_vga = vga + y * 80 + x * 10;
        my_vga += printnum(my_vga, (rsp[i] >> 32) & 0xFFFFFFFF, 16, WHITE | BLUE_BG);
        printnum(my_vga, rsp[i] & 0xFFFFFFFF, 16, WHITE | BLUE_BG);
    }

    const char msg_registers[] = "Registers:";
    const char reg_names[][3]  = {"r15",
                                  "r14",
                                  "r13",
                                  "r12",
                                  "r11",
                                  "r10",
                                  "r9 ",
                                  "r8 ",
                                  "rdi",
                                  "rsi",
                                  "rbp",
                                  "rbx",
                                  "rdx",
                                  "rcx",
                                  "rax"};

    vga = (uint16_t *)0xB8000 + 44 + 80;
    printstr(vga, msg_registers, sizeof(msg_registers) - 1, WHITE | BLUE_BG);
    vga += 80 * 2 - 4;

    uint64_t      *reg_array = (uint64_t *)registers;
    const uint32_t size      = sizeof(struct pushad_frame) / sizeof(uint64_t);

    for (uint32_t i = 0; i < size; ++i) {
        printstr(vga, reg_names[i], 3, BSOD_COLOR);
        printnum(vga + 4, reg_array[i], 16, BSOD_COLOR);

        vga += 80;
    }

    asm volatile("cli");
    for (;;) {
        asm volatile("hlt");
    }
}

