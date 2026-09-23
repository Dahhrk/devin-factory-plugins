# Factory keep-up

Standing routine that keeps the two factory repos aligned.

## Twins

- Kitchen: `Dahhrk/dark-factory`.
- Devin plugin pack: `Dahhrk/devin-factory-plugins` (this repo).

The twins carry shared conventions and overlapping packs, skills, and rules.
They stay mirrored.

Product repos consume packs only. They do not host factory conventions.
DevinGo stays `Dahhrk/devin-go` only (not the kitchen, not this pack).

## Cadence

Weekdays, 10:30 AM Europe/London. Silent when clean: no report when both
twins agree and no drift is found.

## What runs

1. Refresh both mains from GitHub.
2. Compare convention mirrors. At minimum
   `plugins/factory-baseline/rules/language-conventions.md` in this pack
   against `docs/language-conventions.md` in the kitchen.
3. When a Cursor pack twin checkout exists (`PLUG_FACTORY_REPO` or a sibling
   `plug-factory` directory), run `scripts/drift-check.mjs` from this repo in
   hard-fail mode. The advisory `--content` pass alone never opens a PR. If no
   Cursor pack twin is seated, skip that script. That is expected until the
   twin exists.

## On unexplained drift

Open a mirror PR on the lagging twin. Never merge without Dark.

When both sides carry conflicting edits, do not pick a winner. Ask which one
wins, then mirror that choice.

## Never

- Merge without Dark.
- Post publicly outside the PR.
- Enable Autopilot.
- Put secrets in the kitchen.
- Invent evidence.

## Pointer

Language rules and the mirror contract live in
[language-conventions.md](language-conventions.md), Anti-drift.
