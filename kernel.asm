; kernel asm side

bits 32

section .start
    global _start

_start:
    ; setup stack
    mov esp, stack_top
    mov ebp, esp

    call kernel_main
    jmp hang

section .text
    extern kernel_main
    global inb
    global outb

hang:
    hlt
    jmp hang

; talk to hardware, send data
; args:
; - port (short)
; - data (byte)
outb:
    push ebp
    mov ebp, esp

    mov dx, [ebp + 8]
    mov al, [ebp + 12]
    out dx, al

    leave
    ret

; talk to hardware, recv data
; args:
; - port (short)
; returns a byte
inb:
    push ebp
    mov ebp, esp

    mov dx, [ebp + 8]
    in al, dx

    leave
    ret

section .bss

stack_bottom:
resb 4096
stack_top:

