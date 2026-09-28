### Greenfield full-stack

**You sequence existing pstack roles. You do not invent a vendor router.** Match: greenfield app or product from scratch, full-stack one-shot, new product with backend and frontend in one run. This playbook does not replace Feature for single-layer work. It is not an always-on default.

0. **Fail closed on project constraints.** Read `AGENTS.md`, or `CLAUDE.md` if that is the project constraint file. Require at least one project agent constraints file and a clear Done means / Keep path (or an equivalent falsifiable done check the constraints already name). If either is missing, STOP and report. Do not invent `AGENTS.md`. Do not invent constraints. Do not encode.

1. **Plan.** Own the plan on your hardest-tasks and judgment-and-prose models (per Subagents and `/setup-pstack` role lines). Name the data shapes and their organizing structures per **principle-model-the-domain**. Do not invent a vendor router. Do not invent new roles. Use the roles already configured.

2. **Backend encode.** Run the Feature playbook steps (`playbooks/feature.md`) scoped to the backend, using your configured **feature** model. Review the diff yourself. Commit liberally.

3. **Frontend encode.** Run the Feature playbook steps scoped to the frontend, using your configured **feature** model. When the ask is `ui:yes` / Figma, **figma-from-system** still applies as the existing default before encode. Review the diff yourself. Commit liberally.

4. **Adversarial test.** `interrogate` the contested surfaces, then prove on the real surface per **principle-prove-it-works** (`control-ui` or `control-cli` as the matching control skill). "Inconclusive" or wrong-surface is not a pass.

5. **Docs.** Write user-facing and maintainer-facing docs on your judgment-and-prose model. Apply **orwell-prose** for the sentences and **technical-writing** for structure (both already default / existing).

6. Run **Opening a PR**.

**Reply:** what you built across backend and frontend workstreams, data shapes chosen, adversarial evidence, docs landed, open decisions. Say plainly that this playbook sequenced existing roles and did not replace Feature for single-layer work.

