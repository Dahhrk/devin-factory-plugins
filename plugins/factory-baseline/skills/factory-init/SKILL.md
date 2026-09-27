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

5. **Seat the language kit(s).** Census the repo's file extensions; for
   each dominant language check whether the marketplace carries a kit
   (`devin-factory-plugins` → `plugins/<lang>-kit`, or the plug-factory
   twin). For each matching kit:

   - Vendor repo-side gates: `scripts/*` → repo `scripts/`,
     `templates/github-workflows/*` → `.github/workflows/`, other
     `templates/*` configs → repo root (rename `luacheckrc`-style names to
     their dotted form if needed).
   - Install the agent side so skills/rules load in sessions:
     `devin plugins install <kit-path-or-source>` locally; for cloud
     sessions the kit goes on the org manifest's plugin list.
   - Extension→kit is mostly literal (`.lua`→lua-kit, `.py`→python-kit);
     watch aliases: `.ts/.tsx`→typescript-kit, `.cs`→csharp-kit,
     `.ps1/.psm1`→powershell-kit, `.yml/.yaml` alone is not a kit.
   - Skip a kit when the repo only has a stray file or two — a vendored
     gate guarding one file is noise.

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
   kits were seated, and the first suggested run
   (`/factory-baseline:factory-pass` to audit the existing code against
   the contract).

The ambient shipping bar is `rules/code-quality-bar.md`: smallest-correct-diff;
`/no-comments` and `/deslop` before ready.
