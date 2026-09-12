---
name: session-retro
description: Mine a finished session for lessons worth encoding. Extracts user corrections, repeated workarounds, and shipped-broken patterns, then routes each to a rule, skill, gate, or close-loop entry. Use for "go through my sessions", "take the lessons from that session", "what should we encode".
---

# Session retro

Available as `/factory-baseline:session-retro`.

The close-loop play, run over a finished session instead of a single
turn. Output is a findings report plus proposed encodes — not a
transcript summary.

## Sources

- Local sessions: `~/.config/devin/cli/summaries/history_*.md` (Linux) or
  `%APPDATA%\devin\cli\summaries\` (Windows). Pick by `LastWriteTime` or
  the session the human names.
- Cloud sessions: no CLI/API transcript access — ask the human to paste
  the relevant stretch, or work from the GitHub artifacts the session
  produced (PR diffs, review comments, commit messages).
- GitHub trail: `gh pr view <n> --comments` and review-comment bodies are
  corrections too.

## Method

1. Extract user turns — `=== MESSAGE N - User ===` markers in Devin
   transcripts. These are the verbatim correction stream.
2. Mark the signals: explicit corrections ("no", "don't", "not what I
   asked"), repeated questions (the same status check asked twice is a
   missing tool), workarounds reused, features reported broken after
   "done".
3. Cluster into preference atoms: trigger, expected behavior, confidence
   (strong = explicit correction or repeat; weak = single occurrence).
4. Route each cluster to the smallest structure that holds it:
   - general behavior → a rule line or new rule
   - recurring multi-step workflow → a skill
   - same mistake caught twice → a lint/CI gate, not prose
   - repo-local smell → `scripts/close-loop.mjs record` where the ledger
     exists
5. Report: atom, evidence (session + paraphrased turn, never raw secrets),
   proposed artifact, confidence. Existing rules that already cover it
   get named and skipped — do not re-encode what is encoded.

## Boundaries

- Transcripts can contain pasted credentials and private paths. Quote
  corrections, never the secret values.
- No artifact for one-off taste, spend, or timing complaints.
- Contradicted atoms surface as a question, not a guess.
