# Schema Freeze Process

## Goal

Stabilize signal schema before release and avoid last-minute incompatible changes.

## Freeze States

- `OPEN`: regular development mode.
- `FROZEN`: release preparation mode.

State file: `governance/schema_freeze_state.json`

## Freeze Rules (FROZEN)

1. No path rename/removal in `spec/` and `spec/extensions/`.
2. Only critical fixes are allowed with reviewer approval.
3. Metadata and mapping updates must include compatibility note.
4. `SIGNAL_CHANGELOG.md` must be updated for each accepted change.

## Entry Criteria

- All compatibility checks pass.
- Diff report generated.
- Release reviewer confirms no unresolved schema risk.

## Exit Criteria

- Release artifact generation succeeds.
- Version and changelog are finalized.
- Freeze state switched back to `OPEN`.
