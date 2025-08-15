#pragma once

#include <stdint.h>

typedef struct gdtr_t {
    uint16_t limit;
    uint64_t base;
} __attribute__((packed)) gdtr_t;

void *get_stack_top();

// talk to hardware, send data
void outb(short port, char data);

// talk to hardware, recv data
char inb(short port);

