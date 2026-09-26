# objc-kit

Objective-C bar for the dark factory Cursor lane. Public research pilot: SDWebImage/SDWebImage (MIT, active). AFNetworking/AFNetworking suggested (MIT) but **archived** (last push 2023-01) — similar active MIT host preferred.

| Surface | Path |
|---------|------|
| Skills | `skills/objc`, `skills/poteto-objc` |
| Rule | `rules/objc.mdc` (`**/*.{m,h,mm,hpp}`, not alwaysApply) |
| Tier 0 | `scripts/objc-rg-gate.sh` (NSLog; performSelector; manual retain/release/autorelease; **single-walk**; requires **rg**) |
| Tier 0.5 | `scripts/objc-hotpath-gate.sh` (wall-clock budget for rg-gate; default **250ms**; override `OBJC_RG_BUDGET_MS`) |
| Tier 1 | `scripts/objc-fmt-gate.sh` (clang-format wiring / live dry-run) |
| Selfcheck | `scripts/objc-kit-selfcheck.sh` |
| Product CI | `templates/github-workflows/objc-gates.yml` |
| Boundaries | `templates/no_nslog.m`, `templates/no_perform_selector.m`, `templates/no_manual_retain.m`, `templates/.clang-format` |

PSR ObjC encode (Programming Standards Reference): clang-format; ARC (no manual retain/release/autorelease); no NSLog in library code; no performSelector: smells. Primary authority: portable trust bar for Cocoa / GNUstep product trees. Formatter: **clang-format** required (wiring at 0.1.0; live when on PATH).

Compose with `/poteto-mode`. Tier 1 fmt checks wiring (config-only at 0.1.0 unless `clang-format` on PATH).

Write home: this repo. Mirrors: `Dahhrk/devin-factory-plugins` (`plugins/objc-kit`), `Dahhrk/zcode-factory` (exported skills).

Standing scorecard: `skills/poteto-objc` (ObjC stacks; Facepunch is Lua-only).

PR titles and user-facing labels: plain work descriptions only (never `pass N` / `full-pass-N` / `poteto pass`).

### Hot-path

`objc-rg-gate` walks the tree **once** (union of smell patterns), then classifies the hit set. `objc-hotpath-gate` fails if that wall exceeds `OBJC_RG_BUDGET_MS` (default 250ms).

### Escape

Line marker `objc-rg-allow` with a short rationale. Prefer named boundaries from `templates/no_nslog.m` / `templates/no_perform_selector.m` / `templates/no_manual_retain.m` over scattered allows. CFRetain/CFRelease for CoreFoundation bridging stay out of this Tier 0 bar (focus: ObjC MRC message sends + NSLog + performSelector).

## Selfcheck

`bash scripts/objc-kit-selfcheck.sh` proves rg/hotpath/fmt gates discriminate fixtures, single-walk encode, budget discrimination (`OBJC_RG_BUDGET_MS=1`), clang-format wiring bar, and template presence.
