#pragma once

#include <stdint.h>

typedef struct idt32_t {
    uint16_t isr_low;
    uint16_t selector;
    uint8_t  reserved;        // unused, set to 0
    uint8_t  type_attributes; // gate type, dpl, and p fields
    uint16_t isr_high;
} __attribute__((packed)) idt32_t;

typedef struct {
    uint16_t limit;
    uint32_t base;
} __attribute__((packed)) idtr_t;

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

#ifdef LONG_MODE
#error ("not yet implemented")
#else
typedef idt32_t idt_t;
#endif

extern idt_t  idt[];
extern idtr_t idtr;
extern void  *isr_stub_table[];

void load_idtr(void *);
void idt_set_descriptor(idt_t *dst, void *isr, uint8_t flags);
void setup_idt();

// vector is the exception index
// code is optional error code (some of them have it)
void exc_handler(int vector, struct pushad_frame registers, struct interrupt_frame interrupts);

