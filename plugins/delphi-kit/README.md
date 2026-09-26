# delphi-kit

Delphi / Object Pascal bar for the dark factory Cursor lane. Public research pilot: HashLoad/horse (MIT, active, Delphi + Lazarus / FPC). User-suggested skalogryz/pascal was **404 / not found** — similar clear MIT Free Pascal / Lazarus-friendly host preferred. Corroboration: ikelaiah/free-pascal-snippets (MIT; goto + GetMem surface in vendored lgenerics).

| Surface | Path |
|---------|------|
| Skills | `skills/delphi`, `skills/poteto-delphi` |
| Rule | `rules/delphi.mdc` (`**/*.{pas,pp,inc,dpr,lpr}`, not alwaysApply) |
| Tier 0 | `scripts/delphi-rg-gate.sh` (goto; with-statement; unchecked GetMem; WriteLn in libs; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/delphi-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `DELPHI_RG_BUDGET_MS`) |
| Tier 1 | `scripts/delphi-fpc-gate.sh` (Free Pascal `fpc` / Lazarus `lazbuild` Makefile/CI wiring) |
| Selfcheck | `scripts/delphi-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/delphi-gates.yml` |
| Boundaries | `templates/no_goto.pas`, `templates/no_with.pas`, `templates/checked_getmem.pas`, `templates/no_writeln_lib.pas` |

PSR Delphi / Object Pascal encode (Programming Standards Reference): no `goto`; no `with ... do`; GetMem banned (unchecked heap API; prefer `New` / managed types); `WriteLn` banned in library units (`.pas` / `.pp`; CLI `.dpr` / `.lpr` programs may WriteLn). Primary authority: portable trust bar for Delphi / Free Pascal / Lazarus product trees. Toolchain: **fpc** / **lazbuild** wiring required at 0.1.0.

Compose with `/poteto-mode`. Tier 1 fpc checks wiring (config-only at 0.1.0).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/delphi-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-delphi` (Delphi / Object Pascal stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`delphi-rg-gate` walks the tree **once** (union of line smells), classifies the hit set in parallel. `delphi-hotpath-gate` fails if that wall exceeds `DELPHI_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `delphi-rg-allow` with a short rationale. Prefer named boundaries from `templates/no_goto.pas` / `templates/no_with.pas` / `templates/checked_getmem.pas` / `templates/no_writeln_lib.pas` over scattered allows.

## Selfcheck

`bash scripts/delphi-kit-selfcheck.sh` proves rg/hotpath/fpc gates discriminate fixtures, single-walk encode, budget discrimination (`DELPHI_RG_BUDGET_MS=1`), fpc wiring bar, and template presence.
