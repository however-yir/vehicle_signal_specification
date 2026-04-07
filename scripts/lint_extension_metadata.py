# Copyright (c) 2026 Contributors to COVESA
#
# This program and the accompanying materials are made available under the
# terms of the Mozilla Public License 2.0 which is available at
# https://www.mozilla.org/en-US/MPL/2.0/
#
# SPDX-License-Identifier: MPL-2.0

"""Lint extension signal metadata and naming constraints."""

from __future__ import annotations

import argparse
import json
import pathlib
import re
import sys
from typing import Any

DEFAULT_METADATA = pathlib.Path("spec/extensions/metadata/myco_signals.json")
DEFAULT_VSPEC = pathlib.Path("spec/extensions/MyCo/MyCo.vspec")
UNITS_FILE = pathlib.Path("spec/units.yaml")
QUANTITIES_FILE = pathlib.Path("spec/quantities.yaml")

PATH_PATTERN = re.compile(r"^Vehicle\.MyCo\.[A-Za-z0-9_.]+$")
VSPEC_KEY_PATTERN = re.compile(r"^([A-Za-z][A-Za-z0-9_.\[\]" + '"' + r"-]*):\s*$")
VALID_ACCESS = {"ro", "rw", "write-once"}
VALID_SAFETY = {"QM", "ASIL-A", "ASIL-B", "ASIL-C", "ASIL-D"}
VALID_PRIVACY = {"none", "pii", "sensitive-pii"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--metadata", type=pathlib.Path, default=DEFAULT_METADATA)
    parser.add_argument("--vspec", type=pathlib.Path, default=DEFAULT_VSPEC)
    return parser.parse_args()


def load_simple_yaml_keys(path: pathlib.Path) -> set[str]:
    keys: set[str] = set()
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.rstrip()
        if not line or line.lstrip().startswith("#"):
            continue
        if line.startswith(" "):
            continue
        if ":" not in line:
            continue
        key = line.split(":", 1)[0].strip()
        if key:
            keys.add(key)
    return keys


def load_vspec_keys(path: pathlib.Path) -> set[str]:
    keys: set[str] = set()
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        match = VSPEC_KEY_PATTERN.match(line)
        if match:
            keys.add(match.group(1))
    return keys


def fail(errors: list[str], message: str) -> None:
    errors.append(message)


def as_bool(value: Any) -> bool:
    if isinstance(value, bool):
        return value
    return str(value).lower() in {"1", "true", "yes"}


def main() -> int:
    args = parse_args()
    if not args.metadata.exists():
        print(f"Metadata file not found: {args.metadata}", file=sys.stderr)
        return 1

    payload = json.loads(args.metadata.read_text(encoding="utf-8"))
    signals = payload.get("signals", [])
    if not isinstance(signals, list) or not signals:
        print("Metadata must contain a non-empty 'signals' list.", file=sys.stderr)
        return 1

    units = load_simple_yaml_keys(UNITS_FILE)
    quantities = load_simple_yaml_keys(QUANTITIES_FILE)
    vspec_keys = load_vspec_keys(args.vspec)

    seen_paths: set[str] = set()
    errors: list[str] = []

    for idx, signal in enumerate(signals):
        prefix = f"signals[{idx}]"
        path = str(signal.get("path", "")).strip()
        owner = str(signal.get("owner", "")).strip()
        unit = str(signal.get("unit", "")).strip()
        quantity = str(signal.get("quantity", "")).strip()
        access = str(signal.get("access", "")).strip()
        safety = str(signal.get("safety_level", "")).strip()
        privacy = str(signal.get("privacy_class", "")).strip()
        deprecated = as_bool(signal.get("deprecated", False))
        replacement = str(signal.get("replacement", "")).strip()
        signal_range = signal.get("range")

        if not PATH_PATTERN.match(path):
            fail(errors, f"{prefix}: invalid path '{path}', must match Vehicle.MyCo.*")

        if path in seen_paths:
            fail(errors, f"{prefix}: duplicated path '{path}'")
        seen_paths.add(path)

        if path not in vspec_keys:
            fail(errors, f"{prefix}: path '{path}' not found in {args.vspec}")

        if not owner or "@" not in owner:
            fail(errors, f"{prefix}: owner must be a non-empty contact (e.g. team@example.com)")

        if access not in VALID_ACCESS:
            fail(errors, f"{prefix}: access '{access}' must be one of {sorted(VALID_ACCESS)}")

        if safety not in VALID_SAFETY:
            fail(errors, f"{prefix}: safety_level '{safety}' must be one of {sorted(VALID_SAFETY)}")

        if privacy not in VALID_PRIVACY:
            fail(errors, f"{prefix}: privacy_class '{privacy}' must be one of {sorted(VALID_PRIVACY)}")

        if unit:
            if unit not in units:
                fail(errors, f"{prefix}: unit '{unit}' not found in spec/units.yaml")
            if not quantity:
                fail(errors, f"{prefix}: quantity must be provided when unit is set")

        if quantity and quantity not in quantities:
            fail(errors, f"{prefix}: quantity '{quantity}' not found in spec/quantities.yaml")

        if signal_range is not None:
            if not isinstance(signal_range, dict):
                fail(errors, f"{prefix}: range must be an object or null")
            else:
                min_val = signal_range.get("min")
                max_val = signal_range.get("max")
                if min_val is None or max_val is None:
                    fail(errors, f"{prefix}: range.min and range.max are required when range is set")
                elif not isinstance(min_val, (int, float)) or not isinstance(max_val, (int, float)):
                    fail(errors, f"{prefix}: range values must be numeric")
                elif min_val > max_val:
                    fail(errors, f"{prefix}: range.min must be <= range.max")

        if deprecated and not replacement:
            fail(errors, f"{prefix}: deprecated signal must declare replacement path")

    if errors:
        print("Extension metadata lint failed:")
        for err in errors:
            print(f"- {err}")
        return 1

    print("Extension metadata lint passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
