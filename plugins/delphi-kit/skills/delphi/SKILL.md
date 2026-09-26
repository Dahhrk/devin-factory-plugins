---
name: delphi
description: Delphi / Object Pascal PSR bar. no goto, no with-statement, unchecked GetMem, WriteLn banned in libs, fpc/lazbuild wiring. Use when reading or editing any .pas/.pp/.dpr/.lpr in a factory product.
paths: ["**/*.pas", "**/*.pp", "**/*.inc", "**/*.dpr", "**/*.lpr", "**/Makefile", "**/.github/workflows/**"]
---

# Delphi / Object Pascal

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Delphi / Object Pascal checks into product gates.

## PSR Delphi / Object Pascal (encoded)

1. **goto** — no `goto` without allow. Prefer structured loops, `Exit`, `raise`. Gate: `scripts/delphi-rg-gate.sh` (single-walk). Template: `templates/no_goto.pas`.
2. **with-statement** — no `with ... do` without allow. Prefer explicit qualifiers. Gate: `scripts/delphi-rg-gate.sh`. Template: `templates/no_with.pas`.
3. **Unchecked GetMem** — ``GetMem` / `System.GetMem` banned (unchecked heap API); prefer `New` / managed types. Gate: `scripts/delphi-rg-gate.sh`. Template: `templates/checked_getmem.pas`.
4. **WriteLn in libs** — no standalone `WriteLn` / `Writeln` in library units (`.pas` / `.pp`). Method calls like `IOHandler.WriteLn` are not this smell. CLI `.dpr` / `.lpr` may WriteLn. Gate: `scripts/delphi-rg-gate.sh`. Template: `templates/no_writeln_lib.pas`.
5. **Hot-path** — `scripts/delphi-hotpath-gate.sh` fails if rg-gate wall exceeds `DELPHI_RG_BUDGET_MS` (default 250ms).
6. **fpc / lazbuild wiring** — Makefile / build script / CI mentioning `fpc` or `lazbuild`. Gate: `scripts/delphi-fpc-gate.sh`. Product CI: `templates/github-workflows/delphi-gates.yml`.

## Rules

- `delphi-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-delphi**.
