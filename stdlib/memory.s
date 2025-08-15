bits 64

section .text
    global memset
    global memsetw
    global memcpy

; 3 arguments: dst, b, n
; fills n bytes at dst with value b
memset:
    ; rdi = dst
    mov rax, rsi
    mov rcx, rdx

    rep stosb

    ret

; memset, word version
memsetw:
    ; rdi = dst
    mov rax, rsi
    mov rcx, rdx

    rep stosw

    ret

; 3 arguments: dst, src, n
; copies n bytes from src to dst
memcpy:
    cld
    ; rdi = dst
    ; rsi = src
    mov rcx, rdx

    rep movsb

    ret

