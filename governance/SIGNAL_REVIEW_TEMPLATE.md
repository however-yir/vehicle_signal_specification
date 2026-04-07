# Signal Review Template

## 1. Change Type

- [ ] Add signal
- [ ] Modify signal
- [ ] Deprecate signal

## 2. Business Context

Why is this change needed?

## 3. Signal Definition

- Signal path:
- Datatype:
- Unit / quantity:
- Range (min/max):
- Allowed values (if enum/string):

## 4. Governance Metadata

- Owner:
- Access (`ro`/`rw`):
- Safety level (`QM`/`ASIL-*`):
- Privacy class (`none`/`pii`/`sensitive-pii`):
- Deprecated:
- Replacement:

## 5. Compatibility Impact

- Backward compatible:
- Affected consumers (CAN/UDS, cloud telemetry, SDK, apps):
- Migration plan:

## 6. Validation Checklist

- [ ] Naming lint passed
- [ ] Unit/quantity/range validation passed
- [ ] Schema compatibility check passed
- [ ] Diff report generated
- [ ] `SIGNAL_CHANGELOG.md` updated
