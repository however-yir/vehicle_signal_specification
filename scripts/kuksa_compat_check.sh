#!/bin/sh
set -eu

EXT_ROOT="spec/VehicleSignalSpecificationExtensions.vspec"
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

if ! command -v vspec >/dev/null 2>&1; then
  echo "vspec command not found. Install vss-tools first." >&2
  exit 1
fi

vspec export id -u ./spec/units.yaml --strict -s "$EXT_ROOT" -o "$TMP_DIR/vss_extensions_id.vspec"

python3 - <<'PY' "$TMP_DIR/vss_extensions_id.vspec"
import re
import sys

path = sys.argv[1]
keys = []
pattern = re.compile(r"^([A-Za-z][A-Za-z0-9_.\[\]" + '"' + r"-]*):\s*$")
with open(path, "r", encoding="utf-8") as handle:
    for raw in handle:
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        m = pattern.match(line)
        if m:
            keys.append(m.group(1))

if not any(k == "Vehicle" or k.startswith("Vehicle.") for k in keys):
    raise SystemExit("Kuksa compatibility check failed: no Vehicle root namespace")

myco_keys = [k for k in keys if k.startswith("Vehicle.MyCo.")]
if not myco_keys:
    raise SystemExit("Kuksa compatibility check failed: no Vehicle.MyCo extension keys found")

for key in myco_keys:
    if ".." in key or key.endswith("."):
        raise SystemExit(f"Malformed key path: {key}")

print("Kuksa compatibility smoke check passed")
PY

if command -v kuksa-databroker-cli >/dev/null 2>&1; then
  echo "kuksa-databroker-cli detected: optional local integration can be executed by project maintainers."
fi
