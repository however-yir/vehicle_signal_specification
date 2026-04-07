# Copyright (c) 2026 Contributors to COVESA
#
# This program and the accompanying materials are made available under the
# terms of the Mozilla Public License 2.0 which is available at
# https://www.mozilla.org/en-US/MPL/2.0/
#
# SPDX-License-Identifier: MPL-2.0

"""Schema compatibility guard: prevent accidental core signal removals."""

from __future__ import annotations

import argparse
import pathlib
import re
import subprocess

ALLOWLIST = pathlib.Path("governance/schema_compat_allowlist.txt")
REMOVED_PATTERN = re.compile(r"^-(?P<key>[A-Za-z][A-Za-z0-9_.\[\]" + '"' + r"-]*):\s*$")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", default="origin/master")
    parser.add_argument("--head", default="HEAD")
    return parser.parse_args()


def load_allowlist() -> set[str]:
    if not ALLOWLIST.exists():
        return set()
    values: set[str] = set()
    for raw in ALLOWLIST.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        values.add(line)
    return values


def git_diff(base: str, head: str) -> str:
    cmd = [
        "git",
        "diff",
        "-U0",
        base,
        head,
        "--",
        "spec",
        ":(exclude)spec/extensions/**",
    ]
    return subprocess.check_output(cmd, text=True)


def removed_keys(diff_text: str) -> set[str]:
    keys: set[str] = set()
    for raw in diff_text.splitlines():
        if raw.startswith("--- "):
            continue
        match = REMOVED_PATTERN.match(raw)
        if match:
            keys.add(match.group("key"))
    return keys


def main() -> int:
    args = parse_args()

    try:
        subprocess.check_call(["git", "rev-parse", "--verify", args.base], stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        print(f"Base ref '{args.base}' not found. Skip compatibility check.")
        return 0

    diff_text = git_diff(args.base, args.head)
    removed = removed_keys(diff_text)
    if not removed:
        print("Schema compatibility check passed: no core signal removal detected.")
        return 0

    allowlist = load_allowlist()
    violations = sorted(key for key in removed if key not in allowlist)
    if violations:
        print("Schema compatibility check failed. Removed core signals detected:")
        for key in violations:
            print(f"- {key}")
        print(f"Add approved exceptions to {ALLOWLIST} if intentional.")
        return 1

    print("Schema compatibility check passed (removed keys are allowlisted).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
