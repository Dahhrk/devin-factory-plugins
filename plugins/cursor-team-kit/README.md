# Cursor Team Kit plugin

Internal-style workflows for CI, code review, shipping, and test reliability. The kit is designed to be plug and play without requiring third-party service integrations.

**Default:** every non-trivial ask is a one-shot task. Agents start on that route automatically (vague → `poteto-prompt` → `poteto-mode`; structured → `poteto-mode` with Done means + Keep; until-X on Cursor → autonomous-run + built-in `/loop`). Typing `/one-shot-task` is optional; the skill names the contract.

**Default (prose):** every docs, PR, commit, chat report, and landing line runs through `orwell-prose` (rules 1-12) before delivery. Agents apply automatically; do not wait to be asked. Typing `/orwell-prose` is optional; the skill names the contract. Same shape as one-shot-task. `unslop` and no-em-dash stay secondary.

**Default (UI / Figma):** every `ui:yes` / Figma ask starts from the existing design system plus one approved keyframe, expands the full flow in Figma, proves visual parity, gets a frontend look, then encodes. Fail closed without system, keyframe, or Figma access. Typing `/figma-from-system` is optional; the skill names the contract.

**Default (new product idea):** every new product idea opens a temporary product/design/engineering debate room (plain product name), captures requirements and the decision in writing, then closes the room before encode. Typing `/product-debate` is optional; the skill names the contract.


**Default (repeat-back):** before any non-trivial ask, restate Goal / Constraints / Done means / Keep in plain words, then act. Typing `/outcome-repeat-back` is optional; the skill names the contract.

**Default (exit):** leave a mergeable artifact (PR, brief, scorecard, verified claim). Never end with a "you should…" homework list. Typing `/results-not-homework` is optional; the skill names the contract.

**Default (multi-workstream):** when an ask spans multiple workstreams, or when driving other agents on a desk (prompt / wait / loop / hand-off / review; never answer for the human), run parent + specialists with clear ownership, an ordered plate with merge holds, and parent waits on children. Verify before merge. Typing `/fleet-orchestrate` is optional; the skill names the contract.

**Default (post-pass):** if the same manual flow recurred twice, offer skill-authoring / learn-from-demonstration once; drop if declined. Typing `/teach-to-skill` is optional; the skill names the contract.

**Default (leave clean):** kill orphaned local agent children before you stop; mid-session `/leave-machine-clean` reclaims session orphans only. Cap parallel local workstreams; prefer remote for heavy verify. Typing `/leave-machine-clean` is optional; the skill names the contract.

**Default (routine):** when an ask is recurring, scheduled, "let me know when", or about to be re-asked, create or update a routine/automation. Typing `/routine-by-default` is optional; the skill names the contract.

**Default (harness):** capability / agent / bot / AI product work ships harnesses, evals, and delivery paths, not frontier training. Train only when Dark explicitly asks. Typing `/harness-not-training` is optional; the skill names the contract.

**Default (verify):** falsifiable "done" and substance merge claims need fresh `verify-this` evidence before ship.

**Default (factory gates):** non-trivial multi-file feature work passes `software-factory-gates` (Product, Architecture, Program Design, Build Order) with explicit user approval at each gate before implementation. Trivial one-liners skip. Typing `/software-factory-gates` is optional; the skill names the contract.

**Default (design-eng):** UI and animation work applies `design-eng` taste and runs `review-animations` before ship. Vague motion feedback applies `animation-vocabulary` first. Typing `/design-eng` is optional; the skill names the contract.

**Default (control loop):** new agent loop, overnight automation, or feedback-driven system applies `design-control-loop` (sensor/controller/actuator/disturbances) before implementation. Typing `/design-control-loop` is optional; the skill names the contract.

**Default (agents-md):** AGENTS.md drift or rewrite applies `improve-agents-md` for structured instruction blocks. Typing `/improve-agents-md` is optional; the skill names the contract.

**Default (refactor-first):** non-trivial behavior changes in existing modules follow refactor-first (behavior-preserving cleanup with tests green, then the change on the clean structure). Never both in one unverifiable diff. Typing `/refactor-first` is optional; the skill names the contract.

**Default (progressive-disclosure):** designing or reviewing public APIs, libraries, component props, CLI flags, or SDK surfaces applies progressive-disclosure (zero-config default, complexity opt-in, call-site-first, four layers). Typing `/progressive-disclosure` is optional; the skill names the contract.

**Default (pit-of-success):** public seams apply pit-of-success (obvious call correct; misuse hard; footgun test on the seam). Typing `/pit-of-success` is optional; the skill names the contract.

**Default (zero-tech-debt):** reshaping existing code toward a known target applies zero-tech-debt (delete dead compatibility; rework from the intended end state). Typing `/zero-tech-debt` is optional; the skill names the contract.

**Default (ux-flow-plan):** user-facing feature work applies ux-flow-plan (current vs desired UX flow trees, then file/function anchors). Typing `/ux-flow-plan` is optional; the skill names the contract.

**Default (desk boxes):** box / worktree / session / port / desk-config asks apply `desk-boxes`. Typing `/desk-boxes` is optional; the skill names the contract.

**Default (local preview):** UI or page preview asks apply `local-preview` when a desk is present (reserved port + desk UI); otherwise fall back to `control-ui`. Typing `/local-preview` is optional; the skill names the contract.

**Default (event hooks):** event-hook or before-gate automation applies `event-hooks` (distinct from `software-factory-gates`). Typing `/event-hooks` is optional; the skill names the contract.

**Default (fleet / desk drive):** multi-workstream asks and desk agent drive (prompt / wait / loop / hand-off / review; never answer for the human) stay on `fleet-orchestrate`. No second orchestrate skill.

## Installation

```bash
/add-plugin cursor-team-kit
```

## Components

### Skills

| Skill | Description |
|:------|:------------|
| `one-shot-task` | Default entry for every non-trivial ask (named contract; agents start here automatically) |
| `orwell-prose` | Default writing system for every prose surface (named contract; agents apply automatically, same shape as one-shot-task) |
| `figma-from-system` | Default for ui:yes / Figma work (design system + approved keyframe, fail closed; named contract) |
| `product-debate` | Default for every new product idea before encode (temporary debate room; named contract) |
| `outcome-repeat-back` | Default preamble: restate Goal / Constraints / Done means / Keep, then act (named contract) |
| `results-not-homework` | EXIT check: leave a mergeable artifact; never end with homework (named contract) |
| `fleet-orchestrate` | Default for multi-workstream and desk agent drive (parent + specialists; never answer for the human; named contract) |
| `teach-to-skill` | Post-pass: after the same manual flow twice, offer skill-authoring once (named contract) |
| `leave-machine-clean` | EXIT + on-demand reclaim: tear down local agent children; mid-session census kill (named contract) |
| `routine-by-default` | Default: recurring / scheduled / monitor asks become a routine (named contract) |
| `harness-not-training` | Default: capability / agent / AI product work ships harnesses, not frontier training (named contract) |
| `factory-init` | Onboard a repo into the dark factory (AGENTS, close-loop, gates, then seat kits) |
| `seat-kit` | Detect languages and seat matching language kits (repo gates + plugin) |
| `factory-status` | One-table health sweep across factory repos and runners |
| `merge-queue` | Merge every mergeable open PR across the factory repos (invocation is authorization) |
| `loop-on-ci` | Watch CI runs and iterate on failures until checks pass |
| `review-and-ship` | Run a structured review, commit changes, and open a PR |
| `pr-review-canvas` | Generate an interactive HTML PR walkthrough with annotated, categorized diffs |
| `verify-this` | Prove or disprove claims with baseline/treatment artifacts and a clear verdict |
| `control-cli` | Build or adapt a local harness to drive and profile interactive CLIs or TUIs |
| `control-ui` | Build or adapt a local browser/CDP harness for web or Electron UIs |
| `make-pr-easy-to-review` | Clean noisy PR history, improve descriptions, and add reviewer guidance |
| `run-smoke-tests` | Run Playwright smoke tests and triage failures |
| `fix-ci` | Find failing CI jobs, inspect logs, and apply focused fixes |
| `new-branch-and-pr` | Create a fresh branch, complete work, and open a pull request |
| `get-pr-comments` | Fetch and summarize review comments from the active pull request |
| `check-compiler-errors` | Run compile and type-check commands and report failures |
| `what-did-i-get-done` | Summarize authored commits over a given time period into a concise status update |
| `weekly-review` | Generate a weekly recap of shipped work with bug fix/tech-debt/net-new highlights |
| `fix-merge-conflicts` | Resolve merge conflicts, validate build/tests, and summarize decisions |
| `deslop` | Remove AI-generated code slop and clean up code style |
| `workflow-from-chats` | Extract durable working preferences from chats into skills, rules, or docs |
| `thermo-nuclear-code-quality-review` | Run an unusually strict maintainability review (code-judo, 1k-line rule, spaghetti, boundaries) |
| `software-factory-gates` | Default: four gates (Product, Architecture, Program Design, Build Order) before implementing non-trivial multi-file work (named contract) |
| `design-control-loop` | Default: design agentic control loop (sensor/controller/actuator/disturbances) for iterated or overnight agent work (named contract) |
| `improve-agents-md` | Default: rewrite AGENTS.md / CLAUDE.md with clear instruction blocks for agent adherence (named contract) |
| `design-eng` | Default: design-engineering taste for UI and motion work (layout, spacing, animation, polish pass; named contract) |
| `review-animations` | Pre-ship gate: review all animations for timing, easing, purpose, reduced-motion, and performance |
| `animation-vocabulary` | Shared vocabulary for motion feedback; translates vague UI feedback to concrete properties |
| `pick-ui-library` | Structured comparison to choose a UI component or animation library |
| `find-animation-opportunities` | Scan UI for places where animation improves clarity, feedback, or delight |
| `grill-me` | Stress-test a change before building or shipping; routes to pstack /interrogate |
| `refactor-first` | Default: refactor then change on non-trivial behavior changes in existing modules (named contract) |
| `progressive-disclosure` | Default: public-seam design with four-layer progressive disclosure (named contract) |
| `pit-of-success` | Default: make the obvious call correct; footgun test on public seams (named contract) |
| `zero-tech-debt` | Default: reshape toward intended end state; delete dead compatibility (named contract) |
| `ux-flow-plan` | Default: UX flow trees (current vs desired) then file/function anchors (named contract) |
| `desk-boxes` | Default: box / worktree / session / port / desk-config orientation (named contract) |
| `local-preview` | Default: run worktree server on reserved port and open in desk UI (named contract) |
| `event-hooks` | Default: event hooks and before-gates (named contract; not software-factory-gates) |
| `agent-cli-lanes` | Available: install/wire Cursor, Claude Code, Codex, Gemini CLI, OpenCode, Devin |
| `code-refactor-review` | Review diffs/PRs for reuse, composition, consistency, and slop |
| `prepare-branch-context` | Read-only branch catch-up (diff from main, commits, related PR) |
| `create-draft-pr` | Commit, push, open draft PR with Summary/Problem/(UX Flow)/Solution |
| `parallel-task` | Parallel kickoff on a fresh branch via cloud agent or fleet workstream (no ga/tmux/Pi) |
| `parallel-pr-followup` | Parallel follow-up on an existing PR/branch (no ga/tmux/Pi) |
| `e2e-verify` | Require a real e2e path for end-to-end product claims (pairs with verify-this) |
| `inference-perf` | Operational checks for LLM inference serving performance (TTFT, TPOT, KV cache, parallelism, quantization) |
| `perf-watch` | Routine that watches production traces and metrics; on a regression a worker reproduces on staging, fixes, and opens a draft PR with before and after numbers |

### Agents

| Agent | Description |
|:------|:------------|
| `ci-watcher` | Monitor GitHub Actions runs and return concise pass/fail summaries |
| `thermo-nuclear-code-quality-review` | Task subagent that runs the thermo-nuclear code quality rubric against a diff |

### Rules

| Rule | Description |
|:-----|:------------|
| `typescript-exhaustive-switch` | Require exhaustive switch handling for unions/enums |
| `no-inline-imports` | Keep imports at module top-level for readability and consistency |

## License

MIT
