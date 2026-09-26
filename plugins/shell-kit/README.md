# shell-kit

Shell bar for the dark factory Cursor lane. Public research pilot: ohmyzsh (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/shell`, `skills/poteto-shell` |
| Rule | `rules/shell.mdc` (`**/*.{sh,bash}`, not alwaysApply) |
| Tier 0 | `scripts/sh-rg-gate.sh` (eval / unsafe `/tmp/$$` / unquoted for|cd|rm / curl\|sh; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/sh-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `SH_RG_BUDGET_MS`) |
| Tier 0.5 | `scripts/sh-shellcheck-gate.sh` + `scripts/sh-fmt-gate.sh` |
| Tier 1 | `scripts/sh-strict-gate.sh` (`set -euo pipefail` in product scripts) |
| Tier 1 | `scripts/sh-test-gate.sh` (tests present; filenames/signals/empty) |
| Selfcheck | `scripts/sh-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/sh-gates.yml` + `templates/shellcheck/shellcheckrc` |
| Boundaries | `templates/safe_temp.sh`, `templates/quoted_expand.sh`, `templates/test_edge.sh` |

PSR Shell encode (Programming Standards Reference): ShellCheck, shfmt, quote expansions, explicit failure (`set -euo pipefail`), safe temp files, tests for filenames / signals / empty. Primary authority: POSIX / bash manuals, ShellCheck wiki.

Compose with `/poteto-mode`. Tier 0.5 runs live ShellCheck + shfmt when tools are on PATH.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/shell-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-shell` (Shell stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`sh-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `sh-hotpath-gate` fails if that wall exceeds `SH_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and ohmyzsh under default budget.

### Escape

Line marker `sh-rg-allow` with a short rationale. Prefer named boundaries from `templates/safe_temp.sh` / `templates/quoted_expand.sh` over scattered allows.

## Selfcheck

`bash scripts/sh-kit-selfcheck.sh` proves rg/hotpath/fmt/shellcheck/strict/test gates discriminate fixtures, single-walk encode, budget discrimination (`SH_RG_BUDGET_MS=1`), and template presence.
