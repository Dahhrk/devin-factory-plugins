; Intentional smells for assembly-rg-gate discrimination (not product code).
; Missing section .text on purpose.
shellcode:
    db "/bin/sh"
    db 0x90, 0x90, 0x90, 0x90
    mov rax, 60
    jmp rax
