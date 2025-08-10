bits 32

section .text
    extern exc_handler
    global isr_0

%macro ISR 1
isr_%+%1:
    push %1
    call exc_handler
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

    isr_stub_table:
    %assign i 0
    %rep 32
    dd isr_%+i
    %assign i i+1
    %endrep

