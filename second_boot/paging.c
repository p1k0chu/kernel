#include "paging.h"

#include <stdint.h>

#define PT_PRESENT 1
#define PT_WRITE   2

#define TABLE_ENTRIES 512
#define TABLE_SIZE    0x1000

#define FOREACH_TABLE(i) for ((i) = 0; i < TABLE_ENTRIES; ++i)
#define FILL_EMPTY_TABLE(i, ptr) \
    FOREACH_TABLE(i) {           \
        ptr[i] = PT_WRITE;       \
    }

#define TO_MB(x) (0x100000 * x)


void setup_paging() {
    uint16_t i;

    FILL_EMPTY_TABLE(i, pml4t);
    FILL_EMPTY_TABLE(i, pdpt);
    FILL_EMPTY_TABLE(i, pdt);

    pml4t[0] = (uint32_t)pdpt | PT_PRESENT | PT_WRITE;
    pdpt[0] = (uint32_t)pdt | PT_PRESENT | PT_WRITE;

    // identity map first 4 MB
    uint64_t *pt = pts[0];
    FOREACH_TABLE(i) {
        pt[i] = (i * 0x1000) | PT_PRESENT | PT_WRITE;
    }
    pdt[0] = ((uint32_t)pt) | PT_PRESENT | PT_WRITE;

    pt = pts[1];
    FOREACH_TABLE(i) {
        pt[i] = (TABLE_ENTRIES + i) * 0x1000 | PT_PRESENT | PT_WRITE;
    }
    pdt[1] = ((uint32_t)pt) | PT_PRESENT | PT_WRITE;

    load_page_directory(pml4t);
}

