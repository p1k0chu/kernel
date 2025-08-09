
bits 32

section .text
    global printnum
    extern cursor_y
    extern cursor_x
    extern vga_width

; print a number
; args:
; - int to print
; - one byte color attribute
printnum:
    push ebp
    mov ebp, esp

    push edi
    push ebx

    ; calculate start address
    mov edi, 0xB8000
    xor eax, eax
    mov al, [cursor_y]
    mov cl, [vga_width]
    imul ax, cx
    mov cl, [cursor_x]
    add ax, cx
    shl eax, 1
    add edi, eax

    mov eax, [ebp + 8]
    mov ebx, 10
    xor ecx, ecx

    cmp eax, 0
    jge .calc_loop

    ; below 0!
    ; print the -
    mov byte [edi], '-'
    inc edi
    mov byte [edi], 15
    inc edi

    ; eax = abs(eax)
    not eax
    inc eax

.calc_loop:
    cmp eax, 10
    jb .print

    xor edx, edx
    div ebx

    push edx
    inc ecx

    jmp .calc_loop

.print:
    push eax
    inc ecx

    mov eax, [cursor_x]
    add eax, ecx
    mov ebx, [vga_width]
    cmp eax, ebx
    jb .bla

    xor edx, edx
    div ebx

    add [cursor_y], eax
    mov [cursor_x], edx
    jmp .print_loop

.bla:
    mov [cursor_x], eax

.print_loop:
    ; ecx has the N of characters

    pop eax
    add al, '0'
    mov ah, [ebp+12]
    mov [edi], ax
    add edi, 2

    loop .print_loop

    mov edi, [ebp-4]
    mov ebx, [ebp-8]

    leave
    ret

