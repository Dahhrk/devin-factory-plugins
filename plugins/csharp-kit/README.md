# csharp-kit

C# bar for the dark factory Cursor lane. Public research pilot: dotnet/runtime (MIT), bounded to System.Text.Json.

| Surface | Path |
|---------|------|
| Skills | `skills/csharp`, `skills/poteto-csharp` |
| Rule | `rules/csharp.mdc` (`**/*.{cs,csproj,props,targets,sln}`, not alwaysApply) |
| Tier 0 | `scripts/csharp-rg-gate.sh` (Console.Write/WriteLine in libs; SQL string concat; blocking on async; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/csharp-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `CSHARP_RG_BUDGET_MS`) |
| Tier 0.5 | `scripts/csharp-fmt-gate.sh` (dotnet format / .editorconfig csharp style wiring) |
| Tier 1 | `scripts/csharp-analyzers-gate.sh` (EnableNETAnalyzers / AnalysisLevel / Roslyn wiring) |
| Tier 1 | `scripts/csharp-nullable-gate.sh` (`<Nullable>enable</Nullable>` / `#nullable enable`) |
| Selfcheck | `scripts/csharp-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/csharp-gates.yml` + `templates/editorconfig/.editorconfig` + `templates/Directory.Build.props` |
| Boundaries | `templates/parameterized_command.cs`, `templates/logger_not_console.cs` |

PSR C# encode (Programming Standards Reference): `.editorconfig` / Roslyn analyzers / `dotnet format`; nullable reference analysis; no SQL/string concatenation into queries; no `Console.WriteLine` product logging in libraries; avoid blocking on asynchronous operations. Primary authority: C# language and feature specifications, .NET design guidance.

Compose with `/poteto-mode`. Tier 0.5 fmt checks wiring (live `dotnet format --verify-no-changes` when on PATH unless `CSHARP_FMT_CONFIG_ONLY=1`). Analyzers / nullable gates check wiring or project/source presence.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/csharp-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-csharp` (C# stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`csharp-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `csharp-hotpath-gate` fails if that wall exceeds `CSHARP_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and runtime System.Text.Json under default budget.

### Escape

Line marker `csharp-rg-allow` with a short rationale. Prefer named boundaries from `templates/parameterized_command.cs` / `templates/logger_not_console.cs` over scattered allows.

## Selfcheck

`bash scripts/csharp-kit-selfcheck.sh` proves rg/hotpath/fmt/analyzers/nullable gates discriminate fixtures, single-walk encode, budget discrimination (`CSHARP_RG_BUDGET_MS=1`), and template presence.
