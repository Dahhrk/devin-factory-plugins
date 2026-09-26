# powershell-kit

PowerShell bar for the dark factory Cursor lane. Public research pilot: PowerShell/PowerShell (MIT).

| Surface | Path |
|---------|------|
| Skills | `skills/powershell`, `skills/poteto-powershell` |
| Rule | `rules/powershell.mdc` (`**/*.{ps1,psm1,PS1,PSM1}`, not alwaysApply) |
| Tier 0 | `scripts/ps-rg-gate.sh` (Invoke-Expression; Write-Host in modules; unquoted paths; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/ps-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `PS_RG_BUDGET_MS`) |
| Tier 1 | `scripts/ps-pssa-gate.sh` (PSScriptAnalyzer wiring / live; requires PSAvoidUsingInvokeExpression + PSAvoidUsingWriteHost) |
| Selfcheck | `scripts/ps-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/ps-gates.yml` |
| Boundaries | `templates/no_iex.ps1`, `templates/write_output_not_host.psm1`, `templates/quoted_path.ps1` |
| Lint starter | `templates/PSScriptAnalyzerSettings.psd1` |

PSR PowerShell encode (Programming Standards Reference): PSScriptAnalyzer lint; no `Invoke-Expression` without allow; no `Write-Host` in modules without allow; no unquoted path cmdlet args without allow. Primary authority: PSScriptAnalyzer rules (`PSAvoidUsingInvokeExpression`, `PSAvoidUsingWriteHost`) and path-quoting trust bar.

Compose with `/poteto-mode`. Tier 1 PSScriptAnalyzer checks wiring (live `Invoke-ScriptAnalyzer` when pwsh + module on PATH unless `PS_PSSA_CONFIG_ONLY=1`). Config must keep PSAvoidUsingInvokeExpression and PSAvoidUsingWriteHost enabled (not excluded).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/powershell-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-powershell` (PowerShell stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`ps-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `ps-hotpath-gate` fails if that wall exceeds `PS_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and PowerShell research fixtures under default budget.

### Escape

Line marker `ps-rg-allow` with a short rationale. Prefer named boundaries from `templates/no_iex.ps1` / `templates/write_output_not_host.psm1` / `templates/quoted_path.ps1` over scattered allows.

## Selfcheck

`bash scripts/ps-kit-selfcheck.sh` proves rg/hotpath/pssa gates discriminate fixtures, single-walk encode, budget discrimination (`PS_RG_BUDGET_MS=1`), PSR PSScriptAnalyzer rules bar, and template presence.
