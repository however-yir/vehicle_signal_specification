# Upstream Difference List

This file tracks intentional differences between this repository and upstream
`COVESA/vehicle_signal_specification`.

## Current Differences

1. Added extension layer under `spec/extensions/` using `Vehicle.MyCo.*` namespace.
2. Added enterprise governance metadata and validation scripts.
3. Added schema diff reporting and compatibility guard workflows.
4. Added mapping assets for CAN/UDS and cloud telemetry integration.
5. Added SDK constant generation script for application-side integration.
6. Added quarterly upstream sync workflow and policy documents.

## Sync Notes

- Standard trunk files in `spec/` should remain as close as possible to upstream.
- Enterprise-specific changes should stay in extension/governance/mapping paths.
- Update this list whenever a non-upstream change is introduced.
