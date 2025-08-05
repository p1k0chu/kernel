; second stage boot loader

org 0x8000

%define SPACE 0x20
%define NEW_LINE 0xA

start:
    ; fetch vga video mode
    ; ah - number of columns
    mov ah, 0x0F
    int 0x10

    mov bl, ah
    shl bx, 1 ; multiply by two 
              ; because two bytes per character

    ; setup segment override for vga text mode
    mov ax, 0xB800
    mov es, ax
    xor di, di

clear:
    ; clear screen
    mov ah, 0
    mov al, SPACE

    ; clear 25 rows
    mov cx, bx
    imul cx, 25

.loop:
    mov [es:di], ax
    add di, 2

    cmp di, cx
    jb .loop

message:
    xor di, di
    mov si, msg

.loop:
    mov ah, 0b00001111 ; white on black
    mov al, [si]
    cmp al, 0
    je hang

    cmp al, NEW_LINE
    jne .print_char

    ; newline
    ; add the full vga text mode width
    add di, bx

    ; calculate remainder di/bx
    mov ax, di
    xor dx, dx
    mov cx, bx
    div cx

    ; move back di to the start of the line
    sub di, dx

    jmp .inc_char

.print_char:
    mov [es:di], ax
    add di, 2

.inc_char:
    inc si
    jmp .loop

hang:
    cli
.loop:
    hlt
    jmp .loop

msg db "I love maya <3", NEW_LINE
    db "she is the best girl ever <3", NEW_LINE
    db "shes my happiness :33", 0

