**Copyright (c) 2016 Contributors to COVESA**<br />

All files and artifacts in this repository are licensed under the
provisions of the license provided by the LICENSE file in this repository.

# RELEASE PROCESS
This document describes the process for creating a new version of the
signal specification.

The process, driven by COVESA with significant input from the W3C Automotive WG, is aimed at being lightweight and carried
out in public, giving both COVESA members and non-members a say in the
creation of a new version.

![Release Process](pics/vss_release_process.png)

In git, the ```master``` branch is used as an integration branch
accepting pull requests with new and modified vpsec files from
contributors.

Pull requests [PR] are **always** initiated from a **fork** and not through
a feature branch in the main repository. PRs are reviewed, discussed and merged
through the public GitHub repository.
A PR is merged earliest after one week to give a fair chance of reviewing.

Each release is incrementally numbered, starting with 1.

A release is tagged in git with the tag:

    v[m.n]

where [m.n] is the release number.

Detailed instructions on how releases are created can be found in the
[Release Instructions and Checklist](https://github.com/COVESA/vehicle_signal_specification/wiki/Release-Instructions-and-Checklist).

## Additional Governance Gates For Extension Layer

For repositories that maintain enterprise extensions (`spec/extensions`) in addition
to the standard trunk, apply these mandatory gates before release:

1. Enable schema freeze by setting `governance/schema_freeze_state.json` to `FROZEN`.
2. Generate and archive schema diff report (`reports/schema-diff.md`).
3. Pass compatibility guard checks:
   - `scripts/check_core_signal_rename_guard.sh`
   - `scripts/check_schema_compat.py`
   - `scripts/check_schema_freeze.py`
4. Pass metadata lint (`scripts/lint_extension_metadata.py`) including:
   - naming prefix (`Vehicle.MyCo.*`)
   - owner/access/safety/privacy fields
   - deprecated + replacement linkage
   - unit/quantity/range validation
5. Generate extension artifacts:
   - JSON / CSV / IDL / FIDL / JSON-Schema
   - SDK constants (`scripts/generate_sdk_constants.py`)
6. Update `SIGNAL_CHANGELOG.md` and `UPSTREAM_DIFF.md`.
7. Re-open schema by setting freeze state back to `OPEN` after release finalization.

## Versioned Documentation Publish

Versioned documentation deploy is handled by:

- `.github/workflows/docs-versioned.yml`

Deployment policy:

- `master` push -> `gh-pages/latest/`
- `v*` tag push -> `gh-pages/versions/<tag>/`
