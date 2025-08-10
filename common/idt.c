#include "idt.h"

void idt_set_descriptor(idt_t *dst, void *isr, uint8_t flags) {
    dst->isr_low         = (uint32_t)isr & 0xFFFF;
    dst->selector        = 0x08;
    dst->type_attributes = flags;
    dst->isr_high        = ((uint32_t)isr >> 16) & 0xFFFF;
    dst->reserved        = 0;
}

