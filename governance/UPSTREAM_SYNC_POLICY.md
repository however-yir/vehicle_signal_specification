# Quarterly Upstream Sync Policy

To control fork cost, this repository runs an upstream sync review every quarter.

## Cadence

- Schedule: once every quarter.
- Trigger workflow: `.github/workflows/quarterly-upstream-sync.yml`.

## Deliverables

1. Upstream delta summary report under `reports/`.
2. Risk classification: low / medium / high.
3. Proposed merge plan and rollback notes.
4. Updated `UPSTREAM_DIFF.md`.

## Governance Rules

- Prefer rebasing extension layer logic instead of modifying standard trunk files.
- Any unavoidable standard trunk divergence must be documented.
- Keep extension namespace and metadata isolated from upstream files.
