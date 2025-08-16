; kernel asm side

bits 64

section .start
    global main
    extern kernel_main
    extern setup_idt

main:
    ; setup stack
    lea rsp, [rel stack_top]
    mov rbp, rsp

    mov al, 0xFF
    out 0x21, al    ; mask master PIC
    out 0xA1, al    ; mask slave PIC

    call setup_idt
    sti

    call kernel_main
    jmp hang

section .text
    global inb
    global outb
    global get_stack_top

hang:
    hlt
    jmp hang

; talk to hardware, send data
; args:
; - port (short)
; - data (byte)
outb:
    mov dx, di
    mov al, sil
    out dx, al

    ret

; talk to hardware, recv data
; args:
; - port (short)
; returns a byte
inb:
    mov dx, di
    in al, dx

    ret

; 😭 BRO IS CODING IN JAVA OR WHAT?
get_stack_top:
    lea rax, [rel stack_top]
    ret

section .bss

stack_bottom:
resb 4096
stack_top:

