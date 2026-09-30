# cursor-team-kit

Devin conversion of the public MIT-licensed
[cursor-team-kit](https://github.com/cursor/plugins/tree/main/cursor-team-kit)
Cursor plugin by Eric Zakariasson / Cursor (v1.2.0, cursor/plugins@`f5bdd68`).
Not affiliated with or endorsed by Cursor — see
[`../../NOTICE.md`](../../NOTICE.md).

Skills resolve as `/cursor-team-kit:<skill>`, e.g.
`/cursor-team-kit:deslop`, `/cursor-team-kit:verify-this`,
`/cursor-team-kit:one-shot-task`, `/cursor-team-kit:orwell-prose`, `/cursor-team-kit:figma-from-system`, `/cursor-team-kit:product-debate`, `/cursor-team-kit:outcome-repeat-back`, `/cursor-team-kit:results-not-homework`, `/cursor-team-kit:fleet-orchestrate`, `/cursor-team-kit:teach-to-skill`, `/cursor-team-kit:leave-machine-clean`, `/cursor-team-kit:routine-by-default`, `/cursor-team-kit:harness-not-training`, `/cursor-team-kit:software-factory-gates`, `/cursor-team-kit:design-eng`, `/cursor-team-kit:design-control-loop`, `/cursor-team-kit:improve-agents-md`, `/cursor-team-kit:grill-me`, `/cursor-team-kit:refactor-first`, `/cursor-team-kit:inference-perf`.

**Default:** every non-trivial ask is a one-shot task. Agents start on
that route automatically (vague → `poteto-prompt` → `poteto-mode`;
structured → `poteto-mode` with Done means + Keep; until-X on this lane →
verifiable units + re-invoke, no fake Cursor `/loop`). Typing
`/cursor-team-kit:one-shot-task` is optional; the skill names the
contract. Autopilot and TRUST-NEXT stay off unless already greened.

**Default (prose):** every docs, PR, commit, chat report, and landing line
runs through `orwell-prose` (rules 1-12) before delivery. Agents apply
automatically; do not wait to be asked. Typing `/cursor-team-kit:orwell-prose`
is optional; the skill names the contract. Same shape as one-shot-task.
`unslop` and no-em-dash stay secondary.

**Default (UI / Figma):** every `ui:yes` / Figma ask starts from the existing
design system plus one approved keyframe, expands the full flow in Figma,
proves visual parity, gets a frontend look, then encodes. Fail closed without
system, keyframe, or Figma access. Typing `/cursor-team-kit:figma-from-system`
is optional; the skill names the contract.

**Default (new product idea):** every new product idea opens a temporary
product/design/engineering debate room (plain product name), captures
requirements and the decision in writing, then closes the room before encode.
Typing `/cursor-team-kit:product-debate` is optional; the skill names the
contract.

**Default (repeat-back):** before any non-trivial ask, restate Goal /
Constraints / Done means / Keep in plain words, then act. Typing
`/cursor-team-kit:outcome-repeat-back` is optional; the skill names the
contract.

**Default (exit):** leave a mergeable artifact (PR, brief, scorecard,
verified claim). Never end with a "you should…" homework list. Typing
`/cursor-team-kit:results-not-homework` is optional; the skill names the
contract.

**Default (multi-workstream):** when an ask spans multiple workstreams, run
parent + specialists with clear ownership, an ordered plate with merge holds,
and parent waits on children. Verify before merge. Typing
`/cursor-team-kit:fleet-orchestrate` is optional; the skill names the
contract.

**Default (post-pass):** if the same manual flow recurred twice, offer
skill-authoring / learn-from-demonstration once; drop if declined. Typing
`/cursor-team-kit:teach-to-skill` is optional; the skill names the contract.

**Default (leave clean):** kill orphaned local agent children before you stop;
mid-session `/cursor-team-kit:leave-machine-clean` reclaims session orphans
only. Cap parallel local workstreams; prefer remote for heavy verify. Typing
`/cursor-team-kit:leave-machine-clean` is optional; the skill names the
contract.

**Default (routine):** when an ask is recurring, scheduled, "let me know when",
or about to be re-asked, create or update a routine/automation. Typing
`/cursor-team-kit:routine-by-default` is optional; the skill names the
contract.

**Default (harness):** capability / agent / bot / AI product work ships
harnesses, evals, and delivery paths, not frontier training. Train only when
Dark explicitly asks. Typing `/cursor-team-kit:harness-not-training` is
optional; the skill names the contract.

**Default (verify):** falsifiable "done" and substance merge claims need
fresh `verify-this` evidence before ship.

**Default (factory gates):** non-trivial multi-file feature work passes
`software-factory-gates` (Product, Architecture, Program Design, Build Order)
with explicit user approval at each gate before implementation. Trivial
one-liners skip. Typing `/cursor-team-kit:software-factory-gates` is optional;
the skill names the contract.

**Default (design-eng):** UI and animation work applies `design-eng` taste and
runs `review-animations` before ship. Vague motion feedback applies
`animation-vocabulary` first. Typing `/cursor-team-kit:design-eng` is optional;
the skill names the contract.

**Default (control loop):** new agent loop, overnight automation, or
feedback-driven system applies `design-control-loop`
(sensor/controller/actuator/disturbances) before implementation. Typing
`/cursor-team-kit:design-control-loop` is optional; the skill names the
contract.

**Default (agents-md):** AGENTS.md drift or rewrite applies `improve-agents-md`
for structured instruction blocks. Typing `/cursor-team-kit:improve-agents-md`
is optional; the skill names the contract.

**Default (refactor-first):** non-trivial behavior changes in existing modules
follow refactor-first (behavior-preserving cleanup with tests green, then the
change on the clean structure). Never both in one unverifiable diff. Typing
`/cursor-team-kit:refactor-first` is optional; the skill names the contract.

Factory skills also include `factory-init`, `seat-kit`, `factory-status`,
and `merge-queue` when present.

## Caveats

- `rules/` are always-on and TypeScript-flavored; drop or scope them if a repo
  is not TypeScript.
- Shipping-flavored skills (`review-and-ship`, `new-branch-and-pr`,
  `loop-on-ci`) assume merge authority. In the dark factory they stop at a
  draft PR — Riddler → Gordon → human plate.
- `agents/` subagents are CLI/Desktop-only in Devin today. `ci-watcher` keeps
  upstream's `model: fast` pin; `thermo-nuclear-code-quality-review` pins
  `claude-fable-5-1-high` per the pstack Devin model map
  (`../pstack/rules/pstack-models.md`).
- `control-cli` / `control-ui` expect the upstream team's local tooling; use
  them as patterns unless that tooling exists in the repo.
- `assets/avatar.png` is upstream's plugin avatar, kept for tree parity; the
  Devin manifest does not reference it.
