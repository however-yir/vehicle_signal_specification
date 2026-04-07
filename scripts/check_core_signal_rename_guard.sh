#!/bin/sh
set -eu

BASE_REF="${1:-origin/master}"
HEAD_REF="${2:-HEAD}"
ALLOWLIST_FILE="governance/core_signal_rename_allowlist.txt"

if [ "${ALLOW_CORE_SIGNAL_RENAME:-0}" = "1" ]; then
  echo "[rename-guard] ALLOW_CORE_SIGNAL_RENAME=1, skipping guard."
  exit 0
fi

if ! git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
  echo "[rename-guard] Base ref '$BASE_REF' not found, skipping."
  exit 0
fi

DIFF_CONTENT=$(git diff -U0 "$BASE_REF" "$HEAD_REF" -- spec ":(exclude)spec/extensions/**")

REMOVED_KEYS=$(printf "%s\n" "$DIFF_CONTENT" | awk '
  /^--- / {next}
  /^-/ {
    if ($0 ~ /^-[A-Za-z][A-Za-z0-9_.\[\]"-]*:[[:space:]]*$/) {
      sub(/^-/, "", $0)
      sub(/:[[:space:]]*$/, "", $0)
      print $0
    }
  }
' | sort -u)

if [ -z "$REMOVED_KEYS" ]; then
  echo "[rename-guard] No core signal removals detected."
  exit 0
fi

VIOLATIONS=""
for key in $REMOVED_KEYS; do
  if [ -f "$ALLOWLIST_FILE" ] && grep -q "^${key}$" "$ALLOWLIST_FILE"; then
    continue
  fi
  VIOLATIONS="$VIOLATIONS $key"
done

if [ -n "$VIOLATIONS" ]; then
  echo "[rename-guard] Core signal rename/removal detected:${VIOLATIONS}"
  echo "[rename-guard] Add approved exceptions to $ALLOWLIST_FILE if intentional."
  exit 1
fi

echo "[rename-guard] Core signal rename guard passed."
