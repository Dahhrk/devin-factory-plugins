# Factory keep-up

Standing routine that keeps the factory repos aligned.

## Twins

- Kitchen: `Dahhrk/dark-factory`.
- Devin plugin pack: `Dahhrk/devin-factory-plugins` (this repo).
- Cursor pack twin: `Dahhrk/plug-factory` (private). Packs live at repo root:
  `pstack/`, `cursor-team-kit/`.
- ZCode pack twin: `Dahhrk/zcode-factory` (private). ZCode/GLM-5.3 plugin:
  `.zcode-plugin/plugin.json`, `AGENTS.md`, `conventions/`, and flat prefixed
  skills `skills/pstack-<slug>/` and `skills/cursor-team-kit-<slug>/` plus
  `skills/pack-manifest.json`, exported from plug-factory. The conventions
  mirrors stay required.

The twins carry shared conventions and overlapping packs, skills, and rules.
They stay mirrored. Pack write home is `Dahhrk/plug-factory`: pack substance
is authored there and exported to the Devin and ZCode twins.

Product repos consume packs only. They do not host factory conventions.
DevinGo stays `Dahhrk/devin-go` only (not the kitchen, not this pack).

## Cadence

Weekdays, 10:30 AM Europe/London. Silent when clean: no report when the
twins agree and no drift is found.

## What runs

1. Refresh all four mains from GitHub, including `Dahhrk/plug-factory` and
   `Dahhrk/zcode-factory`.
2. Compare convention mirrors. At minimum
   `plugins/factory-baseline/rules/language-conventions.md` in this pack
   against `docs/language-conventions.md` in the kitchen.
3. Run `scripts/drift-check.mjs` in hard-fail mode every run. Prefer this
   repo against the Cursor pack twin checkout (`PLUG_FACTORY_REPO` or
   `~/Projects/plug-factory`). The reverse check can also run from
   `plug-factory` once its scripts exist, or from this tree with
   `PLUG_FACTORY_REPO` set. A missing checkout is a setup failure to fix,
   not a step to skip. The advisory `--content` pass alone never opens a
   PR. Devin CI uses `secrets.PLUG_FACTORY_TOKEN` (or
   `PLUG_FACTORY_READ_TOKEN`) when set; otherwise it falls back to public
   `Dahhrk/plugins` with a warning so the job is not bricked.
4. Run the ZCode twin's structural check:
   `node scripts/drift-check.mjs` inside `Dahhrk/zcode-factory`, or from
   this repo with `ZCODE_FACTORY_REPO` (or `--zcode`) pointing at the
   checkout. With `DARK_FACTORY_REPO` set it also compares the conventions
   mirror's section headers against kitchen `docs/language-conventions.md`.
   Missing checkout is a setup failure, not a skip. Private CI read uses
   `ZCODE_FACTORY_TOKEN` (or `ZCODE_FACTORY_READ_TOKEN`) when set.
5. After any plug pack edit, regenerate the ZCode twin with
   `node scripts/export-packs.mjs --target zcode` (and the Devin twin with
   `--target devin` when it is needed), then open mirror PRs on the lagging
   twins. Never merge without Dark. Pack drift is checked with
   `skills/pack-manifest.json` plus a nested compare of the exported skill
   trees. Twin-only adapt files stay on an allowlist so they do not read as
   drift.

## On unexplained drift

Open a mirror PR on the lagging twin. Never merge without Dark.

When the drift is in pack substance, fix it in `Dahhrk/plug-factory` first,
rerun `node scripts/export-packs.mjs --target zcode` (and `--target devin`
when needed), and mirror the export onto the lagging twins.

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
warning so the job stays green. Add the read token on this repo when
private-twin drift should be the hard path.

Private `Dahhrk/zcode-factory` uses `secrets.ZCODE_FACTORY_TOKEN` (or
`ZCODE_FACTORY_READ_TOKEN`). Without that token, validate warns and skips
the ZCode twin check; wire the secret to enforce it.

## Code defaults

Shipping bar: kitchen `docs/factory-code-defaults.md`.

## Pointer

Language rules and the mirror contract live in
[language-conventions.md](language-conventions.md), Anti-drift.
