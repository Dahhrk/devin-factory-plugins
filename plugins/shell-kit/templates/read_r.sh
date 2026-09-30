#!/usr/bin/env bash
# Named boundary: read lines with -r (SC2162).
# Bare `read var` strips backslashes and mangles input; prefer IFS= read -r.
set -euo pipefail

while IFS= read -r line || [[ -n "$line" ]]; do
  printf '%s\n' "$line"
done
