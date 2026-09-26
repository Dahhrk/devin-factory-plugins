# lexyacc-kit

Lex/Yacc (Flex/Bison) bar for the dark factory Cursor lane. Public research pilots: westes/flex (BSD-3-Clause-flex) and akimd/bison (GPL-3.0). Fixtures OK for smell demos; do not vendor substantial GPL bison sources into the pack.

| Surface | Path |
|---------|------|
| Skills | `skills/lexyacc`, `skills/poteto-lexyacc` |
| Rule | `rules/lexyacc.mdc` (`**/*.{l,y,lex,yacc,ll,yy}`, not alwaysApply) |
| Tier 0 | `scripts/lexyacc-rg-gate.sh` (untrusted %include/#include; yyerror silence; unbounded yytext buffers; unbounded gen-C yytext pointers; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/lexyacc-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `LEXYACC_RG_BUDGET_MS`) |
| Tier 1 | `scripts/lexyacc-tool-gate.sh` (*.l / *.y / *.lex / *.yacc / *.ll / *.yy / CI flex|bison|lex|yacc wiring / live flex|bison when resolvable) |
| Selfcheck | `scripts/lexyacc-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/lexyacc-gates.yml` |
| Boundaries | `templates/trusted_include.l`, `templates/yyerror_report.y`, `templates/bounded_yytext.l`, `templates/bounded_yytext_ptr.l` |

PSR Lex/Yacc encode (Programming Standards Reference): never untrusted `%include` / `#include` paths (absolute / URL / `../` / `$VAR`); never silent `yyerror` (empty body / discard); never unbounded `strcpy`/`sprintf`/`strcat` of `yytext`; never generated action C that walks `yytext` pointers without `yyleng` bounds. Primary authority: westes/flex (BSD) + akimd/bison (GPL-3.0, fixtures only) — intentional smell fixtures drive the product bar.

Compose with `/poteto-mode`. Tier 1 checks flex/bison/lex/yacc wiring (live when resolvable unless `LEXYACC_TOOL_CONFIG_ONLY=1`).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/lexyacc-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-lexyacc` (Lex/Yacc / Build & ops stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`lexyacc-rg-gate` walks the tree **once** (union of line smell patterns), then classifies the hit set. `lexyacc-hotpath-gate` fails if that wall exceeds `LEXYACC_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `lexyacc-rg-allow` with a short rationale. Prefer named boundaries from templates over scattered allows. Prefer static relative `%include "rules.inc"`. Prefer `yyerror` that reports via `fprintf(stderr, ...)`. Prefer `snprintf`/`strncpy` with `yyleng`. Prefer `yyleng`-bounded pointer walks.

## Selfcheck

`bash scripts/lexyacc-kit-selfcheck.sh` proves rg/hotpath/tool gates discriminate fixtures, single-walk encode, budget discrimination (`LEXYACC_RG_BUDGET_MS=1`), tool wiring bar, and template presence.
