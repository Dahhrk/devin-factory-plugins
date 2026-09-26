---
name: objc
description: Objective-C PSR bar. clang-format, ARC (no manual retain/release/autorelease), no NSLog in libs, no performSelector: smells. Use when reading or editing any .m/.h/.mm in a factory product.
paths: ["**/*.m", "**/*.h", "**/*.mm", "**/.clang-format", "**/.github/workflows/**"]
---

# Objective-C

Apply pstack **principle-encode-lessons-in-structure** first. This skill encodes Programming Standards Reference ObjC checks into product gates.

## PSR ObjC (encoded)

1. **No NSLog in libs** — ban `NSLog(...)` in product / shared library sources. Prefer `os_log` or an injected logger. Gate: `scripts/objc-rg-gate.sh` (single-walk). Template: `templates/no_nslog.m`.
2. **No performSelector: smells** — ban `performSelector:` / `performSelectorOnMainThread:` / `performSelectorInBackground:` / `performSelectorOnThread:`. Prefer typed methods, blocks, or proven IMP. Gate: `scripts/objc-rg-gate.sh`. Template: `templates/no_perform_selector.m`.
3. **ARC over manual retain** — ban `[obj retain]` / `[obj release]` / `[obj autorelease]` message sends. Prefer ARC; document CF bridge with allow. Gate: `scripts/objc-rg-gate.sh`. Template: `templates/no_manual_retain.m`.
4. **Hot-path** — `scripts/objc-hotpath-gate.sh` fails if rg-gate wall exceeds `OBJC_RG_BUDGET_MS` (default 250ms).
5. **clang-format wiring** — `.clang-format` (or CI `clang-format`). Gate: `scripts/objc-fmt-gate.sh`. Template: `templates/.clang-format`.

## Rules

- `objc-rg-allow` on the same line as the smell, with a short rationale
- Smallest correct change; no invent handlers for score
- No disable/skip/weaken of gates to force green (PSR AI rule 11)
- CFRetain / CFRelease for CoreFoundation bridging is out of this Tier 0 bar (focus: ObjC MRC messages + NSLog + performSelector)

Gates: pack README. Poteto EXIT: skill **poteto-objc**.
