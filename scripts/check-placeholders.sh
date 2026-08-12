#!/usr/bin/env bash
# Fail if any [[PLACEHOLDER]] token is still in the site.
# Run this before publishing. These tokens are unverified business facts
# (licensure, metrics, hours) that must not go live as-is.
set -uo pipefail

SITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SITE_DIR"

# HTML only. Placeholders never live in CSS or JS, and scanning source files
# just matches the code comments that explain how placeholders are handled.
HITS=$(grep -rn --include='*.html' -o '\[\[[^]]*\]\]' . 2>/dev/null || true)

if [[ -z "$HITS" ]]; then
  echo "OK: no placeholders remain."
  exit 0
fi

echo "BLOCKED: $(echo "$HITS" | wc -l | tr -d ' ') placeholder(s) still present:"
echo
echo "$HITS" | sed 's/^/  /'
echo
echo "Fill these in before publishing. They are claims about licensure,"
echo "capability, and hours that must be verified, not guessed."
exit 1
