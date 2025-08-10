#pragma once

#include "idt.h"

extern idt_t  idt[];
extern idtr_t idtr;
extern void  *isr_stub_table[];

void setup_idt();
void exc_handler(int code);

