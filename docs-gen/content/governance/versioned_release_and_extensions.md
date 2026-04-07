---
title: "Versioned Release & Extensions"
weight: 40
---

## Versioned Documentation

This repository publishes documentation in a versioned layout:

- `latest/` for the current master branch.
- `versions/<tag>/` for tagged releases.

Workflow: `.github/workflows/docs-versioned.yml`

## Extension Layer

Enterprise-specific signals are maintained under:

- `spec/extensions/VehicleSignalSpecificationExtensions.vspec`
- `spec/extensions/MyCo/MyCo.vspec`
- `spec/extensions/metadata/myco_signals.json`

## Governance Checks

- Naming and metadata lint: `scripts/lint_extension_metadata.py`
- Core rename guard: `scripts/check_core_signal_rename_guard.sh`
- Schema compatibility: `scripts/check_schema_compat.py`
- Schema freeze: `scripts/check_schema_freeze.py`
- Diff report: `scripts/generate_diff_report.sh`
