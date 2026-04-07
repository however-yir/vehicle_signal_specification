# VSS Extensions Layer

This directory hosts enterprise-specific extensions that are intentionally
separated from the VSS standard trunk in `spec/`.

## Design Rules

1. Keep standard trunk and extension layer separated.
2. Do not rename standard core signal names in `spec/` without explicit review.
3. New enterprise signals must use the `Vehicle.MyCo.*` namespace.
4. Extension metadata is maintained in `spec/extensions/metadata/`.
5. Extension entry root is `spec/extensions/VehicleSignalSpecificationExtensions.vspec`.

## Files

- `VehicleSignalSpecificationExtensions.vspec`: extension-aware entry file.
- `MyCo/MyCo.vspec`: example enterprise extension catalog.
- `metadata/myco_signals.json`: governance metadata for extension signals.
- `VERSION`: extension schema semantic version.
