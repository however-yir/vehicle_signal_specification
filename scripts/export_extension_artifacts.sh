#!/bin/sh
set -eu

OUT_ROOT="${1:-artifacts/extensions}"
VERSION_FILE="spec/extensions/VERSION"
EXT_ROOT="spec/VehicleSignalSpecificationExtensions.vspec"
COMMON_ARGS="-u ./spec/units.yaml --strict"

if ! command -v vspec >/dev/null 2>&1; then
  echo "vspec command not found. Install vss-tools first." >&2
  exit 1
fi

if [ ! -f "$VERSION_FILE" ]; then
  echo "Missing $VERSION_FILE" >&2
  exit 1
fi

VERSION=$(tr -d '[:space:]' < "$VERSION_FILE")
OUT_DIR="$OUT_ROOT/$VERSION"
mkdir -p "$OUT_DIR/sdk"

vspec export json $COMMON_ARGS -s "$EXT_ROOT" -o "$OUT_DIR/vss_extensions.json"
vspec export csv $COMMON_ARGS -s "$EXT_ROOT" -o "$OUT_DIR/vss_extensions.csv"
vspec export franca $COMMON_ARGS --franca-vss-version "$VERSION" -s "$EXT_ROOT" -o "$OUT_DIR/vss_extensions.fidl"
vspec export ddsidl $COMMON_ARGS -s "$EXT_ROOT" -o "$OUT_DIR/vss_extensions.idl"
vspec export jsonschema $COMMON_ARGS -s "$EXT_ROOT" -o "$OUT_DIR/vss_extensions.schema.json"

python3 scripts/generate_sdk_constants.py \
  --metadata spec/extensions/metadata/myco_signals.json \
  --out-dir "$OUT_DIR/sdk"

echo "Extension artifacts exported to $OUT_DIR"
