# Schema Versioning Policy

This repository adopts `MAJOR.MINOR.PATCH` for extension schema governance.

## Rules

- `MAJOR`: backward-incompatible change (removed/renamed signal path, datatype break).
- `MINOR`: backward-compatible additions (new branch/signal/metadata fields).
- `PATCH`: non-semantic updates (docs, comments, formatting, CI scripts).

## Version Anchors

- Standard trunk version: `spec/Vehicle/Vehicle.vspec` -> `VersionVSS.*`
- Extension layer version: `spec/extensions/VERSION`
- Release changelog: `SIGNAL_CHANGELOG.md`

## Compatibility Guardrails

1. Core standard signal names in `spec/` should not be renamed casually.
2. Extension signals must remain under `Vehicle.MyCo.*` namespace.
3. Any deprecated signal must provide a replacement path.
4. Release candidate must pass schema compatibility and lint checks.
