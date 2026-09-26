---
name: ada
description: Ada PSR bar. No Unchecked_Conversion, no pragma Suppress, gnatcheck/gnatpp wiring. Use when reading or editing any .ads/.adb in a factory product.
paths: ["**/*.ads", "**/*.adb", "**/*.ada", "**/*.gpr", "**/gnatcheck.rules", "**/.github/workflows/**"]
---

# Ada

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Ada checks into product gates.

## PSR Ada (encoded)

1. **No Unchecked_Conversion** — ban `Ada.Unchecked_Conversion` / `Unchecked_Conversion` instantiations and withs. Gate: `scripts/ada-rg-gate.sh` (single-walk). Template: `templates/no_unchecked_conversion.ads`.
2. **No pragma Suppress** — ban `pragma Suppress (...)` in product Ada. Prefer keeping checks; handle `Constraint_Error`. Gate: `scripts/ada-rg-gate.sh`. Template: `templates/no_suppress.adb`.
3. **Hot-path** — `scripts/ada-hotpath-gate.sh` fails if rg-gate wall exceeds `ADA_RG_BUDGET_MS` (default 250ms).
4. **gnatcheck / gnatpp wiring** — `.gpr` `package Check` and/or `package Pretty_Printer`, `gnatcheck.rules` with `--+Unchecked_Conversions` (not `---`), or CI `gnatcheck`/`gnatpp`. Gate: `scripts/ada-gnat-gate.sh`. Templates: `templates/product.gpr`, `templates/gnatcheck.rules`.

## Rules

- `ada-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)
- `Unchecked_Deallocation` for controlled freestore is out of this Tier 0 bar (focus: Unchecked_Conversion + Suppress)

Gates: pack README. Poteto EXIT: skill **poteto-ada**.
