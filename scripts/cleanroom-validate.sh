#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

make clean-local
make install
make bootstrap-local
make smoke
make demo-kueue
make demo-fair-share
make demo-preemption
make demo-starvation
make demo-gang
make verify
make clean-local

# A second bootstrap proves the demos do not depend on retained project state.
make bootstrap-local
make smoke
make demo-kueue
make demo-fair-share
make demo-preemption
make demo-starvation
make demo-gang
make clean-local
