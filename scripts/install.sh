#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PYTHON="${PYTHON:-python3}"
if [ ! -x "$ROOT_DIR/.venv/bin/python" ]; then
  "$PYTHON" -m venv "$ROOT_DIR/.venv"
fi
"$ROOT_DIR/.venv/bin/python" -m pip install 'pytest>=9.0.3,<10' 'ruff>=0.8,<1'
