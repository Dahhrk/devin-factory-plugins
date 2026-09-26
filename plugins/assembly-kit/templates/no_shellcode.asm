; Product asm must not ship shellcode paths, shellcode labels, /bin/sh db payloads,
; or nop-sled db 0x90,0x90,0x90+. Prefer ordinary syscalls and documented test fixtures.
section .text
global _start
_start:
    mov rax, 60
    xor rdi, rdi
    syscall
