#pragma once

#include <stdint.h>

extern uint64_t pml4t[512];
extern uint64_t pdpt[512];
extern uint64_t pdt[512];
extern uint64_t pts[2][512];

void setup_paging();
void load_page_directory(void *);
void enable_paging();
void enable_pae();

