#pragma once

#include <stdint.h>

typedef struct idt64_t {
    uint16_t isr_low;         // offset bits 0..15
    uint16_t selector;        // a code segment selector in GDT or LDT
    uint8_t  ist;             // bits 0..2 holds Interrupt Stack Table offset, rest of bits zero.
    uint8_t  type_attributes; // gate type, dpl, and p fields
    uint16_t isr_mid;         // offset bits 16..31
    uint32_t isr_high;        // offset bits 32..63
    uint32_t reserved;        // reserved
} __attribute__((packed)) idt64_t;

typedef struct {
    uint16_t limit;
    uint64_t base;
} __attribute__((packed)) idtr_t;

struct interrupt_frame {
    uint64_t rip;
    uint64_t cs;
    uint64_t eflags;
    uint64_t rsp;
} __attribute__((packed));

struct pushad_frame {
    uint64_t r15;
    uint64_t r14;
    uint64_t r13;
    uint64_t r12;
    uint64_t r11;
    uint64_t r10;
    uint64_t r9;
    uint64_t r8;
    uint64_t rdi;
    uint64_t rsi;
    uint64_t rbp;
    uint64_t rbx;
    uint64_t rdx;
    uint64_t rcx;
    uint64_t rax;
} __attribute__((packed));

typedef idt64_t idt_t;

extern idt_t  idt[32];
extern idtr_t idtr;
extern void  *isr_stub_table[32];

void load_idtr(void *);
void idt_set_descriptor(idt_t *dst, void *isr, uint8_t flags);
void setup_idt();

// vector is the exception index
// code is optional error code (some of them have it)
void exc_handler(int vector, struct pushad_frame *registers, struct interrupt_frame *interrupts);

