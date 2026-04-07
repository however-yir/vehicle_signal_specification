#!/bin/sh
set -eu

REPO="${1:-${GITHUB_REPOSITORY:-}}"

if [ -z "$REPO" ]; then
  echo "Usage: $0 <owner/repo> or set GITHUB_REPOSITORY" >&2
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI not found" >&2
  exit 1
fi

# Requires gh auth token with repo scope.
gh api -X PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/$REPO/topics" \
  -f names[]='vss' \
  -f names[]='sdv' \
  -f names[]='cockpit' \
  -f names[]='vehicle-signals' \
  -f names[]='automotive'

echo "Updated GitHub topics for $REPO"
