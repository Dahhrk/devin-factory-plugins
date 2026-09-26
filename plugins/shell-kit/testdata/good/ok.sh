#!/usr/bin/env bash
# Good fixture: quoted expansions, explicit failure, safe temp.
set -euo pipefail

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

DIR="${1:-.}"
cd "$DIR"

LIST=("a b" "c")
for x in "${LIST[@]}"; do
  printf '%s\n' "$x"
done

# Named download boundary (no pipe-to-shell).
curl -fsSL "https://example.com/payload.tgz" -o "$WORKDIR/payload.tgz"

printf 'ok dir=%s\n' "$DIR" >"$WORKDIR/out"
