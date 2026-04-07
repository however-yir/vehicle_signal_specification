# Copyright (c) 2026 Contributors to COVESA
#
# This program and the accompanying materials are made available under the
# terms of the Mozilla Public License 2.0 which is available at
# https://www.mozilla.org/en-US/MPL/2.0/
#
# SPDX-License-Identifier: MPL-2.0

"""Generate SDK constants from extension signal metadata."""

from __future__ import annotations

import argparse
import json
import pathlib
import re


DEFAULT_METADATA = pathlib.Path("spec/extensions/metadata/myco_signals.json")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--metadata", type=pathlib.Path, default=DEFAULT_METADATA)
    parser.add_argument("--out-dir", type=pathlib.Path, required=True)
    return parser.parse_args()


def const_name(path: str) -> str:
    return re.sub(r"[^A-Za-z0-9]", "_", path).upper()


def write_ts(paths: list[str], out_file: pathlib.Path) -> None:
    lines = [
        "// Generated file. Do not edit manually.",
        "",
    ]
    for path in paths:
        lines.append(f'export const {const_name(path)} = "{path}";')
    lines.append("")
    out_file.write_text("\n".join(lines), encoding="utf-8")


def write_c(paths: list[str], out_file: pathlib.Path) -> None:
    guard = "VSS_EXTENSIONS_CONSTANTS_H_"
    lines = [
        "/* Generated file. Do not edit manually. */",
        f"#ifndef {guard}",
        f"#define {guard}",
        "",
    ]
    for path in paths:
        lines.append(f'#define {const_name(path)} "{path}"')
    lines.extend(["", f"#endif  /* {guard} */", ""])
    out_file.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    args = parse_args()
    payload = json.loads(args.metadata.read_text(encoding="utf-8"))
    signals = payload.get("signals", [])
    paths = sorted({str(item.get("path", "")).strip() for item in signals if item.get("path")})

    args.out_dir.mkdir(parents=True, exist_ok=True)
    write_ts(paths, args.out_dir / "vss_constants.ts")
    write_c(paths, args.out_dir / "vss_constants.h")

    print(f"Generated SDK constants for {len(paths)} signals in {args.out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
