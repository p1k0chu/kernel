org 0x7C00
bits 16

start:
    ; set es to 0xB800
    mov ax, 0xB800
    mov es, ax

    ; clear the vga buffer
    xor di, di
    mov ax, 0x0020
    mov cx, 2000
    rep stosw

    ; black bg, white fg
    mov ah, 0b00001111

    xor di, di
    mov si, msg

.loop:
    mov al, [si]
    cmp al, 0
    je draw_heart

    ; write a character
    mov [es:di], ax

    ; next character on screen
    add di, 2
    add si, 1
    jmp .loop

draw_heart:
    mov ah, 0b01011111
    mov si, heart

.loop:
    mov al, [si]
    cmp al, 0
    je hang

    mov [es:di], ax

    add di, 2
    add si, 1
    jmp .loop

hang:
    cli
.loop:
    hlt
    jmp hang.loop

msg db "I love Maya ", 0
heart db "<3", 0

times 510 - ($-$$) db 0  ; pad to 510 bytes
dw 0xAA55                ; boot signature (2 bytes)
