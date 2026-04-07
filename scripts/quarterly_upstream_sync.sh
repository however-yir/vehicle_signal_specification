#!/bin/sh
set -eu

UPSTREAM_REMOTE="${UPSTREAM_REMOTE:-upstream}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-master}"
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
NOW_UTC="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
YEAR="$(date -u +%Y)"
MONTH="$(date -u +%m | sed 's/^0*//')"
QUARTER=$(( (MONTH - 1) / 3 + 1 ))
REPORT="reports/upstream-sync-${YEAR}-Q${QUARTER}.md"

mkdir -p reports

if ! git remote get-url "$UPSTREAM_REMOTE" >/dev/null 2>&1; then
  {
    echo "# Upstream Sync Report ${YEAR} Q${QUARTER}"
    echo
    echo "- Generated at: \`$NOW_UTC\`"
    echo "- Current branch: \`$CURRENT_BRANCH\`"
    echo "- Result: upstream remote \`$UPSTREAM_REMOTE\` not configured"
  } > "$REPORT"
  echo "Report written to $REPORT"
  exit 0
fi

git fetch "$UPSTREAM_REMOTE" "$UPSTREAM_BRANCH" --quiet

COUNTS=$(git rev-list --left-right --count "$CURRENT_BRANCH...$UPSTREAM_REMOTE/$UPSTREAM_BRANCH")
AHEAD=$(printf "%s" "$COUNTS" | awk '{print $1}')
BEHIND=$(printf "%s" "$COUNTS" | awk '{print $2}')

{
  echo "# Upstream Sync Report ${YEAR} Q${QUARTER}"
  echo
  echo "- Generated at: \`$NOW_UTC\`"
  echo "- Current branch: \`$CURRENT_BRANCH\`"
  echo "- Upstream ref: \`$UPSTREAM_REMOTE/$UPSTREAM_BRANCH\`"
  echo "- Ahead commits: $AHEAD"
  echo "- Behind commits: $BEHIND"
  echo
  echo "## Suggested Action"
  if [ "$BEHIND" -eq 0 ]; then
    echo "No upstream catch-up required this quarter."
  else
    echo "Prepare a controlled sync branch and run full compatibility checks before merge."
  fi
  echo
  echo "## High-Level Diffstat"
  echo
  git diff --stat "$CURRENT_BRANCH" "$UPSTREAM_REMOTE/$UPSTREAM_BRANCH" || true
} > "$REPORT"

echo "Report written to $REPORT"
