# cursor-team-kit

Devin conversion of the public MIT-licensed
[cursor-team-kit](https://github.com/cursor/plugins/tree/main/cursor-team-kit)
Cursor plugin by Eric Zakariasson / Cursor (v1.2.0, cursor/plugins@`f5bdd68`).
Not affiliated with or endorsed by Cursor — see
[`../../NOTICE.md`](../../NOTICE.md).

Skills resolve as `/cursor-team-kit:<skill>`, e.g.
`/cursor-team-kit:deslop`, `/cursor-team-kit:verify-this`.

## Caveats

- `rules/` are always-on and TypeScript-flavored; drop or scope them if a repo
  is not TypeScript.
- Shipping-flavored skills (`review-and-ship`, `new-branch-and-pr`,
  `loop-on-ci`) assume merge authority. In the dark factory they stop at a
  draft PR — Riddler → Gordon → human plate.
- `agents/` subagents are CLI/Desktop-only in Devin today.
- `control-cli` / `control-ui` expect the upstream team's local tooling; use
  them as patterns unless that tooling exists in the repo.
- `assets/avatar.png` is upstream's plugin avatar, kept for tree parity; the
  Devin manifest does not reference it.
