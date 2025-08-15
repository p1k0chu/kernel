bits 32

section .text
    global load_page_directory
    global enable_paging

; one argument: the address of page dir (int)
load_page_directory:
    mov eax, [esp+4]
    mov cr3, eax

    ret

section .bss
    global pml4t ; Page Map Level 4 Table
    global pdpt  ; Page Directory Pointer Table
    global pdt   ; Page Directory Table
    global pts   ; Page Tables

    align 4096

    pml4t:
    resb 4096

    pdpt:
    resb 4096

    pdt:
    resb 4096

    pts:
    resb 4096 * 2 ; two page tables

