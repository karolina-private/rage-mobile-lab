#!/usr/bin/env sh
set -eu

for file in README.md NOTES.md UPSTREAMS.md; do
  test -s "$file"
done

grep -q 'user-owned' README.md
grep -q 'Madeira' UPSTREAMS.md

echo 'Documentation checks passed.'
