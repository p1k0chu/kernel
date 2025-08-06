; first stage boot loader

bits 16
org 0x7C00

start:
    ; explicitly set es to 0
    xor ax, ax
    mov es, ax

    mov ah, 0x02     ; BIOS read sector function
    mov al, 1        ; Read 1 sector
    mov ch, 0        ; Cylinder 0
    mov cl, 2        ; first sector will be 2
    mov dh, 0        ; Head 0
    mov dl, 0x80     ; First HDD
    ; Load address = 0x0000:0x8000
    mov bx, 0x8000
    int 0x13

    jc error

    ; enable a20 line
    in al, 0x92
    or al, 2
    out 0x92, al

    ; jump to loaded code
    jmp 0x0000:0x8000 

error:
    cli
.loop:
    hlt
    jmp .loop


times 510-($-$$) db 0
dw 0xAA55

