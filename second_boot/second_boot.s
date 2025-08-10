; second stage boot loader

bits 16

%define DRQ 0x8
%define BSY 0x80
%define KERNEL_SECTORS 20

section .start
    global start

start:
    cli
    lgdt [gdtr]

    ; set the protected mode bit
    mov eax, cr0
    or al, 1
    mov cr0, eax

    jmp 0x08:pmode_start

bits 32

section .text

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

    ; start with 3rd sector
    inc dx
    %if KERNEL_SECTORS != 2
    mov al, 2
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

    ; reading is done. execute
    jmp 0x100000 ; 1 MB

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
    gdtr:
        dw gdt_end - gdt - 1
        dd gdt
    
    gdt:
        dq 0 ; null descriptor
        dq 0x00CF9A000000FFFF ; Code segment descriptor
        dq 0x00CF92000000FFFF ; Data segment descriptor
    gdt_end:

section .bss
    stack_bottom:
    resb 4096
    stack_top:

