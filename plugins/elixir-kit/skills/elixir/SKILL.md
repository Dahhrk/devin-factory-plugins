---
name: elixir
description: Elixir PSR bar. mix format, Credo, dialyzer wiring, no String.to_atom on input, no SQL concat, no Process.sleep on hot paths. Use when reading or editing any .ex / .exs in a factory product.
paths: ["**/*.ex", "**/*.exs", "**/mix.exs", "**/.formatter.exs", "**/.credo.exs", "**/.github/workflows/**"]
---

# Elixir

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Elixir checks into product gates.

## PSR Elixir (encoded)

1. **Agreed formatter** — `mix format` (`.formatter.exs` / CI `mix format --check-formatted` / live mix). Gate: `scripts/elixir-fmt-gate.sh`. Product CI: `templates/github-workflows/elixir-gates.yml`.
2. **Credo** — `.credo.exs` and/or `credo` mix dep / CI. Gate: `scripts/elixir-credo-gate.sh` (wiring; not live analyzer run).
3. **dialyzer** — dialyxir / `mix dialyzer` wiring in mix.exs or CI. Gate: `scripts/elixir-dialyzer-gate.sh` (wiring; not live PLT run).
4. **String.to_atom** — no `String.to_atom` on input paths without allow. Prefer `String.to_existing_atom` / allowlisted atoms. Gate: `scripts/elixir-rg-gate.sh` (single-walk). Template: `templates/safe_atom.ex`.
5. **SQL concat** — no SQL literal concat / `#{}` interpolation of values without allow. Prefer Ecto parameterized queries. Gate: `scripts/elixir-rg-gate.sh`. Template: `templates/prepared_query.ex`.
6. **Process.sleep** — no `Process.sleep` on hot paths without allow. Prefer `Process.send_after` / receive / supervised backoff. Gate: `scripts/elixir-rg-gate.sh`.
7. **Hot-path** — `scripts/elixir-hotpath-gate.sh` fails if rg-gate wall exceeds `ELIXIR_RG_BUDGET_MS` (default 250ms).

## Rules

- `elixir-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-elixir**.
