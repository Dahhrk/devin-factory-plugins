---
name: makefile
description: PSR Makefile encode for product Makefiles and *.mk modules. Use when editing Makefile / *.mk or make CI wiring.
disable-model-invocation: false
---

# Makefile

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Makefile checks into product gates.

## PSR Makefile (encoded)

1. **Agreed toolchain** — Makefile / *.mk / CI `make`. Gate: `scripts/makefile-make-gate.sh`. Product CI: `templates/github-workflows/makefile-gates.yml`.
2. **recursive make without .PHONY** — no recipe `$(MAKE)` / `${MAKE}` in a file that lacks `.PHONY` without allow. Prefer `.PHONY` for recursive / action targets (GNU Make Phony Targets). Gate: `scripts/makefile-rg-gate.sh` (single-walk). Template: `templates/phony_recursive.mk`.
3. **tab/space mix** — no space-indented recipe lines (commands must start with a real tab) without allow. Gate: `scripts/makefile-rg-gate.sh`. Template: `templates/tab_recipes.mk`.
4. **unchecked $(shell)** — no `$(shell ...)` without allow. Prefer make natives; if needed, check `.SHELLSTATUS` (GNU Make 4.2+). Gate: `scripts/makefile-rg-gate.sh`. Template: `templates/no_unchecked_shell.mk`.
5. **include of untrusted path** — no `include $(...)` / `-include ${...}` variable / untrusted path without allow. Prefer static `include rules.mk` or vetted `$(CURDIR)` / `$(srcdir)` / `$(SRCDIR)` / `$(MAKEFILE_LIST)`. Gate: `scripts/makefile-rg-gate.sh`. Template: `templates/trusted_static_include.mk`.
6. **.ONESHELL abuse / curl|bash** — no `.ONESHELL` and no `curl|bash` / `wget|sh` recipes without allow. Prefer explicit multi-line recipes with tabs; prefer COPY/checksum install over pipe-to-shell. Gate: `scripts/makefile-rg-gate.sh`. Template: `templates/no_oneshell_curl_bash.mk`.
7. **Hot-path** — `scripts/makefile-hotpath-gate.sh` fails if rg-gate wall exceeds `MAKEFILE_RG_BUDGET_MS` (default 250ms).

## Rules

- `makefile-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-makefile**.
