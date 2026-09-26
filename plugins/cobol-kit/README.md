# cobol-kit

COBOL bar for the dark factory Cursor lane. Public research pilot: meyfa/CobolCraft (MIT, active). openmainframeproject/cobol-programming-course suggested but **CC-BY-4.0** (not MIT) — similar clear-license MIT host preferred. Corroboration: azac/cobol-on-wheelchair (MIT; ACCEPT + END-IF imbalance).

| Surface | Path |
|---------|------|
| Skills | `skills/cobol`, `skills/poteto-cobol` |
| Rule | `rules/cobol.mdc` (`**/*.{cob,cbl,cpy,COB,CBL,CPY}`, not alwaysApply) |
| Tier 0 | `scripts/cobol-rg-gate.sh` (GOTO/GO TO; ALTER; unchecked ACCEPT; END-IF imbalance; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/cobol-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `COBOL_RG_BUDGET_MS`) |
| Tier 1 | `scripts/cobol-cobc-gate.sh` (GnuCOBOL `cobc` Makefile/CI wiring) |
| Selfcheck | `scripts/cobol-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/cobol-gates.yml` |
| Boundaries | `templates/no_goto.cob`, `templates/no_alter.cob`, `templates/checked_accept.cob`, `templates/end_if.cob` |

PSR COBOL encode (Programming Standards Reference): no GOTO / GO TO; no ALTER; ACCEPT carries ON EXCEPTION (or ON ERROR); IF/END-IF hygiene (file-level IF count ≤ END-IF count). Primary authority: portable trust bar for GnuCOBOL / IBM enterprise product trees. Toolchain: **cobc** wiring required at 0.1.0.

Compose with `/poteto-mode`. Tier 1 cobc checks wiring (config-only at 0.1.0).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/cobol-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-cobol` (COBOL stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`cobol-rg-gate` walks the tree **once** (union of line smells), classifies the hit set, then a cheap batch pass for END-IF imbalance. `cobol-hotpath-gate` fails if that wall exceeds `COBOL_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `cobol-rg-allow` with a short rationale. Prefer named boundaries from `templates/no_goto.cob` / `templates/no_alter.cob` / `templates/checked_accept.cob` / `templates/end_if.cob` over scattered allows. END-IF imbalance is file-wide (add matching END-IF; allow marker does not skip the file-level check).

## Selfcheck

`bash scripts/cobol-kit-selfcheck.sh` proves rg/hotpath/cobc gates discriminate fixtures, single-walk encode, budget discrimination (`COBOL_RG_BUDGET_MS=1`), cobc wiring bar, and template presence.
