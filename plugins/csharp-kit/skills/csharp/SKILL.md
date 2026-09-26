---
name: csharp
description: C# PSR bar. dotnet format / .editorconfig, Roslyn analyzers, nullable enable, no Console.WriteLine in libs, no SQL string concat, no blocking on async. Use when reading or editing any .cs / .csproj / Directory.Build.props in a factory product.
paths: ["**/*.cs", "**/*.csproj", "**/Directory.Build.props", "**/Directory.Build.targets", "**/.editorconfig", "**/*.sln", "**/.github/workflows/**"]
---

# C#

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference C# checks into product gates.

## PSR C# (encoded)

1. **Agreed formatter** — `dotnet format` / `.editorconfig` csharp style (CSharpier accepted). Gate: `scripts/csharp-fmt-gate.sh`. Starter: `templates/editorconfig/.editorconfig`.
2. **Roslyn analyzers where practical** — `EnableNETAnalyzers` / `AnalysisLevel` / `.editorconfig` `dotnet_analyzer_*`. Gate: `scripts/csharp-analyzers-gate.sh` (wiring); run analyzers in product CI when the host supports it.
3. **Nullable enable** — `<Nullable>enable</Nullable>` or `#nullable enable`. Gate: `scripts/csharp-nullable-gate.sh`. Starter: `templates/Directory.Build.props`.
4. **Console.WriteLine in libs** — no `Console.Write` / `Console.WriteLine` / `Console.Error.Write` without allow. Prefer `ILogger` / `ILogger<T>`. Gate: `scripts/csharp-rg-gate.sh` (single-walk). Template: `templates/logger_not_console.cs`.
5. **SQL/string concat** — no `"SELECT..."` + / + `" WHERE..."` into queries. Prefer parameterized `SqlCommand` / Dapper. Gate: `scripts/csharp-rg-gate.sh`. Template: `templates/parameterized_command.cs`.
6. **Blocking on async** — no `.Result` / `.Wait(` / `GetAwaiter().GetResult()` without allow. Prefer `await`. Gate: `scripts/csharp-rg-gate.sh`.
7. **Hot-path** — `scripts/csharp-hotpath-gate.sh` fails if rg-gate wall exceeds `CSHARP_RG_BUDGET_MS` (default 250ms).

## Rules

- `csharp-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-csharp**.
