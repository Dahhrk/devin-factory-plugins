# assembly-kit

Assembly bar for the dark factory Cursor lane. Public research pilot: whispem/learn-assembly-with-em (MIT). cirosantilli/x86-bare-metal-examples noted but license NOASSERTION; similar MIT host preferred.

| Surface | Path |
|---------|------|
| Skills | `skills/assembly`, `skills/poteto-assembly` |
| Rule | `rules/assembly.mdc` (`**/*.{asm,s,S,nasm,inc}`, not alwaysApply) |
| Tier 0 | `scripts/assembly-rg-gate.sh` (shellcode path/label/payload/nop-sled; missing section `.text` unless BITS+ORG; `jmp <reg>` without same-line `;` comment; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/assembly-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `ASSEMBLY_RG_BUDGET_MS`) |
| Tier 1 | `scripts/assembly-build-gate.sh` (nasm / gas `as` wiring in Makefile/CMake/meson/CI) |
| Selfcheck | `scripts/assembly-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/assembly-gates.yml` |
| Boundaries | `templates/no_shellcode.asm`, `templates/section_hygiene.asm`, `templates/jmp_reg_comment.asm` |

PSR Assembly encode (Programming Standards Reference): no shellcode in product paths; explicit section hygiene; no `jmp` to register without comment gate. Primary authority: portable trust bar for NASM/gas product trees. Assembler: nasm or gas when practical.

Compose with `/poteto-mode`. Tier 1 build checks wiring (config-only at 0.1.0 unless noted).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/assembly-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-assembly` (Assembly stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`assembly-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `assembly-hotpath-gate` fails if that wall exceeds `ASSEMBLY_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and learn-assembly-with-em under default budget (research host may FAIL on section hygiene for bootloader).

### Escape

Line marker `assembly-rg-allow` with a short rationale. Prefer named boundaries from `templates/no_shellcode.asm` / `templates/section_hygiene.asm` / `templates/jmp_reg_comment.asm` over scattered allows. Bare-metal `BITS`+`ORG` satisfies section hygiene without `section .text`.

## Selfcheck

`bash scripts/assembly-kit-selfcheck.sh` proves rg/hotpath/build gates discriminate fixtures, single-walk encode, budget discrimination (`ASSEMBLY_RG_BUDGET_MS=1`), PSR nasm/gas wiring bar, and template presence.
