---
name: lexyacc
description: PSR Lex/Yacc (Flex/Bison) encode for product *.l / *.y / *.lex / *.yacc / *.ll / *.yy. Use when editing scanner/parser sources or flex/bison CI wiring.
disable-model-invocation: false
---

# Lex/Yacc

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Lex/Yacc checks into product gates.

## PSR Lex/Yacc (encoded)

1. **Agreed toolchain** — *.l / *.y / *.lex / *.yacc / *.ll / *.yy / CI `flex` / `bison` / `lex` / `yacc`. Gate: `scripts/lexyacc-tool-gate.sh`. Product CI: `templates/github-workflows/lexyacc-gates.yml`.
2. **untrusted %include / #include** — no `%include` absolute / URL / `$VAR`; no `#include` absolute / `../` / `$VAR` in prologue. Prefer static relative `%include "rules.inc"` / `#include "local.h"`. Gate: `scripts/lexyacc-rg-gate.sh` (single-walk). Template: `templates/trusted_include.l`.
3. **yyerror silence** — no empty or discard-only `yyerror` body. Prefer `fprintf(stderr, "%s\n", msg)`. Gate: `scripts/lexyacc-rg-gate.sh`. Template: `templates/yyerror_report.y`.
4. **unbounded yytext buffers** — no `strcpy` / `sprintf` / `strcat` of `yytext`. Prefer `snprintf` / `strncpy` with `yyleng`. Gate: `scripts/lexyacc-rg-gate.sh`. Template: `templates/bounded_yytext.l`.
5. **unbounded gen-C yytext pointers** — no `char *p = yytext` / `while (*yytext)` / `for (... = yytext)` walks without `yyleng` on the same line. Prefer index `< yyleng`. Gate: `scripts/lexyacc-rg-gate.sh`. Template: `templates/bounded_yytext_ptr.l`.
6. **Hot-path** — `scripts/lexyacc-hotpath-gate.sh` fails if rg-gate wall exceeds `LEXYACC_RG_BUDGET_MS` (default 250ms).

## Rules

- `lexyacc-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)
- Note licenses: westes/flex is BSD-3-Clause-flex; akimd/bison is GPL-3.0 (fixtures OK; do not vendor substantial GPL into product without license review)

Gates: pack README. Poteto EXIT: skill **poteto-lexyacc**.
