# swift-kit

Swift bar for the dark factory Cursor lane. Public research pilot: apple/swift-nio (Apache-2.0).

| Surface | Path |
|---------|------|
| Skills | `skills/swift`, `skills/poteto-swift` |
| Rule | `rules/swift.mdc` (`**/*.swift`, not alwaysApply) |
| Tier 0 | `scripts/swift-rg-gate.sh` (force unwrap; try!; unsafe pointers; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/swift-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `SWIFT_RG_BUDGET_MS`) |
| Tier 0.5 | `scripts/swift-fmt-gate.sh` (swift-format / SwiftFormat wiring / live) |
| Tier 1 | `scripts/swift-lint-gate.sh` (SwiftLint wiring) |
| Selfcheck | `scripts/swift-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/swift-gates.yml` + `templates/.swift-format` / `templates/.swiftlint.yml` |
| Boundaries | `templates/optional_bind.swift`, `templates/safe_pointer.swift` |

PSR Swift encode (Programming Standards Reference): swift-format or SwiftFormat; SwiftLint; no force unwrap without allow; no `try!` without allow; no unsafe pointers without named boundary. Primary authority: Swift language guide and Apple / swiftlang tooling (swift-format, SwiftLint).

Compose with `/poteto-mode`. Tier 0.5 fmt checks wiring (live `swift format` / `swift-format` when on PATH unless `SWIFT_FMT_CONFIG_ONLY=1`). Lint gate checks SwiftLint config / CI wiring.

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/swift-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-swift` (Swift stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`swift-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `swift-hotpath-gate` fails if that wall exceeds `SWIFT_RG_BUDGET_MS` (default 250ms). Measured 2026-09-26 Europe/London: good fixture and apple/swift-nio (NIOCore+NIOPosix+NIOEmbedded Sources) under default budget.

### Escape

Line marker `swift-rg-allow` with a short rationale. Prefer named boundaries from `templates/optional_bind.swift` / `templates/safe_pointer.swift` over scattered allows.

## Selfcheck

`bash scripts/swift-kit-selfcheck.sh` proves rg/hotpath/fmt/lint gates discriminate fixtures, single-walk encode, budget discrimination (`SWIFT_RG_BUDGET_MS=1`), and template presence.
