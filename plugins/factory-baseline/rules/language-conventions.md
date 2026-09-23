# Language conventions

Standing rules for factory writing and user-facing docs (Dark, 2026-09-23). Keep mirrored with Dahhrk/dark-factory docs/language-conventions.md.

## Names

Name workstreams with plain nouns only:

- frontend
- backend
- mobile
- design
- CI
- review
- QA
- registry

Do not use bot persona names.
Do not use role titles.

## Work labels

Prefer: foundation, increment, PR, milestone, backlog.

Do not label work as Phase N, Slice N, or Section N.

## Punctuation

No em dashes. Use periods, commas, or parentheses.

## Keep

Autopilot stays gated until TRUST-NEXT is green. No product secrets in the kitchen.

## Anti-drift

Three seated twins stay mirrored for shared conventions and overlapping packs:

- Kitchen: `Dahhrk/dark-factory`
- Devin plugin pack: `Dahhrk/devin-factory-plugins` (this repo)
- Cursor pack twin: `Dahhrk/plug-factory` (private; packs at repo root)

DevinGo app remains `Dahhrk/devin-go` only (not kitchen, not a pack twin).

The keep-up routine that checks this mirror is described in
[factory-keep-up.md](factory-keep-up.md).
