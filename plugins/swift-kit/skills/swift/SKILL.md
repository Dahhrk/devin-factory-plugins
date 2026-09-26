---
name: swift
description: Swift PSR bar. swift-format/SwiftFormat, SwiftLint, no force unwrap, no try!, no unchecked unsafe pointers. Use when reading or editing any .swift in a factory product.
paths: ["**/*.swift", "**/.swift-format", "**/.swiftformat", "**/.swiftlint.yml", "**/.swiftlint.yaml", "**/Package.swift", "**/.github/workflows/**"]
---

# Swift

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference Swift checks into product gates.

## PSR Swift (encoded)

1. **Agreed formatter** — swift-format or SwiftFormat (`.swift-format` / `.swiftformat`). Gate: `scripts/swift-fmt-gate.sh`. Starter: `templates/.swift-format`.
2. **SwiftLint** — `.swiftlint.yml` / CI wiring. Gate: `scripts/swift-lint-gate.sh` (wiring); run SwiftLint in product CI when the host supports it.
3. **force unwrap** — no postfix `!` / IUO without allow. Prefer `if let` / `guard let` / `??`. Gate: `scripts/swift-rg-gate.sh` (single-walk). Template: `templates/optional_bind.swift`.
4. **try!** — no `try!` without allow. Prefer `try` / `Result`. Gate: `scripts/swift-rg-gate.sh`.
5. **unsafe pointers** — no `Unsafe*Pointer` / `withUnsafe*` / `assumingMemoryBound` without allow on a named boundary. Gate: `scripts/swift-rg-gate.sh`. Template: `templates/safe_pointer.swift`.
6. **Hot-path** — `scripts/swift-hotpath-gate.sh` fails if rg-gate wall exceeds `SWIFT_RG_BUDGET_MS` (default 250ms).

## Rules

- `swift-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)

Gates: pack README. Poteto EXIT: skill **poteto-swift**.
