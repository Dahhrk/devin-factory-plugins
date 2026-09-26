---
name: vbnet
description: Visual Basic .NET PSR bar. On Error Resume Next banned, Option Strict Off banned, Console.WriteLine banned in libs, dotnet/vbproj wiring. Use when reading or editing any .vb/.vbproj in a factory product.
paths: ["**/*.vb", "**/*.vbproj", "**/Directory.Build.props", "**/.github/workflows/**"]
---

# Visual Basic .NET

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Visual Basic .NET checks into product gates.

## PSR Visual Basic .NET (encoded)

1. **On Error Resume Next** — no `On Error Resume Next` without allow. Prefer `Try` / `Catch` / `Finally`. Gate: `scripts/vbnet-rg-gate.sh` (single-walk). Template: `templates/no_on_error_resume_next.vb`.
2. **Option Strict Off** — no `Option Strict Off` and no `<OptionStrict>Off</OptionStrict>` in `.vbproj` without allow. Prefer `Option Strict On`. Gate: `scripts/vbnet-rg-gate.sh`. Template: `templates/option_strict_on.vb`.
3. **Console.WriteLine in libs** — no `Console.Write` / `WriteLine` / `Error.Write(Line)` in library `.vb`. Prefer `ILogger` / `Trace` / `Debug`. CLI `Program.vb` may Console with allow when intentional. Gate: `scripts/vbnet-rg-gate.sh`. Template: `templates/logger_not_console.vb`.
4. **Hot-path** — `scripts/vbnet-hotpath-gate.sh` fails if rg-gate wall exceeds `VBNET_RG_BUDGET_MS` (default 250ms).
5. **dotnet / vbproj wiring** — `.vbproj` and/or CI mentioning `dotnet` build/restore. Gate: `scripts/vbnet-dotnet-gate.sh`. Product CI: `templates/github-workflows/vbnet-gates.yml`.

## Rules

- `vbnet-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-vbnet**.
