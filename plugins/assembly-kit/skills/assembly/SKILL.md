---
name: assembly
description: Assembly PSR bar. No shellcode in product paths, explicit section hygiene, no jmp-to-register without comment. nasm/gas build. Use when reading or editing any .asm/.s/.S/.nasm in a factory product.
paths: ["**/*.asm", "**/*.s", "**/*.S", "**/*.nasm", "**/*.inc", "**/Makefile", "**/CMakeLists.txt", "**/.github/workflows/**"]
---

# Assembly

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Assembly checks into product gates.

## PSR Assembly (encoded)

1. **No shellcode in product paths** — ban path/name `*shellcode*`; content labels matching `\bshellcode\b`; classic payload `db "/bin/sh"` / `db '/bin/sh'`; nop-sled `db 0x90, 0x90, 0x90` (3+). Gate: `scripts/assembly-rg-gate.sh` (single-walk). Template: `templates/no_shellcode.asm`.
2. **Section hygiene** — instruction-bearing `.asm`/`.s` units declare `section .text` / `.section .text` / `.text`, or bare-metal `BITS` + `ORG`. Gate: `scripts/assembly-rg-gate.sh` (file-level). Template: `templates/section_hygiene.asm`.
3. **jmp to register** — `jmp <reg>` requires a same-line `;` comment (why indirect) or `assembly-rg-allow`. Gate: `scripts/assembly-rg-gate.sh`. Template: `templates/jmp_reg_comment.asm`.
4. **Hot-path** — `scripts/assembly-hotpath-gate.sh` fails if rg-gate wall exceeds `ASSEMBLY_RG_BUDGET_MS` (default 250ms).
5. **Build wiring** — nasm or gas (`as`) in Makefile / CMake / meson / CI. Gate: `scripts/assembly-build-gate.sh`.

## Rules

- `assembly-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)
- Shell interpreters / CLI shells in product trees are not shellcode; shellcode means exploit payload patterns and `*shellcode*` product paths

Gates: pack README. Poteto EXIT: skill **poteto-assembly**.
