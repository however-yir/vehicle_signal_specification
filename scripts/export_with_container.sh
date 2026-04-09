#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="${1:-all}"

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker command not found." >&2
  exit 1
fi

docker run --rm \
  -v "${ROOT_DIR}:/workspace" \
  -w /workspace \
  python:3.11-slim \
  bash -lc "apt-get update >/dev/null && apt-get install -y --no-install-recommends make git >/dev/null && pip install --no-cache-dir --upgrade pip >/dev/null && pip install --no-cache-dir git+https://github.com/COVESA/vss-tools@master >/dev/null && make ${TARGET}"

echo "container export target '${TARGET}' completed."
