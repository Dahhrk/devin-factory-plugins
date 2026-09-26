#!/usr/bin/env bash
# Named boundary: quote expansions (PSR: quote expansions).
# Prefer arrays and "$@" over unquoted $var / $*.
set -euo pipefail

DIR="${1:-.}"
cd "$DIR"

files=("$@")
for f in "${files[@]}"; do
  printf '%s\n' "$f"
done
