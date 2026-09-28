# Language conventions

Standing rules for factory writing and user-facing docs (Dark, 2026-09-23).

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

Do not label work as Phase N, Slice N, Section N, Wave N, Wave A/B/C, or any similar sequencing letter/number scheme.

In chat, docs, PR titles, and commit titles: use plain work descriptions (what changed), not wave/phase/slice/section labels.

## Prose system

Default writing system is [orwell-prose](https://github.com/Dahhrk/dark-factory/blob/main/docs/orwell-prose.md) (rules 1-12), same
contract shape as one-shot-task. Agents apply automatically on every prose
path; do not wait to be asked. Positive rules that build voice. `unslop` is
a secondary pattern gate, not the main system. Project `AGENTS.md` /
`CLAUDE.md` may override voice.

## Punctuation

No em dashes. Use periods, commas, or parentheses. This is a secondary gate
under orwell-prose, not the writing system itself.

## Keep

Autopilot stays gated until TRUST-NEXT is green. No product secrets in the kitchen.

## Anti-drift

Four seated pack twins stay mirrored for shared conventions and overlapping packs:

- Kitchen: `Dahhrk/dark-factory`
- Devin plugin pack: `Dahhrk/devin-factory-plugins`
- Cursor pack twin: `Dahhrk/plug-factory` (private; packs at repo root)
- ZCode pack twin: `Dahhrk/zcode-factory` (private; thin plugin at repo root)

Kitchen peers (not pack twins): `Dahhrk/claude-factory` (Claude) and `Dahhrk/chatgpt-factory` (ChatGPT), split from deprecated mono `Dahhrk/claude-chatgpt-factory`. Five-lane substance-parity: Cursor + Devin + ZCode + Claude + ChatGPT. Shared kitchen conventions must stay in sync with this kitchen. Pack substance mirrors via lane-native exports into each peer. Weekday Factory Drift includes full pack sync via those exports. Pack hard-check stays on pack twins only. Keep-up set is six repos (includes both peers; mono stub excluded).

DevinGo app remains `Dahhrk/devin-go` only (not kitchen, not a pack twin).

The keep-up routine that checks this mirror is described in
[docs/factory-keep-up.md](factory-keep-up.md).

Each twin must ship lane-native manifests (Cursor `.cursor-plugin`, Devin `.devin-plugin`, ZCode flat skills); Cursor-only trees on Devin are a defect.
