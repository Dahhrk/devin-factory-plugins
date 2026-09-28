---
name: factory-init
description: Onboard a repo into the dark factory - .devin/ blueprint+config, AGENTS contract, close-loop set, attribution gate, gates pack. Wraps the kitchen product-bootstrap installer safely. Use for "set up the factory here", "bootstrap this repo", "factory this project".
---

# Factory init

Available as `/factory-baseline:factory-init`. One-shot onboarding; the
ambient contract (plugin rules) needs nothing — this installs the
repo-local pieces. Runs end-to-end from a bare session: it self-provisions
packs and the kitchen before touching the repo.

## Steps

0. **Self-provision the lane.** `devin plugins list`: if
   `dark-factory-pack` is absent, `devin plugins install -y
   Dahhrk/devin-factory-plugins`. `gh auth status`: if there is no account
   with access to the private `Dahhrk` org, stop and say so — auth is the
   human's job, do not improvise credentials. In cloud sessions the org
   required-plugins entry governs instead; a local install there is a
   no-op if plugins are already required.

1. **Locate the kitchen.** Try `%USERPROFILE%\Projects\dark-factory`, then
   `$DARK_FACTORY_REPO`. If absent:
   `gh repo clone Dahhrk/dark-factory ~/Projects/dark-factory`.

2. **Check for existing files the installer force-overwrites** —
   `AGENTS.md`, `BUGBOT.md`, `PRIVATE.md`. If any exist, read them first;
   after install, merge back any product-specific content the template
   dropped (or keep the repo's version and skip the template for that
   file). Never silently clobber.

3. **Run the installer:**
   `powershell -File <kitchen>/templates/product-bootstrap/install.ps1 -TargetRepo <repo>`
   Add `-WithDesignSkills` only for UI products, `-WithAntiSlop` likewise.

4. **Prune what doesn't apply.** Non-web/non-UI repos (Lua, C++, services):
   delete `.cursor/rules/anti-ai-ui.mdc` and `scripts/check-anti-ai-ui.mjs` —
   a UI trope gate on a backend is noise.

5. **Seat the language kit(s).** Apply the `seat-kit` procedure
   (`../seat-kit/SKILL.md`, also `/factory-baseline:seat-kit` standalone):
   census the repo's extensions, vendor each matching kit's repo-side
   gates, and install its plugin. If the packs were just installed this
   session and the skill file isn't on disk yet, read it from the
   marketplace clone (`plugins/factory-baseline/skills/seat-kit/SKILL.md`).

6. **Make the blueprint true.** Edit `.devin/blueprint.yaml` `knowledge`
   to the repo's real commands (build.ps1/cmake/npm test — whatever its
   gate actually is). A blueprint naming commands that don't exist is
   worse than none.

7. **Verify:** `node scripts/close-loop.mjs doctor` prints `ok`;
   `.devin/blueprint.yaml` and `config.json` parse; vendored gate
   scripts are executable where the platform supports it.

8. **Ship it.** On a feature branch, draft PR `chore: factory bootstrap` —
   factory files only, never the human's in-flight work. Add the repo to
   `~/Projects/registry.md` if it isn't listed.

9. Report what landed, what was merged back from pre-existing files, which
   kits were seated, and that real work now defaults to one-shot-task
   (vague compose then poteto; structured enter directly; verifiable
   units + re-invoke; no fake Cursor `/loop`). Autopilot stays off.
   `/factory-baseline:factory-pass` audits existing code against the
   contract when needed.

The ambient shipping bar is `rules/code-quality-bar.md`: smallest-correct-diff;
`/no-comments` and `/deslop` before ready.
