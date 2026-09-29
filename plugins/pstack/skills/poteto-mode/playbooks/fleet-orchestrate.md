### Fleet orchestrate

**You sequence a parent plus named workstream specialists. You do not invent a vendor router.** Match: an ask that spans multiple workstreams (frontend, backend, research, docs, CI, review, QA) in one run. This playbook does not replace Feature for single-workstream work. It is not an always-on default; the `cursor-team-kit` skill `fleet-orchestrate` is the named default for multi-specialist asks. Use this playbook when poteto-mode matches the same shape opt-in, like Greenfield full-stack.

0. **Fail closed on project constraints.** Read `AGENTS.md`, or `CLAUDE.md` if that is the project constraint file. Require at least one project agent constraints file and a clear Done means / Keep path (or an equivalent falsifiable done check the constraints already name). If either is missing, STOP and report. Do not invent `AGENTS.md`. Do not invent constraints. Do not encode. Also stop if ownership across workstreams cannot be named in plain words.

1. **Parent plate.** Stay parent. Name each workstream in plain nouns (frontend, backend, research, docs, CI, review, QA, design, mobile, registry). Assign one specialist or unit per workstream with clear ownership. Publish an ordered plate: what runs first, what waits, where merge holds sit until child artifacts land. Shared box filesystem is fine for artifacts; memory stays per-agent, so brief each child with what it needs. Do not invent new roles. Use the roles already configured under Subagents and `/setup-pstack`.

2. **Specialist encode.** Run each held workstream (Feature steps in `playbooks/feature.md`, or the matching playbook) under its owner. Parent waits on children. Do not merge or declare Done means met while a hold is open. Review each child diff yourself. Commit liberally inside the child's scope.

3. **Verify before ship.** For every falsifiable Done means claim and every substance merge claim, run **verify-this** (`cursor-team-kit`) and keep the verdict with the plate. `NOT VERIFIED` or `INCONCLUSIVE` blocks Opening a PR on that claim. Builds and self-reports are not evidence.

4. **Docs when the Done means names them.** Write user-facing and maintainer-facing docs on your judgment-and-prose model. Apply **orwell-prose** for the sentences and **technical-writing** for structure.

5. Run **Opening a PR** only after holds cleared and verify-this passed (or the Done means named no falsifiable claim).

**Reply:** workstreams and ownership, ordered plate with holds, child artifact links, verify-this verdicts, open decisions. Say plainly that this playbook sequenced existing roles and did not replace Feature for single-workstream work.
