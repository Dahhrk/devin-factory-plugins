---
name: factory-init
description: Onboard a repo into the dark factory - AGENTS contract, close-loop set, attribution gate, gates pack. Wraps the kitchen product-bootstrap installer safely. Use for "set up the factory here", "bootstrap this repo", "factory this project".
---

# Factory init

Available as `/factory-init` once `cursor-team-kit` is seated. One-shot
onboarding; the ambient contract (plugin rules) needs nothing - this
installs the repo-local pieces. Runs end-to-end from a bare session: it
self-provisions packs and the kitchen before touching the repo.

## Steps

0. **Self-provision the lane.** Confirm `pstack` and `cursor-team-kit` are
   available (skills resolve, or `.cursor/settings.json` enables them). If
   either is absent, install via the Cursor marketplace path:
   `/add-plugin pstack` then `/add-plugin cursor-team-kit`. Private write
   home is `Dahhrk/plug-factory`; public marketplace twin is
   `Dahhrk/plugins`. `gh auth status`: if there is no account with access
   to the private `Dahhrk` org, stop and say so - auth is the human's job,
   do not improvise credentials. Cloud Agents sessions that already have
   the packs required are a no-op for local install.

1. **Locate the kitchen.** Try `%USERPROFILE%\Projects\dark-factory`, then
   `$DARK_FACTORY_REPO`. If absent:
   `gh repo clone Dahhrk/dark-factory ~/Projects/dark-factory`.

2. **Check for existing files the installer force-overwrites** -
   `AGENTS.md`, `BUGBOT.md`, `PRIVATE.md`. If any exist, read them first;
   after install, merge back any product-specific content the template
   dropped (or keep the repo's version and skip the template for that
   file). Never silently clobber.

3. **Run the installer:**
   `powershell -File <kitchen>/templates/product-bootstrap/install.ps1 -TargetRepo <repo>`
   Add `-WithDesignSkills` only for UI products, `-WithAntiSlop` likewise.

4. **Prune what does not apply.** Non-web/non-UI repos (Lua, C++, services):
   delete `.cursor/rules/anti-ai-ui.mdc` and `scripts/check-anti-ai-ui.mjs` -
   a UI trope gate on a backend is noise.

5. **Seat the language kit(s).** Apply the `seat-kit` procedure
   (`../seat-kit/SKILL.md`, also `/seat-kit` standalone): census the
   repo's extensions via `kits.json`, vendor each matching kit's
   repo-side gates, and install its plugin. If the packs were just
   installed this session and the skill file isn't on disk yet, read it
   from the write-home checkout
   (`cursor-team-kit/skills/seat-kit/SKILL.md`).

6. **Make the blueprint true.** Edit `.devin/blueprint.yaml` `knowledge`
   to the repo's real commands (build.ps1/cmake/npm test - whatever its
   gate actually is). A blueprint naming commands that do not exist is
   worse than none. Cursor-only products still keep `.cursor/settings.json`
   enabling `pstack` and `cursor-team-kit`.

7. **Verify:** `node scripts/close-loop.mjs doctor` prints `ok` when that
   script landed; `.cursor/settings.json` enables the packs; vendored gate
   scripts are executable where the platform supports it.

8. **Ship it.** On a feature branch, draft PR `chore: factory bootstrap` -
   factory files only, never the human's in-flight work. Add the repo to
   `~/Projects/registry.md` if it is not listed.

9. Report what landed, what was merged back from pre-existing files, which
   kits were seated, and that real work now defaults to one-shot-task
   (vague → `/poteto-prompt` → `/poteto-mode`; structured → `/poteto-mode`
   with Done means + Keep; until-X on Cursor → autonomous-run + `/loop`).
   Prose defaults to `orwell-prose` (rules 1-12) on every docs, PR, commit,
   chat report, and landing line. Agents apply automatically; do not wait
   to be asked. `/orwell-prose` names the contract (same shape as
   one-shot-task). `unslop` stays secondary. If the product `AGENTS.md` /
   `CLAUDE.md` needs a different voice, note the override.
   Also name the Day-1 defaults now seated with the kit: `outcome-repeat-back`
   (Goal / Constraints / Done means / Keep before act), `results-not-homework`
   (mergeable artifact exit, no homework list), `fleet-orchestrate` when the
   ask spans multiple workstreams, `teach-to-skill` post-pass after a flow
   recurs twice, `leave-machine-clean` EXIT + on-demand reclaim of local agent
   children, `routine-by-default` for recurring / scheduled / monitor asks,
   `harness-not-training` for capability / agent / AI product work (harnesses
   over frontier training), and fresh `verify-this` evidence before shipping falsifiable
   done or substance merge claims. Ambient `/factory-status` stays quiet when
   healthy and pings only on real drift.
   `/factory-status` remains the health sweep.

The ambient shipping bar is smallest-correct-diff; `/no-comments` and
`/deslop` before ready.
