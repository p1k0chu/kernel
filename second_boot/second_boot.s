; second stage boot loader

bits 16

%define DRQ 0x8
%define BSY 0x80
%define KERNEL_SECTORS 20

%macro LOGLETTER 1
mov edi, 0xB8000
mov byte [edi], %1
%endmacro

section .start
    global _start

_start:
    cli
    lgdt [gdtr32]

    ; set the protected mode bit
    mov eax, cr0
    or al, 1
    mov cr0, eax

    jmp 0x08:pmode_start

bits 32

section .text
    extern setup_long_mode
    extern setup_paging

pmode_start:
    ; set all segment registers to 0x10
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; setup stack
    mov esp, stack_top
    mov ebp, esp

    ; read the kernel from the disc

    mov dx, 0x1F6     ; drive/head register
    mov al, 0xE0      ; 0xE0 = master drive + LBA mode enabled
    out dx, al

    ; sector count
    mov dx, 0x1F2
    mov al, KERNEL_SECTORS
    out dx, al

    ; start with 4th sector
    inc dx
    %if KERNEL_SECTORS != 3
    mov al, 3
    %endif
    out dx, al

    inc dx
    xor al, al
    out dx, al

    inc dx
    ; al = 0
    out dx, al

    push BSY
    push -1
    push 0x1F7
    call wait_for_status
    add esp, 12

    mov dx, 0x1F7     ; command port
    mov al, 0x20      ; READ SECTORS command
    out dx, al

    mov ebx, KERNEL_SECTORS
    mov edi, 0x100000 ; 1 MB

.loop_sector:
    ; save my registers
    push ebx
    push edi

    push BSY
    push DRQ
    push 0x1F7
    call wait_for_status
    add esp, 12

    pop edi
    pop ebx

    mov dx, 0x1F0
    mov ecx, 256

.read_loop:
    in ax, dx
    mov [edi], ax
    add edi, 2
    loop .read_loop
    
    sub ebx, 1
    cmp ebx, 0
    jne .loop_sector

    ; reading is done. set up long mode

    call setup_paging

    ; enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    EFER_MSR equ 0xC0000080
    EFER_LM_ENABLE equ 1 << 8

    ; enable long mode in EFER
    mov ecx, EFER_MSR
    rdmsr
    or eax, EFER_LM_ENABLE
    wrmsr

    ; enable paging (enables long mode)
    mov eax, cr0
    or eax, 1 | (1 << 31)
    mov cr0, eax

    lgdt [gdtr64]

    ; everything is set up,
    ; long jump to the 64 bit kernel
    jmp 0x08:0x100000 ; 1 MB

; accepts 3 args:
; - port
; - bitmask for ones
; - bitmask for zeroes
wait_for_status:
    push ebp
    mov ebp, esp

    mov dx, [ebp+8]
    mov bl, [ebp+12]
    mov cl, [ebp+16]

.loop:
    in al, dx
    test al, bl
    jz .loop

    test al, cl
    jnz .loop

    leave
    ret

section .data
    gdtr32:
        dw gdt32_end - gdt32 - 1
        dd gdt32

    gdt32:
        dq 0 ; null descriptor
        dq 0x00CF9A000000FFFF ; Code segment descriptor
        dq 0x00CF92000000FFFF ; Data segment descriptor
    gdt32_end:

    gdt64:
        dq 0                  ; Null descriptor
        dq 0x00AF9A000000FFFF ; Code segment
        dq 0x00CF92000000FFFF ; Data segment
    gdt64_end:
    
    gdtr64:
        dw gdt64_end - gdt64 - 1 ; limit
        dq gdt64                 ; base

section .bss
    stack_bottom:
    resb 4096
    stack_top:

