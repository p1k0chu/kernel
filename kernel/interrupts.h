#pragma once

#include "idt.h"

struct interrupt_frame {
    uint32_t eip;
    uint32_t cs;
    uint32_t eflags;
};

struct pushad_frame {
    uint32_t edi;
    uint32_t esi;
    uint32_t ebp;
    uint32_t esp;
    uint32_t ebx;
    uint32_t edx;
    uint32_t ecx;
    uint32_t eax;
};

extern idt_t  idt[];
extern idtr_t idtr;
extern void  *isr_stub_table[];

void setup_idt();

// vector is the exception index
// code is optional error code (some of them have it)
void exc_handler(int vector, struct pushad_frame registers, struct interrupt_frame interrupts);

