---
name: cobol
description: COBOL PSR bar. no GOTO/ALTER, checked ACCEPT (ON EXCEPTION), END-IF hygiene, cobc wiring. Use when reading or editing any .cob/.cbl/.cpy in a factory product.
paths: ["**/*.cob", "**/*.cbl", "**/*.cpy", "**/*.COB", "**/*.CBL", "**/*.CPY", "**/Makefile", "**/.github/workflows/**"]
---

# COBOL

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference COBOL checks into product gates.

## PSR COBOL (encoded)

1. **GOTO** — no `GOTO` / `GO TO` without allow. Prefer `PERFORM`, `EVALUATE`, structured `EXIT`. Gate: `scripts/cobol-rg-gate.sh` (single-walk). Template: `templates/no_goto.cob`.
2. **ALTER** — no `ALTER` without allow. Prefer explicit `PERFORM` targets. Gate: `scripts/cobol-rg-gate.sh`. Template: `templates/no_alter.cob`.
3. **Unchecked ACCEPT** — `ACCEPT` carries `ON EXCEPTION` (or `ON ERROR`) on the same line without allow. Gate: `scripts/cobol-rg-gate.sh`. Template: `templates/checked_accept.cob`.
4. **END-IF hygiene** — file-level IF count must not exceed END-IF count (period-terminated IF-without-END-IF is a smell). Gate: `scripts/cobol-rg-gate.sh`. Template: `templates/end_if.cob`.
5. **Hot-path** — `scripts/cobol-hotpath-gate.sh` fails if rg-gate wall exceeds `COBOL_RG_BUDGET_MS` (default 250ms).
6. **cobc wiring** — Makefile / CMake / meson / CI mentioning `cobc` (GnuCOBOL). Gate: `scripts/cobol-cobc-gate.sh`. Product CI: `templates/github-workflows/cobol-gates.yml`.

## Rules

- `cobol-rg-allow` on the same line as the smell, with a short rationale (line smells only; END-IF imbalance is file-wide)
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-cobol**.
