bits 64

section .text
    global load_idtr
    extern exc_handler

; 1 arg - pointer at idtr
load_idtr:
    lidt [rdi]
    ret

%macro PUSH_ALL 0
push rax
push rcx
push rdx
push rbx
push rbp
push rsi
push rdi
push r8
push r9
push r10
push r11
push r12
push r13
push r14
push r15
%endmacro

%macro POP_ALL 0
pop r15
pop r14
pop r13
pop r12
pop r11
pop r10
pop r9
pop r8
pop rdi
pop rsi
pop rbp
pop rbx
pop rdx
pop rcx
pop rax
%endmacro

isr_common:
    PUSH_ALL

    mov rdi, [rsp + 15*8]
    mov rsi, rsp
    lea rdx, [rsp + 15*8 + 8]

    cld
    call exc_handler ; never returns

    ;POP_ALL
    ;add rsp, 8 ; pop error vector
    ;iretq

%macro ISR 1
isr_%+%1:
    push %1 ; error vector
    
    jmp isr_common
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
    dq isr_%+i
    %assign i i+1
    %endrep

    idtr:
    resb 10
    idt:
    resb 512 ; 32 entries; 16 bytes each

