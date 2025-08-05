; second stage boot loader

bits 16

section .start

_start:
    jmp start

section .text

extern kernel_main
global start
global inb
global outb

start:
    cli
    lgdt [gdtr]

    ; set the protected mode bit
    mov eax, cr0
    or al, 1
    mov cr0, eax

    jmp 0x08:pmode_start

bits 32

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

    call kernel_main

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

