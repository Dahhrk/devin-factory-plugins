section .rodata
msg: db "ok", 10

section .text
global _start
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, 3
    syscall
    ; Documented intentional seam; keep allow on the smell line when needed.
    jmp rax ; assembly-rg-allow: fixture documents allow marker for intentional jmp-reg seam
    mov rax, 60
    xor rdi, rdi
    syscall
