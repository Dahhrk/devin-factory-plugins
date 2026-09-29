# Dark factory — Devin coding lane

Devin drafts; humans plate.

- Non-trivial engineering work starts in `/poteto-mode` — observe, name the data shape, smallest correct diff, verify against the real artifact, hand off with Done means + Keep.
- Default: every prose surface is orwell-prose (docs, PRs, commits, chat reports, landing copy; rules 1-12). Agents apply before delivery; do not wait to be asked. `/orwell-prose` names the contract. `unslop` and no-em-dash stay secondary. Project `AGENTS.md` / `CLAUDE.md` may override voice.
- Default: every `ui:yes` / Figma ask starts from the existing design system plus one approved keyframe, expands the full flow in Figma, proves visual parity, gets a frontend look, then encodes. Fail closed without system, keyframe, or Figma access. `/figma-from-system` names the contract.
- Default: every new product idea opens a temporary product/design/engineering debate room (plain product name), captures requirements and the decision in writing, then closes the room before encode. `/product-debate` names the contract.
- Default: before any non-trivial ask, restate Goal / Constraints / Done means / Keep in plain words, then act (`outcome-repeat-back`). Cuts dump→wrong-build. Agents start here automatically; `/outcome-repeat-back` names the contract.
- Default: exit with a mergeable artifact (PR, brief, scorecard, verified claim). Never end with a "you should…" homework list (`results-not-homework`). Agents apply on close; `/results-not-homework` names the contract.
- Default: when an ask spans multiple workstreams (frontend, backend, research, docs, CI, review, QA), run parent + specialists with clear ownership, an ordered plate with merge holds, and parent waits on children (`fleet-orchestrate`). Shared box filesystem OK; memory stays per-agent. Verify before merge. Plain workstream names only. Agents start here automatically; `/fleet-orchestrate` names the contract. Opt-in poteto playbook: `playbooks/fleet-orchestrate.md`.
- Default: after a pass, if the same manual flow recurred twice, offer skill-authoring / learn-from-demonstration once; drop if declined (`teach-to-skill`). Agents apply as a post-pass; `/teach-to-skill` names the contract.
- Default: falsifiable "done" claims and substance merge claims need fresh `verify-this` evidence before ship. Recap is not evidence.
- Draft PRs only. Never merge, never enable Autopilot.
- Proof order: Riddler → Gordon → human plate. The author never plates.
- Harvey Specter is Cos (outer loop). Devin is the coding lane, not Cos.
- One verifiable unit per PR, with **Done means** and **Keep** written down.
- No secrets and no product Feature Maps in the public kitchen.
