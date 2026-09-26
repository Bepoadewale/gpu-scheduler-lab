#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

make clean-local
make install
make bootstrap-local
make smoke
make dashboard
curl -fsS http://127.0.0.1:18081/ | grep -q 'SIMULATED HARDWARE'
make demo-kueue
make demo-fair-share
make demo-preemption
make demo-starvation
make demo-gang
make verify
make dashboard-stop
make clean-local

# A second bootstrap proves the demos do not depend on retained project state.
make bootstrap-local
make smoke
make dashboard
curl -fsS http://127.0.0.1:18081/ | grep -q 'SIMULATED HARDWARE'
make demo-kueue
make demo-fair-share
make demo-preemption
make demo-starvation
make demo-gang
make dashboard-stop
make clean-local
