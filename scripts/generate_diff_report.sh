#!/bin/sh
set -eu

BASE_REF="${1:-origin/master}"
HEAD_REF="${2:-HEAD}"
OUT_FILE="${3:-reports/schema-diff.md}"

mkdir -p "$(dirname "$OUT_FILE")"

if ! git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
  echo "Base ref '$BASE_REF' not found" >&2
  exit 1
fi

CHANGED_FILES=$(git diff --name-status "$BASE_REF" "$HEAD_REF" -- spec spec/extensions mapping governance README.md | sed '/^$/d' || true)

ADDED_KEYS=$(git diff -U0 "$BASE_REF" "$HEAD_REF" -- spec spec/extensions | awk '
  /^\+\+\+ / {next}
  /^\+/ {
    if ($0 ~ /^\+[A-Za-z][A-Za-z0-9_.\[\]"-]*:[[:space:]]*$/) {
      sub(/^\+/, "", $0)
      sub(/:[[:space:]]*$/, "", $0)
      print $0
    }
  }
' | sort -u)

REMOVED_KEYS=$(git diff -U0 "$BASE_REF" "$HEAD_REF" -- spec spec/extensions | awk '
  /^--- / {next}
  /^-/ {
    if ($0 ~ /^-[A-Za-z][A-Za-z0-9_.\[\]"-]*:[[:space:]]*$/) {
      sub(/^-/, "", $0)
      sub(/:[[:space:]]*$/, "", $0)
      print $0
    }
  }
' | sort -u)

ADDED_COUNT=$(printf "%s\n" "$ADDED_KEYS" | sed '/^$/d' | wc -l | tr -d ' ')
REMOVED_COUNT=$(printf "%s\n" "$REMOVED_KEYS" | sed '/^$/d' | wc -l | tr -d ' ')
FILE_COUNT=$(printf "%s\n" "$CHANGED_FILES" | sed '/^$/d' | wc -l | tr -d ' ')

{
  echo "# Schema Diff Report"
  echo
  echo "- Base: \`$BASE_REF\`"
  echo "- Head: \`$HEAD_REF\`"
  echo "- Generated at: \`$(date -u +"%Y-%m-%dT%H:%M:%SZ")\`"
  echo
  echo "## Summary"
  echo
  echo "| Metric | Count |"
  echo "|---|---:|"
  echo "| Changed files | $FILE_COUNT |"
  echo "| Added signal keys | $ADDED_COUNT |"
  echo "| Removed signal keys | $REMOVED_COUNT |"
  echo
  echo "## Changed Files"
  echo
  if [ -n "$CHANGED_FILES" ]; then
    printf "\n\`\`\`\n%s\n\`\`\`\n" "$CHANGED_FILES"
  else
    echo "No schema-related file changes detected."
  fi
  echo
  echo "## Added Signal Keys"
  echo
  if [ -n "$ADDED_KEYS" ]; then
    printf "%s\n" "$ADDED_KEYS" | sed 's/^/- /'
  else
    echo "- None"
  fi
  echo
  echo "## Removed Signal Keys"
  echo
  if [ -n "$REMOVED_KEYS" ]; then
    printf "%s\n" "$REMOVED_KEYS" | sed 's/^/- /'
  else
    echo "- None"
  fi
} > "$OUT_FILE"

echo "Diff report written to $OUT_FILE"
