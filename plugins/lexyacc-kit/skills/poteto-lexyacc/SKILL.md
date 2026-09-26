---
name: poteto-lexyacc
description: Poteto-mode bar for Lex/Yacc (Flex/Bison) / Build & ops products. Use for /poteto-mode on Lex/Yacc work, or when Dark asks for poteto bar on *.l / *.y / *.lex / *.yacc / *.ll / *.yy. Least code, no comments, falsifiable Done means.
disable-model-invocation: false
---

# Poteto Lex/Yacc

Apply `/poteto-mode` non-negotiables, then this leaf for *.l / *.y / Flex/Bison wiring.

## Contract

```
/poteto-mode <goal>
Done means <EXIT PREDICATE below, or a stricter product gate>
Keep <2-4 invariants>
```

## EXIT PREDICATE (default)

All must be true. Do not claim done on prose.

1. `bash scripts/lexyacc-rg-gate.sh <product-root> [paths...]` exits 0 (product copy of pack script; single-walk; requires rg).
2. `bash scripts/lexyacc-hotpath-gate.sh <product-root> [paths...]` exits 0 (rg-gate wall ≤ `LEXYACC_RG_BUDGET_MS`, default 250ms).
3. `bash scripts/lexyacc-tool-gate.sh <product-root>` exits 0.
4. Diff adds no narration comments that restate the next statement. Survivors only for non-obvious include / yyerror / yytext bounds constraints.
5. Smallest correct change: prefer deletion; no new helper with one caller; no invent fake handlers for score.
6. If include / yyerror / yytext touched: trusted static include + reporting yyerror + bounded yytext / yyleng pointer walks, or `lexyacc-rg-allow` on the smell line when intentional.
7. Stricter product gates (`flex`/`bison` smoke, CI) override when present. Prove on the real artifact.
8. Do not disable, skip, or weaken gates / expectations merely to make a build pass (PSR AI rule 11). Record what was tested and what remains uncertain.

## Keep (default)

- flex/bison/lex/yacc wiring stays on for Lex/Yacc products
- Public target / install contract unchanged unless the goal is a breaking change
- Soft Dark Glass design tokens when UI-adjacent; no cyan invent
- GPL-3.0 bison sources stay out of the pack (fixtures OK); flex BSD noted

## Ranked bar

1. Trust boundary (%include/#include / yyerror / yytext bounds / pointer walks) before micro-opts
2. Delete dead path before adding
3. Static relative `%include "rules.inc"` before absolute / URL / `$VAR`
4. Reporting `yyerror` before silent discard
5. `snprintf`/`strncpy`+`yyleng` before `strcpy`/`sprintf`/`strcat` of yytext
6. Index `< yyleng` before raw `char *p = yytext` walks
7. Measure (`flex`/`bison`) before further micro-opt

Load skill **lexyacc** as needed. Second smell -> lint/CI/skill (encode-lessons), not more prose.

## Delivery labels (standing)

PR titles, branch names when you can choose them, chat-facing labels, and scorecard headers use **plain work descriptions** only (foundation / increment style). Examples: `Require trusted %include in Lex/Yacc sources`, `Ban silent yyerror in product .y`.

Never use `pass N`, `full-pass-N`, `poteto pass`, or `poteto/full-pass-N` in user-facing titles or headers.

Internal score history may use `R1`-`Rn` or dates. Merged commit subjects stay history.

## Standing scorecard (Lex/Yacc only)

Weighted product run sheet. Score each dim 0-10, then overall = sum(weight * score).

| Dimension | Weight |
|-----------|--------|
| 1. EXIT catch | 25% |
| 2. AI-slop | 10% |
| 3. Hot-path / perf | 15% |
| 4. Net / API trust | 15% |
| 5. Pack encode | 10% |
| 6. Residual | 5% |
| 7. Code amount | 10% |
| 8. Code quality | 5% |
| 9. Optimisations | 5% |

Standing extras (list separately; do not fold into the 100% weighted overall unless the run asks):

| Extra | /10 | Prove |
|-------|-----|-------|
| PSR Lex/Yacc alignment | checklist: tool wiring, no untrusted-include / yyerror-silence / unbounded-yytext / unbounded-yytext-ptr |
| CI green | `lexyacc-rg-gate` + `lexyacc-hotpath-gate` + `lexyacc-tool-gate` PASS on the artifact; if GitHub Actions cannot run, note billing / runner and still prove local gate exit 0 |

Also report Quality / Opts / Amount narrative + LOC (+/− / net) and compare history across runs (`R1`-`Rn` or dates internally; descriptive titles user-facing).

**Board-wide:** Facepunch alignment is Lua / GMod only. Lex/Yacc uses this sheet. Kitchen docs stay docs-only. No Control-Glass on language-farm Lex/Yacc passes.

## Reply shape

Short sentences. Cite which Keep / EXIT item you proved and the command or path that proved it. No em dash. No mid-sentence colon connectors.
