; Explicit section hygiene: declare section .text (or .section .text / .text).
; Bare-metal boot units may use BITS + ORG instead.
section .rodata
msg: db "ok", 10
msg_len equ $ - msg

section .text
global _start
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, msg_len
    syscall
    mov rax, 60
    xor rdi, rdi
    syscall
