---
name: seat-kit
description: Detect a repo's dominant languages and seat the matching language kits - vendor the repo-side gates/configs/CI workflow and install the kit plugin for the agent side. Use for "install the language kit", "add the lua kit", "seat kits here", or when a factory repo gains a new language.
---

# Seat kit

Available as `/factory-baseline:seat-kit`. Detects which language kits a
repo needs and seats both halves: repo-side gates (scripts, configs, CI)
and agent-side skills/rules (the kit plugin).

Kits live in `Dahhrk/devin-factory-plugins` under `plugins/<lang>-kit`
(mirror of plug-factory). Each carries `skills/`, `rules/`, `scripts/`,
`templates/`.

## Steps

1. **Census the repo.** Count source files by extension; take the
   dominant languages. Map to kit names — mostly literal
   (`.lua`→lua-kit, `.py`→python-kit, `.go`→go-kit), watch aliases:
   `.ts/.tsx`→typescript-kit, `.cs`→csharp-kit, `.ps1/.psm1`→powershell-kit,
   `.js/.jsx`→javascript-kit, `.rs`→rust-kit, `.html`→html-kit,
   `.css/.scss`→css-kit/scss-kit. `.yml/.yaml`, `.json`, `.md` alone are
   not kits.
2. **Skip what doesn't apply.** A stray file or two does not justify a
   kit — a vendored gate guarding one file is noise. Report skipped
   detections so the human can override.
3. **Vendor repo-side gates** for each matching kit:
   - `scripts/*` → repo `scripts/`
   - `templates/github-workflows/*` → repo `.github/workflows/`
   - other `templates/*` configs → repo root (a kit's README names the
     exact target filename, e.g. `luacheckrc` → `.luacheckrc`)
   - Executable bit on vendored `.sh` files (`git update-index --chmod=+x`
     on Windows checkouts) — the attribution gate fails on lost exec bits.
4. **Install the agent side.** `devin plugins install <kit>` — a local
   checkout path (`./plugins/lua-kit`) or the git-subdir spec
   (`https://github.com/Dahhrk/devin-factory-plugins#plugins/lua-kit`).
   Cloud sessions get kits only from the org manifest (org-wide, admin
   action) — surface it as a suggestion, do not treat local install as
   sufficient for cloud.
5. **True the blueprint.** If the kit ships a CI workflow, the repo's
   `.devin/blueprint.yaml` `knowledge` should mention the local gate
   commands it adds.
6. **Verify.** Run the vendored Tier-0 gate script locally if its tool
   exists (`bash scripts/lua-rg-gate.sh .`); a gate that can't run in
   this environment gets a noted skip, not a green claim.
7. **Ship.** Feature branch, draft PR `chore: seat <lang> kit` — kit
   files only. Report what was seated, what was skipped, and which side
   still needs the org manifest.

Already-seated kits are idempotent: if the scripts and plugin are
present, report it and move on.
