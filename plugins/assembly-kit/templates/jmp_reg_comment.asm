; Indirect jmp must carry a same-line ; comment explaining why (ABI / tail-call / table).
section .text
global dispatch
dispatch:
    ; rax holds the target primitive
    jmp rax                    ; tail-call primitive; returns to our caller
