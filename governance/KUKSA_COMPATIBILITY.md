# Kuksa Compatibility Test Scope

This repository performs a Kuksa compatibility smoke test by validating:

1. Exported schema contains a `Vehicle` root namespace.
2. Extension paths are rooted at `Vehicle.MyCo.*`.
3. No malformed path segments in exported JSON.
4. Optional local integration check can be run when Kuksa tooling is available.

Script entrypoint: `scripts/kuksa_compat_check.sh`
