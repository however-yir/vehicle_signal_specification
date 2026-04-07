# Copyright (c) 2026 Contributors to COVESA
#
# This program and the accompanying materials are made available under the
# terms of the Mozilla Public License 2.0 which is available at
# https://www.mozilla.org/en-US/MPL/2.0/
#
# SPDX-License-Identifier: MPL-2.0

"""Enforce schema freeze policy based on governance/schema_freeze_state.json."""

from __future__ import annotations

import argparse
import json
import pathlib
import subprocess
import sys
from typing import Iterable

FREEZE_STATE_PATH = pathlib.Path("governance/schema_freeze_state.json")
ALLOWLIST_PATH = pathlib.Path("governance/freeze_allowlist.txt")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", default="origin/master")
    parser.add_argument("--head", default="HEAD")
    parser.add_argument("--require-frozen", action="store_true")
    return parser.parse_args()


def read_freeze_state() -> str:
    if not FREEZE_STATE_PATH.exists():
        return "OPEN"
    with FREEZE_STATE_PATH.open("r", encoding="utf-8") as handle:
        payload = json.load(handle)
    return str(payload.get("status", "OPEN")).upper()


def read_allowlist() -> set[str]:
    if not ALLOWLIST_PATH.exists():
        return set()
    entries = set()
    for raw in ALLOWLIST_PATH.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        entries.add(line)
    return entries


def changed_files(base: str, head: str) -> list[str]:
    cmd = ["git", "diff", "--name-only", base, head]
    out = subprocess.check_output(cmd, text=True)
    return [line.strip() for line in out.splitlines() if line.strip()]


def is_schema_path(path: str) -> bool:
    return path.startswith("spec/") or path.startswith("mapping/")


def match_allowlist(path: str, patterns: Iterable[str]) -> bool:
    for pattern in patterns:
        if pattern.endswith("/**"):
            prefix = pattern[:-3]
            if path.startswith(prefix):
                return True
        elif path == pattern:
            return True
    return False


def main() -> int:
    args = parse_args()
    try:
        state = read_freeze_state()
    except Exception as exc:  # pylint: disable=broad-except
        print(f"Failed to read freeze state: {exc}", file=sys.stderr)
        return 1

    if args.require_frozen and state != "FROZEN":
        print(
            "Schema freeze status is "
            f"{state}; release gate requires FROZEN.",
            file=sys.stderr,
        )
        return 1

    if state != "FROZEN":
        print(f"Schema freeze status is {state}; checks passed.")
        return 0

    allowlist = read_allowlist()
    files = changed_files(args.base, args.head)

    blocked = []
    for path in files:
        if not is_schema_path(path):
            continue
        if match_allowlist(path, allowlist):
            continue
        blocked.append(path)

    if blocked:
        print("Schema is FROZEN; the following schema/mapping files changed:")
        for path in blocked:
            print(f"- {path}")
        print("Add approved paths to governance/freeze_allowlist.txt if needed.")
        return 1

    print("Schema freeze check passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
