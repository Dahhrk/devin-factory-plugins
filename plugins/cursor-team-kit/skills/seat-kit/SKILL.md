---
name: seat-kit
description: Detect a repo's dominant languages and seat the matching language kits - vendor the repo-side gates/configs/CI workflow and install the kit plugin for the agent side. Use for "install the language kit", "add the lua kit", "seat kits here", or when a factory repo gains a new language.
---

# Seat kit

Available as `/seat-kit` once `cursor-team-kit` is seated. Detects which
language kits a repo needs and seats both halves: repo-side gates
(scripts, configs, CI) and agent-side skills/rules (the kit plugin).

Kits live in `Dahhrk/plug-factory` under `<lang>-kit` (public twin
`Dahhrk/plugins`). Each carries `skills/`, `rules/`, `scripts/`,
`templates/`.

## Steps

1. **Census the repo.** Count source files by extension and key
   filenames (`Dockerfile`, `Makefile`, `justfile`). Read the kit map
   from `kits.json` at the root of the plug-factory checkout - the same
   source the vendor step pulls kit files from; if it is not cloned:
   `gh repo clone Dahhrk/plug-factory ~/Projects/plug-factory`.
   `language`/`tooling` kits auto-match; `framework` kits
   (react/vite/tailwind/astro) are reported as suggestions only -
   extension alone cannot prove the framework. `.yml/.yaml`, `.json`,
   `.md` alone are not kits.
2. **Skip what doesn't apply.** A stray file or two does not justify a
   kit - a vendored gate guarding one file is noise. Report skipped
   detections so the human can override.
3. **Vendor repo-side gates** for each matching kit:
   - `scripts/*` → repo `scripts/`
   - `templates/github-workflows/*` → repo `.github/workflows/`
   - other `templates/*` configs → repo root (a kit's README names the
     exact target filename, e.g. `luacheckrc` → `.luacheckrc`)
   - Executable bit on vendored `.sh` files (`git update-index --chmod=+x`
     on Windows checkouts) - the attribution gate fails on lost exec bits.
4. **Install the agent side.** `/add-plugin <lang>-kit` via the Cursor
   marketplace path (write home `Dahhrk/plug-factory`; public twin
   `Dahhrk/plugins`). Documented path when `/add-plugin` is unavailable:
   enable the kit under `.cursor/settings.json` from a local checkout of
   the write home. Cloud Agents sessions that already have the kit are a
   no-op for local install.
5. **True the blueprint.** If the kit ships a CI workflow, the repo's
   `.devin/blueprint.yaml` `knowledge` should mention the local gate
   commands it adds. Cursor-only products still keep `.cursor/settings.json`
   enabling `pstack` and `cursor-team-kit` plus any seated kits.
6. **Verify.** Run the vendored Tier-0 gate script locally if its tool
   exists (`bash scripts/lua-rg-gate.sh .`); a gate that can't run in
   this environment gets a noted skip, not a green claim.
7. **Ship.** Feature branch, draft PR `chore: seat <lang> kit` - kit
   files only. Report what was seated, what was skipped, and which side
   still needs marketplace or settings enablement.

Already-seated kits are idempotent: if the scripts and plugin are
present, report it and move on.
