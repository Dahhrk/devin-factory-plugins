# fortran-kit

Fortran bar for the dark factory Cursor lane. Public research pilot: fortran-lang/stdlib (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/fortran`, `skills/poteto-fortran` |
| Rule | `rules/fortran.mdc` (`**/*.{f90,F90,f95,F95,f03,F03,f08,F08,f,F,fypp}`, not alwaysApply) |
| Tier 0 | `scripts/fortran-rg-gate.sh` (missing / non-`none` `implicit`; `GOTO` / `GO TO`; unchecked `open`/`read`/`write`/`close` without `iostat=`; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/fortran-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `FORTRAN_RG_BUDGET_MS`) |
| Tier 1 | `scripts/fortran-fortitude-gate.sh` (fortitude wiring / live; requires `C001` / `implicit-typing` encode) |
| Selfcheck | `scripts/fortran-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/fortran-gates.yml` |
| Boundaries | `templates/implicit_none.f90`, `templates/no_goto.f90`, `templates/checked_io.f90` |
| Lint starter | `templates/.fortitude.toml` |
| Formatter | **fprettify** (recommended; not a hard gate at 0.1.0) |

PSR Fortran encode (Programming Standards Reference): fortitude lint; `implicit none` (no old-style implicit typing); no `GOTO` / `GO TO` without allow; `open`/`read`/`write`/`close` carry `iostat=` (or allow). Primary authority: fortitude (`C001` implicit-typing) plus portable trust bar for GOTO / I/O. Formatter: fprettify when practical.

Compose with `/poteto-mode`. Tier 1 fortitude checks wiring (live `fortitude check` when on PATH unless `FORTRAN_FORTITUDE_CONFIG_ONLY=1`). Config must keep **C001** / **implicit-typing** enabled (not ignored / excluded).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/fortran-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-fortran` (Fortran stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`fortran-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `fortran-hotpath-gate` fails if that wall exceeds `FORTRAN_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and stdlib `src/` under default budget.

### Escape

Line marker `fortran-rg-allow` with a short rationale. Prefer named boundaries from `templates/implicit_none.f90` / `templates/no_goto.f90` / `templates/checked_io.f90` over scattered allows.

## Selfcheck

`bash scripts/fortran-kit-selfcheck.sh` proves rg/hotpath/fortitude gates discriminate fixtures, single-walk encode, budget discrimination (`FORTRAN_RG_BUDGET_MS=1`), PSR fortitude C001 bar, and template presence.
