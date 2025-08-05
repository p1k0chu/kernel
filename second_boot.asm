; second stage boot loader

org 0x8000

%define SPACE 0x20
%define NEW_LINE 0xA

start:
    ; setup stack
    mov ax, 0x7000
    mov ss, ax
    mov sp, 0xFFFE

    ; fetch vga text mode width
    mov ah, 0x0F
    int 0x10

    mov dl, ah
    shl dx, 1
    mov [vga_width], dx

    ; setup segment override for vga text mode
    mov ax, 0xB800
    mov es, ax

    call clear

    xor di, di
    mov si, msg
    call print

hang:
    cli
.loop:
    hlt
    jmp .loop

newline:
    ; di - index
    ; return ax - new index
    mov bx, [vga_width]
    add di, bx

    ; calculate remainder di/bx
    mov ax, di
    xor dx, dx
    mov cx, bx
    div cx

    mov ax, di

    ; move back to the start of the line
    sub ax, dx

    ret

; prints a string
print:
    ; di - the character index
    ; si - pointer at the beginning of str
    ; return ax - new character index
    
.loop:
    mov al, [si]
    cmp al, 0
    je .ret

    ; new line?
    cmp al, NEW_LINE
    jne .nn

    ; new line.
    call newline
    mov di, ax
    inc si
    jmp .loop

; no new line
.nn:
    mov ah, 0b00001111 ; white on black
    mov [es:di], ax
    add di, 2
    inc si
    jmp .loop

.ret:
    mov ax, di
    ret

; clears the screen
clear:
    xor dx, dx
    mov ax, [vga_width]
    mov bx, 25
    mul bx
    mov cx, ax

    mov ax, 0x20
    xor di, di ; start from 0 character
    rep stosw

    ret


msg db "I love maya <3", NEW_LINE
    db "she is the best girl ever <3", NEW_LINE
    db "shes my happiness :33", 0

; global variable to store
; vga text mode columns width (in bytes)
; its double because 2 bytes per character
vga_width dw 0

