
bits 32

section .text
    global printnum
    extern putc_white

; print a number
; one int argument: the number
printnum:
    push ebp
    mov ebp, esp
    
    mov eax, [ebp+8]

    cmp eax, 0
    jge .pos

    ; below
    push '-'
    call putc_white
    add esp, 4

    mov eax, [ebp+8]
    not eax
    add eax, 1

.pos:
    mov ebx, 10
    xor ecx, ecx

    cmp eax, 10
    jl .stage2

.loop:
    inc ecx
    cdq

    div ebx
    push edx

    cmp eax, 10
    jge .loop

.stage2:
    inc ecx
    push eax

.loop2:
    cmp ecx, 0
    je .return

    dec ecx

    pop eax
    push ecx
    add eax, '0'
    push eax

    ; call putc_white
    call putc_white
    add esp, 4
    pop ecx

    jmp .loop2

.return:

    leave
    ret

