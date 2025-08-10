#pragma once

#include <stdint.h>

typedef struct idt32_t {
    uint16_t isr_low;
    uint16_t selector;
    uint8_t  reserved;        // unused, set to 0
    uint8_t  type_attributes; // gate type, dpl, and p fields
    uint16_t isr_high;
} __attribute__((packed)) idt32_t;

#ifdef LONG_MODE
#error ("not yet implemented")
#else
typedef idt32_t idt_t;
#endif

typedef struct {
    uint16_t limit;
    uint32_t base;
} __attribute__((packed)) idtr_t;

void load_idtr(void *);
void idt_set_descriptor(idt_t *dst, void *isr, uint8_t flags);

