#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

"$ROOT_DIR/scripts/dashboard.sh" stop || true

if kind get clusters | grep -qx "$CLUSTER_NAME"; then
  log "Deleting only kind cluster ${CLUSTER_NAME}"
  kind delete cluster --name "$CLUSTER_NAME"
fi
rm -rf "$ROOT_DIR/.local"
printf 'clean-local: removed only gpu-scheduler-lab project resources\n'
