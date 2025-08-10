#pragma once

#include <stdint.h>

extern void *isr_stub_table[];

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

// vector is the exception index
// code is optional error code (some of them have it)
void exc_handler(int                    vector,
                 struct interrupt_frame interrupts,
                 uint32_t               code,
                 struct pushad_frame    registers);

