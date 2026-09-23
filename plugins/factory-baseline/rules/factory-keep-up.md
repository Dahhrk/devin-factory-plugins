# Factory keep-up

Standing routine that keeps the factory repos aligned.

## Twins

- Kitchen: `Dahhrk/dark-factory`.
- Devin plugin pack: `Dahhrk/devin-factory-plugins` (this repo).
- Cursor pack twin: `Dahhrk/plug-factory` (private). Packs live at repo root:
  `pstack/`, `cursor-team-kit/`.

The twins carry shared conventions and overlapping packs, skills, and rules.
They stay mirrored.

Product repos consume packs only. They do not host factory conventions.
DevinGo stays `Dahhrk/devin-go` only (not the kitchen, not this pack).

## Cadence

Weekdays, 10:30 AM Europe/London. Silent when clean: no report when the
twins agree and no drift is found.

## What runs

1. Refresh all three mains from GitHub, including `Dahhrk/plug-factory`.
2. Compare convention mirrors. At minimum
   `plugins/factory-baseline/rules/language-conventions.md` in this pack
   against `docs/language-conventions.md` in the kitchen.
3. Run `scripts/drift-check.mjs` from this repo against the Cursor pack twin
   checkout in hard-fail mode, every run. The checkout is `PLUG_FACTORY_REPO`
   or `~/Projects/plug-factory`; that naming stays valid. A missing checkout
   is a setup failure to fix, not a step to skip. The advisory `--content`
   pass alone never opens a PR.

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

## CI secret

Devin CI prefers private `Dahhrk/plug-factory` when
`secrets.PLUG_FACTORY_TOKEN` (or `PLUG_FACTORY_READ_TOKEN`) is set. When
unset, validate drifts against public `Dahhrk/plugins` and prints a
warning so the job stays green. Add the read token on the Devin pack repo
when private-twin drift should be the hard path.

## Pointer

Language rules and the mirror contract live in
[language-conventions.md](language-conventions.md), Anti-drift.
