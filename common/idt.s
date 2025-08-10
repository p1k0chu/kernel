bits 32

section .text
    global load_idtr

; 1 arg - pointer at idtr
load_idtr:
    mov eax, [esp+4]
    lidt [eax]
    sti

    ret

