bits 32

section .text
    extern exc_handler

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

