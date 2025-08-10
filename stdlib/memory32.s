bits 32

section .text
    global memset
    global memsetw
    global memcpy

; 3 arguments: dst, b, n
; fills n bytes at dst with value b
memset:
    push ebp
    mov ebp, esp

    push edi

    mov edi, [ebp+8]
    mov eax, [ebp+12]
    mov ecx, [ebp+16]

    rep stosb

    mov edi, [ebp-4]
    mov eax, [ebp+8]

    leave
    ret

; memset, word version
memsetw:
    push ebp
    mov ebp, esp

    push edi

    mov edi, [ebp+8]
    mov eax, [ebp+12]
    mov ecx, [ebp+16]

    rep stosw

    mov edi, [ebp-4]
    mov eax, [ebp+8]

    leave
    ret

; 3 arguments: dst, src, n
; copies n bytes from src to dst
memcpy:
    push ebp
    mov ebp, esp

    push edi
    push esi

    cld
    mov edi, [ebp+8]
    mov esi, [ebp+12]
    mov ecx, [ebp+16]

    rep movsb

    mov edi, [ebp-4]
    mov esi, [ebp-8]
    mov eax, [ebp+8]

    leave
    ret

