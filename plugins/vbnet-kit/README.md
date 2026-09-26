# vbnet-kit

Visual Basic .NET bar for the dark factory Cursor lane. Public research pilot: CommunityVB/Community.VisualBasic (MIT, Microsoft-compatible Community Visual Basic library). Corroboration: Lake1059/FFmpegFreeUI (MIT, active VB.NET desktop; Console.WriteLine surface in Updater).

| Surface | Path |
|---------|------|
| Skills | `skills/vbnet`, `skills/poteto-vbnet` |
| Rule | `rules/vbnet.mdc` (`**/*.{vb,vbproj}`, not alwaysApply) |
| Tier 0 | `scripts/vbnet-rg-gate.sh` (On Error Resume Next; Option Strict Off; Console.WriteLine in libs; **single-walk**; requires **rg** + PCRE `-P`) |
| Tier 0.5 | `scripts/vbnet-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `VBNET_RG_BUDGET_MS`) |
| Tier 1 | `scripts/vbnet-dotnet-gate.sh` (.NET `dotnet` / `.vbproj` Makefile/CI wiring) |
| Selfcheck | `scripts/vbnet-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/vbnet-gates.yml` |
| Boundaries | `templates/no_on_error_resume_next.vb`, `templates/option_strict_on.vb`, `templates/logger_not_console.vb` |

PSR Visual Basic .NET encode (Programming Standards Reference): no `On Error Resume Next`; no `Option Strict Off` (file or `<OptionStrict>Off</OptionStrict>`); `Console.Write` / `WriteLine` banned in library modules (CLI `Program.vb` may Console with allow). Primary authority: portable trust bar for VB.NET product trees. Toolchain: **dotnet** / **.vbproj** wiring required at 0.1.0.

Compose with `/poteto-mode`. Tier 1 dotnet checks wiring (config-only at 0.1.0).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/vbnet-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-vbnet` (Visual Basic .NET stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`vbnet-rg-gate` walks the tree **once** (union of line smells), classifies the hit set in parallel. `vbnet-hotpath-gate` fails if that wall exceeds `VBNET_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `vbnet-rg-allow` with a short rationale. Prefer named boundaries from `templates/no_on_error_resume_next.vb` / `templates/option_strict_on.vb` / `templates/logger_not_console.vb` over scattered allows.

## Selfcheck

`bash scripts/vbnet-kit-selfcheck.sh` proves rg/hotpath/dotnet gates discriminate fixtures, single-walk encode, budget discrimination (`VBNET_RG_BUDGET_MS=1`), dotnet wiring bar, and template presence.
