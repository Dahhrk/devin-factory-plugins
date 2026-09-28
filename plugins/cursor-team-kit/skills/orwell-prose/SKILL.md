---
name: orwell-prose
description: Default plain-writing system for every prose surface (docs, PRs, commits, chat reports, landing copy). Positive rules that build voice, not a word ban list. Agents apply before delivering prose; typing /orwell-prose is optional.
---

# Orwell prose

Default writing system for every non-code prose surface: docs, README, PR
text, commit messages, chat reports, landing copy, and session notes.

Govern prose only. Never rewrite code, identifiers, APIs, flags, file paths,
or technical terms where precision needs them. Prefer everyday English only
where the precise meaning survives.

This is a muscle, not a nail trim. Positive rules teach voice. Pattern
catalogs (unslop) and punctuation gates (no em dash) stay as secondary
checks after these rules, not the main system.

Project-level `AGENTS.md` / `CLAUDE.md` can override voice when a product
needs a different register. Global default is this skill.

## Base rules (Orwell, 1946)

1. Never use a metaphor, simile, or other figure of speech which you are
   used to seeing in print.
2. Never use a long word where a short one will do.
3. If it is possible to cut a word out, always cut it out.
4. Never use the passive where you can use the active.
5. Never use a foreign phrase, a scientific word, or a jargon word if you
   can think of an everyday English equivalent.
6. Break any of these rules sooner than say anything outright barbarous.

## 2026 patch (corrective juxtaposition)

7. Don't build a straw man to knock down. Use "not X, it's Y" once per
   piece, max.
8. Two examples are enough. Don't stretch to three.
9. Don't announce what you're about to say. Say it.
10. Don't end two paragraphs in a row with punchlines.
11. Vary the length and shape of neighboring sentences.
12. Break any of these rules sooner than write like a machine.

## Before you deliver

Review every prose output against rules 1-12 before sending. Even when the
rules are already pasted into context, run a final pass against them every
session. Paste is not practice.

## Operational prompts

### Before / after (illustration)

Bad:

> We comprehensively overhauled the authentication infrastructure to
> leverage robust token rotation, ensuring a seamless and secure experience
> across the entire platform.

Good:

> Login now rotates tokens every hour. Stolen tokens die faster.

### Rewrite old text

1. List every violation of rules 1-12 in the source, with the rule number.
2. Rewrite. Keep facts, numbers, and names.
3. Keep rejected drafts next to the rewrite, each with the exact reason it
   failed. "Don't sound like an agent" fails in different ways; the reason
   line teaches the next pass.

### Commits and PRs

Say what changed and why. No achievement language. No "comprehensive" or
"robust". A reviewer should know the change in one read. Prefer professional
PR titles that name the change.

### Landing copy

One concrete claim per line. Swap test: paste a competitor's name into the
line. If the line still works, rewrite or delete it.

### Session reports

Plain sentences: what changed, what failed, what is next. No emoji
checkmarks. No "Successfully". No "Perfect". No bullet walls. Lead with
three lines.

## Secondary gates (not the main system)

- **unslop** (`pstack`): pattern catalog for AI tells. Use after the rules
  above, not instead of them.
- **No em dash**: factory punctuation gate. Periods or commas. Keep it as a
  gate; do not treat it as the writing system.
- **technical-writing** (`pstack`): Diátaxis / STE / Global English for docs
  structure. Apply orwell-prose to the sentences those layers produce.

## Reply shape

Name which rule changed a sentence when it matters. Keep rejected drafts
with reasons when you rewrote. End with a final pass check: rules 1-12 held,
or which rule you broke on purpose and why (rule 6 / 12).
