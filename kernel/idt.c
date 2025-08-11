#include "idt.h"

#include "isr.h"

idt_t  *idt  = (void *)0x180000;
idtr_t *idtr = (void *)0x170000;

void setup_idt() {
    idtr->base  = (uint32_t)idt;
    idtr->limit = sizeof(idt_t) * 32 - 1;

    for (uint8_t i = 0; i < 32; ++i) {
        idt_set_descriptor(idt + i, isr_stub_table[i], 0x8E);
    }
    load_idtr(idtr);
}

