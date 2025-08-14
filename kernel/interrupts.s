bits 32

section .text
    global load_idtr
    extern exc_handler

; 1 arg - pointer at idtr
load_idtr:
    mov eax, [esp+4]
    lidt [eax]

    ret

%macro ISR 1
isr_%+%1:
    pushad ; 8 registers

    push dword %1 ; error vector
    
    call exc_handler
    add esp, 4
    popad
    iret
%endmacro

; generate the functions
%assign i 0
%rep 32
ISR i
%assign i i+1
%endrep

section .data
    global isr_stub_table
    global idtr
    global idt

    isr_stub_table:
    %assign i 0
    %rep 32
    dd isr_%+i
    %assign i i+1
    %endrep

    idtr:
    resb 6
    idt:
    resb 256 ; 32 entries; 8 bytes each

