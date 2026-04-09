#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="${ROOT_DIR}/.venv-vspec"

python3 -m venv "${VENV_DIR}"
# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate"
python -m pip install --upgrade pip
"${ROOT_DIR}/scripts/install_vss_tools.sh"

if ! command -v vspec >/dev/null 2>&1; then
  echo "ERROR: vspec not found after bootstrap." >&2
  exit 1
fi

echo "vss-tools bootstrap completed."
echo "activate with: source ${VENV_DIR}/bin/activate"
